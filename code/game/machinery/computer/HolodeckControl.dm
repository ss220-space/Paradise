/obj/machinery/computer/HolodeckControl
	name = "holodeck control computer"
	desc = "A computer used to control a nearby holodeck."
	icon_keyboard = "tech_key"
	icon_screen = "holocontrol"

	/// String name of the currently selected holodeck state
	var/selected_deck = "Empty Court"
	/// The default deck for this holodeck incase of emergency / destruction
	var/area/shutdown_state = /area/holodeck/source_plating
	/// All decks available to the player, will automatically be selectable in the menu if put in this list
	var/list/available_decks = list(
		"Empty Court" = /area/holodeck/source_emptycourt,
		"Boxing Court" = /area/holodeck/source_boxingcourt,
		"Basketball Court" = /area/holodeck/source_basketball,
		"Thunderdome Court" = /area/holodeck/source_thunderdomecourt,
		"Beach" = /area/holodeck/source_beach,
		"Desert" = /area/holodeck/source_desert,
		"Space" = /area/holodeck/source_space,
		"Picnic Area" = /area/holodeck/source_picnicarea,
		"Snow Field" = /area/holodeck/source_snowfield,
		"Theatre" = /area/holodeck/source_theatre,
		"Meeting Hall" = /area/holodeck/source_meetinghall,
		"Knight Arena" = /area/holodeck/source_knightarena,
	)
	var/emag_deck = /area/holodeck/source_wildlife
	var/area/linkedholodeck = null
	var/area/target = null
	var/active = FALSE
	var/list/holographic_items = list()
	var/last_change = 0

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/HolodeckControl/Initialize(mapload)
	. = ..()
	linkedholodeck = locate(/area/holodeck/alphadeck)

/obj/machinery/computer/HolodeckControl/Destroy()
	emergency_shutdown()
	return ..()

/obj/machinery/computer/HolodeckControl/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/HolodeckControl/attackby(obj/item/D, mob/user)
	return

/obj/machinery/computer/HolodeckControl/attack_ghost(mob/user)
	ui_interact(user)
	return ..()

/obj/machinery/computer/HolodeckControl/attack_hand(mob/user)
	ui_interact(user)
	return ..()

/obj/machinery/computer/HolodeckControl/process()
	for(var/item in holographic_items) // do this first, to make sure people don't take items out when power is down.
		if(!(get_turf(item) in linkedholodeck))
			derez(item, 0)

	if(!..())
		return

	if(active)
		if(!check_deck_integrity(linkedholodeck))
			target = locate(/area/holodeck/source_plating)
			if(target)
				loadProgram(target)
			active = FALSE
			for(var/mob/M in range(10,src))
				M.show_message("The holodeck overloads!")


			for(var/turf/T in linkedholodeck)
				if(prob(30))
					do_sparks(2, 1, T)
				T.ex_act(3)
				T.hotspot_expose(1000,500,1)

/obj/machinery/computer/HolodeckControl/proc/loadProgram(area/A)

	if(world.time < (last_change + 25))
		if(world.time < (last_change + 15))//To prevent super-spam clicking, reduced process size and annoyance -Sieve
			return
		for(var/mob/M in range(3,src))
			M.show_message("<b>ERROR. Recalibrating projection apparatus.</b>")
			last_change = world.time
			return

	last_change = world.time
	active = TRUE

	for(var/item in holographic_items)
		derez(item)
	for(var/obj/effect/decal/cleanable/blood/B in linkedholodeck)
		qdel(B)
	for(var/mob/living/simple_animal/hostile/carp/holocarp/C in linkedholodeck)
		qdel(C)
	holographic_items = A.copy_contents_to(linkedholodeck, platingRequired = TRUE)

	if(emagged)
		for(var/obj/item/holo/H in linkedholodeck)
			H.damtype = BRUTE

	spawn(30)
		for(var/obj/effect/landmark/L in linkedholodeck)
			if(L.name=="Holocarp Spawn")
				new /mob/living/simple_animal/hostile/carp/holocarp(L.loc)


/obj/machinery/computer/HolodeckControl/proc/emergency_shutdown()
	//Get rid of any items
	for(var/item in holographic_items)
		derez(item)
	//Turn it back to the regular non-holographic room
	target = locate(/area/holodeck/source_plating)
	if(target)
		loadProgram(target)

	var/area/targetsource = locate(/area/holodeck/source_plating)
	targetsource.copy_contents_to(linkedholodeck , 1)
	active = FALSE


/obj/machinery/computer/HolodeckControl/proc/derez(obj/obj, silent = TRUE)
	holographic_items.Remove(obj)

	if(!istype(obj))
		return

	var/mob/M = obj.loc
	if(istype(M))
		M.unEquip(obj, TRUE) //Holoweapons should always drop.

	if(!silent)
		var/obj/old_obj = obj
		visible_message("[old_obj] fades away!")
	qdel(obj)

/obj/machinery/computer/HolodeckControl/proc/check_deck_integrity(area/A)
	for(var/turf/space/T in A)
		return FALSE
	return TRUE

