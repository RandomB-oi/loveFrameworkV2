_type = type

type = function(value)
    local t = _type(value)
    if t == "table" and value.CreateProperty then
        return "Object"
    end
    return t
end

typeof = function(value)
	local t = _type(value)
	if t == "table" then
		return value.__type or t
	end
	return t
end

Enum = require("Engine.DataTypes.Enum")
math = require("Engine.Utilities.Math")
table = require("Engine.Utilities.Table")
string = require("Engine.Utilities.String")
task = require("Engine.Utilities.Task")
json = require("Engine.Utilities.json")
-- if not _G.LaunchParameters.noGraphics then
	require("Engine.Utilities.Graphics")
-- end

do -- DataTypes
	Binary = require("Engine.DataTypes.Binary")
	Vector = require("Engine.DataTypes.Vector")

	Color = require("Engine.DataTypes.Color")
	ColorSequence = require("Engine.DataTypes.ColorSequence")

	NumberRange = require("Engine.DataTypes.NumberRange")
	NumberSequence = require("Engine.DataTypes.NumberSequence")

	UDim = require("Engine.DataTypes.UDim")
	UDim2 = require("Engine.DataTypes.UDim2")

	Maid = require("Engine.DataTypes.Maid")
	Signal = require("Engine.DataTypes.Signal")
	GCSignal = require("Engine.DataTypes.GCSignal")

	TweenInfo = require("Engine.DataTypes.TweenInfo")
end

do -- load all instances
	function loadPath(path, list)
		for index, value in pairs(list) do
			if type(index) == "string" then
				loadPath(path.."."..index, value)
			else
				require(path.."."..value)
			end
		end
	end

	local function fixPath(path)
		return select(1, string.gsub(path, "/", "."))
	end

	-- fixes a yellow warn line
	love.filesystem.isDirectory = love.filesystem.isDirectory
	
	function autoLoad(path, ignoreList)
		local tbl = {}

		local directories = {}
		
		for i, fileName in pairs(love.filesystem.getDirectoryItems(path)) do
			local isDirectory do
				if love.filesystem.getInfo then
					isDirectory = love.filesystem.getInfo(path.."/"..fileName).type == "directory"
				else
					isDirectory = love.filesystem.isDirectory(path.."/"..fileName)
				end
			end

			if isDirectory then
				table.insert(directories, {name = fileName, path = path.."/"..fileName})
			elseif fileName:find(".lua") then
				local objectName = string.split(fileName, ".")[1]
				local fileDir = fixPath(path.."."..objectName)
				if ignoreList and not table.find(ignoreList, fileDir) or not ignoreList then
					local s, value = xpcall(require, print, fileDir)
					if s then
						tbl[objectName] = value
					end
				end
			end
		end

		for _ , info in ipairs(directories) do
			tbl[info.name] = autoLoad(info.path)
		end
		
		return tbl
	end
end


Object = require("Engine.Objects.Object")
autoLoad("Engine/Objects")
Game = Object.Create("DataModel","DataModel")