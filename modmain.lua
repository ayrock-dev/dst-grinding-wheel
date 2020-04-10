PrefabFiles = 
{
    "sharpening_stone"
}

Assets =
{
    Asset("ATLAS", "images/inventoryimages/sharpening_stone.xml"),
    Asset("IMAGE", "images/inventoryimages/sharpening_stone.tex"),
}

ACTIONS     = GLOBAL.ACTIONS
STRINGS 	= GLOBAL.STRINGS
RECIPETABS 	= GLOBAL.RECIPETABS
Recipe 		= GLOBAL.Recipe
TECH		= GLOBAL.TECH
Ingredient 	= GLOBAL.Ingredient
CHARACTERS  = GLOBAL.STRINGS.CHARACTERS

AddRecipe(
    "sharpening_stone",
    {
        Ingredient("flint", 2),
    },
    RECIPETABS.SURVIVAL,
    TECH.SCIENCE_ONE,
    nil, nil, nil, nil, nil, "images/inventoryimages/sharpening_stone.xml", "sharpening_stone.tex"
)

STRINGS.NAMES.SHARPENING_STONE = "Sharpening Stone"
STRINGS.RECIPE_DESC.SHARPENING_STONE = "Makes like new again!"
CHARACTERS.GENERIC.DESCRIBE.SHARPENING_STONE = "Makes like new again!"
STRINGS.ACTIONS.SHARPEN = "Sharpen"

local SHARPEN = AddAction(
    "SHARPEN", -- id
    "Sharpen", -- str
    function(act)
        if act.target and 
            act.target:HasTag("sharpenable") and
            act.invobject and
            act.invobject.components.sharpener then
            return act.invobject.components.sharpener:Sharpen(act.target, act.doer)
        end

<<<<<<< HEAD
        return false
    end
)
SHARPEN.rmb = true
SHARPEN.mount_valid = true
=======
-- ADD SHARPENABLE COMPONENT TO THOSE WHICH WE WANT TO BE SHARPENABLE
>>>>>>> 45a59e1e54aed07498654b48fd9b30e4f394e757

AddComponentAction(
    "USEITEM",   -- actiontype
    "sharpener", -- component
    function(inst, doer, target, actions)
        if target:HasTag("sharpenable") then
            table.insert(actions, GLOBAL.ACTIONS.SHARPEN)
        end
    end
)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SHARPEN, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.SHARPEN, "dolongaction"))

-- ADD ITEMS WHICH WE WANT TO BE SHARPENABLE
local function AddSharpenable(inst)
    inst:AddTag("sharpenable")
end

local sharpenables = {
    "axe",
    "goldenaxe",
    "pickaxe",
    "goldenpickaxe",
    "shovel",
    "goldenshovel",
    "pitchfork",
    "hammer",
    "spear",
    "tentaclespike",
    "ruins_bat",
    "spear_wathgrithr",
    "multitool_axe_pickaxe",
}

<<<<<<< HEAD
for _,prefab in ipairs(sharpenables) do
    AddPrefabPostInit(prefab, AddSharpenable);
end
=======
for _,item in sharpenable_items do
    AddPrefabPostInit(item, AddSharpenableComponent);
end

-- 
>>>>>>> 45a59e1e54aed07498654b48fd9b30e4f394e757
