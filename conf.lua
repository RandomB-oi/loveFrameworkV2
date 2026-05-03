function love.conf(t)
    local raw = arg or {}
	-- table.insert(raw, "--server")
	table.insert(raw, "--editor")
	-- table.insert(raw, "--debug")

	local parameters = {}

    for _, a in ipairs(raw) do
		if type(a) == "string" and a:sub(1,2) == "--" then
			parameters[a:sub(3,-1)] = true
		end
    end

	if parameters.debug then
		t.console = true
	end

	if parameters.server then
		-- parameters.editor = true
		-- parameters.debug = true

		t.console = true
		if not parameters.editor then
			t.modules.window = false
			t.modules.graphics = false
		end
	end

	_G.LaunchParameters = parameters
end