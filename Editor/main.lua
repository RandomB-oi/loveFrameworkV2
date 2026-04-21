autoLoad("Editor", { "Editor.main" })

EditorScreen = Object.Create("GUIContainer"):SetProperties({
	Name = "Editor"
})
local EditorFrame = Object.Create("Frame"):SetProperties({
	Name = "EditorFrame",
	ZIndex = 10,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor = Color.Blank,
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector.one / 2,
	Parent = EditorScreen,
})

local BannerSize = 24

local Banner = Object.Create("Frame"):SetProperties({
	Position = UDim2.new(0, 0, 0, 0),
	AnchorPoint = Vector.zero,
	Size = UDim2.new(1, 0, 0, BannerSize),
	BackgroundColor = Color.from255(46, 46, 46, 255),
	Parent = EditorFrame,
})

local BannerList = Object.Create("UIListLayout"):SetProperties({
	Padding = UDim2.new(0, 0, 0, 0),
	ListAxis = Vector.new(1, 0),
	SortMode = Enum.SortMode.LayoutOrder,
	Parent = Banner,
})

EditorFrame.BannerButtons = {}

local serial = 0
local function NewTopButton(image, text)
	serial = serial + 1
	local runButton = Object.Create("Button"):SetProperties({
		LayoutOrder = serial,
		Size = UDim2.new(0, BannerSize, 0, BannerSize),
		BackgroundColor = Color.Blank,
		Parent = Banner,
	})

	local buttonBackdrop = Object.Create("Frame"):SetProperties({
		Size = UDim2.new(1, -4, 1, -4),
		AnchorPoint = Vector.one / 2,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor = Color.new(0, 0, 0, .25),
		Parent = runButton,
	})

	local runIcon = Object.Create("ImageLabel"):SetProperties({
		Image = image,
		BackgroundColor = Color.Blank,
		Size = UDim2.fromScale(1, 1),
		Parent = buttonBackdrop,
	})
	Object.Create("UIAspectRatioConstraint"):SetProperty("Parent", runIcon)

	runButton.Icon = runIcon

	if text then
		local label = Object.Create("TextLabel"):SetProperties({
			Text = text,
			AnchorPoint = Vector.new(0, 0.5),
			Size = UDim2.new(1, -BannerSize, 1, 4),
			Position = UDim2.new(0, BannerSize - 2, .5, 0),
			BackgroundColor = Color.Blank,
			TextColor = Color.White,
			Parent = buttonBackdrop,
		})

		runButton:SetProperty("Size", runButton:GetProperty("Size") + UDim2.new(0, BannerSize * (text:len() * .5), 0, 0))
	end

	return runButton
end

do
	EditorFrame.BannerButtons.ToggleFullscreen = NewTopButton("Editor/Assets/Maximize.png", "Fullscreen")
	EditorFrame.BannerButtons.Pause = NewTopButton("Editor/Assets/Pause.png", "Pause")
	EditorFrame.BannerButtons.Unpause = NewTopButton("Editor/Assets/Unpause.png", "Unpause")
	EditorFrame.BannerButtons.Unpause:SetProperty("Visible", false)
end

local Area = Object.Create("Frame"):SetProperties({
	Position = UDim2.new(0, 0, 1, 0),
	AnchorPoint = Vector.new(0, 1),
	Size = UDim2.new(1, 0, 1, -BannerSize),
	BackgroundColor = Color.Blank,
	Parent = EditorFrame,
})
local ViewportWidget = Object.Create("Widget"):SetProperties({
	Position = UDim2.new(.5, 0, .5, 0),
	AnchorPoint = Vector.new(.5, .5),
	Size = UDim2.new(.5, 0, 1, 0),
	Parent = Area,
})
ViewportWidget:SetTitle("Editor")

local ViewportHolder = Object.Create("Frame"):SetProperties({
	Size = UDim2.fromScale(1, 1),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundColor = Color.new(0, 0, 0, 1),
	AnchorPoint = Vector.one / 2,
	Name = "ViewportHolder",
})
ViewportWidget:AttachGui(ViewportHolder)

