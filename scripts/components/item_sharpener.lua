local sharpening = require("sharpening")

local function ondone(self, done)
    if done then
        self.inst:AddTag("donesharpening")
    else
        self.inst:RemoveTag("donesharpening")
    end
end

local function oncheckready(inst)
    if inst.components.container ~= nil and
        not inst.components.container:IsOpen() and
        inst.components.container:IsFull() then
        inst:AddTag("readytosharpen")
    end
end

local function onnotready(inst)
    inst:RemoveTag("readytosharpen")
end

local ItemSharpener = Class(function(self, inst)
    self.inst = inst

    self.done = nil
    self.targettime = nil
    self.task = nil
    self.product = nil

    --"readytosharpen" means it's CLOSED and FULL
    --This tag is used for gathering scene actions only
    --The widget cook button doesn't check this tag,
    --and obviously has to work when the pot is open

    inst:ListenForEvent("itemget", oncheckready)
    inst:ListenForEvent("onclose", oncheckready)

    inst:ListenForEvent("itemlose", onnotready)
    inst:ListenForEvent("onopen", onnotready)

    self.inst:AddTag("item_sharpener")
end,
nil,
{
    done = ondone,
})

function ItemSharpener:OnRemoveFromEntity()
    self.inst:RemoveTag("donesharpening")
    self.inst:RemoveTag("readytosharpen")
end

local function dosharpen(inst, self)
    self.task = nil
    self.targettime = nil
    
    if self.ondonesharpening ~= nil then
        self.ondonesharpening(inst)
    end

    self.done = true
end

function ItemSharpener:IsDone()
    return self.done
end

function ItemSharpener:IsSharpening()
    return not self.done and self.targettime ~= nil
end

function ItemSharpener:GetTimeToSharpen()
    return not self.done and self.targettime ~= nil and self.targettime - GetTime() or 0
end

function ItemSharpener:CanSharpen()
    return self.inst.components.container ~= nil and self.inst.components.container:IsFull()
end

function ItemSharpener:StartSharpening()
    if self.targettime == nil and self.inst.components.container ~= nil then
        self.done = nil

        if self.onstartsharpening ~= nil then
            self.onstartsharpening(self.inst)
        end

		local raw_materials = {}
		for k, v in pairs(self.inst.components.container.slots) do
			table.insert(raw_materials, v.prefab)
		end

        self.product = table.remove(raw_materials,1)

        local total_repair = sharpening.CalculateRepair(self.inst.prefab, raw_materials)

        sharpentime = TUNING.BASE_COOK_TIME -- possibly move to TUNING.BASE_SHARPEN_TIME
        self.targettime = GetTime() + sharpentime

        if self.task ~= nil then
            self.task:Cancel()
        end
        self.task = self.inst:DoTaskInTime(sharpentime, dosharpen, self)

        self.inst.components.container:Close()
        self.inst.components.container:DestroyContents()
        self.inst.components.container.canbeopened = false
    end
end

local function StopProductPhysics(prod)
    prod.Physics:Stop()
end

function ItemSharpener:StopSharpening(reason)
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    if self.product ~= nil and reason == "fire" then
        local prod = SpawnPrefab(self.product)
        if prod ~= nil then
            prod.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
            prod:DoTaskInTime(0, StopProductPhysics)
        end
    end
    self.product = nil
    self.targettime = nil
    self.done = nil
end

function ItemSharpener:OnSave()
    local remainingtime = self.targettime ~= nil and self.targettime - GetTime() or 0
    return
    {
        done = self.done,
        product = self.product,
        remainingtime = remainingtime > 0 and remainingtime or nil,
    }
end

function ItemSharpener:OnLoad(data)
    if data.product ~= nil then
        self.done = data.done or nil
        self.product = data.product

        if self.task ~= nil then
            self.task:Cancel()
            self.task = nil
        end
        self.targettime = nil

        if data.remainingtime ~= nil then
            self.targettime = GetTime() + math.max(0, data.remainingtime)
            if self.done then
                if self.oncontinuedone ~= nil then
                    self.oncontinuedone(self.inst)
                end
            else
                self.task = self.inst:DoTaskInTime(data.remainingtime, dosharpen, self)
                if self.oncontinuesharpening ~= nil then
                    self.oncontinuesharpening(self.inst)
                end
            end
        elseif self.oncontinuedone ~= nil then
            self.oncontinuedone(self.inst)
        end

        if self.inst.components.container ~= nil then
            self.inst.components.container.canbeopened = false
        end
    end
end

return ItemSharpener