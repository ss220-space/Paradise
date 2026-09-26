// MARK: Generic wooden bow
/obj/item/gun/projectile/bow
	name = "bow"
	desc = "Прочный лук, сделанный из дерева."
	gender = MALE
	icon_state = "bow"
	base_icon_state = "bow"
	item_state = "bow"
	fire_sound = 'sound/weapons/bows/bow_fire.ogg'
	pickup_sound = 'sound/weapons/bows/bow_pickup.ogg'
	drop_sound = 'sound/weapons/bows/bow_drop.ogg'
	equip_sound = 'sound/weapons/bows/bow_equip.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/bow
	item_flags = SLOWS_WHILE_IN_HAND
	slot_flags = ITEM_SLOT_BACK
	weapon_weight = WEAPON_HEAVY
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	accuracy = GUN_ACCURACY_BOW
	recoil = null
	can_holster = FALSE
	var/draw_sound = 'sound/weapons/bows/bow_pull.ogg'
	var/ready_to_fire = FALSE
	var/slowdown_when_ready = 2
	var/speed_modifier = 1.5
	var/range_modifier = 0.8
	var/ready_to_fire_time = 1.5 SECONDS

/obj/item/gun/projectile/bow/get_ru_names()
	return alist(
		NOMINATIVE = "деревянный лук",
		GENITIVE = "деревянного лука",
		DATIVE = "деревянному луку",
		ACCUSATIVE = "деревянный лук",
		INSTRUMENTAL = "деревянным луком",
		PREPOSITIONAL = "деревянном луке",
	)

/obj/item/gun/projectile/bow/proc/update_state()
	update_slowdown()
	update_icon(UPDATE_ICON_STATE)
	update_equipped_item()

/obj/item/gun/projectile/bow/update_icon_state()
	if(chambered && !ready_to_fire)
		icon_state = "[base_icon_state]_loaded"
	else if(ready_to_fire)
		icon_state = "[base_icon_state]_firing"
	else
		icon_state = base_icon_state

/obj/item/gun/projectile/bow/proc/update_slowdown()
	CALCULATE_SKILL_MOD(gun_user, BOW_SLOWDOWN_MOD, skill_mod)
	slowdown = ready_to_fire ? slowdown_when_ready * skill_mod : initial(slowdown)

/obj/item/gun/projectile/bow/dropped(mob/user, slot, silent = FALSE)
	if(chambered)
		chambered.forceMove(drop_location())
		chambered = null
		ready_to_fire = FALSE
		update_state()
	return ..()

/obj/item/gun/projectile/bow/attack_self(mob/living/user)
	GET_SKILL_LEVEL(user, /datum/skill/combat/bows, skill_level)
	if(!chambered && skill_level >= SKILL_LEVEL_ADVANCED && !user.get_inactive_hand())
		var/list/possible_quivers = list(user.get_item_by_slot(ITEM_SLOT_BACK), user.get_item_by_slot(ITEM_SLOT_BELT))
		for(var/obj/item/storage/backpack/quiver/quiver in possible_quivers)
			if(!length(quiver.contents))
				continue
			var/loaded = magazine.reload(pick(quiver.contents), user, silent = TRUE, count_chambered = TRUE)
			if(!loaded)
				return
			balloon_alert(user, "стрела помещена")
			chamber_round()
			update_state()
			return
	return ..()

/obj/item/gun/projectile/bow/unload_act(mob/user)
	CALCULATE_SKILL_MOD(user, BOW_READY_TO_FIRE_MOD, skill_mod)
	if(chambered && !ready_to_fire && do_after(user, ready_to_fire_time * skill_mod, src, timed_action_flags = DA_IGNORE_USER_LOC_CHANGE, max_interact_count = 1))
		ready_to_fire = TRUE
		playsound(user, draw_sound, 100, TRUE)
	else
		ready_to_fire = FALSE
	update_state()

/obj/item/gun/projectile/bow/attackby(obj/item/I, mob/user, params)
	if(isammobox(I) || isammocasing(I))
		add_fingerprint(user)
		var/loaded = magazine.reload(I, user, silent = TRUE, count_chambered = TRUE)
		if(loaded)
			balloon_alert(user, "стрела помещена")
			chamber_round()
			update_state()
			return ATTACK_CHAIN_BLOCKED_ALL
		balloon_alert(user, "не удалось!")
		return ATTACK_CHAIN_PROCEED

	return ..()

/obj/item/gun/projectile/bow/can_shoot(mob/user)
	return chambered && ready_to_fire

