/datum/loot_tier
	var/name
	var/open_time = 5 SECONDS
	var/list/loot_list
	var/loot_count
	var/modules_spawn_chance = 0

/datum/loot_tier/proc/on_start_open(mob/user, obj/structure/crate, list/current_loot = loot_list)
	if(!istype(crate))
		return

	for(var/i in 1 to loot_count)
		var/list/loot = safepick(current_loot)
		if(!islist(loot))
			loot = list(loot)
		for(var/loot_item in loot)
			new loot_item(crate)

	if(!prob(modules_spawn_chance))
		return

	new /obj/item/storage/box/syndie_kit/gun_mods/super(crate)

/datum/loot_tier/first
	name = "снаряжение зеленого кода"
	modules_spawn_chance = 1
	loot_count = 3
	loot_list = list(
		/obj/item/gun/energy/taser,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/laser/retro,
		/obj/item/gun/energy/emittergun,
		/obj/item/gun/energy/gun/mini,
		/obj/item/gun/energy/gun/advtaser,
		/obj/item/gun/energy/e_gun/old,
		list(
			/obj/item/gun/projectile/automatic/lr30,
			/obj/item/ammo_box/magazine/lr30mag,
			/obj/item/ammo_box/magazine/lr30mag,
			/obj/item/ammo_box/magazine/lr30mag,
		),
		list(
			/obj/item/gun/projectile/revolver/doublebarrel/improvised,
			/obj/item/ammo_box/shotgun/buck,
			/obj/item/ammo_box/speedloader/shotgun,
		),
		list(
			/obj/item/gun/projectile/automatic/pistol/enforcer,
			/obj/item/ammo_box/magazine/enforcer/lethal,
			/obj/item/ammo_box/magazine/enforcer/lethal,
			/obj/item/ammo_box/magazine/enforcer/lethal,
		),
		/obj/item/storage/box/thunderdome/crossbow,
		/obj/item/twohanded/spear,
		/obj/item/melee/baton/telescopic,
		/obj/item/clothing/gloves/boxing,
		/obj/item/twohanded/bostaff,
		/obj/item/twohanded/garrote,
		/obj/item/twohanded/spear/plasma,
		/obj/item/reagent_containers/spray/pestspray,
		/obj/item/dnainjector/runfast,
		list(
			/obj/item/clothing/suit/armor/vest/security,
			/obj/item/clothing/head/helmet,
		),
		list(
			/obj/item/clothing/suit/armor/vest/security,
			/obj/item/clothing/head/helmet,
		),
		/obj/item/clothing/suit/armor/vest/blueshield,
		/obj/item/clothing/suit/armor/vest/bloody,
		/obj/item/clothing/suit/armor/secjacket,
		/obj/item/clothing/suit/armor/hos,
		/obj/item/clothing/suit/armor/hos/alt,
		/obj/item/clothing/suit/armor/hos/jensen,
		/obj/item/clothing/suit/armor/vest/warden,
		/obj/item/clothing/suit/armor/vest/warden/alt,
		/obj/item/clothing/suit/armor/vest/det_suit,
		/obj/item/clothing/suit/storage/lawyer/blackjacket/armored,
		)

