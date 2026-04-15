local InputService = Game:GetService("InputService")
local ClientService = Game:GetService("ClientService")

require(GamePath.."Client.Multiplayer.main")

ClientService.Connected:Connect(function()
    local remote = workspace:WaitForChild("ServerScreen"):WaitForChild("ReplicationTest1"):WaitForChild("ChangeColor")
    while task.wait(1/3) do
        remote:FireServer(Color.new(math.random(), math.random(), math.random(), 1))
    end
end)