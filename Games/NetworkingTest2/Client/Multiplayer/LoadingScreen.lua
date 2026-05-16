return function (parent, ip, port)
    local ClientService = Game:GetService("ClientService")

    local renderContainer = Object.Create("GUIContainer")
    renderContainer:SetProperties({
        Name = "MultiplayerScreen",
        Parent = parent,
    })

    local mainFrame = Object.Create("Frame")
    mainFrame:SetProperties({
        Name = "ServerConnectScene",
        Size = UDim2.fromOffset(250,100),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector.new(0.5, 0.5),
        BackgroundColor = Color.new(.2,.2,.2,1),
        Parent = renderContainer
    })

    Object.Create("TextLabel"):SetProperties({
        Size = UDim2.new(1, -12, 0, 24),
        Position = UDim2.new(0.5, 0, 0.5, 12),
        AnchorPoint = Vector.new(0.5, 0.5),
        TextColor = Color.from255(200,200,200,255),
        BackgroundColor = Color.Blank,
        Text = ip .. ":" .. port,
        Parent = mainFrame,
    })

    local connectingLabel = Object.Create("TextLabel")
    connectingLabel:SetProperties({
        Size = UDim2.new(1, -12, 0, 24),
        Position = UDim2.new(0.5, 0, 0.5, -12),
        AnchorPoint = Vector.new(0.5, 0.5),
        TextColor = Color.from255(200,200,200,255),
        BackgroundColor = Color.Blank,
        Text = "",
        Parent = mainFrame,
    })
    local active = true
    connectingLabel.Maid:GiveTask(function()
        active = false
    end)
    task.spawn(function()
        local i = 0
        while active do
            i = (i + 1) % 4
            connectingLabel:SetProperty("Text", "Connecting"..string.rep(".", i))
            task.wait(1/3)
        end
    end)

    local button = Object.Create("Button")
    button:SetProperties({
        Size = UDim2.new(0, 150, 0, 50),
        Position = UDim2.new(.5, 0, 1, 0),
        AnchorPoint = Vector.new(0.5, 0),
        BackgroundColor = Color.from255(255,255,255,200),
        Parent = mainFrame,
    })

    local textLabel = Object.Create("TextLabel")
    textLabel:SetProperties({
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector.new(0.5, 0.5),
        TextColor = Color.from255(0,0,0,255),
        BackgroundColor = Color.Blank,
        Text = "Cancel",
        Parent = button,
    })

    button.LeftClicked:Connect(function()
        ClientService:DisconnectFromServer()
    end)


    return renderContainer
end