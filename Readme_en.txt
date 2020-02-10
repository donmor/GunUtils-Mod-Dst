========GunUtils API========

[Details]
	*Max firerate: 500 RPM
	*Max clip size: 255
	*Remained bullets in the gun can be configured recyclable
	*Connfigurable range
	*Selector with SAFE mode and is able to locked it up
	*Semi/Burst/Auto mode
	*Bolt action/Shootgun mode
	*Configurable projectile amount per shoot under Shotgun/Burst mode
	*Define your own ballistic model using a custom function
	*HUD that shows the name/pattern/ammo/selector status of the gun
	*Magazines can be configured decomposable
	*Bullets can be filled into magazines or guns(configurable)
[Modmain]
	Add these code at the beginning of modmain.lua:
		if not GLOBAL.TUNING.MGUNAMMOTYPES then
			GLOBAL.TUNING.MGUNAMMOTYPES = {}
		end
		if not GLOBAL.TUNING.MGUNBULLETTYPES then
			GLOBAL.TUNING.MGUNBULLETTYPES = {}
		end
	Then add your own ammo/bullet type in these tables such as:
		GLOBAL.TUNING.MGUNAMMOTYPES.UZI = "uzi"
		GLOBAL.TUNING.MGUNBULLETTYPES.NATO_9MM = "nato_9mm"
