local module = {}

local typeLookup = {
	Enum = function(category, name)
		return Enum[category][name]
	end,
	Instance = function(id)
		return id
	end,

	Binary = Binary.new,
	Vector = Vector.new,
	Color = Color.from255,
	ColorSequence = ColorSequence.new,
	NumberRange = NumberRange.new,
	NumberSequence = NumberSequence.new,
	UDim = UDim.new,
	UDim2 = UDim2.new,
	Maid = Maid.new,
	Signal = Signal.new,
	GCSignal = GCSignal.new,
	TweenInfo = TweenInfo.new,
}

function module.Encode(value, cyclicValues)
	cyclicValues = cyclicValues or {}
	if type(value) == "table" then
		if cyclicValues[value] then return "Cyclic Value" end
		cyclicValues[value] = true
		if value.Serialize then
			local t = typeof(value)
			return {_T = t, _V = {value:Serialize()}}
		end

		local encoded = {}
		for i,v in pairs(value) do
			encoded[module.Encode(i)] = module.Encode(v)
		end
		return encoded
	end

	return value
end

function module.Decode(value)
	if type(value) == "table" then
		if value._T then
			return typeLookup[value._T](unpack(value._V or {}))
		end

		local decoded = {}
		for i, v in pairs(value) do
			decoded[module.Decode(i)] = module.Decode(v)
		end
		return decoded
	end

	return value
end

return module