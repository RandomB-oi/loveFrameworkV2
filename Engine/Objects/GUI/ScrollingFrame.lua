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


    self:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        self._updateRender = true
		print("update it ")
    end)
    self:GetPropertyChangedSignal("CanvasSize"):Connect(function()
        self._updateRender = true
    end)
    self:GetPropertyChangedSignal("ScrollbarThickness"):Connect(function()
        self._updateRender = true
    end)
    self:GetPropertyChangedSignal("ScrollbarPadding"):Connect(function()
        self._updateRender = true
    end)
    self:GetPropertyChangedSignal("HorizontalScrollbarSide"):Connect(function()
        self._updateRender = true
    end)
    self:GetPropertyChangedSignal("VerticalScrollbarSide"):Connect(function()
        self._updateRender = true
    end)

	local InputService = Game:GetService("InputService")
	self.Maid:Add(InputService.Scrolled:Connect(function(dir)
		if not (self:MouseHovering() and self:IsSimulated()) then return end
		local horizontal = InputService:IsKeyPressed(Enum.KeyCode.LeftShift) or InputService:IsKeyPressed(Enum.KeyCode.RightShift)
		local scrollAxis = horizontal and Vector.xAxis or Vector.yAxis
		task.spawn(function()
			for i = 1, 3 do
				self:SetProperty("CanvasPosition", self:GetClampedCanvasPosition(self:GetProperty("CanvasPosition") - scrollAxis*(dir*10)))
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

function module:GetClampedCanvasPosition(canvasPosition)
	local canvasPosition = canvasPosition or self:GetProperty("CanvasPosition")
	return canvasPosition:Clamp(Vector.zero, self.RenderCanvasSize-self.RenderSize)
end

function module:UpdateCanvas(dt)
	local canvasX, canvasY
	if self.Canvas then
		canvasX, canvasY = self.Canvas:getPixelDimensions()
		canvasX = math.round(canvasX)
		canvasY = math.round(canvasY)
	end

	local solvedCanvasSize = self:GetProperty("CanvasSize"):Calculate(self.RenderSize)
	local canvasPosition = self:GetProperty("CanvasPosition")

	self.RenderCanvasSize = Vector.new(math.max(self.RenderSize.X, solvedCanvasSize.X), math.max(self.RenderSize.Y, solvedCanvasSize.Y))

	local desiredPosition = self:GetClampedCanvasPosition()

	self:SetProperty("CanvasPosition", canvasPosition:Lerp(desiredPosition, 1-0.0000001^dt))

	if love.graphics and (math.round(self.RenderSize.X) ~= canvasX or math.round(self.RenderSize.Y) ~= canvasY) then
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
	self:UpdateCanvas(dt)
end

function module:_draw()
	if self.Canvas then
		local prevCanvas = love.graphics.getCanvas()
		
		love.graphics.setCanvas(self.Canvas)
		love.graphics.clear()
		love.graphics.push()
		local offset = self.RenderPosition--+self:GetProperty("CanvasPosition")
		love.graphics.translate(-offset.X, -offset.Y)
		self:_drawChildren()
		love.graphics.pop()
		love.graphics.setCanvas(prevCanvas)
	end
	self:Draw()
end

function module:Draw()
	module.__base.Draw(self)

	if self.Canvas then
		self:GetProperty("CanvasColor"):Apply()
		love.graphics.cleanDrawImage(self.Canvas, self.RenderPosition, self.RenderSize)
	end

	local scrollbarThickness = self:GetProperty("ScrollbarThickness")
	local canvasPosition = self:GetProperty("CanvasPosition")

	self:GetProperty("ScrollbarColor"):Apply()
	love.graphics.push()
	love.graphics.translate(self.RenderPosition.X-self.RenderSize.X, self.RenderPosition.Y-self.RenderSize.Y)
	if self.RenderSize.Y ~= self.RenderCanvasSize.Y then
		local scrollPercent = canvasPosition.Y/(self.RenderCanvasSize.Y-self.RenderSize.Y)
		local scrollbarHeight = self.RenderSize.Y * (self.RenderSize.Y/self.RenderCanvasSize.Y)
		local scrollbarPosition = self:GetProperty("HorizontalScrollbarSide") == Enum.LateralDirection.Left and 0 or self.RenderSize.X - scrollbarThickness

		love.graphics.rectangle("fill", 0, 0, 10, 10)
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
	love.graphics.pop()
end

return module:Register()