local module = {}
module.__index = module

local Run = Game:GetService("RunService")
local ContainerSlotClass = require(GamePath.."Client.UI.ContainerSlot")

module.new = function()
    local self = setmetatable({}, module)
    self.Maid = Maid.new()
    self.ContainerMaid = self.Maid:Add(Maid.new())

    self.SlotFrames = {}
    self.CurrentContainer = nil

    self.Frame = self.Maid:Add(Object.Create("Frame")):SetProperties({
        Name = "ContainerMenu",
        BackgroundColor = Color.new(1,1,1,.5),
    })

    return self
end

function module:UpdateFrames()
    if not self.CurrentContainer then return end
    self.CurrentContainer:ForEach(function(index, slot)
        local slotFrame = self.SlotFrames[index]
        if not slotFrame then return end

        slotFrame:SetStack(slot)
    end)
end

function module:AttachContainer(container)
    self.ContainerMaid:Destroy()

    self.CurrentContainer = container
    if container then
        local rowSize = container.RowSize
        local width, height = rowSize, math.ceil(container.SlotCount/rowSize)
        container:ForEach(function(index)
            local x = ((index-1) % rowSize)
            local y = math.floor((index-1)/rowSize)
            
            local newSlot = ContainerSlotClass.new()
            newSlot.Frame:SetProperties({
                Position = UDim2.fromScale(x/width, y/height),
                Size = UDim2.fromScale(1/width, 1/height),
                Parent = self.Frame
            })
            self.SlotFrames[index] = newSlot
        end)

        local initial = true
        container:BindItems(function(index, item)
            local con = item.AmountChanged:Connect(function()
                self:UpdateFrames()
            end)

            if not initial then
                self:UpdateFrames()
            end

            return function()
                con:Disconnect()
                self:UpdateFrames()
            end
        end)

        self:UpdateFrames()
        initial = false

        self.ContainerMaid:GiveTask(function()
            for i,v in next, self.SlotFrames do
                v:Destroy()
            end
            self.SlotFrames = {}
        end)
    end
end

function module:Destroy()
    self.Maid:Destroy()
end

return module