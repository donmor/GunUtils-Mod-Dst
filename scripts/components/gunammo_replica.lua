local GunAmmo = Class(function(self, inst)
	self.inst = inst
	self._value = net_byte(inst.GUID, "gunammo._value")
	self._maxvalue = net_byte(inst.GUID, "gunammo._maxvalue")
	self._gunbullets = net_string(inst.GUID, "gunammo._gunbullets")
	self._decomposable = net_bool(inst.GUID, "gunammo._decomposable")
end)

function GunAmmo:GetValue()
	return self._value:value()
end

function GunAmmo:GetMaxValue()
	return self._maxvalue:value()
end

function GunAmmo:GetGunBullets()
	return self._gunbullets:value()
end

function GunAmmo:GetDecomposable()
	return self._decomposable:value()
end

return GunAmmo