// MARK: Generic
/obj/item/gun/projectile/bow
	name = "bow"
	desc = "Прочный лук, сделанный из дерева."
	gender = MALE
	icon_state = "bow"
	item_state = "bow"

	fire_sound = 'sound/weapons/bows/bow_fire.ogg'
	pickup_sound = 'sound/weapons/bows/bow_pickup.ogg'
	drop_sound = 'sound/weapons/bows/bow_drop.ogg'
	equip_sound = 'sound/weapons/bows/bow_equip.ogg'

	mag_type = /obj/item/ammo_box/magazine/internal/bow
	item_flags = SLOWS_WHILE_IN_HAND
	slot_flags = ITEM_SLOT_BACK
	weapon_weight = WEAPON_HEAVY
	trigger_guard = TRIGGER_GUARD_NONE

	var/draw_sound = 'sound/weapons/bows/bow_pull.ogg'
	var/ready_to_fire = FALSE
	var/slowdown_when_ready = 2
	accuracy = GUN_ACCURACY_DEFAULT
	recoil = null

/obj/item/gun/projectile/bow/get_ru_names()
	return list(
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
		icon_state = "[initial(icon_state)]_loaded"
	else if(ready_to_fire)
		icon_state = "[initial(icon_state)]_firing"
	else
		icon_state = initial(icon_state)

/obj/item/gun/projectile/bow/proc/update_slowdown()
	slowdown = ready_to_fire ? slowdown_when_ready : initial(slowdown)

/obj/item/gun/projectile/bow/dropped(mob/user, slot, silent = FALSE)
	if(chambered)
		chambered.forceMove(drop_location())
		chambered = null
		ready_to_fire = FALSE
		update_state()
	return ..()

/obj/item/gun/projectile/bow/unload_act(mob/user)
	if(chambered && !ready_to_fire)
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

/obj/item/gun/projectile/bow/process_chamber(eject_casing = FALSE, empty_chamber = TRUE)
	. = ..()
	ready_to_fire = FALSE
	update_state()

// MARK: Bone
/obj/item/gun/projectile/bow/ashen //better than wooden
	name = "bone bow"
	desc = "Примитивный лук с тетивой, сделанной из жилы. Обычно используется племенными охотниками и воинами."
	icon_state = "ashenbow"
	item_state = "ashenbow"

	fire_sound = 'sound/weapons/bows/bonebow_fire.ogg'
	drop_sound = 'sound/weapons/bows/bonebow_drop.ogg'
	draw_sound = 'sound/weapons/bows/bonebow_pull.ogg'

	item_flags = NONE
	flags = NONE
	force = 10
	slowdown_when_ready = 1
	accuracy = GUN_ACCURACY_RIFLE

/obj/item/gun/projectile/bow/ashen/get_ru_names()
	return list(
		NOMINATIVE = "костяной лук",
		GENITIVE = "костяного лука",
		DATIVE = "костяному луку",
		ACCUSATIVE = "костяной лук",
		INSTRUMENTAL = "костяным луком",
		PREPOSITIONAL = "костяном луке",
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
	can_hold = list(
		/obj/item/ammo_casing/caseless/arrow,
	)

/obj/item/storage/backpack/quiver/get_ru_names()
	return list(
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
	update_icon()

/obj/item/storage/backpack/quiver/update_icon_state()
	if(length(contents))
		icon_state = "quiver_[clamp(length(contents),1,5)]"
	else
		icon_state = initial(icon_state)

/obj/item/storage/belt/quiver_weaver //belt slot
	name = "weaver chitin quiver"
	desc = "Огнеупорный колчан, сделанный из хитина ткача. Используется для хранения стрел."
	icon_state = "quiver_weaver"
	item_state = "quiver_weaver"
	storage_slots = 21 //every craft makes 3 arrows
	max_combined_w_class = INFINITY
	display_contents_with_number = TRUE
	can_hold = list(
		/obj/item/ammo_casing/caseless/arrow,
	)
	resistance_flags = FIRE_PROOF

/obj/item/storage/belt/quiver_weaver/get_ru_names()
	return list(
		NOMINATIVE = "колчан из хитина ткача",
		GENITIVE = "колчана из хитина ткача",
		DATIVE = "колчану из хитина ткача",
		ACCUSATIVE = "колчан из хитина ткача",
		INSTRUMENTAL = "колчаном из хитина ткача",
		PREPOSITIONAL = "колчане из хитина ткача",
	)

/obj/item/storage/belt/quiver_weaver/full/populate_contents()
	for(var/i in 1 to storage_slots)
		new /obj/item/ammo_casing/caseless/arrow/bone_tipped(src)
