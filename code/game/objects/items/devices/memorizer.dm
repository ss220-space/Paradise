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

/obj/item/memorizer/proc/clown_check(mob/user)
	if(user && (CLUMSY in user.mutations) && prob(50))
		memorize_carbon(user, user, 15, FALSE)
		return FALSE
	return TRUE

/obj/item/memorizer/attackby(obj/item/W, mob/user, params)
	if(!can_overcharge)
		return
	if(istype(W, /obj/item/screwdriver))
		battery_panel = !battery_panel
		if(battery_panel)
			to_chat(user, "<span class='notice'>You open the battery compartment on the [src].</span>")
		else
			to_chat(user, "<span class='notice'>You close the battery compartment on the [src].</span>")
	else if(istype(W, /obj/item/stock_parts/cell))
		if(!battery_panel || overcharged)
			return
		to_chat(user, "<span class='notice'>You jam the cell into battery compartment on the [src].</span>")
		qdel(W)
		overcharged = TRUE
		overlays += "overcharge"

/obj/item/memorizer/proc/burn_out() //Made so you can override it if you want to have an invincible flash from R&D or something.
	broken = TRUE
	icon_state = "[initial(icon_state)]burnt"
	visible_message("<span class='notice'>The [src.name] burns out!</span>")


/obj/item/memorizer/proc/flash_recharge(var/mob/user)
	if(prob(times_used * 2))	//if you use it 5 times in a minute it has a 10% chance to break!
		burn_out()
		return FALSE

	var/deciseconds_passed = world.time - last_used
	times_used -= round(deciseconds_passed / 100)

	last_used = world.time
	times_used = max(0, times_used) //sanity


/obj/item/memorizer/proc/try_use_flash(mob/user = null)
	flash_recharge(user)

	if(broken)
		return FALSE

	playsound(loc, use_sound, 100, 1)
	flick("[initial(icon_state)]2", src)
	set_light(2, 1, COLOR_WHITE)
	addtimer(CALLBACK(src, /atom./proc/set_light, 0), 2)
	times_used++

	if(user && !clown_check(user))
		return FALSE

	return TRUE


/obj/item/memorizer/proc/memorize_carbon(mob/living/carbon/Mob, mob/user = null, power = 5, targeted = TRUE)
	if(user)
		add_attack_logs(user, Mob, "memorized with [src]")
		if(targeted)
			if(Mob.weakeyes)
				Mob.Weaken(3) //quick weaken bypasses eye protection but has no eye flash
			if(Mob.flash_eyes(1, 1))
				Mob.AdjustConfused(power)
				Mob.Stun(1)
				visible_message("<span class='disarm'>[user] erases [Mob] memory with the memorizer!</span>")
				to_chat(user, "<span class='danger'>You erased [Mob] memory with the memorizer!</span>")
				to_chat(Mob, "<span class='danger'><span class='reallybig'>Your memory about last events has been erased!</span>")
				if(Mob.weakeyes)
					Mob.Stun(2)
					Mob.visible_message("<span class='disarm'>[Mob] gasps and shields [Mob.p_their()] eyes!</span>", "<span class='userdanger'>You gasp and shield your eyes!</span>")
			else
				visible_message("<span class='disarm'>[user] fails to erase [Mob] memory with the memorizer!</span>")
				to_chat(user, "<span class='warning'>You fail to erase [Mob] memory with the memorizer!</span>")
				to_chat(Mob, "<span class='danger'>[user] fails to erase your memory with the memorizer!</span>")
			return

	if(Mob.flash_eyes())
		Mob.AdjustConfused(power)