/datum/loot_tier/second
	name = "снаряжение синего кода"
	modules_spawn_chance = 20
	open_time = 7 SECONDS
	loot_count = 3
	loot_list = list(
		/obj/item/gun/energy/immolator,
		/obj/item/gun/energy/gun/hos,
		/obj/item/gun/energy/mindflayer,
		/obj/item/gun/energy/gun,
		/obj/item/gun/energy/shock_revolver,
		/obj/item/gun/energy/laser/scatter,
		/obj/item/gun/energy/laser,
		/obj/item/gun/energy/emittercannon,
		/obj/item/gun/energy/dominator,
		/obj/item/gun/energy/plasma_pistol,
		/obj/item/gun/energy/kinetic_accelerator/crossbow/toy,
		/obj/item/gun/energy/decloner,
		/obj/item/gun/energy/lasercannon,
		/obj/item/gun/energy/xray,
		list(
			/obj/item/gun/projectile/automatic/pistol/specter,
			/obj/item/ammo_box/magazine/specter,
			/obj/item/ammo_box/magazine/specter,
			/obj/item/ammo_box/magazine/specter,
		),
		list(
			/obj/item/gun/projectile/revolver/ga12,
			/obj/item/ammo_box/shotgun/buck,
			/obj/item/ammo_box/shotgun/buck,
			/obj/item/ammo_box/speedloader/shotgun,
		),
		list(
			/obj/item/gun/projectile/automatic/rusted/ppsh,
			/obj/item/ammo_box/magazine/ppsh,
			/obj/item/ammo_box/magazine/ppsh,
		),
		list(
			/obj/item/gun/projectile/automatic/pistol/sp8/sp8t,
			/obj/item/ammo_box/magazine/sp8,
			/obj/item/ammo_box/magazine/sp8,
			/obj/item/ammo_box/magazine/sp8,
		),
		list(
			/obj/item/gun/projectile/shotgun/lethal,
			/obj/item/ammo_box/shotgun,
			/obj/item/ammo_box/shotgun/buck,
			/obj/item/ammo_box/speedloader/shotgun,
		),
		list(
			/obj/item/gun/projectile/automatic/pistol,
			/obj/item/ammo_box/magazine/m10mm,
			/obj/item/ammo_box/magazine/m10mm,
			/obj/item/ammo_box/magazine/m10mm,
		),
		list(
			/obj/item/gun/projectile/automatic/lasercarbine,
			/obj/item/ammo_box/magazine/laser,
			/obj/item/ammo_box/magazine/laser,
			/obj/item/ammo_box/magazine/laser,
		),
		list(
			/obj/item/gun/projectile/revolver/doublebarrel,
			/obj/item/ammo_box/shotgun/buck,
			/obj/item/ammo_box/speedloader/shotgun,
		),
		list(
			/obj/item/gun/projectile/automatic/pistol/sp8/sp8ar,
			/obj/item/ammo_box/magazine/sp8,
			/obj/item/ammo_box/magazine/sp8,
			/obj/item/ammo_box/magazine/sp8,
		),
		list(
			/obj/item/gun/projectile/automatic/c20r/toy/riot,
			/obj/item/ammo_box/magazine/toy/smgm45/riot,
			/obj/item/ammo_box/magazine/toy/smgm45/riot,
			/obj/item/ammo_box/magazine/toy/smgm45/riot,
		),
		list(
			/obj/item/gun/projectile/automatic/pistol/sp8,
			/obj/item/ammo_box/magazine/sp8,
			/obj/item/ammo_box/magazine/sp8,
			/obj/item/ammo_box/magazine/sp8,
		),
		list(
			/obj/item/gun/projectile/shotgun/riot/short,
			/obj/item/ammo_box/shotgun,
			/obj/item/ammo_box/shotgun/buck,
			/obj/item/ammo_box/speedloader/shotgun,
		),
		list(
			/obj/item/gun/projectile/automatic/pistol/m1911,
			/obj/item/ammo_box/magazine/m45,
			/obj/item/ammo_box/magazine/m45,
			/obj/item/ammo_box/magazine/m45,
		),
		list(
			/obj/item/gun/projectile/shotgun/riot,
			/obj/item/ammo_box/shotgun,
			/obj/item/ammo_box/shotgun/buck,
			/obj/item/ammo_box/speedloader/shotgun,
		),
		list(
			/obj/item/gun/projectile/automatic/proto,
			/obj/item/ammo_box/magazine/smgm9mm,
			/obj/item/ammo_box/magazine/smgm9mm,
			/obj/item/ammo_box/magazine/smgm9mm,
		),
		/obj/item/gun/syringe/rapidsyringe/experimental/preloaded,
		/obj/item/storage/belt/security/judobelt,
		/obj/item/twohanded/spear/bonespear/chitinspear,
		/obj/item/twohanded/bamboospear,
		/obj/item/fauna_bomb/preloaded/t3,
		/obj/item/kitchen/knife/butcher/sharped,
		/obj/item/melee/baton/security/loaded,
		/obj/item/melee/energy/blade,
		/obj/item/twohanded/sechammer,
		/obj/item/twohanded/spear/bonespear,
		/obj/item/twohanded/chainsaw_handmade,
		/obj/item/melee/baseball_bat/ablative,
		/obj/item/mr_chang_technique,
		/obj/item/twohanded/fireaxe/boneaxe,
		/obj/item/twohanded/fireaxe,
		/obj/item/dnainjector/nobreath,
		/obj/item/dnainjector/telemut,
		/obj/item/clothing/suit/armor/vest/capcarapace,
		/obj/item/clothing/suit/armor/vest/capcarapace/alt,
		/obj/item/clothing/suit/armor/laserproof,
		list(
			/obj/item/clothing/head/helmet/ert/security,
			/obj/item/clothing/suit/armor/vest/ert/security,
			/obj/item/clothing/gloves/combat/swat,
			/obj/item/clothing/shoes/combat,
		),
	)

