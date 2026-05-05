local ogPrint = print
print = function(...)
	ogPrint("[SERVER]", ...)
end
if not _G.LaunchParameters then
	_G.LaunchParameters = {}
	_G.LaunchParameters.sepThread = true
end
_G.LaunchParameters.server = true

require("Engine.main")

local RunService = Game:GetService("RunService")
local ServerService = Game:GetService("ServerService")

local socket = require("socket") -- only used for the sleep command lol

RunService._isServer = true

_G._rootObject = _G._rootObject or Game
require("LoaderConfig")
require(GamePath.."Shared.main")
require(GamePath.."Server.main")

ServerService:StartServer(6767)

local lastTick = os.clock()
local tickRate = 1/20

local lastRun, tickTimer = 0, 0
local function Update(dt)
	dt = dt * RunService:GetProperty("TimeScale")
    task.update(dt)
    RunService.DeltaTime = dt


    local st = RunService:GetProperty("SyncedTime")
	local fixedStepsDt = st-lastRun
	lastRun = st
    tickTimer = tickTimer + fixedStepsDt
    local fixedTickRate = RunService:GetProperty("FixedTickRate")

    while tickTimer >= fixedTickRate do
        tickTimer = tickTimer - fixedTickRate
        _G._rootObject:_fixedUpdate()
        RunService:SetProperty("CurrentTick", RunService:GetProperty("CurrentTick") + 1)
    end

    _G._rootObject:_update(dt)
end

if love.window then
	love.window.setTitle("Server")
end

if _G.LaunchParameters.sepThread then -- running on separate thread
	local channel = love.thread.getChannel("server_events")
	while true do
		local tock = os.clock()
		dt = (tock - lastTick)
		lastTick = tock

		Update(dt)
		local msg = channel:pop()
		if msg == "shutdown" then
			break
		end

		if love.timer then
			love.timer.sleep(tickRate)
		else
			socket.sleep(tickRate)
		end
	end
	ServerService:DisconnectAll()
	print("Close server")
else
	love.update = Update
	
	love.draw = function()
        _G._rootObject:_draw()
	end
end