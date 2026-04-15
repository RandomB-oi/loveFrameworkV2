return function(parent, ratio)
    local guiContainer = Object.Create("GUIContainer"):SetProperties({
        Parent = parent,
    })

    local gameFrame = Object.Create("Frame"):SetProperties({
        Size = UDim2.fromScale(1, 1),
        AnchorPoint = Vector.one/2,
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor = Color.Blank,
        Parent = guiContainer,
    })

    Object.Create("UIAspectRatioConstraint"):SetProperties({AspectRatio = ratio, Parent = gameFrame})

    return guiContainer, {
        GameFrame = gameFrame
    }
end