local module = {}
module.__index = module
module.__type = "Players"
module.__base = require("Engine.Objects.Services.Service")
setmetatable(module, module.__base)

module.ClassIcon = "Engine/Assets/InstanceIcons/Players.png"
module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("Simulated", true)
module:SetDefaultProperyValue("Visible", false)
module:CreateProperty("CharacterAutoLoads", "boolean", true)
module:CreateProperty("RespawnTime", "number", 3)
module:CreateProperty("StarterCharacter", "Object", nil)
module:CreateProperty("CharacterParent", "Object", nil)
module:CreateProperty("LocalPlayer", "Object", nil)

local function ScanForLocalPlayer()
	local players = Game:GetService("Players")
	local localID = Game:GetService("ClientService"):GetProperty("LocalID")
	if not players then return end
	for _, newPlayer in next, players:GetPlayers() do
		if newPlayer:GetProperty("UserID") == localID then
			players:SetProperty("LocalPlayer", newPlayer)
			break
		end
	end
end

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
		Game:GetService("ClientService"):BindToProperty("LocalID", function()
			ScanForLocalPlayer()
		end)
		self.PlayerAdded:Connect(ScanForLocalPlayer)
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