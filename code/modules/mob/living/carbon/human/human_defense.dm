/*
Contains most of the procs that are called when a mob is attacked by something

bullet_act
ex_act
meteor_act
emp_act

*/


/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone)
	if(!dna.species.bullet_act(P, src))
		add_attack_logs(P.firer, src, "hit by [P.type] but got deflected by species '[dna.species]'")
		return FALSE
	if(P.is_reflectable(REFLECTABILITY_ENERGY))
		var/can_reflect = check_reflect(def_zone)
		var/reflected = FALSE

		switch(can_reflect)
			if(1) // proper reflection
				reflected = TRUE
			if(2) //If target is holding a toy sword
				var/static/list/safe_list = list(/obj/item/projectile/beam/lasertag, /obj/item/projectile/beam/practice)
				reflected = is_type_in_list(P, safe_list) //And it's safe

		if(reflected)
			visible_message("<span class='danger'>The [P.name] gets reflected by [src]!</span>", \
				   "<span class='userdanger'>The [P.name] gets reflected by [src]!</span>")
			add_attack_logs(P.firer, src, "hit by [P.type] but got reflected")
			P.reflect_back(src)
			return -1

	//Shields
	if(check_shields(P, P.damage, "the [P.name]", PROJECTILE_ATTACK, P.armour_penetration))
		P.on_hit(src, 100, def_zone)
		return 2


	if(mind?.martial_art?.reflection_chance) //Some martial arts users can even reflect projectiles!
		if(body_position != LYING_DOWN && !HAS_TRAIT(src, TRAIT_HULK) && prob(mind.martial_art.reflection_chance)) //But only if they're not lying down, and hulks can't do it
			var/checks_passed = TRUE
			if(istype(mind.martial_art, /datum/martial_art/ninja_martial_art))
				var/datum/martial_art/ninja_martial_art/creeping_widow = mind.martial_art
				if(!creeping_widow.check_katana(mind.current))
					checks_passed = FALSE
			if(checks_passed)
				visible_message("<span class='danger'>The [P.name] gets reflected by [src]!</span>", \
			"<span class='userdanger'>The [P.name] gets reflected by [src]!</span>")
				add_attack_logs(P.firer, src, "hit by [P.type] but got reflected by martial arts '[mind.martial_art]'")
				P.reflect_back(src)
				return -1
			return FALSE

	if(mind?.martial_art?.deflection_chance) //Some martial arts users can deflect projectiles!
		if(body_position != LYING_DOWN && !HAS_TRAIT(src, TRAIT_HULK) && mind.martial_art.try_deflect(src)) //But only if they're not lying down, and hulks can't do it
			add_attack_logs(P.firer, src, "hit by [P.type] but got deflected by martial arts '[mind.martial_art]'")
			if(HAS_TRAIT(src, TRAIT_PACIFISM) || !P.is_reflectable(REFLECTABILITY_PHYSICAL)) //if it cannot be reflected, it hits the floor. This is the exception to the rule
				// Pacifists can deflect projectiles, but not reflect them.
				// Instead, they deflect them into the ground below them.
				var/turf/T = get_turf(src)
				P.firer = src
				T.bullet_act(P)
				visible_message("<span class='danger'>[src] deflects the projectile into the ground!</span>", "<span class='userdanger'>You deflect the projectile towards the ground beneath your feet!</span>")
				playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, TRUE)
			if(mind.martial_art.reroute_deflection)
				P.firer = src
				P.set_angle(rand(0, 360))
				return -1
			else
				return FALSE

	var/obj/item/organ/external/organ = get_organ(check_zone(def_zone))
	if(isnull(organ))
		return bullet_act(P, BODY_ZONE_CHEST) //act on chest instead

	organ.add_autopsy_data(P.name, P.damage) // Add the bullet's name to the autopsy data
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, P, def_zone)
	return (..(P , def_zone))