/obj/item/gun/projectile/bow/shoot_with_empty_chamber(mob/living/user)
	return

/obj/item/gun/projectile/bow/on_pre_process_fire(mob/living/user, atom/target)
	if(chambered)
		chambered.speed_modifier = speed_modifier
		chambered.range_modifier = range_modifier
	return

/obj/item/gun/projectile/bow/process_chamber(eject_casing = FALSE, empty_chamber = TRUE)
	. = ..()
	ready_to_fire = FALSE
	update_state()

// MARK: Bone
/obj/item/gun/projectile/bow/ashen
	name = "bone bow"
	desc = "Примитивный лук с тетивой, сделанной из жилы. Обычно используется племенными охотниками и воинами."
	icon_state = "ashenbow"
	base_icon_state = "ashenbow"
	item_state = "ashenbow"
	fire_sound = 'sound/weapons/bows/bonebow_fire.ogg'
	drop_sound = 'sound/weapons/bows/bonebow_drop.ogg'
	draw_sound = 'sound/weapons/bows/bonebow_pull.ogg'
	item_flags = NONE
	flags = NONE
	force = 10
	slowdown_when_ready = 1
	accuracy = GUN_ACCURACY_BOW_ADVANCED
	speed_modifier = 0.8
	range_modifier = 1.1
	ready_to_fire_time = 1 SECONDS

/obj/item/gun/projectile/bow/ashen/get_ru_names()
	return alist(
		NOMINATIVE = "костяной лук",
		GENITIVE = "костяного лука",
		DATIVE = "костяному луку",
		ACCUSATIVE = "костяной лук",
		INSTRUMENTAL = "костяным луком",
		PREPOSITIONAL = "костяном луке",
	)

// MARK: Compound
/obj/item/gun/projectile/bow/compound
	name = "compound bow"
	desc = "Композитный лук, предназначенный для любительской охоты и соревнований."
	icon_state = "modernbow"
	base_icon_state = "modernbow"
	item_state = "modernbow"
	item_flags = NONE
	flags = NONE
	force = 10
	slowdown_when_ready = 1
	accuracy = GUN_ACCURACY_BOW_ADVANCED
	speed_modifier = 0.8
	range_modifier = 1.1
	ready_to_fire_time = 1 SECONDS

/obj/item/gun/projectile/bow/compound/get_ru_names()
	return alist(
		NOMINATIVE = "композитный лук",
		GENITIVE = "композитного лука",
		DATIVE = "композитному луку",
		ACCUSATIVE = "композитный лук",
		INSTRUMENTAL = "композитным луком",
		PREPOSITIONAL = "композитном луке",
	)

// MARK: Tactical
/obj/item/gun/projectile/bow/tactical
	name = "tactical bow"
	desc = "Тактический лук \"Синдиката\", предназначенный для особых операций, для которых не подходит любое другое оружие. Для удобства прицеливания установлен прицел малой кратности."
	icon_state = "assaultbow"
	base_icon_state = "assaultbow"
	item_state = "assaultbow"
	item_flags = NONE
	flags = NONE
	force = 20
	w_class = WEIGHT_CLASS_SMALL
	slowdown_when_ready = 1
	accuracy = GUN_ACCURACY_BOW_ADVANCED
	speed_modifier = 0.8
	range_modifier = 1.1
	zoomable = TRUE
	ready_to_fire_time = 0.5 SECONDS

/obj/item/gun/projectile/bow/tactical/get_ru_names()
	return alist(
		NOMINATIVE = "тактический лук",
		GENITIVE = "тактического лука",
		DATIVE = "тактическому луку",
		ACCUSATIVE = "тактический лук",
		INSTRUMENTAL = "тактическим луком",
		PREPOSITIONAL = "тактическом луке",
	)

// MARK: Handmade
/obj/item/gun/projectile/bow/handmade
	name = "handmade bow"
	desc = "Самодельный лук, сделанный из того, что нашлось под рукой."
	icon_state = "homemade"
	base_icon_state = "homemade"
	item_state = "homemade"
	force = 10

/obj/item/gun/projectile/bow/handmade/get_ru_names()
	return alist(
		NOMINATIVE = "самодельный лук",
		GENITIVE = "самодельного лука",
		DATIVE = "самодельному луку",
		ACCUSATIVE = "самодельный лук",
		INSTRUMENTAL = "самодельным луком",
		PREPOSITIONAL = "самодельном луке",
	)

