var/global/curse_dial = TRUE
var/global/curse_upper = TRUE
var/global/curse_lower = TRUE
var/global/obj/structure/clockwork/functional/heart/Heart = null

/obj/structure/clockwork/functional/heart
	name = "The heart of Ratvar"
	ru_names = list(
		NOMINATIVE = "Сердце Ратвара",
		GENITIVE = "Сердца Ратвара",
		DATIVE = "Сердцу Ратвара",
		ACCUSATIVE = "Сердце Ратвара",
		INSTRUMENTAL = "Сердцем Ратвара",
		PREPOSITIONAL = "Сердце Ратвара",
	)
	desc = "Огромный механизм из латуни, напоминающий сердце. От его громкого тиканья у вас начинает болеть голова..."
	icon = 'icons/obj/clockheart.dmi'
	icon_state = "heart"
	pixel_x = -32
	pixel_y = -32
	plane = WALL_PLANE
	var/list/obj/structure/fillers = list()
	var/pulse_range = 3
	mouse_drag_pointer = MOUSE_DROP_POINTER
	var/cur_enchant = null
	var/list/enchants

/obj/structure/clockwork/functional/heart/Initialize(mapload)
	enchants = GLOB.heart_pulses
	if(isnull(Heart))
		Heart = src
	alpha = 0
	new /obj/effect/temp_visual/ratvar/reconstruct/heart(loc)
	update_icon(UPDATE_OVERLAYS)
	alpha = 255
	bound_width = world.icon_size
	var/list/occupied = list()
	for(var/direct in list(NORTHWEST,NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTH,SOUTHWEST,WEST))
		occupied += get_step(src,direct)

	for(var/T in occupied)
		var/obj/structure/heart_filler/F = new(T)
		F.parent = src
		fillers += F
	addtimer(CALLBACK(src, PROC_REF(heart_pulse)), 30 SECONDS, TIMER_LOOP | TIMER_DELETE_ME)
	. = ..()

/obj/structure/clockwork/functional/heart/update_overlays()
	.=..()
	if(curse_dial)
		. += "[icon_state]_dialcurse"
	else
		. -= "[icon_state]_dialcurse"
	if(curse_upper)
		. += "[icon_state]_curse_upper"
	else
		. -= "[icon_state]_curse_upper"

	if(curse_lower)
		. += "[icon_state]_curse_lower"
	else
		. -= "[icon_state]_curse_lower"
	if(cur_enchant)
		.+= "heart_overlay_[cur_enchant]"

/obj/structure/clockwork/functional/heart/proc/heart_pulse()
	update_icon(UPDATE_OVERLAYS)
	if(!curse_dial)
		switch(cur_enchant)
			if(EMP_HEART_PULSE)
				new /obj/effect/temp_visual/ratvar/reconstruct/heart_pulse/emp(loc, pulse_range)
			if(HEAL_HEART_PULSE)
				new /obj/effect/temp_visual/ratvar/reconstruct/heart_pulse/heal(loc, pulse_range)
			if(STUN_HEART_PULSE)
				new /obj/effect/temp_visual/ratvar/reconstruct/heart_pulse/stun(loc, pulse_range)
			else
				new /obj/effect/temp_visual/ratvar/reconstruct/heart_pulse(loc, pulse_range)
	return


/obj/structure/clockwork/functional/heart/Destroy(force)
	for(var/turf/tile in orange(1, src))
		new /obj/effect/gibspawner/clock(tile)
	playsound(src, 'sound/effects/forge_destroy.ogg', 50, TRUE)
	QDEL_LIST(fillers)
	. = ..()

/obj/structure/clockwork/functional/heart/MouseDrop_T(atom/movable/dropping, mob/user, params)
	if(!isclocker(user))
		return
	if(istype(dropping, /obj/structure/part1))
		if(curse_dial)
			if(do_after(user, 5 SECONDS, src))
				curse_dial = FALSE
				qdel(dropping)
				update_icon(UPDATE_OVERLAYS)

/obj/structure/clockwork/functional/heart/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/part2))
		if(curse_upper)
			if(do_after(user, 5 SECONDS, src))
				curse_upper = FALSE
				qdel(I)
				update_icon(UPDATE_OVERLAYS)
				return
	if(istype(I, /obj/item/part3))
		if(curse_lower)
			if(do_after(user, 5 SECONDS, src))
				curse_lower = FALSE
				qdel(I)
				update_icon(UPDATE_OVERLAYS)
				return
	. = ..()

