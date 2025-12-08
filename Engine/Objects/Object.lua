--[[
This is the parent class for every object in the framework
This class has object properties with changed values, and hierarchal structure

Object:GetID() -> string|any -- returns the objects id, if none is given during creation, a default one will be generated

Object:GetProperty(name : string) -> any -- returns the stored value of a property, and if none was given, it will return the default value

-- you can change the property without firing the changed signal by manually setting it with dot notation (Frame.BackgroundColor = Color.new(1,1,1,1))
Object:SetProperty(name : string, value : any) -> self -- tries to set the property value, returns self for chaining

Object:SetProperties(list : {[string] : any}) -> self -- bulk calls SetProperty with the values

Object:GetPropertyChangedSignal(name : string) -> GCSignal -- returns a GCSignal that fires when the property detects a change through :SetProperty

Object:BindToProperty(name : string, callback : (any)) -> GCSignalConnection -- calls the callback with the initial propery value, and any changes after

Object:GetChildren(recursive : boolean?) -> {Object} -- returns a list of all the children, if recursive, it will get all of their children and so on

Object:FindChild(name : string, recursive : boolean?) -> Object? -- tries to find a child with the specified name, if recursive, it will search all subchildren and so on

Object:GetConstraint(constraintType : string) -> Object? -- returns the constraint if there is one

Object:IsSimulated() -> boolean -- recursive parent check for the Simulated property

Object:IsVisible() -> boolean -- recursive parent check for the Visible property

Object:Update(dt : number) -- updates the object

Object:Draw() -- draws the object

Object:Destroy() -- cleans up the object

Object/ObjectClass:IsA(checkType:string) -> boolean -- checks all parent classes to see if it matches

ObjectClass:CreateProperty(name, propertyType, defaultValue, valueCleaner)
ObjectClass:SetDefaultProperyValue(name, value)
ObjectClass:CopyProperties()
ObjectClass:Register()
]]

local module = {}
module.__index = module
module.__type = "Object"

module.ClassProperties = {}
local All = {}
local RegisteredClasses = {}

local function PropertyTypeMatches(value, desiredType)
	if desiredType == "any" then return true end
	if desiredType then
		if desiredType == "Object" and (value == nil or type(value) == desiredType) then
			return true
		end

		return typeof(value) == desiredType
	end
	return true
end

local TypeCleaners = {
	Int = function(value)
		return math.round(value)
	end,
}

function module.GetClass(className)
    return RegisteredClasses[className]
end

function module.Create(className, id, ...)
    if All[id] then
        return All[id]
    end

    local class = RegisteredClasses[className]
    return class.new(id, ...)
end

module.new = function(id)
    local self = setmetatable({}, module)
    self.Maid = Maid.new()
    self.Changed = self.Maid:Add(Signal.new())
    self.ChildAdded = self.Maid:Add(Signal.new())
    self.ChildRemoved = self.Maid:Add(Signal.new())
    
    self.ID = id or string.GenerateID()

    self:GetPropertyChangedSignal("Parent"):Connect(function(newParent)
        self.Maid.ParentMaid = nil

        if newParent then
            local parentMaid = Maid.new()
            self.Maid.ParentMaid = parentMaid

            newParent:_setChild(self.ID, self)
            newParent.ChildAdded:Fire(self)
            
            parentMaid:GiveTask(function()
                newParent:_setChild(self.ID, nil)
                newParent.ChildRemoved:Fire(self)
            end)
        end
    end)

    All[self.ID] = self

    return self
end

function module:GetID()
    return self.ID
end

-- property stuff
function module:GetProperty(name)
    local selfValue = self[name]
    if selfValue ~= nil then
        return selfValue
    end
    return self.ClassProperties[name] and self.ClassProperties[name].Value
end

function module:SetProperty(name, value)
    local info = self.ClassProperties[name]
    if not info then return self end -- invalid property
    if not (PropertyTypeMatches(value, info.Type)) then return self end

    if info.Cleaner then
        value = TypeCleaners[info.Cleaner](value)
    end
    local currentValue = self:GetProperty(name)
    if currentValue == value then
        return self
    end

    if value == info.Value then
        self[name] = nil
    else
        self[name] = value
    end
    self.Changed:Fire(name, value)

    if self._cs and self._cs[name] then
        self._cs[name]:Fire(value)
    end
    return self
end