// MARK: Arrow storages
// TODO: move it into it's own files
/obj/item/storage/backpack/quiver
	name = "quiver"
	desc = "Колчан для хранения стрел."
	gender =  MALE
	icon_state = "quiver"
	item_state = "quiver"
	max_combined_w_class = INFINITY
	display_contents_with_number = TRUE
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	can_hold = list(
		/obj/item/ammo_casing/caseless/arrow,
	)

/obj/item/storage/backpack/quiver/get_ru_names()
	return alist(
		NOMINATIVE = "колчан",
		GENITIVE = "колчана",
		DATIVE = "колчану",
		ACCUSATIVE = "колчан",
		INSTRUMENTAL = "колчаном",
		PREPOSITIONAL = "колчане",
	)

/obj/item/storage/backpack/quiver/full/populate_contents()
	for(var/i in 1 to storage_slots)
		new /obj/item/ammo_casing/caseless/arrow(src)
	update_appearance(UPDATE_ICON)

/obj/item/storage/backpack/quiver/update_icon_state()
	if(length(contents))
		icon_state = "quiver_[clamp(length(contents), 1, 5)]"
	else
		icon_state = initial(icon_state)

/obj/item/storage/backpack/quiver/weaver
	name = "weaver chitin quiver"
	desc = "Огнеупорный колчан, сделанный из хитина ткача. Используется для хранения стрел."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "quiver_weaver"
	item_state = "quiver_weaver"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	resistance_flags = FIRE_PROOF
	storage_slots = 30

/obj/item/storage/backpack/quiver/weaver/get_ru_names()
	return alist(
		NOMINATIVE = "колчан из хитина ткача",
		GENITIVE = "колчана из хитина ткача",
		DATIVE = "колчану из хитина ткача",
		ACCUSATIVE = "колчан из хитина ткача",
		INSTRUMENTAL = "колчаном из хитина ткача",
		PREPOSITIONAL = "колчане из хитина ткача",
	)

/obj/item/storage/backpack/quiver/weaver/update_icon_state()
	return

/obj/item/storage/backpack/quiver/weaver/full/populate_contents()
	for(var/i in 1 to storage_slots)
		new /obj/item/ammo_casing/caseless/arrow/bone_tipped(src)

/obj/item/storage/backpack/quiver/modern
	name = "modern quiver"
	desc = "Качественный колчан из синтетической кожи."
	icon_state = "quivermodern"
	item_state = "quivermodern"
	storage_slots = 30

/obj/item/storage/backpack/quiver/modern/get_ru_names()
	return alist(
		NOMINATIVE = "колчан из синтетической кожи",
		GENITIVE = "колчана из синтетической кожи",
		DATIVE = "колчану из синтетической кожи",
		ACCUSATIVE = "колчан из синтетической кожи",
		INSTRUMENTAL = "колчаном из синтетической кожи",
		PREPOSITIONAL = "колчане из синтетической кожи",
	)

/obj/item/storage/backpack/quiver/modern/update_icon_state()
	if(length(contents))
		icon_state = "quivermodern_full"
		item_state = "quivermodern_full"
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)

/obj/item/storage/backpack/quiver/modern/full/populate_contents()
	for(var/i in 1 to storage_slots)
		new /obj/item/ammo_casing/caseless/arrow/modern(src)
	update_appearance(UPDATE_ICON)

/obj/item/storage/backpack/quiver/homemade
	name = "homemade quiver"
	desc = "Колчан из того, что можно найти в ближайшей куче мусора. Лучше чем ничего."
	icon_state = "homemade"
	storage_slots = 10

/obj/item/storage/backpack/quiver/homemade/get_ru_names()
	return alist(
		NOMINATIVE = "колчан из мусорного пакета",
		GENITIVE = "колчана из мусорного пакета",
		DATIVE = "колчану из мусорного пакета",
		ACCUSATIVE = "колчан из мусорного пакета",
		INSTRUMENTAL = "колчаном из мусорного пакета",
		PREPOSITIONAL = "колчане из мусорного пакета",
	)

/obj/item/storage/backpack/quiver/homemade/update_icon_state()
	if(length(contents))
		icon_state = "homemade_full"
	else
		icon_state = initial(icon_state)

/obj/item/storage/backpack/quiver/homemade/full/populate_contents()
	for(var/i in 1 to storage_slots)
		new /obj/item/ammo_casing/caseless/arrow/homemade(src)
	update_appearance(UPDATE_ICON)
