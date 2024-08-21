/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = TRUE
	anchored = FALSE
	pressure_resistance = 2*ONE_ATMOSPHERE
	container_type = DRAINABLE | AMOUNT_VISIBLE
	max_integrity = 300
	var/tank_volume = 1000 //In units, how much the dispenser can hold
	var/reagent_id = "water" //The ID of the reagent that the dispenser uses
	var/lastrigger = "" // The last person to rig this fuel tank - Stored with the object. Only the last person matter for investigation
	var/went_boom = FALSE /// If the dispenser is being blown up already. Used to avoid multiple boom calls due to itself exploding etc

/obj/structure/reagent_dispensers/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		if(tank_volume && (damage_flag == "bullet" || damage_flag == "laser"))
			boom(FALSE, TRUE)


/obj/structure/reagent_dispensers/attackby(obj/item/I, mob/user, params)
	if(I.is_refillable())
		return ATTACK_CHAIN_PROCEED //so we can refill them via their afterattack.
	return ..()


/obj/structure/reagent_dispensers/Initialize(mapload)
	. = ..()
	create_reagents(tank_volume)
	reagents.add_reagent(reagent_id, tank_volume)

/obj/structure/reagent_dispensers/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(reagents)
		for(var/i in 1 to 8)
			if(reagents)
				reagents.temperature_reagents(exposed_temperature)

/obj/structure/reagent_dispensers/proc/boom(rigtrigger = FALSE, log_attack = FALSE)
	if(went_boom)
		return
	went_boom = TRUE
	visible_message("<span class='danger'>[src] ruptures!</span>")
	chem_splash(loc, 5, list(reagents))
	qdel(src)

/obj/structure/reagent_dispensers/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		if(!disassembled)
			boom(FALSE, TRUE)
	else
		qdel(src)

//Dispensers
/obj/structure/reagent_dispensers/watertank
	name = "water tank"
	desc = "A water tank."
	icon_state = "water"

/obj/structure/reagent_dispensers/watertank/high
	name = "high-capacity water tank"
	desc = "A highly-pressurized water tank made to hold gargantuan amounts of water.."
	icon_state = "water_high" //I was gonna clean my room...
	tank_volume = 100000


/obj/structure/reagent_dispensers/oil
	name = "oil tank"
	desc = "A tank of oil, commonly used to by robotics to fix leaking IPCs or just to loosen up those rusted underused parts."
	icon_state = "oil"
	reagent_id = "oil"
	tank_volume = 3000

/obj/structure/reagent_dispensers/fueltank
	name = "fuel tank"
	desc = "A tank full of industrial welding fuel. Do not consume."
	icon_state = "fuel"
	reagent_id = "fuel"
	tank_volume = 4000
	var/icon/rigged_olay
	var/obj/item/assembly_holder/rig = null
	var/accepts_rig = TRUE


/obj/structure/reagent_dispensers/fueltank/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/structure/reagent_dispensers/fueltank/Destroy()
	QDEL_NULL(rig)
	QDEL_NULL(rigged_olay)
	return ..()


/obj/structure/reagent_dispensers/fueltank/bullet_act(obj/item/projectile/P)
	var/will_explode = !QDELETED(src) && !P.nodamage && (P.damage_type == BURN || P.damage_type == BRUTE)

	if(will_explode) // Log here while you have the information needed
		add_attack_logs(P.firer, src, "shot with [P.name]", ATKLOG_FEW)
		investigate_log("[key_name_log(P.firer)] triggered a fueltank explosion with [P.name]", INVESTIGATE_BOMB)
	..()

/obj/structure/reagent_dispensers/fueltank/boom(rigtrigger = FALSE, log_attack = FALSE) // Prevent case where someone who rigged the tank is blamed for the explosion when the rig isn't what triggered the explosion
	if(rigtrigger) // If the explosion is triggered by an assembly holder
		add_attack_logs(lastrigger, src, "rigged fuel tank exploded", ATKLOG_FEW)
		investigate_log("A fueltank, last rigged by [lastrigger]", INVESTIGATE_BOMB)
	if(log_attack)
		add_attack_logs(usr, src, "blew up", ATKLOG_FEW)
	if(reagents)
		reagents.set_reagent_temp(1000) //uh-oh
	qdel(src)

