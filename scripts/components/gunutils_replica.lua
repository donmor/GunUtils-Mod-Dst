local GunUtils = Class(function(self, inst)
	self.inst = inst
	self._selector = net_int(inst.GUID, "gunutils._selector")
	self._selectorlock = net_bool(inst.GUID, "gunutils._selectorlock")
	self._current = net_byte(inst.GUID, "gunutils._current")
	self._max = net_byte(inst.GUID, "gunutils._max")
	self._reloading = net_bool(inst.GUID, "gunutils._reloading")
	self._semiintervalmult = net_float(inst.GUID, "gunutils._semiintervalmult")
	self._autointervalmult = net_float(inst.GUID, "gunutils._autointervalmult")
	self._boltaction = net_bool(inst.GUID, "gunutils._boltaction")
	self._boltactiondelay = net_float(inst.GUID, "gunutils._boltactiondelay")
	
	self._reloadingimage = net_string(inst.GUID, "gunutils._reloadingimage")
	self._reloadingatlas = net_string(inst.GUID, "gunutils._reloadingatlas")
	self._selectorimage0 = net_string(inst.GUID, "gunutils._selectorimage0")
	self._selectoratlas0 = net_string(inst.GUID, "gunutils._selectoratlas0")
	self._selectorimage1 = net_string(inst.GUID, "gunutils._selectorimage1")
	self._selectoratlas1 = net_string(inst.GUID, "gunutils._selectoratlas1")
	self._selectorimage2 = net_string(inst.GUID, "gunutils._selectorimage2")
	self._selectoratlas2 = net_string(inst.GUID, "gunutils._selectoratlas2")
	self._selectorimage3 = net_string(inst.GUID, "gunutils._selectorimage3")
	self._selectoratlas3 = net_string(inst.GUID, "gunutils._selectoratlas3")
end)

function GunUtils:IsSelectorLocked()
	return self._selectorlock:value()
end

function GunUtils:GetIntervalMult()
	return self._selector:value() == 3 and self._autointervalmult:value() or self._selector:value() == 2 and self._semiintervalmult:value() or self._selector:value() == 1 and self._semiintervalmult:value() or nil
end

function GunUtils:GetBoltActionDelay()
	return self._selector:value() == 1 and self._boltaction:value() and self._boltactiondelay:value()
end

function GunUtils:CanBeReloaded()
    return (self._current:value() < self._max:value() or self._max:value() <= 0) and not self._reloading:value()
end

function GunUtils:GetHudImage(k)
	local image = {}
	table.insert(image, self._selectorimage0:value() or "")
	table.insert(image, self._selectorimage1:value() or "")
	table.insert(image, self._selectorimage2:value() or "")
	table.insert(image, self._selectorimage3:value() or "")
	table.insert(image, self._reloadingimage:value() or "")
	return image[k + 1]..".tex"
end

function GunUtils:GetHudAtlas(k)
	local atlas = {}
	table.insert(atlas, 1, self._selectoratlas0:value() or "")
	table.insert(atlas, 2, self._selectoratlas1:value() or "")
	table.insert(atlas, 3, self._selectoratlas2:value() or "")
	table.insert(atlas, 4, self._selectoratlas3:value() or "")
	table.insert(atlas, 5, self._reloadingatlas:value() or "")
	return atlas[k + 1]
end

return GunUtils
