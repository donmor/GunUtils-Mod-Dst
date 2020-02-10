GLOBAL.MGUNFIREMODE = 
{
	SAFE = "SAFE",
	SINGLE = "SINGLE",
	BURST = "BURST",
	AUTO = "AUTO",
}

local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local STRINGS = GLOBAL.STRINGS
local TUNING = GLOBAL.TUNING
--local TheNet = GLOBAL.TheNet
local require = GLOBAL.require
local SpawnPrefab = GLOBAL.SpawnPrefab
local State = GLOBAL.State
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler
local FRAMES = GLOBAL.FRAMES
local TimeEvent = GLOBAL.TimeEvent
local EventHandler = GLOBAL.EventHandler
local DEGREES = GLOBAL.DEGREES or 0.017453277777778

--local MGUNFIREMODE = GLOBAL.MGUNFIREMODE

if not TUNING.MGUNAMMOTYPES then
	TUNING.MGUNAMMOTYPES = {}
end
if not TUNING.MGUNBULLETTYPES then
	TUNING.MGUNBULLETTYPES = {}
end
STRINGS.MGUN_MODE_ADJECTIVES = 
{
	SAFE = "保险",
	SINGLE = "单发",
	BURST = "连发",
	AUTO = "自动",
}

AddAction("RELOAD", "装填", function(act)
	if act.doer.components.inventory and act.target.components.gunutils then
		local ammo = act.doer.components.inventory:RemoveItem(act.invobject)
		if ammo then
			if act.target.components.gunutils:Reload(ammo) then
				return true
			else
				act.doer.components.inventory:GiveItem(ammo)
			end
		end
	end
end)
AddAction("REFILL", "装填", function(act)
	if act.doer.components.inventory and act.target.components.gunammo then
		local bullet = act.doer.components.inventory:RemoveItem(act.invobject)
		if bullet then
			if act.target.components.gunammo:Refill(bullet) then
				return true
			else
				act.doer.components.inventory:GiveItem(bullet)
			end
		end
	end
end)
AddComponentAction("USEITEM", "gunbullets", function(inst, doer, target, actions)
	if target.replica.inventoryitem ~= nil and target.replica.gunutils then
		for _, v in pairs(TUNING.MGUNBULLETTYPES) do
			if inst:HasTag(v.."_bullets") then
				if target:HasTag(v.."_bullets_user") and target.replica.gunutils:CanBeReloaded() then
					table.insert(actions, ACTIONS.RELOAD)
				end
				return
			end
		end
	elseif target.replica.inventoryitem ~= nil and target.replica.gunammo then
		for _, v in pairs(TUNING.MGUNBULLETTYPES) do
			if inst:HasTag(v.."_bullets") then
				if target.replica.gunammo and target.replica.gunammo:GetGunBullets() == inst.prefab and target.replica.gunammo:GetValue() < target.replica.gunammo:GetMaxValue() then
					table.insert(actions, ACTIONS.REFILL)
				end
				return
			end
		end
	end
end)
AddComponentAction("USEITEM", "gunammo", function(inst, doer, target, actions)
	if target.replica.inventoryitem ~= nil and target.replica.gunutils then
		for _, v in pairs(TUNING.MGUNAMMOTYPES) do
			if inst:HasTag(v.."_ammo") and inst.replica.gunammo:GetValue() > 0 then
				if target:HasTag(v.."_ammo_user") and target.replica.gunutils:CanBeReloaded() then
					table.insert(actions, ACTIONS.RELOAD)
				end
				return
			end
		end
	end
end)
AddAction("FIRESELECT", "快慢机", function(act)
	if act.invobject ~= nil and
		act.invobject.components.gunutils ~= nil and
		act.doer.components.inventory ~= nil and
		act.doer.components.inventory:IsOpenedBy(act.doer) then
		act.invobject.components.gunutils:ChangeMode()
		return true
	end
end)
AddComponentAction("INVENTORY", "gunutils", function(inst, doer, actions)
	if inst.replica.equippable ~= nil and
		inst.replica.equippable:IsEquipped() and
		not inst.replica.gunutils:IsSelectorLocked() and
		doer.replica.inventory ~= nil and
		doer.replica.inventory:IsOpenedBy(doer) then
		table.insert(actions, ACTIONS.FIRESELECT)
	end
end)
AddAction("DECOMPOSE", "分解", function(act)
	if act.invobject ~= nil and
		act.invobject.components.gunammo ~= nil and
		act.doer.components.inventory ~= nil and
		act.doer.components.inventory:IsOpenedBy(act.doer) then
		act.invobject.components.gunammo:Decompose()
		return true
	end
end)
AddComponentAction("INVENTORY", "gunammo", function(inst, doer, actions)
	if inst.replica.gunammo ~= nil and
		inst.replica.gunammo:GetDecomposable() and
		inst.replica.gunammo:GetValue() > 0 and
		doer.replica.inventory ~= nil and
		doer.replica.inventory:IsOpenedBy(doer) then
		table.insert(actions, ACTIONS.DECOMPOSE)
	end
end)

