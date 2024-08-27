/obj/item/memorizer
	name = "memorizer"
	desc = "If you see this, you're not likely to remember it any time soon."
	icon = 'icons/obj/device.dmi'
	icon_state = "memorizer"
	item_state = "nullrod"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT

	var/times_used = 0 //Number of times it's been used.
	var/broken = FALSE     //Is the flash burnt out?
	var/last_used = 0 //last world.time it was used.
	var/battery_panel = FALSE //whether the flash can be modified with a cell or not
	var/overcharged = FALSE   //if overcharged the flash will set people on fire then immediately burn out (does so even if it doesn't blind them).
	var/can_overcharge = FALSE //set this to FALSE if you don't want your flash to be overcharge capable
	var/use_sound = 'sound/weapons/flash.ogg'


/obj/item/memorizer/update_icon_state()
	icon_state = "memorizer[broken ? "burnt" : ""]"


/obj/item/memorizer/update_overlays()
	. = ..()
	if(overcharged)
		. += "overcharge"


/obj/item/memorizer/proc/clown_check(mob/user)
	if(user && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		memorize_carbon(user, user, 15, FALSE)
		return FALSE
	return TRUE


/obj/item/memorizer/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!can_overcharge)
		to_chat(user, span_warning("This [name] has no panel!"))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	battery_panel = !battery_panel
	to_chat(user, span_notice("You [battery_panel ? "open" : "close"] the battery compartment on [src]."))


/obj/item/memorizer/attackby(obj/item/I, mob/user, params)
	if(!can_overcharge || !istype(I, /obj/item/stock_parts/cell))
		return ..()
	add_fingerprint(user)
	if(!battery_panel)
		to_chat(user, span_warning("You need to open the panel first!"))
		return ATTACK_CHAIN_PROCEED
	if(overcharged)
		to_chat(user, span_warning("The [name] is already overcharged!"))
		return ATTACK_CHAIN_PROCEED
	if(!user.drop_transfer_item_to_loc(I, src))
		return ..()
	. = ATTACK_CHAIN_BLOCKED_ALL
	to_chat(user,  span_notice("You jam the cell into the battery compartment on [src]."))
	overcharged = TRUE
	update_icon(UPDATE_OVERLAYS)
	qdel(I)


/obj/item/memorizer/proc/burn_out() //Made so you can override it if you want to have an invincible flash from R&D or something.
	broken = TRUE
	update_icon(UPDATE_ICON_STATE)
	visible_message("<span class='notice'>The [name] burns out!</span>")


/obj/item/memorizer/proc/flash_recharge(mob/user)
	if(prob(times_used * 2))	//if you use it 5 times in a minute it has a 10% chance to break!
		burn_out()
		return FALSE

	var/deciseconds_passed = world.time - last_used
	times_used -= round(deciseconds_passed / 100)

	last_used = world.time
	times_used = max(0, times_used) //sanity


/obj/item/memorizer/proc/try_use_flash(mob/user)
	flash_recharge(user)

	if(broken)
		return FALSE

	playsound(loc, use_sound, 100, 1)
	flick("[initial(icon_state)]2", src)
	set_light(2, 1, COLOR_WHITE, l_on = TRUE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light_on), FALSE), 2)
	times_used++

	if(user && !clown_check(user))
		return FALSE

	return TRUE


/obj/item/memorizer/proc/memorize_carbon(mob/living/carbon/fucking_target, mob/user, power = 10 SECONDS, targeted = TRUE)
	if(user)
		add_attack_logs(user, fucking_target, "memorized with [src]")
		if(targeted)
			if(fucking_target.weakeyes)
				fucking_target.Weaken(3) //quick weaken bypasses eye protection but has no eye flash
			if(fucking_target.flash_eyes(1, TRUE))
				fucking_target.AdjustConfused(power)
				fucking_target.Stun(2 SECONDS)
				visible_message(span_disarm("[user] erases [fucking_target] memory with the memorizer!"))
				to_chat(user, span_danger("You erased [fucking_target] memory with the memorizer!"))
				to_chat(fucking_target, span_danger("<span class='reallybig'>Your memory about last events has been erased!"))
				if(fucking_target.weakeyes)
					fucking_target.Stun(4 SECONDS)
					fucking_target.visible_message(span_disarm("[fucking_target] gasps and shields [fucking_target.p_their()] eyes!"), span_userdanger("You gasp and shield your eyes!"))
			else
				visible_message(span_disarm("[user] fails to erase [fucking_target] memory with the memorizer!"))
				to_chat(user, span_warning("You fail to erase [fucking_target] memory with the memorizer!"))
				to_chat(fucking_target, span_danger("[user] fails to erase your memory with the memorizer!"))
			return

	if(fucking_target.flash_eyes())
		fucking_target.AdjustConfused(power)


