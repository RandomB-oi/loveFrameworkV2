local module = {}
module.__index = module
module.__type = "Player"
module.__base = require("Engine.Objects.Object")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:CreateProperty("UserID", "string", "0")
module:CreateProperty("Character", "Object", nil)

module.new = function(id)
    local self = setmetatable(module.__base.new(id), module)
    self:SetProperty("UserID", id)
    self.CharacterAdded = self.Maid:Add(Signal.new())
    self.CharacterRemoved = self.Maid:Add(Signal.new())

    self.Destroying:Connect(function()
        print("player left")
        self:RemoveCharacter()
    end)

    self.CharacterRemoved:Connect(function()
        task.delay(Game:GetService("Players"):GetProperty("RespawnTime"), function()
            if not self:GetProperty("Character") then
                self:LoadCharacter()
            end
        end)
    end)

    if Game:GetService("RunService"):IsServer() then
        self.CharacterRemoved:Fire()
        -- self:LoadCharacter()
    end

    return self
end

function module:RemoveCharacter()
    local char = self:GetProperty("Character")
    if char then
        char:Destroy()
        self:SetProperty("Character", nil)
        self.CharacterRemoved:Fire()
        Game:GetService("Players").CharacterRemoved:Fire(self)
    end
end

function module:LoadCharacter()
    self:RemoveCharacter()

    local players = Game:GetService("Players")
    local starterChar = players:GetProperty("StarterCharacter")
    if not starterChar then return end

    local newChar = starterChar:Clone()
    newChar:SetProperties({
        Name = self:GetProperty("UserID"),
        Parent = players:GetProperty("CharacterParent"),
    })
    newChar.Destroying:Connect(function()
        self:RemoveCharacter()
    end)
    self:SetProperty("Character", newChar)
    self.CharacterAdded:Fire(newChar)
    players.CharacterAdded:Fire(self, newChar)
    return newChar
end

return module:Register()