local ah = ActionHandler(ACTIONS.ATTACK, function(inst, action)
	inst.sg.mem.localchainattack = not action.forced or nil
	if not (inst.sg:HasStateTag("attack") and action.target == inst.sg.statemem.attacktarget or inst.components.health:IsDead()) then
		local weapon = inst.components.combat ~= nil and inst.components.combat:GetWeapon() or nil
		return (weapon == nil and "attack")
			or (weapon:HasTag("blowdart") and "blowdart")
			or (weapon:HasTag("mgun") and "mgun")
			or (weapon:HasTag("thrown") and "throw")
			or (weapon:HasTag("multithruster") and "multithrust_pre")
			or "attack"
	end
end)
local ahc = ActionHandler(ACTIONS.ATTACK, function(inst, action)
	if not (inst.sg:HasStateTag("attack") and action.target == inst.sg.statemem.attacktarget or inst.replica.health:IsDead()) then
		local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equip == nil then
			return "attack"
		end
		local inventoryitem = equip.replica.inventoryitem
		return (not (inventoryitem ~= nil and inventoryitem:IsWeapon()) and "attack")
			or (equip:HasTag("blowdart") and "blowdart")
			or (equip:HasTag("mgun") and "mgun")
			or (equip:HasTag("thrown") and "throw")
			or "attack"
	end

end)
AddStategraphActionHandler("wilson", ah)
AddStategraphActionHandler("wilson_client", ahc)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.RELOAD, "mgunfireselect"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.RELOAD, "mgunfireselect"))
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.REFILL))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.REFILL))
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.DECOMPOSE, "mgunfireselect"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.DECOMPOSE, "mgunfireselect"))
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.FIRESELECT, "mgunfireselect"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.FIRESELECT, "mgunfireselect"))