/obj/item/memorizer/attack(mob/living/fucking_target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(!try_use_flash(user))
		return .
	if(iscarbon(fucking_target))
		memorize_carbon(fucking_target, user, 5, TRUE)
		if(overcharged)
			fucking_target.adjust_fire_stacks(6)
			fucking_target.IgniteMob()
			burn_out()
		return .|ATTACK_CHAIN_SUCCESS
	else if(issilicon(fucking_target))
		add_attack_logs(user, fucking_target, "Flashed with [src]")
		if(fucking_target.flash_eyes(affect_silicon = TRUE))
			fucking_target.Weaken(rand(10 SECONDS, 20 SECONDS))
			user.visible_message(span_disarm("[user] overloads [fucking_target]'s sensors with the [name]!"), span_danger("You overload [fucking_target]'s sensors with the [name]!"))
		return .|ATTACK_CHAIN_SUCCESS
	user.visible_message(span_disarm("[user] fails to blind [fucking_target] with the [name]!"), span_warning("You fail to blind [fucking_target] with the [name]!"))


/obj/item/memorizer/attack_self(mob/living/carbon/user, flag = 0, emp = FALSE)
	if(!try_use_flash(user))
		return FALSE
	user.visible_message("<span class='disarm'>[user]'s [src.name] emits a blinding light!</span>", "<span class='danger'>Your [src.name] emits a blinding light!</span>")
	for(var/mob/living/carbon/fucking_target in oviewers(3, get_turf(src)))
		memorize_carbon(fucking_target, user, 3, FALSE)


/obj/item/memorizer/emp_act(severity)
	if(!try_use_flash())
		return FALSE
	for(var/mob/living/carbon/fucking_target in viewers(3, get_turf(src)))
		memorize_carbon(fucking_target, null, 10, TRUE)
	burn_out()

/obj/item/memorizer/syndicate
	name = "Нейрализатор"
	desc = "Если перед вами сработает это устройство, скорее всего вы не сможете об этом вспомнить!"
	origin_tech = "abductor=3;syndicate=2"

/obj/item/memorizer/syndicate/memorize_carbon(mob/living/carbon/fucking_target, mob/user = null, power = 10 SECONDS, targeted = TRUE)
	if(user)
		add_attack_logs(user, fucking_target, "[user] стёр память [fucking_target] с помощью [src]а")
		if(targeted)
			if(!fucking_target.mind)
				to_chat(user, span_danger("[fucking_target] кататоник! Стирание памяти бесполезно против тех, кто не осознаёт ничего вокруг себя!"))
				return
			if(fucking_target.weakeyes)
				fucking_target.Weaken(6 SECONDS) //quick weaken bypasses eye protection but has no eye flash
			if(fucking_target.flash_eyes(1, TRUE))
				fucking_target.AdjustConfused(power)
				fucking_target.Stun(2 SECONDS)
				visible_message(span_disarm("[user] стирает память [fucking_target] с помощью Нейрализатора!"))
				to_chat(user, span_danger("Вы стёрли память [fucking_target] с помощью Нейрализатора!"))
				to_chat(fucking_target, span_danger(span_reallybig("Ваша память о последних недавних событиях была стёрта!")))
				if(is_taipan(fucking_target.z) && !fucking_target.mind.lost_memory)
					var/objective = "Вы не помните ничего о последних событиях, так как ваша память была стёрта. \
					В частности вы не помните о базе синдиката \"Тайпан\", о том как туда добраться и обо всём так или иначе с ней связанным!"
					var/datum/objective/custom_objective = new(objective)
					custom_objective.needs_target = FALSE
					custom_objective.owner = fucking_target.mind
					fucking_target.mind.objectives += custom_objective
					fucking_target.mind.lost_memory = TRUE
					var/list/messages = fucking_target.mind.prepare_announce_objectives()
					to_chat(fucking_target, chat_box_red(messages.Join("<br>")))
				last_used = world.time
				if(fucking_target.weakeyes)
					fucking_target.Stun(4 SECONDS)
					fucking_target.visible_message(span_disarm("[fucking_target] моргает, тем самым защищая свои глаза!"), span_userdanger("Вы моргнули и защитили свои глаза!"))
			else
				visible_message(span_disarm("У [user] не получилось стереть память [fucking_target] с помощью \"Нейрализатора\"!"))
				to_chat(user, span_warning("Вы не смогли стереть память [fucking_target] с помощью \"Нейрализатора\"!"))
				to_chat(fucking_target, span_danger("У [user] не получилось стереть вашу память с помощью \"Нейрализатора\"!"))
			return

	if(fucking_target.flash_eyes())
		fucking_target.AdjustConfused(power)
