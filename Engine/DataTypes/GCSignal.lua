local module = {}
module.__index = module
module.__type = "GCSignal"

local function WrapConnection(self, connection)
	local reg = connection.Disconnect

	connection.Disconnect = function(...)
		reg(...)
		self:CheckGC()
	end
end

local function OutputMessage()
	print("Signal was garbage collected")
end

module.new = function(callback)
	return setmetatable({
		Callback = callback,
		Signal = Signal.new(),
	}, module)
end

function module:Connect(...)
	if not self.Signal then OutputMessage() return end
	return WrapConnection(self, self.Signal:Connect(...))
end

function module:Once(...)
	if not self.Signal then OutputMessage() return end
	return WrapConnection(self, self.Signal:Once(...))
end

function module:Wait(...)
	if not self.Signal then OutputMessage() return end
	return self.Signal:Wait(...)
end

function module:Fire(...)
	if not self.Signal then OutputMessage() return end
	return self.Signal:Fire(...)
end

function module:CheckGC()
	if not self.Signal then OutputMessage() return end
	if not next(self.Signal) then
		self:Destroy()
	end
end

function module:ToLua()
	return "GCSignal.new()"
end

function module:Destroy()
	self.Signal = nil
	self.Signal:Destroy()
	
	if self.Callback then
		self.Callback()
		self.Callback = nil
	end
end

return module