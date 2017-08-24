local Sharpenable = Class(function(self, inst)
    self.inst = inst
    self.product = nil
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

function Sharpenable:Sharpen(item_sharpener, doer)
    if self.onsharpened ~= nil then
        self.onsharpened(self.inst, item_sharpener, doer)
    end
    if self.product ~= nil then
        local prod = SpawnPrefab(
            type(self.product) ~= "function" and
            self.product or
            self.product(self.inst, item_sharpener, doer)
        )
        if prod ~= nil then
            return prod
        end
    end
end

return Sharpenable