/obj/item/memorizer/attack(mob/living/Mob, mob/user)
	if(!try_use_flash(user))
		return FALSE
	if(iscarbon(Mob))
		memorize_carbon(Mob, user, 5, TRUE)
		if(overcharged)
			Mob.adjust_fire_stacks(6)
			Mob.IgniteMob()
			burn_out()
		return TRUE
	else if(issilicon(Mob))
		add_attack_logs(user, Mob, "Flashed with [src]")
		if(Mob.flash_eyes(affect_silicon = TRUE))
			Mob.Weaken(rand(5,10))
			user.visible_message("<span class='disarm'>[user] overloads [Mob]'s sensors with the [src.name]!</span>", "<span class='danger'>You overload [Mob]'s sensors with the [src.name]!</span>")
		return TRUE
	user.visible_message("<span class='disarm'>[user] fails to blind [Mob] with the [src.name]!</span>", "<span class='warning'>You fail to blind [Mob] with the [src.name]!</span>")


/obj/item/memorizer/attack_self(mob/living/carbon/user, flag = 0, emp = FALSE)
	if(!try_use_flash(user))
		return FALSE
	user.visible_message("<span class='disarm'>[user]'s [src.name] emits a blinding light!</span>", "<span class='danger'>Your [src.name] emits a blinding light!</span>")
	for(var/mob/living/carbon/Mob in oviewers(3, null))
		memorize_carbon(Mob, user, 3, FALSE)


/obj/item/memorizer/emp_act(severity)
	if(!try_use_flash())
		return FALSE
	for(var/mob/living/carbon/Mob in viewers(3, null))
		memorize_carbon(Mob, null, 10, TRUE)
	burn_out()

/obj/item/memorizer/syndicate
	name = "Нейрализатор"
	desc = "Если перед вами сработает это устройство, скорее всего вы не сможете об этом вспомнить!"
	origin_tech = "abductor=3;syndicate=2"

/obj/item/memorizer/syndicate/memorize_carbon(mob/living/carbon/Mob, mob/user = null, power = 5, targeted = TRUE)
	if(user)
		add_attack_logs(user, Mob, "[user] стёр память [Mob] с помощью [src]а")
		if(targeted)
			if(!Mob.mind)
				to_chat(user, "<span class='danger'>[Mob] кататоник! Стирание памяти бесполезно против тех, кто не осознаёт ничего вокруг себя!</span>")
				return
			if(Mob.weakeyes)
				Mob.Weaken(3) //quick weaken bypasses eye protection but has no eye flash
			if(Mob.flash_eyes(1, 1))
				Mob.AdjustConfused(power)
				Mob.Stun(1)
				visible_message("<span class='disarm'>[user] стирает память [Mob] с помощью Нейрализатора!</span>")
				to_chat(user, "<span class='danger'>Вы стёрли память [Mob] с помощью Нейрализатора!</span>")
				to_chat(Mob, "<span class='danger'><span class='reallybig'>Ваша память о последних недавних событиях была стёрта!</span>")
				if(is_taipan(Mob.z) && !Mob.mind.lost_memory)
					var/objective = "Вы не помните ничего о последних событиях, так как ваша память была стёрта. \
					В частности вы не помните о базе синдиката \"Тайпан\", о том как туда добраться и обо всём так или иначе с ней связанным!"
					var/datum/objective/custom_objective = new(objective)
					custom_objective.owner = Mob.mind
					Mob.mind.objectives += custom_objective
					Mob.mind.lost_memory = TRUE
					Mob.mind.announce_objectives()
				last_used = world.time
				if(Mob.weakeyes)
					Mob.Stun(2)
					Mob.visible_message("<span class='disarm'>[Mob] моргает, тем самым защищая свои глаза!!</span>", "<span class='userdanger'>Вы моргнули и защитили свои глаза!</span>")
			else
				visible_message("<span class='disarm'>У [user] не получилось стереть память [Mob] с помощью \"Нейрализатора\"!</span>")
				to_chat(user, "<span class='warning'>Вы не смогли стереть память [Mob] с помощью \"Нейрализатора\"!</span>")
				to_chat(Mob, "<span class='danger'>У [user] не получилось стереть вашу память с помощью \"Нейрализатора\"!</span>")
			return

	if(Mob.flash_eyes())
		Mob.AdjustConfused(power)
