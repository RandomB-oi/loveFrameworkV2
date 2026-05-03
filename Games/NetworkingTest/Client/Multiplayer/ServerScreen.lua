return function (parent)
    local ClientService = Game:GetService("ClientService")
    
    local renderContainer = Object.Create("GUIContainer")
    renderContainer:SetProperties({
        Name = "MultiplayerScreen",
        Parent = parent,
    })

    local mainFrame = Object.Create("Frame")
    mainFrame:SetProperties({
        Name = "ServerConnectScene",
        Size = UDim2.fromScale(1,1),
        BackgroundColor = Color.new(0,0,0,1),
        AnchorPoint = Vector.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Parent = renderContainer
    })

    Object.Create("UIPadding"):SetProperties({
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        Parent = mainFrame,
    })

    local backdrop = Object.Create("ScrollingFrame")
    backdrop:SetProperties({
        Size = UDim2.new(.5, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector.new(0, 0),
        BackgroundColor = Color.from255(255,255,255,50),
        ScrollbarPadding = Enum.ScrollbarPadding.Scrollbar,
        Parent = mainFrame,
    })

    Object.Create("UIPadding"):SetProperties({
        PaddingLeft = UDim.new(0, 3),
        PaddingRight = UDim.new(0, 3),
        PaddingTop = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 3),
        Parent = backdrop,
    })

    local layout = Object.Create("UIListLayout")
    layout:SetProperties({
        Padding = UDim2.fromOffset(0, 0),
        ListAxis = Vector.yAxis,
        Parent = backdrop,
    })

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function(size)
        backdrop:SetProperty("CanvasSize", UDim2.fromOffset(0, size.Y))
    end)

    local serial = 0
    local function NewButton(text)
        serial = serial + 1
        local holder = Object.Create("Frame"):SetProperties({
            Size = UDim2.new(1, 0, 0, 75),
            Position = UDim2.new(0, 0, 0, 0),
            AnchorPoint = Vector.new(0.5, 0),
            BackgroundColor = Color.Blank,
            LayoutOrder = serial,
            Parent = backdrop,
        })
        local button = Object.Create("Button"):SetProperties({
            Size = UDim2.new(1, -6, 1, -6),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector.new(0.5, 0.5),
            BackgroundColor = Color.from255(255,255,255,200),
            LayoutOrder = serial,
            Parent = holder,
        })

        button:GetPropertyChangedSignal("Hovering"):Connect(function()
            local size = button:GetProperty("Hovering") and UDim2.new(1,0,1,0) or UDim2.new(1, -6, 1, -6)

            Game:GetService("TweenService"):Create(
                button,
                TweenInfo.new(1/7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                {Size = size}
            ):Play()
        end)

        Object.Create("TextLabel"):SetProperties({
            Size = UDim2.new(1, -6, 1, -6),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector.new(0.5, 0.5),
            TextColor = Color.from255(0,0,0,255),
            BackgroundColor = Color.Blank,
            Text = text,
            Parent = button,
        })

        return button, holder
    end


    NewButton("Host").LeftClicked:Connect(function()
        ClientService:HostLocalServer()
    end)



    local joinBackdrop = Object.Create("ScrollingFrame")
    joinBackdrop:SetProperties({
        Size = UDim2.new(.5, -6, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector.new(1, 0),
        BackgroundColor = Color.from255(255,255,255,50),
        ScrollbarPadding = Enum.ScrollbarPadding.Scrollbar,
        Parent = mainFrame,
        Visible = false,
    })

    Object.Create("UIPadding"):SetProperties({
        PaddingLeft = UDim.new(0, 3),
        PaddingRight = UDim.new(0, 3),
        PaddingTop = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 3),
        Parent = joinBackdrop,
    })

    Object.Create("UIListLayout"):SetProperties({
        Padding = UDim2.fromOffset(0, 0),
        ListAxis = Vector.yAxis,
        Parent = joinBackdrop,
    })

    local serverIPHolder = Object.Create("Frame"):SetProperties({
        Size = UDim2.new(1, 0, 0, 75),
        Position = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector.new(0.5, 0),
        BackgroundColor = Color.Blank,
        LayoutOrder = 1,
        Parent = joinBackdrop,
    })
    local serverIP = Object.Create("TextBox")
    serverIP:SetProperties({
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector.new(0.5, 0.5),
        BackgroundColor = Color.from255(255,255,255,200),
        PlaceholderText = "Server IP",
        Text = "localhost",
        Parent = serverIPHolder,
    })

    local serverPortHolder = Object.Create("Frame"):SetProperties({
        Size = UDim2.new(1, 0, 0, 75),
        Position = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector.new(0.5, 0),
        BackgroundColor = Color.Blank,
        LayoutOrder = 2,
        Parent = joinBackdrop,
    })
    local serverPort = Object.Create("TextBox")
    serverPort:SetProperties({
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector.new(0.5, 0.5),
        BackgroundColor = Color.from255(255,255,255,200),
        PlaceholderText = "Server Port",
        Text = "6767",
        Parent = serverPortHolder,
    })

    local connectButton, connectHolder = NewButton("Connect")
    connectHolder:SetProperties({
        LayoutOrder = 3,
        Parent = joinBackdrop,
    })

    connectButton.LeftClicked:Connect(function()
        ClientService:ConnectToServer(serverIP:GetProperty("Text"), serverPort:GetProperty("Text"))
    end)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function(size)
        joinBackdrop:SetProperty("CanvasSize", UDim2.fromOffset(0, size.Y))
    end)

    NewButton("Join").LeftClicked:Connect(function()
        joinBackdrop:SetProperty("Visible", not joinBackdrop:GetProperty("Visible"))
    end)

    return renderContainer
end