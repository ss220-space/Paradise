/obj/item/gun/projectile/bow
	name = "bow"
	desc = "Прочный лук, сделанный из дерева."
	ru_names = list(
		NOMINATIVE = "деревянный лук",
		GENITIVE = "деревянного лука",
		DATIVE = "деревянному луку",
		ACCUSATIVE = "деревянный лук",
		INSTRUMENTAL = "деревянным луком",
		PREPOSITIONAL = "деревянном луке"
	)
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

/obj/item/gun/projectile/bow/ashen //better than wooden
	name = "bone bow"
	desc = "Примитивный лук с тетивой, сделанной из жилы. Обычно используется племенными охотниками и воинами."
	ru_names = list(
		NOMINATIVE = "костяной лук",
		GENITIVE = "костяного лука",
		DATIVE = "костяному луку",
		ACCUSATIVE = "костяной лук",
		INSTRUMENTAL = "костяным луком",
		PREPOSITIONAL = "костяном луке"
	)
	icon_state = "ashenbow"
	item_state = "ashenbow"

	fire_sound = 'sound/weapons/bows/bonebow_fire.ogg'
	drop_sound = 'sound/weapons/bows/bonebow_drop.ogg'
	draw_sound = 'sound/weapons/bows/bonebow_pull.ogg'

	item_flags = NONE
	flags = NONE
	force = 10
	slowdown_when_ready = 1

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

	. = ..()


/obj/item/gun/projectile/bow/attack_self(mob/living/user)
	if(chambered && !ready_to_fire)
		ready_to_fire = TRUE
		playsound(user, draw_sound, 100, TRUE)
	else
		ready_to_fire = FALSE
	update_state()


/obj/item/gun/projectile/bow/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box) || istype(I, /obj/item/ammo_casing))
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


// ammo
/obj/item/ammo_box/magazine/internal/bow
	name = "bow internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	caliber = "arrow"
	max_ammo = 1
	start_empty = TRUE
	replacing_sound = list(
		'sound/weapons/bows/arrow_insert1.ogg',
		'sound/weapons/bows/arrow_insert2.ogg'
	)
	remove_sound = list(
		'sound/weapons/bows/arrow_remove1.ogg',
		'sound/weapons/bows/arrow_remove2.ogg'
	)
	insert_sound = list(
		'sound/weapons/bows/arrow_insert1.ogg',
		'sound/weapons/bows/arrow_insert2.ogg'
	)
	load_sound = list(
		'sound/weapons/bows/arrow_remove1.ogg',
		'sound/weapons/bows/arrow_remove2.ogg'
	) //all these sounds are too good to be true

/obj/item/projectile/bullet/reusable/arrow //only for wooden bow!
	name = "arrow"
	icon_state = "arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	range = 10
	damage = 25
	damage_type = BRUTE
	var/faction_bonus_damage = 13
	var/nemesis_factions = list("mining", "boss")
	var/nemesis_faction = FALSE

/obj/item/projectile/bullet/reusable/arrow/prehit(atom/target)
	var/mob/living/H = target

	if(!ismob(H) || !LAZYLEN(nemesis_factions))
		return

	for(var/faction in H.faction)
		if(faction in nemesis_factions)
			nemesis_faction = TRUE
			damage += faction_bonus_damage
			break

	. = ..()

/obj/item/projectile/bullet/reusable/arrow/bone //A fully upgraded normal arrow; it's got the stats to show. Still *less* damage than a slug, slower, and with negative AP. Only for bone bow!
	name = "bone-tipped arrow"
	icon_state = "bone_arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone_tipped
	range = 12
	damage = 45
	armour_penetration = -10
	faction_bonus_damage = 23

/obj/item/projectile/bullet/reusable/arrow/jagged //alternative arrow, made from fishing
	name = "jagged-tipped arrow"
	icon_state = "jagged_arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/jagged
	range = 12
	damage = 60
	armour_penetration = -30
	faction_bonus_damage = 50

/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "Послушай, ты не мог бы положить это яблоко себе на голову?"
	ru_names = list(
		NOMINATIVE = "деревянная стрела",
		GENITIVE = "деревянной стрелы",
		DATIVE = "деревянной стреле",
		ACCUSATIVE = "деревянную стрелу",
		INSTRUMENTAL = "деревянной стрелой",
		PREPOSITIONAL = "деревянной стреле"
	)
	gender = FEMALE
	icon_state = "arrow"
	item_state = "arrow"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 10
	projectile_type = /obj/item/projectile/bullet/reusable/arrow
	muzzle_flash_effect = null
	caliber = "arrow"

/obj/item/ammo_casing/caseless/arrow/bone_tipped
	name = "bone-tipped arrow"
	desc = "Стрела, сделанная из кости, дерева и сухожилий. Прочная и острая."
	ru_names = list(
		NOMINATIVE = "костяная стрела",
		GENITIVE = "костяной стрелы",
		DATIVE = "костяной стреле",
		ACCUSATIVE = "костяную стрелу",
		INSTRUMENTAL = "костяной стрелой",
		PREPOSITIONAL = "костяной стреле"
	)
	icon_state = "bone_arrow"
	item_state = "bone_arrow"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 12
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bone
	caliber = "arrow"

/obj/item/ammo_casing/caseless/arrow/jagged
	name = "jagged-tipped arrow"
	desc = "Стрела, сделанная из зубов хищной рыбы. Невероятно острая и крепкая."
	ru_names = list(
		NOMINATIVE = "зазубренная стрела",
		GENITIVE = "зазубренной стрелы",
		DATIVE = "зазубренной стреле",
		ACCUSATIVE = "зазубренную стрелу",
		INSTRUMENTAL = "зазубренной стрелой",
		PREPOSITIONAL = "зазубренной стреле",
	)
	icon_state = "jagged_arrow"
	force = 16
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/jagged
	caliber = "arrow"

//quiver
/obj/item/storage/backpack/quiver
	name = "quiver"
	desc = "Колчан для хранения стрел."
	ru_names = list(
		NOMINATIVE = "колчан",
		GENITIVE = "колчана",
		DATIVE = "колчану",
		ACCUSATIVE = "колчан",
		INSTRUMENTAL = "колчаном",
		PREPOSITIONAL = "колчане"
	)
	gender =  MALE
	icon_state = "quiver"
	item_state = "quiver"
	storage_slots = 21
	max_combined_w_class = INFINITY
	display_contents_with_number = TRUE
	can_hold = list(
		/obj/item/ammo_casing/caseless/arrow
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
	ru_names = list(
		NOMINATIVE = "колчан из хитина ткача",
		GENITIVE = "колчана из хитина ткача",
		DATIVE = "колчану из хитина ткача",
		ACCUSATIVE = "колчан из хитина ткача",
		INSTRUMENTAL = "колчаном из хитина ткача",
		PREPOSITIONAL = "колчане из хитина ткача"
	)
	gender = MALE
	icon_state = "quiver_weaver"
	item_state = "quiver_weaver"
	storage_slots = 21 //every craft makes 3 arrows
	max_combined_w_class = INFINITY
	display_contents_with_number = TRUE
	can_hold = list(
		/obj/item/ammo_casing/caseless/arrow
		)
	resistance_flags = FIRE_PROOF

/obj/item/storage/belt/quiver_weaver/full/populate_contents()
	for(var/i in 1 to storage_slots)
		new /obj/item/ammo_casing/caseless/arrow/bone_tipped(src)
