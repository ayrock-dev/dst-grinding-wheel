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