local mgunshot = State{
	name = "mgun",
	tags = { "attack", "notalking", "abouttoattack", "autopredict" },

	onenter = function(inst)
		local buffaction = inst:GetBufferedAction()
		local target = buffaction ~= nil and buffaction.target or nil
		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		inst.components.combat:SetTarget(target)
		inst.components.combat:StartAttack()
		inst.AnimState:PlayAnimation("dart_lag")
		
		if inst.sg.prevstate == inst.sg.currentstate then
			inst.sg.statemem.chained = true
			inst.AnimState:SetTime(1 * FRAMES)
		elseif equip.components.gunutils then
			equip.components.gunutils.count = 0
		end
		inst.AnimState:PushAnimation("catch", false)
		
		local intervalmult = equip.components.gunutils and equip.components.gunutils:GetIntervalMult() or 1
		local boltactiondelay = equip.components.gunutils and equip.components.gunutils:GetBoltActionDelay() or 0
		inst.sg:SetTimeout((inst.sg.statemem.chained and 2.1 or 2.4) * FRAMES * intervalmult + boltactiondelay)

		if target ~= nil and target:IsValid() then
			inst:FacePoint(target.Transform:GetWorldPosition())
			inst.sg.statemem.attacktarget = target
		end

		if (equip ~= nil and equip.projectiledelay or 0) > 0 then
			--V2C: Projectiles don't show in the initial delayed frames so that
			--	 when they do appear, they're already in front of the player.
			--	 Start the attack early to keep animation in sync.
			inst.sg.statemem.projectiledelay = (inst.sg.statemem.chained and 0.7 or 0.8) * FRAMES
			if inst.sg.statemem.projectiledelay <= 0 then
				inst.sg.statemem.projectiledelay = nil
			end
		end
	end,

	onupdate = function(inst, dt)
		if (inst.sg.statemem.projectiledelay or 0) > 0 then
			inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
			if inst.sg.statemem.projectiledelay <= 0 then
				inst:PerformBufferedAction()
				inst.sg:RemoveStateTag("abouttoattack")
			end
		end
	end,

	timeline =
	{
		TimeEvent(0.7 * FRAMES, function(inst)
			if inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
				inst:PerformBufferedAction()
				inst.sg:RemoveStateTag("abouttoattack")
			end
		end),
		TimeEvent(0.8 * FRAMES, function(inst)
			if not inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
				inst:PerformBufferedAction()
				inst.sg:RemoveStateTag("abouttoattack")
			end
		end),
	},

	ontimeout = function(inst)
		inst.sg:RemoveStateTag("attack")
		inst.sg:AddStateTag("idle")
	end,

	events =
	{
		EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
		EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
		EventHandler("animqueueover", function(inst)
			if inst.AnimState:AnimDone() then
				inst.sg:GoToState("idle")
			end
		end),
	},

	onexit = function(inst)
		inst.components.combat:SetTarget(nil)
		if inst.sg:HasStateTag("abouttoattack") then
			inst.components.combat:CancelAttack()
		end
	end,
}
local mgunshotc = State{
	name = "mgun",
	tags = { "attack", "notalking", "abouttoattack" },

	onenter = function(inst)
		local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		inst.AnimState:PlayAnimation("dart_lag")
		if inst.sg.prevstate == inst.sg.currentstate then
			inst.sg.statemem.chained = true
			inst.AnimState:SetTime(1 * FRAMES)
		end
		inst.AnimState:PushAnimation("catch", false)

		if inst.replica.combat ~= nil then
			inst.replica.combat:StartAttack()
			local intervalmult = equip.replica.gunutils and equip.replica.gunutils:GetIntervalMult() or 1
			local boltactiondelay = equip.replica.gunutils and equip.replica.gunutils:GetBoltActionDelay() or 0
			inst.sg:SetTimeout((inst.sg.statemem.chained and 2.1 or 2.4) * FRAMES * intervalmult + boltactiondelay)
		end

		local buffaction = inst:GetBufferedAction()
		if buffaction ~= nil then
			inst:PerformPreviewBufferedAction()

			if buffaction.target ~= nil and buffaction.target:IsValid() then
				inst:FacePoint(buffaction.target:GetPosition())
				inst.sg.statemem.attacktarget = buffaction.target
			end
		end

		if (equip.projectiledelay or 0) > 0 then
			--V2C: Projectiles don't show in the initial delayed frames so that
			--     when they do appear, they're already in front of the player.
			--     Start the attack early to keep animation in sync.
			inst.sg.statemem.projectiledelay = (inst.sg.statemem.chained and 0.7 or 0.8) * FRAMES
			if inst.sg.statemem.projectiledelay <= 0 then
				inst.sg.statemem.projectiledelay = nil
			end
		end
	end,

	onupdate = function(inst, dt)
		if (inst.sg.statemem.projectiledelay or 0) > 0 then
			inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
			if inst.sg.statemem.projectiledelay <= 0 then
				inst:ClearBufferedAction()
				inst.sg:RemoveStateTag("abouttoattack")
			end
		end
	end,

	timeline =
	{
		TimeEvent(0.7 * FRAMES, function(inst)
			if inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
				inst:ClearBufferedAction()
				inst.sg:RemoveStateTag("abouttoattack")
			end
		end),
		TimeEvent(0.8 * FRAMES, function(inst)
			if not inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
				inst:ClearBufferedAction()
				inst.sg:RemoveStateTag("abouttoattack")
			end
		end),
	},

	ontimeout = function(inst)
		inst.sg:RemoveStateTag("attack")
		inst.sg:AddStateTag("idle")
	end,

	events =
	{
		EventHandler("animqueueover", function(inst)
			if inst.AnimState:AnimDone() then
				inst.sg:GoToState("idle")
			end
		end),
	},

	onexit = function(inst)
		if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
			inst.replica.combat:CancelAttack()
		end
	end,
}

