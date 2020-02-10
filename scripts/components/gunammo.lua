local function onammotype(self, ammotype, old_ammotype)
    if old_ammotype ~= nil then
        self.inst:RemoveTag(old_ammotype.."_ammo")
    end
    if ammotype ~= nil then
        self.inst:AddTag(ammotype.."_ammo")
    end
end

local function ongunbullets(self, gunbullets)
    self.inst.replica.gunammo._gunbullets:set(gunbullets)
end

local function onvalue(self, value)
    self.inst.replica.gunammo._value:set(value)
end

local function onmaxvalue(self, maxvalue)
    self.inst.replica.gunammo._maxvalue:set(maxvalue)
end

local function ondecomposable(self, decomposable)
    self.inst.replica.gunammo._decomposable:set(decomposable)
end

local GunAmmo = Class(function(self, inst)
    self.inst = inst
    self.value = 0
	self.maxvalue = 0
    self.ammotype = nil
    self.bullet = nil
	self.recyclable = false
	self.decomposable = false
	self.gunbullets = ""
    self.damage = 0
    self.onloaded = nil
	self.onrefilled = nil
	self.interval = 2
end,
nil,
{
    ammotype = onammotype,
	gunbullets = ongunbullets,
	value = onvalue,
	maxvalue = onmaxvalue,
	decomposable = ondecomposable,
})

function GunAmmo:OnRemoveFromEntity()
    if self.ammotype ~= nil then
        self.inst:RemoveTag(self.ammotype.."_ammo")
    end
end

function GunAmmo:OnSave()
	return
	{
		value = self.value,
	}
end

function GunAmmo:OnLoad(data)
	if data.value ~= nil then 
		self.value = data.value
	end
end

function GunAmmo:GetValue()
    return self.value
end

function GunAmmo:GetMaxValue()
    return self.maxvalue
end

function GunAmmo:SetValue(val)
    self.value = math.min(val, self.maxvalue)
end

function GunAmmo:SetMaxValue(val)
    self.maxvalue = math.max(val, self.value)
end

function GunAmmo:SetInterval(val)
    self.interval = val
end

function GunAmmo:GetType()
    return self.ammotype
end

function GunAmmo:SetType(ammotype)
    self.ammotype = ammotype
end

function GunAmmo:GetBullet()
    return self.bullet
end

function GunAmmo:SetBullet(val)
    self.bullet = val
end

function GunAmmo:SetRecyclable(val)
    self.recyclable = val
end

function GunAmmo:SetDecomposable(val)
    self.decomposable = val
end

function GunAmmo:GetGunBullets()
    return self.gunbullets
end

function GunAmmo:SetGunBullets(val)
    self.gunbullets = val
end

function GunAmmo:GetDamage()
    return self.damage
end

function GunAmmo:SetDamage(val)
    self.damage = val
end

function GunAmmo:SetOnLoadedFn(fn)
    self.onloaded = fn
end

function GunAmmo:Loaded(tgt)
    self.inst:PushEvent("loaded", {tgt = tgt})
    if self.onloaded then
        self.onloaded(self.inst, tgt)
    end
end

function GunAmmo:SetOnRefilledFn(fn)
    self.onrefilleded = fn
end

function GunAmmo:Refill(bullet)
	if self.value < self.maxvalue then
		self.value = self.value + 1
		bullet.components.gunbullets:Loaded(self.inst)
		self.inst:PushEvent("refilled", {bullet = bullet})
		if self.onrefilled then
			self.onrefilled(self.inst, bullet)
		end
		return true
	end
end
function GunAmmo:Decompose()
	local owner = self.inst and self.inst.components.inventoryitem and self.inst.components.inventoryitem:GetGrandOwner()
	if owner and owner.components.inventory and self.value > 0 then
		repeat
			owner.components.inventory:GiveItem(SpawnPrefab(self.gunbullets))
			self.value = self.value - 1
		until(self.value <= 0)
	end
end

return GunAmmo