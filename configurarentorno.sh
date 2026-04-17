#!/usr/bin/env bash
set -euo pipefail

function prettyprint() {
    local level=$1
    shift
    local packed=("$@")

    case $level in
        0)
            printf "\e[0;36m[INFO]:\e[0m %s\n" "${packed[*]}"
        ;;
        1)
            printf "\e[0;33m[WARN]:\e[0m %s\n" "${packed[*]}"
        ;;
        2|*)
            printf "\e[0;31m[FAIL]:\e[0m %s\n" "${packed[*]}"
        ;;
    esac
}


prettyprint 0 "Iniciando instalacion. . ."

export MAKEFLAGS="-j$(nproc || echo 2)"
export PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig"

BASE_PATH="$PWD"
LUAROCKS_VERSION="3.13.0"

source /etc/os-release
OS=$ID
CODENAME="${VERSION_CODENAME:-}"

if [ -z "$CODENAME" ]; then
	prettyprint 2 " VERSION_CODENAME vacio."
	exit 1
fi

prettyprint 0 "OS: $OS ($CODENAME)"

java --version > /dev/null 2>&1 && JAVA_INSTALADO=0 || JAVA_INSTALADO=1
mongod --version > /dev/null 2>&1 && MONGOD_INSTALADO=0 || MONGOD_INSTALADO=1
luarocks --version > /dev/null 2>&1 && LUAROCKS_INSTALADO=0 || LUAROCKS_INSTALADO=1

dependencies=(
	luajit wget curl make cmake gfortran gcc g++ build-essential pkg-config
	libssl-dev zlib1g-dev ca-certificates git
	libproj-dev libgeos-dev libgdal-dev
	libblas-dev liblapack-dev
	libwebp-dev protobuf-compiler libprotobuf-dev
	libluajit-5.1-dev libssh2-1-dev
	librsvg2-dev libcurl4-openssl-dev libxml2-dev
	libgit2-dev libjpeg-dev libtiff5-dev libpng-dev
	libfribidi-dev libharfbuzz-dev libcairo2-dev libfontconfig1-dev
	libreadline-dev libncurses-dev unzip zip
	python3-venv python3-pip python3-full
)

if [ "$OS" = "ubuntu" ]; then
	dependencies+=(libfreetype6-dev)
elif [ "$OS" = "debian" ]; then
	dependencies+=(libfreetype-dev)
else
	prettyprint 2 "Distribucion no soportada: $OS"
	exit 1
fi

prettyprint 0 "Instalando dependencias. . ."
sudo apt-get update
sudo apt-get install -y "${dependencies[@]}"

if [ "$LUAROCKS_INSTALADO" -ne 0 ]; then
	prettyprint 0 "Instalando LuaRocks $LUAROCKS_VERSION. . ."

	cd /tmp || exit 1
	rm -rf "luarocks-$LUAROCKS_VERSION"

	wget -q "https://luarocks.org/releases/luarocks-$LUAROCKS_VERSION.tar.gz"
	tar zxf "luarocks-$LUAROCKS_VERSION.tar.gz"
	cd "luarocks-$LUAROCKS_VERSION"

	./configure \
		--with-lua-include=/usr/include/luajit-2.1 \
		--with-lua-bin=/usr/bin \
		--lua-suffix=jit \
		--lua-version=5.1

	make
	sudo make install

	rm -rf "/tmp/luarocks-$LUAROCKS_VERSION"
fi

prettyprint 0 "Instalando paquetes Lua. . ."
sudo luarocks install luasocket || true
sudo luarocks install luasec || true

if [ ! -f "$BASE_PATH/import/Linux/ssh.so" ]; then
	prettyprint 0 "Compilando lua-ssh. . ."

	cd /tmp
	rm -rf /tmp/lua-ssh
	git clone https://github.com/esno/lua-ssh.git
	cd lua-ssh/src

	gcc -O2 -fPIC -I/usr/include/luajit-2.1 -c ssh.c -o ssh.o
	gcc -shared -o ssh.so ssh.o -lluajit-5.1 $(pkg-config --libs libssh2 || echo "-lssh2")

	mkdir -p "$BASE_PATH/import/Linux/"
	cp ssh.so "$BASE_PATH/import/Linux/"

	rm -rf /tmp/lua-ssh
