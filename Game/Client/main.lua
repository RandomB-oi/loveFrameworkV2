local InputService = Game:GetService("InputService")

InputService.InputBegan:Connect(function(input)
    for i,v in next, input do
        print(i,v)
    end
end)

local guiMain = Object.Create("GUIContainer")
:SetProperty("Parent", Game)


local a = Object.Create("Frame"):SetProperty("Size", UDim2.new(0,300,0,100)):SetProperty("BackgroundColor", Color.new(1,0,1,1)):SetProperty("Parent", guiMain)
Object.Create("UIScale"):SetProperty("Scale", 2):SetProperty("Parent", a)
Object.Create("UIAspectRatioConstraint"):SetProperty("AspectRatio", 2):SetProperty("Parent", a)
Object.Create("UISizeConstraint"):SetProperty("Max", Vector.new(100,math.huge)):SetProperty("Parent", a)

Object.Create("Frame"):SetProperty("Parent", guiMain):SetProperty("Size", UDim2.new(0,50,0,100)):SetProperty("BackgroundColor", Color.new(1,1,0,1))

Object.Create("UIListLayout"):SetProperty("Parent", guiMain)


Object.Create("UIPadding"):SetProperty("Parent", a)
:SetProperty("PaddingLeft", UDim.new(0,6))
:SetProperty("PaddingRight", UDim.new(0,6))
:SetProperty("PaddingTop", UDim.new(0,6))
:SetProperty("PaddingBottom", UDim.new(0,6))
Object.Create("Frame"):SetProperty("Parent", a):SetProperty("Size", UDim2.new(1,0,1,0)):SetProperty("BackgroundColor", Color.new(1,0,1,1))

print(string.tostring(Game))

task.spawn(function()
    while task.wait() do
        a.BackgroundColor = Color.new(math.sin(os.clock())/2+0.5, 1, 1, 1)
    end
end)