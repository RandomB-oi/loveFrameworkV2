ItemRegistry = require(GamePath.."Shared.Classes.ItemRegistry")
ItemStack = require(GamePath.."Shared.Classes.ItemStack")
StackComponents = require(GamePath.."Shared.Classes.StackComponents.StackComponent").Components

ContainerGroupClass = require(GamePath.."Shared.Classes.ContainerGroup")
ContainerClass = require(GamePath.."Shared.Classes.Container")

autoLoad(GameDirectory.."Shared/Objects")
autoLoad(GameDirectory.."Shared/Classes/StackComponents")
autoLoad(GameDirectory.."Shared/Classes")

Game:GetService("Players")
local module = {}



-- local ContainerGroup = ContainerGroupClass.new()
-- ContainerGroup:AddContainer(ContainerClass.new("Inventory", 9))

-- local uniqueTag = StackComponents.Unique()

-- local stack = ItemStack.new("Wood", 1)
-- stack:AddComponent(uniqueTag)

-- local stack2 = ItemStack.new("Wood", 1)
-- stack2:AddComponent(uniqueTag)

-- print("destroy stack 1")
-- stack:Destroy()
-- print("destroy stack 2")
-- stack2:Destroy()

-- ContainerGroup:AddItem(stack)

-- ContainerGroup:BindItems(function(containerName, index, item)
--     -- print("new item in", containerName,"index:", index, "item:", getStr(item))
--     local con = item:BindAmount(function(newAmount)

--     end)

--     return function()
--         con:Destroy()
--     end
-- end)


-- local total = 0
-- for i = 1, 6 do
--     local a = 4
--     total = total + a
--     ContainerGroup:AddItem(ItemStack.new("Wood", a))
-- end


-- print(getStr(ContainerGroup:Serialize()))

-- print(total, total/5)
-- print(getStr(ContainerGroup))

-- print(stack1:CanCombine(stack2))
-- ItemStack.new("Wood"):BindComponent("ItemIcon", function(value)
--     print(getStr(value))
-- end)

return module