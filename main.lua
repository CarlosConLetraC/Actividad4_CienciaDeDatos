import("task")

local unpack = unpack or table.unpack
local fileName = (select(1, ...))
task.spawn(blund(loadfile(fileName)), ...)

local task_step = task.step
task.step = nil

while task_step() do end
