#define DRYING_TIME 5 * 60 * 10 //for 1 unit of depth in puddle (amount var)

/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "Оно густое и липкое. Возможно, это шедевр местного повара?"
	gender = PLURAL
	plane = GAME_PLANE
	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	random_icon_states = list("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7")
	blood_DNA = list()
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	var/base_icon = 'icons/effects/blood.dmi'
	var/blood_state = BLOOD_STATE_HUMAN
	var/basecolor = BLOOD_COLOR_RED
	var/amount = 5
	var/dry_timer = 0
	var/off_floor = FALSE
	var/is_dry = FALSE
	var/max_shone_bloodiness = MAX_SHOE_BLOODINESS
	var/drying_time = DRYING_TIME
	var/dryname = "dried blood"
	var/drydesc = "Оно сухое и засохшее. Кто-то явно халтурит."

#undef DRYING_TIME

/obj/effect/decal/cleanable/blood/get_ru_names_cached() //we can't cache this now
	return is_dry? list(
		NOMINATIVE = "засохшая кровь",
		GENITIVE = "засохшей крови",
		DATIVE = "засохшей крови",
		ACCUSATIVE = "засохшую кровь",
		INSTRUMENTAL = "засохшей кровью",
		PREPOSITIONAL = "засохшей крови",
	): list(
		NOMINATIVE = "кровь",
		GENITIVE = "крови",
		DATIVE = "крови",
		ACCUSATIVE = "кровь",
		INSTRUMENTAL = "кровью",
		PREPOSITIONAL = "крови",
	)

/obj/effect/decal/cleanable/blood/replace_decal(obj/effect/decal/cleanable/blood/C)
	if(C.blood_DNA)
		blood_DNA |= C.blood_DNA.Copy()
	if(bloodiness)
		if(C.bloodiness < MAX_SHOE_BLOODINESS)
			C.bloodiness += bloodiness
	return ..()

/obj/effect/decal/cleanable/blood/Initialize(mapload)
	. = ..()
	update_icon()
	if(type == /obj/effect/decal/cleanable/blood/gibs)
		return
	if(!.)
		dry_timer = addtimer(CALLBACK(src, PROC_REF(dry)), drying_time * (amount+1), TIMER_STOPPABLE)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)
	if(!QDELING(src))
		AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/decal/cleanable/blood/Destroy()
	if(dry_timer)
		deltimer(dry_timer)
	return ..()

/obj/effect/decal/cleanable/blood/update_icon(updates = ALL)
	if(!updates)
		return
	if(basecolor == "rainbow")
		basecolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	color = basecolor
	. = ..()

/obj/effect/decal/cleanable/blood/proc/dry()
	name = dryname
	desc = drydesc
	is_dry = TRUE
	color = adjust_brightness(color, -50)
	amount = 0

/obj/effect/decal/cleanable/blood/attack_hand(mob/living/carbon/human/user)
	..()
	if(amount && istype(user))
		add_fingerprint(user)
		if(user.gloves)
			return
		var/taken = rand(1,amount)
		amount -= taken
		to_chat(user, span_notice("Вы взяли немного [declent_ru(GENITIVE)] в руки."))
		if(!user.blood_DNA)
			user.blood_DNA = list()
		user.blood_DNA |= blood_DNA.Copy()
		user.bloody_hands += taken
		user.hand_blood_color = basecolor
		user.update_worn_gloves()
		add_verb(user, /mob/living/carbon/human/proc/bloody_doodle)

/obj/effect/decal/cleanable/blood/can_bloodcrawl_in()
	return TRUE

/obj/effect/decal/cleanable/blood/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(off_floor || !ishuman(arrived))
		return

	blood_decal_crossed(arrived)

/obj/effect/decal/cleanable/blood/proc/on_exited(datum/source, atom/movable/departed, atom/newLoc)
	SIGNAL_HANDLER

	if(off_floor || !ishuman(departed))
		return

	blood_decal_uncrossed(departed)