/obj/machinery/computer/HolodeckControl/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/HolodeckControl/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Holodeck", name)
		ui.autoupdate = TRUE
		ui.open()

/obj/machinery/computer/HolodeckControl/ui_data(mob/user)
	var/list/data = list()
	data["current_deck"] = selected_deck
	data["emagged"] = emagged
	data["ai_override"] = issilicon(user)
	data["decks"] = list()
	for(var/deck_name in available_decks)
		data["decks"] += deck_name
	return data

/obj/machinery/computer/HolodeckControl/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	. = TRUE

	add_fingerprint(ui.user)
	switch(action)
		if("select_deck")
			target = locate(available_decks[params["deck"]])
			selected_deck = params["deck"]
			if(target)
				loadProgram(target)
		if("ai_override")
			if(!issilicon(ui.user))
				return
			emagged = !emagged
			if(emagged)
				message_admins("[key_name_admin(ui.user)] overrode the holodeck's safeties")
				log_game("[key_name(ui.user)] overrode the holodeck's safeties")
				return
			message_admins("[key_name_admin(ui.user)] restored the holodeck's safeties")
			log_game("[key_name(ui.user)] restored the holodeck's safeties")
		if("wildlifecarp")
			if(!emagged)
				return
			target = locate(emag_deck)
			selected_deck = "Wildlife Simulation"
			if(target)
				loadProgram(target)

/obj/machinery/computer/HolodeckControl/emag_act(user)
	if(emagged)
		return
	playsound(loc, 'sound/effects/sparks4.ogg', 75, 1)
	emagged = TRUE
	to_chat(user, "<span class='notice'>You vastly increase projector power and override the safety and security protocols.</span>")
	to_chat(user, "Warning! Automatic shutoff and derezing protocols have been corrupted. Please call Nanotrasen maintenance and do not use the simulator.")
	log_game("[key_name(user)] emagged the Holodeck Control Computer")

/obj/machinery/computer/HolodeckControl/emp_act(severity)
	emergency_shutdown()
	..()

/obj/machinery/computer/HolodeckControl/ex_act(severity)
	emergency_shutdown()
	..()

/obj/machinery/computer/HolodeckControl/blob_act(obj/structure/blob/B)
	emergency_shutdown()
	return ..()
// Holographic Items!
/turf/simulated/floor/holofloor/
	thermal_conductivity = 0
	icon_state = "plating"
/turf/simulated/floor/holofloor/grass
	name = "Lush Grass"
	icon_state = "grass1"
	floor_tile = /obj/item/stack/tile/grass

/turf/simulated/floor/holofloor/grass/New()
	..()
	spawn(1)
		update_icon()

/turf/simulated/floor/holofloor/grass/update_icon()
	..()
	if(!(icon_state in list("grass1", "grass2", "grass3", "grass4", "sand")))
		icon_state = "grass[pick("1","2","3","4")]"

/turf/simulated/floor/holofloor/attackby(obj/item/W as obj, mob/user as mob, params)
	return
	// HOLOFLOOR DOES NOT GIVE A FUCK

/turf/simulated/floor/holofloor/space
	name = "\proper space"
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	plane = PLANE_SPACE

/turf/simulated/floor/holofloor/space/Initialize(mapload)
	icon_state = SPACE_ICON_STATE // so realistic
	. = ..()

/turf/simulated/floor/holofloor/space/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/space.dmi'
	underlay_appearance.icon_state = SPACE_ICON_STATE
	underlay_appearance.plane = PLANE_SPACE
	return TRUE

/obj/structure/table/holotable/has_prints()
	return FALSE

/obj/structure/table/holotable
	flags = NODECONSTRUCT
	canSmoothWith = list(/obj/structure/table/holotable)

/obj/structure/table/holotable/wood
	name = "wooden table"
	desc = "A square piece of wood standing on four wooden legs. It can not move."
	icon = 'icons/obj/smooth_structures/wood_table.dmi'
	icon_state = "wood_table"
	canSmoothWith = list(/obj/structure/table/holotable/wood)

/obj/structure/chair/stool/holostool/has_prints()
	return FALSE

/obj/structure/chair/stool/holostool
	flags = NODECONSTRUCT
	item_chair = null

/obj/item/clothing/gloves/boxing/hologlove
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	item_state = "boxing"

/obj/structure/holowindow/has_prints()
	return FALSE

/obj/structure/holowindow
	name = "reinforced window"
	icon = 'icons/obj/structures.dmi'
	icon_state = "rwindow"
	desc = "A window."
	density = 1
	layer = 3.2//Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1.0
	flags = ON_BORDER

/obj/structure/rack/holorack/has_prints()
	return FALSE

/obj/structure/rack/holorack
	flags = NODECONSTRUCT

/obj/item/holo
	damtype = STAMINA

/obj/item/holo/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 40
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 50

/obj/item/holo/claymore/blue
	icon_state = "claymoreblue"
	item_state = "claymoreblue"

/obj/item/holo/claymore/red
	icon_state = "claymorered"
	item_state = "claymorered"