/obj/structure/reagent_dispensers/fueltank/blob_act(obj/structure/blob/B)
	boom()

/obj/structure/reagent_dispensers/fueltank/ex_act()
	boom()

/obj/structure/reagent_dispensers/fueltank/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	boom()

/obj/structure/reagent_dispensers/fueltank/tesla_act()
	..() //extend the zap
	boom()

/obj/structure/reagent_dispensers/fueltank/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2 && rig)
		. += "<span class='notice'>There is some kind of device rigged to the tank.</span>"


/obj/structure/reagent_dispensers/fueltank/attack_hand()
	if(rig)
		usr.visible_message("<span class='notice'>[usr] begins to detach [rig] from [src].</span>", "<span class='notice'>You begin to detach [rig] from [src].</span>")
		if(do_after(usr, 2 SECONDS, src))
			add_fingerprint(usr)
			usr.visible_message("<span class='notice'>[usr] detaches [rig] from [src].</span>", "<span class='notice'>You detach [rig] from [src].</span>")
			rig.forceMove(get_turf(usr))
			rig = null
			qdel(GetComponent(/datum/component/proximity_monitor))
			lastrigger = null
			QDEL_NULL(rigged_olay)
			update_icon(UPDATE_OVERLAYS)


/obj/structure/reagent_dispensers/fueltank/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/assembly_holder))
		add_fingerprint(user)
		var/obj/item/assembly_holder/assembly = I
		if(!accepts_rig)
			to_chat(user, span_warning("The [name] is incompatible with [I]."))
			return ATTACK_CHAIN_PROCEED
		if(rig)
			to_chat(user, span_warning("There is another device in the way."))
			return ATTACK_CHAIN_PROCEED
		if(isigniter(assembly.a_left) && !isigniter(assembly.a_right))
			to_chat(user, span_warning("The [assembly.name] is incompatible with [src]."))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_warning("[user] starts rigging [assembly] to [src]."),
			span_notice("You start rigging [assembly] to [src]..."),
		)
		if(!do_after(user, 2 SECONDS, src, category = DA_CAT_TOOL) || rig || (isigniter(assembly.a_left) && !isigniter(assembly.a_right)))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(assembly, src))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_warning("[user] has rigged [assembly] to [src]."),
			span_notice("You have rigged [assembly] to [src]."),
		)
		add_attack_logs(user, src, "rigged fuel tank with [assembly.name] for explosion", ATKLOG_FEW)
		investigate_log("[key_name_log(user)] rigged [name] with [assembly.name] for explosion", INVESTIGATE_BOMB)
		lastrigger = "[key_name_log(user)]"
		rig = assembly
		if(rig.has_prox_sensors())
			AddComponent(/datum/component/proximity_monitor)
		rigged_olay = getFlatIcon(assembly)
		rigged_olay.Shift(NORTH, 1)
		rigged_olay.Shift(EAST, 6)
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/reagent_dispensers/fueltank/update_overlays()
	. = ..()
	if(rigged_olay)
		. += rigged_olay


/obj/structure/reagent_dispensers/fueltank/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!reagents.has_reagent("fuel"))
		to_chat(user, "<span class='warning'>[src] is out of fuel!</span>")
		return
	if(I.tool_enabled && I.use_tool(src, user, volume = I.tool_volume)) //check it's enabled first to prevent duplicate messages when refuelling
		user.visible_message("<span class='danger'>[user] catastrophically fails at refilling [user.p_their()] [I]!</span>", "<span class='userdanger'>That was stupid of you.</span>")
		add_attack_logs(user, src, "hit with lit welder")
		investigate_log("[key_name(user)] triggered a fueltank explosion", INVESTIGATE_BOMB)
		boom()
	else
		I.refill(user, src, reagents.get_reagent_amount("fuel")) //Try dump all fuel into the welder


/obj/structure/reagent_dispensers/fueltank/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	if(rig)
		rig.process_movement()

/obj/structure/reagent_dispensers/fueltank/HasProximity(atom/movable/AM)
	if(rig)
		rig.HasProximity(AM)


/obj/structure/reagent_dispensers/fueltank/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(rig)
		rig.assembly_crossed(arrived, old_loc)