-- local Viewport = Object.Create("Scene"):SetProperties({
-- 	-- Size = UDim2.fromScale(1, 1),
-- 	-- Position = UDim2.fromScale(0.5, 0.5),
-- 	-- BackgroundColor = Color.new(0,0,0, 1),
-- 	-- AnchorPoint = Vector.one/2,
-- 	Name = "Viewport",
-- 	Parent = ViewportHolder,
-- })

-- EditorFrame.Viewport = Viewport

local Explorer = Object.Create("Explorer"):SetProperties({
	Position = UDim2.new(1, 0, 0, 0),
	AnchorPoint = Vector.new(1,0),
	Size = UDim2.new(.25, 0, 1, 0),
	Parent = Area,
	RootObject = Game,
})

local Properties = Object.Create("Properties"):SetProperties({
	Position = UDim2.new(0, 0, 0, 0),
	AnchorPoint = Vector.new(0, 0),
	Size = UDim2.new(.25, 0, 1, 0),
	Parent = Area,
})

EditorFrame.BannerButtons.ToggleFullscreen.LeftClicked:Connect(function()
	local fullscreen = Explorer:GetProperty("Visible")

	Explorer:SetProperty("Visible", not fullscreen)
	Properties:SetProperty("Visible", not fullscreen)
	EditorFrame.BannerButtons.ToggleFullscreen.Icon:SetProperty("Image", fullscreen and "Editor/Assets/Minimize.png" or "Editor/Assets/Maximize.png")
	if fullscreen then
		ViewportWidget:SetProperty("Size", UDim2.new(1, 0, 1, 0))
	else
		ViewportWidget:SetProperty("Size", UDim2.new(.5, 0, 1, 0))
	end
end)


local function setPaused(paused)
	EditorFrame.BannerButtons.Pause:SetProperty("Visible", not paused)
	EditorFrame.BannerButtons.Unpause:SetProperty("Visible", not not paused)

	ViewportHolder:SetProperty("Simulated", not paused)
end

setPaused(false)

EditorFrame.BannerButtons.Pause.LeftClicked:Connect(function()
	setPaused(true)
end)

EditorFrame.BannerButtons.Unpause.LeftClicked:Connect(function()
	setPaused(false)
end)

-- scene.Parent = newEditor.Viewport

local existingDropdown
local function CreateDropdown(options, selected)
	if existingDropdown then
		existingDropdown:Destroy()
		existingDropdown = nil
	end

	local mousePos = Game:GetService("InputService"):GetMouseLocation()
	local dropdown = Object.Create("Dropdown", nil, options):SetProperties({
		Position = UDim2.fromOffset(mousePos.X, mousePos.Y),
		AnchorPoint = Vector.zero,
		Parent = EditorScreen,
	})
	existingDropdown = dropdown

	dropdown.ValueSelected:Connect(function(...)
		if selected(...) then
			dropdown:Destroy()
		end
	end)

	return dropdown
end

function EditorScreen:CreateContextMenu(object)
	local dropdown = CreateDropdown({ "Insert", "Export", "Duplicate", "Delete" }, function(value)
		if value == "Insert" then
			local classList = {}
			for className in next, Object.GetAllClasses() do
				table.insert(classList, className)
			end

			CreateDropdown(classList, function(className)
				Object.Create(className):SetProperty("Parent", object)
				return true
			end)
			return true
		elseif value == "Export" then
			-- 	local pathName = object:GetFullName():gsub("%.", "_")
			-- 	Instance.CreatePrefab(object, "ExportedInstances/"..pathName..".lua")
			return true
		elseif value == "Duplicate" then
			local new = object:Clone()
			new:SetProperties({
				-- Name = new:GetProperty("Name"),
				Parent = object:GetProperty("Parent"),
			})
			return true
		elseif value == "Delete" then
			object:Destroy()
			return true
		end
	end)
end

Game:SetProperty("Parent", ViewportHolder)

return EditorScreen
