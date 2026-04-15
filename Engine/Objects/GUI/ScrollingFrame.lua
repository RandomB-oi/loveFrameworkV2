local module = {}
module.__index = module
module.__type = "ScrollingFrame"
module.__base = require("Engine.Objects.GUI.Frame")
setmetatable(module, module.__base)

module.ClassIcon = "Engine/Assets/InstanceIcons/ScrollingFrame.png"
module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:CreateProperty("CanvasPosition", "Vector", Vector.zero)
module:CreateProperty("CanvasSize", "UDim2", UDim2.new(0,0, 0,0))
module:CreateProperty("ScrollbarColor", "Color", Color.White)
module:CreateProperty("CanvasColor", "Color", Color.White)
module:CreateProperty("ScrollbarThickness", "number", 12, "Int")
module:CreateProperty("ScrollbarPadding", "ScrollbarPadding", Enum.ScrollbarPadding.Never)
module:CreateProperty("HorizontalScrollbarSide", "LateralDirection", Enum.LateralDirection.Right)
module:CreateProperty("VerticalScrollbarSide", "VerticalDirection", Enum.VerticalDirection.Bottom)

module.new = function(...)
	local self = setmetatable(module.__base.new(...), module)

	self.Canvas = nil
	self.RenderCanvasSize = Vector.zero

	local InputService = Game:GetService("InputService")
	self.Maid:Add(InputService.Scrolled:Connect(function(dir)
		if not (self:MouseHovering() and self:IsSimulated()) then return end
		local horizontal = InputService:IsKeyPressed(Enum.KeyCode.LeftShift) or InputService:IsKeyPressed(Enum.KeyCode.RightShift)
		local scrollAxis = horizontal and Vector.xAxis or Vector.yAxis
		task.spawn(function()
			for i = 1, 3 do
				self:SetProperty("CanvasPosition", self:GetProperty("CanvasPosition") - scrollAxis*(dir*10))
				task.wait()
			end
		end)
	end))

	return self
end

function module:GetPadding()
	local add, sub = module.__base.GetPadding(self)

	local scrollbarPadding = self:GetProperty("ScrollbarPadding")
	local scrollbarThickness = self:GetProperty("ScrollbarThickness")

	if scrollbarPadding == Enum.ScrollbarPadding.Scrollbar and self.RenderSize.Y ~= self.RenderCanvasSize.Y or scrollbarPadding == Enum.ScrollbarPadding.Always then
		if self:GetProperty("HorizontalScrollbarSide") == Enum.LateralDirection.Left then
			add = add + Vector.new(scrollbarThickness, 0)
		else
			sub = sub + Vector.new(scrollbarThickness, 0)
		end
	end

	if scrollbarPadding == Enum.ScrollbarPadding.Scrollbar and self.RenderSize.X ~= self.RenderCanvasSize.X or scrollbarPadding == Enum.ScrollbarPadding.Always then
		if self:GetProperty("VerticalScrollbarSide") == Enum.LateralDirection.Top then
			add = add + Vector.new(0, scrollbarThickness)
		else
			sub = sub + Vector.new(0, scrollbarThickness)
		end
	end

	return add, sub
end

function module:UpdateCanvas()
	local canvasX, canvasY
	if self.Canvas then
		canvasX, canvasY = self.Canvas:getPixelDimensions()
		canvasX = math.round(canvasX)
		canvasY = math.round(canvasY)
	end

	local solvedCanvasSize = self:GetProperty("CanvasSize"):Calculate(self.RenderSize)
	local canvasPosition = self:GetProperty("CanvasPosition")

	self.RenderCanvasSize = Vector.new(math.max(self.RenderSize.X, solvedCanvasSize.X), math.max(self.RenderSize.Y, solvedCanvasSize.Y))

	self:SetProperty("CanvasPosition", Vector.new(
		math.clamp(canvasPosition.X, 0, self.RenderCanvasSize.X-self.RenderSize.X),
		math.clamp(canvasPosition.Y, 0, self.RenderCanvasSize.Y-self.RenderSize.Y)
	))

	if math.round(self.RenderSize.X) ~= canvasX or math.round(self.RenderSize.Y) ~= canvasY then
		if self.Canvas then
			self.Canvas:release()
			self.Canvas = nil
		end

		if self.RenderSize.X > 0 and self.RenderSize.Y > 0 then
			self.Canvas = love.graphics.newCanvas(self.RenderSize.X, self.RenderSize.Y)
		end
		return true
	end
end

function module:Update(dt)
	module.__base.Update(self, dt)
	self:UpdateCanvas()
end

function module:_draw()
	if not self.Canvas then return end

	local prevCanvas = love.graphics.getCanvas()

	love.graphics.setCanvas(self.Canvas)
	love.graphics.clear()
	love.graphics.push()
	local offset = self.RenderPosition
	love.graphics.translate(-offset.X, -offset.Y)
	self:_drawChildren()
	love.graphics.pop()
	love.graphics.setCanvas(prevCanvas)
	self:Draw()
end

function module:Draw()
	if not self.Canvas then return end

	self:GetProperty("CanvasColor"):Apply()
	love.graphics.cleanDrawImage(self.Canvas, self.RenderPosition, self.RenderSize)

	local scrollbarThickness = self:GetProperty("ScrollbarThickness")
	local canvasPosition = self:GetProperty("CanvasPosition")

	self:GetProperty("ScrollbarColor"):Apply()
	if self.RenderSize.Y ~= self.RenderCanvasSize.Y then
		local scrollPercent = canvasPosition.Y/(self.RenderCanvasSize.Y-self.RenderSize.Y)
		local scrollbarHeight = self.RenderSize.Y * (self.RenderSize.Y/self.RenderCanvasSize.Y)
		local scrollbarPosition = self:GetProperty("HorizontalScrollbarSide") == Enum.LateralDirection.Left and 0 or self.RenderSize.X - scrollbarThickness

		love.graphics.rectangle("fill",
			self.RenderSize.X + scrollbarPosition,
			self.RenderSize.Y + (self.RenderSize.Y - scrollbarHeight) * scrollPercent,
			scrollbarThickness,
			scrollbarHeight
		)
	end
	if self.RenderSize.X ~= self.RenderCanvasSize.X then
		local scrollPercent = canvasPosition.X/(self.RenderCanvasSize.X-self.RenderSize.X)
		local scrollbarHeight = self.RenderSize.X * (self.RenderSize.X/self.RenderCanvasSize.X)
		local scrollbarPosition = self:GetProperty("VerticalScrollbarSide") == Enum.VerticalDirection.Top and 0 or self.RenderSize.Y - scrollbarThickness

		love.graphics.rectangle("fill",
			self.RenderSize.X + (self.RenderSize.X - scrollbarHeight) * scrollPercent,
			self.RenderSize.Y + scrollbarPosition,
				scrollbarHeight,
				scrollbarThickness
		)
	end
end

return module:Register()