/mob/living/carbon/human/welder_act(mob/user, obj/item/I)
	var/mob/living/carbon/human/H = user
	if(user.a_intent != INTENT_HELP)
		return
	if(!I.tool_use_check(user, 1))
		return
	var/obj/item/organ/external/S = bodyparts_by_name[user.zone_selected]
	if(!S)
		return
	if(!S.is_robotic() || S.open == ORGAN_SYNTHETIC_OPEN)
		return
	. = TRUE
	if(S.brute_dam > ROBOLIMB_SELF_REPAIR_CAP)
		to_chat(user, "<span class='danger'>The damage is far too severe to patch over externally.</span>")
		return

	if(!S.brute_dam)
		to_chat(user, "<span class='notice'>Nothing to fix!</span>")
		return

	var/surgery_time = 0
	if(user == src)
		surgery_time = 10
	if(!I.use_tool(src, user, surgery_time, amount = 1, volume = I.tool_volume))
		return
	var/rembrute = HEALPERWELD
	var/nrembrute = 0
	var/childlist
	if(LAZYLEN(S.children))
		childlist = S.children.Copy()
	var/parenthealed = FALSE
	var/should_update_health = FALSE
	var/update_damage_icon = NONE
	while(rembrute > 0)
		var/obj/item/organ/external/E
		if(S.brute_dam)
			E = S
		else if(LAZYLEN(childlist))
			E = pick_n_take(childlist)
			if(!E.brute_dam || !E.is_robotic())
				continue
		else if(S.parent && !parenthealed)
			E = S.parent
			parenthealed = TRUE
			if(!E.brute_dam || !E.is_robotic())
				break
		else
			break
		nrembrute = max(rembrute - E.brute_dam, 0)
		var/brute_was = E.brute_dam
		update_damage_icon |= E.heal_damage(rembrute, 0, FALSE, TRUE, FALSE)
		if(E.brute_dam != brute_was)
			should_update_health = TRUE
		rembrute = nrembrute
		user.visible_message("<span class='alert'>[user] patches some dents on [src]'s [E.name] with [I].</span>")
	if(should_update_health)
		H.updatehealth("welder repair")
	if(update_damage_icon)
		H.UpdateDamageIcon()
	if(bleed_rate && ismachineperson(src))
		bleed_rate = 0
		user.visible_message("<span class='alert'>[user] patches some leaks on [src] with [I].</span>")
	if(IgniteMob())
		add_attack_logs(user, src, "set on fire with [I]")


/mob/living/carbon/human/check_projectile_dismemberment(obj/item/projectile/P, def_zone)
	var/obj/item/organ/external/affecting = get_organ(check_zone(def_zone))
	if(affecting && !affecting.cannot_amputate && affecting.get_damage() >= (affecting.max_damage - P.dismemberment))
		var/damtype = DROPLIMB_SHARP
		if(!P.dismember_limbs)
			switch(P.damage_type)
				if(BRUTE)
					damtype = DROPLIMB_BLUNT
				if(BURN)
					damtype = DROPLIMB_BURN
		if(P.dismember_head && istype(affecting, /obj/item/organ/external/head))
			damtype = DROPLIMB_SHARP
		affecting.droplimb(FALSE, damtype)


/mob/living/carbon/human/getarmor(def_zone, attack_flag)
	var/armorval = 0
	var/organnum = 0

	if(def_zone)
		if(isexternalorgan(def_zone))
			return getarmor_organ(def_zone, attack_flag)
		var/obj/item/organ/external/affecting = get_organ(def_zone)
		if(affecting)
			return getarmor_organ(affecting, attack_flag)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/obj/item/organ/external/organ as anything in bodyparts)
		armorval += getarmor_organ(organ, attack_flag)
		organnum++

	return (armorval/max(organnum, 1))


/// This proc returns the armour value for a particular external organ.
/mob/living/carbon/human/proc/getarmor_organ(obj/item/organ/external/def_zone, attack_flag)
	if(!attack_flag || !def_zone)
		return 0
	var/protection = 100
	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, l_ear, r_ear, wear_id, neck) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/obj/item/clothing/cloth in clothing_items)
		if(cloth.body_parts_covered & def_zone.limb_body_flag)
			protection *= (100 - min(cloth.armor.getRating(attack_flag), 100)) * 0.01
	protection *= (100 - min(physiology.armor.getRating(attack_flag), 100)) * 0.01
	return 100 - protection


//this proc returns the Siemens coefficient of electrical resistivity for a particular external organ.
/mob/living/carbon/human/proc/get_siemens_coefficient_organ(obj/item/organ/external/def_zone)
	if(!def_zone)
		return 1.0

	var/siemens_coefficient = 1.0

	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?
	for(var/obj/item/clothing/cloth in clothing_items)
		if(cloth.body_parts_covered & def_zone.limb_body_flag) // Is that body part being targeted covered?
			siemens_coefficient *= cloth.siemens_coefficient

	return siemens_coefficient