/obj/structure/reagent_dispensers/fueltank/hear_talk(mob/living/M, list/message_pieces)
	if(rig)
		rig.hear_talk(M, message_pieces)

/obj/structure/reagent_dispensers/fueltank/hear_message(mob/living/M, msg)
	if(rig)
		rig.hear_message(M, msg)


/obj/structure/reagent_dispensers/fueltank/Bump(atom/bumped_atom)
	. = ..()
	if(. || !rig)
		return .
	rig.process_movement()


/obj/structure/reagent_dispensers/peppertank
	name = "pepper spray refiller"
	desc = "Contains condensed capsaicin for use in law \"enforcement.\""
	icon_state = "pepper"
	anchored = TRUE
	density = FALSE
	reagent_id = "condensedcapsaicin"

/obj/structure/reagent_dispensers/water_cooler
	name = "liquid cooler"
	desc = "A machine that dispenses liquid to drink."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "water_cooler"
	anchored = TRUE
	tank_volume = 500
	reagent_id = "water"
	var/paper_cups = 25 //Paper cups left from the cooler

/obj/structure/reagent_dispensers/water_cooler/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2)
		. += "<span class='notice'>There are [paper_cups ? paper_cups : "no"] paper cups left.</span>"

/obj/structure/reagent_dispensers/water_cooler/attack_hand(mob/living/user)
	if(!paper_cups)
		to_chat(user, "<span class='warning'>There aren't any cups left!</span>")
		return
	add_fingerprint(user)
	user.visible_message("<span class='notice'>[user] takes a cup from [src].</span>", "<span class='notice'>You take a paper cup from [src].</span>")
	var/obj/item/reagent_containers/food/drinks/sillycup/S = new(get_turf(src))
	user.put_in_hands(S, ignore_anim = FALSE)
	paper_cups--

/obj/structure/reagent_dispensers/water_cooler/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I, 40)

/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "Beer is liquid bread, it's good for you..."
	icon_state = "beer"
	reagent_id = "beer"
	var/has_lid = TRUE

/obj/structure/reagent_dispensers/beerkeg/blob_act(obj/structure/blob/B)
	explosion(loc, 0, 3, 5, 7, 10, cause = "[src.name] got blobbed")
	if(!QDELETED(src))
		qdel(src)

/obj/structure/reagent_dispensers/beerkeg/proc/add_lid()
		container_type = DRAINABLE | AMOUNT_VISIBLE
		has_lid = TRUE

/obj/structure/reagent_dispensers/beerkeg/proc/remove_lid()
		container_type = REFILLABLE | AMOUNT_VISIBLE
		has_lid = FALSE

/obj/structure/reagent_dispensers/beerkeg/attack_hand(mob/user)
	add_fingerprint(user)
	if(has_lid)
		to_chat(usr, "<span class='notice'>You take the lid off [src].</span>")
		remove_lid()
	else
		to_chat(usr, "<span class='notice'>You put the lid on [src].</span>")
		add_lid()

/obj/structure/reagent_dispensers/beerkeg/nuke
	name = "Nanotrasen-brand nuclear fission explosive"
	desc = "One of the more successful achievements of the Nanotrasen Corporate Warfare Division, their nuclear fission explosives are renowned for being cheap \
	to produce and devestatingly effective. Signs explain that though this is just a model, every Nanotrasen station is equipped with one, just in case. \
	All Captains carefully guard the disk needed to detonate them - at least, the sign says they do. There seems to be a tap on the back."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb0"

/obj/structure/reagent_dispensers/virusfood
	name = "virus food dispenser"
	desc = "A dispenser of low-potency virus mutagenic."
	icon_state = "virus_food"
	anchored = TRUE
	density = FALSE
	reagent_id = "virusfood"

/obj/structure/reagent_dispensers/spacecleanertank
	name = "space cleaner refiller"
	desc = "Refills space cleaner bottles."
	icon_state = "cleaner"
	anchored = TRUE
	density = FALSE
	tank_volume = 5000
	reagent_id = "cleaner"

/obj/structure/reagent_dispensers/fueltank/chem
	icon_state = "fuel_chem"
	anchored = TRUE
	density = FALSE
	accepts_rig = 0
	tank_volume = 1000
