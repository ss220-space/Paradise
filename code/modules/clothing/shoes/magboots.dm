/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	origin_tech = "materials=3;magnets=4;engineering=4"
	var/magboot_state = "magboots"
	var/magpulse = FALSE
	var/slowdown_active = 2
	var/slowdown_passive = SHOES_SLOWDOWN
	var/magpulse_name = "mag-pulse traction system"
	var/gustprotection = FALSE									//this is for unsafe_unwrenching protection
	var/lubeprotection = FALSE									//this is for lube protection when magpulse
	actions_types = list(/datum/action/item_action/toggle)
	strip_delay = 70
	put_on_delay = 70
	resistance_flags = FIRE_PROOF
	pickup_sound = 'sound/items/handling/boots_pickup.ogg'
	drop_sound = 'sound/items/handling/boots_drop.ogg'

/obj/item/clothing/shoes/magboots/atmos
	desc = "Magnetic boots, made to withstand gusts of space wind over 500kmph."
	name = "atmospheric magboots"
	icon_state = "atmosmagboots0"
	magboot_state = "atmosmagboots"
	gustprotection = TRUE

/obj/item/clothing/shoes/magboots/security
	name = "combat magboots"
	desc = "Combat-edition magboots issued by Nanotrasen Security for extravehicular missions."
	icon_state = "cmagboots0"
	magboot_state = "cmagboots"
	armor = list("melee" = 30, "bullet" = 20, "laser" = 25, "energy" = 25, "bomb" = 60, "bio" = 30, "rad" = 30, "fire" = 90, "acid" = 50)
	slowdown_active = 1

/obj/item/clothing/shoes/magboots/security/captain
	name = "captain's greaves"
	desc = "A relic predating magboots, these ornate greaves have retractable spikes in the soles to maintain grip."
	icon_state = "capboots0"
	magboot_state = "capboots"
	magpulse_name = "anchoring spikes"
	slowdown_active = 2


/obj/item/clothing/shoes/magboots/update_icon_state()
	icon_state = "[magboot_state][magpulse]"


/obj/item/clothing/shoes/magboots/attack_self(mob/user, forced = FALSE)
	toggle_magpulse(user, forced)


/obj/item/clothing/shoes/magboots/proc/toggle_magpulse(mob/user, forced)
	if(magpulse)
		START_PROCESSING(SSobj, src) //Gravboots
		flags &= ~NOSLIP
		slowdown = slowdown_passive
	else
		STOP_PROCESSING(SSobj, src)
		flags |= NOSLIP
		slowdown = slowdown_active
	magpulse = !magpulse
	update_icon(UPDATE_ICON_STATE)
	if(!forced)
		to_chat(user, "You [magpulse ? "enable" : "disable"] the [magpulse_name].")
	user.update_gravity(user.mob_has_gravity())
	update_equipped_item()


/obj/item/clothing/shoes/magboots/negates_gravity()
	return (flags & NOSLIP)

/obj/item/clothing/shoes/magboots/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Its [magpulse_name] appears to be [magpulse ? "enabled" : "disabled"].</span>"

/obj/item/clothing/shoes/magboots/advance
	desc = "Advanced magnetic boots that have a lighter magnetic pull, placing less burden on the wearer."
	name = "advanced magboots"
	icon_state = "advmag0"
	magboot_state = "advmag"
	gustprotection = TRUE
	slowdown_active = SHOES_SLOWDOWN
	origin_tech = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/magboots/syndie
	desc = "Reverse-engineered magnetic boots that have a heavy magnetic pull. Property of Gorlex Marauders."
	name = "blood-red magboots"
	icon_state = "syndiemag0"
	magboot_state = "syndiemag"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 25, "energy" = 25, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 90, "acid" = 50)
	origin_tech = "magnets=4;syndicate=2"

/obj/item/clothing/shoes/magboots/syndie/advance //For the Syndicate Strike Team and Nuclear operative
	desc = "Reverse-engineered magboots that appear to be based on an advanced model, as they have a lighter magnetic pull. Property of Gorlex Marauders."
	name = "advanced blood-red magboots"
	icon_state = "advsyndiemag0"
	magboot_state = "advsyndiemag"
	slowdown_active = SHOES_SLOWDOWN
	lubeprotection = TRUE

