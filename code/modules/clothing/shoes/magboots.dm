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
	pickup_sound = 'sound/items/handling/boots_pickup.ogg'
	drop_sound = 'sound/items/handling/boots_drop.ogg'
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
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge! There's a red light on the side."
	name = "clown shoes"
	icon_state = "clownmag0"
	base_icon_state = "clownmag"
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


/obj/item/clothing/shoes/magboots/gravity
	name = "gravitational boots"
	ru_names = list(NOMINATIVE = "гравитационные ботинки", \
					GENITIVE = "гравитационных ботинок", \
					DATIVE = "гравитационным ботинкам", \
					ACCUSATIVE = "гравитационные ботинки", \
					INSTRUMENTAL = "гравитационными ботинками", \
					PREPOSITIONAL = "гравитационных ботинках")
	desc = "Эти экспериментальные магбутсы обходят замедление обычных, за счет миниатюрных гравитационных в подошвах. \
			К сожалению, для работы им необходимо ядро гравитационной аномалии."
	gender = PLURAL
	icon_state = "gravboots0"
	actions_types = list(/datum/action/item_action/toggle, /datum/action/item_action/gravity_jump) //combination of magboots and jumpboots
	strip_delay = 10 SECONDS
	put_on_delay = 10 SECONDS
	slowdown_active = 0
	base_icon_state = "gravboots"
	magpulse_name = "micro gravitational traction system"
	var/datum/martial_art/grav_stomp/style
	var/jumpdistance = 5
	var/jumpspeed = 3
	var/recharging_rate = 6 SECONDS
	var/recharging_time = 0 // Time until next dash
	var/dash_cost = 1000 // Cost to dash.
	var/power_consumption_rate = 30 // How much power is used by the boots each cycle when magboots are active
	var/obj/item/assembly/signaler/anomaly/core = null
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
		. += span_notice("[declent_ru(NOMINATIVE)] полностью функциональны!")
		. += span_notice("Ботинки заряжены на [round(cell.percent())]%.")
	else if(core)
		. += span_warning("В них установлено ядро ​​гравитационной аномалии, но не установлена батарейка.")
	else if(cell)
		. += span_warning("В них установлена батарейка, но не установлено ядро гравитационной аномалии.")
	else
		. += span_warning("В них не хватает ядра гравитационной аномалии и батарейки.")


/obj/item/clothing/shoes/magboots/gravity/toggle_magpulse(mob/user, silent = FALSE)
	if(silent && (!cell || !core || cell.charge <= power_consumption_rate && !magpulse))
		return

	if(!cell)
		user.balloon_alert("нет батарейки")
		return

	if(cell.charge <= power_consumption_rate && !magpulse)
		user.balloon_alert("недостаточно заряда")
		return

	if(!core)
		user.balloon_alert("нет ядра")
		return

	return ..()


/obj/item/clothing/shoes/magboots/gravity/process()
	if(!cell) //There should be a cell here, but safety first
		return

	if(cell.charge <= power_consumption_rate * 2)
		if(ishuman(loc))
			var/mob/living/carbon/human/user = loc
			to_chat(user, span_warning("[declent_ru(NOMINATIVE)] израсходовали весь заряд и отключились!"))
			toggle_magpulse(user, silent = TRUE)
	else
		cell.use(power_consumption_rate)

/obj/item/clothing/shoes/magboots/gravity/screwdriver_act(mob/living/user, obj/item/I)
	if(!cell)
		to_chat(user, span_warning("Внутри нет батарейки!"))
		return

	if(magpulse)
		to_chat(user, span_warning("Сначала выключите [declent_ru(ACCUSATIVE)]!"))
		return

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	cell.forceMove_turf()
	user.put_in_hands(cell, ignore_anim = FALSE)
	to_chat(user, span_notice("Вы достали [cell.declent_ru(ACCUSATIVE)] из [declent_ru(GENITIVE)]."))
	cell.update_icon()
	cell = null
	update_icon()