local fireselect = State{
	name = "mgunfireselect",
	tags = { "fireselect" },

	onenter = function(inst)
		local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equip and equip.components.gunutils then
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("dart_lag")
			inst.AnimState:PushAnimation("catch", false)
		end
	end,

	timeline =
	{
		TimeEvent(13 * FRAMES, function(inst)
			inst:PerformBufferedAction()
		end),
	},

	events =
	{
		EventHandler("animqueueover", function(inst)
			if inst.AnimState:AnimDone() then
				inst.sg:GoToState("idle")
			end
		end),
	},
}
local fireselectc = State
{
	name = "mgunfireselect",
	tags = { "fireselect" },

	onenter = function(inst)
		local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if equip and equip.replica.gunutils then
			if not inst:HasTag("fireselect") then
				inst.AnimState:PlayAnimation("dart_lag")
			end
		end
		inst:PerformPreviewBufferedAction()
		inst.sg:SetTimeout(2)
		
	end,

	onupdate = function(inst)
		if inst:HasTag("fireselect") then
			if inst.entity:FlattenMovementPrediction() then
				inst.sg:GoToState("idle", "noanim")
			end
		elseif inst.bufferedaction == nil then
			local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if equip and equip.replica.gunutils then
				inst.AnimState:PlayAnimation("catch")
			end
			inst.sg:GoToState("idle", true)
		end
	end,

	ontimeout = function(inst)
		inst:ClearBufferedAction()
		if equip and equip.replica.gunutils then
			inst.AnimState:PlayAnimation("catch")
		end
		inst.sg:GoToState("idle", true)
	end,
}
AddStategraphState("wilson", mgunshot)
AddStategraphState("wilson_client", mgunshotc)
AddStategraphState("wilson", fireselect)
AddStategraphState("wilson_client", fireselectc)

local function launch(self, attacker, target, projectile, offset)
	local proj = SpawnPrefab(projectile or self.projectile)
	if proj ~= nil then
		if proj.components.projectile ~= nil then
			local x, y, z = attacker.Transform:GetWorldPosition()
			local x2, y2, z2 = target.Transform:GetWorldPosition()
			local offsetd = offset ~= nil and math.tan(math.rad(offset)) * math.sqrt(math.pow(z2 - z, 2) + math.pow(x2 - x, 2)) or 0
			proj.Transform:SetPosition(x, y + (self.projalign or 0), z)
			
			proj.components.projectile:Throw(self.inst, target, attacker, offsetd, offsetd, offsetd)
			if self.inst.projectiledelay ~= nil then
				proj.components.projectile:DelayVisibility(self.inst.projectiledelay)
			end
		elseif proj.components.complexprojectile ~= nil then
			proj.Transform:SetPosition(attacker.Transform:GetWorldPosition())
			proj.components.complexprojectile:Launch(target:GetPosition(), attacker, self.inst)
		end
	end
