local module = {}
module.__index = module

local NextClientID = 0

local function GetID() -- count downwards so it doesnt conflict with the entity ids
    NextClientID = NextClientID + 1
	return tostring(-NextClientID)
end

module.new = function(peer)
	local ServerService = Game:GetService("ServerService")

    local self = setmetatable({}, module)
	self.Maid = Maid.new()
	self.Peer = peer
	self.ID = GetID()
	self.Instance = self.Maid:Add(Object.Create("Player", self.ID))
	self.Instance:SetProperties({
		Name = self.ID,
		Parent = Game:GetService("Players"),
	})

	self.PendingMessages = {}

	return self
end

function module:SendMessage(message, data)
	-- make this update old messages instead of adding tons
	local updated = false
	if message == "UpdateProperty" then
		for i = #self.PendingMessages, 1, -1 do
			local pendingMessage = self.PendingMessages[i]
			if pendingMessage.name == message and pendingMessage.data.ID == data.ID and pendingMessage.data.Prop == data.Prop then
				pendingMessage.data.Value = data.Value
				updated = true
				break
			end
		end
	end
	if not updated then
		table.insert(self.PendingMessages, {
			name = message,
			data = data
		})
	end

	local encodingService = Game:GetService("EncodingService")
	local success, data = encodingService:Encode({
		name = message,
		data = data,
	})
	if success then
		self.Peer:send(data)
	end
end

function module:BatchSend()
	if not next(self.PendingMessages) then return end
	local encodingService = Game:GetService("EncodingService")

	local name, value = "Batch", self.PendingMessages

	if not value[2] then
		name, value = value[1].name, value[1].data
	end

	local success, data = encodingService:Encode({
		name = name,
		data = value,
	})
	if success then
		self.PendingMessages = {}
		self.Peer:send(data)
	end
end

function module:Destroy()
	self.Maid:Destroy()
end

return module