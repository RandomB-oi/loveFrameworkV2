love.load = function()
    require("Engine.main")

    require("Client")
end

love.update = function(dt)
	task.update(dt)
    Game:_update(dt)
end

love.draw = function()
    Game:_draw()
end