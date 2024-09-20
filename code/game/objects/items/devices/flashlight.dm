/obj/item/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL=50, MAT_GLASS=20)
	actions_types = list(/datum/action/item_action/toggle_light)
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 4
	light_power = 1
	light_on = FALSE
	var/on = FALSE
	var/togglesound = 'sound/weapons/empty.ogg'

/obj/item/flashlight/dummy
	name = "Testing flashlight"
	light_system = MOVABLE_LIGHT
	light_range = 4
	light_power = 1
	light_on = FALSE

/obj/item/flashlight/Initialize()
	. = ..()
	if(icon_state == "[initial(icon_state)]-on")
		on = TRUE
	update_brightness()


/obj/item/flashlight/update_icon_state()
	if(on)
		icon_state = "[initial(icon_state)]-on"
	else
		icon_state = "[initial(icon_state)]"


/obj/item/flashlight/proc/update_brightness()
	if(light_system == STATIC_LIGHT)
		update_light()
	set_light_on(on)
	update_icon()


/obj/item/flashlight/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in this [user.loc].")	//To prevent some lighting anomalities.
		return FALSE
	on = !on
	playsound(user, togglesound, 100, 1)
	update_brightness()
	update_equipped_item(update_speedmods = FALSE)
	return TRUE


/obj/item/flashlight/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!on || user.zone_selected != BODY_ZONE_PRECISE_EYES)
		return ..()

	if((HAS_TRAIT(user, TRAIT_CLUMSY) || user.getBrainLoss() >= 60) && prob(50))	//too dumb to use flashlight properly
		return ..()	//just hit them in the head

	. = ATTACK_CHAIN_PROCEED

	if(!ishuman(user) || SSticker?.mode.name != "monkey")	//don't have dexterity
		to_chat(user, span_notice("You don't have the dexterity to do this!"))
		return .

	var/mob/living/carbon/human/human_target = target	//mob has protective eyewear
	if(ishuman(target) && ((human_target.head && human_target.head.flags_cover & HEADCOVERSEYES) || (human_target.wear_mask && human_target.wear_mask.flags_cover & MASKCOVERSEYES) || (human_target.glasses && human_target.glasses.flags_cover & GLASSESCOVERSEYES)))
		to_chat(user, span_notice("You're going to need to remove that [(human_target.head && human_target.head.flags_cover & HEADCOVERSEYES) ? "helmet" : (human_target.wear_mask && human_target.wear_mask.flags_cover & MASKCOVERSEYES) ? "mask" : "glasses"] first."))
		return .

	. |= ATTACK_CHAIN_SUCCESS

	if(target == user)	//they're using it on themselves
		if(user.flash_eyes(visual = TRUE))
			user.visible_message(
				span_notice("[user] directs [src] to [user.p_their()] eyes."),
				span_notice("You wave the light in front of your eyes! Trippy!"),
			)
		else
			user.visible_message(
				span_notice("[user] directs [src] to [user.p_their()] eyes."),
				span_notice("You wave the light in front of your eyes."),
			)
	else

		user.visible_message(
			span_notice("[user] directs [src] to [target]'s eyes."),
			span_notice("You direct [src] to [target]'s eyes."),
		)

		if(ishuman(target)) //robots and aliens are unaffected
			var/obj/item/organ/internal/eyes/eyes = human_target.get_int_organ(/obj/item/organ/internal/eyes)
			if(human_target.stat == DEAD || !eyes || HAS_TRAIT(human_target, TRAIT_BLIND))	//mob is dead or fully blind
				to_chat(user, span_notice("[human_target]'s pupils are unresponsive to the light!"))
			else if(HAS_TRAIT(human_target, TRAIT_XRAY) || human_target.nightvision >= 8) //The mob's either got the X-RAY vision or has a tapetum lucidum (extreme nightvision, i.e. Vulp/Tajara with COLOURBLIND & their monkey forms).
				to_chat(user, span_notice("[human_target]'s pupils glow eerily!"))
			else //they're okay!
				if(human_target.flash_eyes(visual = TRUE))
					to_chat(user, span_notice("[human_target]'s pupils narrow."))


/obj/item/flashlight/extinguish_light(force = FALSE)
	if(on)
		on = FALSE
		update_brightness()
		update_equipped_item()

/obj/item/flashlight/pen
	name = "penlight"
	desc = "A pen-sized light, used by medical staff."
	icon_state = "penlight"
	item_state = ""
	belt_icon = "penlight"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_EARS
	flags = CONDUCT
	light_system = MOVABLE_LIGHT
	light_range = 2