/obj/item/clothing/shoes/magboots/clown
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge! There's a red light on the side."
	name = "clown shoes"
	icon_state = "clownmag0"
	magboot_state = "clownmag"
	item_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	slowdown_active = SHOES_SLOWDOWN+1
	slowdown_passive = SHOES_SLOWDOWN+1
	magpulse_name = "honk-powered traction system"
	item_color = "clown"
	origin_tech = "magnets=4;syndicate=2"
	pickup_sound = 'sound/items/handling/shoes_pickup.ogg'
	drop_sound = 'sound/items/handling/shoes_drop.ogg'
	var/enabled_waddle = TRUE

/obj/item/clothing/shoes/magboots/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg' = 1, 'sound/effects/clownstep2.ogg' = 1), 50, falloff_exponent = 20) //die off quick please

/obj/item/clothing/shoes/magboots/clown/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == SLOT_HUD_SHOES && enabled_waddle)
		user.AddElement(/datum/element/waddling)

/obj/item/clothing/shoes/magboots/clown/dropped(mob/user, silent = FALSE)
	. = ..()
	user.RemoveElement(/datum/element/waddling)

/obj/item/clothing/shoes/magboots/clown/CtrlClick(mob/living/user)
	if(!isliving(user))
		return
	if(user.get_active_hand() != src)
		to_chat(user, "You must hold [src] in your hand to do this.")
		return
	if(!enabled_waddle)
		to_chat(user, "<span class='notice'>You switch off the waddle dampeners!</span>")
		enabled_waddle = TRUE
	else
		to_chat(user, "<span class='notice'>You switch on the waddle dampeners!</span>")
		enabled_waddle = FALSE

/obj/item/clothing/shoes/magboots/wizard //bundled with the wiz hardsuit
	name = "boots of gripping"
	desc = "These magical boots, once activated, will stay gripped to any surface without slowing you down."
	icon_state = "wizmag0"
	magboot_state = "wizmag"
	slowdown_active = SHOES_SLOWDOWN //wiz hardsuit already slows you down, no need to double it
	magpulse_name = "gripping ability"
	magical = TRUE
	light_system = MOVABLE_LIGHT
	light_on = FALSE
	light_range = 2
	light_power = 1

/obj/item/clothing/shoes/magboots/wizard/attack_self(mob/user)
	if(user)
		if(user.mind in SSticker.mode.wizards)
			if(magpulse) //faint blue light when shoes are turned on gives a reason to turn them off when not needed in maint
				set_light_on(FALSE)
			else
				set_light_on(TRUE)
			..()
		else
			to_chat(user, "<span class='notice'>You poke the gem on [src]. Nothing happens.</span>")

/obj/item/clothing/shoes/magboots/gravity
	name = "gravitational boots"
	desc = "These experimental boots try to get around the restrictions of magboots by installing miniture gravitational generators in the soles. Sadly, power hungry, and needs a gravitational anomaly core."
	icon_state = "gravboots0"
	actions_types = list(/datum/action/item_action/toggle, /datum/action/item_action/gravity_jump) //combination of magboots and jumpboots
	strip_delay = 10 SECONDS
	put_on_delay = 10 SECONDS
	slowdown_active = 0
	magboot_state = "gravboots"
	magpulse_name = "micro gravitational traction system"
	var/datum/martial_art/grav_stomp/style
	var/jumpdistance = 5
	var/jumpspeed = 3
	var/recharging_rate = 6 SECONDS
	var/recharging_time = 0 // Time until next dash
	var/dash_cost = 1000 // Cost to dash.
	var/power_consumption_rate = 30 // How much power is used by the boots each cycle when magboots are active
	var/obj/item/assembly/signaler/anomaly/grav/core = null
	var/obj/item/stock_parts/cell/cell = null


/obj/item/clothing/shoes/magboots/gravity/Initialize()
	. = ..()
	style = new()


/obj/item/clothing/shoes/magboots/gravity/Destroy()
	QDEL_NULL(style)
	QDEL_NULL(cell)
	QDEL_NULL(core)
	return ..()

/obj/item/clothing/shoes/magboots/gravity/examine(mob/user)
	. = ..()
	if(core && cell)
		. += "<span class='notice'>[src] are fully operational!</span>"
		. += "<span class='notice'>The boots are [round(cell.percent())]% charged.</span>"
	else if(core)
		. += "<span class='warning'>It has a gravitational anomaly core installed, but no power cell installed.</span>"
	else if(cell)
		. += "<span class='warning'>It has a power installed, but no gravitational anomaly core installed.</span>"
	else
		. += "<span class='warning'>It is missing a gravitational anomaly core and a power cell.</span>"


