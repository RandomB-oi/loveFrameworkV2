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
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        Parent = backdrop,
    })

    local layout = Object.Create("UIListLayout")
    layout:SetProperties({
        Padding = UDim2.fromOffset(6, 6),
        ListAxis = Vector.yAxis,
        Parent = backdrop,
    })

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function(size)
        backdrop:SetProperty("CanvasSize", UDim2.fromOffset(0, size.Y))
    end)

    local serial = 0
    local function NewButton(text)
        serial = serial + 1
        local button = Object.Create("Button"):SetProperties({
            Size = UDim2.new(1, 0, 0, 75),
            Position = UDim2.new(0, 0, 0, 0),
            AnchorPoint = Vector.new(0.5, 0),
            BackgroundColor = Color.from255(255,255,255,200),
            LayoutOrder = serial,
            Parent = backdrop,
        })

        Object.Create("TextLabel"):SetProperties({
            Size = UDim2.new(1, -6, 1, -6),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector.new(0.5, 0.5),
            TextColor = Color.from255(0,0,0,255),
            BackgroundColor = Color.Blank,
            Text = text,
            Parent = button,
        })

        return button
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
        Enabled = false,
    })

    Object.Create("UIPadding"):SetProperties({
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        Parent = joinBackdrop,
    })

    Object.Create("UIListLayout"):SetProperties({
        Padding = UDim2.fromOffset(6, 6),
        ListAxis = Vector.yAxis,
        Parent = joinBackdrop,
    })

    local serverIP = Object.Create("TextBox")
    serverIP:SetProperties({
        Size = UDim2.new(1, 0, 0, 75),
        Position = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector.new(0.5, 0),
        BackgroundColor = Color.from255(255,255,255,200),
        PlaceholderText = "Server IP",
        Text = "localhost",
        LayoutOrder = 1,
        Parent = joinBackdrop,
    })

    local serverPort = Object.Create("TextBox")
    serverPort:SetProperties({
        Size = UDim2.new(1, 0, 0, 75),
        Position = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector.new(0.5, 0),
        BackgroundColor = Color.from255(255,255,255,200),
        PlaceholderText = "Server Port",
        Text = "6767",
        LayoutOrder = 2,
        Parent = joinBackdrop,
    })

    local connectButton = NewButton("Connect")
    connectButton:SetProperties({
        LayoutOrder = 3,
        Parent = joinBackdrop,
    })

    connectButton.LeftClicked:Connect(function()
        ClientService:ConnectToServer(serverIP.Text, serverPort.Text)
    end)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function(size)
        joinBackdrop.CanvasSize = UDim2.fromOffset(0, size.Y)
    end)

    NewButton("Join").LeftClicked:Connect(function()
        joinBackdrop.Enabled = not joinBackdrop.Enabled
    end)

    return renderContainer
end