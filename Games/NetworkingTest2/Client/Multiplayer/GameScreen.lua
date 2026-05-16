return function (parent)
    local ClientService = Game:GetService("ClientService")

    local renderContainer = Object.Create("GUIContainer")
    renderContainer:SetProperties({
        Name = "MultiplayerScreen",
        Parent = parent,
    })

    local button = Object.Create("Button")
    button:SetProperties({
        Size = UDim2.new(0, 150, 0, 50),
        Position = UDim2.new(1, 0, 1, 0),
        AnchorPoint = Vector.new(1, 1),
        BackgroundColor = Color.from255(255,255,255,200),
        Parent = renderContainer,
    })

    local textLabel = Object.Create("TextLabel")
    textLabel:SetProperties({
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector.new(0.5, 0.5),
        TextColor = Color.from255(0,0,0,255),
        BackgroundColor = Color.Blank,
        Text = "Disconnect",
        Parent = button,
    })

    button.LeftClicked:Connect(function()
        ClientService:DisconnectFromServer()
    end)


    return renderContainer
end