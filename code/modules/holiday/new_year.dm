/**
 * New year celebration stuff. Yeah :D
 */
/obj/structure/garland
	name = "garland"
	desc = "It's a glowey garland."
	icon = 'icons/obj/new_year/decorations.dmi'
	icon_state = "garland_on"
	max_integrity = 24 //can be removed easily (also, symbolism)
	density = FALSE
	layer = BELOW_OBJ_LAYER
	anchored = TRUE


/obj/structure/garland/wirecutter_act(mob/living/user, obj/item/wirecutters/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	to_chat(user, span_notice("You cut garland apart."))
	deconstruct()


/obj/structure/garland/wrench_act(mob/living/user, obj/item/wrench/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	set_anchored(!anchored)
	to_chat(user, span_notice("You [anchored ? "" : "un"]wrenched [src]"))


/obj/item/clothing/head/new_year
	name = "Red furhat"
	desc = "Warm furhat for freezing weather"
	icon_state = "red_furhat"
	item_state = "red_furhat"
	resistance_flags = INDESTRUCTIBLE
	w_class = WEIGHT_CLASS_SMALL
	clothing_flags = STOPSPRESSUREDMAGE|THICKMATERIAL
	body_parts_covered = HEAD
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 70)
	flags_inv = NONE
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
	)

/obj/item/clothing/suit/space/new_year
	name = "Red furcoat"
	desc = "Very warm long coat colored in red color"
	icon_state = "red_furcoat"
	item_state = "red_furcoat"
	resistance_flags = INDESTRUCTIBLE
	w_class = WEIGHT_CLASS_NORMAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|TAIL|WING
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/gun/magic/staff/frost)
	slowdown = FALSE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 70)
	flags_inv = NONE
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | TAIL
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | TAIL
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
	)

/obj/item/gun/magic/staff/frost
	name = "Frost staff"
	desc = "An anchient wonderous artifact of widely-known old man loved across entire USSP"
	ammo_type = /obj/item/ammo_casing/magic/frost
	icon_state = "frost_staff"
	item_state = "frost_staff"
	max_charges = 10
	recharge_rate = 2
	fire_sound = 'sound/magic/staff_healing.ogg'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/magic/staff/frost/attack_self(mob/user)
	. = ..()
	visible_message(span_darkmblue("[user] raises up [src], forming blizzard around it."), \
	 span_darkmblue("You raise up [src] and start forming snowy blizzard..."))
	if(do_after(user, 5 SECONDS, user))
		for(var/turf/simulated/T in range(4, user))
			if(T.density)
				continue
			T.air.temperature = T0C
			new /obj/effect/snow(T)

/obj/item/ammo_casing/magic/frost
	projectile_type = /obj/item/projectile/magic/frost

/obj/item/projectile/magic/frost
	name = "bolt of frost"
	icon_state = "ice_2"
	hitsound = 'sound/effects/hit_on_shattered_glass.ogg'
	hitsound_wall = 'sound/effects/hit_on_shattered_glass.ogg'
	armour_penetration = 100
	flag = "magic"

/obj/item/projectile/magic/frost/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(isliving(target))
		var/mob/living/victim = target
		freeze(victim)

/obj/item/projectile/magic/frost/proc/freeze(mob/living/target)
	target.apply_status_effect(/datum/status_effect/freon/frost)

/datum/status_effect/freon/frost
	ice_state = "ice_shell"
	duration = 20 SECONDS
	can_melt = FALSE

/obj/item/clothing/gloves/color/white/redcoat
	siemens_coefficient = 0
	permeability_coefficient = 0.01

/obj/item/storage/backpack/santabag/ded_moroz
	name = "Presents bag"
	desc = "Bag filled with presents. Artifact of a widely-known old man loved across entire USSP."
	max_w_class = WEIGHT_CLASS_BULKY
	max_combined_w_class = 2024

/obj/item/storage/backpack/santabag/ded_moroz/populate_contents()
	for(var/i in 1 to 50)
		new /obj/item/a_gift(src)
	update_icon()

/datum/outfit/ded_moroz
	name = "Ded Moroz"
	uniform = /obj/item/clothing/under/color/red
	suit = /obj/item/clothing/suit/space/new_year
	back = /obj/item/storage/backpack/santabag/ded_moroz
	head = /obj/item/clothing/head/new_year
	r_hand = /obj/item/gun/magic/staff/frost
	shoes = /obj/item/clothing/shoes/winterboots
	gloves = /obj/item/clothing/gloves/color/white/redcoat