/mob/living/carbon/human/proc/check_reflect(def_zone) //Reflection checks for anything in your l_hand, r_hand, or wear_suit based on the reflection chance var of the object
	if(wear_suit?.IsReflect(def_zone) == 1)
		return 1

	if(l_hand)
		var/result = l_hand.IsReflect(def_zone)
		if(result)
			return result

	if(r_hand)
		var/result = r_hand.IsReflect(def_zone)
		if(result)
			return result

	return 0


//End Here

/mob/living/carbon/human/proc/check_shields(atom/AM, damage, attack_text = "the attack", attack_type = MELEE_ATTACK, armour_penetration = 0, shields_penetration = 0)
	var/block_chance_modifier = round(damage / -3) - shields_penetration
	var/is_crawling = (body_position == LYING_DOWN)
	if(l_hand && !isclothing(l_hand))
		var/final_block_chance = is_crawling ? 0 : l_hand.block_chance - (clamp((armour_penetration-l_hand.armour_penetration)/2,0,100)) + block_chance_modifier //So armour piercing blades can still be parried by other blades, for example
		if(l_hand.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return TRUE
	if(r_hand && !isclothing(r_hand))
		var/final_block_chance = is_crawling ? 0 : r_hand.block_chance - (clamp((armour_penetration-r_hand.armour_penetration)/2,0,100)) + block_chance_modifier //Need to reset the var so it doesn't carry over modifications between attempts
		if(r_hand.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return TRUE
	if(wear_suit)
		var/final_block_chance = wear_suit.block_chance - (clamp((armour_penetration-wear_suit.armour_penetration)/2,0,100)) + block_chance_modifier
		if(wear_suit.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return TRUE
	if(neck)
		var/final_block_chance = neck.block_chance - (clamp((armour_penetration-neck.armour_penetration)/2,0,100)) + block_chance_modifier
		if(neck.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return TRUE
	if(w_uniform)
		var/final_block_chance = w_uniform.block_chance - (clamp((armour_penetration-w_uniform.armour_penetration)/2,0,100)) + block_chance_modifier
		if(w_uniform.hit_reaction(src, AM, attack_text, final_block_chance, damage, attack_type))
			return TRUE
	if(SEND_SIGNAL(src, COMSIG_HUMAN_CHECK_SHIELDS, AM, attack_text, 0, damage, attack_type) & SHIELD_BLOCK)
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/check_martial_art_defense(mob/living/carbon/human/defender, mob/living/carbon/human/attacker, obj/item/I, visible_message, self_message)
	if(mind && mind.martial_art)
		return mind.martial_art.attack_reaction(defender, attacker, I, visible_message, self_message)

/mob/living/carbon/human/acid_act(acidpwr, acid_volume, bodyzone_hit) //todo: update this to utilize check_obscured_slots() //and make sure it's check_obscured_slots(TRUE) to stop aciding through visors etc
	var/list/damaged = list()
	var/list/inventory_items_to_kill = list()
	var/acidity = acidpwr * min(acid_volume * 0.005, 0.1)
	//HEAD//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_HEAD) //only if we didn't specify a zone or if that zone is the head.
		var/obj/item/clothing/head_clothes = null
		if(glasses)
			head_clothes = glasses
		if(wear_mask)
			head_clothes = wear_mask
		if(head)
			head_clothes = head
		if(head_clothes)
			if(!(head_clothes.resistance_flags & UNACIDABLE))
				head_clothes.acid_act(acidpwr, acid_volume)
				update_inv_glasses()
				update_inv_wear_mask()
				update_inv_head()
			else
				to_chat(src, "<span class='notice'>Your [head_clothes.name] protects your head and face from the acid!</span>")
		else
			. = get_organ(BODY_ZONE_HEAD)
			if(.)
				damaged += .
			if(l_ear)
				inventory_items_to_kill += l_ear
			if(r_ear)
				inventory_items_to_kill += r_ear

	//CHEST//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_CHEST)
		var/obj/item/clothing/chest_clothes = null
		if(w_uniform)
			chest_clothes = w_uniform
		if(wear_suit)
			chest_clothes = wear_suit
		if(chest_clothes)
			if(!(chest_clothes.resistance_flags & UNACIDABLE))
				chest_clothes.acid_act(acidpwr, acid_volume)
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, "<span class='notice'>Your [chest_clothes.name] protects your body from the acid!</span>")
		else
			. = get_organ(BODY_ZONE_CHEST)
			if(.)
				damaged += .
			if(wear_id)
				inventory_items_to_kill += wear_id
			if(wear_pda)
				inventory_items_to_kill += wear_pda
			if(r_store)
				inventory_items_to_kill += r_store
			if(l_store)
				inventory_items_to_kill += l_store
			if(s_store)
				inventory_items_to_kill += s_store


	//ARMS & HANDS//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_L_ARM || bodyzone_hit == BODY_ZONE_R_ARM)
		var/obj/item/clothing/arm_clothes = null
		if(gloves)
			arm_clothes = gloves
		if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
			arm_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
			arm_clothes = wear_suit

		if(arm_clothes)
			if(!(arm_clothes.resistance_flags & UNACIDABLE))
				arm_clothes.acid_act(acidpwr, acid_volume)
				update_inv_gloves()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, "<span class='notice'>Your [arm_clothes.name] protects your arms and hands from the acid!</span>")
		else
			. = get_organ(BODY_ZONE_R_ARM)
			if(.)
				damaged += .
			. = get_organ(BODY_ZONE_L_ARM)
			if(.)
				damaged += .


	//LEGS & FEET//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_L_LEG || bodyzone_hit == BODY_ZONE_R_LEG || bodyzone_hit == "feet")
		var/obj/item/clothing/leg_clothes = null
		if(shoes)
			leg_clothes = shoes
		if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (w_uniform.body_parts_covered & LEGS))))
			leg_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (wear_suit.body_parts_covered & LEGS))))
			leg_clothes = wear_suit
		if(leg_clothes)
			if(!(leg_clothes.resistance_flags & UNACIDABLE))
				leg_clothes.acid_act(acidpwr, acid_volume)
				update_inv_shoes()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, "<span class='notice'>Your [leg_clothes.name] protects your legs and feet from the acid!</span>")
		else
			. = get_organ(BODY_ZONE_R_LEG)
			if(.)
				damaged += .
			. = get_organ(BODY_ZONE_L_LEG)
			if(.)
				damaged += .

	//DAMAGE//
	var/should_update_health = FALSE
	var/update_damage_icon = NONE
	for(var/obj/item/organ/external/affecting as anything in damaged)
		var/brute_was = affecting.brute_dam
		var/burn_was = affecting.burn_dam
		update_damage_icon |= affecting.external_receive_damage(acidity, 2 * acidity, updating_health = FALSE)
		if(QDELETED(affecting) || affecting.loc != src)
			should_update_health = TRUE
			continue
		if(affecting.brute_dam != brute_was || affecting.burn_dam != burn_was)
			should_update_health = TRUE
		if(!istype(affecting, /obj/item/organ/external/head) || !prob(min(acidpwr * acid_volume / 10, 90)))	//Applies disfigurement
			continue
		var/obj/item/organ/external/head/head_organ = affecting
		if(has_pain())
			emote("scream")
		head_organ.h_style = "Bald"
		head_organ.f_style = "Shaved"
		update_hair()
		update_fhair()
		head_organ.disfigure()

	if(should_update_health)
		updatehealth("acid act")

	if(update_damage_icon)
		UpdateDamageIcon()

	//MELTING INVENTORY ITEMS//
	//these items are all outside of armour visually, so melt regardless.
	if(!bodyzone_hit)
		if(back)
			inventory_items_to_kill += back
		if(belt)
			inventory_items_to_kill += belt
		if(l_hand)
			inventory_items_to_kill += l_hand
		if(r_hand)
			inventory_items_to_kill += r_hand

	for(var/obj/item/I in inventory_items_to_kill)
		I.acid_act(acidpwr, acid_volume)
	return 1

