local function onselector(self, selector)
	self.inst.replica.gunutils._selector:set(selector)
	if self.inst.components.weapon then
		if selector == 0 then
			self:Emptied()
		elseif self.current > 0 then
			self:Reloaded()
		end
	end
end

local function onselectorlock(self, selectorlock)
	self.inst.replica.gunutils._selectorlock:set(selectorlock)
end

local function onhudimage(self, hudimage)
	if hudimage and hudimage.atlas then
		if hudimage.atlas.reload then
			self.inst.replica.gunutils._reloadingatlas:set(hudimage.atlas.reload)
			self.inst.replica.gunutils._reloadingimage:set(hudimage.image.reload)
		end
		if hudimage.atlas.selector0 then
			self.inst.replica.gunutils._selectoratlas0:set(hudimage.atlas.selector0)
			self.inst.replica.gunutils._selectorimage0:set(hudimage.image.selector0)
		end
		if hudimage.atlas.selector1 then
			self.inst.replica.gunutils._selectoratlas1:set(hudimage.atlas.selector1)
			self.inst.replica.gunutils._selectorimage1:set(hudimage.image.selector1)
		end
		if hudimage.atlas.selector2 then
			self.inst.replica.gunutils._selectoratlas2:set(hudimage.atlas.selector2)
			self.inst.replica.gunutils._selectorimage2:set(hudimage.image.selector2)
		end
		if hudimage.atlas.selector3 then
			self.inst.replica.gunutils._selectoratlas3:set(hudimage.atlas.selector3)
			self.inst.replica.gunutils._selectorimage3:set(hudimage.image.selector3)
		end
	end
end

local function oncurrent(self, current)
	self.inst.replica.gunutils._current:set(current)
	if current <= 0 then
		self:Emptied()
	end
end

local function onmax(self, max)
	self.inst.replica.gunutils._max:set(max)
end

local function onammotype(self, ammotype, old_ammotype)
	if old_ammotype ~= nil then
		self.inst:RemoveTag(old_ammotype.."_ammo_user")
	end
	if ammotype ~= nil then
		self.inst:AddTag(ammotype.."_ammo_user")
	end
end
local function ongunbullets(self, gunbullets, old_gunbullets)
	if old_gunbullets ~= nil then
		self.inst:RemoveTag(old_gunbullets.."_bullets_user")
	end
	if gunbullets ~= nil then
		self.inst:AddTag(gunbullets.."_bullets_user")
	end
end
local function onreloading(self, reloading)
	self.inst.replica.gunutils._reloading:set(reloading)
end

local function onsemiintervalmult(self, semiintervalmult)
	self.inst.replica.gunutils._semiintervalmult:set(semiintervalmult)
end

local function onautointervalmult(self, autointervalmult)
	self.inst.replica.gunutils._autointervalmult:set(autointervalmult)
end

local function onboltaction(self, boltaction)
	self.inst.replica.gunutils._boltaction:set(boltaction)
end

local function onboltactiondelay(self, boltactiondelay)
	self.inst.replica.gunutils._boltactiondelay:set(boltactiondelay)
end


local GunUtils = Class(function(self, inst)
	self.inst = inst
	
	self.cansingle = false
	self.canburst = false
	self.canauto = false
	self.selectorlock = false
	self.hudimage = nil
	self.burst = 3
	self.burstdelay = 2 * FRAMES
	self.shotgun = false
	self.shotgunoffset = 4
	self.boltaction = false
	self.boltactiondelay = 1
	self.ammotype = nil
	self.gunbullets = nil
	self.range = 15
	self.autointervalmult = 2
	self.semiintervalmult = 6
	self.infinite = false
	self.lastammo = nil
	self.reloadingfn = nil
	self.reloadedfn = nil
	self.emptiedfn = nil
	self.onfirefn = nil
	self.onselectorfn = nil
	self.offsetfn = nil
	
	self.selector = 0
	self.max = 0
	self.current = 0
	self.combo = 0
	self.bullet = nil
	self.damage = 0
	self.reloading = false
end,
nil,
{
	selector = onselector,
	selectorlock = onselectorlock,
	hudimage = onhudimage,
	max = onmax,
	current = oncurrent,
	ammotype = onammotype,
	gunbullets = ongunbullets,
	reloading = onreloading,
	semiintervalmult = onsemiintervalmult,
	autointervalmult = onautointervalmult,
	boltaction = onboltaction,
	boltactiondelay = onboltactiondelay,
})

