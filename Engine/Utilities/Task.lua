local task = {
    _tasks = {},
    _time = 0
}

local function newHandle()
    return {
        cancelled = false,
        running = true
    }
end

local function GetTime()
    
    -- local run = Game:GetService("RunService")
	-- return run.ElapsedTime
    return os.clock()
end

function task.update(dt)
    task._time = task._time + dt
    for i = #task._tasks, 1, -1 do
        local t = task._tasks[i]
        if not t.handle.cancelled and task._time >= t.runAt then
            table.remove(task._tasks, i)
            local status, result = coroutine.resume(t.co, table.unpack(t.args))

            if status then
                -- print("Coroutine completed successfully. Result:", result)
            else
                print("Coroutine error:", result)
            end
            
        elseif t.handle.cancelled then
            table.remove(task._tasks, i)
        end
    end
end

function task.spawn(func, ...)
    local co = coroutine.create(func)
    local handle = newHandle()
    table.insert(task._tasks, {
        co = co,
		args = {...},
        runAt = task._time,
        handle = handle
    })
    return handle
end

function task.delay(seconds, func, ...)
    local co = coroutine.create(func)
    local handle = newHandle()
    table.insert(task._tasks, {
        co = co,
		args = {...},
        runAt = task._time + (seconds or 0),
        handle = handle
    })
    return handle
end

function task.wait(seconds)
    local co = coroutine.running()

    local begin = GetTime()
    local function resumeLater()
        coroutine.resume(co, GetTime() - begin)
    end

    task.delay(seconds or 0, resumeLater)

    return coroutine.yield()
end

function task.cancel(handle)
    if handle then
        handle.cancelled = true
        handle.running = false
    end
end

return task