/mob/living/carbon/human/emag_act(mob/user, obj/item/organ/external/affecting)
	if(!istype(affecting))
		return
	if(!affecting.is_robotic())
		to_chat(user, "<span class='warning'>That limb isn't robotic.</span>")
		return
	if(affecting.sabotaged)
		to_chat(user, "<span class='warning'>[src]'s [affecting.name] is already sabotaged!</span>")
	else
		add_attack_logs(user, src, "emagged [p_their()] [affecting.name]")
		to_chat(user, "<span class='warning'>You sneakily slide the card into the dataport on [src]'s [affecting.name] and short out the safeties.</span>")
		affecting.sabotaged = 1
	return 1


/mob/living/carbon/human/grippedby(mob/living/grabber, grab_state_override)
	. = ..()
	if(.)
		w_uniform?.add_fingerprint(grabber)


/mob/living/carbon/human/proceed_attack_results(obj/item/I, mob/living/user, params, def_zone)
	if(QDELETED(src) || QDELETED(I) || QDELETED(user))	// tripple insurance, jesus fucking christ
		return ATTACK_CHAIN_BLOCKED_ALL

	if((istype(I, /obj/item/kitchen/knife/butcher/meatcleaver) || istype(I, /obj/item/twohanded/chainsaw)) && stat == DEAD && user.a_intent == INTENT_HARM)
		var/turf/source_turf = get_turf(src)
		new dna.species.meat_type(source_turf, src)
		I.add_mob_blood(src)
		add_splatter_floor(source_turf)
		if(get_dist(user, source_turf) <= 1) //people with TK won't get smeared with blood
			user.add_mob_blood(src)
		user.visible_message(
			span_danger("[user] has hacked off a chunk of meat from [src]!"),
			span_warning("You have hacked off a chunk of meat from [src]!"),
		)
		meatleft--
		if(meatleft <= 0)
			add_attack_logs(user, src, "Chopped up into meat")
			qdel(src)
			return ATTACK_CHAIN_BLOCKED_ALL
		add_mob_blood(src)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	var/attack_zone = ran_zone(def_zone)
	var/obj/item/organ/external/affecting = get_organ(attack_zone)
	// if the targeted limb doesn't exist, pick its parent or torso
	if(!affecting)
		var/list/species_bodyparts = dna.species.has_limbs[attack_zone]
		if(species_bodyparts)
			var/obj/item/organ/external/affecting_path = species_bodyparts["path"]
			affecting = get_organ(initial(affecting_path.parent_organ_zone)) || get_organ(BODY_ZONE_CHEST)
		else	// has no targeted species bodypart (wings/tail)
			affecting = get_organ(BODY_ZONE_CHEST)
		if(!affecting)
			stack_trace("Human somehow has no chest bodypart.")
			return ATTACK_CHAIN_BLOCKED_ALL

	if(user != src && check_shields(I, I.force, "the [I.name]", MELEE_ATTACK, I.armour_penetration))
		return ATTACK_CHAIN_BLOCKED

	if(check_martial_art_defense(src, user, I, span_warning("[src] blocks [I]!")))
		return ATTACK_CHAIN_BLOCKED

	if(istype(I, /obj/item/card/emag) && emag_act(user, affecting))
		return ATTACK_CHAIN_BLOCKED_ALL

	send_item_attack_message(I, user, affecting.limb_zone)

	. = ATTACK_CHAIN_PROCEED_SUCCESS	// from now on we consider that attack was succesful
	if(!I.force)
		return .

	var/hit_area = affecting.limb_zone
	var/hit_area_name = parse_zone(hit_area)

	var/armor = run_armor_check(affecting, MELEE, span_warning("Your armour has protected your [hit_area_name]."), span_warning("Your armour has softened hit to your [hit_area_name]."), armour_penetration = I.armour_penetration)
	if(armor >= 100)
		return .

	var/weapon_sharp = is_sharp(I)
	if(weapon_sharp && prob(getarmor(user.zone_selected, MELEE)))
		weapon_sharp = FALSE

	var/cached_force = I.force * check_weakness(I, user)
	// this can destroy some species (damn nucleo-bombers), so from now on we cannot count on its existance
	var/apply_damage_result = apply_damage(cached_force, I.damtype, affecting, armor, weapon_sharp, I)
	var/IM_ALIVE = !QDELETED(src)

	var/list/all_objectives = user.mind?.get_all_objectives()
	if(all_objectives)
		for(var/datum/objective/pain_hunter/objective in all_objectives)
			if(mind == objective.target)
				objective.take_damage(cached_force, I.damtype)

	if(!IM_ALIVE)
		return .

	var/bloody = FALSE
	if(apply_damage_result && I.damtype == BRUTE && prob(25 + cached_force * 2))
		I.add_mob_blood(src)	//Make the weapon bloody, not the person.
		if(prob(cached_force * 2)) //blood spatter!
			bloody = TRUE
			add_splatter_floor()
			if(get_dist(user, src) <= 1) //people with TK won't get smeared with blood
				user.add_mob_blood(src)

	switch(hit_area)
		if(BODY_ZONE_HEAD)//Harder to score a stun but if you do it lasts a bit longer
			if(apply_damage_result && stat == CONSCIOUS && armor < 50)
				if(prob(cached_force))
					visible_message(
						span_combatdanger("[src] has been knocked down!"),
						span_combatuserdanger("[src] has been knocked down!"),
					)
					apply_effect(4 SECONDS, KNOCKDOWN, armor)
					AdjustConfused(30 SECONDS)
				if(mind?.special_role == SPECIAL_ROLE_REV && prob(cached_force + ((100 - health)/2)) && src != user && I.damtype == BRUTE)
					SSticker.mode.remove_revolutionary(mind)

			if(bloody)//Apply blood
				if(wear_mask)
					wear_mask.add_mob_blood(src)
					update_inv_wear_mask()
				if(head)
					head.add_mob_blood(src)
					update_inv_head()
				if(glasses && prob(33))
					glasses.add_mob_blood(src)
					update_inv_glasses()

		if(BODY_ZONE_CHEST)//Easier to score a stun but lasts less time
			if(apply_damage_result && stat == CONSCIOUS && prob(cached_force + 10))
				visible_message(
					span_combatdanger("[src] has been knocked down!"),
					span_combatuserdanger("[src] has been knocked down!"),
				)
				apply_effect(2 SECONDS, KNOCKDOWN, armor)

			if(bloody)
				if(wear_suit)
					wear_suit.add_mob_blood(src)
					update_inv_wear_suit()
				if(w_uniform)
					w_uniform.add_mob_blood(src)
					update_inv_w_uniform()

	if(apply_damage_result && (cached_force > 10 || (cached_force >= 5 && prob(33))))
		forcesay(GLOB.hit_appends)	//forcesay checks stat already

	. |= dna.species.spec_proceed_attack_results(I, src, user, affecting)