/obj/item/clothing/shoes/magboots/gravity/toggle_magpulse(mob/user, forced)
	if(!cell)
		to_chat(user, "<span class='warning'>Your boots do not have a power cell!</span>")
		return
	else if(cell.charge <= power_consumption_rate && !magpulse)
		to_chat(user, "<span class='warning'>Your boots do not have enough charge!</span>")
		return
	if(!core)
		to_chat(user, "<span class='warning'>There's no core installed!</span>")
		return
	return ..()


/obj/item/clothing/shoes/magboots/gravity/process()
	if(!cell) //There should be a cell here, but safety first
		return
	if(cell.charge <= power_consumption_rate * 2)
		if(ishuman(loc))
			var/mob/living/carbon/human/user = loc
			to_chat(user, "<span class='warning'>[src] has ran out of charge, and turned off!</span>")
			attack_self(user, TRUE)
	else
		cell.use(power_consumption_rate)

/obj/item/clothing/shoes/magboots/gravity/screwdriver_act(mob/living/user, obj/item/I)
	if(!cell)
		to_chat(user, "<span class='warning'>There's no cell installed!</span>")
		return

	if(magpulse)
		to_chat(user, "<span class='warning'>Turn off the boots first!</span>")
		return

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	cell.forceMove_turf()
	user.put_in_hands(cell, ignore_anim = FALSE)
	to_chat(user, "<span class='notice'>You remove [cell] from [src].</span>")
	cell.update_icon()
	cell = null
	update_icon()

/obj/item/clothing/shoes/magboots/gravity/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, "<span class='warning'>[src] already has a cell!</span>")
			return
		if(!user.drop_transfer_item_to_loc(I, src))
			return
		cell = I
		to_chat(user, "<span class='notice'>You install [I] into [src].</span>")
		update_icon()
		return

	if(istype(I, /obj/item/assembly/signaler/anomaly/grav))
		if(core)
			to_chat(user, "<span class='notice'>[src] already has a [I]!</span>")
			return
		if(!user.drop_transfer_item_to_loc(I, src))
			to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
			return
		to_chat(user, "<span class='notice'>You insert [I] into [src], and [src] starts to warm up.</span>")
		core = I
	else
		return ..()

/obj/item/clothing/shoes/magboots/gravity/equipped(mob/user, slot, initial)
	. = ..()

	if(!ishuman(user))
		return
	if(slot == SLOT_HUD_SHOES && cell && core)
		style.teach(user, TRUE)

/obj/item/clothing/shoes/magboots/gravity/dropped(mob/user, silent = FALSE)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(SLOT_HUD_SHOES) == src)
		style.remove(H)
		if(magpulse)
			to_chat(user, "<span class='notice'>As [src] are removed, they deactivate.</span>")
			attack_self(user, TRUE)

/obj/item/clothing/shoes/magboots/gravity/item_action_slot_check(slot)
	if(slot == SLOT_HUD_SHOES)
		return TRUE

/obj/item/clothing/shoes/magboots/gravity/proc/dash(mob/user, action)
	if(!isliving(user))
		return

	if(cell)
		if(cell.charge <= dash_cost)
			to_chat(user, "<span class='warning'>Your boots do not have enough charge to dash!</span>")
			return
	else
		to_chat(user, "<span class='warning'>Your boots do not have a power cell!</span>")
		return

	if(!core)
		to_chat(user, "<span class='warning'>There's no core installed!</span>")
		return

	if(recharging_time > world.time)
		to_chat(user, "<span class='warning'>The boot's gravitational pulse needs to recharge still!</span>")
		return

	var/atom/target = get_edge_target_turf(user, user.dir) //gets the user's direction
	ADD_TRAIT(user, TRAIT_MOVE_FLYING, ITEM_GRAV_BOOTS_TRAIT)
	var/after_jump_callback = CALLBACK(src, PROC_REF(after_jump), user)
	if(user.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE, callback = after_jump_callback))
		playsound(src, 'sound/effects/stealthoff.ogg', 50, 1, 1)
		user.visible_message("<span class='warning'>[usr] dashes forward into the air!</span>")
		recharging_time = world.time + recharging_rate
		cell.use(dash_cost)
	else
		after_jump(user)
		to_chat(user, "<span class='warning'>Something prevents you from dashing forward!</span>")


/obj/item/clothing/shoes/magboots/gravity/proc/after_jump(mob/user)
	REMOVE_TRAIT(user, TRAIT_MOVE_FLYING, ITEM_GRAV_BOOTS_TRAIT)

