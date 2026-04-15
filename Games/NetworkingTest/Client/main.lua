local InputService = Game:GetService("InputService")
local ClientService = Game:GetService("ClientService")

require(GamePath.."Client.Multiplayer.main")

ClientService.Connected:Connect(function()
    local remote = workspace:WaitForChild("MoveMouse")
    local mainFrame = workspace:WaitForChild("MainRender"):WaitForChild("Holder"):WaitForChild("WorldRender")
    print("Connected to server, starting to send mouse position")
    while true do
        remote:FireServer(InputService:GetMouseLocation() - mainFrame.RenderPosition)
        task.wait()
    end
end)