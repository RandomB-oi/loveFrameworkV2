local module = {}
module.__index = module

local All = {}
module.Get = function(id)
    return All[id]
end

-- local ReplicationRemote
-- if Game:GetService("RunService"):IsServer() then
--     -- ReplicationRemote = Object.Create("RemoteEvent"):SetProperties({
--     --     Name = "ReplicateContainer",
--     --     Parent = workspace:WaitPath("Storage.Remotes")
--     -- })
-- end

function module.Replicate(data) -- client function
    if type(data) == "string" then
        local group = module.Get(data)
        if group then
            group:Destroy()
        end
        return
    end

    local group = module.Get(data.ID) or module.new(data.ID)
    
    for name, containerData in next, data.Containers or {} do
        local container = group:GetContainer(containerData.Name)
        if not container then
            local found = ContainerClass.Get(containerData.ID)
            if not found then
                found = ContainerClass.new(containerData.Name, containerData.SlotCount, containerData.RowSize, containerData.ID)
            end
            container = found

            group:AddContainer(found)
        end

        container:Replicate(containerData)
    end

    return group
end

module.new = function(groupID)
    local self = setmetatable({}, module)
    self.Maid = Maid.new()
    self.GroupID = groupID or GenerateGUID()
    self.StackAdded = self.Maid:Add(Signal.new())
    self.StackRemoved = self.Maid:Add(Signal.new())
    self.Containers = {}

    self.Allowed = {}

    All[self.GroupID] = self

    return self
end

function module:Serialize()
    local data = {}

    data.ID = self.GroupID
    data.Containers = {}

    for containerName, container in next, self.Containers do
        data.Containers[containerName] = container:Serialize()
    end
    if not next(data.Containers) then
        data.Containers = nil
    end

    return data
end

function module:GiveAccess(player)
    if self.Allowed[player] then return end

    local maid = Maid.new()
    
    local function replicate()
        local replicateRemote = workspace:SearchPath("Storage.Remotes.ReplicateContainerGroup")
        if not replicateRemote then return end

        if self.Allowed[player] then
            replicateRemote:FireClient(player, self:Serialize())
        else
            replicateRemote:FireClient(player, self.ID)
        end
    end

    local initial = true
    self:BindItems(function(containerName, index, item)
        if not initial then
            replicate()
        end
        local con = item.AmountChanged:Connect(replicate)
        return function()
            con:Disconnect()
            if not self.Allowed[player] then return end
            replicate()
        end
    end)
    initial = false
    self.Allowed[player] = maid

    replicate()
end

function module:RemoveAccess(player)
    local access = self.Allowed[player]
    if not access then return end

    self.Allowed[player] = nil
    access:Destroy()
end

function module:GetItems()
    local items = {}
    for containerName, container in next, self.Containers do
        for _, item in next, container:GetItems() do
            table.insert(items)
        end
    end
    return items
end

function module:BindItems(callback)
    local maid = Maid.new()
 
    maid:GiveTask(self.StackAdded:Connect(function(containerName, index, item)
        maid[item] = callback(containerName, index, item)
    end))
    maid:GiveTask(self.StackRemoved:Connect(function(_, _, item)
        maid[item] = nil
    end))

    for containerName, container in next, self.Containers do
        container:ForEach(function(index, item)
            if not item then return end
            maid[item] = callback(containerName, index, item)
        end)
    end

    return maid
end

function module:GetContainer(name)
    return self.Containers[name]
end

function module:AddContainer(newContainer)
    local containerName = newContainer.Name
    if self:GetContainer(containerName) then print("container group already has", containerName) end

    self.Containers[containerName] = newContainer
    newContainer.StackAdded:Connect(function(index, item)
        self.StackAdded:Fire(containerName, index, item)
    end)
    newContainer.StackRemoved:Connect(function(index, item)
        self.StackRemoved:Fire(containerName, index, item)
    end)
end

function module:AddItem(stack)
    for containerName, container in next, self.Containers do
        if container:AddItem(stack) then
            break
        end
    end
end

function module:Destroy()
    self.Maid:Destroy()
    All[self.GroupID] = nil

    for _, access in next, self.Allowed do
        access:Destroy()
    end
    self.Allowed = {}

    while true do
        local index, comp = next(self.Containers)
        if not index then break end

        self.Containers[index] = nil
        if comp then
            comp:Destroy()
        end
    end
end

return module