/datum/loot_tier/third
	name = "снаряжение красного кода"
	modules_spawn_chance = 30
	open_time = 15 SECONDS
	loot_count = 3
	loot_list = list(
		/obj/item/gun/energy/immolator/multi,
		/obj/item/gun/energy/gun/nuclear,
		/obj/item/gun/energy/laser/captain/scattershot,
		/obj/item/gun/energy/kinetic_accelerator/crossbow/large,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/sniperrifle/pod_pilot,
		list(
			/obj/item/gun/projectile/automatic/c20r,
			/obj/item/ammo_box/magazine/smgm45,
			/obj/item/ammo_box/magazine/smgm45,
			/obj/item/ammo_box/magazine/smgm45,
		),
		list(
			/obj/item/gun/projectile/automatic/wt550,
			/obj/item/ammo_box/magazine/wt550m9,
			/obj/item/ammo_box/magazine/wt550m9,
			/obj/item/ammo_box/magazine/wt550m9,
		),
		list(
			/obj/item/gun/projectile/automatic/sfg,
			/obj/item/ammo_box/magazine/sfg9mm,
			/obj/item/ammo_box/magazine/sfg9mm,
			/obj/item/ammo_box/magazine/sfg9mm,
		),
		list(
			/obj/item/gun/projectile/shotgun/automatic/combat,
			/obj/item/ammo_box/shotgun,
			/obj/item/ammo_box/shotgun/buck,
			/obj/item/ammo_box/speedloader/shotgun,
		),
		list(
			/obj/item/gun/rocketlauncher,
			/obj/item/ammo_casing/rocket,
			/obj/item/ammo_casing/rocket,
			/obj/item/ammo_casing/rocket,
		),
		list(
			/obj/item/gun/projectile/shotgun/boltaction,
			/obj/item/ammo_box/speedloader/a762,
			/obj/item/ammo_box/speedloader/a762,
		),
		list(
			/obj/item/gun/projectile/automatic/l6_saw/toy/riot,
			/obj/item/ammo_box/magazine/toy/m762/riot,
			/obj/item/ammo_box/magazine/toy/m762/riot,
		),
		list(
			/obj/item/gun/projectile/shotgun/automatic/dual_tube,
			/obj/item/ammo_box/shotgun,
			/obj/item/ammo_box/shotgun/buck,
			/obj/item/ammo_box/speedloader/shotgun,
		),
		list(
			/obj/item/gun/projectile/automatic/rusted/aksu,
			/obj/item/ammo_box/magazine/aksu,
			/obj/item/ammo_box/magazine/aksu,
			/obj/item/ammo_box/magazine/aksu,
		),
		list(
			/obj/item/gun/projectile/automatic/shotgun/bulldog,
			/obj/item/ammo_box/magazine/m12g/XtrLrg/slug,
			/obj/item/ammo_box/magazine/m12g/XtrLrg/slug,
			/obj/item/ammo_box/magazine/m12g,
		),
		list(
			/obj/item/gun/projectile/automatic/pistol/deagle/gold,
			/obj/item/ammo_box/magazine/m50,
			/obj/item/ammo_box/magazine/m50,
			/obj/item/ammo_box/magazine/m50,
		),
		list(
			/obj/item/gun/projectile/bombarda,
			/obj/item/ammo_casing/a40mm/improvised/exp_shell,
			/obj/item/ammo_casing/a40mm/improvised/exp_shell,
			/obj/item/ammo_casing/a40mm/improvised/flame_shell,
			/obj/item/ammo_casing/a40mm/improvised/flame_shell,
			/obj/item/ammo_casing/a40mm/improvised/smoke_shell,
			/obj/item/ammo_casing/a40mm/improvised/smoke_shell,
		),
		list(
			/obj/item/gun/projectile/revolver/golden,
			/obj/item/ammo_box/speedloader/a357,
			/obj/item/ammo_box/speedloader/a357,
			/obj/item/ammo_box/speedloader/a357,
		),
		list(
			/obj/item/gun/projectile/bombarda/secgl/m79,
			/obj/item/ammo_casing/a40mm,
			/obj/item/ammo_casing/a40mm,
			/obj/item/ammo_casing/a40mm/secgl/solid,
			/obj/item/ammo_casing/a40mm/secgl/solid,
			/obj/item/ammo_casing/a40mm/secgl/flash,
			/obj/item/ammo_casing/a40mm/secgl/gas,
		),
		list(
			/obj/item/gun/projectile/automatic/pistol/deagle,
			/obj/item/ammo_box/magazine/m50,
			/obj/item/ammo_box/magazine/m50,
			/obj/item/ammo_box/magazine/m50,
		),
		list(
			/obj/item/gun/projectile/revolver/mateba,
			/obj/item/ammo_box/speedloader/a357,
			/obj/item/ammo_box/speedloader/a357,
			/obj/item/ammo_box/speedloader/a357,
		),
		list(
			/obj/item/gun/projectile/automatic/pistol/APS,
			/obj/item/ammo_box/magazine/pistolm9mm,
			/obj/item/ammo_box/magazine/pistolm9mm,
			/obj/item/ammo_box/magazine/pistolm9mm,
		),
		list(
			/obj/item/gun/projectile/revolver,
			/obj/item/ammo_box/speedloader/a357,
			/obj/item/ammo_box/speedloader/a357,
			/obj/item/ammo_box/speedloader/a357,
		),
		list(
			/obj/item/gun/projectile/revolver/nagant,
			/obj/item/ammo_box/speedloader/n762,
			/obj/item/ammo_box/speedloader/n762,
			/obj/item/ammo_box/speedloader/n762,
		),
		list(
			/obj/item/gun/projectile/bombarda/secgl,
			/obj/item/ammo_casing/a40mm,
			/obj/item/ammo_casing/a40mm,
			/obj/item/ammo_casing/a40mm/secgl/solid,
			/obj/item/ammo_casing/a40mm/secgl/solid,
			/obj/item/ammo_casing/a40mm/secgl/flash,
			/obj/item/ammo_casing/a40mm/secgl/gas,
		),
		list(
			/obj/item/gun/projectile/automatic/pistol/deagle/camo,
			/obj/item/ammo_box/magazine/m50,
			/obj/item/ammo_box/magazine/m50,
			/obj/item/ammo_box/magazine/m50,
		),
		list(
			/obj/item/gun/projectile/automatic/sp91rc,
			/obj/item/ammo_box/magazine/sp91rc,
			/obj/item/ammo_box/magazine/sp91rc,
			/obj/item/ammo_box/magazine/sp91rc,
		),
		/obj/item/shield/energy,
		/obj/item/twohanded/spear/grey_tide,
		/obj/item/kitchen/knife/ghostface_knife/devil,
		/obj/item/melee/ghost_sword,
		/obj/item/shield/riot/buckler,
		/obj/item/storage/belt/champion/wrestling,
		/obj/item/shield/riot/roman,
		/obj/item/storage/box/syndie_kit/commando_kit,
		/obj/item/shield/riot,
		/obj/item/melee/rapier/captain,
		/obj/item/kitchen/knife/butcher/meatcleaver,
		/obj/item/melee/rapier/syndie,
		/obj/item/shield/riot/tele,
		/obj/item/kitchen/knife/combat,
		/obj/item/shield/riot/goliath,
		/obj/item/twohanded/spear/bonespear/her_biting_embrace,
		/obj/item/shield/energy/syndie,
		/obj/item/melee/energy/sword/pirate,
		/obj/item/melee/energy/sword/saber,
		/obj/item/weldingtool/sword,
		/obj/item/dnainjector/hulkmut,
		/obj/item/dnainjector/farvisionmut,
		/obj/item/relict_production/strange_teleporter,
		/obj/item/clothing/suit/space/hardsuit/syndi,
		/obj/item/clothing/suit/space/hardsuit/contractor,
		/obj/item/clothing/suit/space/hardsuit/contractor/agent,
		/obj/item/clothing/suit/space/hardsuit/syndi/freedom,
		/obj/item/clothing/suit/space/hardsuit/ert/security,
		/obj/item/clothing/suit/space/hardsuit/ert/solgov,
		/obj/item/clothing/suit/space/hardsuit/soviet,
		/obj/item/clothing/suit/space/hardsuit/singuloth,
		list(
			/obj/item/clothing/suit/armor/bulletproof,
			/obj/item/clothing/head/helmet/alt,
			/obj/item/clothing/gloves/color/black/ballistic,
			/obj/item/clothing/shoes/jackboots/armored,
		),
		list(
			/obj/item/clothing/head/helmet/riot,
			/obj/item/clothing/suit/armor/riot,
			/obj/item/clothing/gloves/combat/riot,
			/obj/item/clothing/shoes/combat/riot,
		),
		list(
			/obj/item/clothing/head/helmet/reflector,
			/obj/item/clothing/suit/armor/reflector,
			/obj/item/clothing/gloves/reflector,
			/obj/item/clothing/shoes/reflector,
		),
		/obj/item/clothing/suit/hooded/drake,
	)