/mob/living/carbon/human/send_item_attack_message(obj/item/I, mob/living/user, def_zone)
	if(I.item_flags & SKIP_ATTACK_MESSAGE)
		return

	var/message_hit_area = ""	// only humans have def zones, so we need an override
	if(def_zone)
		message_hit_area = " in the [parse_zone(def_zone)]"

	if(!I.force)
		visible_message(
			span_warning("[user] gently taps [src][message_hit_area] with [I]."),
			span_warning("[user] gently taps you[message_hit_area] with [I]."),
			ignored_mobs = user,
		)
		to_chat(user, span_warning("You gently tap [src][message_hit_area] with [I]."))
		return

	var/message_verb = "attacked"
	if(length(I.attack_verb))
		message_verb = "[pick(I.attack_verb)]"

	visible_message(
		span_danger("[user] has [message_verb] [src][message_hit_area] with [I]!"),
		span_userdanger("[user] has [message_verb] you[message_hit_area] with [I]!"),
		ignored_mobs = user,
	)
	to_chat(user, span_danger("You have [message_verb] [src][message_hit_area] with [I]!"))


/**
 * This proc handles being hit by a thrown atom.
 */
/mob/living/carbon/human/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	var/spec_return = dna.species.spec_hitby(AM, src)
	if(spec_return)
		return spec_return

	var/MA_return = mind?.martial_art?.user_hit_by(AM, src)
	if(MA_return)
		return MA_return

	var/obj/item/I
	var/throwpower = 30
	var/armour_penetration = 0
	var/shields_penetration = 0
	if(isitem(AM))
		I = AM
		throwpower = I.throwforce
		armour_penetration = I.armour_penetration
		shields_penetration = I.shields_penetration
		if(locateUID(I.thrownby) == src) //No throwing stuff at yourself to trigger reactions
			return ..()

	SEND_SIGNAL(src, COMSIG_CARBON_HITBY)

	if(check_shields(AM, throwpower, "\the [AM.name]", THROWN_PROJECTILE_ATTACK, armour_penetration, shields_penetration))
		hitpush = FALSE
		skipcatch = TRUE
		blocked = TRUE

	else if(I && (((throwingdatum ? throwingdatum.speed : I.throw_speed) >= EMBED_THROWSPEED_THRESHOLD) || I.embedded_ignore_throwspeed_threshold) && can_embed(I) && !HAS_TRAIT(src, TRAIT_EMBEDIMMUNE) && prob(I.embed_chance))
		embed_item_inside(I)
		hitpush = FALSE
		skipcatch = TRUE //can't catch the now embedded item

	return ..(AM, skipcatch, hitpush, blocked, throwingdatum)


