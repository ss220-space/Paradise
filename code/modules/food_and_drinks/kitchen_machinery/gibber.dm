#define GIBBER_ANIMATION_DELAY 16
/obj/machinery/gibber
	name = "Gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = TRUE
	anchored = TRUE
	var/operating = 0 //Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/mob/living/carbon/human/occupant // Mob who has been put inside
	var/locked = 0 //Used to prevent mobs from breaking the feedin anim

	var/gib_throw_dir = WEST // Direction to spit meat and gibs in. Defaults to west.

	var/gibtime = 40 // Time from starting until meat appears
	var/animation_delay = GIBBER_ANIMATION_DELAY

	// For hiding gibs, making an even more devious trap (invisible autogibbers)
	var/stealthmode = FALSE
	var/list/victims = list()

	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 500


/obj/machinery/gibber/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/gibber/Destroy()
	if(contents.len)
		for(var/atom/movable/A in contents)
			A.forceMove(get_turf(src))
	if(occupant)
		occupant = null
	return ..()

/obj/machinery/gibber/RefreshParts() //If you want to make the machine upgradable, this is where you would change any vars basd on its stock parts.
	return


/obj/machinery/gibber/update_overlays()
	. = ..()

	if(dirty)
		. +=  "grbloody"

	if(stat & (NOPOWER|BROKEN))
		return

	if(!occupant)
		. += "grjam"

	else if(operating)
		. +=  "gruse"

	else
		. += "gridle"


/obj/machinery/gibber/suicide_act(mob/living/user)
	if(occupant || locked)
		return FALSE
	user.visible_message("<span class='danger'>[user] climbs into [src] and turns it on!</b></span>")
	user.Stun(20 SECONDS)
	user.forceMove(src)
	occupant = user
	update_icon()
	feedinTopanim()
	addtimer(CALLBACK(src, PROC_REF(startgibbing), user), 33)
	return OBLITERATION


/obj/machinery/gibber/relaymove(mob/user)
	if(locked)
		return

	go_out()

/obj/machinery/gibber/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(operating)
		to_chat(user, "<span class='danger'>The gibber is locked and running, wait for it to finish.</span>")
		return

	if(locked)
		to_chat(user, "<span class='warning'>Wait for [occupant.name] to finish being loaded!</span>")
		return

	add_fingerprint(user)
	startgibbing(user)


/obj/machinery/gibber/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE)
		return .
	add_fingerprint(grabber)
	move_into_gibber(grabber, grabbed_thing)



/obj/machinery/gibber/screwdriver_act(mob/living/user, obj/item/I)
	return default_deconstruction_screwdriver(user, "grinder_open", "grinder", I)


/obj/machinery/gibber/wrench_act(mob/living/user, obj/item/I)
	return default_unfasten_wrench(user, I)


/obj/machinery/gibber/crowbar_act(mob/living/user, obj/item/I)
	return default_deconstruction_crowbar(user, I)


