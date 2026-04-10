/**
 * MARK: Suppressor
 */
/obj/item/gun_module/muzzle
	slot = ATTACHMENT_SLOT_MUZZLE

/obj/item/gun_module/muzzle/suppressor
	name = "suppressor"
	desc = "Глушитель, совместимый с широким диапазоном огнестрельного оружия. Существенно снижает шум, производимый при выстреле."
	icon_state = "supp"
	item_state = "supp"
	overlay_state = "supp_o"
	overlay_offset = list("x" = -1, "y" = 0)
	class = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_SNIPER_MUZZLE
	var/oldsound
	var/initial_w_class

/obj/item/gun_module/muzzle/suppressor/get_ru_names()
	return list(
		NOMINATIVE = "универсальный глушитель",
		GENITIVE = "универсального глушителя",
		DATIVE = "универсальному глушителю",
		ACCUSATIVE = "универсальный глушитель",
		INSTRUMENTAL = "универсальным глушителем",
		PREPOSITIONAL = "универсальном глушителе",
	)

/obj/item/gun_module/muzzle/suppressor/integrated
	can_detach = FALSE

/obj/item/gun_module/muzzle/suppressor/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.suppressed = TRUE
	target_gun.suppress_muzzle_flash = TRUE
	oldsound = target_gun.fire_sound
	initial_w_class = target_gun.w_class
	target_gun.fire_sound = 'sound/weapons/gunshots/1suppres.ogg'
	if(target_gun.w_class < WEIGHT_CLASS_NORMAL)
		target_gun.w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun_module/muzzle/suppressor/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.suppressed = FALSE
	target_gun.suppress_muzzle_flash = FALSE
	target_gun.fire_sound = oldsound
	target_gun.w_class = initial_w_class

/obj/item/gun_module/muzzle/suppressor/shotgun
	name = "shotgun suppressor"
	desc = "Тяжёлый квадратный глушитель, предназначенный для дробовиков и ружей, позволяет значительно снизить шум от выстрелов и интенсивность вспышки."
	icon_state = "suppshotgun"
	overlay_state = "suppshotgun_o"
	class = GUN_MODULE_CLASS_SHOTGUN_MUZZLE

/obj/item/gun_module/muzzle/suppressor/shotgun/get_ru_names()
	return list(
		NOMINATIVE = "ружейный глушитель",
		GENITIVE = "ружейного глушителя",
		DATIVE = "ружейному глушителю",
		ACCUSATIVE = "ружейный глушитель",
		INSTRUMENTAL = "ружейным глушителем",
		PREPOSITIONAL = "ружейном глушителе"
	)

/obj/item/gun_module/muzzle/suppressor/heavy
	name = "heavy suppressor"
	desc = "Массивный глушитель, предназначенный для крупнокалиберных винтовок, снижает шум выстрелов и интенсивность вспышки."
	icon_state = "suppheavy"
	overlay_state = "suppheavy_o"
	class = GUN_MODULE_CLASS_SNIPER_MUZZLE

/obj/item/gun_module/muzzle/suppressor/heavy/get_ru_names()
	return list(
		NOMINATIVE = "тяжёлый глушитель",
		GENITIVE = "тяжёлого глушителя",
		DATIVE = "тяжёлому глушителю",
		ACCUSATIVE = "тяжёлый глушитель",
		INSTRUMENTAL = "тяжёлым глушителем",
		PREPOSITIONAL = "тяжёлом глушителе"
	)

/obj/item/gun_module/muzzle/suppressor/handmade
	name = "handmade suppressor"
	desc = "Сделан из банки, скотча и куска металла. Неплохо глушит звук выстрела, но может в любой момент развалиться на части."
	icon_state = null
	base_icon_state = "handmade_supp_"
	overlay_state = "handmade_supp_1_o"
	overlay_offset = list("x" = 0, "y" = 0)
	var/variant = 1
	var/break_chance = 0
	var/break_increase_chance = 1