/mob/living/carbon/human/proc/bloody_hands(var/mob/living/source, var/amount = 2)

	if(gloves)
		gloves.add_mob_blood(source)
		gloves:transfer_blood = amount
	else
		add_mob_blood(source)
		bloody_hands = amount
	update_inv_gloves()		//updates on-mob overlays for bloody hands and/or bloody gloves

/mob/living/carbon/human/proc/bloody_body(var/mob/living/source)
	if(wear_suit)
		wear_suit.add_mob_blood(source)
		update_inv_wear_suit()
		return
	if(w_uniform)
		w_uniform.add_mob_blood(source)
		update_inv_w_uniform()

/mob/living/carbon/human/attack_hand(mob/user)
	if(..())	//to allow surgery to return properly.
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		dna.species.spec_attack_hand(H, src)

/mob/living/carbon/human/attack_larva(mob/living/carbon/alien/larva/L)
	if(..()) //successful larva bite.
		if(stat != DEAD)
			L.evolution_points = min(L.evolution_points + L.attack_damage, L.max_evolution_points)
			var/obj/item/organ/external/affecting = get_organ(ran_zone(L.zone_selected))
			var/armor_block = run_armor_check(affecting, MELEE)
			apply_damage(L.attack_damage, BRUTE, affecting, armor_block)


