local function onbullettype(self, bullettype, old_bullettype)
    if old_bullettype ~= nil then
        self.inst:RemoveTag(old_bullettype.."_bullets")
    end
    if bullettype ~= nil then
        self.inst:AddTag(bullettype.."_bullets")
    end
end

local GunBullets = Class(function(self, inst)
    self.inst = inst
    self.bullet = nil
    self.bullettype = nil
    self.damage = 0
    self.onloaded = nil
	self.interval = 0.5
end,
nil,
{
    bullettype = onbullettype,
})

function GunBullets:OnRemoveFromEntity()
    if self.ammotype ~= nil then
        self.inst:RemoveTag(self.ammotype.."_ammo")
    end
end

function GunBullets:SetInterval(val)
    self.interval = val
end

function GunBullets:GetBullet()
    return self.bullet
end

function GunBullets:SetBullet(val)
    self.bullet = val
end

function GunBullets:GetBulletType()
    return self.bullettype
end

function GunBullets:SetBulletType(val)
    self.bullettype = val
end

function GunBullets:GetDamage()
    return self.damage
end

function GunBullets:SetDamage(val)
    self.damage = val
end

function GunBullets:SetOnLoadedFn(fn)
    self.onloaded = fn
end

function GunBullets:Loaded(tgt)
    self.inst:PushEvent("loaded", {tgt = tgt})
    if self.onloaded then
        self.onloaded(self.inst, tgt)
    end
end

return GunBullets