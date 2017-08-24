local Sharpenable = Class(function(self, inst)
    self.inst = inst
    self.onsharpened = nil

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("sharpenable")
end)

function Sharpenable:OnRemoveFromEntity()
    self.inst:RemoveTag("sharpenable")
end

function Sharpenable:SetOnSharpenedFn(fn)
    self.onsharpened = fn
end

function Sharpenable:Sharpen(item_sharpener, repair)
    if self.onsharpened ~= nil then
        self.onsharpened(self.inst, item_sharpener, repair)
    end
    if self.inst.components.finiteuses ~= nil then
        -- current is the current number of uses
        local current = self.inst.components.finiteuses:GetUses()
        local percent = self.inst.components.finiteuses:GetPercent()
        -- total is the maximum number of uses
        local total = (1 / percent) * current
        local new = current + repair
        self.inst.components.finiteuses:SetUses(math.max(total, new))
    end
end

return Sharpenable