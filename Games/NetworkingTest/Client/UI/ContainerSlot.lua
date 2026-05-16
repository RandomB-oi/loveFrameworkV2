local module = {}
module.__index = module

local Run = Game:GetService("RunService")

module.new = function()
    local self = setmetatable({}, module)
    self.Maid = Maid.new()
    self.StackMaid = self.Maid:Add(Maid.new())

    self.CurrentStack = false

    self.Frame = self.Maid:Add(Object.Create("ImageLabel")):SetProperties({
        Name = "ContainerSlot",
        BackgroundColor = Color.Blank,
        Image = GameDirectory.."Client/Assets/ItemSlot.png"
    })

    self.Icon = Object.Create("ImageLabel"):SetProperties({
        Size = UDim2.fromScale(.8, .8),
        Position = UDim2.fromScale(.5, .5),
        AnchorPoint = Vector.one/2,
        BackgroundColor = Color.Blank,
        ZIndex = 1,
        Parent = self.Frame,
    })

    self.AmountLabel = Object.Create("TextLabel"):SetProperties({
        Size = UDim2.fromScale(.8, .4),
        Position = UDim2.fromScale(.5, .9),
        AnchorPoint = Vector.new(0.5, 1),
        BackgroundColor = Color.Blank,
        TextColor = Color.White,
        XAlignment = Enum.XAlignment.Right,
        YAlignment = Enum.YAlignment.Bottom,
        ZIndex = 2,
        Parent = self.Frame,
    })

    return self
end

function module:SetStack(newStack)
    if self.CurrentStack == newStack then return end
    self.CurrentStack = newStack

    if newStack then
        self.StackMaid:GiveTask(newStack:BindComponent("ItemIcon", function(comp)
            local imagePath = comp and comp:GetPath() or GameDirectory.."Client/Assets/Unknown.png"

            self.Icon:SetProperty("Image", imagePath)
        end))
        self.StackMaid:GiveTask(newStack:BindAmount(function(amount)
            self.AmountLabel:SetProperty("Text", tostring(amount))
        end))
    else
        self.Icon:SetProperty("Image", "")
        self.AmountLabel:SetProperty("Text", "")
    end
end

function module:Destroy()
    self.Maid:Destroy()
end

return module