/datum/loot_tier/fourth
	name = "снаряжение кода ГАММА"
	modules_spawn_chance = 40
	open_time = 20 SECONDS
	loot_count = 6
	loot_list = list(
		/obj/item/gun/energy/gun/minigun,
		/obj/item/gun/energy/sniperrifle,
		/obj/item/gun/energy/telegun,
		/obj/item/gun/energy/kinetic_accelerator/crossbow,
		list(
			/obj/item/gun/projectile/automatic/ar,
			/obj/item/ammo_box/magazine/m556,
			/obj/item/ammo_box/magazine/m556,
			/obj/item/ammo_box/magazine/m556,
		),
		list(
			/obj/item/gun/projectile/automatic/sniper_rifle/toy,
			/obj/item/ammo_box/magazine/toy/sniper_rounds,
			/obj/item/ammo_box/magazine/toy/sniper_rounds,
		),
		list(
			/obj/item/gun/projectile/automatic/ak814,
			/obj/item/ammo_box/magazine/ak814,
			/obj/item/ammo_box/magazine/ak814,
			/obj/item/ammo_box/magazine/ak814,
		),
		list(
			/obj/item/gun/projectile/bombarda/secgl/x4,
			/obj/item/ammo_casing/a40mm,
			/obj/item/ammo_casing/a40mm,
			/obj/item/ammo_casing/a40mm,
			/obj/item/ammo_casing/a40mm,
			/obj/item/ammo_casing/a40mm/secgl/solid,
			/obj/item/ammo_casing/a40mm/secgl/solid,
			/obj/item/ammo_casing/a40mm/secgl/solid,
			/obj/item/ammo_casing/a40mm/secgl/solid,
			/obj/item/ammo_casing/a40mm/secgl/flash,
			/obj/item/ammo_casing/a40mm/secgl/flash,
			/obj/item/ammo_casing/a40mm/secgl/flash,
			/obj/item/ammo_casing/a40mm/secgl/flash,
			/obj/item/ammo_casing/a40mm/secgl/gas,
			/obj/item/ammo_casing/a40mm/secgl/gas,
			/obj/item/ammo_casing/a40mm/secgl/gas,
			/obj/item/ammo_casing/a40mm/secgl/gas,
		),
		list(
			/obj/item/gun/projectile/automatic/m90,
			/obj/item/ammo_box/magazine/m556,
			/obj/item/ammo_box/magazine/m556,
			/obj/item/ammo_box/magazine/m556,
			/obj/item/ammo_casing/a40mm,
		),
		list(
			/obj/item/gun/projectile/automatic/tommygun,
			/obj/item/ammo_box/magazine/tommygunm45,
			/obj/item/ammo_box/magazine/tommygunm45,
			/obj/item/ammo_box/magazine/tommygunm45,
		),
		list(
			/obj/item/gun/projectile/automatic/l6_saw,
			/obj/item/ammo_box/magazine/a762x51,
			/obj/item/ammo_box/magazine/a762x51,
			/obj/item/ammo_box/magazine/a762x51,
		),
		list(
			/obj/item/gun/projectile/automatic/m52,
			/obj/item/ammo_box/magazine/m52mag,
			/obj/item/ammo_box/magazine/m52mag,
			/obj/item/ammo_box/magazine/m52mag,
		),
		list(
			/obj/item/gun/projectile/automatic/sniper_rifle/syndicate/penetrator,
			/obj/item/ammo_box/magazine/sniper_rounds/compact,
			/obj/item/ammo_box/magazine/sniper_rounds/compact,
		),
		list(
			/obj/item/gun/projectile/automatic/cats,
			/obj/item/ammo_box/magazine/cats12g,
			/obj/item/ammo_box/magazine/cats12g/large,
			/obj/item/ammo_box/magazine/cats12g/large,
		),
		list(
			/obj/item/gun/projectile/automatic/sniper_rifle/compact,
			/obj/item/ammo_box/magazine/sniper_rounds/compact,
			/obj/item/ammo_box/magazine/sniper_rounds/compact,
		),
		list(
			/obj/item/gun/projectile/bombarda/bombplet,
			/obj/item/ammo_casing/a40mm/improvised/exp_shell,
			/obj/item/ammo_casing/a40mm/improvised/exp_shell,
			/obj/item/ammo_casing/a40mm/improvised/flame_shell,
			/obj/item/ammo_casing/a40mm/improvised/flame_shell,
			/obj/item/ammo_casing/a40mm/improvised/smoke_shell,
			/obj/item/ammo_casing/a40mm/improvised/smoke_shell,
		),
		/obj/item/CQC_manual,
		/obj/item/mimejutsu_scroll,
		/obj/item/storage/box/syndie_kit/mantisblade,
		/obj/item/twohanded/dualsaber,
		/obj/item/weldingtool/sword/double,
		/obj/item/storage/box/syndie_kit/teleporter,
		/obj/item/dnainjector/regenerate,
		/obj/item/clothing/suit/armor/centcomm,
		/obj/item/clothing/suit/armor/heavy,
		/obj/item/clothing/suit/space/hardsuit/syndi/elite,
		/obj/item/clothing/suit/space/hardsuit/syndi/shielded,
		/obj/item/clothing/suit/space/hardsuit/ert/gamma/security,
		/obj/item/clothing/suit/space/hardsuit/soviet/commander,
		/obj/item/clothing/suit/space/hardsuit/ert/solgov/command,
		/obj/item/clothing/suit/space/hardsuit/champion/templar,
		/obj/item/clothing/suit/space/hardsuit/champion,
		/obj/item/clothing/suit/space/hardsuit/champion/inquisitor,
		/obj/item/clothing/suit/space/hardsuit/syndi/elite/med,
		/obj/item/clothing/suit/space/hardsuit/syndi/elite/comms
	)