/obj/effect/decal/cleanable/blood/proc/blood_decal_crossed(mob/living/carbon/human/arrived)
	if(istype(arrived.shoes, /obj/item/clothing/shoes) && blood_state && bloodiness)
		var/obj/item/clothing/shoes/shoes = arrived.shoes
		var/add_blood = 0
		if(bloodiness >= BLOOD_GAIN_PER_STEP)
			add_blood = BLOOD_GAIN_PER_STEP
		else
			add_blood = bloodiness
		bloodiness -= add_blood
		shoes.bloody_shoes[blood_state] = min(max_shone_bloodiness, shoes.bloody_shoes[blood_state] + add_blood)
		if(length(blood_DNA))
			shoes.add_blood(blood_DNA, basecolor)
		shoes.blood_state = blood_state
		shoes.blood_color = basecolor
		update_icon()
		shoes.update_icon()
		arrived.update_worn_shoes()

	else if(!arrived.shoes && arrived.num_legs > 0 && blood_state && bloodiness)//Or feet
		var/add_blood = 0
		if(bloodiness >= BLOOD_GAIN_PER_STEP)
			add_blood = BLOOD_GAIN_PER_STEP
		else
			add_blood = bloodiness
		bloodiness -= add_blood
		arrived.bloody_feet[blood_state] = min(max_shone_bloodiness, arrived.bloody_feet[blood_state] + add_blood)
		if(!arrived.feet_blood_DNA)
			arrived.feet_blood_DNA = list()
		arrived.blood_state = blood_state
		arrived.feet_blood_DNA |= blood_DNA.Copy()
		arrived.feet_blood_color = basecolor
		update_icon()
		arrived.update_worn_shoes()

/obj/effect/decal/cleanable/blood/proc/blood_decal_uncrossed(mob/living/carbon/human/departed)
	return

/obj/effect/decal/cleanable/blood/splatter
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2

/obj/effect/decal/cleanable/blood/splatter/over_window // special layer/plane set to appear on windows
	layer = ABOVE_WINDOW_LAYER
	vis_flags = VIS_INHERIT_PLANE
	alpha = 180
	//is_mopped = FALSE

/obj/effect/decal/cleanable/blood/splatter/over_window/never_should_have_come_here(turf/here_turf)
	return isgroundlessturf(here_turf)

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "Оно красное."
	icon = 'icons/effects/drip.dmi'
	icon_state = "1"
	random_icon_states = list("1", "2", "3", "4", "5")
	amount = 0
	bloodiness = 0
	var/drips = 1

/obj/effect/decal/cleanable/blood/drip/get_ru_names()
	return list(
		NOMINATIVE = "капли крови",
		GENITIVE = "капель крови",
		DATIVE = "каплям крови",
		ACCUSATIVE = "капли крови",
		INSTRUMENTAL = "каплями крови",
		PREPOSITIONAL = "каплях крови",
	)

/obj/effect/decal/cleanable/blood/drip/can_bloodcrawl_in()
	return TRUE

/obj/effect/decal/cleanable/trail_holder //not a child of blood on purpose
	name = "blood"
	icon_state = "nothing"
	desc = "Ваши инстинкты подсказывают, что не стоит идти этим путём."
	gender = PLURAL
	layer = TURF_LAYER
	random_icon_states = null
	blood_DNA = list()
	var/list/existing_dirs = list()

/obj/effect/decal/cleanable/trail_holder/get_ru_names()
	return list(
		NOMINATIVE = "кровь",
		GENITIVE = "крови",
		DATIVE = "крови",
		ACCUSATIVE = "кровь",
		INSTRUMENTAL = "кровью",
		PREPOSITIONAL = "крови",
	)

/obj/effect/decal/cleanable/trail_holder/can_bloodcrawl_in()
	return TRUE

/obj/effect/decal/cleanable/blood/writing
	icon_state = "tracks"
	desc = "Это похоже на надпись кровью."
	gender = NEUTER
	random_icon_states = list("writing1", "writing2", "writing3", "writing4", "writing5")
	amount = 0
	var/message

/obj/effect/decal/cleanable/blood/writing/Initialize(mapload)
	. = ..()
	if(length(random_icon_states))
		for(var/obj/effect/decal/cleanable/blood/writing/W in loc)
			random_icon_states.Remove(W.icon_state)
		icon_state = pick(random_icon_states)
	else
		icon_state = "writing1"

/obj/effect/decal/cleanable/blood/writing/examine(mob/user)
	. = ..()
	. += span_notice("Надпись гласит: <font color='[basecolor]'>\"[message]\"<font>")

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "Кто-то или что-то явно было разорвано на части."
	layer = TURF_LAYER
	icon_state = "gib2"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	no_clear = TRUE
	scoop_reagents = list("liquidgibs" = 5)
	mergeable_decal = FALSE
	var/image/giblets
	var/fleshcolor = "#FFFFFF"
	/// Do these gibs produce squishy sounds?
	var/squishy = TRUE

