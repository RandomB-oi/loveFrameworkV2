_G._rootObject = nil

local ogHandler = love.errhand
love.errhand = function(message)
    logError(message, true)
    ogHandler(message)
end

love.load = function()
    _G._rootObject = require("Engine.main")

	_G.LaunchParameters = _G.LaunchParameters or {}
	local RunService = Game:GetService("RunService")

	if _G.LaunchParameters.editor then
		RunService._editor = true
	end

	if _G.LaunchParameters.server then
		-- RunService._editor = false
		RunService._isServer = true
	end

    if RunService:IsEditor() then
        _G._rootObject = require("Editor.main")
    end

    if RunService:IsServer() then
        require("Server")
    else
        require("Client")
    end
end

