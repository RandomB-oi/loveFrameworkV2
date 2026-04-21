local module = {}
module.__index = module
module.__type = "Players"
module.__base = require("Engine.Objects.Services.Service")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("Simulated", true)
module:SetDefaultProperyValue("Visible", false)
module:CreateProperty("CharacterAutoLoads", "boolean", true)
module:CreateProperty("RespawnTime", "number", 3)
module:CreateProperty("StarterCharacter", "Object", nil)
module:CreateProperty("CharacterParent", "Object", nil)
module:CreateProperty("LocalPlayer", "Object", nil)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
	self.PlayerAdded = self.Maid:Add(Signal.new())
	self.PlayerRemoved = self.Maid:Add(Signal.new())
	
	self.CharacterAdded = self.Maid:Add(Signal.new())
	self.CharacterRemoved = self.Maid:Add(Signal.new())

	self.ChildAdded:Connect(function(child)
		if not child:IsA("Player") then return end
		self.PlayerAdded:Fire(child)
	end)
	self.ChildRemoved:Connect(function(child)
		if not child:IsA("Player") then return end
		self.PlayerRemoved:Fire(child)
	end)

	if Game:GetService("RunService"):IsClient() then
		self.PlayerAdded:Connect(function(newPlayer)
			if newPlayer:GetProperty("UserID") == Game:GetService("ClientService"):GetProperty("LocalID") then
				self:SetProperty("LocalPlayer", newPlayer)
			end
		end)
	end

	return self
end

function module:GetPlayerByCharacter(char)
	for _, player in next, self:GetPlayers() do
		if player:GetProperty("Character") == char then
			return player
		end
	end
end

function module:GetPlayers()
	local list = {}
	for _, v in next, self:GetChildren() do
		table.insert(list, v)
	end
	return list
end

return module:Register()