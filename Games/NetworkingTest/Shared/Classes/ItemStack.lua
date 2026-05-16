local module = {}
module.__index = module

local Run = Game:GetService("RunService")

module.new = function(itemID, amount, stackID)
    local self = setmetatable({}, module)
    self.Maid = Maid.new()
    self.ComponentChanged = self.Maid:Add(Signal.new())
    self.AmountChanged = self.Maid:Add(Signal.new())
    self.StackID = stackID or GenerateGUID(10)
    self.ItemID = itemID
    self.Amount = amount or 1
    self.Components = {}

    -- if Run:IsServer() then
    --     self.AmountChanged:Connect(function()
            
    --     end)
    -- else

    -- end

    return self
end

function module:Replicate(data)
    data.Components = data.Components or {}

    if data.Amount ~= self.Amount then
        self.Amount = data.Amount
        self.AmountChanged:Fire(self.Amount)
    end

    for name, comp in next, self.Components do
        if data.Components[name] == false then
            self:AddComponent(name)
        elseif data.Components[name] == nil then
            self:RemoveComponent(name)
        else
            local otherComp = StackComponents[name](unpack(data.Components[name]))
            if not comp:Same(comp) then
                self:AddComponent(otherComp)
            end
        end

        data.Components[name] = nil
    end

    for name, info in next, data.Components do
        if info == false then
            self:AddComponent(name)
        else
            local otherComp = StackComponents[name](unpack(info))
            self:AddComponent(otherComp)
        end
    end
end

function module:Serialize()
    local serializedComponents = {}

    for name, comp in next, self.Components do
        if comp then
            comp = {comp:Serialize()}
        end
        serializedComponents[name] = comp
    end
    
    if not next(serializedComponents) then
        serializedComponents = nil
    end

    return {
        StackID = self.StackID,
        ID = self.ItemID,
        Amount = self.Amount,
        Components = serializedComponents,
    }
end

function module:IsAlive()
    return not self.Dead
end

function module:GetMaxAmount()
    local stackAmountComp = self:GetComponent("StackSize")
    return stackAmountComp and stackAmountComp:GetStackSize() or 999
end

-- returns if the stack was completely used
function module:Combine(otherStack)
    local maxStackAmount = self:GetMaxAmount()

    local previousAmount = self.Amount
    local takeAmount = math.clamp(previousAmount + otherStack.Amount, 0, maxStackAmount)-previousAmount

    local diff = otherStack.Amount - takeAmount

    if takeAmount ~= 0 then
        self.Amount = self.Amount + takeAmount
        self.AmountChanged:Fire(self.Amount)
    end

    if diff > 0 then
        otherStack.Amount = diff
        otherStack.AmountChanged:Fire(otherStack.Amount)
    else
        otherStack:Destroy()
        return true
    end
end

-- returns copy and if the original was completely used
function module:Split(amount)
    local amount = math.clamp(amount, 0, self.Amount)
    if amount <= 0 then return end

    local copy = self:Copy()
    copy.Amount = amount

    if amount >= self.Amount then
        self:Destroy()
    else
        self.Amount = self.Amount - amount
        self.AmountChanged:Fire(self.Amount)
    end

    return copy, self.Amount > 0
end

function module:Clone()
    local newStack = module.new(self.ItemID, self.Amount)
    for compName, comp in next, self.Components do
        if not comp then
            newStack:RemoveComponent(compName)
        else
            newStack:AddComponent(comp)
        end
    end
    return newStack
end

function module:CanCombine(otherStack, _alreadyChecked)
    if not (self:IsAlive() and otherStack:IsAlive()) then return false end
    if self.ItemID ~= otherStack.ItemID then return false end

    local checkedList = _alreadyChecked or {}
    for name, comp in next, self:GetComponents() do
        if not checkedList[name] then
            checkedList[name] = true
            local otherComp = otherStack:GetComponent(name)

            if not (comp and otherComp and comp:CanCombine(otherComp)) then
                return false
            end
        end
    end

    if not _alreadyChecked then
        return otherStack:CanCombine(self, checkedList)
    end

    return true
end

function module:GetComponents()
    local components = table.shallowCopy(self.Components)

    for compName, comp in next, ItemRegistry.Items[self.ItemID] or {} do
        if components[compName] == nil then
            components[compName] = comp
        end
    end

    return components
end

function module:GetComponent(compName)
    if self.Components[compName] ~= nil then
        return self.Components[compName]
    end

    local registryItem = ItemRegistry.Items[self.ItemID]
    if registryItem then
        return registryItem[compName]
    end
end

function module:AddComponent(newComp)
    local compName
    if type(newComp) == "string" then
        compName, newComp = newComp, false
    else
        compName = newComp.ComponentID
    end

    self:RemoveComponent(compName, true)

    self.Components[compName] = newComp
    self.ComponentChanged:Fire(compName)
end

function module:RemoveComponent(compName, _dontFire)
    local comp = self.Components[compName]
    self.Components[compName] = nil

    if comp ~= nil and not _dontFire then
        self.ComponentChanged:Fire(compName)
    end
end

function module:BindComponent(name, callback)
    callback(self:GetComponent(name))
    return self.ComponentChanged:Connect(function(changedCompName)
        if changedCompName == name then
            callback(self:GetComponent(name))
        end
    end)
end

function module:BindAmount(callback)
    callback(self.Amount)
    return self.AmountChanged:Connect(callback)
end

function module:Destroy()
    self.Dead = true
    self.Maid:Destroy()
end

return module