/datum/loot_tier/fifth
	name = "снаряжение кода ЭПСИЛОН"
	modules_spawn_chance = 70
	open_time = 30 SECONDS
	loot_count = 6
	loot_list = list(
		/obj/item/gun/energy/pulse/pistol,
		/obj/item/gun/energy/bsg/prebuilt,
		list(
			/obj/item/gun/projectile/automatic/shotgun/minotaur,
			/obj/item/ammo_box/magazine/m12g/XtrLrg/slug,
			/obj/item/ammo_box/magazine/m12g/XtrLrg/slug,
			/obj/item/ammo_box/magazine/m12g,
		),
		list(
			/obj/item/gun/projectile/automatic/gyropistol,
			/obj/item/ammo_box/magazine/m75,
			/obj/item/ammo_box/magazine/m75,
		),
		list(
			/obj/item/gun/projectile/automatic/sniper_rifle/axmc,
			/obj/item/ammo_box/magazine/a338,
			/obj/item/ammo_box/magazine/a338,
		),
		list(
			/obj/item/gun/projectile/revolver/rocketlauncher,
			/obj/item/ammo_casing/caseless/rocket/hedp,
			/obj/item/ammo_casing/caseless/rocket/hedp,
			/obj/item/ammo_casing/caseless/rocket,
			/obj/item/ammo_casing/caseless/rocket,
		),
		/obj/item/twohanded/singularityhammer,
		/obj/item/twohanded/mjollnir,
		/obj/item/twohanded/fireaxe/energized,
		/obj/item/plasma_fist_scroll,
		/obj/item/twohanded/knighthammer,
		/obj/item/twohanded/chainsaw,
		list(
			/obj/item/melee/baton/telescopic/contractor,
			/obj/item/baton_upgrade/cuff,
			/obj/item/baton_upgrade/mute,
			/obj/item/baton_upgrade/focus,
			/obj/item/baton_upgrade/antidrop,
		),
		/obj/item/reagent_containers/hypospray/autoinjector/stimulants,
		/obj/item/dnainjector/xraymut,
		/obj/item/storage/firstaid/tactical,
		/obj/item/clothing/suit/space/hardsuit/deathsquad,
		/obj/item/clothing/suit/space/hardsuit/syndi/elite/sst,
	)