/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(check_shields(M, 0, M.name))
		visible_message("<span class='danger'>[M] attempted to touch [src]!</span>")
		return 0

	if(..())
		if(M.a_intent == INTENT_HARM)
			if(w_uniform)
				w_uniform.add_fingerprint(M)
			var/damage = prob(90) ? M.attack_damage : 0
			if(!damage)
				playsound(loc, 'sound/weapons/slashmiss.ogg', 50, TRUE, -1)
				visible_message("<span class='danger'>[M] has lunged at [src]!</span>")
				return 0
			var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_selected))
			var/armor_block = run_armor_check(affecting, "melee", armour_penetration = M.armour_penetration)

			playsound(loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>", \
 				"<span class='userdanger'>[M] has slashed at [src]!</span>")

			apply_damage(damage, BRUTE, affecting, armor_block, TRUE)
			add_attack_logs(M, src, "Alien attacked")
			var/all_objectives = M?.mind?.get_all_objectives()
			if(mind && all_objectives)
				for(var/datum/objective/pain_hunter/objective in all_objectives)
					if(mind == objective.target)
						armor_block = (100 - armor_block) / 100
						if(armor_block <= 0)
							armor_block= 0
						objective.take_damage(damage * armor_block, BRUTE)

		if(M.a_intent == INTENT_DISARM) //Always drop item in hand, if no item, get stun instead.
			var/obj/item/I = get_active_hand()
			if(I && drop_item_ground(I))
				playsound(loc, 'sound/weapons/slash.ogg', 25, TRUE, -1)
				visible_message("<span class='danger'>[M] disarms [src]!</span>", "<span class='userdanger'>[M] disarms you!</span>", "<span class='hear'>You hear aggressive shuffling!</span>")
				to_chat(M, "<span class='danger'>You disarm [src]!</span>")
			else
				var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_selected))
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
				apply_damage(M.disarm_stamina_damage, STAMINA)
				if(prob(40))
					apply_effect(2 SECONDS, WEAKEN, run_armor_check(affecting, "melee"))
					add_attack_logs(M, src, "Alien tackled")
					visible_message("<span class='danger'>[M] has tackled down [src]!</span>")
				else
					visible_message("<span class='danger'>[M] tried to tackle down [src]!</span>")
					add_attack_logs(M, src, "Alien tried to tackle")

/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		if(check_shields(M, damage, "the [M.name]", MELEE_ATTACK, M.armour_penetration))
			return FALSE
		var/dam_zone = pick(
			BODY_ZONE_CHEST,
			BODY_ZONE_PRECISE_GROIN,
			BODY_ZONE_HEAD,
			BODY_ZONE_L_ARM,
			BODY_ZONE_R_ARM,
			BODY_ZONE_L_LEG,
			BODY_ZONE_R_LEG,
			BODY_ZONE_PRECISE_L_HAND,
			BODY_ZONE_PRECISE_R_HAND,
			BODY_ZONE_PRECISE_L_FOOT,
			BODY_ZONE_PRECISE_R_FOOT,
		)
		var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_organ(BODY_ZONE_CHEST)
		affecting.add_autopsy_data(M.name, damage) // Add the mob's name to the autopsy data
		var/armor = run_armor_check(affecting, MELEE, armour_penetration = M.armour_penetration)
		apply_damage(damage, M.melee_damage_type, affecting, armor)
		var/all_objectives = M?.mind?.get_all_objectives()
		if(mind && all_objectives)
			for(var/datum/objective/pain_hunter/objective in all_objectives)
				if(mind == objective.target)
					armor = (100 - armor) / 100
					if(armor <= 0)
						armor = 0
					objective.take_damage(damage * armor, BRUTE)

