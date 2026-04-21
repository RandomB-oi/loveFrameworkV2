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

local socket = require("socket")

RunService._isServer = true

_G._rootObject = _G._rootObject or Game
require("LoaderConfig")
require(GamePath.."Shared.main")
require(GamePath.."Server.main")

ServerService:StartServer(6767)

local lastTick = os.clock()
local tickRate = 1/20

local function Update(dt)
    task.update(dt)
    RunService.DeltaTime = dt
    _G._rootObject:_update(dt)
end

if _G.LaunchParameters.sepThread then -- running on separate thread
	local channel = love.thread.getChannel("server_events")
	while true do
		dt = os.clock() - lastTick
		lastTick = os.clock()

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