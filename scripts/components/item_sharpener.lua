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
    --and obviously has to work when the sharpener is open

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

-- used to enable/disable widget button
function ItemSharpener:CanStartSharpening()
    return self.inst.components.container ~= nil and self.inst.components.container:IsFull()
end

function ItemSharpener:StartSharpening()
    if self.targettime == nil and self.inst.components.container ~= nil then
        self.done = nil

        if self.onstartsharpening ~= nil then
            self.onstartsharpening(self.inst)
        end

        self.product = self.inst.components.container:RemoveItemBySlot(1)
        self.product.prevcontainer = nil
        self.product.prevslot = nil

        local raw_materials = {}
		for _,item in pairs(self.inst.components.container.slots) do
			table.insert(raw_materials, item.prefab)
		end
        local total_repair = sharpening.CalculateRepair(self.inst.prefab, raw_materials)

        -- possibly move to TUNING.BASE_SHARPEN_TIME
        -- for now using BASE_COOK_TIME is good enough for sharpen time
        sharpentime = TUNING.BASE_COOK_TIME 

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

    -- if we are done sharpening due to burning up, drop the item
    if self.product ~= nil and reason == "fire" then
        self.product.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
        self.product:DoTaskInTime(0, StopProductPhysics)
        if self.product.components.inventoryitem ~= nil then
            self.product.components.inventoryitem:OnDropped(true)
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

function ItemSharpener:GetDebugString()
    local status = (self:IsCooking() and "SHARPENING")
                or (self:IsDone() and "FULL")
                or "EMPTY"

    local prefab_name = (self.product and self.product.prefab) or "<none>"

    return string.format("%s %s timetosharpen: %.2f",
            prefab_name,
            status,
            self:GetTimeToSharpen())
end

function ItemSharpener:Harvest(harvester)
    if self.done then
        if self.onharvest ~= nil then
            self.onharvest(self.inst)
        end

        if self.product ~= nil then
            local loot = self.product
            if loot ~= nil then
                if harvester ~= nil and harvester.components.inventory ~= nil then
                    harvester.components.inventory:GiveItem(loot, nil, self.inst:GetPosition())
                else
                    LaunchAt(loot, self.inst, nil, 1, 1)
                end
            end
            self.product = nil
        end

        if self.task ~= nil then
            self.task:Cancel()
            self.task = nil
        end
        self.targettime = nil
        self.done = nil

        if self.inst.components.container ~= nil then      
            self.inst.components.container.canbeopened = true
        end

        return true
    end
end

function ItemSharpener:LongUpdate(dt)
    if self:IsSharpening() then
        if self.task ~= nil then
            self.task:Cancel()
        end
        if self.targettime - dt > GetTime() then
            self.targettime = self.targettime - dt
            self.task = self.inst:DoTaskInTime(self.targettime - GetTime(), dosharpen, self)
            dt = 0            
        else
            dt = dt - self.targettime + GetTime()
            dosharpen(self.inst, self)
        end
    end
end

return ItemSharpener