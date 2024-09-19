/mob/living/simple_animal/bot/secbot/griefsky //This bot is powerful. If you managed to get 4 eswords somehow, you deserve this horror. Emag him for best results.
	name = "\improper General Griefsky"
	desc = "Is that a secbot with four eswords in its arms...?"
	icon_state = "griefsky0"
	health = 100
	maxHealth = 100
	base_icon = "griefsky"
	window_name = "Automatic Security Unit v3.0"

	var/spin_icon = "griefsky-c"  // griefsky and griefsky junior have dif icons
	var/weapon = /obj/item/melee/energy/sword
	var/block_chance = 50   //block attacks
	var/reflect_chance = 80 // chance to reflect projectiles
	var/dmg = 30 //esword dmg
	var/block_chance_melee = 50
	var/block_chance_ranged = 90
	var/stun_chance = 50
	var/spam_flag = FALSE
	var/frustration_number = 15
	var/syndie = FALSE	// taipan griefsky


/mob/living/simple_animal/bot/secbot/griefsky/toy  //A toy version of general griefsky!
	name = "Genewul Giftskee"
	desc = "An adorable looking secbot with four toy swords taped to its arms"
	spin_icon = "griefskyj-c"
	health = 50
	maxHealth = 50
	radio_channel = "Service" //we dont report sec anymore!
	dmg = 0
	block_chance_melee = 1
	block_chance_ranged = 1
	stun_chance = 0
	bot_core_type = /obj/machinery/bot_core/toy
	weapon = /obj/item/toy/sword
	frustration_number = 5
	locked = FALSE


/obj/machinery/bot_core/toy
	req_access = list(ACCESS_MAINT_TUNNELS, ACCESS_THEATRE, ACCESS_ROBOTICS)


/mob/living/simple_animal/bot/secbot/griefsky/syndicate
	radio_channel = "SyndTaipan"
	name = "Генерал Синди"
	icon_state = "general_syndie0"
	base_icon = "general_syndie"
	spin_icon = "general_syndie-c"
	desc = "В процессе его создания пострадало как минимум 24 агента. 22 из них не выжили..."
	faction = list("syndicate")
	allow_pai = TRUE
	auto_patrol = TRUE
	remote_disabled = TRUE
	weaponscheck = TRUE
	check_records = FALSE
	idcheck = TRUE
	bot_core_type = /obj/machinery/bot_core/syndicate
	syndie = TRUE


/obj/machinery/bot_core/syndicate
	req_access = list(ACCESS_SYNDICATE)


/mob/living/simple_animal/bot/secbot/griefsky/Initialize(mapload)
	. = ..()
	icon_state = "[base_icon][on]"
	var/datum/job/detective/J = new/datum/job/detective
	access_card.access += J.get_access()
	prev_access = access_card.access


/mob/living/simple_animal/bot/secbot/griefsky/Destroy()
	QDEL_NULL(weapon)
	return ..()


/mob/living/simple_animal/bot/secbot/griefsky/back_to_idle()
	..()
	playsound(loc, 'sound/weapons/saberoff.ogg', 50, TRUE, -1)


/mob/living/simple_animal/bot/secbot/griefsky/emag_act(mob/user)
	..()
	light_color = LIGHT_COLOR_PURE_RED //if you see a red one. RUN!!


/mob/living/simple_animal/bot/secbot/griefsky/secbot_crossed(mob/living/carbon/arrived)
	if(!iscarbon(arrived) || arrived != target || in_range(src, arrived))
		return FALSE

	visible_message(span_danger("[src] flails his swords and pushes [arrived] out of it's way!"))
	arrived.Weaken(4 SECONDS)


/mob/living/simple_animal/bot/secbot/griefsky/UnarmedAttack(atom/A) //like secbots its only possible with admin intervention
	if(!on || !can_unarmed_attack())
		return
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		sword_attack(C)


