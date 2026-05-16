local module = {}

module.Items = {}

module.RegisterItem = function(itemName, defaultComponents)
    local cleaned = {}
    for _, comp in next, defaultComponents do
        cleaned[comp.ComponentID] = comp
    end
    module.Items[itemName] = cleaned
end

return module