[Building Prefab For the Gun]
	Add these components to prefab of the gun: 
		inspecable, inventoryitem, equippable, weapon
	After the codes of weapon component, add this component: gunutils
	GunUtils - functions: ([R] = Replica, # = essential)
		*SetAmmoType((string)ammotype)#
			Define the type of ammo, using TUNING.MGUNAMMOTYPES.*.
		*SetGunBullets((string)ammotype)#
			Define the type of bullets, using TUNING.MGUNBULLETTYPES.*.Attention: Avoid using different bullets on the same gun unless clip size is 1.
		*SetCanSingle((Bool)val)
		*SetCanBurst((Bool)val)
		*SetCanAuto((Bool)val)
			Define the modes of the gun.
			#At least one mode is required.
		*SetHudImage([table]atlas, [table]image)
			This function provides the texture of reloading overlay and selector icons.
		*SetSemiIntervalMult((float)val)
			Semi-mode(Single/Burst) interval multiplier. The minimum is 3 and the default is 6.
		*SetAutoIntervalMult((float)val)
			Auto-mode interval multiplier. The minimum is 1 and the default is 2.
		*GetIntervalMult()[R]
			Returns current interval multiplier.
		·SetSafeDamage((float)val)
			Define the damage when the gun can't fire. Usually set on rifles with a bayonet.
		*SetOffsetFn((function(count))fn)
			Set a function of bullets shot in a burst, which returns an offset angle that affects the ballistic model of mode BURST and AUTO. If not set, the offset will be always 0.
		*SetRange((float)val)
			Define the range(>=0). The default is 15.
		*SetBurst((int)val)
			Define the value that how many projectiles will be launched under Shotgun/Burst mode. The default is 3.
		*SetBurstDelay((float)val)
			Define the interval between Burst launchings(sec). The default is 3 FRAMES.
		*SetIsShotgun((bool)val)
			Set the gun to Shotgun mode instead of Single mode.
		*SetShotgunOffset((float)val)
			Define the offset angle of shotgun balls. The default is 4.
		*SetIsBoltAction((bool)val)
			Is this gun Bolt-Action(need to spend extra time to reload after each launching)?
		*SetBoltActionDelay((float)val)
			Define the extra reoading time of Bolt-Action guns(sec).
		*GetBoltActionDelay()[R]
			Get the extra reoading time of Bolt-Action guns.
		*CanBeReloaded()[R]
			Could this gun be reloaded?.
		*SetEmptiedFn((function(inst))fn)
			Set a function to execute when the gun is emptied.
		*SetReloadingFn((function(inst, slot))fn)
			Set a function to execute when starting reload the gun. The argument slot = true when loading a magazine, false when loading a single bullet.
		*SetReloadedFn((function(inst))fn)
			Set a function to execute when finishing reload the gun.
		*SetOnFireFn((function(inst))fn)
			Set a function to execute when the gun fires.
		*SetOnSelectorFn((function(inst))fn)
			Set a function to execute when changing the mode of the gun.
		*Reload((object)ammo)
			Immediately reload the gun with given ammo.
		*DoDelta((int)val)
			Add remove some bullets from the gun.
		*SetMax((int)val)# - if SetGunBullets(ammotype) exists
			Define the max amount of bullets. Must be defined before SetCurrent().
		*SetCurrent((int)val)
			Define the current amount of bullets.
		*GetMax()
			Get the max amount of bullets.
		*GetCurrent()
			Get the current amount of bullets.
		*SetInfinite((bool)val)
			Test only - Set this gun to infinite mode.Attention: Don't use if max = 0.
		*ChangeMode()
			Change mode.
		*SetSelectorLock((bool)val)
			Lock or unlock selector. Usually for simple OP guns. Evaluate "inst.components.gunutils.selector" in the prefab and then lock it up.
	To add reloading/selector patterns, add these tables before the main function of the prefab:
		local hudimage =
		{
			reload = "reload",			-- Reloading overlay
			selector0 = "selector-0",	-- SAFE
			selector1 = "selector-1",	-- SINGLE
			selector2 = "selector-2",	-- BURST
			selector3 = "selector-3",	-- AUTO
		}

		local hudatlas =
		{
			reload = "images/utils/reload.xml",
			selector0 = "images/utils/selector-0.xml",
			selector1 = "images/utils/selector-1.xml",
			selector2 = "images/utils/selector-2.xml",
			selector3 = "images/utils/selector-3.xml",
		}
		*Unnecessary elements can be ignored.
	Then prepare the texture.
	Finally add function SetHudImage:
		inst.components.gunutils:SetHudImage(hudatlas, hudimage)
[Building Prefab for ammo]
	Add these component to the prefab of the ball(projectile):
		weapon, projectile
	Add these component to the prefab of the ammo
		inspectable, inventoryitem
	Add this component: gunammo
	GunAmmo - functions: ([R] = Replica, # = essential)
		*GetMaxValue()[R]
			Get the max clip size.
		*GetValue()[R]
			Get the current amount of bullets in the magazine.
		*SetMaxValue((int)val)#
			Define the max clip size. This should be the same to the Value.
		*SetValue((int)val)#
			Define the current amount of bullets in the magazine.
		*SetInterval((int)val)#
			
		*GetType()
			Get the type of ammo.
		*SetType((string)val)#
			Define the type of ammo, using TUNING.MGUNAMMOTYPES.*.
		*GetBullet()
			Get the prefab name of the balls launched by the gun.
		*SetBullet((string)val)#
			Define the prefab name of the balls launched by the gun.
		*SetRecyclable((bool)val)
			Set it to "true" to recycle the remaining bullets when the gun reloads.
		*SetDecomposable((bool)val)[R]
			Define whether magazines can be Decomposed to get bullets(ITEM) or not.
		*GetGunBullets()[R]
			Get the prefab name of the bullet.
		*SetGunBullets((string)val)# - if SetDecomposable(true) exists
			Get the prefab name of the bullet.
		*GetDamage()
			Get the damage per bullet.
		*SetDamage((float)val)#
			Set the damage per bullet. This should be the same to That in the projectile prefab.
		*SetOnLoadedFn((function(inst, tgt))fn)
			Set a function to execute when the ammo is loaded.
		*SetOnRefilledFn((function(inst, tgt))fn)
			Set a function to execute where filling something into the ammo.
	*Ignore if not needed.
	Add these component to the prefab of the bullets(ITEM):
		inspectable, inventoryitem
	Add this component: gunammo
	GunBullets - function: (# = essential)
		*SetInterval((int)val)#
			Define the time duration spent by reloading. The default is 0.5.
		*GetBullet()
			Get the prefab name of the balls launched by the gun.
		*SetBullet((string)val)#
			Define the prefab name of the balls launched by the gun.
		*GetBulletType()
			Define the type of bullet(ITEM), using TUNING.MGUNBULLETTYPES.*.
		*SetBulletType((string)val)#
			Define the type of bullet(ITEM), using TUNING.MGUNBULLETTYPES.*.
		*GetDamage()
			Get the damage per bullet.
		*SetDamage((float)val)#
			Set the damage per bullet. This should be the same to That in the projectile prefab.
		*SetOnLoadedFn((function(inst, tgt))fn)
			Set a function to execute when the bullet is loaded.
