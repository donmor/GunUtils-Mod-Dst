========GunUtils API========

[基本特性]
	·最高支持射速500发/分
	·最高弹匣容量支持255发
	·弹匣可配置回收余弹
	·可配置射程
	·带保险功能的快慢机, 可锁定
	·单发/连发/自动3种模式, 可根据实际需要分别开启
	·单发模式可配置开启栓动/霰弹枪模式
	·连发模式单次发射弹数(霰弹枪单发射出弹丸数)可配置
	·使用一个函数配置连发和自动模式的弹道
	·通过画面左下角的射击指示器显示枪械图案/名称/弹量/快慢机状态(换弹/快慢机图示需自备)
	·弹匣可配置分解得到单发子弹, 子弹可填入未满的弹匣
	·可配置用单发子弹直接装填
[Modmain]
	确认modmain.lua的头部包含以下内容:
		if not GLOBAL.TUNING.MGUNAMMOTYPES then
			GLOBAL.TUNING.MGUNAMMOTYPES = {}
		end
		if not GLOBAL.TUNING.MGUNBULLETTYPES then
			GLOBAL.TUNING.MGUNBULLETTYPES = {}
		end
	接着在表MGUNAMMOTYPES中添加对应的子项, 以MicroUzi为例(下同):
		GLOBAL.TUNING.MGUNAMMOTYPES.UZI = "uzi"
		GLOBAL.TUNING.MGUNAMMOTYPES.NATO_9MM = "nato_9mm"
[构建枪械Prefab]
	确认以下component已经添加到枪械的prefab中: 
		inspecable, inventoryitem, equippable, weapon
	在weapon定义段后添加component: gunutils, 并指定基本属性.
	GunUtils类的主要方法: ([R]表示Client可用, *表示为必需项)
		·SetAmmoType((string)ammotype)*
			指定使用的弹药类型, 必须为TUNING.MGUNAMMOTYPES的子项.
		·SetGunBullets((string)ammotype)*
			指定使用弹药的子弹类型, 必须为TUNING.MGUNBULLETTYPES的子项.注意: 装填不同属性的单发子弹将改变枪内所有子弹的属性. 避免在同一枪械上使用不同属性的多种弹药, 除非最大弹量为1.
		·SetCanSingle((Bool)val)
		·SetCanBurst((Bool)val)
		·SetCanAuto((Bool)val)
			设置是否能单发射击/连发点射/全自动射击.
			*此三项必须至少设定其中之一.
		·SetHudImage([table]atlas, [table]image)
			设置显示在射击指示器上的换弹时的覆盖图像以及快慢机图示.
		·SetSemiIntervalMult((float)val)
			指定半自动射击(单发/连发点射)的射击间隔倍数, 最小为3, 默认为6.
		·SetAutoIntervalMult((float)val)
			指定全自动射击的射击间隔倍数, 最小为1, 默认为2.
		·GetIntervalMult()[R]
			获取当前射击模式下的射击间隔倍数.
		·SetOffsetFn((function(count))fn)
			指定弹道发散角度关于一次连发或自动射击的射出子弹数的函数, 返回的角度值将用来设定连发和自动模式的弹道偏移, 若不指定则弹道永不偏移.
		·SetRange((float)val)
			指定射程(不小于0), 默认为15.
		·SetBurst((int)val)
			指定一次半自动射击的射出弹量, 此项决定连发点射的发弹量和霰弹枪的单发弹丸射出量, 默认为3.
		·SetBurstDelay((float)val)
			指定连发点射时的发弹间隔, 单位为秒, 默认为2帧长度.
		·SetIsShotgun((bool)val)
			设置单发模式时是否发射霰弹, 即是否为霰弹枪.
		·SetShotgunOffset((float)val)
			设置霰弹枪的发弹散布角, 默认为4.
		·SetIsBoltAction((bool)val)
			设置单发模式是否为栓动(即有一段额外的时间进入装填状态).
		·SetBoltActionDelay((float)val)
			设置栓动枪械额外的上弹时间, 单位为秒.
		·GetBoltActionDelay()[R]
			获取栓动枪械额外的上弹时间. 仅在单发模式可用.
		·CanBeReloaded()[R]
			获取获取枪械当前是否能装入弹药.
		·SetEmptiedFn((function(inst))fn)
			指定一个函数在枪械弹药耗尽时执行.
		·SetReloadingFn((function(inst, slot))fn)
			指定一个函数在枪械开始装弹时执行. 多用来播放装弹音效.slot参数为true时代表装入的是弹匣, 否则为单发子弹.
		·SetReloadedFn((function(inst))fn)
			指定一个函数在枪械装弹完成时执行. 多用来播放装弹音效.slot参数为true时代表装入的是弹匣, 否则为单发子弹.
		·SetOnFireFn((function(inst))fn)
			指定一个函数在枪械开火时执行. 多用来播放开火音效.
		·SetOnSelectorFn((function(inst))fn)
			指定一个函数在枪械转换射击模式时执行. 多用来播放快慢机音效.
		·Reload((object)ammo)
			立即使用指定的弹药装填枪械.
		·DoDelta((int)val)
			使当前弹量增加/减少指定数值.
		·SetMax((int)val)* - 当SetGunBullets(ammotype)存在时
			指定枪械最大弹量, 须在SetCurrent前执行.
		·SetCurrent((int)val)
			指定枪械当前弹量.
		·GetMax()
			获取枪械最大弹量.
		·GetCurrent()
			获取枪械当前弹量.
		·SetInfinite((bool)val)
			仅供测试, 指定枪械是否弹药无尽, 若参数为真则填入满足枪械正常发射的最小弹量(对可连发点射枪械为一次点射的发弹量, 其余为1). 对未曾装填弹药的新枪无效.
		·ChangeMode()
			操作快慢机, 改变枪械当前射击模式.
		·SetSelectorLock((bool)val)
			锁定快慢机. 通常用于一些装弹方式特殊或者无需装弹的枪械. 在prefab中为"inst.components.gunutils.selector"赋值, 然后锁定之.
	若需添加换弹/快慢机图示, 则需在prefab构建函数前加入:
		local hudimage =
		{
			reload = "reload",			-- 换弹覆盖图像
			selector0 = "selector-0",	-- 保险状态图标
			selector1 = "selector-1",	-- 单发状态图标
			selector2 = "selector-2",	-- 连发点射状态图标
			selector3 = "selector-3",	-- 全自动状态图标
		}

		local hudatlas =
		{
			reload = "images/utils/reload.xml",
			selector0 = "images/utils/selector-0.xml",
			selector1 = "images/utils/selector-1.xml",
			selector2 = "images/utils/selector-2.xml",
			selector3 = "images/utils/selector-3.xml",
		}
		*若某项不需要可忽略.
	准备好对应的材质文件, 置于hudatlas所指定的位置并照之命名.
	接着在gunutils段中使用SetHudImage函数:
		inst.components.gunutils:SetHudImage(hudatlas, hudimage)