/obj/machinery/gibber/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/gibber/MouseDrop_T(mob/target, mob/user, params)
	if(!ishuman(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(!isliving(target))
		return

	var/mob/living/targetl = target

	if(targetl.buckled)
		return
	. = TRUE
	add_fingerprint(user)
	move_into_gibber(user,target)

/obj/machinery/gibber/proc/move_into_gibber(mob/user, mob/living/victim)
	if(occupant)
		to_chat(user, "<span class='danger'>The [src] is full, empty it first!</span>")
		return

	if(operating)
		to_chat(user, "<span class='danger'>The [src] is locked and running, wait for it to finish.</span>")
		return

	if(!ishuman(victim))
		to_chat(user, "<span class='danger'>This is not suitable for the [src]!</span>")
		return

	if(victim.abiotic(1))
		to_chat(user, "<span class='danger'>Subject may not have abiotic items on.</span>")
		return

	user.visible_message("<span class='danger'>[user] starts to put [victim] into the [src]!</span>")
	add_fingerprint(user)
	if(do_after(user, 3 SECONDS, victim) && user.Adjacent(src) && victim.Adjacent(user) && !occupant)
		user.visible_message("<span class='danger'>[user] stuffs [victim] into the [src]!</span>")

		victim.forceMove(src)
		occupant = victim

		update_icon(UPDATE_OVERLAYS)
		feedinTopanim()

/obj/machinery/gibber/verb/eject()
	set category = "Object"
	set name = "Empty Gibber"
	set src in oview(1)

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	go_out()
	add_fingerprint(usr)

/obj/machinery/gibber/proc/go_out()
	if(operating || !occupant) //no going out if operating, just in case they manage to trigger go_out before being dead
		return

	if(locked)
		return

	for(var/obj/O in src)
		O.forceMove(loc)

	occupant.forceMove(get_turf(src))
	occupant = null

	update_icon(UPDATE_OVERLAYS)


/obj/machinery/gibber/proc/feedinTopanim()
	if(!occupant)
		return

	locked = 1 //lock gibber

	var/image/gibberoverlay = new //used to simulate 3D effects
	gibberoverlay.icon = icon
	gibberoverlay.icon_state = "grinderoverlay"
	gibberoverlay.add_overlay(image('icons/obj/kitchen.dmi', "gridle"))

	var/image/feedee = new
	occupant.dir = SOUTH
	feedee.icon = getFlatIcon(occupant, 2) //makes the image a copy of the occupant

	var/atom/movable/holder = new //holder for occupant image
	holder.name = null //make unclickable
	holder.add_overlay(feedee)	//add occupant to holder overlays
	holder.pixel_y = 25 //above the gibber
	holder.pixel_x = 2
	holder.loc = get_turf(src)
	holder.layer = MOB_LAYER //simulate mob-like layering
	holder.set_anchored(TRUE)

	var/atom/movable/holder2 = new //holder for gibber overlay, used to simulate 3D effect
	holder2.name = null
	holder2.add_overlay(gibberoverlay)
	holder2.loc = get_turf(src)
	holder2.layer = MOB_LAYER + 0.1 //3D, it's above the mob, rest of the gibber is behind
	holder2.set_anchored(TRUE)

	animate(holder, pixel_y = 16, time = animation_delay) //animate going down

	sleep(animation_delay)

	holder.cut_overlay(feedee)	//reset static icon
	feedee.icon += icon('icons/obj/kitchen.dmi', "footicon") //this is some byond magic; += to the icon var with a black and white image will mask it
	holder.add_overlay(feedee)
	animate(holder, pixel_y = -3, time = animation_delay) //animate going down further

	sleep(animation_delay) //time everything right, animate doesn't prevent proc from continuing

	qdel(holder) //get rid of holder object
	qdel(holder2) //get rid of holder object
	locked = 0 //unlock

/obj/machinery/gibber/proc/startgibbing(mob/user, UserOverride=0)
	if(!istype(user) && !UserOverride)
		log_debug("Some shit just went down with the gibber at X[x], Y[y], Z[z] with an invalid user. (<a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
		return

	if(UserOverride)
		add_attack_logs(user, occupant, "gibbed by an autogibber ([src])", ATKLOG_FEW)

	if(operating)
		return

	if(!occupant)
		visible_message("<span class='danger'>You hear a loud metallic grinding sound.</span>")
		return

	use_power(1000)
	visible_message("<span class='danger'>You hear a loud squelchy grinding sound.</span>")

	operating = TRUE
	update_icon(UPDATE_OVERLAYS)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = gibtime * 5) //start shaking

	while(occupant.meatleft > 0)
		new occupant.dna.species.meat_type(src, occupant)
		occupant.meatleft--

	if(ishuman(occupant))
		var/mob/living/carbon/human/H = occupant
		var/skinned = H.dna.species.skinned_type
		if(ismachineperson(H))
			new /obj/effect/gibspawner/robot(src)
		else if(!isplasmaman(H) && !isnucleation(H) && !isgolem(H))
			new /obj/effect/gibspawner(src, H.dna)
		if(skinned)
			new skinned(src)

	if(!UserOverride)
		add_attack_logs(user, occupant, "Gibbed in [src]", !!occupant.ckey ? ATKLOG_FEW : ATKLOG_ALL)

	else //this looks ugly but it's better than a copy-pasted startgibbing proc override
		add_attack_logs(src, occupant, "gibbed")

	occupant.emote("scream")
	playsound(get_turf(src), 'sound/goonstation/effects/gib.ogg', 50, 1)
	victims += "\[[time_stamp()]\] [key_name(occupant)] killed by [UserOverride ? "Autogibbing" : "[key_name(user)]"]" //have to do this before ghostizing
	occupant.death(1)
	occupant.ghostize()

	QDEL_NULL(occupant)

	spawn(gibtime)
		playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)

		if(stealthmode)
			for(var/atom/movable/AM in contents)
				qdel(AM)
				sleep(1)
		else
			for(var/obj/item/thing in contents) //Meat is spawned inside the gibber and thrown out afterwards.
				thing.loc = get_turf(thing) // Drop it onto the turf for throwing.
				thing.throw_at(get_edge_target_turf(src, gib_throw_dir), rand(1, 5), 15) // Being pelted with bits of meat and bone would hurt.
				sleep(1)

			for(var/obj/effect/gibs in contents) //throw out the gibs too
				gibs.loc = get_turf(gibs) //drop onto turf for throwing
				gibs.throw_at(get_edge_target_turf(src, gib_throw_dir), rand(1, 5), 15)
				sleep(1)

		pixel_x = initial(pixel_x) //return to it's spot after shaking
		operating = FALSE
		update_icon(UPDATE_OVERLAYS)



/* AUTOGIBBER */


//gibs anything that stands on it's input

/obj/machinery/gibber/autogibber
	var/acceptdir = NORTH
	var/lastacceptdir = NORTH
	var/turf/lturf
	var/consumption_delay = 3 SECONDS
	var/list/victim_targets = list()

/obj/machinery/gibber/autogibber/New()
	..()
	spawn(5)
		var/turf/T = get_step(src, acceptdir)
		if(istype(T))
			lturf = T
	component_parts = list()
	component_parts += new /obj/item/circuitboard/gibber(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/gibber/autogibber/process()
	if(!lturf || occupant || locked || dirty || operating || victim_targets.len)
		return

	if(acceptdir != lastacceptdir)
		lturf = null
		lastacceptdir = acceptdir
		var/turf/T = get_step(src, acceptdir)
		if(istype(T))
			lturf = T

	for(var/mob/living/carbon/human/H in lturf)
		victim_targets += H

	if(victim_targets.len)
		visible_message({"<span class='danger'>\The [src] states, "Food detected!"</span>"})
		sleep(consumption_delay)
		for(var/mob/living/carbon/H in victim_targets)
			if(H.loc == lturf) //still standing there
				if(force_move_into_gibber(H))
					locked = 1 // no escape
					ejectclothes(occupant)
					cleanbay()
					startgibbing(null, 1)
					locked = 0
			break
	victim_targets.Cut()

/obj/machinery/gibber/autogibber/proc/force_move_into_gibber(mob/living/carbon/human/victim)
	if(!istype(victim))
		return FALSE
	visible_message("<span class='danger'>\The [victim.name] gets sucked into \the [src]!</span>")

	victim.forceMove(src)
	occupant = victim

	update_icon(UPDATE_OVERLAYS)
	feedinTopanim()
	return TRUE


/obj/machinery/gibber/autogibber/proc/ejectclothes(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(H != occupant)
		return //only using H as a shortcut to typecast

	for(var/obj/O in H)
		if(isclothing(O)) //clothing gets skipped to avoid cleaning out shit
			continue
		if(istype(O,/obj/item/implant))
			var/obj/item/implant/I = O
			if(I.implanted)
				continue
		if(istype(O,/obj/item/organ))
			continue
		if(HAS_TRAIT(O, TRAIT_NODROP) || stealthmode)
			qdel(O) //they are already dead by now
		H.drop_transfer_item_to_loc(O, loc)
		O.throw_at(get_edge_target_turf(src, gib_throw_dir), rand(1, 5), 15)
		sleep(1)

	for(var/obj/item/clothing/C in H)
		if(HAS_TRAIT(C, TRAIT_NODROP) || stealthmode)
			qdel(C)
		H.drop_transfer_item_to_loc(C, loc)
		C.throw_at(get_edge_target_turf(src, gib_throw_dir), rand(1, 5), 15)
		sleep(1)

	visible_message("<span class='warning'>\The [src] spits out \the [H.name]'s possessions!")

/obj/machinery/gibber/autogibber/proc/cleanbay()
	var/spats = 0 //keeps track of how many items get spit out. Don't show a message if none are found.
	for(var/obj/O in src)
		if(stealthmode)
			qdel(O)
		else if(istype(O))
			O.forceMove(loc)
			O.throw_at(get_edge_target_turf(src, gib_throw_dir), rand(1, 5), 15)
			spats++
			sleep(1)
	if(spats)
		visible_message("<span class='warning'>\The [src] spits out more possessions!</span>")
