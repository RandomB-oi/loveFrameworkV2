local module = {}
module.__index = module

local All = {}
module.Get = function(id)
    return All[id]
end

module.new = function(name, slotCount, rowSize, containerID)
    local self = setmetatable({}, module)
    self.Maid = Maid.new()
    self.ContainerID = containerID or GenerateGUID()
    self.StackAdded = self.Maid:Add(Signal.new())
    self.StackMoved = self.Maid:Add(Signal.new())
    self.StackRemoved = self.Maid:Add(Signal.new())
    self.Name = name
    self.Slots = {}
    self.SlotCount = slotCount
    self.RowSize = rowSize

    All[self.ContainerID] = self

    return self
end

function module:Replicate(data)
    local selfItemsByID = {}
    self:ForEach(function(index, item)
        if item then
            selfItemsByID[item.StackID] = {index, item}
        end
    end)
    self.Slots = {}
    for slot, itemInfo in next, data.Items or {} do
        local index = tonumber(slot)
        local slotInfo = selfItemsByID[itemInfo.StackID]
        local stack = slotInfo and slotInfo[2]
        local isNew = false
        if not stack then
            stack = ItemStack.new(itemInfo.ID, itemInfo.Amount, itemInfo.StackID)
            isNew = true
        end
        stack:Replicate(itemInfo)
        self.Slots[index] = stack
        selfItemsByID[itemInfo.StackID] = nil
        if isNew then
            self.StackAdded:Fire(index, stack)
        end
        if slotInfo and index ~= slotInfo[1] then
            self.StackMoved:Fire(stack)
        end
    end

    for id, item in next, selfItemsByID do
        item[2]:Destroy()
        self.StackRemoved:Fire(item[1], item[2])
    end
end

function module:Serialize()
    local data = {}

    data.Name = self.Name
    data.SlotCount = self.SlotCount
    data.RowSize = self.RowSize
    data.ID = self.ContainerID
    data.Items = {}
    self:ForEach(function(index, item)
        if not item then
            return
        end

        data.Items[tostring(index)] = item:Serialize()
    end)
    
    if not next(data.Items) then
        data.Items = nil
    end

    return data
end

function module:GetItems()
    local items = {}
    for index, stack in next, self.Slots do
        table.insert(items, stack)
    end
    return items
end

function module:ForEach(callback)
    for i = 1, self.SlotCount do
        if callback(i, self.Slots[i]) then
            return
        end
    end
end

function module:BindItems(callback)
    local maid = Maid.new()
 
    maid:GiveTask(self.StackAdded:Connect(function(index, item)
        maid[item] = callback(index, item)
    end))
    maid:GiveTask(self.StackRemoved:Connect(function(_, _, item)
        maid[item] = nil
    end))

    self:ForEach(function(index, item)
        if not item then return end
        maid[item] = callback(index, item)
    end)

    return maid
end

-- returns if the stack was completely used
function module:AddItem(itemStack)
    self:ForEach(function(index, slot)
        if slot and itemStack:CanCombine(slot) then
            if slot:Combine(itemStack) then
                return true
            end
        end
    end)

    if itemStack:IsAlive() then
        local used = self:ForEach(function(index, slot)
            if not slot and self:CanItemGoInSlot(index, itemStack) then
                self.Slots[index] = itemStack
                self.StackAdded:Fire(index, itemStack)
                return true
            end
        end)
        if used then return true end
    end

    return not itemStack:IsAlive()
end

function module:ReleaseSlot(index)
    local itemStack = self.Slots[index]
    if itemStack then
        self.Slots[index] = nil
        self.StackRemoved:Fire(index, itemStack)
        return itemStack
    end
end

function module:CanItemGoInSlot(index, itemStack)
    return true
end

function module:Destroy()
    self.Maid:Destroy()
    All[self.ContainerID] = nil
    
    while true do
        local index, item = next(self.Slots)
        if not index then break end

        self.Slots[index] = nil
        if item then
            item:Destroy()
        end
    end
end

return module