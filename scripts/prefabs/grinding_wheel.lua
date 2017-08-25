require "prefabutil"

local assets = 
{
    Asset("ANIM", "anim/grinding_wheel.zip"),
    --Asset("ANIM", "anim/ui_grinding_wheel_1x2.zip"),	
}

local prefabs = 
{
    "collapse_small"
}

local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	if inst.components.container then 
        inst.components.container:DropEverything() 
    end
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	if inst.flies then 
		inst.flies:Remove() inst.flies = nil 
	end	
	inst:Remove()
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
        if inst.components.item_sharpener:IsSharpening() then
            inst.AnimState:PlayAnimation("hit_sharpeninging")
            inst.AnimState:PushAnimation("sharpening_loop", true)
        elseif inst.components.item_sharpener:IsDone() then
            inst.AnimState:PlayAnimation("hit_full")
            inst.AnimState:PushAnimation("idle_full", false)
        else
            inst.AnimState:PlayAnimation("hit_empty")
            inst.AnimState:PushAnimation("idle_empty", false)
        end
	end
end

local function startsharpenfn(inst)
	if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("sharpening_loop", true)
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
    end
end

local function onopen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("sharpening_pre_loop", true)
		inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
		inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot", "snd")
    end
end

local function onclose(inst) 
	if not inst:HasTag("burnt") then 
        if not inst.components.item_sharpener:IsSharpening() then
            inst.AnimState:PlayAnimation("idle_empty")
            inst.SoundEmitter:KillSound("snd")
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/chest_close")
    end
end

local function ShowProduct(inst)
    if not inst:HasTag("burnt") then
        local prod = inst.components.item_sharpener.product.prefab.name
		inst.AnimState:OverrideSymbol("swap_sharpened", prod, prod)
    end
end

local function donesharpenfn(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("sharpening_pst")
        inst.AnimState:PushAnimation("idle_full", false)
        ShowProduct(inst)
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
    end
end

local function continuedonefn(inst)
    if not inst:HasTag("burnt") then 
        inst.AnimState:PlayAnimation("idle_full")
        ShowProduct(inst)
    end
end

local function continuesharpenfn(inst)
    if not inst:HasTag("burnt") then 
        inst.AnimState:PlayAnimation("sharpening_loop", true)
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
    end
end

local function harvestfn(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("idle_empty")
    end
end

local function getstatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst.components.item_sharpener:IsDone() and "DONE")
        or (not inst.components.item_sharpener:IsSharpening() and "EMPTY")
        or (inst.components.item_sharpener:GetTimeToSharpen() > 15 and "SHARPENING_LONG")
        or "SHARPENING_SHORT"
end

local function onfar(inst)
    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle_empty", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/cook_pot_craft")
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
	if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function fn()
	local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
	
	MakeObstaclePhysics(inst, .5)
		
	inst.MiniMapEntity:SetIcon("grinding_wheel.tex")
	
	inst:AddTag("structure")

	inst.AnimState:SetBank("grinding_wheel")
    inst.AnimState:SetBuild("grinding_wheel")
    inst.AnimState:PlayAnimation("idle_empty")

	MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

    -- END CLIENT, HOST ONLY CODE NOW
	
	inst:AddComponent("item_sharpener")
    inst.components.item_sharpener.onstartsharpening = startsharpenfn
    inst.components.item_sharpener.oncontinuesharpening = continuesharpenfn
    inst.components.item_sharpener.oncontinuedone = continuedonefn
    inst.components.item_sharpener.ondonesharpening = donesharpenfn
    inst.components.item_sharpener.onharvest = harvestfn

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("grinding_wheel")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

	inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

	inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,5)
    inst.components.playerprox:SetOnPlayerFar(onfar)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit) 

	inst:ListenForEvent("onbuilt", onbuilt)

	MakeSnowCovered(inst, .01)	
	
	MakeMediumBurnable(inst, 6+ math.random()*6)
	MakeSmallPropagator(inst)

	inst.OnSave = onsave 
    inst.OnLoad = onload
	
    return inst
end

STRINGS.NAMES.GRINDING_WHEEL 								= "Grinding Wheel"
STRINGS.RECIPE_DESC.GRINDING_WHEEL 						    = "Makes tools like new again!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GRINDING_WHEEL 		    = "It's basic tool carpentry, really."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.GRINDING_WHEEL 			= "Unfortunately, that wouldn't burn."
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.GRINDING_WHEEL 		= "Reminds me of a stage bicylce!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.GRINDING_WHEEL 			= "All old things become new."
STRINGS.CHARACTERS.WX78.DESCRIBE.GRINDING_WHEEL 			= "TOOL REFINEMENT"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.GRINDING_WHEEL 	= "Uses an abrasive wheel to restore durability."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.GRINDING_WHEEL 			= "Talk about re-inventing the wheel!"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.GRINDING_WHEEL 		    = "Looks heavy."
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.GRINDING_WHEEL 	    = "Wheel öf war!"
STRINGS.CHARACTERS.WEBBER.DESCRIBE.GRINDING_WHEEL 		    = "It's a rock wheel?"

return	Prefab("grinding_wheel", fn, assets, prefabs),
		MakePlacer("grinding_wheel_placer", "grinding_wheel", "grinding_wheel", "idle_empty") 