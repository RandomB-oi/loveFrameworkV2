local module = {}
module.__index = module
module.__type = "RemoteEvent"
module.__base = require("Engine.Objects.Object")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
	self.Event = self.Maid:Add(Signal.new())

	return self
end

function module:_addEvent(data)
	if type(self) == "string" then
		local connection connection = Object.ObjectCreated:Connect(function(id, object)
			if id == self then
				connection:Disconnect()
				connection = nil

				object:_addEvent(data)
			end
		end)
		return
	end
	if not next(self.Event) then
		task.spawn(function()
			repeat task.wait(1/60) if not self.Parent then return end until next(self.Event)
			self.Event:Fire(unpack(data))
		end)
		return
	end

	self.Event:Fire(unpack(data))
end

function module:FireClient(clientID, ...)
	local runService = Game:GetService("RunService")
	if not runService:IsServer() then return end
	local serverService = Game:GetService("ServerService")
	
	serverService:SendMessage(clientID, "RemoteEvent", {
		ID = self.ID,
		Data = {...},
	})
end

function module:FireAllClients(...)
	local runService = Game:GetService("RunService")
	if not runService:IsServer() then return end
	local serverService = Game:GetService("ServerService")

	serverService:SendMessageAll("RemoteEvent", {
		ID = self.ID,
		Data = {...},
	})
end

function module:FireServer(...)
	local runService = Game:GetService("RunService")
	if not runService:IsClient() then return end
	local clientService = Game:GetService("ClientService")

	clientService:SendMessage("RemoteEvent", {
		ID = self.ID,
		Data = {...},
	})
end


return module:Register()