/datum/loot_tier/ammo
	name = "Патроны"
	loot_count = 6
	loot_list = list(
		CALIBER_9MM = list(
			/obj/item/ammo_box/c9mm,
			/obj/item/ammo_box/rubber9mm,
		),
		CALIBER_9MM_TE = list(
			/obj/item/ammo_box/c9mmte,
		),
		CALIBER_DOT_357 = list(
			/obj/item/ammo_box/a357,
		),
		CALIBER_40NR = list(
			/obj/item/ammo_box/fortynr,
		),
		CALIBER_7_DOT_62X54MM = list(
			/obj/item/ammo_box/a762,
		),
		CALIBER_7_DOT_62X51MM = list(
			/obj/item/ammo_box/a762x51,
			/obj/item/ammo_box/a762x51/weak,
			/obj/item/ammo_box/a762x51/bleeding,
			/obj/item/ammo_box/a762x51/ap,
			/obj/item/ammo_box/a762x51/incen,
			/obj/item/ammo_box/a762x51/hollow,
		),
		CALIBER_7_DOT_62X25MM = list(
			/obj/item/ammo_box/a762x25,
		),
		CALIBER_7_DOT_62X38MM = list(
			/obj/item/ammo_box/n762,
			/obj/item/ammo_box/nagant,
		),
		CALIBER_DOT_338 = list(
			/obj/item/ammo_box/a338,
			/obj/item/ammo_box/a338/penetrator,
			/obj/item/ammo_box/a338/explosive,
		),
		CALIBER_DOT_50L = list(
			/obj/item/ammo_box/sniper_rounds_compact,
			/obj/item/ammo_box/sniper_rounds_compact/penetrator,
		),
		CALIBER_DOT_50AE = list(
			/obj/item/ammo_box/m50,
		),
		CALIBER_10MM = list(
			/obj/item/ammo_box/c10mm,
			/obj/item/ammo_box/m10mm,
			/obj/item/ammo_box/m10mm/ap,
			/obj/item/ammo_box/m10mm/hp,
			/obj/item/ammo_box/m10mm/fire,
		),
		CALIBER_4_DOT_6X30MM = list(
			/obj/item/ammo_box/c46x30mm,
			/obj/item/ammo_box/ap46x30mm,
			/obj/item/ammo_box/tox46x30mm,
			/obj/item/ammo_box/inc46x30mm,
		),
		CALIBER_DOT_45 = list(
			/obj/item/ammo_box/c45,
			/obj/item/ammo_box/c45/ext,
			/obj/item/ammo_box/rubber45,
			/obj/item/ammo_box/rubber45/ext,
		),
		CALIBER_84MM = list(
			/obj/item/ammo_casing/caseless/rocket,
			/obj/item/ammo_casing/caseless/rocket/hedp,
		),
		CALIBER_12X70 = list(
			/obj/item/ammo_box/shotgun,
			/obj/item/ammo_box/shotgun/buck,
			/obj/item/ammo_box/shotgun/buck/assassination,
			/obj/item/ammo_box/shotgun/buck/magnum,
			/obj/item/ammo_box/shotgun/rubbershot,
			/obj/item/ammo_box/shotgun/beanbag,
			/obj/item/ammo_box/shotgun/stunslug,
			/obj/item/ammo_box/shotgun/pulseslug,
			/obj/item/ammo_box/shotgun/incendiary,
			/obj/item/ammo_box/shotgun/dragonsbreath,
			/obj/item/ammo_box/shotgun/dragonsbreath/napalm,
			/obj/item/ammo_box/shotgun/laserslug,
			/obj/item/ammo_box/shotgun/lasershot,
			/obj/item/ammo_box/shotgun/flechette,
			/obj/item/ammo_box/shotgun/improvised,
		),
		CALIBER_SPECTER = list(
			/obj/item/ammo_box/specter/laser,
			/obj/item/ammo_box/specter/disabler,
		),
		CALIBER_5_DOT_56X45MM = list(
			/obj/item/ammo_box/a556,
		),
		CALIBER_5_DOT_45X39MM = list(
			/obj/item/ammo_box/ak814/fusty,
			/obj/item/ammo_box/ak814,
		),
		CALIBER_ROCKET = list(
			/obj/item/ammo_casing/rocket,
		),
		CALIBER_DOT_75 = list(
			/obj/item/ammo_box/a75,
		),
		CALIBER_40MM = list(
			/obj/item/ammo_box/a40mm,
			/obj/item/ammo_box/secgl/exp,
			/obj/item/ammo_box/secgl/gas,
			/obj/item/ammo_box/secgl/flash,
			/obj/item/ammo_box/secgl/solid,
		),
		CALIBER_FOAM_FORCE = list(
			/obj/item/ammo_box/foambox/riot,
		),
		CALIBER_FOAM_FORCE_SNIPER = list(
			/obj/item/ammo_box/foambox/sniper/riot,
		),
		CALIBER_LASER = list(
			/obj/item/ammo_box/laserammobox,
		),
		FAKE_CALIBER_40MM_IMP = list(
			/obj/item/ammo_casing/a40mm/improvised/exp_shell,
			/obj/item/ammo_casing/a40mm/improvised/flame_shell,
			/obj/item/ammo_casing/a40mm/improvised/smoke_shell,
		),
		FAKE_CALIBER_80MM_MORTAR = list(
			/obj/item/mortar_shell/he,
			/obj/item/mortar_shell/frag,
			/obj/item/mortar_shell/incendiary,
			/obj/item/mortar_shell/flare,
		)
	)

