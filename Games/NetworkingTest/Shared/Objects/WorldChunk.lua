local module = {}
module.__index = module
module.__type = "WorldChunk"
module.__base = require("Engine.Objects.GUI.Frame")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("ZIndex", -1)
module:SetDefaultProperyValue("BackgroundColor", Color.Blank)
module:CreateProperty("ChunkSize", "number", 8)
module:CreateProperty("ChunkData", "Buffer", Buffer.create(1))

local Run = Game:GetService("RunService")
local Players = Game:GetService("Players")
local BytesPerBlock = 1 -- 256 blocks

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
    local chunkSize = self:GetProperty("ChunkSize")
    self:SetProperty("ChunkData", Buffer.create(BytesPerBlock * chunkSize^2))
    self:SetProperty("Size", UDim2.fromScale(chunkSize, chunkSize))

    if Run:IsServer() then
        local chunkSize = self:GetProperty("ChunkSize")
        for x = 0, chunkSize-1 do
            for y = 0, chunkSize-1 do
                self:WriteBlock(x,y, math.random(0,2))
            end
        end

        task.spawn(function()
            while task.wait(1/3) do
                self:WriteBlock(math.random(0,7), math.random(0,7), math.random(0,2))
            end
        end)
    else
        self:BindToProperty("ChunkData", function()
            self:RenderChunk()
        end)
    end

    return self
end

function module:RenderChunk()
    if not self.Frames then
        self.Frames = {}
    end

    local chunkSize = self:GetProperty("ChunkSize")
    for x = 0, chunkSize-1 do
        if not self.Frames[x] then self.Frames[x] = {} end
        for y = 0, chunkSize-1 do
            local block = self:ReadBlock(x,y)

            local frame = self.Frames[x][y]
            if frame and tostring(frame:GetProperty("Name")) ~= tostring(block) then
                frame:Destroy()
                self.Frames[x][y] = nil
            end
            
            if block ~= 0 then
                if self.Frames[x][y] then return end
                local newFrame = Object.Create("ImageLabel"):SetProperties({
                    Size = UDim2.fromScale(1/chunkSize, 1/chunkSize),
                    Position = UDim2.fromScale(x/chunkSize, y/chunkSize),
                    Parent = self,
                    Archivable = false,
                    Replicates = false,
                })

                if block == 1 then
                    newFrame:SetProperty("Image", GameDirectory.."Client/Assets/Grass.png")
                elseif block == 2 then
                    newFrame:SetProperty("Image", GameDirectory.."Client/Assets/bob.png")
                end

                self.Frames[x][y] = newFrame
            end
        end
    end
end

function module:GetBlockIndex(x,y)
    return (y * self:GetProperty("ChunkSize") + x) * BytesPerBlock
end

function module:ReadBlock(x,y)
    local data = self:GetProperty("ChunkData")
    local offset = self:GetBlockIndex(x,y)
    return Buffer.readi8(data, offset)
end

function module:WriteBlock(x,y, id)
    local data = self:GetProperty("ChunkData")
    local offset = self:GetBlockIndex(x,y)
    Buffer.writei8(data, offset, id)
    self:SetProperty("ChunkData", data)
end

return module:Register()