/obj/item/clothing/shoes/magboots/gravity/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stock_parts/cell))
		add_fingerprint(user)
		if(cell)
			to_chat(user, span_warning("В [declent_ru(PREPOSITIONAL)] уже есть батарейка."))
			return ATTACK_CHAIN_PROCEED

		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()

		to_chat(user, span_notice("Вы установили [I.declent_ru(ACCUSATIVE)] в [declent_ru(NOMINATIVE)]."))
		cell = I
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(iscoregrav(I))
		add_fingerprint(user)
		if(core)
			to_chat(user, span_warning("В [declent_ru(PREPOSITIONAL)] уже есть [core.declent_ru(NOMINATIVE)]."))
			return ATTACK_CHAIN_PROCEED

		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()

		to_chat(user, span_notice("Вы установили [I.declent_ru(ACCUSATIVE)] в [declent_ru(NOMINATIVE)]. Они немного потеплели."))
		core = I
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/clothing/shoes/magboots/gravity/AltClick(mob/user)
	if(!user.contains(src))
		return ..()

	if(!core)
		user.balloon_alert(user, "нет ядра")
		return

	user.put_in_active_hand(core)
	core = null
	user.balloon_alert(user, "ядро извлечено")

/obj/item/clothing/shoes/magboots/gravity/equipped(mob/user, slot, initial)
	. = ..()

	if(!ishuman(user))
		return

	if(slot == ITEM_SLOT_FEET && cell && core)
		style.bonus_damage = 10 * core.get_strenght() / 150
		style.teach(user, TRUE)


/obj/item/clothing/shoes/magboots/gravity/dropped(mob/living/carbon/human/user, slot, silent = FALSE)
	. = ..()
	if(!ishuman(user) || slot != ITEM_SLOT_FEET)
		return .

	style.remove(user)
	if(!magpulse)
		return

	if(!silent)
		to_chat(user, span_notice("Как только вы сняли [declent_ru(NOMINATIVE)] они автоматически деактивировались."))

	toggle_magpulse(user, silent = TRUE)


/obj/item/clothing/shoes/magboots/gravity/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_FEET)
		return TRUE

/obj/item/clothing/shoes/magboots/gravity/proc/dash(mob/user, action)
	if(!isliving(user))
		return

	if(!cell)
		user.balloon_alert("нет батарейки")
		return

	if(cell.charge <= dash_cost)
		user.balloon_alert("недостаточно заряда")
		return

	if(!core)
		user.balloon_alert("нет ядра")
		return

	if(recharging_time > world.time)
		user.balloon_alert("идет перезарядка")
		return

	if(user.throwing)
		user.balloon_alert("нет опоры")
		return

	var/jump_mult = core.get_strenght() / 150
	var/cur_jumpdistance = jumpdistance * jump_mult
	var/cur_jumpjumpspeed = jumpspeed * jump_mult
	var/turf/T = get_step(get_turf(user), user.dir)
	for(var/i = 1 to cur_jumpdistance)
		if(!T.can_enter(user))
			cur_jumpjumpspeed = max(3, jumpspeed * jump_mult * (cur_jumpdistance / i))
			cur_jumpdistance = i
			break

		T = get_step(T, user.dir)

	var/atom/target = get_edge_target_turf(user, user.dir) //gets the user's direction
	ADD_TRAIT(user, TRAIT_MOVE_FLYING, ITEM_GRAV_BOOTS_TRAIT)
	var/after_jump_callback = CALLBACK(src, PROC_REF(after_jump), user)
	if(user.throw_at(target, cur_jumpdistance, cur_jumpjumpspeed, spin = FALSE, diagonals_first = TRUE, callback = after_jump_callback))
		playsound(src, 'sound/effects/stealthoff.ogg', 50, 1, 1)
		user.visible_message(span_warning("[user] прыгает вперед!"))
		recharging_time = world.time + recharging_rate
		cell.use(dash_cost)
		return

	after_jump(user)
	to_chat(user, span_warning("Что-то помешало вам прыгнуть!"))


/obj/item/clothing/shoes/magboots/gravity/proc/after_jump(mob/user)
	REMOVE_TRAIT(user, TRAIT_MOVE_FLYING, ITEM_GRAV_BOOTS_TRAIT)

