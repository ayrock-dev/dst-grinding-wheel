local Sharpener = Class(function(self, inst)
    self.inst = inst
    self.repair_value = 0.25 -- repairs 25%
end)

function Sharpener:Sharpen(target, doer)
    if target:HasTag("sharpenable") then

        local sharpened = false

        if target.components.finiteuses then
            local value = target.components.finiteuses:GetPercent() + self.repair_value
            target.components.finiteuses:SetPercent( math.min(1, value) )

            sharpened = true
        end

        if sharpened and self.inst.components.finiteuses then
            self.inst.components.finiteuses:Use(1)

            if self.onsharpen then
                self.onsharpen(self.inst, target, doer)
            end
        end

        return sharpened
    end

    return false
end

return Sharpener