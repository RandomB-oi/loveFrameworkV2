require("LoaderConfig")

task.spawn(require, GamePath.."Shared.main")
task.spawn(require, GamePath.."Client.main")

local RunService = Game:GetService("RunService")
_G._rootObject = _G._rootObject or Game

love.window.setMode(800, 600, {resizable = true})

love.update = function(dt)
    -- dt = 1/30
    task.update(dt)
    RunService.DeltaTime = dt
    _G._rootObject:_update(dt)
end

love.draw = function()
    _G._rootObject:_draw()

    local goodFPS = Color.new(0, 1, 0, 1)
    local okFPS = Color.new(1, 1, 0, 1)
    local stinkyFPS = Color.new(1, 0, 0, 1)
    local fps = math.round(1/RunService.DeltaTime)
    if fps < 15 then
        stinkyFPS:Apply()
    elseif fps < 30 then
        okFPS:Apply()
    else
        goodFPS:Apply()
    end
    
    love.graphics.drawCustomText(tostring(fps), 12,30,1)
end