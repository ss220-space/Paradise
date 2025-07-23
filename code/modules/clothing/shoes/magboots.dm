/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	origin_tech = "materials=3;magnets=4;engineering=4"
	base_icon_state = "magboots"
	actions_types = list(/datum/action/item_action/toggle)
	strip_delay = 70
	put_on_delay = 70
	resistance_flags = FIRE_PROOF
	pickup_sound = 'sound/items/handling/pickup/boots_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/boots_drop.ogg'
	/// Fluff name for our magpulse system.
	var/magpulse_name = "mag-pulse traction system"
	/// Whether the magpulse system is active
	var/magpulse = FALSE
	/// Slowdown applied when magpulse is inactive.
	var/slowdown_passive = SHOES_SLOWDOWN
	/// Slowdown applied when magpulse is active. This is added onto slowdown_passive
	var/slowdown_active = 2
	/// A list of traits we apply when we get activated
	var/list/active_traits = list(TRAIT_NEGATES_GRAVITY, TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_SLIDE)

/obj/item/clothing/shoes/magboots/atmos
	desc = "Magnetic boots, made to withstand gusts of space wind over 500kmph."
	name = "atmospheric magboots"
	icon_state = "atmosmagboots0"
	base_icon_state = "atmosmagboots"
	active_traits = list(TRAIT_NEGATES_GRAVITY, TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_SLIDE, TRAIT_GUSTPROTECTION)

/obj/item/clothing/shoes/magboots/security
	name = "combat magboots"
	desc = "Combat-edition magboots issued by Nanotrasen Security for extravehicular missions."
	icon_state = "cmagboots0"
	base_icon_state = "cmagboots"
	armor = list("melee" = 30, "bullet" = 20, "laser" = 25, "energy" = 25, "bomb" = 60, "bio" = 30, "rad" = 30, "fire" = 90, "acid" = 50)
	slowdown_active = 1

/obj/item/clothing/shoes/magboots/security/captain
	name = "captain's greaves"
	desc = "A relic predating magboots, these ornate greaves have retractable spikes in the soles to maintain grip."
	icon_state = "capboots0"
	base_icon_state = "capboots"
	magpulse_name = "anchoring spikes"
	slowdown_active = 2


/obj/item/clothing/shoes/magboots/update_icon_state()
	icon_state = "[base_icon_state][magpulse]"


/obj/item/clothing/shoes/magboots/attack_self(mob/user)
	toggle_magpulse(user)


/obj/item/clothing/shoes/magboots/proc/toggle_magpulse(mob/user, silent = FALSE)
	magpulse = !magpulse
	if(magpulse)
		START_PROCESSING(SSobj, src) //Gravboots
		attach_clothing_traits(active_traits)
		slowdown = slowdown_active
	else
		STOP_PROCESSING(SSobj, src)
		detach_clothing_traits(active_traits)
		slowdown = slowdown_passive
	update_icon(UPDATE_ICON_STATE)
	if(!silent)
		to_chat(user, "You [magpulse ? "enable" : "disable"] the [magpulse_name].")
	update_equipped_item()


/obj/item/clothing/shoes/magboots/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Its [magpulse_name] appears to be [magpulse ? "enabled" : "disabled"].</span>"

/obj/item/clothing/shoes/magboots/advance
	desc = "Advanced magnetic boots that have a lighter magnetic pull, placing less burden on the wearer."
	name = "advanced magboots"
	icon_state = "advmag0"
	base_icon_state = "advmag"
	active_traits = list(TRAIT_NEGATES_GRAVITY, TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_SLIDE, TRAIT_GUSTPROTECTION)
	slowdown_active = SHOES_SLOWDOWN
	origin_tech = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/magboots/advance/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/clothing/shoes/magboots/syndie
	desc = "Reverse-engineered magnetic boots that have a heavy magnetic pull. Property of Gorlex Marauders."
	name = "blood-red magboots"
	icon_state = "syndiemag0"
	base_icon_state = "syndiemag"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 25, "energy" = 25, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 90, "acid" = 50)
	origin_tech = "magnets=4;syndicate=2"

/obj/item/clothing/shoes/magboots/syndie/advance //For the Syndicate Strike Team and Nuclear operative
	desc = "Reverse-engineered magboots that appear to be based on an advanced model, as they have a lighter magnetic pull. Property of Gorlex Marauders."
	name = "advanced blood-red magboots"
	icon_state = "advsyndiemag0"
	base_icon_state = "advsyndiemag"
	slowdown_active = SHOES_SLOWDOWN
	active_traits = list(TRAIT_NEGATES_GRAVITY, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_SLIDE, TRAIT_GUSTPROTECTION)

/obj/item/clothing/shoes/magboots/clown
	name = "clown shoes"
	desc = "Это обычные башмаки клоуна. Чёрт возьми, они такие огромные! Сбоку мигает красная лампочка."
	ru_names = list(
		NOMINATIVE = "клоунские башмаки",
		GENITIVE = "клоунских башмаков",
		DATIVE = "клоунским башмакам",
		ACCUSATIVE = "клоунские башмаки",
		INSTRUMENTAL = "клоунскими башмаками",
		PREPOSITIONAL = "клоунских башмаках"
	)
	icon_state = "clownmag0"
	base_icon_state = "clownmag"
	item_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	slowdown_active = SHOES_SLOWDOWN+1
	slowdown_passive = SHOES_SLOWDOWN+1
	magpulse_name = "honk-powered traction system"
	item_color = "clown"
	origin_tech = "magnets=4;syndicate=2"
	pickup_sound = 'sound/items/handling/pickup/shoes_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/shoes_drop.ogg'
	var/enabled_waddle = TRUE

/obj/item/clothing/shoes/magboots/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg', 'sound/effects/clownstep2.ogg'), 50, falloff_exponent = 20) //die off quick please

/obj/item/clothing/shoes/magboots/clown/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_FEET && enabled_waddle)
		user.AddElement(/datum/element/waddling)

/obj/item/clothing/shoes/magboots/clown/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_FEET && enabled_waddle)
		user.RemoveElement(/datum/element/waddling)

/obj/item/clothing/shoes/magboots/clown/CtrlClick(mob/living/user)
	if(!isliving(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(user.get_active_hand() != src)
		balloon_alert(user, "нужно держать в руках!")
		return
	if(!enabled_waddle)
		balloon_alert(user, "развалочка включена")
		enabled_waddle = TRUE
	else
		balloon_alert(user, "развалочка выключена")
		enabled_waddle = FALSE

/obj/item/clothing/shoes/magboots/wizard //bundled with the wiz hardsuit
	name = "boots of gripping"
	desc = "These magical boots, once activated, will stay gripped to any surface without slowing you down."
	icon_state = "wizmag0"
	base_icon_state = "wizmag"
	slowdown_active = SHOES_SLOWDOWN //wiz hardsuit already slows you down, no need to double it
	magpulse_name = "gripping ability"
	magical = TRUE
	light_system = MOVABLE_LIGHT
	light_on = FALSE
	light_range = 2
	light_power = 1


/obj/item/clothing/shoes/magboots/wizard/toggle_magpulse(mob/user, silent = FALSE)
	if(!user || !user.mind)
		return

	if(user.mind in SSticker.mode.wizards)
		if(magpulse) //faint blue light when shoes are turned on gives a reason to turn them off when not needed in maint
			set_light_on(FALSE)
		else
			set_light_on(TRUE)
		..()
		return

	if(!silent)
		to_chat(user, span_notice("You poke the gem on [src]. Nothing happens."))