fi

if [ "$JAVA_INSTALADO" -ne 0 ]; then
	prettyprint 0 "Instalando JDK 25. . ."
	cd /tmp

	JDK_DEB="jdk-25_linux-x64_bin.deb"
	JDK_URL="https://download.oracle.com/java/25/latest/$JDK_DEB"

	wget -q -O "$JDK_DEB" "$JDK_URL"
	sudo dpkg -i "$JDK_DEB" || sudo apt-get install -f -y
	rm -f "$JDK_DEB"

	JAVA_PATH=$(update-alternatives --list java | grep jdk-25 | head -n1 || true)
	if [ -n "$JAVA_PATH" ]; then
		sudo update-alternatives --set java "$JAVA_PATH"
	else
		prettyprint 1 "No se pudo configurar JDK 25 automaticamente."
	fi
fi

java -version || true

#if [ "$MONGOD_INSTALADO" -ne 0 ]; then
#	echo "[INFO] Instalando MongoDB. . ."
#
#	MONGODB_GPG_VERSION="8.0"
#	MONGODB_REPO_VERSION="8.2"
#	KEYRING="/usr/share/keyrings/mongodb-server.gpg"
#	LIST_FILE="/etc/apt/sources.list.d/mongodb-org.list"
#
#	MONGO_DIST="$CODENAME"
#
#	if [ "$OS" = "debian" ]; then
#		case "$CODENAME" in
#			trixie|bookworm)
#				MONGO_DIST="bookworm"
#				;;
#			*)
#				MONGO_DIST="$CODENAME"
#				;;
#		esac
#	elif [ "$OS" = "ubuntu" ]; then
#		case "$CODENAME" in
#			jammy|kinetic)
#				MONGO_DIST="jammy"
#				;;
#			*)
#				MONGO_DIST="$CODENAME"
#				;;
#		esac
#	fi
#
#	sudo rm -f "$KEYRING"
#
#	prettyprint 0 "Descargando clave GPG MongoDB. . ."
#	curl -fsSL "https://pgp.mongodb.com/server-${MONGODB_GPG_VERSION}.asc" | \
#		sudo gpg --dearmor -o "$KEYRING"
#
#	sudo chmod 644 "$KEYRING"
#
#	sudo rm -f "$LIST_FILE"
#
#	if [ "$OS" = "debian" ]; then
#		REPO_LINE="deb [ signed-by=$KEYRING arch=amd64 ] https://repo.mongodb.org/apt/debian ${MONGO_DIST}/mongodb-org/${MONGODB_REPO_VERSION} main"
#	else
#		REPO_LINE="deb [ signed-by=$KEYRING arch=amd64 ] https://repo.mongodb.org/apt/ubuntu ${MONGO_DIST}/mongodb-org/${MONGODB_REPO_VERSION} multiverse"
#	fi
#
#	prettyprint 0 "Agregando repositorio MongoDB. . ."
#	echo "$REPO_LINE" | sudo tee "$LIST_FILE" > /dev/null
#
#	sudo apt-get update
#
#	prettyprint 0 "Instalando paquetes MongoDB. . ."
#	sudo apt-get install -y mongodb-org mongodb-mongosh
#
#	if command -v systemctl &>/dev/null; then
#		sudo systemctl daemon-reexec || true
#		sudo systemctl enable mongod
#		sudo systemctl restart mongod
#	fi
#
#	prettyprint 0 "Version instalada:"
#	mongod --version | head -n1
#fi

prettyprint 0 "Configurando entorno Python. . ."
VENV_PATH="$BASE_PATH/entorno"

if [ ! -d "$VENV_PATH" ]; then
	prettyprint 0 "Creando entorno virtual..."
	python3 -m venv "$VENV_PATH"
fi

prettyprint 0 "Asegurando que pip exista..."
"$VENV_PATH/bin/python" -m ensurepip --upgrade || true

prettyprint 0 "Actualizando herramientas base..."
"$VENV_PATH/bin/python" -m pip install --upgrade pip setuptools wheel

prettyprint 0 "Instalando dependencias Python..."
"$VENV_PATH/bin/python" -m pip install pymongo matplotlib pandas numpy scikit-learn umap-learn plotly dash seaborn

prettyprint 0 "Instalacion completada correctamente."
