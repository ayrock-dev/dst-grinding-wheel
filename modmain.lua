PrefabFiles = 
{
    "grinding_wheel",
}

Assets =
{
    Asset("ATLAS", "images/inventoryimages/grinding_wheel.xml"),
    Asset("ATLAS", "minimap/grinding_wheel.xml" ),
}

STRINGS 	= GLOBAL.STRINGS
RECIPETABS 	= GLOBAL.RECIPETABS
Recipe 		= GLOBAL.Recipe
TECH		= GLOBAL.TECH
Ingredient 	= GLOBAL.Ingredient

-- SETUP OF THE GRINDING WHEEL

local grinding_wheel = Recipe(
        "grinding_wheel",
        {
            Ingredient("boards",    1),
            Ingredient("cutstone",  8),
        },
        RECIPETABS.TOWN,
        TECH.SCIENCE_ONE,
        "grinding_wheel_placer"
    )

grinding_wheel.atlas = "images/inventoryimages/grinding_wheel.xml"
AddMinimapAtlas("images/inventoryimages/grinding_wheel.xml")

-- ADD ITEMS WHICH WE WANT TO BE SHARPENABLE

local function AddSharpenableComponent(prefab)
    if not prefab.components.insulator then
        prefab:AddComponent("sharpenable");
    end
end

local sharpenable_items = {
    "axe",
    "goldenaxe",
    "pickaxe",
    "goldenpickaxe",
    "shovel",
    "goldenshovel",
    "pitchfork",
    "hammer",
    "razor",
    "spear",
    "tentaclespike",
    "ruins_bat",
    "spear_wathgrithr",
    "multitool_axe_pickaxe",
}

for _,item in sharpenable_items do
    AddPrefabPostInit(item, AddSharpenableComponent);
end