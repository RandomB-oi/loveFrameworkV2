return function(parent)
    local returnInfo = {}
    returnInfo.FlashlightToggle = Signal.new()

    local officeFrame = Object.Create("ImageLabel"):SetProperties({
        Size = UDim2.new(10, 0, 1, 0),
        AnchorPoint = Vector.one/2,
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor = Color.new(0.1,0.1,0.1,1),
        Parent = parent,
        Image = GameDirectory.."Client/Assets/Office.png"
    })

    Object.Create("UIAspectRatioConstraint"):SetProperties({AspectRatio = 2, Parent = officeFrame})

    local hallway = Object.Create("Button"):SetProperties({
        Size = UDim2.new(.5, 0, .5, 0),
        AnchorPoint = Vector.one/2,
        Position = UDim2.fromScale(0.475, 0.45),
        -- BackgroundColor = Color.new(1,0,0,.5),
        BackgroundColor = Color.Blank,
        ZIndex = 1,
        Parent = officeFrame,
    })
    Object.Create("UIAspectRatioConstraint"):SetProperties({AspectRatio = 1, Parent = hallway})

    local vent1 = Object.Create("Button"):SetProperties({
        Size = UDim2.new(.5, 0, .25, 0),
        AnchorPoint = Vector.one/2,
        Position = UDim2.fromScale(0.125, 0.7),
        -- BackgroundColor = Color.new(1,0,0,.5),
        BackgroundColor = Color.Blank,
        ZIndex = 1,
        Parent = officeFrame,
    })
    Object.Create("UIAspectRatioConstraint"):SetProperties({AspectRatio = 1, Parent = vent1})

    local vent2 = Object.Create("Button"):SetProperties({
        Size = UDim2.new(.5, 0, .25, 0),
        AnchorPoint = Vector.one/2,
        Position = UDim2.fromScale(0.875, 0.7),
        -- BackgroundColor = Color.new(1,0,0,.5),
        BackgroundColor = Color.Blank,
        ZIndex = 1,
        Parent = officeFrame,
    })
    Object.Create("UIAspectRatioConstraint"):SetProperties({AspectRatio = 1, Parent = vent2})

    local flashlight = Object.Create("ImageLabel"):SetProperties({
        Size = UDim2.fromScale(1,1),
        AnchorPoint = Vector.one/2,
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor = Color.Blank,
        Image = GameDirectory.."Client/Assets/BlankImage.png",
        ImageColor = Color.new(1,1,1,.2),
        Visible = true
    })
    flashlight.ImageShader = {
        Shader = love.graphics.newShader(GameDirectory.."Client/Shaders/FlashlightPixel.glsl", GameDirectory.."Client/Shaders/GenericVertex.glsl"),
        Update = function(shader)
            -- shader:send("fog_start", 10)
            -- shader:send("fog_end", 100)
            -- shader:send("circle_percent", 0.5)
        end
    }
    returnInfo.Flashlight = flashlight

    local function BindFlashlight(button, name)
        button.LeftClicked:Connect(function()
            returnInfo.FlashlightToggle:Fire(name, true)
        end)
        button.LeftReleased:Connect(function()
            returnInfo.FlashlightToggle:Fire(name, false)
        end)
    end
    BindFlashlight(hallway, "Hallway")
    BindFlashlight(vent1, "Vent1")
    BindFlashlight(vent2, "Vent2")


    returnInfo.FlashlightToggle:Connect(function(name, toggle)
        if not toggle then
            flashlight:SetParent(nil)
            return
        end

        if name == "Hallway" then
            flashlight:SetParent(hallway)
        elseif name == "Vent1" then
            flashlight:SetParent(vent1)
        elseif name == "Vent2" then
            flashlight:SetParent(vent2)
        end
    end)


    return officeFrame, returnInfo
end