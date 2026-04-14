local module = {}
module.__index = module
module.__type = "ClientService"
module.__base = require("Engine.Objects.Services.Service")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("Simulated", true)
module:CreateProperty("ServerIP", "string", "")
module:CreateProperty("ServerPort", "string", "")
module:CreateProperty("LocalID", "string", "")
module:CreateProperty("DisconnectTimeoutTime", "number", 60)

local enet = require("enet")

local ServerInstances = {}

local function ClearInstances()
    local old = ServerInstances
    ServerInstances = {}
    for i,v in pairs(old) do
        v:Destroy()
    end
end

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

    self.Connected = Signal.new()
    self.Disconnected = Signal.new()
    self.MessageRecieved = Signal.new()

    self.Hidden = false

    self.ServerPeer = nil
    self.LocalServer = nil
    self.LastPing = os.clock()

    self.Disconnected:Connect(ClearInstances)
    self.MessageRecieved:Connect(function(message, data)
        if message == "CreateInstance" then
            local data = Serializer.Decode(data)
            local object = self:GetInstance(data.ID, data.ClassName)
            object:DeserializeData(data)
        elseif message == "UpdateProperty" then
            local object = self:GetInstance(data.ID)
            if object then
                object:SetProperty(data.Prop, Serializer.Decode(data.Value))
            end
        elseif message == "RemoveInstance" then
            local object = self:GetInstance(data.ID)
            if object then
                object:Destroy()
            end
        elseif message == "RemoteEvent" then
            local remote = Object.GetByID(data.ID)
            if remote then
                remote:_addEvent(data.Data)
            else
                Object.GetClass("RemoteEvent")._addEvent(data.ID, data.Data)
            end
        elseif message == "Batch" then
            for _, command in pairs(data) do
                self.MessageRecieved:Fire(command.name, command.data)
            end
        elseif message == "Ping" then
            self.LastPing = os.clock()
        elseif message == "connect" then
            self:SetProperty("LocalID", data.id)
            self:SendMessage("connected")
        end
    end)

	return self
end

function module:GetInstance(id, className)
    local existing = Object.GetByID(id)
    if existing then return existing end

    if className then
        local new = Object.Create(className, id)
        ServerInstances[id] = new
        new.Maid:GiveTask(function()
            ServerInstances[id] = nil
        end)
        return new
    end
end

function module:ConnectedToServer()
    return not not (self.Host and self.ServerPeer or self._connected), not not self._connected
end

function module:ConnectToServer(ip, port)
    if self:ConnectedToServer() then return end
    self:DisconnectFromServer()

    self.LastPing = os.clock()
    self.ServerIP = tostring(ip)
    self.ServerPort = tostring(port)

    self.Host = enet.host_create()
    self.ServerPeer = self.Host:connect(ip .. ":" .. port)
    if self.ServerPeer then
        return true
    end
end

function module:HostLocalServer()
    if self:ConnectedToServer() then return end
    self:DisconnectFromServer()

    local thread = love.thread.newThread("Server.lua")
    thread:start()
    local success = self:ConnectToServer("localhost", 6767)
    if success then
        self.LocalServer = thread
        return true
    end
    
    love.thread.getChannel("server_events"):push("shutdown")
    return false
end

function module:DisconnectFromServer()
    self._connected = false
    
    if self.ServerPeer then
        self.ServerPeer:disconnect()
        self.ServerPeer = nil
        self.Disconnected:Fire()
        print("Disconnect from server")
    end
    if self.Host then
        self.Host:destroy()
        self.Host = nil
        print("clean host")
    end
    
    if self.LocalServer then
        love.thread.getChannel("server_events"):push("shutdown")
        self.LocalServer = nil
        print("Clean server thread")
    end
end

function module:SendMessage(name, value)
    if not self.ServerPeer then print("no server peer") return end
    
    task.spawn(function()
        if not (self.LocalID and self._connected) then repeat until (self.ServerPeer and self._connected) end
        local encodingService = Game:GetService("EncodingService")
        local success, data = encodingService:Encode({
            name = name,
            data = value
        })
        if success then
            self.ServerPeer:send(data)
        end
    end)
end

function module:CheckTimeout()
    if not self:ConnectedToServer() then return end
    if os.clock() - self.LastPing >= self:GetProperty("DisconnectTimeoutTime") then
        self:DisconnectFromServer()
    end
end

function module:Update()
    if not Game:GetService("RunService"):IsClient() then return end
    if not (self.ServerPeer and self.Host) then return end
    local encodingService = Game:GetService("EncodingService")

    local event = self.Host:service(0)
    while event do
        if event.type == "receive" then
            local success,  data = encodingService:Decode(event.data)

            if success then
                self.MessageRecieved:Fire(data.name, data.data)
            end
        elseif event.type == "connect" then
            self._connected = true
            self.Connected:Fire()
        elseif event.type == "disconnect" then
            self:DisconnectFromServer()
        end

        event = self.Host:service(0)
    end

    self:CheckTimeout()
end

return module:Register()