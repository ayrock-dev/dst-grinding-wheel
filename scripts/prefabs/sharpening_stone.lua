local assets =
{
    Asset("ANIM", "anim/sharpening_stone.zip"),
    Asset("ATLAS", "images/inventoryimages/sharpening_stone.xml"),
    Asset("IMAGE", "images/inventoryimages/sharpening_stone.tex"),
}

local function onsharpen(inst, target, doer) 
<<<<<<< HEAD
    doer:PushEvent("repair")
=======
    --doer:PushEvent("repair")
>>>>>>> 364de3f92e52fe70d56e25a51fbbbfe3c89ff9e0
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sharpening_stone")
    inst.AnimState:SetBuild("sharpening_stone")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("sharpener")
    inst.components.sharpener.onsharpen = onsharpen;

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(5)
    inst.components.finiteuses:SetUses(5)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sharpening_stone.xml"
    inst.components.inventoryitem:SetSinks(true)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("sharpening_stone", fn, assets)