/obj/item/holo/esword
	name = "Holographic Energy Sword"
	desc = "This looks like a real energy sword!"
	icon_state = "sword0"
	hitsound = "swing_hit"
	force = 3.0
	throw_speed = 1
	throw_range = 5
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	armour_penetration = 50
	block_chance = 50
	var/active = 0

/obj/item/holo/esword/green/New()
	..()
	item_color = "green"

/obj/item/holo/esword/red/New()
	..()
	item_color = "red"

/obj/item/holo/esword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(active)
		return ..()
	return 0

/obj/item/holo/esword/New()
	..()
	item_color = pick("red","blue","green","purple")

/obj/item/holo/esword/attack_self(mob/living/user as mob)
	active = !active
	if(active)
		force = 30
		icon_state = "sword[item_color]"
		hitsound = "sound/weapons/blade1.ogg"
		w_class = WEIGHT_CLASS_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 20, 1)
		to_chat(user, span_notice("[src] is now active."))
	else
		force = 3
		icon_state = "sword0"
		hitsound = "swing_hit"
		w_class = WEIGHT_CLASS_SMALL
		playsound(user, 'sound/weapons/saberoff.ogg', 20, 1)
		to_chat(user, span_notice("[src] can now be concealed."))
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	return

//BASKETBALL OBJECTS
/obj/item/beach_ball/holoball
	icon = 'icons/obj/basketball.dmi'
	icon_state = "basketball"
	name = "basketball"
	item_state = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets

/obj/item/beach_ball/holoball/baseball
	icon_state = "baseball"
	name = "baseball"
	item_state = "baseball"
	desc = "Take me out to the ball game."

/obj/structure/holohoop
	name = "basketball hoop"
	desc = "Boom, Shakalaka!"
	icon = 'icons/obj/basketball.dmi'
	icon_state = "hoop"
	anchored = 1
	density = 1
	pass_flags = LETPASSTHROW

/obj/structure/holohoop/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/grab) && get_dist(src,user)<2)
		var/obj/item/grab/G = W
		if(G.state<2)
			to_chat(user, span_warning("You need a better grip to do that!"))
			return
		G.affecting.loc = src.loc
		G.affecting.Weaken(10 SECONDS)
		visible_message(span_warning("[G.assailant] dunks [G.affecting] into [src]!"))
		qdel(W)
		return
	else if(istype(W, /obj/item) && get_dist(src,user)<2)
		user.drop_from_active_hand(src)
		visible_message(span_notice("[user] dunks [W] into the [src]!"))
		return

/obj/structure/holohoop/has_prints()
	return FALSE

/obj/structure/holohoop/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover,/obj/item) && mover.throwing)
		var/obj/item/I = mover
		if(istype(I, /obj/item/projectile))
			return
		if(prob(50))
			I.loc = src.loc
			visible_message(span_notice("Swish! \the [I] lands in \the [src]."))
		else
			visible_message(span_alert("\The [I] bounces off of \the [src]'s rim!"))
		return 0
	else
		return ..(mover, target, height)

/obj/structure/holohoop/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isitem(AM) && !istype(AM,/obj/item/projectile))
		if(prob(50))
			AM.forceMove(get_turf(src))
			visible_message(span_warning("Swish! [AM] lands in [src]."))
			return
		else
			visible_message(span_danger("[AM] bounces off of [src]'s rim!"))
			return ..()
	else
		return ..()

/obj/machinery/readybutton
	name = "Ready Declaration Device"
	desc = "This device is used to declare ready. If all devices in an area are ready, the event will begin!"
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "auth_off"
	var/ready = 0
	var/area/currentarea = null
	var/eventstarted = 0

	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON

/obj/machinery/readybutton/attack_ai(mob/user as mob)
	to_chat(user, "The station AI is not to interact with these devices.")
	return

/obj/machinery/readybutton/attackby(obj/item/W as obj, mob/user as mob, params)
	add_fingerprint(user)
	to_chat(user, "The device is a solid button, there's nothing you can do with it!")

/obj/machinery/readybutton/attack_hand(mob/user as mob)
	if(user.stat || stat & (BROKEN))
		to_chat(user, "This device is not functioning.")
		return

	currentarea = get_area(src.loc)
	if(!currentarea)
		qdel(src)

	if(eventstarted)
		to_chat(usr, "The event has already begun!")
		return

	add_fingerprint(user)
	ready = !ready

	update_icon()

	var/numbuttons = 0
	var/numready = 0
	for(var/obj/machinery/readybutton/button in currentarea.machinery_cache)
		numbuttons++
		if(button.ready)
			numready++

	if(numbuttons == numready)
		begin_event()

/obj/machinery/readybutton/update_icon()
	if(ready)
		icon_state = "auth_on"
	else
		icon_state = "auth_off"

/obj/machinery/readybutton/proc/begin_event()
	eventstarted = 1

	for(var/obj/structure/holowindow/W in currentarea)
		qdel(W)

	for(var/mob/M in currentarea)
		to_chat(M, "FIGHT!")
