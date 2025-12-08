local module = {}
module.__index = module
module.__type = "Vector"

local function isNumber(x)
	return type(x) == "number" and x == x
end

module.new = function(x, y)
	if not isNumber(x) then
		x = 0
	end
	if not isNumber(y) then
		y = 0
	end
	local self = setmetatable({X = x, Y = y}, module)
	return self
end

function module:Normalized()
	return self/self:Length()
end
function module:Length()
	return math.sqrt(self.X^2 + self.Y^2)
end

module.FromAngle = function(angle) -- in radians
	return module.new(math.sin(angle), -math.cos(angle))
end

function module:GetAngle()
	return math.atan2(-self.Y, self.X)
end

function module:Dot(other)
	return self.X * other.X + self.Y * other.Y
end
function module:Cross(other)
	return self.X * other.Y - self.Y * other.X
end
function module:Lerp(other, alpha)
	return module.new(
		math.lerp(self.X, other.X, alpha),
		math.lerp(self.Y, other.Y, alpha)
	)
end

function module:__add(other)
	if type(self) == "number" then
		return other + self
	end
	return module.new(self.X + other.X, self.Y + other.Y)
end

function module:__sub(other)
	if type(self) == "number" then
		return other - self
	end
	return module.new(self.X - other.X, self.Y - other.Y)
end

function module:__unm()
	return module.new(-self.X, -self.Y)
end

function module:__mul(other)
	if isNumber(self) then
		return other * self
	end
	if isNumber(other) then
		return module.new(self.X * other, self.Y * other)
	end
	return module.new(self.X * other.X, self.Y * other.Y)
end

function module:__div(other)
	if isNumber(self) then
		return other / self
	end
	
	if isNumber(other) then
		return module.new(self.X / other, self.Y / other)
	end
	return module.new(self.X / other.X, self.Y / other.Y)
end

function module:__lt(other)
	return self.X < other.X and self.Y < other.Y
end

function module:__le(other)
	return self.X <= other.X and self.Y <= other.Y
end

function module:__eq(other)
	return self.X == other.X and self.Y == other.Y
end

function module:__tostring()
	return tostring(self.X)..", "..tostring(self.Y)
end

function module:ToLua()
	return "Vector.new("..tostring(self.X)..", "..tostring(self.Y)..")"
end

function module:Serialize()
    return self.X, self.X
end

module.zero = module.new(0,0)
module.xAxis = module.new(1,0)
module.yAxis = module.new(0,1)
module.one = module.new(1,1)

return module