/datum/loot_tier/ammo/on_start_open(mob/user, obj/structure/crate, list/current_loot = loot_list)

	if(!istype(user))
		return

	current_loot = tgui_input_list(user, "Выберите калибр", "Выбор калибра", loot_list)
	if(!current_loot)
		return

	. = ..(user, crate, loot_list[current_loot])

/datum/loot_tier/medical
	name = "Медикаменты"
	loot_count = 8
	loot_list = list(
		/obj/item/storage/firstaid/fire,
		list(
			/obj/item/storage/firstaid/regular,
			///obj/item/stack/medical/suture,
		),
		/obj/item/storage/firstaid/toxin,
		/obj/item/storage/firstaid/doctor/mining_medic,
		/obj/item/storage/firstaid/doctor,
		/obj/item/storage/firstaid/o2,
		/obj/item/storage/firstaid/brute,
		/obj/item/storage/firstaid/adv,
		/obj/item/storage/firstaid/paramed,
		/obj/item/storage/firstaid/ertm,
		list(
			/obj/item/storage/firstaid/ancient,
			///obj/item/stack/medical/suture,
		),
		/obj/item/storage/firstaid/surgery,
		list(
			/obj/item/scalpel/laser/manager,
			/obj/item/roller/holo,
		),
		list(
			/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis,
			/obj/item/reagent_containers/iv_bag/slime,
			/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis,
		),
		/obj/item/reagent_containers/glass/bottle/morphine,
		/obj/item/reagent_containers/glass/bottle/potassium_iodide,
		/*list(
			/obj/item/stack/medical/bruise_pack/military,
			/obj/item/stack/medical/suture/advanced,
		),*/
		/obj/item/reagent_containers/glass/bottle/abductor/rezadone,
		list(
			/obj/item/handheld_defibrillator/syndie,
			/obj/item/defibrillator/compact/combat/loaded
		),
		/obj/item/reagent_containers/hypospray/autoinjector/nanocalcium,
		list(
			/obj/item/organ/internal/cyberimp/arm/surgery,
			/obj/item/organ/internal/cyberimp/arm/medibeam,
			/obj/item/autoimplanter/oneuse,
			/obj/item/autoimplanter/oneuse,
			/obj/item/screwdriver,
		),
	)
