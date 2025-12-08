local module = {}
module.__index = module
module.__type = "UDim"

module.new = function(scale, offset)
	return setmetatable({
		Scale = scale or 0, 
		Offset = offset or 0
	}, module)
end


function module:__add(other)
	return module.new(
		self.Scale + other.Scale,
		self.Offset + other.Offset
	)
end
function module:__sub(other)
	return module.new(
		self.Scale - other.Scale,
		self.Offset - other.Offset
	)
end

function module:__mul(other)
	if type(other) == "number" then
		return module.new(
			self.Scale * other,
			self.Offset * other
		)
	end
	return module.new(
		self.Scale * other.Scale,
		self.Offset * other.Offset
	)
end

function module:__unm()
	return module.new(
		-self.Scale,
		-self.Offset
	)
end

function module:Lerp(other, alpha)
	return module.new(
		math.lerp(self.Scale, other.Scale, alpha),
		math.lerp(self.Offset, other.Offset, alpha)
	)
end

function module:__tostring()
	return tostring(self.Scale)..", "..tostring(self.Offset)
end

function module:ToLua()
	return "UDim.new("..tostring(self.Scale)..", "..tostring(self.Offset)..")"
end

function module:Serialize()
    return self.Scale, self.Offset
end

return module