function module:SetProperties(list)
    for prop, value in next, list do
        self:SetProperty(prop, value)
    end
    return self
end

function module:GetPropertyChangedSignal(name)
    if not self._cs then
        self._cs = {}
    end
    if not self._cs[name] then
        self._cs[name] = GCSignal.new(function()
            if not self._cs then return end
            self._cs[name] = nil

            if not next(self._cs) then
                self._cs = nil
            end
        end)
    end

    return self._cs[name]
end

function module:BindToProperty(name, callback)
    callback(self:GetProperty(name))

    return self:GetPropertyChangedSignal(name):Connect(callback)
end

function module:IsA(checkType)
    local class = self
    while class do
        if class.__type == checkType then
            return true
        end
        class = class.__base
    end
    return false
end

-- hierarchal stuff
function module:GetChildren(recursive)
    local list = {}
    if not self._c then return list end

    for id, child in next, self._c do
        table.insert(list, child)
        if recursive then
            for _, subChild in ipairs(child:GetChildren(true)) do
                table.insert(list, subChild)
            end
        end
    end
    return list
end

function module:_setChild(id, value)
    if not self._c and not value then return end
    if value and not self._c then self._c = {} end
    self._c[id] = value
    if not value and not next(self._c) then
        self._c = nil
    end
end

function module:FindChild(name, recursive)
    local children = self:GetChildren(recursive)

    for _, child in ipairs(children) do
        if child:GetProperty("Name") == name then
            return child
        end
    end
end

function module:GetConstraint(constraintType)
	local constraintChildren = rawget(self, "_cC")
	if not constraintChildren then return end
	return constraintChildren[constraintType]
end

function module:IsSimulated()
    if not self:GetProperty("Simulated") then return false end

    local parent = self:GetProperty("Parent")
	if parent and not parent:IsSimulated() then
		return false
	end

	return true
end

function module:IsVisible()
    if not self:GetProperty("Visible") then return false end

    local parent = self:GetProperty("Parent")
	if parent and not parent:IsVisible() then
		return false
	end

	return true
end

-- loops
function module:_update(dt)
    if not self:GetProperty("Simulated") then return false end

    self:Update(dt)

    for _, child in ipairs(self:GetChildren()) do
        child:_update(dt)
    end
end

function module:_draw()
    if not self:GetProperty("Visible") then return false end

    self:Draw()


	local zIndices = {}
	local layers = {}
	for _, child in ipairs(self:GetChildren()) do
		local zIndex = child.ZIndex or 0
		if not layers[zIndex] then
			layers[zIndex] = {}
			table.insert(zIndices, zIndex)
		end
		table.insert(layers[zIndex], child)
	end
	table.sort(zIndices) -- could be costly

	for _, layerNumber in ipairs(zIndices) do
		for _, child in ipairs(layers[layerNumber]) do
			child:_draw()
		end
	end
end

function module:Update(dt)
end
function module:Draw()
end

function module:Destroy()
    All[self.ID] = self
    self.Maid:Destroy()
end

-- call this on the class, not the instance
function module:CreateProperty(name, propertyType, defaultValue, valueCleaner)
    if self.ClassProperties[name] then
        print("property named "..name.." already exists for "..self.__type)
        return
    end

    self.ClassProperties[name] = {
        Type = propertyType,
        Value = defaultValue,
        Cleaner = valueCleaner,
    }
end

function module:SetDefaultProperyValue(name, value)
    if not self.ClassProperties[name] then
        print("no property named "..name.." exists for "..self.__type)
        return
    end
    self.ClassProperties[name].Value = value
end

function module:CopyProperties()
    -- deepcopy the values
    local copy = {}
    for name, info in next, self.ClassProperties do
        copy[name] = {
            Type = info.Type,
            Value = info.Value,
            Cleaner = info.Cleaner,
        }
    end
    return copy
end

function module:Register()
    RegisteredClasses[self.__type] = self

    if not rawget(self, "new") then
        rawset(self, "new", function(...)
            local new = setmetatable(self.__base.new(...), self)

            return new
        end)
    end
    return self
end

module:CreateProperty("Name", "string", module.__type)
module:CreateProperty("Simulated", "boolean", true)
module:CreateProperty("Visible", "boolean", true)
module:CreateProperty("ZIndex", "number", 1)
module:CreateProperty("Parent", "Object", nil)

return module:Register()