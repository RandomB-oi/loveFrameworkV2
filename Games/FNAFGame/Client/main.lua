local OfficePrefab = require(GamePath.."Client.Prefabs.Office")
local GamePrefab = require(GamePath.."Client.Prefabs.Game")

local InputService = Game:GetService("InputService")
local RunService = Game:GetService("RunService")

local function StartGame()
    local gameMaid = Maid.new()

    local gameContainer, gameValues = GamePrefab(Game, 800/600)
    gameMaid:GiveTask(gameContainer)
    local gameFrame = gameValues.GameFrame

    local office = OfficePrefab(gameFrame)

    gameMaid:GiveTask(RunService.UpdateSignal:Connect(function(dt)
        local mouseLocation = (InputService:GetMouseLocation() - gameFrame.RenderPosition) / gameFrame.RenderSize
        
        local alphaX = math.clamp(mouseLocation.X, 0, 1)
        local moveVector = Vector.zero

        local turnPadding = 0.2
        if alphaX <= turnPadding then
            moveVector = Vector.new(math.map(alphaX, 0, turnPadding, -1, 0))
        elseif alphaX >= 1-turnPadding then
            moveVector = Vector.new(math.map(alphaX, 1, 1-turnPadding, 1, 0))
        end
        local minAnchor = (gameFrame.RenderSize.X/office.RenderSize.X)/2
        minAnchor = math.clamp(minAnchor, 0, 0.5)
        local maxAnchor = 1-minAnchor
        office:SetProperty("AnchorPoint", Vector.new(math.clamp(office.AnchorPoint.X + moveVector.X*dt, minAnchor, maxAnchor), 0.5))
    end))

    return gameMaid
end


	Game:GetService("ClientService"):HostLocalServer()

StartGame()