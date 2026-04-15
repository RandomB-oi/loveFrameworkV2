local module = {}
module.__index = module
module.__type = "Wall"
module.__base = require("Engine.Objects.Object")
setmetatable(module, module.__base)

module.ClassIcon = "Engine/Assets/InstanceIcons/Frame.png"
module.ClassProperties = module.__base:CopyProperties()
module:CreateProperty("PointA", "Object", nil)
module:CreateProperty("PointB", "Object", nil)
module:SetDefaultProperyValue("Name", module.__type)

module.AllWalls = {}

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
    module.AllWalls[self.ID] = self
    self.Maid:GiveTask(function()
        module.AllWalls[self.ID] = nil
    end)

    return self
end

function module:GetNormal(point)
	local a, b = self:GetPoints()
	local edge = a - b

	local normal = Vector.new(-edge.Y, edge.X):Normalized()

	if point and (point - a):Dot(normal) > 0 then
		normal = -normal
	end

	return normal
end

function module:GetCenter()
	local a, b = self:GetPoints()
	return (a + b) / 2
end

-- function module:GetSide(point)
--     local a, b = self:GetPoints()
--     local midPoint = (a+b)/2
--     local normal = self:GetNormal()

--     return math.sign((point-midPoint):Normalized():Dot(normal))
-- end

function module:GetPoints()
	local a = self:GetProperty("PointA"):GetProperty("Position")
	local b = self:GetProperty("PointB"):GetProperty("Position")
	return a, b
end


function module:Cast(from, direction)
    local a,b = self:GetPoints()
    b = b - a

	local den = b:Cross(direction)
	if den == 0 then
		return -- parallel
	end

	local qp = from - a
	local t = qp:Cross(direction) / den
	local u = qp:Cross(b) / den

	if t > 0 and t < 1 and u > 0 and u < 1 then
		return a + b * t
	end
end

function module:PointColliding(pointPosition)
	local pointA, pointB = self:GetPoints()
	local center = self:GetCenter()

	do -- check if its within bounds
		local diff = (pointB - pointA)
		local length = diff:Length()
		local dir = diff / length

		local dot = dir:Dot(pointPosition-pointA)
		if dot < 0 or dot > length then
			return
		end
	end

	local diff = pointPosition-center
	local dot = diff:Dot(self:GetNormal())

	if dot <= 0 then
		return dot
	end
end

-- function module:WithinBounds(point)
--     local a, b = self:GetPoints()
-- 	local ab = b - a
-- 	local ap = point - a

-- 	local abLenSq = ab:Dot(ab)
-- 	if abLenSq == 0 then
-- 		return false
-- 	end

-- 	local t = ap:Dot(ab) / abLenSq
-- 	return t >= 0 and t <= 1
-- end

function module:Draw()
    -- module.__base.Draw(self)
    -- Color.Red:Apply()
    -- love.graphics.rectangle("line", self.RenderPosition.X, self.RenderPosition.Y, self.RenderSize.X, self.RenderSize.Y)
    
    local a,b = self:GetPoints()

	local normal = self:GetNormal()
	local mid = self:GetCenter()
	local midOffset = mid + normal * 25

    Color.Red:Apply()
	love.graphics.line(mid.X, mid.Y, midOffset.X, midOffset.Y)

    Color.White:Apply()
    love.graphics.line(a.X, a.Y, b.X, b.Y)
end

return module:Register()