[构建弹药Prefab]
	确认子弹弹头(发射物)的prefab中具有自毁机制并已添加以下component:
		weapon, projectile
	确认弹药的prefab中已添加以下component:
		inspectable, inventoryitem
	添加component: gunammo, 并指定基本属性.
	GunAmmo类的主要方法: ([R]表示Client可用, *表示为必需项)
		·GetMaxValue()[R]
			获取弹药容器最大弹量.
		·GetValue()[R]
			获取弹药包含弹量.
		·SetMaxValue((int)val)*
			指定弹药容器最大弹量. 除单发填弹的霰弹枪外, 此值应与弹药包含弹量一致.
		·SetValue((int)val)*
			指定弹药包含弹量. 对单发填弹的霰弹枪, 此值为1.
		·SetInterval((int)val)*
			指定弹药的上弹时间, 默认为2.
		·GetType()
			获取弹药类型.
		·SetType((string)val)*
			指定弹药类型, 必须为TUNING.MGUNAMMOTYPES的子项.
		·GetBullet()
			获取弹药内的子弹弹头prefab.
		·SetBullet((string)val)*
			指定弹药内的子弹弹头prefab.
		·SetRecyclable((bool)val)
			指定弹药在换弹时是否可被回收.
		·SetDecomposable((bool)val)[R]
			指定弹药是否可以分解成子弹(物品).
		·GetGunBullets()[R]
			获取弹药内的子弹(物品)的prefab名.
		·SetGunBullets((string)val)* - 当存在SetDecomposable(true)时
			指定弹药内的子弹(物品), 须为子弹(物品)的prefab名.
		·GetDamage()
			获取弹药内单发子弹伤害.
		·SetDamage((float)val)*
			指定弹药内单发子弹伤害, 须与子弹prefab内指定的一致.
		·SetOnLoadedFn((function(inst, tgt))fn)
			指定一个函数在弹药被装入时执行.
		·SetOnRefilledFn((function(inst, tgt))fn)
			指定一个函数在装入子弹时执行.
	*若不需要子弹(物品)则以下部分可忽略
	确认子弹(物品)的prefab中已添加以下component:
		inspectable, inventoryitem
	添加component: gunammo, 并指定基本属性.
	GunBullets类的主要方法: (*表示为必需项)
		·SetInterval((int)val)*
			指定子弹的上弹时间, 默认为0.5.
		·GetBullet()
			获取子弹弹头prefab.
		·SetBullet((string)val)*
			指定子弹弹头prefab, 须与弹药prefab内指定的一致.
		·GetBulletType()
			获取子弹(物品)类型, 必须为TUNING.MGUNBULLETTYPES的子项.
		·SetBulletType((string)val)*
			指定子弹(物品)类型, 必须为TUNING.MGUNBULLETTYPES的子项.
		·GetDamage()
			获取单发子弹伤害.
		·SetDamage((float)val)*
			指定单发子弹伤害, 须与子弹prefab内指定的一致.
		·SetOnLoadedFn((function(inst, tgt))fn)
			指定一个函数在子弹装入时执行.