/obj/item/flashlight/seclite
	name = "seclite"
	desc = "A robust flashlight used by security."
	icon_state = "seclite"
	item_state = "seclite"
	belt_icon = "seclite"
	force = 9 // Not as good as a stun baton.
	light_range = 5 // A little better than the standard flashlight.
	hitsound = 'sound/weapons/genhit1.ogg'

/obj/item/flashlight/drone
	name = "low-power flashlight"
	desc = "A miniature lamp, that might be used by small robots."
	icon_state = "penlight"
	item_state = ""
	flags = CONDUCT
	light_range = 2
	w_class = WEIGHT_CLASS_TINY

// the desk lamps are a bit special
/obj/item/flashlight/lamp
	name = "desk lamp"
	desc = "A desk lamp with an adjustable mount."
	icon_state = "lamp"
	item_state = "lamp"
	light_range = 5
	w_class = WEIGHT_CLASS_BULKY
	flags = CONDUCT
	materials = list()
	on = TRUE


// green-shaded desk lamp
/obj/item/flashlight/lamp/green
	desc = "A classic green-shaded desk lamp."
	icon_state = "lampgreen"
	item_state = "lampgreen"


//Bananalamp
/obj/item/flashlight/lamp/bananalamp
	name = "banana lamp"
	desc = "Only a clown would think to make a ghetto banana-shaped lamp. Even has a goofy pullstring."
	icon_state = "bananalamp"
	item_state = "bananalamp"


// FLARES

/obj/item/flashlight/flare
	name = "flare"
	desc = "A red Nanotrasen issued flare. There are instructions on the side, it reads 'pull cord, make light'."
	light_range = 8
	light_system = MOVABLE_LIGHT
	light_color = "#ff0000"
	icon_state = "flare"
	item_state = "flare"
	togglesound = 'sound/goonstation/misc/matchstick_light.ogg'
	var/can_fire_cigs = TRUE
	var/fuel = 0
	var/on_damage = 7
	var/produce_heat = 1500
	var/fuel_lower = 800
	var/fuel_upp = 1000


/obj/item/flashlight/flare/Initialize()
	fuel = rand(fuel_lower, fuel_upp)
	. = ..()


/obj/item/flashlight/flare/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/flashlight/flare/update_icon_state()
	if(on)
		item_state = "[initial(item_state)]-on"
	else
		item_state = "[initial(item_state)]"

	if(!fuel)
		icon_state = "[initial(icon_state)]-empty"
		return
	..()


/obj/item/flashlight/flare/process()
	var/turf/pos = get_turf(src)
	if(pos && produce_heat)
		pos.hotspot_expose(produce_heat, 5)
	fuel = max(fuel - 1, 0)
	if(!fuel || !on)
		turn_off()
		STOP_PROCESSING(SSobj, src)


/obj/item/flashlight/flare/proc/turn_off()
	on = FALSE
	force = initial(force)
	damtype = initial(damtype)
	update_brightness()


/obj/item/flashlight/flare/attack_self(mob/user)
	// Usual checks
	if(!fuel)
		to_chat(user, "<span class='notice'>[src] is out of fuel.</span>")
		return
	if(on)
		to_chat(user, "<span class='notice'>[src] is already on.</span>")
		return

	. = ..()
	// All good, turn it on.
	if(.)
		user.visible_message("<span class='notice'>[user] activates [src].</span>", "<span class='notice'>You activate [src].</span>")
		if(produce_heat)
			force = on_damage
			damtype = BURN
		START_PROCESSING(SSobj, src)


// GLOWSTICKS

/obj/item/flashlight/flare/glowstick
	name = "green glowstick"
	desc = "A military-grade glowstick."
	light_range = 4
	color = LIGHT_COLOR_GREEN
	icon_state = "glowstick"
	item_state = "glowstick"
	togglesound = 'sound/effects/bone_break_1.ogg'
	can_fire_cigs = FALSE
	produce_heat = 0
	fuel_lower = 1600
	fuel_upp = 2000
	blocks_emissive = FALSE
	var/chemglow_sprite_type = "green"


/obj/item/flashlight/flare/glowstick/Initialize()
	light_color = color
	. = ..()


/obj/item/flashlight/flare/glowstick/update_icon_state()
	if(!fuel)
		icon_state = "glowstick-empty"


/obj/item/flashlight/flare/glowstick/update_overlays()
	. = ..()
	if(on)
		var/mutable_appearance/glowstick_overlay = mutable_appearance(icon, "glowstick-glow")
		glowstick_overlay.color = color
		. += glowstick_overlay


/obj/item/flashlight/flare/glowstick/red
	name = "red glowstick"
	color = LIGHT_COLOR_RED
	chemglow_sprite_type = "red"