function GunUtils:OnRemoveFromEntity()
	self.inst:RemoveTag("mgun")
	self.inst:RemoveTag("spear")
	if self.ammotype ~= nil then
		self.inst:RemoveTag(self.ammotype.."_ammo_user")
	end
	if self.gunbullets ~= nil then
		self.inst:RemoveTag(self.gunbullets.."_bullets_user")
	end
end
function GunUtils:OnSave()
	return
	{
		selector = self.selector,
		selectorlock = self.selectorlock,
		max = self.max,
		current = self.current,
		bullet = self.bullet,
		lastammo = self.lastammo,
		damage = self.damage,
		infinite = self.infinite,
	}
end

function GunUtils:OnLoad(data)
	if data.infinite ~= nil then 
		self.infinite = data.infinite
	end
	if data.bullet ~= nil then 
		self.bullet = data.bullet
	end
	if data.lastammo ~= nil then 
		self.lastammo = data.lastammo
	end
	if data.damage ~= nil then 
		self.damage = data.damage
	end
	if data.max ~= nil then 
		self:SetMax(data.max)
	end
	if data.current ~= nil then 
		self:SetCurrent(data.current)
	end
	if data.selector ~= nil then 
		self.selector = data.selector
	end
	if data.selectorlock ~= nil then 
		self.selectorlock = data.selectorlock
	end
end

local function isvalidmode(self, s)
	if s == 1 then
		return self.cansingle
	elseif s == 2 then
		return self.canburst
	elseif s == 3 then
		return self.canauto
	else 
		return true
	end
end

function GunUtils:SetAmmoType(ammotype)
	self.ammotype = ammotype
end

function GunUtils:SetGunBullets(gunbullets)
	self.gunbullets = gunbullets
end

function GunUtils:SetCanSingle(val)
	self.cansingle = val
end

function GunUtils:SetCanBurst(val)
	self.canburst = val
end

function GunUtils:SetCanAuto(val)
	self.canauto = val
end

function GunUtils:SetHudImage(atlas, image)
	self.hudimage = {atlas = atlas, image = image}
end

function GunUtils:SetAutoIntervalMult(val)
	self.autointervalmult = val
end

function GunUtils:SetSemiIntervalMult(val)
	self.semiintervalmult = val
end

function GunUtils:GetIntervalMult()
	return self.selector == 3 and self.autointervalmult or self.selector == 2 and self.semiintervalmult or self.selector == 1 and self.semiintervalmult or nil
end

function GunUtils:SetOffsetFn(fn)
	self.offsetfn = fn
end

function GunUtils:SetRange(val)
	self.range = val
end

function GunUtils:SetBurst(val)
	self.burst = val
end

function GunUtils:SetBurstDelay(val)
	self.burstdelay = val
end

function GunUtils:SetIsShotgun(val)
	self.shotgun = val
end

function GunUtils:SetShotgunOffset(val)
	self.shotgunoffset = val
end

function GunUtils:SetIsBoltAction(val)
	self.boltaction = val
end

function GunUtils:SetBoltActionDelay(val)
	self.boltactiondelay = val
end

function GunUtils:GetBoltActionDelay()
	return self.selector == 1  and self.boltaction and self.boltactiondelay
end

function GunUtils:CanBeReloaded()
	return (self.current < self.max or self.max <= 0) and not self.reloading
end

function GunUtils:SetEmptiedFn(fn)
	self.emptiedfn = fn
end

function GunUtils:SetReloadingFn(fn)
	self.reloadingfn = fn
end

function GunUtils:SetReloadedFn(fn)
	self.reloadedfn = fn
end

function GunUtils:SetOnFireFn(fn)
	self.onfirefn = fn
end

function GunUtils:SetOnSelectorFn(fn)
	self.onselectorfn = fn
end

function GunUtils:Emptied()
	if self.inst.components.weapon then
		self.inst.components.weapon:SetProjectile(nil)
		self.inst.components.weapon:SetRange(0)
		self.inst:RemoveTag("mgun")
		self.inst:AddTag("spear")
		self.inst.components.weapon:SetDamage(TUNING.HAMMER_DAMAGE)
		if self.selector ~= 0 and self.emptiedfn ~= nil then
			self.emptiedfn(self.inst)
		end
	end
end

function GunUtils:Reloaded(slot)
	if self.inst.components.weapon then
		if self.selector ~= 0 then
			self.inst.components.weapon:SetProjectile(self.bullet)
			self.inst.components.weapon:SetRange(self.range)
			self.inst:RemoveTag("spear")
			self.inst:AddTag("mgun")
			self.inst.components.weapon:SetDamage(self.damage)
		end
		if self.reloadedfn ~= nil then
			self.reloadedfn(self.inst, slot)
		end
	end
