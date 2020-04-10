local sharpening_materials = {}

function AddSharpeningMaterial(names, repair_value)
	for _,name in pairs(names) do
		sharpening_materials[name] = repair_value
	end
end

--------------------------------
-- SHARPENING MATERIALS TABLE --
--------------------------------

<<<<<<< HEAD
AddSharpeningMaterial({"rocks"}, 15)
AddSharpeningMaterial({"flint"}, 25)
AddSharpeningMaterial({"cutstone"}, 75)

-- end SHARPENING MATERIALS TABLE
=======
AddMaterialValues({"rocks"}, 15)
AddMaterialValues({"nitre"}, 25)
AddMaterialValues({"goldnugget"}, 25)
AddMaterialValues({"cutstone"}, 75)
AddMaterialValues({"flint"}, 75)
AddMaterialValues({"redgem"}, 100)
AddMaterialValues({"bluegem"}, 100)
AddMaterialValues({"marble"}, 100)

--------------------------------- --
-- end SHARPENING MATERIALS TABLE --
------------------------------------
>>>>>>> 45a59e1e54aed07498654b48fd9b30e4f394e757

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
    return total
end

return 
{ 
    sharpening_materials = sharpening_materials,
    IsSharpeningMaterial = IsSharpeningMaterial,
    GetRepairValueByPrefab = GetRepairValueByPrefab, 
    CalculateRepair = CalculateRepair,
}
