local module = {}
module.__index = module
module.__type = "ServerService"
module.__base = require("Engine.Objects.Services.Service")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("Simulated", true)

local enet = require("enet")
local ConnectedClient = require("Engine.Objects.Networking.ConnectedClient")

local MessageRate = 1/20
local lastMessageSend = -math.huge


local function GetClientIDFromPeer(self, peer)
    for id, p in pairs(self.Clients) do
        if p.Peer == peer then
            return id
        end
    end
end

local function AddClient(self, peer)
    local newClient = ConnectedClient.new(peer)
    local clientID = newClient.ID
    self.Clients[clientID] = newClient

    print("new Client", clientID)

    newClient.Maid:GiveTask(function()
        print("remove client")
        self.Clients[clientID] = nil
        local exitCode = newClient.DisconnectCode or 0

        newClient.Peer:disconnect_later(exitCode)
        self.ClientDisconnected:Fire(clientID, exitCode)
    end)

    self:SendMessage(clientID, "connect", {
        id = clientID,
    })

    self.ClientConnected:Fire(clientID)
end


module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
    self.Clients = {}
    self.Host = nil

    self.ClientConnected = self.Maid:Add(Signal.new())
    self.ClientDisconnected = self.Maid:Add(Signal.new())
    self.MessageRecieved = self.Maid:Add(Signal.new())

    -- finish this
    self.ClientConnected:Connect(function(clientID)
        -- Game:Replicate(nil, clientID)
        for _, service in ipairs(Game:GetServices()) do
            service:Replicate(nil, clientID)
        end
    end)

    -- self.MessageRecieved:Connect(print)
    self.MessageRecieved:Connect(function(clientID, message, data)
        if message == "Batch" then
            for _, command in pairs(data) do
                self.MessageRecieved:Fire(clientID, command.name, command.data)
            end
        elseif message == "RemoteEvent" then
            local remote = Object.GetByID(data.ID)
            if remote then
                remote:_addEvent({clientID, unpack(data.Data)})
            end
        end
    end)

	return self
end

function module:StartServer(port)
    self.Host = enet.host_create("*:" .. tostring(port))
    print("Server hosted on port", port)

    local function newInstance(id, object)
        object.Changed:Connect(function(prop)
            object:Replicate(prop)
        end)
    end

    Object.ObjectCreated:Connect(newInstance)
    for id, instance in pairs(Object.GetAll()) do
        newInstance(id, instance)
    end
end

function module:SendMessage(clientID, name, value)
    local client = self.Clients[clientID]
    if not client then return end

    client:SendMessage(name, value)
end

function module:SendMessageAll(name, value)
    for clientID in pairs(self.Clients) do
        self:SendMessage(clientID, name, value)
    end
end

function module:GetPlayerObject(clientID)
    local client = self.Clients[clientID]
    return client and client.Instance
end

function module:DisconnectClient(clientID, code)
    local client = self.Clients[clientID]
    client.DisconnectCode = code
    client:Destroy()
end

function module:DisconnectAll(code)
    for id, client in next, self.Clients do
        self:DisconnectClient(id, code)
    end
end

function module:Update()
    if not Game:GetService("RunService"):IsServer() then return end
    if not self.Host then return end

    local encodingService = Game:GetService("EncodingService")

    if os.clock() - lastMessageSend > MessageRate then
        lastMessageSend = os.clock()
        for clientID, client in pairs(self.Clients) do
            self:SendMessage(clientID, "Ping")
            client:BatchSend()
        end
    end

    local event = self.Host:service(0)
    while event do
        if event.type == "connect" then
            AddClient(self, event.peer)
        elseif event.type == "receive" then
            local success, data = encodingService:Decode(event.data)
            if success and data then
                local clientID = GetClientIDFromPeer(self, event.peer)
                if clientID then 
                    self.MessageRecieved:Fire(clientID, data.name, data.data)
                end
            end

        elseif event.type == "disconnect" then
            local clientID = GetClientIDFromPeer(self, event.peer)
            if clientID then
                self:DisconnectClient(clientID)
            end
        end

        event = self.Host:service(0)
    end
end

return module:Register()