end

function GunUtils:Reload(ammo)
	if ammo then
		local val, maxval, bullet, damage, intval
		if ammo.components.gunammo then
			val = ammo.components.gunammo:GetValue()
			maxval = ammo.components.gunammo:GetMaxValue()
			bullet = ammo.components.gunammo:GetBullet()
			damage = ammo.components.gunammo:GetDamage()
			intval = ammo.components.gunammo.interval
		elseif ammo.components.gunbullets then
			val = 1
			maxval = nil
			bullet = ammo.components.gunbullets:GetBullet()
			damage = ammo.components.gunbullets:GetDamage()
			intval = ammo.components.gunbullets.interval
		else
			return false
		end
		self.inst.components.weapon:SetProjectile(nil)
		self.inst.components.weapon:SetRange(0)
		self.inst:RemoveTag("mgun")
		self.inst:AddTag("spear")
		self.inst.components.weapon:SetDamage(TUNING.HAMMER_DAMAGE)
		if ammo.components.gunammo then
			if self.lastammo then
				local owner = self.inst.components.inventoryitem and self.inst.components.inventoryitem:GetGrandOwner()
				if owner and owner.components.inventory then
					local la = SpawnPrefab(self.lastammo)
					la.components.gunammo:SetValue(self.current)
					owner.components.inventory:GiveItem(la)
				end
			end
			if ammo.components.gunammo.recyclable then
				self.lastammo = ammo.prefab
			else
				self.lastammo = nil
			end
		end
		if self.reloadingfn ~= nil then
			self.reloadingfn(self.inst, ammo.components.gunammo ~= nil)
		end
		if ammo.components.gunammo then ammo.components.gunammo:Loaded(self.inst) end
		if ammo.components.gunbullets then ammo.components.gunbullets:Loaded(self.inst) end
		ammo:Remove()
		self.reloading = true
		self.inst:DoTaskInTime(intval, function()
			local slot = self:SetMax(maxval)
			if slot then
				self:SetCurrent(val)
			else
				self:DoDelta(1)
			end
			self.bullet = bullet
			self.damage = damage
			self:Reloaded(slot)
			self.inst:PushEvent("mgun_reloaded", { val = val , slot =  slot })
			self.reloading = false
		end)
		return true
	else
		return false
	end
end

function GunUtils:Fire()
	if self.selector == 3 then
		self.count = self.count + 1
	end
	if not self.infinite then
		self:DoDelta(self.selector == 2 and not self.shotgun and self.burst * (-1) or -1)
	end
	if self.boltaction and self.selector == 1 then
		self.inst:PushEvent("boltaction")
		self.reloading = true
		self.inst:DoTaskInTime(self.boltactiondelay + FRAMES * self.semiintervalmult, function()
			self.reloading = false
		end)
	end
	if self.onfirefn ~= nil then
		self.onfirefn(self.inst)
	end

end

function GunUtils:DoDelta(val)
	self.current = math.max(0, math.min(self.max, self.current + val))
end

function GunUtils:SetMax(val)
	if val then
		self.current = math.max(0, math.min(self.current, val))
		self.max = math.max(0, val)
		return true
	else
		return false
	end
end

function GunUtils:SetCurrent(val)
	self.current = math.max(0, math.min(self.max, val))
end

function GunUtils:GetMax()
	return self.max
end

function GunUtils:GetCurrent()
	return self.current
end

function GunUtils:SetInfinite(val)
	if self.bullet ~= nil then
		self.infinite = val
		if val then
			local value = self.canburst and self.burst or 1
			self:SetMax(value)
			self:SetCurrent(value)
			self:Reloaded()
		end
	end
end

function GunUtils:ChangeMode()
	if not self.selectorlock then
		local mode = self.selector
		repeat
			mode = mode + 1
			if mode > 3 then
				mode = 0
			end
			if isvalidmode(self, mode) then
				break
			end
		until mode == self.selector
		if self.selector ~= mode then
			self.selector = mode
		end
		if self.onselectorfn ~= nil then
			self.onselectorfn(self.inst)
		end
	end
end

function GunUtils:SetSelectorLock(val)
	self.selectorlock = val
end

function GunUtils:IsSelectorLocked()
	return self.selectorlock
end

return GunUtils