/obj/item/flashlight/flare/glowstick/green
	name = "green glowstick"

/obj/item/flashlight/flare/glowstick/blue
	name = "blue glowstick"
	color = LIGHT_COLOR_BLUE
	chemglow_sprite_type = "blue"

/obj/item/flashlight/flare/glowstick/orange
	name = "orange glowstick"
	color = LIGHT_COLOR_ORANGE
	chemglow_sprite_type = "orange"

/obj/item/flashlight/flare/glowstick/yellow
	name = "yellow glowstick"
	color = LIGHT_COLOR_YELLOW
	chemglow_sprite_type = "yellow"

/obj/item/flashlight/flare/glowstick/pink
	name = "pink glowstick"
	color = LIGHT_COLOR_PINK
	chemglow_sprite_type = "pink"

/obj/item/flashlight/flare/glowstick/emergency
	name = "emergency glowstick"
	desc = "A cheap looking, mass produced glowstick. You can practically feel it was made on a tight budget."
	color = LIGHT_COLOR_BLUE
	fuel_lower = 30
	fuel_upp = 90
	chemglow_sprite_type = "blue"

/obj/item/flashlight/flare/glowstick/random
	name = "random colored glowstick"
	icon_state = "random_glowstick"
	color = null

/obj/item/flashlight/flare/glowstick/random/Initialize()
	. = ..()
	var/T = pick(typesof(/obj/item/flashlight/flare/glowstick) - /obj/item/flashlight/flare/glowstick/random - /obj/item/flashlight/flare/glowstick/emergency)
	new T(loc)
	qdel(src) // return INITIALIZE_HINT_QDEL <-- Doesn't work


/obj/item/flashlight/flare/extinguish_light(force = FALSE)
	if(force)
		fuel = 0
		visible_message(span_danger("[src] burns up rapidly!"))
	else
		visible_message(span_danger("[src] dims slightly before scattering the shadows around it."))

/obj/item/flashlight/flare/torch
	name = "torch"
	desc = "A torch fashioned from some leaves and a log."
	w_class = WEIGHT_CLASS_BULKY
	light_range = 7
	icon_state = "torch"
	item_state = "torch"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	light_color = LIGHT_COLOR_ORANGE
	on_damage = 10

/obj/item/flashlight/slime
	gender = PLURAL
	name = "glowing slime extract"
	desc = "A glowing ball of what appears to be amber."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "floor1" //not a slime extract sprite but... something close enough!
	item_state = "slime"
	w_class = WEIGHT_CLASS_TINY
	light_range = 6
	light_system = MOVABLE_LIGHT
	light_color = "#FFBF00"
	materials = list()
	on = TRUE //Bio-luminesence has one setting, on.


/obj/item/flashlight/slime/update_icon_state()
	return


/obj/item/flashlight/slime/attack_self(mob/user)
	return //Bio-luminescence does not toggle.

/obj/item/flashlight/slime/extinguish_light(force = FALSE)
	if(force)
		visible_message(span_danger("[src] withers away."))
		qdel(src)
	else
		visible_message(span_danger("[src] dims slightly before scattering the shadows around it."))

/obj/item/flashlight/emp
	origin_tech = "magnets=3;syndicate=1"

	var/emp_max_charges = 4
	var/emp_cur_charges = 4
	var/charge_tick = 0


/obj/item/flashlight/emp/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/flashlight/emp/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/flashlight/emp/process()
	charge_tick++
	if(charge_tick < 10)
		return FALSE
	charge_tick = 0
	emp_cur_charges = min(emp_cur_charges+1, emp_max_charges)
	return TRUE


/obj/item/flashlight/emp/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(on && user.zone_selected == BODY_ZONE_PRECISE_EYES) // call original attack proc only if aiming at the eyes
		return ..()
	return ATTACK_CHAIN_PROCEED


/obj/item/flashlight/emp/afterattack(atom/A, mob/user, proximity, params)
	if(!proximity)
		return
	if(emp_cur_charges > 0)
		emp_cur_charges -= 1
		if(ismob(A))
			var/mob/M = A
			add_attack_logs(user, M, "Hit with EMP-light")
		to_chat(user, "[src] now has [emp_cur_charges] charge\s.")
		A.emp_act(1)
	else
		to_chat(user, "<span class='warning'>\The [src] needs time to recharge!</span>")


/obj/item/flashlight/spotlight //invisible lighting source
	name = "disco light"
	desc = "Groovy..."
	icon_state = null
	light_system = STATIC_LIGHT
	light_color = null
	light_range = 0
	light_power = 10
	alpha = 0
	layer = 0
	on = TRUE
	anchored = TRUE
	var/range = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