/mob/living/simple_animal/bot/secbot/griefsky/bullet_act(obj/item/projectile/P) //so uncivilized
	retaliate(P.firer)
	if((icon_state == spin_icon) && (prob(block_chance_ranged))) //only when the eswords are on
		visible_message("[src] deflects [P] with its energy swords!")
		playsound(loc, 'sound/weapons/blade1.ogg', 50, 1, 0)
	else
		..()

/mob/living/simple_animal/bot/secbot/griefsky/proc/sword_attack(mob/living/carbon/C)     // esword attack
	if((HAS_TRAIT(src, TRAIT_PACIFISM) || GLOB.pacifism_after_gt) && dmg)
		if(usr)
			to_chat(usr, span_warning("You don't want to harm other living beings!"))
		return
	do_attack_animation(C)
	playsound(loc, 'sound/weapons/blade1.ogg', 50, TRUE, -1)
	addtimer(CALLBACK(src, PROC_REF(do_sword_attack), C), 0.2 SECONDS)


/mob/living/simple_animal/bot/secbot/griefsky/proc/do_sword_attack(mob/living/carbon/C)
	icon_state = spin_icon
	var/threat = C.assess_threat(src)
	if(ishuman(C))
		C.apply_damage(dmg, BRUTE)
		if(prob(stun_chance))
			C.Weaken(10 SECONDS)
	if(dmg)
		add_attack_logs(src, C, "sliced")
	if(declare_arrests)
		var/area/location = get_area(src)
		if(!spam_flag)
			if(syndie)
				speak("Back away! I will deal with this [("syndicate" in C.faction) ? "level [threat]" : "Nanotrasen"] swine <b>[C]</b> in [location] myself!.", radio_channel)
			else
				speak("Back away! I will deal with this level [threat] swine <b>[C]</b> in [location] myself!.", radio_channel)
			spam_flag = TRUE
			addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), 10 SECONDS)	//to avoid spamming comms of sec for each hit
			visible_message("[src] flails his swords and cuts [C]!")


/mob/living/simple_animal/bot/secbot/griefsky/handle_automated_action()
	if(!on)
		return

	if(hijacked)
		return // is there a good reason this override doesn't call its parent?

	switch(mode)
		if(BOT_IDLE)		// idle
			icon_state = "[base_icon][on]"
			SSmove_manager.stop_looping(src)
			set_path(null)
			look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = BOT_START_PATROL	// switch to patrol mode
		if(BOT_HUNT)		// hunting for perp
			icon_state = spin_icon
			playsound(loc,'sound/effects/spinsabre.ogg',50,1,-1)
			if(frustration >= frustration_number) // general beepsky doesn't give up so easily, jedi scum
				SSmove_manager.stop_looping(src)
				set_path(null)
				back_to_idle()
				return
			if(target)		// make sure target exists
				if(target.stat == !DEAD)
					if(Adjacent(target) && isturf(target.loc))	// if right next to perp
						target_lastloc = target.loc
						sword_attack(target)
						set_anchored(TRUE)
						frustration++
						return
					else	// not next to perp
						var/turf/olddist = get_dist(src, target)
						SSmove_manager.move_to(src, target, 1, 3)	//he's a fast fucker
						if((get_dist(src, target)) >= (olddist))
							frustration++
						else
							frustration = 0
				else
					back_to_idle()
					speak("You fool")
			else
				back_to_idle()

		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			icon_state = "[base_icon][on]"
			look_for_perp()
			bot_patrol()