/mob/living/carbon/human/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = rand(5, 25)
		if(M.age_state.age != SLIME_BABY)
			damage = rand(10 + M.age_state.damage, 35 + M.age_state.damage)

		if(check_shields(M, damage, "the [M.name]"))
			return FALSE

		var/dam_zone = pick(
			BODY_ZONE_CHEST,
			BODY_ZONE_PRECISE_GROIN,
			BODY_ZONE_HEAD,
			BODY_ZONE_L_ARM,
			BODY_ZONE_R_ARM,
			BODY_ZONE_L_LEG,
			BODY_ZONE_R_LEG,
			BODY_ZONE_PRECISE_L_HAND,
			BODY_ZONE_PRECISE_R_HAND,
			BODY_ZONE_PRECISE_L_FOOT,
			BODY_ZONE_PRECISE_R_FOOT,
		)

		var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_organ(BODY_ZONE_CHEST)
		var/armor_block = run_armor_check(affecting, MELEE)
		apply_damage(damage, BRUTE, affecting, armor_block)
		var/all_objectives = M?.mind?.get_all_objectives()
		if(mind && all_objectives)
			for(var/datum/objective/pain_hunter/objective in all_objectives)
				if(mind == objective.target)
					armor_block = (100 - armor_block) / 100
					if(armor_block <= 0)
						armor_block = 0
					objective.take_damage(damage * armor_block, BRUTE)

/mob/living/carbon/human/mech_melee_attack(obj/mecha/M)
	if(M.occupant.a_intent == INTENT_HARM)
		if(HAS_TRAIT(M.occupant, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
			to_chat(M.occupant, "<span class='warning'>You don't want to harm other living beings!</span>")
			return
		M.do_attack_animation(src)
		if(M.damtype == "brute")
			step_away(src,M,15)
		var/obj/item/organ/external/affecting = get_organ(pick(BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_HEAD))
		if(affecting)
			var/dmg = rand(M.force/2, M.force)
			switch(M.damtype)
				if(BRUTE)
					if(M.force > 35) // durand and other heavy mechas
						Paralyse(2 SECONDS)
					else if(M.force > 20 && !IsWeakened()) // lightweight mechas like gygax
						Weaken(4 SECONDS)
					apply_damage(dmg, BRUTE, def_zone = affecting)
					playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
				if(BURN)
					apply_damage(dmg, BURN, def_zone = affecting)
					playsound(src, 'sound/items/welder.ogg', 50, TRUE)
				if(TOX)
					M.mech_toxin_damage(src)
				else
					return

		M.occupant_message("<span class='danger'>You hit [src].</span>")
		visible_message("<span class='danger'>[M.name] hits [src]!</span>", "<span class='userdanger'>[M.name] hits you!</span>")

		add_attack_logs(M.occupant, src, "Mecha-meleed with [M]")
	else
		..()


/mob/living/carbon/human/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	dna.species.water_act(src, volume, temperature, source, method)

/mob/living/carbon/human/is_eyes_covered(check_glasses = TRUE, check_head = TRUE, check_mask = TRUE)
	if(check_glasses && glasses && (glasses.flags_cover & GLASSESCOVERSEYES))
		return TRUE
	if(check_head && head && (head.flags_cover & HEADCOVERSEYES))
		return TRUE
	if(check_mask && wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH))
		return TRUE

/mob/living/carbon/human/proc/reagent_safety_check(hot = TRUE)
	if(wear_mask)
		to_chat(src, "<span class='danger'>Your [wear_mask.name] protects you from the [hot ? "hot" : "cold"] liquid!</span>")
		return FALSE
	if(head)
		to_chat(src, "<span class='danger'>Your [head.name] protects you from the [hot ? "hot" : "cold"] liquid!</span>")
		return FALSE
	return TRUE
