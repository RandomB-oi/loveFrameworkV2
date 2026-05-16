local module = {}
module.__index = module
module.__type = "PlayerInventory"
module.__base = require("Engine.Objects.Folder")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

local Run = Game:GetService("RunService")
local Players = Game:GetService("Players")
local InputService = Run:IsClient() and Game:GetService("InputService")
local TweenService = Game:GetService("TweenService")

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

    if Run:IsServer() then
        local id = "PI_"..self.ID
        self.ContainerGroup = self.Maid:Add(ContainerGroupClass.new("Group_"..id))
        self.ContainerGroup:AddContainer(ContainerClass.new("Inventory", 9*3, 9, "Inventory_"..id))

        local stack = ItemStack.new("Wood", 1)
        stack:AddComponent(StackComponents.Unique())
        self.ContainerGroup:AddItem(stack)

        self.ContainerGroup:BindItems(function(containerName, index, item)
            -- print("new item in", containerName,"index:", index, "item:", getStr(item))
            local con = item:BindAmount(function(newAmount)

            end)

            return function()
                con:Destroy()
            end
        end)


        local total = 0
        for i = 1, 6 do
            local a = 4
            total = total + a
            self.ContainerGroup:AddItem(ItemStack.new("Wood", a))
        end

        task.delay(1, function()
            print("add item")
            local stack = ItemStack.new("Wood", 8)
            stack:AddComponent(StackComponents.StackSize(24))
            stack:AddComponent(StackComponents.ItemIcon("Engine/Assets/InstanceIcons/Workspace.png"))
            stack:AddComponent(StackComponents.Unique())
            self.ContainerGroup:AddItem(stack)
            
            local stack = ItemStack.new("Wood", 24)
            stack:AddComponent("ItemIcon")
            self.ContainerGroup:AddItem(stack)
        end)
    end

    return self
end

function module:GetContainerGroup()
    if Run:IsClient() then
        return ContainerGroupClass.Get("Group_PI_"..self.ID)
    end
    return self.ContainerGroup
end

return module:Register()