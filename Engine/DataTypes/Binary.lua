local module = {}
module.__index = module
module.__type = "Binary"

local function GetNumber(self)
    return type(self) == "number" and self or self.Value
end

module.new = function(value)
	return setmetatable({
        Value = value or 0,
    }, module)
end

function module:ReadBits(offset, size)
    local number = GetNumber(self)

    local shifted = bit.rshift(number, size)
    local value = 0

    for i = offset, offset + size-1 do
        local shiftedValue = bit.rshift(number, i)%2
        value = value + bit.lshift(shiftedValue, i)
    end
    
    return value
end

function module:WriteBits(offset, size, value)
    local number = GetNumber(self)
    for i = offset, offset + size-1 do
        local shiftedValue = bit.rshift(number, i)%2
        local addValue = bit.rshift(value, i)%2

        if shiftedValue ~= addValue then
           number = number + (bit.lshift(addValue-shiftedValue, i))
        end
    end
    
    if type(self) == "table" then
        self.Value = number
    end

    return self
end

function module:ToLua()
    return "Binary.new("..tostring(self.Value)..")"
end

function module:Serialize()
    return self.Value
end

function module:GetSize()
    local number = GetNumber(self)
    return math.ceil(math.log(number, 2))
end

function module:__tostring()
	return tostring(self.Value)
end

return module