/obj/effect/decal/cleanable/blood/gibs/get_ru_names()
	return list(
		NOMINATIVE = "кровавое месиво",
		GENITIVE = "кровавого месива",
		DATIVE = "кровавому месиву",
		ACCUSATIVE = "кровавое месиво",
		INSTRUMENTAL = "кровавым месивом",
		PREPOSITIONAL = "кровавом месиве",
	)

/obj/effect/decal/cleanable/blood/gibs/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_PIPE_EJECTING, PROC_REF(on_pipe_eject))
	if(squishy)
		AddElement(/datum/element/squish_sound)

/obj/effect/decal/cleanable/blood/gibs/Destroy()
	if(giblets)
		QDEL_NULL(giblets)
	. = ..()

/obj/effect/decal/cleanable/blood/gibs/proc/on_pipe_eject(datum/source, direction)
	SIGNAL_HANDLER

	var/list/dirs
	if(direction)
		dirs = list(direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	INVOKE_ASYNC(src, PROC_REF(streak), dirs)

/obj/effect/decal/cleanable/blood/gibs/update_icon(updates = ALL)
	if(!updates)
		return
	giblets = new(base_icon, "[icon_state]_flesh", dir)
	if(!fleshcolor || fleshcolor == "rainbow")
		fleshcolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	giblets.color = fleshcolor
	var/icon/blood = new(base_icon, "[icon_state]", dir)
	icon = blood
	. = ..()

/obj/effect/decal/cleanable/blood/gibs/update_overlays()
	. = ..()
	. += giblets

/obj/effect/decal/cleanable/blood/gibs/ex_act(severity, target)
	return

/obj/effect/decal/cleanable/blood/gibs/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gibup1", "gibup1", "gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gibdown1", "gibdown1", "gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/limb
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")
	scoop_reagents = list("liquidgibs" = 15)

/obj/effect/decal/cleanable/blood/gibs/cleangibs //most ironic name ever...
	scoop_reagents = null

/obj/effect/decal/cleanable/blood/gibs/proc/streak(list/directions)
	set waitfor = 0

	var/direction = pick(directions)
	for(var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
		sleep(3)
		if(i > 0)
			var/obj/effect/decal/cleanable/blood/b = new /obj/effect/decal/cleanable/blood/splatter(loc)
			b.basecolor = src.basecolor
			b.update_icon()
		if(step_to(src, get_step(src, direction), 0))
			break

/obj/effect/decal/cleanable/blood/old/Initialize(mapload)
	. = ..()
	bloodiness = 0
	dry()

/obj/effect/decal/cleanable/blood/old/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/gibs/old/Initialize(mapload)
	. = ..()
	bloodiness = 0
	dry()

/obj/effect/decal/cleanable/blood/gibs/old/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/hitsplatter
	name = "blood splatter"
	pass_flags = PASSTABLE | PASSGRILLE
	icon_state = "hitsplatter1"
	random_icon_states = list("hitsplatter1", "hitsplatter2", "hitsplatter3")
	layer = ABOVE_WINDOW_LAYER
	/// The turf we just came from, so we can back up when we hit a wall
	var/turf/prev_loc
	/// Skip making the final blood splatter when we're done, like if we're not in a turf
	var/skip = FALSE
	/// How many tiles/items/people we can paint red
	var/splatter_strength = 3
	/// Insurance so that we don't keep moving once we hit a stoppoint
	var/hit_endpoint = FALSE
	/// How fast the splatter moves
	var/splatter_speed = 0.1 SECONDS
	/// Tracks what direction we're flying
	var/flight_dir = NONE
	/// Should we be leaving any decals, or just adding DNA to mobs?
	var/leave_blood = TRUE
	/// The cached info about the blood
	var/list/blood_dna_info

/obj/effect/decal/cleanable/blood/hitsplatter/Initialize(mapload, splatter_strength)
	. = ..()
	//leave_blood = has_blood_flag(blood_dna_info, BLOOD_COVER_TURFS)
	prev_loc = loc //Just so we are sure prev_loc exists
	if(splatter_strength)
		src.splatter_strength = splatter_strength

/obj/effect/decal/cleanable/blood/hitsplatter/proc/expire()
	if(isturf(loc) && !skip)
		playsound(src, 'sound/effects/splatter.ogg', 60, TRUE, -1)
		if(blood_dna_info)
			loc.add_blood(blood_dna_info)
	qdel(src)

/// Set the splatter up to fly through the air until it rounds out of steam or hits something
/obj/effect/decal/cleanable/blood/hitsplatter/proc/fly_towards(turf/target_turf, range)
	flight_dir = get_dir(src, target_turf)
	var/datum/move_loop/loop = GLOB.move_manager.move_towards(src, target_turf, splatter_speed, timeout = splatter_speed * range, priority = MOVEMENT_ABOVE_SPACE_PRIORITY, flags = MOVEMENT_LOOP_START_FAST)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(loop_done))

/obj/effect/decal/cleanable/blood/hitsplatter/proc/pre_move(datum/move_loop/source)
	SIGNAL_HANDLER
	prev_loc = loc

/obj/effect/decal/cleanable/blood/hitsplatter/proc/post_move(datum/move_loop/source)
	SIGNAL_HANDLER
	if(loc == prev_loc || !isturf(loc))
		return

	var/hit_endpoint_cached = hit_endpoint
	var/splatter_strength_cached = splatter_strength
	for(var/atom/movable/iter_atom in loc)
		if(hit_endpoint_cached)
			return
		if(iter_atom == src || iter_atom.invisibility || iter_atom.alpha <= 0 || (isobj(iter_atom) && !iter_atom.density))
			continue
		if(splatter_strength_cached <= 0)
			break
		iter_atom.add_blood(blood_dna_info)

	splatter_strength--
	// we used all our blood so go away
	if(splatter_strength <= 0)
		expire()
		return

	if(!leave_blood)
		loc.add_blood(blood_dna_info)
		return

	// make a trail
	var/obj/effect/decal/cleanable/blood/fly_trail = new(loc, null, blood_dna_info)
	fly_trail.dir = dir
	if(ISDIAGONALDIR(flight_dir))
		fly_trail.transform = fly_trail.transform.Turn((flight_dir == NORTHEAST || flight_dir == SOUTHWEST) ? 135 : 45)
	fly_trail.icon_state = pick("trails_1", "trails_2")
	//fly_trail.adjust_bloodiness(fly_trail.bloodiness * -0.66)
	fly_trail.update_appearance(UPDATE_ICON)

/obj/effect/decal/cleanable/blood/hitsplatter/proc/loop_done(datum/source)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		expire()

/obj/effect/decal/cleanable/blood/hitsplatter/Bump(atom/bumped_atom)
	if(!iswallturf(bumped_atom) && !is_window(bumped_atom))
		expire()
		return

	if(is_window(bumped_atom))
		var/obj/structure/window/bumped_window = bumped_atom
		if(!bumped_window.fulltile)
			hit_endpoint = TRUE
			expire()
			return

	hit_endpoint = TRUE
	if(!isturf(prev_loc)) // This will only happen if prev_loc is not even a turf, which is highly unlikely.
		abstract_move(bumped_atom)
		expire()
		return

	abstract_move(bumped_atom)
	skip = TRUE
	//Adjust pixel offset to make splatters appear on the wall
	if(is_window(bumped_atom))
		if(land_on_window(bumped_atom))
			return

	if(!leave_blood)
		prev_loc.add_blood(blood_dna_info)
		return

	var/obj/effect/decal/cleanable/blood/splatter/over_window/final_splatter = new(prev_loc, null, blood_dna_info)
	final_splatter.pixel_x = (dir == EAST ? 32 : (dir == WEST ? -32 : 0))
	final_splatter.pixel_y = (dir == NORTH ? 32 : (dir == SOUTH ? -32 : 0))

/// A special case for hitsplatters hitting windows, since those can actually be moved around, store it in the window and slap it in the vis_contents
/obj/effect/decal/cleanable/blood/hitsplatter/proc/land_on_window(obj/structure/window/the_window)
	if(!leave_blood)
		the_window.add_blood(blood_dna_info)
		return TRUE

	if(!the_window.fulltile)
		return FALSE

	var/obj/effect/decal/cleanable/final_splatter = new /obj/effect/decal/cleanable/blood/splatter/over_window(prev_loc, null, blood_dna_info)
	final_splatter.forceMove(the_window)
	the_window.vis_contents += final_splatter
	expire()
	return TRUE
