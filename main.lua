local RootObject

love.load = function()
    love.window.setMode(800, 600, {resizable = true})
    RootObject = require("Engine.main")
    local Server -- check starting parameters
    -- local EditorEnabled = true

    if EditorEnabled then
        RootObject = require("Editor.main")
    end

    if Server then
        require("Server")
    else
        require("Client")
    end
end

local pDT = 0
love.update = function(dt)
	task.update(dt)
    RootObject:_update(dt)
    pDT = dt
end



love.draw = function()
    RootObject:_draw()


    local goodFPS = Color.new(0, 1, 0, 1)
    local okFPS = Color.new(1, 1, 0, 1)
    local stinkyFPS = Color.new(1, 0, 0, 1)
	local fps = math.round(1/pDT)
    if fps < 15 then
        stinkyFPS:Apply()
    elseif fps < 30 then
        okFPS:Apply()
    else
        goodFPS:Apply()
    end
    
	love.graphics.drawCustomText(tostring(fps), 12,30,1)
end