/obj/item/gun_module/muzzle/suppressor/handmade/Initialize(mapload)
	. = ..()
	variant = rand(1, 3)
	update_icon()

/obj/item/gun_module/muzzle/suppressor/handmade/update_icon_state()
	icon_state = "[initial(base_icon_state)][variant]"
	overlay_state = "[base_icon_state]_o"

/obj/item/gun_module/muzzle/suppressor/handmade/get_ru_names()
	return list(
		NOMINATIVE = "самодельный глушитель",
		GENITIVE = "самодельного глушителя",
		DATIVE = "самодельному глушителю",
		ACCUSATIVE = "самодельный глушитель",
		INSTRUMENTAL = "самодельным глушителем",
		PREPOSITIONAL = "самодельном глушителе",
	)

/obj/item/gun_module/muzzle/suppressor/handmade/on_attach(obj/item/gun/target_gun, mob/user)
	. = ..()
	RegisterSignal(target_gun, COMSIG_GUN_FIRED, PROC_REF(on_fire))

/obj/item/gun_module/muzzle/suppressor/handmade/on_detach(obj/item/gun/target_gun, mob/user)
	UnregisterSignal(target_gun, COMSIG_GUN_FIRED)
	. = ..()

/obj/item/gun_module/muzzle/suppressor/handmade/proc/on_fire(datum/source, mob/user)
	SIGNAL_HANDLER

	break_chance += break_increase_chance
	if(!prob(break_chance))
		return
	INVOKE_ASYNC(src, PROC_REF(destroy_module), user)

/obj/item/gun_module/muzzle/suppressor/handmade/proc/destroy_module(mob/user)
	detach_without_check(gun, user, TRUE, FALSE, TRUE) //force detach module, no put in hands and do it silence
	qdel(src)

/**
 * MARK: Compensator
 */

/obj/item/gun_module/muzzle/compensator
	name = "compensator"
	desc = "Глушитель, совместимый с широким диапазоном огнестрельного оружия. Уменьшает дульную вспышку и отдачу, производимую при выстреле, тем самым немного повышая точность стрельбы."
	icon_state = "comp"
	item_state = "comp"
	overlay_state = "comp_o"
	overlay_offset = list("x" = -3, "y" = 0)
	class = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_SNIPER_MUZZLE
	var/bonus_accuracy = 10
	var/initial_w_class
	var/spread_decrease = 0
	var/initial_recoil

/obj/item/gun_module/muzzle/compensator/get_ru_names()
	return list(
		NOMINATIVE = "универсальный компенсатор",
		GENITIVE = "универсального компенсатора",
		DATIVE = "универсальному компенсатору",
		ACCUSATIVE = "универсальный компенсатор",
		INSTRUMENTAL = "универсальным компенсатором",
		PREPOSITIONAL = "универсальном компенсаторе",
	)

/obj/item/gun_module/muzzle/compensator/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.suppress_muzzle_flash = TRUE
	initial_w_class = target_gun.w_class
	if(target_gun.w_class < WEIGHT_CLASS_NORMAL)
		target_gun.w_class = WEIGHT_CLASS_NORMAL
	target_gun.accuracy.add_accuracy(bonus_accuracy)
	if(!target_gun.accuracy.max_spread)
		return
	spread_decrease = initial(target_gun.accuracy.max_spread) * 0.15
	target_gun.accuracy.max_spread = target_gun.accuracy.max_spread - spread_decrease
	initial_recoil = target_gun.recoil.strength
	target_gun.recoil.strength = target_gun.recoil.strength * 0.2

/obj/item/gun_module/muzzle/compensator/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.suppress_muzzle_flash = FALSE
	target_gun.w_class = initial_w_class
	target_gun.accuracy.add_accuracy(-bonus_accuracy)
	target_gun.accuracy.max_spread += spread_decrease
	spread_decrease = 0
	target_gun.recoil.strength = initial_recoil
	initial_recoil = 0