/obj/structure/clockwork/functional/heart/Destroy(force)
	for(var/turf/tile in orange(1, src))
		new /obj/effect/gibspawner/clock(tile)
	playsound(src, 'sound/effects/forge_destroy.ogg', 50, TRUE)
	QDEL_LIST(fillers)
	. = ..()

/obj/structure/clockwork/functional/heart/MouseDrop_T(atom/movable/dropping, mob/user, params)
	if(!isclocker(user))
		return
	if(istype(dropping, /obj/structure/part1))
		if(curse_dial)
			if(do_after(user, 5 SECONDS, src))
				curse_dial = FALSE
				qdel(dropping)
				update_icon(UPDATE_OVERLAYS)

/obj/structure/clockwork/functional/heart/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/part2))
		if(curse_upper)
			if(do_after(user, 5 SECONDS, src))
				curse_upper = FALSE
				qdel(I)
				update_icon(UPDATE_OVERLAYS)
				return
	if(istype(I, /obj/item/part3))
		if(curse_lower)
			if(do_after(user, 5 SECONDS, src))
				curse_lower = FALSE
				qdel(I)
				update_icon(UPDATE_OVERLAYS)
				return
	. = ..()

/obj/structure/clockwork/functional/heart/Destroy(force)
	for(var/turf/tile in orange(1, src))
		new /obj/effect/decal/cleanable/blood/gibs/clock(tile)
	playsound(src, 'sound/effects/forge_destroy.ogg', 50, TRUE)
	QDEL_LIST(fillers)
	. = ..()

/obj/structure/clockwork/functional/heart/MouseDrop_T(atom/movable/dropping, mob/user, params)
	if(istype(dropping, /obj/structure/part1))
		curse_dial = FALSE
	. = ..()

/obj/structure/heart_filler
	name = "The heart of Ratvar"
	ru_names = list(
		NOMINATIVE = "Сердце Ратвара",
		GENITIVE = "Сердца Ратвара",
		DATIVE = "Сердцу Ратвара",
		ACCUSATIVE = "Сердце Ратвара",
		INSTRUMENTAL = "Сердцем Ратвара",
		PREPOSITIONAL = "Сердце Ратвара",
	)
	desc = "Огромный механизм из латуни, напоминающий сердце. От его громкого тиканья у вас начинает болеть голова..."
	density = TRUE
	anchored = TRUE
	smoothing_groups = SMOOTH_GROUP_FILLER
	var/obj/machinery/parent
	icon = 'icons/effects/blood.dmi'
	icon_state =  "thisisfuckingstupid"
	alpha = 1

/obj/structure/heart_filler/Destroy()
	parent = null
	return ..()

/obj/structure/heart_filler/ex_act()
	return

/obj/structure/heart_filler/attack_hand(mob/living/user)
	parent.attack_hand(user)

/obj/structure/heart_filler/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	parent.take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)

/obj/structure/heart_filler/MouseDrop_T(atom/movable/dropping, mob/user, params)
	parent.MouseDrop_T(dropping, user, params)
	. = ..()

/obj/structure/part1
	name = "Big brass dial"
	ru_names = list(
		NOMINATIVE = "Большой латунный циферблат",
		GENITIVE = "большого латунного циферблата",
		DATIVE = "большому латунному циферблату",
		ACCUSATIVE = "большой латунный циферблат",
		INSTRUMENTAL = "большим латунным циферблатом",
		PREPOSITIONAL = "большом латунном циферблате",
	)
	desc = "Большой циферблат из латуни."
	icon ='icons/obj/clockwork.dmi'
	icon_state = "ratvarpart1"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE
	mouse_drag_pointer = TRUE

/obj/structure/part1/Bump(atom/bumped_atom)
	var/mob/bumped = bumped_atom
	if(!isclocker(bumped))
		to_chat(span_clockitalic("Вы пытаетесь толкнуть циферблат, но его словно что-то удерживает!"))
		return
	. = ..()

/obj/structure/part1/CtrlClick(mob/user)
	if(!isclocker(user))
		var/mob/living/carbon/human/sinner = user
		to_chat(span_clockitalic("Вы попытались потянуть циферблат, но ваша рука обратилась в пепел!"))
		var/limb_to_burn = sinner.pull_hand
		qdel(limb_to_burn)
		new /obj/effect/decal/cleanable/ash(user.loc)
	. = ..()
