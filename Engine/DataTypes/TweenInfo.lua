local module = {}
module.__index = module
module.__type = "TweenInfo"

local function flip(a)
	return 1 - a
end

local pi = math.pi
local sin, cos, pow = math.sin, math.cos, math.pow

local c1 = 1.70158;
local c2 = c1 * 1.525;
local c3 = c1 + 1;
local c4 = (2 * pi) / 3
local c5 = (2 * pi) / 4.5

local EasingStyles
local function CalcEasing(a, style, direction)
	local x = math.clamp(a, 0, 1)

	if not style then print("no style") return end
	if not direction then print("no dir") return end
	if not EasingStyles[style] then print("no list") return end
	
	return EasingStyles[style][direction](x)
end
EasingStyles = {
	[Enum.EasingStyle.Linear] = {
		[Enum.EasingDirection.Out] = function(x)
			return x
		end,
		In = function(x)
			return x
		end,
	},
	
	[Enum.EasingStyle.Quad] = {
		[Enum.EasingDirection.Out] = function(x)
			return x^2
		end,
		[Enum.EasingDirection.InOut] = function(x)
			return x < 0.5 and 2 * x * x or 1 - pow(-2 * x + 2, 2) / 2
		end,
	},

	[Enum.EasingStyle.Cubic] = {
		[Enum.EasingDirection.Out] = function(x)
			return x^3
		end,
		[Enum.EasingDirection.InOut] = function(x)
			return x < 0.5 and 4 * x * x * x or 1 - pow(-2 * x + 2, 3) / 2
		end,
	},

	[Enum.EasingStyle.Quart] = {
		[Enum.EasingDirection.Out] = function(x)
			return x^4
		end,
		[Enum.EasingDirection.InOut] = function(x)
			return x < 0.5 and 8 * x * x * x * x or 1 - pow(-2 * x + 2, 4) / 2
		end,
	},
	[Enum.EasingStyle.Quint] = {
		[Enum.EasingDirection.Out] = function(x)
			return x^5
		end,
		
		[Enum.EasingDirection.InOut] = function(x)
			return x < 0.5 and 16 * x * x * x * x * x or 1 - pow(-2 * x + 2, 5) / 2
		end,
	},

	[Enum.EasingStyle.Elastic] = {
		[Enum.EasingDirection.Out] = function(x)
			return pow(2, -10 * x) * sin((x * 10 - 0.75) * c4) + 1
		end,
		[Enum.EasingDirection.InOut] = function(x)
			return x == 0
			  and 0
			  or x == 1
			  and 1
			  or x < 0.5
			  and -(pow(2, 20 * x - 10) * sin((20 * x - 11.125) * c5)) / 2
			  or (pow(2, -20 * x + 10) * sin((20 * x - 11.125) * c5)) / 2 + 1
		end,
	},

	[Enum.EasingStyle.Sine] = {
		[Enum.EasingDirection.Out] = function(x)
			return sin((x * pi) / 2)
		end,
		[Enum.EasingDirection.InOut] = function(x)
			return -(cos(pi * x) - 1) / 2
		end,
	},

	[Enum.EasingStyle.Bounce] = {
		[Enum.EasingDirection.Out] = function(x)
 			if (x < (1/2.75)) then
		        return (7.5625*x*x);
		    elseif (x < (2/2.75)) then
		        x = x - 1.5/2.75
		        return (7.5625*(x)*x + 0.75);
		    elseif (x < (2.5/2.75)) then
		        x = x - 2.25/2.75
		        return (7.5625*(x)*x + 0.9375);
		    else 
		        x = x - 2.625/2.75
		        return (7.5625*(x)*x + 0.984375);
		    end
		end,
		
		[Enum.EasingDirection.InOut] = function(x)
			return x < 0.5
			  and (1 - CalcEasing(1 - 2 * x, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)) / 2
			  or (1 + CalcEasing(2 * x - 1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)) / 2
		end,
	},

	[Enum.EasingStyle.Back] = {
		[Enum.EasingDirection.Out] = function(x)
			return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2);
		end,
		[Enum.EasingDirection.InOut] = function(x)
			return x < 0.5 and (math.pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
  			or (math.pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2;
		end,
	},
}



for style in pairs(EasingStyles) do
	EasingStyles[style][Enum.EasingDirection.In] = function(x)
		return flip(CalcEasing(flip(x), style, Enum.EasingDirection.Out))
	end
end



--Style: Linear | Quad | Cubic | Quart | Quint | Elastic | Sine | Bounce | Back
--Direction: In | Out | InOut
module.new = function(length, style, direction)
	local self = setmetatable({}, module)

	self.Length = length or 1
	self.Style = style and EasingStyles[style] and style or Enum.EasingStyle.Linear
	self.Direction = direction and EasingStyles[self.Style][direction] and direction or Enum.EasingDirection.Out

	return self
end

module._calcEasing = CalcEasing
function module:Solve(alpha)
	return CalcEasing(alpha, self.Style, self.Direction)
end

function module:__tostring()
	return tostring(self.Length)..", "..tostring(self.Style)..", "..tostring(self.Direction)
end

return module