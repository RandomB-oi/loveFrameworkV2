require("LoaderConfig")

require(GamePath.."Shared.main")
require(GamePath.."Client.main")

local RunService = Game:GetService("RunService")
_G._rootObject = _G._rootObject or Game

love.window.setMode(800, 600, {resizable = true})
love.graphics.setDefaultFilter("nearest", "nearest")

local lastRun, tickTimer = 0, 0

love.update = function(dt)
    dt = dt * RunService:GetProperty("TimeScale")
    
    task.update(dt)
    RunService.DeltaTime = dt
    
    local st = RunService:GetProperty("SyncedTime")
	local fixedStepsDt = st-lastRun
	lastRun = st
    tickTimer = tickTimer + fixedStepsDt
    local fixedTickRate = RunService:GetProperty("FixedTickRate")
    local ticks = 0

	if fixedStepsDt <= -1 then -- when joining a server
		tickTimer = 0
	end

    while tickTimer >= fixedTickRate do
        ticks = ticks + 1
        tickTimer = tickTimer - fixedTickRate
        if ticks < 300 then
            _G._rootObject:_fixedUpdate()
        end
        RunService:SetProperty("CurrentTick", RunService:GetProperty("CurrentTick") + 1)
    end
    _G._rootObject:_update(dt)
end

love.draw = function()
    _G._rootObject:_draw()

    local goodFPS = Color.new(0, 1, 0, 1)
    local okFPS = Color.new(1, 1, 0, 1)
    local stinkyFPS = Color.new(1, 0, 0, 1)
    local fps = math.round(1/RunService:GetProperty("DeltaTime"))
    if fps < 15 then
        stinkyFPS:Apply()
    elseif fps < 30 then
        okFPS:Apply()
    else
        goodFPS:Apply()
    end
    
    love.graphics.drawCustomText(tostring(fps), 12,30,1)
end