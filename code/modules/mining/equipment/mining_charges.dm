/****************Mining Charges****************/
/obj/item/grenade/plastic/miningcharge
	name = "industrial mining charge"
	desc = "Used to make big holes in rocks. Only works on rocks!"
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining-charge-2"
	det_time = 5
	var/smoke_amount = 3
	var/boom_sizes = list(2,3,5)
	var/hacked = FALSE

/obj/item/grenade/plastic/miningcharge/examine(mob/user)
	. = ..()
	if(hacked)
		. += "Its wiring is haphazardly changed."

/obj/item/grenade/plastic/miningcharge/Initialize()
	. = ..()
	image_overlay = mutable_appearance(icon, "[icon_state]_active", ON_EDGED_TURF_LAYER)

/obj/item/grenade/plastic/miningcharge/attack_self(mob/user)
	if(nadeassembly)
		nadeassembly.attack_self(user)

/obj/item/grenade/plastic/miningcharge/afterattack(atom/movable/AM, mob/user, flag)
	if(ismineralturf(AM) || hacked)
		if(isancientturf(AM) && !hacked)
			visible_message("<span class='notice'>This rock appears to be resistant to all mining tools except pickaxes!</span>")
			return
		..()

/obj/item/grenade/plastic/miningcharge/prime()
	if(hacked) //explosion
		explode()
		return
	var/turf/simulated/mineral/location = get_turf(target)
	var/datum/effect_system/smoke_spread/S = new
	S.set_up(smoke_amount,0,location,null)
	S.start()
	//location.attempt_drill(null,TRUE,3) //orange says it doesnt include the actual middle
	for(var/turf/simulated/mineral/rock in circlerangeturfs(location, boom_sizes[3]))
		var/distance = get_dist_euclidian(location,rock)
		if(distance <= boom_sizes[1])
			rock.attempt_drill(null,TRUE,3)
		else if (distance <= boom_sizes[2])
			rock.attempt_drill(null,TRUE,2)
		else if (distance <= boom_sizes[3])
			rock.attempt_drill(null,TRUE,1)

	for(var/mob/living/carbon/C in circlerange(location,boom_sizes[3]))
		if(ishuman(C)) //working on everyone
			var/distance = get_dist_euclidian(location,C)
			C.flash_eyes()
			C.Weaken((boom_sizes[2] - distance) * 1 SECONDS) //1 second for how close you are to center if you're in range
			C.AdjustDeaf((boom_sizes[3] - distance) * 10 SECONDS)
			var/obj/item/organ/internal/ears/ears = C.get_int_organ(/obj/item/organ/internal/ears)
			if(istype(ears))
				ears.receive_damage((boom_sizes[3] - distance) * 2) //something like that i guess. Mega charge makes 12 damage to ears if nearby
			to_chat(C, span_warning("<font size='2'><b>You are knocked down by the power of the mining charge!</font></b>"))
	qdel(src)

/obj/item/grenade/plastic/miningcharge/proc/explode() //c4 code
	var/turf/location
	if(target)
		if(!QDELETED(target))
			if(istype(target, /turf/))
				location = get_turf(target)
			else
				location = get_atom_on_turf(target)
			target.overlays -= image_overlay
	else
		location = get_atom_on_turf(src)
	if(location)
		explosion(location, boom_sizes[1], boom_sizes[2], boom_sizes[3], cause = src)
		location.ex_act(2, target)
	if(istype(target, /mob))
		var/mob/M = target
		M.gib()
	qdel(src)


/obj/item/grenade/plastic/miningcharge/proc/override_safety()
	hacked = TRUE
	boom_sizes[1] = round(boom_sizes[1]/3)	//lesser - 0, normal - 0, mega - 1; c4 - 0
	boom_sizes[2] = round(boom_sizes[2]/3)	//lesser - 0, normal - 1, mega - 2; c4 - 0
	boom_sizes[3] = round(boom_sizes[3]/1.5)//lesser - 2, normal - 3, mega - 5; c4 - 3

/obj/item/grenade/plastic/miningcharge/deconstruct(disassembled = TRUE) //no gibbing a miner with pda bombs
	if(!QDELETED(src))
		qdel(src)

/obj/item/grenade/plastic/miningcharge/lesser
	name = "mining charge"
	desc = "A mining charge. This one seems less powerful than industrial. Only works on rocks!"
	icon_state = "mining-charge-1"
	smoke_amount = 1
	boom_sizes = list(1,2,3)

/obj/item/grenade/plastic/miningcharge/mega
	name = "experimental mining charge"
	desc = "A mining charge. This one seems much more powerful than normal!"
	icon_state = "mining-charge-3"
	smoke_amount = 5
	boom_sizes = list(4,6,8) //did you see the price? It has to be better..

/obj/item/storage/backpack/duffel/miningcharges/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/grenade/plastic/miningcharge/lesser(src)
	for(var/i in 1 to 2)
		new /obj/item/grenade/plastic/miningcharge(src)


//MINING CHARGE HACKER
/obj/item/t_scanner/adv_mining_scanner/syndicate
	var/charges = 6
	description_antag = "This scanner has an extra port for overriding mining charge safeties."

/obj/item/t_scanner/adv_mining_scanner/syndicate/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istype(target,/obj/item/grenade/plastic/miningcharge))
		var/obj/item/grenade/plastic/miningcharge/charge = target
		if(charge.hacked)
			to_chat(user, span_notice("[src] is already overridden!"))
			return
		if(charges <= 0)
			to_chat(user, span_notice("Its overriding function is depleted."))
			return
		charge.override_safety()
		visible_message(span_warning("Sparks fly out of [src]!"), span_notice("You override [src], disabling its safeties."))
		playsound(src, "sparks", 50, 1)
		charges--
		if(charges <= 0)
			to_chat(user ,span_warning("[src]'s internal battery for overriding mining charges has run dry!"))