/mob/living/simple_animal/bot/secbot/griefsky/look_for_perp()
	set_anchored(FALSE)
	for (var/mob/living/carbon/C in view(7,src)) //Let's find us a criminal
		if((C.stat) || (C.handcuffed))
			continue

		if((C.name == oldtarget_name) && (world.time < last_found + 10 SECONDS))
			continue

		if(syndie)
			if(idcheck && istype(C.get_id_card(), /obj/item/card/id/syndicate))
				threatlevel = 0
			else if(!("syndicate" in C.faction))
				threatlevel = 20
			if(is_taipan(z) && C.mind?.assigned_role != "Space Base Syndicate Comms Officer" && (check_for_mug(C.get_active_hand()) || check_for_mug(C.get_inactive_hand())))
				speak("[C.name] наглый вор! Положи кружку!", radio_channel)
				threatlevel += 4
		else
			threatlevel = C.assess_threat(src)

		if(!threatlevel)
			continue

		else if(threatlevel >= 4)
			target = C
			oldtarget_name = C.name
			speak("You are a bold one")
			playsound(src,'sound/weapons/saberon.ogg',50,TRUE,-1)
			visible_message("[src] ignites his energy swords!")
			icon_state = "[base_icon]-c"
			visible_message("<b>[src]</b> points at [C.name]!")
			mode = BOT_HUNT
			INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
			break
		else
			continue


/**
 * Taipan bullshit.
 */
/mob/living/simple_animal/bot/secbot/griefsky/proc/check_for_mug(obj/item/slot_item)
	if(istype(slot_item, /obj/item/reagent_containers/food/drinks/mug/comms))
		return TRUE
	return FALSE


/mob/living/simple_animal/bot/secbot/griefsky/explode()
	SSmove_manager.stop_looping(src)
	visible_message(span_boldannounceic("[src] lets out a huge cough as it blows apart!"))
	var/turf/Tsec = get_turf(src)
	new /obj/item/assembly/prox_sensor(Tsec)
	var/obj/item/secbot_assembly/Sa = new /obj/item/secbot_assembly(Tsec)
	Sa.build_step = 1
	Sa.add_overlay("hs_hole")
	Sa.created_name = name
	if(prob(50))
		new /obj/item/robot_parts/r_arm(Tsec)
	if(prob(50)) //most of the time weapon will be destroyed
		new weapon(Tsec)
	if(prob(25))
		new weapon(Tsec)
	if(prob(10))
		new weapon(Tsec)
	if(prob(5))
		new weapon(Tsec)
	do_sparks(3, 1, src)
	new /obj/effect/decal/cleanable/blood/oil(loc)
	qdel(src)


/**
 * This section is blocking attack.
 */
/mob/living/simple_animal/bot/secbot/griefsky/bullet_act(obj/item/projectile/P) //so uncivilized
	retaliate(P.firer)
	if((icon_state == spin_icon) && (prob(block_chance_ranged))) //only when the eswords are on
		visible_message("[src] deflects [P] with its energy swords!")
		playsound(loc, 'sound/weapons/blade1.ogg', 50, 1, 0)
	else
		..()


/**
 * Allows special actions to take place after being attacked.
 */
/mob/living/simple_animal/bot/secbot/griefsky/proc/special_retaliate_after_attack(mob/user)
	if(icon_state != spin_icon)
		return
	if(prob(block_chance_melee))
		visible_message("[src] deflects [user]'s attack with his energy swords!")
		playsound(loc, 'sound/weapons/blade1.ogg', 50, TRUE, -1)
		return TRUE


/mob/living/simple_animal/bot/secbot/griefsky/attack_hand(mob/living/carbon/human/H)
	if((H.a_intent == INTENT_HARM) || (H.a_intent == INTENT_DISARM))
		retaliate(H)
		if(special_retaliate_after_attack(H))
			return
	return ..()


/mob/living/simple_animal/bot/secbot/griefsky/attackby(obj/item/I, mob/user, params) //cant touch or attack him while spinning
	if(icon_state == spin_icon && prob(block_chance_melee))	// FFS! have no time to rework this now
		user.do_attack_animation(src)
		visible_message("[src] deflects [user]'s move with his energy swords!")
		playsound(loc, 'sound/weapons/blade1.ogg', 50, TRUE, -1)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

