local module = {}
module.__index = module
module.__type = "Frame"
module.__base = require("Engine.Objects.Object")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module:CreateProperty("Size", "UDim2", UDim2.new(0,100,0,100))
module:CreateProperty("Position", "UDim2", UDim2.new(0,0,0,0))
module:CreateProperty("AnchorPoint", "Vector", Vector.new(0,0))
module:CreateProperty("BackgroundColor", "Color", Color.new(1,1,1,1))


module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

    self.RenderPosition = Vector.zero
    self.RenderSize = Vector.zero

    self:GetPropertyChangedSignal("Parent"):Connect(function(newParent)
        if newParent then
            newParent._updateRender = nil
        end
    end)

    self:GetPropertyChangedSignal("Position"):Connect(function()
        self._updateRender = true
    end)
    self:GetPropertyChangedSignal("Size"):Connect(function()
        self._updateRender = true
    end)
    self:GetPropertyChangedSignal("AnchorPoint"):Connect(function()
        self._updateRender = true
    end)

    return self
end

function module:GetModifiedSize(size)
	local aspectRatio = self:GetConstraint("AspectRatio")
	local ratio = aspectRatio and aspectRatio:GetProperty("AspectRatio")

	local sizeConstraint = self:GetConstraint("Size")
	if sizeConstraint then
        local min, max = sizeConstraint:GetProperty("Min"), sizeConstraint:GetProperty("Max")
		size = Vector.new(math.clamp(size.X, min.X, max.X), math.clamp(size.Y, min.Y, max.Y))
	end

	if ratio then
		local targetWidth = size.Y * ratio
		local targetHeight = size.X / ratio

		if targetWidth <= size.X then
			return Vector.new(targetWidth, size.Y)
		end
		return Vector.new(size.X, targetHeight)
	end

	return size
end

function module:GetPadding()
	local topLeft, bottomRight = Vector.zero, Vector.zero
	
	local padding = self:GetConstraint("Padding")
	if padding then
		topLeft = topLeft + padding.TopLeft
		bottomRight = bottomRight + padding.BottomRight
	end

	return topLeft, bottomRight
end

function module:UpdateRenderProperties(parentPos, parentSize)
    local parent = self:GetProperty("Parent")
    if not (parentPos and parentSize) then
        if not (parent and parent.RenderPosition and parent.RenderSize) then return end
        return self:UpdateRenderProperties(parent.RenderPosition, parent.RenderSize)
    end

    self._updateRender = nil
    local prevPos, prevSize = self.RenderPosition, self.RenderSize

    local newPos, newSize

    local listLayout = parent and parent:GetConstraint("List")
    if listLayout then
        newSize, newPos = listLayout:Resolve(self, parentSize, parentPos)
    else
        local pos, size, anchor = self:GetProperty("Position"), self:GetProperty("Size"), self:GetProperty("AnchorPoint")
        newSize = self:GetModifiedSize(size:Calculate(parentSize))
        newPos = parentPos + pos:Calculate(parentSize) - newSize * anchor
    end

    if newPos == prevPos and newSize == prevSize then return end

    self.RenderPosition = newPos
    self.RenderSize = newSize

    for _, child in ipairs(self:GetChildren()) do
        if child:IsA("Frame") then
            child:UpdateRenderProperties(new)
        end
    end
end

function module:Update(dt)
    if self._updateRender then
        self:UpdateRenderProperties()
    end
end

function module:Draw()
    local backgroundColor = self:GetProperty("BackgroundColor")
    if backgroundColor.A > 0 then
        backgroundColor:Apply()
        love.graphics.rectangle("fill", self.RenderPosition.X, self.RenderPosition.Y, self.RenderSize.X, self.RenderSize.Y)
    end
end

return module:Register()