local module = {}
module.__index = module
module.__type = "Signal"
	
module.new = function()
	return setmetatable({}, module)
end

local connectionMeta = {}
connectionMeta.__index = connectionMeta
function connectionMeta:Disconnect()
	for i,v in ipairs(self[2]) do
		if v == self then
			table.remove(self[2], i)
			break
		end
	end
end

function module:Connect(callback)
	local connection = setmetatable({callback, self}, connectionMeta)
	table.insert(self, connection)
	return connection
end

function module:Once(callback)
	local connection connection = self:Connect(function(...)
		connection:Disconnect()
			
		coroutine.wrap(callback)(...)
	end)
end

function module:Wait()
	local thread = coroutine.running()
	self:Once(function(...)
		coroutine.resume(thread, ...)
	end)
	return coroutine.yield()
end

function module:Fire(...)
	local args = {...}

	for _, connection in pairs(table.shallowCopy(self)) do
		if type(connection) == "table" then
			xpcall(coroutine.wrap(connection[1]), function(err)
				warn(err, debug.traceback())
			end, unpack(args))
		end
	end
end

function module:ToLua()
	return "Signal.new()"
end

function module:Destroy()
	local index = next(self)
	while index do
		self[index] = nil
		index = next(self)
	end
end

return module