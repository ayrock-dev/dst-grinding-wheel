local sharpening_materials = {}

function AddMaterialValues(names, repair_value)
	for _,name in pairs(names) do
		sharpening_materials[name] = repair_value
	end
end

--------------------------------
-- SHARPENING MATERIALS TABLE --
--------------------------------

AddMaterialValues({"rocks"}, 15)
AddMaterialValues({"flint"}, 25)
AddMaterialValues({"cutstone"}, 75)

-- end SHARPENING MATERIALS TABLE

local function IsSharpeningMaterial(prefabname)
    return sharpening_materials[prefabname] ~= nil
end

local function GetRepairValueByPrefab(prefabname)
    return sharpening_materials[prefabname]
end

local function CalculateRepair(item_sharpener, prefablist)
    local total = 0
    for _,name in pair(prefablist) do
        if IsSharpeningMaterial(name) then
            total = total + GetRepairValueByPrefab(name)
        end
    end
end

return 
{ 
    sharpening_materials = sharpening_materials,
    IsSharpeningMaterial = IsSharpeningMaterial,
    GetRepairValueByPrefab = GetRepairValueByPrefab, 
    CalculateRepair = CalculateRepair,
}