end
AddComponentPostInit("weapon", function(self)
	self.onprojectilelaunched = nil
	self.SetOnProjectileLaunched = function(self, fn)
		self.onprojectilelaunched = fn
	end
	self.LaunchProjectile = function(self, attacker, target)
		if self.projectile ~= nil then
			if self.onprojectilelaunch ~= nil then
				self.onprojectilelaunch(self.inst, attacker, target)
			end
			
			if self.inst:HasTag("mgun") and self.inst.components.gunutils then
				if self.inst.components.gunutils.selector == 1 and self.inst.components.gunutils.shotgun then
					for _ = 1, self.inst.components.gunutils.burst do
						local offset = self.inst.components.gunutils.shotgunoffset
						launch(self, attacker, target, nil, offset)
					end
					self.inst.components.gunutils:Fire()
				elseif self.inst.components.gunutils.selector == 2 then
					for k = 1, math.min(self.inst.components.gunutils.burst, self.inst.components.gunutils.current) do
						local proj = self.projectile
						local offsetfn = self.inst.components.gunutils.offsetfn
						local offset = offsetfn and offsetfn(k) or 0
						self.inst:DoTaskInTime((k - 1) * self.inst.components.gunutils.burstdelay, function()
							launch(self, attacker, target, proj, offset)
							self.inst.components.gunutils:Fire()
						end)
					end
				else
					local offsetfn = self.inst.components.gunutils.offsetfn
					local count = self.inst.components.gunutils.count
					local offset = offsetfn and offsetfn(count) or 0
					launch(self, attacker, target, nil, offset)
					self.inst.components.gunutils:Fire()
				end
			else
				launch(self, attacker, target)
			end
			if self.onprojectilelaunched ~= nil then
				self.onprojectilelaunched(self.inst, attacker, target)
			end
		end
	end
end)

AddComponentPostInit("projectile", function(self)

	self.Throw = function(self, owner, target, attacker, x_offset, y_offset, z_offset)
		self.owner = owner
		self.target = target
		self.start = owner:GetPosition()
		self.dest = target:GetPosition()
		
		self.dest.x = x_offset and x_offset * (math.random() - 0.5) + self.dest.x or self.dest.x
		self.dest.y = y_offset and y_offset * (math.random() - 0.5) + self.dest.y or self.dest.y
		self.dest.z = z_offset and z_offset * (math.random() - 0.5) + self.dest.z or self.dest.z

		if attacker ~= nil and self.launchoffset ~= nil then
			local x, y, z = self.inst.Transform:GetWorldPosition()
			local facing_angle = attacker.Transform:GetRotation() * DEGREES
			self.inst.Transform:SetPosition(x + self.launchoffset.x * math.cos(facing_angle), y + self.launchoffset.y, z - self.launchoffset.x * math.sin(facing_angle))
		end

		self:RotateToTarget(self.dest)
		self.inst.Physics:SetMotorVel(self.speed, 0, 0)
		
		-- Make compatitable with Watatsuki sisters
		target:PushEvent("hostileprojectile_for_jws", { thrower = owner, attacker = attacker, target = target, proj = self.inst})
		
		self.inst:StartUpdatingComponent(self)
		self.inst:PushEvent("onthrown", { thrower = owner, target = target })
		target:PushEvent("hostileprojectile", { thrower = owner, attacker = attacker, target = target })
		if self.onthrown ~= nil then
			self.onthrown(self.inst, owner, target, attacker)
		end
		if self.cancatch and target.components.catcher ~= nil then
			target.components.catcher:StartWatching(self.inst)
		end
	end
end)


AddComponentPostInit("combat", function(self)
	local pCalcDamage = self.CalcDamage
	self.CalcDamage = function(self, target, weapon, multiplier)		
		local negamult = 1 / (self.damagemultiplier or 1) / (self.externaldamagemultipliers:Get() or 1)
		local nmult = weapon and weapon:HasTag("fixeddamage") and negamult
		return pCalcDamage(self, target, weapon, nmult or multiplier) - (self.damagebonus or 0)
	end
end)

local gunhud = require("widgets/gunhud")

local function AddGunHud(self)
	self.gunhud = self:AddChild(gunhud(self.owner))
end

AddClassPostConstruct("widgets/inventorybar", AddGunHud)

AddReplicableComponent("gunutils")
AddReplicableComponent("gunammo")
