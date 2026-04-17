import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.ArrayList;
import java.util.List;

import static java.lang.System.out;

abstract class Proceso implements Runnable {
    private static int nextPid = 1;
    private final int pid;

    protected Proceso() { this.pid = getNextPid(); }
    public int getPid() { return pid; }

    private static synchronized int getNextPid() { return nextPid++; }
}

class lua_State extends Proceso {
    private final Path rutaDeScript;

    public lua_State(Path rutaDeScript) {
        super();
        this.rutaDeScript = rutaDeScript;
        out.printf("Iniciando instancia LuaJIT con PID=%d -> %s\n", getPid(), rutaDeScript.getFileName());
    }

    @Override
    public void run() {
        try {
            ProcessBuilder pb = new ProcessBuilder("luajit", "-l", "import/init", "main.lua", rutaDeScript.toString());
            pb.redirectErrorStream(true);
            
            Process p = pb.start();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()))) {
                List<String> output = new ArrayList<>();
                String line;
                while ((line = reader.readLine()) != null) output.add(line);

                synchronized (out) {
                    out.printf("[%s] PID=%d\n%s\n\n", rutaDeScript.toString(), getPid(), String.join("\n", output));
                }
            }

            int exitCode = p.waitFor();
            out.printf("PID=%d terminado con salida %d\n", getPid(), exitCode);
        } catch (IOException | InterruptedException e) {
            Thread.currentThread().interrupt();
            out.printf("PID=%d error: %s\n", getPid(), e.getMessage());
        }
    }
}

public class backend {
    public static void main(String[] args) throws IOException, InterruptedException {
        Path scriptsDir = Paths.get(".");
        List<lua_State> scriptsToRun = new ArrayList<>();

        try (DirectoryStream<Path> stream = Files.newDirectoryStream(scriptsDir, "program*.lua")) {
            for (Path script : stream) scriptsToRun.add(new lua_State(script));
        } catch (IOException e) {
            out.printf("Error al leer el directorio %s: %s\n", scriptsDir.toString(), e.getMessage());
            return;
        }

        int numThreads = Runtime.getRuntime().availableProcessors();
        ExecutorService executor = Executors.newFixedThreadPool(numThreads);

        for (lua_State script : scriptsToRun) executor.submit(script);

        executor.shutdown();
        executor.awaitTermination(Long.MAX_VALUE, TimeUnit.SECONDS);

        out.println("El backend de Java ha terminado de procesar todos los subprocesos.");
    }
}