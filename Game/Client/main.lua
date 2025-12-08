local InputService = Game:GetService("InputService")

InputService.InputBegan:Connect(function(input)
    for i,v in next, input do
        print(i,v)
    end
end)

local guiMain = Object.Create("GUIContainer")
:SetProperty("Parent", Game)


local a = Object.Create("Frame"):SetProperty("Parent", guiMain):SetProperty("Size", UDim2.new(0,200,0,50)):SetProperty("BackgroundColor", Color.new(1,0,1,1))
Object.Create("Frame"):SetProperty("Parent", guiMain):SetProperty("Size", UDim2.new(0,50,0,100)):SetProperty("BackgroundColor", Color.new(1,1,0,1))

Object.Create("UIListLayout"):SetProperty("Parent", guiMain)


task.spawn(function()
    while task.wait() do
        a.BackgroundColor = Color.new(math.sin(os.clock())/2+0.5, 1, 1, 1)
    end
end)