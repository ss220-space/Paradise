/mob/living/Initialize()
	. = ..()
	AddElement(/datum/element/movetype_handler)
	register_init_signals()
	var/datum/atom_hud/data/human/medical/advanced/medhud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medhud.add_to_hud(src)
	faction += "\ref[src]"
	determine_move_and_pull_forces()
	gravity_setup()
	if(ventcrawler_trait)
		var/static/list/ventcrawler_sanity = list(
			TRAIT_VENTCRAWLER_ALWAYS,
			TRAIT_VENTCRAWLER_NUDE,
			TRAIT_VENTCRAWLER_ALIEN,
		)
		if(ventcrawler_trait in ventcrawler_sanity)
			ADD_TRAIT(src, ventcrawler_trait, INNATE_TRAIT)
		else
			stack_trace("Mob [type] has improper ventcrawler_trait value.")

	if(mobility_flags & MOBILITY_REST)
		add_verb(src, /mob/living/proc/toggle_resting)
		if(!density)	// we want undense mobs to stay undense when they stop resting
			ADD_TRAIT(src, TRAIT_UNDENSE, INNATE_TRAIT)

	if(length(weather_immunities))
		add_traits(weather_immunities, INNATE_TRAIT)

	GLOB.mob_living_list += src


/mob/living/Destroy()
	for(var/s in ownedSoullinks)
		var/datum/soullink/S = s
		S.ownerDies(FALSE)
		qdel(s) //If the owner is destroy()'d, the soullink is destroy()'d
	ownedSoullinks = null
	for(var/s in sharedSoullinks)
		var/datum/soullink/S = s
		S.sharerDies(FALSE)
		S.removeSoulsharer(src) //If a sharer is destroy()'d, they are simply removed
	sharedSoullinks = null
	if(ranged_ability)
		ranged_ability.remove_ranged_ability(src)
	remove_from_all_data_huds()
	now_pushing = null
	if(LAZYLEN(status_effects))
		for(var/s in status_effects)
			var/datum/status_effect/S = s
			if(S.on_remove_on_mob_delete) //the status effect calls on_remove when its mob is deleted
				qdel(S)
			else
				S.be_replaced()
	GLOB.mob_living_list -= src
	return ..()

// Used to determine the forces dependend on the mob size
// Will only change the force if the force was not set in the mob type itself
/mob/living/proc/determine_move_and_pull_forces()
	var/value
	switch(mob_size)
		if(MOB_SIZE_TINY)
			value = MOVE_FORCE_EXTREMELY_WEAK
		if(MOB_SIZE_SMALL)
			value = MOVE_FORCE_WEAK
		if(MOB_SIZE_HUMAN)
			value = MOVE_FORCE_NORMAL
		if(MOB_SIZE_LARGE)
			value = MOVE_FORCE_NORMAL // For now
	if(!move_force)
		move_force = value
	if(!pull_force)
		pull_force = value
	if(!move_resist)
		move_resist = value

/mob/living/prepare_huds()
	..()
	prepare_data_huds()

/mob/living/proc/prepare_data_huds()
	med_hud_set_health()
	med_hud_set_status()


/mob/living/ghostize(can_reenter_corpse = 1)
	var/prev_client = client
	. = ..()
	if(.)
		if(ranged_ability && prev_client)
			ranged_ability.remove_mousepointer(prev_client)
	SEND_SIGNAL(src, COMSIG_LIVING_GHOSTIZED)

/mob/living/proc/OpenCraftingMenu()
	return


/mob/living/IsLying()
	return body_position == LYING_DOWN


/mob/living/canface()
	if(!(mobility_flags & MOBILITY_MOVE))
		return FALSE
	return ..()


/mob/living/onZImpact(turf/impacted_turf, levels, impact_flags = NONE)
	if(!isopenspaceturf(impacted_turf))
		impact_flags |= ZImpactDamage(impacted_turf, levels)

	return ..()

/mob/living/proc/ZImpactDamage(turf/impacted_turf, levels)
	. = SEND_SIGNAL(src, COMSIG_LIVING_Z_IMPACT, levels, impacted_turf)
	if(. & ZIMPACT_CANCEL_DAMAGE)
		return .

	// If you are incapped, you probably can't brace yourself
	var/can_help_themselves = !incapacitated(INC_IGNORE_RESTRAINED)
	if(levels <= 1 && can_help_themselves)
		var/obj/item/organ/external/wing/bodypart_wing = get_organ(BODY_ZONE_WING)
		if(bodypart_wing && !bodypart_wing.has_fracture()) // wings can soften
			visible_message(
				span_notice("[src] makes a hard landing on [impacted_turf] but remains unharmed from the fall."),
				span_notice("You brace for the fall. You make a hard landing on [impacted_turf], but remain unharmed."),
			)
			AdjustWeakened((levels * 4 SECONDS))
			return . | ZIMPACT_NO_MESSAGE
	var/incoming_damage = (levels * 5) ** 1.5
	var/cat = iscat(src)
	var/functional_legs = TRUE
	var/skip_weaken = FALSE
	if(ishuman(src))
		for(var/zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT))
			var/obj/item/organ/external/leg = get_organ(zone)
			if(leg.has_fracture())
				functional_legs = FALSE
				break
	if(((istajaran(src) && functional_legs) || cat) && body_position != LYING_DOWN && can_help_themselves)
		. |= ZIMPACT_NO_MESSAGE|ZIMPACT_NO_SPIN
		skip_weaken = TRUE
		if(cat || HAS_TRAIT(src, TRAIT_DWARF)) // lil' bounce kittens
			visible_message(
				span_notice("[src] makes a hard landing on [impacted_turf], but lands safely on [p_their()] feet!"),
				span_notice("You make a hard landing on [impacted_turf], but land safely on your feet!"),
			)
			return .
		incoming_damage *= 1.2 // at least no stuns
		visible_message(
			span_danger("[src] makes a hard landing on [impacted_turf], landing on [p_their()] feet painfully!"),
			span_userdanger("You make a hard landing on [impacted_turf], and instinctively land on your feet - still painfully!"),
		)

	if(body_position != LYING_DOWN)
		var/damage_for_each_leg = round(incoming_damage / 4)
		apply_damage(damage_for_each_leg, BRUTE, BODY_ZONE_L_LEG)
		apply_damage(damage_for_each_leg, BRUTE, BODY_ZONE_R_LEG)
		apply_damage(damage_for_each_leg, BRUTE, BODY_ZONE_PRECISE_L_FOOT)
		apply_damage(damage_for_each_leg, BRUTE, BODY_ZONE_PRECISE_R_FOOT)

	else
		apply_damage(incoming_damage, BRUTE)

	if(!skip_weaken)
		AdjustWeakened(levels * 5 SECONDS)
	return .


// Generic Bump(). Override MobBump() and ObjBump() instead of this.
/mob/living/Bump(atom/bumped_atom)
	. = ..()
	if(.) // we were thrown onto something
		return .
	if(buckled || now_pushing)
		return .
	if(isliving(bumped_atom))
		if(MobBump(bumped_atom))
			return .
	else if(isobj(bumped_atom))
		if(ObjBump(bumped_atom))
			return .
	if(ismovable(bumped_atom))
		if(PushAM(bumped_atom, move_force))
			return .


//Called when we bump into a mob
/mob/living/proc/MobBump(mob/living/bumped_mob)
	// even if we don't push/swap places, we "touched" them, so spread fire
	spreadFire(bumped_mob)

	if(get_confusion() && get_disoriented())
		Weaken(1 SECONDS)
		take_organ_damage(rand(5, 10))
		bumped_mob.Weaken(1 SECONDS)
		bumped_mob.take_organ_damage(rand(5, 10))
		visible_message(
			span_danger("[name] вреза[pluralize_ru(gender,"ет","ют")]ся в [bumped_mob.name], сбивая друг друга с ног!"),
			span_userdanger("Вы жестко врезаетесь в [bumped_mob.name]!"),
		)
		playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
		return TRUE

	// no pushing if we're already pushing past something
	if(now_pushing)
		return TRUE

	// spread diseases
	for(var/datum/disease/virus/virus in diseases)
		if(virus.spread_flags & CONTACT)
			virus.Contract(bumped_mob, act_type = CONTACT, need_protection_check = TRUE)

	for(var/datum/disease/virus/virus in bumped_mob.diseases)
		if(virus.spread_flags & CONTACT)
			virus.Contract(src, act_type = CONTACT, need_protection_check = TRUE)

	if(bumped_mob.pulledby && bumped_mob.pulledby != src && HAS_TRAIT(bumped_mob, TRAIT_RESTRAINED))
		if(!(world.time % 5))
			to_chat(src, span_warning("[bumped_mob] is restrained, you cannot push past!"))
		return TRUE

	if(isliving(bumped_mob.pulling) && HAS_TRAIT(bumped_mob.pulling, TRAIT_RESTRAINED))
		if(!(world.time % 5))
			to_chat(src, span_warning("[bumped_mob] is restrained, you cannot push past!"))
		return TRUE

	if(moving_diagonally) //no mob swap during diagonal moves.
		return TRUE

	// if bumped mob is anchored or we are pulling dense object, lets just skip to pushing
	if(bumped_mob.anchored || (isobj(pulling) && pulling.density))
		return FALSE

	// if bumped mob pulling dense object we will check their pull dir
	// no swaps no pushes if object is one tile away in front of our direction
	if(isobj(bumped_mob.pulling) && bumped_mob.pulling.density && (dir & get_dir(bumped_mob, bumped_mob.pulling)))
		return TRUE

	if(!bumped_mob.buckled && !bumped_mob.has_buckled_mobs())
		var/mob_swap = FALSE
		// can't swap with immovable objects unless they help us
		var/too_strong = (move_force < bumped_mob.move_resist)
		// the puller can always swap with their pullee
		if(bumped_mob.pulledby == src && !too_strong)
			mob_swap = TRUE
		// can't swap or push mobs in neck grab
		else if( \
			(bumped_mob.pulling && bumped_mob.grab_state >= GRAB_NECK) || \
			(bumped_mob.pulledby && bumped_mob.pulledby.grab_state >= GRAB_NECK))
			return TRUE
		// restrained people act if they were on 'help' intent to prevent a person being pulled from being separated from their puller
		else if( \
			((HAS_TRAIT(bumped_mob, TRAIT_RESTRAINED) && !too_strong) || bumped_mob.a_intent == INTENT_HELP) && \
			(HAS_TRAIT(src, TRAIT_RESTRAINED) || a_intent == INTENT_HELP))
			mob_swap = TRUE

		if(mob_swap)
			//switch our position with bumped_mob
			if(loc && !loc.Adjacent(bumped_mob.loc))
				return TRUE

			now_pushing = bumped_mob
			var/oldloc = loc
			var/oldbumpedloc = bumped_mob.loc

			// we give PASSMOB to both mobs to avoid bumping other mobs during swap.
			var/bumped_mob_passmob = (bumped_mob.pass_flags & PASSMOB)
			var/src_passmob = (pass_flags & PASSMOB)
			bumped_mob.pass_flags |= PASSMOB
			pass_flags |= PASSMOB

			var/move_failed = FALSE
			// its important that we move first in case of pulled dense objects
			if(!Move(oldbumpedloc) || !bumped_mob.Move(oldloc))
				bumped_mob.forceMove(oldbumpedloc)
				forceMove(oldloc)
				move_failed = TRUE
			if(!src_passmob)
				pass_flags &= ~PASSMOB
			if(!bumped_mob_passmob)
				bumped_mob.pass_flags &= ~PASSMOB

			now_pushing = null

			if(!move_failed)
				return TRUE

	// okay, so we didn't switch. but should we push?
	// not if he's not CANPUSH of course
	if(!(bumped_mob.status_flags & CANPUSH) || HAS_TRAIT(bumped_mob, TRAIT_PUSHIMMUNE))
		return TRUE
	//anti-riot equipment is also anti-push
	if(bumped_mob.r_hand && !isclothing(bumped_mob.r_hand) && prob(bumped_mob.r_hand.block_chance * 2))
		return TRUE
	if(bumped_mob.l_hand && !isclothing(bumped_mob.l_hand) && prob(bumped_mob.l_hand.block_chance * 2))
		return TRUE


//Called when we bump into an obj
/mob/living/proc/ObjBump(obj/object)
	if(get_confusion() && get_disoriented())
		Weaken(1 SECONDS)
		take_organ_damage(rand(5, 10))
		visible_message(
			span_danger("[name] вреза[pluralize_ru(gender,"ет","ют")]ся в [object.name]!"),
			span_userdanger("Вы жестко врезаетесь в [object.name]!"),
		)
		playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)


/// Called when we want to push an atom/movable
/mob/living/proc/PushAM(atom/movable/AM, force = move_force)
	if(now_pushing)
		return
	if(moving_diagonally) // no pushing during diagonal moves
		return
	if(!client && (mob_size < MOB_SIZE_SMALL))
		return
	if(SEND_SIGNAL(AM, COMSIG_MOVABLE_BUMP_PUSHED, src, force) & COMPONENT_NO_PUSH)
		return
	now_pushing = AM
	SEND_SIGNAL(src, COMSIG_LIVING_PUSHING_MOVABLE, AM)
	var/dir_to_target = get_dir(src, AM)

	// If there's no dir_to_target then the player is on the same turf as the atom they're trying to push.
	// This can happen when a player is stood on the same turf as a directional window. All attempts to push the window
	// will fail as get_dir will return 0 and the player will be unable to move the window when it should be pushable.
	// In this scenario, we will use the facing direction of the /mob/living attempting to push the atom as a fallback.
	if(!dir_to_target)
		dir_to_target = dir

	var/push_anchored = FALSE
	if((AM.move_resist * MOVE_FORCE_CRUSH_RATIO) <= force)
		if(move_crush(AM, move_force, dir_to_target))
			push_anchored = TRUE

	// trigger move_crush and/or force_push regardless of if we can push it normally
	if((AM.move_resist * MOVE_FORCE_FORCEPUSH_RATIO) <= force)
		if(force_push(AM, move_force, dir_to_target, push_anchored))
			push_anchored = TRUE

	var/pushing_mob = isliving(AM)
	var/mob/living/mob_to_push = AM
	if(pushing_mob)
		// we cannot push mobs into dense objects behind them
		var/turf/turf_to_check = get_step(mob_to_push, dir)
		if(!turf_to_check || turf_to_check.density)
			now_pushing = null
			return
		var/border_dir = get_dir(turf_to_check, mob_to_push)
		for(var/atom/movable/thing as anything in turf_to_check)
			if(!thing.CanPass(mob_to_push, border_dir))
				now_pushing = null
				return
		var/atom/movable/mob_buckle = mob_to_push.buckled
		// If we can't pull them because of what they're buckled to, make sure we can push the thing they're buckled to instead.
		// If neither are true, we're not pushing anymore.
		if(mob_buckle && (mob_buckle.buckle_prevents_pull || (force < (mob_buckle.move_resist * MOVE_FORCE_PUSH_RATIO))))
			now_pushing = null
			return

	if((AM.anchored && !push_anchored) || (force < (AM.move_resist * MOVE_FORCE_PUSH_RATIO)))
		now_pushing = null
		return

	if(istype(AM, /obj/structure/window))
		var/obj/structure/window/window = AM
		if(window.fulltile)
			for(var/obj/structure/window/win in get_step(window, dir_to_target))
				now_pushing = null
				return

	if(pulling == AM)
		stop_pulling()

	var/current_dir
	if(pushing_mob)
		current_dir = AM.dir
	if(AM.Move(get_step(AM.loc, dir_to_target), dir_to_target))
		AM.add_fingerprint(src)
		Move(get_step(loc, dir_to_target), dir_to_target)
		if(pushing_mob && mob_to_push.buckled)
			mob_to_push.buckled.set_glide_size(glide_size)
		else
			AM.set_glide_size(glide_size)
	if(current_dir)
		if(pushing_mob && mob_to_push.buckled)
			mob_to_push.buckled.setDir(current_dir)
		else
			AM.setDir(current_dir)
	now_pushing = null


/mob/living/proc/can_track(mob/living/user)
	//basic fast checks go first. When overriding this proc, I recommend calling ..() at the end.
	var/turf/source_turf = get_turf(src)
	if(!source_turf)
		return FALSE

	if(!is_level_reachable(source_turf.z))
		return FALSE

	if(!isnull(user) && src == user)
		return FALSE

	if(invisibility || alpha == 0)//cloaked
		return FALSE

	if(HAS_TRAIT(src, TRAIT_AI_UNTRACKABLE))
		return FALSE

	// Now, are they viewable by a camera? (This is last because it's the most intensive check)
	if(!near_camera(src))
		return FALSE

	return TRUE


/mob/living/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	// all this repeated spaghetti code is used to properly register projectiles
	if(mover.pass_flags == PASSEVERYTHING)
		return TRUE
	if(mover.pass_flags & pass_flags_self)
		return TRUE
	if(mover.throwing && (pass_flags_self & LETPASSTHROW))
		return TRUE
	if(mover in buckled_mobs)
		return TRUE
	var/is_projectile = isprojectile(mover)
	if(!density || is_projectile)
		if(is_projectile)
			return projectile_allow_through(mover, border_dir)
		return TRUE
	if(mover.throwing)
		return body_position == LYING_DOWN || mover.throwing.thrower == src
	if(pulling && pulling == mover && grab_state >= GRAB_NECK)	// pulled mob can step through us
		return TRUE
	if(buckled == mover)
		return TRUE
	return !mover.density || body_position == LYING_DOWN


/// Special projectiles handling for living mobs
/mob/living/proc/projectile_allow_through(obj/item/projectile/projectile, border_dir)
	// default behavior for generic mobs
	if(!(mobility_flags & (MOBILITY_REST|MOBILITY_LIEDOWN)))
		return !density
	// DEAD mobs are fine to skip if they are not dense or lying
	if(stat == DEAD)
		return !density || body_position == LYING_DOWN
	// always hitting dense/standing mobs
	if(density || body_position == STANDING_UP)
		return FALSE
	// otherwise chance to hit is defined by the projectile var/hit_crawling_mobs_chance
	if(projectile.hit_crawling_mobs_chance > 0 && projectile.hit_crawling_mobs_chance <= 100)
		return !prob(projectile.hit_crawling_mobs_chance)
	return TRUE


/mob/living/tompost_bump_override(atom/movable/mover, border_dir)
	if(pulling && pulling.loc == loc && pulling.density && !pulling.CanPass(mover, border_dir))
		var/check_dir = dir
		if(check_dir & border_dir)	// mover approaches from the front
			return pulling
		if(REVERSE_DIR(check_dir) & border_dir)	// mover approaches from behind
			return src
		return prob(50) ? pulling : src	// fifty fifty for the sides
	if(pulledby && pulledby.loc == loc && pulledby.density && !pulledby.CanPass(mover, border_dir))
		var/check_dir = pulledby.dir
		if(check_dir & border_dir)
			return src
		if(REVERSE_DIR(check_dir) & border_dir)
			return pulledby
		return prob(50) ? pulledby : src


//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/living/proc/pulled(atom/movable/to_pull)
	if(istype(to_pull) && Adjacent(to_pull))
		start_pulling(to_pull)
	else
		stop_pulling()


/mob/living/stop_pulling()
	if(isliving(pulling))
		reset_pull_offsets(pulling)
	..()
	if(pull_hand != PULL_WITHOUT_HANDS)
		pull_hand = null
	update_hands_HUD()
	update_pull_movespeed()
	pullin?.update_icon(UPDATE_ICON_STATE)


/mob/living/verb/stop_pulling1()
	set name = "Stop Pulling"
	set category = "IC"
	stop_pulling()

//same as above
/mob/living/pointed(atom/A as mob|obj|turf in view())
	if(incapacitated())
		return FALSE
	if(HAS_TRAIT(src, TRAIT_FAKEDEATH))
		return FALSE
	return ..()


/mob/living/run_pointed(atom/target)
	if(!..())
		return FALSE

	var/obj/item/hand_item = get_active_hand()
	var/pointed_object = "[target.declent_ru(ACCUSATIVE)]"

	if(target.loc in src)
		var/atom/inside = target.loc
		pointed_object += " внутри [inside.declent_ru(GENITIVE)]"

	if(isgun(hand_item) && target != hand_item)
		if(a_intent == INTENT_HELP || !ismob(target))
			visible_message("<b>[declent_ru(NOMINATIVE)]</b> указыва[pluralize_ru(gender,"ет","ют")] [hand_item.declent_ru(INSTRUMENTAL)] на [pointed_object].")
			return TRUE

		target.visible_message(
			span_danger("[declent_ru(NOMINATIVE)] направля[pluralize_ru(src.gender,"ет","ют")] [hand_item.declent_ru(INSTRUMENTAL)] на [pointed_object]!"),
			span_userdanger("[declent_ru(NOMINATIVE)] направля[pluralize_ru(src.gender,"ет","ют")] [hand_item.declent_ru(INSTRUMENTAL)] на [pluralize_ru(target.gender,"тебя","вас")]!"),
		)
		SEND_SOUND(target, 'sound/weapons/targeton.ogg')
		SEND_SOUND(src, 'sound/weapons/targeton.ogg')
		add_emote_logs(src, "point [hand_item] HARM to [key_name(target)] [COORD(target)]")
		return TRUE

	if(istype(hand_item, /obj/item/toy/russian_revolver/trick_revolver) && target != hand_item)
		var/obj/item/toy/russian_revolver/trick_revolver/trick = hand_item
		visible_message(span_danger("[declent_ru(NOMINATIVE)] направля[pluralize_ru(src.gender,"ет","ют")] [trick.declent_ru(INSTRUMENTAL)] на... и [trick.declent_ru(NOMINATIVE)] срабатывает у [genderize_ru(gender, "него","неё","него","них")] в руках!"))
		trick.shoot_gun(src)
		add_emote_logs(src, "point to [key_name(target)] [COORD(target)]")
		return TRUE

	visible_message("<b>[declent_ru(NOMINATIVE)]</b> указыва[pluralize_ru(gender,"ет","ют")] на [pointed_object].")
	add_emote_logs(src, "point to [key_name(target)] [COORD(target)]")
	return TRUE


/mob/living/proc/InCritical()
	return (health < HEALTH_THRESHOLD_CRIT && health > HEALTH_THRESHOLD_DEAD && stat == UNCONSCIOUS)


/mob/living/ex_act(severity)
	..()
	flash_eyes()

/mob/living/acid_act(acidpwr, acid_volume)
	take_organ_damage(acidpwr * min(1, acid_volume * 0.1))
	return 1

/mob/living/welder_act(mob/user, obj/item/I)
	if(!I.tool_use_check(user, 0, silent = TRUE)) //Don't need the message, just if it succeeded
		return
	if(IgniteMob())
		message_admins("[key_name_admin(user)] set [key_name_admin(src)] on fire with [I]")
		add_attack_logs(user, src, "set on fire with [I]")

/mob/living/update_stat(reason = "none given", should_log = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		set_stat(CONSCIOUS)
	med_hud_set_health()
	med_hud_set_status()
	update_health_hud()
	update_stamina_hud()
	update_damage_hud()
	if(should_log)
		log_debug("[src] update_stat([reason][HAS_TRAIT(src, TRAIT_GODMODE) ? ", GODMODE" : ""])")


///Sets the current mob's health value. Do not call directly if you don't know what you are doing, use the damage procs, instead.
/mob/living/proc/set_health(new_value)
	. = health
	health = new_value


/mob/living/proc/updatehealth(reason = "none given", should_log = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		set_health(maxHealth)
		update_stat("updatehealth([reason])", should_log)
		return
	set_health(maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss())
	update_stat("updatehealth([reason])", should_log)


//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(pressure)
	return 0

/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(ishuman(src))
//		to_chat(world, "[src] ~ [bodytemperature] ~ [temperature]")
	return temperature


/mob/proc/get_contents()


//Recursive function to find everything a mob is holding.
/mob/living/get_contents(var/obj/item/storage/Storage = null)
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()

		//Leave this commented out, it will cause storage items to exponentially add duplicate to the list
		//for(var/obj/item/storage/S in Storage.return_inv()) //Check for storage items
		//	L += get_contents(S)

		for(var/obj/item/gift/G in Storage.return_inv()) //Check for gift-wrapped items
			L += G.gift
			if(isstorage(G.gift))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in Storage.return_inv()) //Check for package wrapped items
			L += D.wrapped
			if(isstorage(D.wrapped)) //this should never happen
				L += get_contents(D.wrapped)
		return L

	else

		L += contents
		for(var/obj/item/storage/S in contents)	//Check for storage items
			L += get_contents(S)
		for(var/obj/item/clothing/suit/storage/S in contents)//Check for labcoats and jackets
			L += get_contents(S)
		for(var/obj/item/clothing/accessory/storage/S in contents)//Check for holsters
			L += get_contents(S)
		for(var/obj/item/implant/storage/I in contents) //Check for storage implants.
			L += I.get_contents()
		for(var/obj/item/gift/G in contents) //Check for gift-wrapped items
			L += G.gift
			if(isstorage(G.gift))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in contents) //Check for package wrapped items
			L += D.wrapped
			if(isstorage(D.wrapped)) //this should never happen
				L += get_contents(D.wrapped)
		for(var/obj/item/folder/F in contents)
			L += F.contents //Folders can't store any storage items.

		return L

/mob/living/proc/check_contents_for(A)
	var/list/L = get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0

// Living mobs use can_inject() to make sure that the mob is not syringe-proof in general.
/mob/living/proc/can_inject(mob/user, error_msg, target_zone, penetrate_thick, ignore_pierceimmune)
	return TRUE

/mob/living/is_injectable(mob/user, allowmobs = TRUE)
	return (allowmobs && reagents && can_inject(user))

/mob/living/is_drawable(mob/user, allowmobs = TRUE)
	return (allowmobs && reagents && can_inject(user))

/mob/living/proc/restore_all_organs()
	return

/mob/living/proc/revive()
	rejuvenate()
	if(iscarbon(src))
		var/mob/living/carbon/C = src

		if(C.handcuffed && !initial(C.handcuffed))
			C.drop_item_ground(C.handcuffed, TRUE)

		if(C.legcuffed && !initial(C.legcuffed))
			C.drop_item_ground(C.legcuffed, TRUE)

		if(C.reagents)
			C.reagents.clear_reagents()
			QDEL_LIST(C.reagents.addiction_list)
			C.reagents.addiction_threshold_accumulated.Cut()
		if(iscultist(src))
			if(SSticker.mode.cult_risen)
				SSticker.mode.rise(src)
			if(SSticker.mode.cult_ascendant)
				SSticker.mode.ascend(src)

		QDEL_LIST(C.processing_patches)

// rejuvenate: Called by `revive` to get the mob into a revivable state
// the admin "rejuvenate" command calls `revive`, not this proc.
/mob/living/proc/rejuvenate()
	var/mob/living/carbon/human/human_mob = null //Get this declared for use later.

	// shut down various types of badness
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	setStaminaLoss(0)
	SetSleeping(0)
	SetDisgust(0)
	SetParalysis(0, TRUE)
	SetStunned(0, TRUE)
	SetWeakened(0, TRUE)
	SetSlowed(0)
	SetImmobilized(0)
	SetLoseBreath(0)
	SetDizzy(0)
	SetJitter(0)
	SetStuttering(0)
	SetConfused(0)
	SetDrowsy(0)
	radiation = 0
	SetDruggy(0)
	SetHallucinate(0)
	set_nutrition(NUTRITION_LEVEL_FED + 50)
	set_bodytemperature(dna ? dna.species.body_temperature : BODYTEMP_NORMAL)
	CureBlind()
	CureNearsighted()
	CureMute()
	CureDeaf()
	CureTourettes()
	CureEpilepsy()
	CureCoughing()
	CureNervous()
	SetEyeBlind(0)
	SetEyeBlurry(0)
	SetDeaf(0)
	heal_overall_damage(1000, 1000)
	ExtinguishMob()
	CureAllDiseases(FALSE)
	fire_stacks = 0
	on_fire = 0
	suiciding = 0
	if(buckled) //Unbuckle the mob and clear the alerts.
		buckled.unbuckle_mob(src, force = TRUE)

	if(iscarbon(src))
		var/mob/living/carbon/C = src
		C.uncuff()

		for(var/thing in C.diseases)
			var/datum/disease/D = thing
			D.cure(need_immunity = FALSE)

		// restore all of the human's blood and reset their shock stage
		if(ishuman(src))
			human_mob = src
			human_mob.set_heartattack(FALSE)
			human_mob.restore_blood()
			human_mob.decaylevel = 0
			human_mob.remove_all_embedded_objects()
			human_mob.remove_all_parasites()
	SEND_SIGNAL(src, COMSIG_LIVING_AHEAL)
	restore_all_organs()
	surgeries.Cut() //End all surgeries.
	if(stat == DEAD)
		update_revive()
	else if(stat == UNCONSCIOUS)
		set_stat(CONSCIOUS)

	get_up(instant = TRUE)

	update_fire()
	regenerate_icons()
	restore_blood()
	if(human_mob)
		human_mob.update_eyes()
		human_mob.update_dna()
	return

/mob/living/proc/remove_CC()
	SetWeakened(0)
	SetStunned(0)
	SetParalysis(0)
	SetKnockdown(0)
	SetImmobilized(0)
	SetSleeping(0)
	setStaminaLoss(0)
	SetSlowed(0)

/mob/living/proc/UpdateDamageIcon()
	return


/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(CONFIG_GET(flag/allow_metadata))
		if(client)
			to_chat(usr, "[src]'s Metainfo:<br>[client.prefs.metadata]")
		else
			to_chat(usr, "[src] does not have any stored infomation!")
	else
		to_chat(usr, "OOC Metadata is not supported by this server!")


/mob/living/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	if(lying_angle != 0 && !buckled)
		lying_angle_on_movement(direct)

	if(buckled && buckled.loc != newloc) //not updating position
		if(!buckled.anchored)
			buckled.moving_from_pull = moving_from_pull
			. = buckled.Move(newloc, direct)
			buckled?.moving_from_pull = null
		return .

	if(pulling)
		update_pull_movespeed()

	update_push_movespeed()

	var/turf/old_loc = loc

	. = ..()

	if(isliving(pulling))
		set_pull_offsets(pulling, grab_state)

	if(s_active && !(s_active in contents) && get_turf(s_active) != get_turf(src))	//check !( s_active in contents ) first so we hopefully don't have to call get_turf() so much.
		s_active.close(src)

	if(body_position == LYING_DOWN && !buckled && prob(getBruteLoss() * 200 / maxHealth))
		makeTrail(old_loc)


///Called by mob Move() when the lying_angle is different than zero, to better visually simulate crawling.
/mob/living/proc/lying_angle_on_movement(direct)
	if(direct & EAST)
		set_lying_angle(90)
	else if(direct & WEST)
		set_lying_angle(270)


/mob/living/move_from_pull(atom/movable/puller, turf/target_turf, glide_size_override)
	..()
	if(buckled || body_position == LYING_DOWN || m_intent == MOVE_INTENT_WALK || puller.grab_state > GRAB_PASSIVE || get_confusion() <= 0 || !prob(4))
		return
	Knockdown(3 SECONDS)
	puller.stop_pulling()
	visible_message(span_danger("Ноги [name] путаются и [genderize_ru(gender,"он","она","оно","они")] с грохотом пада[pluralize_ru(gender,"ет","ют")] на пол!"))


/mob/living/proc/makeTrail(turf/T)
	if(!has_gravity())
		return
	var/blood_exists = 0

	for(var/obj/effect/decal/cleanable/trail_holder/C in loc) //checks for blood splatter already on the floor
		blood_exists = 1
	if(isturf(loc))
		var/trail_type = getTrail()
		if(trail_type)
			var/brute_ratio = round(getBruteLoss()/maxHealth, 0.1)
			if(blood_volume && blood_volume > max(BLOOD_VOLUME_NORMAL*(1 - brute_ratio * 0.25), 0))//don't leave trail if blood volume below a threshold
				blood_volume = max(blood_volume - max(1, brute_ratio * 2), 0) 					//that depends on our brute damage.
				var/newdir = get_dir(T, loc)
				if(newdir != src.dir)
					newdir = newdir | dir
					if(newdir == 3) //N + S
						newdir = NORTH
					else if(newdir == 12) //E + W
						newdir = EAST
				if((newdir in GLOB.cardinal) && (prob(50)))
					newdir = turn(get_dir(T, loc), 180)
				if(!blood_exists)
					new /obj/effect/decal/cleanable/trail_holder(loc)
				for(var/obj/effect/decal/cleanable/trail_holder/TH in loc)
					if((!(newdir in TH.existing_dirs) || trail_type == "trails_1" || trail_type == "trails_2") && TH.existing_dirs.len <= 16) //maximum amount of overlays is 16 (all light & heavy directions filled)
						TH.existing_dirs += newdir
						TH.overlays.Add(image('icons/effects/blood.dmi', trail_type, dir = newdir))
						TH.transfer_mob_blood_dna(src)
						if(ishuman(src))
							var/mob/living/carbon/human/H = src
							if(H.dna.species.blood_color)
								TH.color = H.dna.species.blood_color
						else
							TH.color = "#A10808"


/mob/living/carbon/human/makeTrail(turf/T)
	if(HAS_TRAIT(src, TRAIT_NO_BLOOD) || !bleed_rate || bleedsuppress)
		return
	..()


/mob/living/proc/getTrail()
	if(getBruteLoss() < 300)
		return pick("ltrails_1", "ltrails_2")
	else
		return pick("trails_1", "trails_2")

/mob/living/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta = 0)
	playsound(src, 'sound/effects/space_wind.ogg', 50, TRUE)
	if(buckled || mob_negates_gravity())
		return FALSE
	if(client && client.move_delay >= world.time + world.tick_lag * 2)
		pressure_resistance_prob_delta -= 30

	var/list/turfs_to_check = list()

	if(has_limbs)
		var/turf/T = get_step(src, angle2dir(dir2angle(direction) + 90))
		if (T)
			turfs_to_check += T

		T = get_step(src, angle2dir(dir2angle(direction) - 90))
		if(T)
			turfs_to_check += T

		for(var/t in turfs_to_check)
			T = t
			if(T.density)
				pressure_resistance_prob_delta -= 20
				continue
			for(var/atom/movable/AM in T)
				if(AM.density && AM.anchored)
					pressure_resistance_prob_delta -= 20
					break

	..(pressure_difference, direction, pressure_resistance_prob_delta)

/*//////////////////////
	START RESIST PROCS
*///////////////////////

/mob/living/can_resist()
	if(next_move > world.time)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_INCAPACITATED))
		return FALSE
	return TRUE


/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(run_resist)))


///proc extender of [/mob/living/verb/resist] meant to make the process queable if the server is overloaded when the verb is called
/mob/living/proc/run_resist()
	if(!can_resist())
		return
	changeNext_move(CLICK_CD_RESIST)

	SEND_SIGNAL(src, COMSIG_LIVING_RESIST, src)

	//resisting grabs (as if it helps anyone...)
	if(!HAS_TRAIT(src, TRAIT_RESTRAINED) && pulledby)
		resist_grab()
		return

	//unbuckling yourself
	if(buckled && last_special <= world.time)
		resist_buckle()

	//Breaking out of a container (Locker, sleeper, cryo...)
	else if(isobj(loc))
		var/obj/C = loc
		C.container_resist(src)

	else if(mobility_flags & MOBILITY_MOVE)
		if(on_fire)
			resist_fire() //stop, drop, and roll
		else if(last_special <= world.time)
			resist_restraints() //trying to remove cuffs.


/*////////////////////
	RESIST SUBPROCS
*/////////////////////

/// Used to override victim resist chances.
/mob/living/proc/get_resist_chance(mob/living/grabber)
	. = 100
	if(!grabber || grabber.grab_state < GRAB_AGGRESSIVE)
		return .
	var/datum/antagonist/vampire/vampire = grabber.mind?.has_antag_datum(/datum/antagonist/vampire)
	var/datum/vampire_passive/upgraded_grab/vampire_grab = vampire?.get_ability(/datum/vampire_passive/upgraded_grab)
	switch(grabber.grab_state)
		if(GRAB_AGGRESSIVE)
			if(vampire_grab)
				. = vampire_grab.grab_resist_chances[MARTIAL_GRAB_AGGRESSIVE]
			else
				var/martial_override = grabber.mind?.martial_art?.get_resist_chance(GRAB_AGGRESSIVE)
				. = isnull(martial_override) ? GRAB_RESIST_CHANCE_AGGRESSIVE : martial_override
		if(GRAB_NECK)
			if(vampire_grab)
				. = vampire_grab.grab_resist_chances[MARTIAL_GRAB_NECK]
			else
				var/martial_override = grabber.mind?.martial_art?.get_resist_chance(GRAB_NECK)
				. = isnull(martial_override) ? GRAB_RESIST_CHANCE_NECK : martial_override
		if(GRAB_KILL)
			if(vampire_grab)
				. = vampire_grab.grab_resist_chances[MARTIAL_GRAB_KILL]
			else
				var/martial_override = grabber.mind?.martial_art?.get_resist_chance(GRAB_KILL)
				. = isnull(martial_override) ? GRAB_RESIST_CHANCE_KILL : martial_override
	if(. > 0)
		if(ishuman(src))
			var/mob/living/carbon/human/human = src
			. *= human.physiology.grab_resist_mod
		. = round(. * (1 - (clamp(getStaminaLoss(), 0, maxHealth) / maxHealth)))
	else if(. < 0)
		. = 0
		stack_trace("Wrong resist chance passed to get_resist_chance(), defaulting to zero.")


/// Basic proc used to resist any grab state.
/mob/proc/resist_grab(moving_resist = FALSE)
	return TRUE //returning FALSE means we successfully broke free


/mob/living/resist_grab(moving_resist = FALSE)
	if(pulledby.grab_state < GRAB_AGGRESSIVE)
		pulledby.stop_pulling()
		return FALSE

	if(!COOLDOWN_FINISHED(src, grab_resist_delay))
		return TRUE

	var/resist_chance = get_resist_chance(pulledby)
	if(resist_chance > 0 && prob(resist_chance))
		add_attack_logs(pulledby, src, "broke grab", ATKLOG_ALL)
		visible_message(
			span_danger("[name] вырвал[genderize_ru(gender, "ся", "ась", "ось", "ись")] из захвата [pulledby.name]!"),
			span_danger("Вы вырвались из захвата [pulledby.name]!"),
			ignored_mobs = pulledby,
		)
		to_chat(pulledby, span_danger("[name] вырвал[genderize_ru(gender, "ся", "ась", "ось", "ись")] из Вашего захвата!"))
		pulledby.stop_pulling()
		return FALSE

	var/resist_stamina_cost = 20
	switch(pulledby.grab_state)
		if(GRAB_NECK)
			resist_stamina_cost += rand(5, 10)
		if(GRAB_KILL)
			resist_stamina_cost += rand(10, 15)
	adjustStaminaLoss(resist_stamina_cost)//failure to escape still imparts a pretty serious penalty
	visible_message(
		span_danger("[name] не удаётся вырваться из захвата [pulledby.name]!"),
		span_danger("Вам не удаётся вырваться из захвата [pulledby.name]!"),
		ignored_mobs = pulledby,
	)
	to_chat(pulledby, span_danger("[name] пыта[pluralize_ru(gender,"ется","ются")] вырваться из Вашего захвата!"))
	COOLDOWN_START(src, grab_resist_delay, 2 SECONDS)
	if(moving_resist && client) //we resisted by trying to move
		client.move_delay = world.time + 2 SECONDS
	return TRUE


/mob/living/proc/resist_buckle()
	buckled.user_unbuckle_mob(src, src)


/mob/living/proc/resist_muzzle()
	return


/mob/living/proc/resist_fire()
	return FALSE


/mob/living/proc/resist_restraints()
	return FALSE


/*//////////////////////
	END RESIST PROCS
*///////////////////////

/mob/living/proc/Exhaust()
	to_chat(src, "<span class='notice'>You're too exhausted to keep going...</span>")
	Weaken(10 SECONDS)


/mob/living/proc/is_facehugged()
	return FALSE


/mob/living/proc/update_gravity(gravity)
	// Handle movespeed stuff
	var/speed_change = max(0, gravity - STANDARD_GRAVITY)
	if(speed_change)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/gravity, multiplicative_slowdown = speed_change)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/gravity)

	// Time to add/remove gravity alerts. sorry for the mess it's gotta be fast
	var/atom/movable/screen/alert/gravity_alert = LAZYACCESS(alerts, ALERT_GRAVITY)
	switch(gravity)
		if(-INFINITY to NEGATIVE_GRAVITY)
			if(!istype(gravity_alert, /atom/movable/screen/alert/negative))
				throw_alert(ALERT_GRAVITY, /atom/movable/screen/alert/negative)
				ADD_TRAIT(src, TRAIT_MOVE_UPSIDE_DOWN, NEGATIVE_GRAVITY_TRAIT)
				var/matrix/flipped_matrix = transform
				flipped_matrix.b = -flipped_matrix.b
				flipped_matrix.e = -flipped_matrix.e
				animate(src, transform = flipped_matrix, pixel_y = pixel_y+4, time = 0.5 SECONDS, easing = EASE_OUT)
				base_pixel_y += 4
		if(NEGATIVE_GRAVITY + 0.01 to 0)
			if(!istype(gravity_alert, /atom/movable/screen/alert/weightless))
				throw_alert(ALERT_GRAVITY, /atom/movable/screen/alert/weightless)
				ADD_TRAIT(src, TRAIT_MOVE_FLOATING, NO_GRAVITY_TRAIT)
		if(0.01 to STANDARD_GRAVITY)
			if(gravity_alert)
				clear_alert(ALERT_GRAVITY)
		if(STANDARD_GRAVITY + 0.01 to GRAVITY_DAMAGE_THRESHOLD - 0.01)
			throw_alert(ALERT_GRAVITY, /atom/movable/screen/alert/highgravity)
		if(GRAVITY_DAMAGE_THRESHOLD to INFINITY)
			throw_alert(ALERT_GRAVITY, /atom/movable/screen/alert/veryhighgravity)

	// If we had no gravity alert, or the same alert as before, go home
	if(!gravity_alert || LAZYACCESS(alerts, ALERT_GRAVITY) == gravity_alert)
		return

	// By this point we know that we do not have the same alert as we used to
	if(istype(gravity_alert, /atom/movable/screen/alert/weightless))
		REMOVE_TRAIT(src, TRAIT_MOVE_FLOATING, NO_GRAVITY_TRAIT)

	else if(istype(gravity_alert, /atom/movable/screen/alert/negative))
		REMOVE_TRAIT(src, TRAIT_MOVE_UPSIDE_DOWN, NEGATIVE_GRAVITY_TRAIT)
		var/matrix/flipped_matrix = transform
		flipped_matrix.b = -flipped_matrix.b
		flipped_matrix.e = -flipped_matrix.e
		animate(src, transform = flipped_matrix, pixel_y = pixel_y-4, time = 0.5 SECONDS, easing = EASE_OUT)
		base_pixel_y -= 4


///Proc to modify the value of num_legs and hook behavior associated to this event.
/mob/living/proc/set_num_legs(new_value)
	if(num_legs == new_value)
		return
	. = num_legs
	num_legs = new_value


///Proc to modify the value of usable_legs and hook behavior associated to this event.
/mob/living/proc/set_usable_legs(new_value, special = ORGAN_MANIPULATION_DEFAULT)
	if(usable_legs == new_value)
		return
	if(new_value < 0) // Sanity check
		stack_trace("[src] had set_usable_legs() called on them with a negative value!")
		new_value = 0

	. = usable_legs
	usable_legs = new_value

	if(special != ORGAN_MANIPULATION_DEFAULT)
		return .

	if(new_value > .) // Gained leg usage.
		REMOVE_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	else if(!(movement_type & (FLYING|FLOATING))) //Lost leg usage, not flying.
		if(!usable_legs)
			ADD_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
			if(!usable_hands)
				ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)

	update_limbless_slowdown()


///Proc to modify the value of num_hands and hook behavior associated to this event.
/mob/living/proc/set_num_hands(new_value)
	if(num_hands == new_value)
		return
	. = num_hands
	num_hands = new_value


///Proc to modify the value of usable_hands and hook behavior associated to this event.
/mob/living/proc/set_usable_hands(new_value, special = ORGAN_MANIPULATION_DEFAULT, hand_index)
	if(usable_hands == new_value)
		return
	. = usable_hands
	usable_hands = new_value

	if(special != ORGAN_MANIPULATION_DEFAULT)
		return .

	if(hand_index && pulling && !isnull(pull_hand) && pull_hand != PULL_WITHOUT_HANDS)
		if((hand_index == BODY_ZONE_PRECISE_L_HAND && pull_hand == PULL_HAND_LEFT) || (hand_index == BODY_ZONE_PRECISE_R_HAND && pull_hand == PULL_HAND_RIGHT))
			stop_pulling()

	if(new_value > .) // Gained hand usage.
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	else if(!(movement_type & (FLYING|FLOATING)) && !usable_hands && !usable_legs) //Lost a hand, not flying, no hands left, no legs.
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)

	if(!usable_legs)
		update_limbless_slowdown()	// in case we got new hand but have no legs


/mob/living/proc/update_limbless_slowdown()
	if(usable_legs < default_num_legs)
		var/limbless_slowdown = (default_num_legs - usable_legs) * 4 - get_crutches()
		if(!usable_legs && usable_hands < default_num_hands)
			limbless_slowdown += (default_num_hands - usable_hands) * 4
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/limbless, multiplicative_slowdown = limbless_slowdown)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/limbless)


/// Returns a modifier of all items considered as crutches in hands.
/mob/living/proc/get_crutches()
	. = 0
	// Canes and crutches help you stand (if the latter is ever added)
	// One cane mitigates a broken leg+foot, or a missing foot.
	// Two canes are needed for a lost leg. If you are missing both legs or you are lying, canes aren't gonna help you.
	if(body_position == LYING_DOWN)
		return .
	. += l_hand?.is_crutch()
	. += r_hand?.is_crutch()


//called when the mob receives a bright flash
/mob/living/proc/flash_eyes(intensity = 1, override_blindness_check, affect_silicon, visual, type = /atom/movable/screen/fullscreen/flash)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	if(check_eye_prot() < intensity && (override_blindness_check || !HAS_TRAIT(src, TRAIT_BLIND)))
		overlay_fullscreen("flash", type)
		addtimer(CALLBACK(src, PROC_REF(clear_fullscreen), "flash", 25), 25)
		return TRUE


/mob/living/proc/check_eye_prot()
	var/eye_prot = FLASH_PROTECTION_NONE
	var/datum/antagonist/vampire/vampire = mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vampire?.get_ability(/datum/vampire_passive/eyes_flash_protection))
		eye_prot += FLASH_PROTECTION_FLASH
	if(vampire?.get_ability(/datum/vampire_passive/eyes_welding_protection))
		eye_prot += FLASH_PROTECTION_FLASH
	return eye_prot


/mob/living/proc/check_ear_prot()
	var/datum/antagonist/vampire/vampire = mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vampire?.get_ability(/datum/vampire_passive/ears_bang_protection))
		return HEARING_PROTECTION_TOTAL
	return HEARING_PROTECTION_NONE


/mob/living/singularity_act()
	investigate_log("([key_name_log(src)]) has been consumed by the singularity.", INVESTIGATE_ENGINE) //Oh that's where the clown ended up!
	gib()
	return 20

/mob/living/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_SIX) //your puny magboots/wings/whatever will not save you against supermatter singularity
		throw_at(S, 14, 3, src, TRUE)
	else if(!mob_negates_gravity())
		step_towards(src,S)

/mob/living/narsie_act()
	if(client)
		make_new_construct(/mob/living/simple_animal/hostile/construct/harvester, src, cult_override = TRUE)
	spawn_dust()
	gib()

/mob/living/ratvar_act(weak = FALSE)
	if(weak)
		return //It's too weak to break a flesh!
	if(client)
		switch(rand(1,3))
			if(1)
				var/mob/living/simple_animal/hostile/clockwork/marauder/cog = new (get_turf(src))
				if(mind)
					SSticker.mode.add_clocker(mind)
					mind.transfer_to(cog)
				else
					cog.key = client.key
			if(2)
				var/mob/living/silicon/robot/cogscarab/cog = new (get_turf(src))
				if(mind)
					SSticker.mode.add_clocker(mind)
					mind.transfer_to(cog)
				else
					cog.key = client.key
			if(3)
				var/mob/living/silicon/robot/cog = new (get_turf(src))
				if(mind)
					SSticker.mode.add_clocker(mind)
					mind.transfer_to(cog)
				else
					cog.key = client.key
				cog.ratvar_act()
	spawn_dust()
	gib()

/mob/living/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item)
		used_item = get_active_hand()
		if(!visual_effect_icon && used_item?.attack_effect_override)
			visual_effect_icon = used_item.attack_effect_override
	..()


/// Helper proc that causes the mob to do a jittering animation by jitter_amount.
/// `jitteriness` will only apply up to 300 (maximum jitter effect).
/mob/living/proc/do_jitter_animation(jitteriness, loop_amount = 6)
	var/amplitude = min(4, (jitteriness / 100) + 1)
	var/pixel_x_diff = rand(-amplitude, amplitude)
	var/pixel_y_diff = rand(-amplitude / 3, amplitude / 3)
	animate(src, pixel_x = pixel_x_diff, pixel_y = pixel_y_diff, time = 0.2 SECONDS, loop = loop_amount, flags = ANIMATION_PARALLEL)
	animate(pixel_x = -pixel_x_diff, pixel_y = -pixel_y_diff, time = 0.2 SECONDS)


/mob/living/proc/get_temperature(datum/gas_mixture/environment)
	if(istype(loc, /obj/structure/closet/critter))
		return environment.temperature
	if(ismecha(loc))
		var/obj/mecha/M = loc
		return  M.return_temperature()
	if(isvampirecoffin(loc))
		var/obj/structure/closet/coffin/vampire/coffin = loc
		return coffin.return_temperature()
	if(isspacepod(loc))
		var/obj/spacepod/S = loc
		return S.return_temperature()
	if(istype(loc, /obj/structure/transit_tube_pod))
		return environment.temperature
	if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		return heat_turf.temperature
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		var/obj/machinery/atmospherics/unary/cryo_cell/C = loc
		if(C.air_contents.total_moles() < 10)
			return environment.temperature
		else
			return C.air_contents.temperature
	if(environment)
		return environment.temperature
	return T0C


/mob/living/proc/spawn_dust()
	new /obj/effect/decal/cleanable/ash(loc)

//used in datum/reagents/reaction() proc
/mob/living/proc/get_permeability_protection()
	return 0


/mob/living/proc/attempt_harvest(obj/item/I, mob/user)
	if(user.a_intent != INTENT_HARM || stat != DEAD || !is_sharp(I) || (!butcher_results && !is_monkeybasic(src))) //can we butcher it?
		return FALSE
	. = TRUE
	to_chat(user, span_notice("You begin to butcher [src]..."))
	playsound(loc, 'sound/weapons/slice.ogg', 50, TRUE, -1)
	if(!do_after(user, 4 SECONDS * mob_size, src, NONE, max_interact_count = 1, cancel_on_max = TRUE) || !Adjacent(user))
		return .
	harvest(user)


/mob/living/proc/harvest(mob/living/user)
	if(QDELETED(src) || !butcher_results)
		return
	for(var/path in butcher_results)
		for(var/i in 1 to butcher_results[path])
			new path(loc)
		butcher_results.Remove(path) //In case you want to have things like simple_animals drop their butcher results on gib, so it won't double up below.
	visible_message(span_notice("[user] butchers [src]."))
	gib()


/mob/living/proc/can_use_guns(var/obj/item/gun/G)
	if(G.trigger_guard != TRIGGER_GUARD_ALLOW_ALL && !IsAdvancedToolUser() && !is_monkeybasic(src))
		to_chat(src, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 0
	return 1


/mob/living/can_be_pulled(atom/movable/puller, grab_state, force, supress_message)
	return ..() && !(buckled && buckled.buckle_prevents_pull)


/mob/living/proc/can_pull(hand_to_check, supress_message = FALSE)
	if(pull_hand == PULL_WITHOUT_HANDS)
		return TRUE
	var/hand_occupied = (hand_to_check == ACTIVE_HAND_LEFT) ? l_hand : r_hand
	if(hand_occupied || (!isnull(pull_hand) && hand_to_check == pull_hand))
		if(!supress_message)
			to_chat(src, span_warning("Освободите [(hand_to_check == ACTIVE_HAND_LEFT) ? "левую" : "правую"] руку!"))
		return FALSE
	return TRUE


/mob/living/start_pulling(atom/movable/pulled_atom, state, force = pull_force, supress_message = FALSE)
	if(QDELETED(pulled_atom) || QDELETED(src))
		return FALSE
	if(!pulled_atom.can_be_pulled(src, state, force))
		return FALSE
	if(throwing || !(mobility_flags & MOBILITY_PULL))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_LIVING_TRY_PULL, pulled_atom, force) & COMSIG_LIVING_CANCEL_PULL)
		return FALSE
	if(SEND_SIGNAL(pulled_atom, COMSIG_LIVING_TRYING_TO_PULL, src, force) & COMSIG_LIVING_CANCEL_PULL)
		return FALSE

	pulled_atom.add_fingerprint(src)

	// If we're pulling something then drop what we're currently pulling and pull this instead.
	if(pulling)
		// Are we trying to pull something we are already pulling with the same hand? Then just stop here, no need to continue.
		if(pulled_atom == pulling && (pull_hand == PULL_WITHOUT_HANDS || pull_hand == hand))
			return FALSE
		stop_pulling()

	// carbons can try to pull with other hand
	if(iscarbon(src))
		var/active_hand_available = can_pull(hand, supress_message = TRUE)
		var/inactive_hand_available = can_pull(!hand, supress_message = TRUE)
		if(!active_hand_available && !inactive_hand_available)
			if(!supress_message)
				can_pull(hand)	// we still need to inform user about his active hand unavailability
			return FALSE
		if(!active_hand_available && !swap_hand())
			return FALSE
	else if(!can_pull(hand, supress_message))
		return FALSE

	. = TRUE

	changeNext_move(CLICK_CD_GRABBING)

	if(pulled_atom.pulledby)
		if(!supress_message)
			pulled_atom.visible_message(
				span_danger("[name] перехватил[genderize_ru(gender,"","а","о","и")] [pulled_atom.name] у [pulled_atom.pulledby.name]."),
				span_danger("[name] перехватил[genderize_ru(gender,"","а","о","и")] Вас у [pulled_atom.pulledby.name]!"),
			)
			to_chat(src, span_notice("Вы перехватили [pulled_atom.name] у [pulled_atom.pulledby.name]!"))
		add_attack_logs(pulled_atom, pulled_atom.pulledby, "pulled from", ATKLOG_ALMOSTALL)
		pulled_atom.pulledby.stop_pulling() //an object can't be pulled by two mobs at once.

	if(pull_hand != PULL_WITHOUT_HANDS)
		pull_hand = hand
	pulling = pulled_atom
	pulled_atom.set_pulledby(src)

	SEND_SIGNAL(src, COMSIG_LIVING_START_PULL, pulled_atom, state, force)

	if(!supress_message)
		var/sound_to_play = 'sound/weapons/thudswoosh.ogg'
		if(ishuman(src))
			var/mob/living/carbon/human/human_grabber = src
			//if(human_grabber.dna.species.grab_sound)
			//	sound_to_play = human_puller.dna.species.grab_sound
			if(HAS_TRAIT(human_grabber, TRAIT_STRONG_GRABBER))
				sound_to_play = null
		if(sound_to_play)
			playsound(loc, sound_to_play, 50, TRUE, -1)

	pullin?.update_icon(UPDATE_ICON_STATE)
	update_hands_HUD()

	if(ismob(pulled_atom))
		var/mob/pulled_mob = pulled_atom
		add_attack_logs(src, pulled_mob, "passively grabbed", ATKLOG_ALMOSTALL)

		pulled_mob.LAssailant = iscarbon(src) ? src : null

		if(!supress_message && !(iscarbon(pulled_mob) && HAS_TRAIT(src, TRAIT_STRONG_GRABBER)))
			if(ishuman(pulled_mob))
				var/mob/living/carbon/human/grabbed_human = pulled_mob
				var/grabbed_by_hands = (zone_selected == BODY_ZONE_PRECISE_R_HAND || zone_selected == BODY_ZONE_PRECISE_L_HAND) && grabbed_human.usable_hands > 0
				grabbed_human.visible_message(
					span_warning("[name] схватил[genderize_ru(gender,"","а","о","и")] [grabbed_human.name][grabbed_by_hands ? " за руки" : ""]!"),
					span_warning("[name] схватил[genderize_ru(gender,"","а","о","и")] Вас[grabbed_by_hands ? " за руки" : ""]!"),
					ignored_mobs = src,
				)
				to_chat(src, span_notice("Вы cхватили [grabbed_human.name][grabbed_by_hands ? " за руки" : ""]!"))
			else
				pulled_mob.visible_message(
					span_warning("[name] схватил[genderize_ru(gender,"","а","о","и")] [pulled_mob.declent_ru(ACCUSATIVE)]!"),
					span_warning("[name] схватил[genderize_ru(gender,"","а","о","и")] Вас!"),
					ignored_mobs = src,
				)
				to_chat(src, span_notice("Вы схватили [pulled_mob.declent_ru(ACCUSATIVE)]!"))

		if(isliving(pulled_mob))
			var/mob/living/pulled_living = pulled_mob

			SEND_SIGNAL(pulled_living, COMSIG_LIVING_GET_PULLED, src)

			//Share diseases that are spread by touch
			for(var/datum/disease/virus/virus in diseases)
				if(virus.spread_flags & CONTACT)
					virus.Contract(pulled_living, act_type = CONTACT, need_protection_check = TRUE, zone = zone_selected)

			for(var/datum/disease/virus/virus in pulled_living.diseases)
				if(virus.spread_flags & CONTACT)
					virus.Contract(src, act_type = CONTACT, need_protection_check = TRUE, zone = hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)

			if(iscarbon(pulled_living) && HAS_TRAIT(src, TRAIT_STRONG_GRABBER))
				pulled_living.grabbedby(src)

			set_pull_offsets(pulled_living, state)

		pulled_mob.LAssailant = iscarbon(src) ? src : null

	update_pull_movespeed()


/mob/living/proc/set_pull_offsets(mob/living/target, grab_state_to_offset = GRAB_PASSIVE)
	if(target.buckled)
		return //don't make them change direction or offset them if they're buckled into something.
	var/offset = 0
	switch(grab_state_to_offset)
		if(GRAB_PASSIVE)
			offset = GRAB_PIXEL_SHIFT_PASSIVE
		if(GRAB_AGGRESSIVE)
			offset = GRAB_PIXEL_SHIFT_AGGRESSIVE
		if(GRAB_NECK)
			offset = GRAB_PIXEL_SHIFT_NECK
		if(GRAB_KILL)
			offset = GRAB_PIXEL_SHIFT_KILL
	var/same_loc = target.loc == loc
	var/direction = same_loc ? dir : get_dir(target, src)
	var/target_pixel_x = target.base_pixel_x + target.body_position_pixel_x_offset
	var/target_pixel_y = target.base_pixel_y + target.body_position_pixel_y_offset
	target.setDir(direction)
	target.update_layer()
	if(direction & NORTH)
		target_pixel_y += offset
	else if(direction & SOUTH)
		target_pixel_y -= offset
	if(direction & EAST)
		if(same_loc && target.lying_angle == 90) //update the dragged dude's direction if we've turned
			target.set_lying_angle(270)
		else if(!same_loc && target.lying_angle == 270)
			target.set_lying_angle(90)
		target_pixel_x += offset
	else if(direction & WEST)
		if(same_loc && target.lying_angle == 270)
			target.set_lying_angle(90)
		else if(!same_loc && target.lying_angle == 90)
			target.set_lying_angle(270)
		target_pixel_x -= offset
	animate(target, pixel_x = target_pixel_x, pixel_y = target_pixel_y, 0.3 SECONDS)


/mob/living/proc/reset_pull_offsets(mob/living/target, override)
	if(!override && target.buckled)
		return
	update_layer()
	animate(target, pixel_x = target.base_pixel_x + target.body_position_pixel_x_offset , pixel_y = target.base_pixel_y + target.body_position_pixel_y_offset, 0.1 SECONDS)


/mob/living/Move_Pulled(atom/moving_atom)
	. = ..()
	if(!. || !isliving(pulling))
		return .
	set_pull_offsets(pulling, grab_state)


/// Proc extender of quick equip verb when user tries to equip grab or pull.
/// Returning TRUE will add 1s. cooldown on the next move.
/mob/living/proc/on_grab_quick_equip(atom/movable/grabbed_thing, current_pull_hand)
	return FALSE


/mob/living/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || !isliving(grabbed_thing))
		return .
	var/mob/living/target = grabbed_thing
	switch(grabber.a_intent)
		if(INTENT_HARM)
			if(target != src || !ishuman(target) || !ishuman(grabber) || target.body_position == LYING_DOWN)
				return
			var/mob/living/carbon/human/attacker = grabber
			var/mob/living/carbon/human/victim = target
			var/obj/item/organ/external/head/head = victim.get_organ(BODY_ZONE_HEAD)
			if(!head)
				return
			victim.visible_message(
				span_danger("[attacker] нанос[pluralize_ru(attacker.gender,"ит","ят")] удар головой в мягкие ткани черепа [victim.name]!"),
				span_userdanger("[attacker] нанос[pluralize_ru(attacker.gender,"ит","ят")] удар головой в мягкие ткани Вашего черепа!"),
			)
			attacker.do_attack_animation(victim, no_effect = TRUE)
			var/damage = 5
			if(attacker.head)
				damage += attacker.head.force * 3
			victim.apply_damage(damage*rand(90, 110)/100, BRUTE, BODY_ZONE_HEAD, victim.run_armor_check(head, MELEE))
			if(prob(40))
				victim.Knockdown(2 SECONDS)
			playsound(victim.loc, "desceration", 35, TRUE, -1)
			add_attack_logs(attacker, victim, "Headbutted")

		if(INTENT_GRAB)
			if(grabber == src)
				target.devoured(grabber)


/mob/living/proc/update_z(new_z) // 1+ to register, null to unregister
	if(registered_z == new_z)
		return
	if(registered_z)
		SSmobs.clients_by_zlevel[registered_z] -= src
	if(isnull(client))
		registered_z = null
		return
	if(!new_z)
		registered_z = new_z
		return
	//Figure out how many clients were here before
	var/oldlen = SSmobs.clients_by_zlevel[new_z].len
	SSmobs.clients_by_zlevel[new_z] += src
	for(var/index in length(SSidlenpcpool.idle_mobs_by_zlevel[new_z]) to 1 step -1) //Backwards loop because we're removing (guarantees optimal rather than worst-case performance), it's fine to use .len here but doesn't compile on 511
		var/mob/living/simple_animal/animal = SSidlenpcpool.idle_mobs_by_zlevel[new_z][index]
		if(animal)
			if(!oldlen)
				//Start AI idle if nobody else was on this z level before (mobs will switch off when this is the case)
				animal.toggle_ai(AI_IDLE)
			//If they are also within a close distance ask the AI if it wants to wake up
			if(get_dist(get_turf(src), get_turf(animal)) < MAX_SIMPLEMOB_WAKEUP_RANGE)
				animal.consider_wakeup() // Ask the mob if it wants to turn on it's AI
		//They should clean up in destroy, but often don't so we get them here
		else
			SSidlenpcpool.idle_mobs_by_zlevel[new_z] -= animal
	registered_z = new_z


/mob/living/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents = TRUE)
	..()
	update_z(new_turf?.z)

/mob/living/proc/owns_soul()
	if(mind)
		return mind.soulOwner == mind
	return 1

/mob/living/proc/return_soul()
	if(mind)
		if(mind.soulOwner.devilinfo)//Not sure how this could happen, but whatever.
			mind.soulOwner.devilinfo.remove_soul(mind)
		mind.soulOwner = mind
		mind.damnation_type = 0

/mob/living/proc/has_bane(banetype)
	if(mind)
		if(mind.devilinfo)
			return mind.devilinfo.bane == banetype
	return 0

/mob/living/proc/check_weakness(obj/item/weapon, mob/living/attacker)
	if(mind && mind.devilinfo)
		return check_devil_bane_multiplier(weapon, attacker)
	return 1

/mob/living/proc/check_acedia()
	if(src.mind && src.mind.objectives)
		for(var/datum/objective/sintouched/acedia/A in src.mind.objectives)
			return 1
	return 0

/mob/living/proc/fakefireextinguish()
	return

/mob/living/proc/fakefire()
	return

/mob/living/extinguish_light(force = FALSE)
	for(var/obj/item/item as anything in get_equipped_items(TRUE, TRUE))
		item.extinguish_light(force)

/mob/living/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, maxHealth))
			if(!isnum(var_value) || var_value <= 0)
				return FALSE
		if(NAMEOF(src, health)) //this doesn't work. gotta use procs instead.
			return FALSE
		if(NAMEOF(src, resting))
			set_resting(var_value)
			. = TRUE
		if(NAMEOF(src, lying_angle))
			set_lying_angle(var_value)
			. = TRUE
		if(NAMEOF(src, buckled))
			set_buckled(var_value)
			. = TRUE
		if(NAMEOF(src, num_legs))
			set_num_legs(var_value)
			. = TRUE
		if(NAMEOF(src, usable_legs))
			set_usable_legs(var_value)
			. = TRUE
		if(NAMEOF(src, num_hands))
			set_num_hands(var_value)
			. = TRUE
		if(NAMEOF(src, usable_hands))
			set_usable_hands(var_value)
			. = TRUE
		if(NAMEOF(src, body_position))
			set_body_position(var_value)
			. = TRUE
		if(NAMEOF(src, current_size))
			if(var_value == 0) //prevents divisions of and by zero.
				return FALSE
			update_transform(var_value/current_size)
			. = TRUE

	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return .

	. = ..()

	switch(var_name)
		if(NAMEOF(src, maxHealth))
			updatehealth("var edit")
		if(NAMEOF(src, lighting_alpha))
			sync_lighting_plane_alpha()


/mob/living/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, dodgeable)
	stop_pulling()
	return ..()


/mob/living/hit_by_thrown_carbon(mob/living/carbon/human/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	if(C == src || (movement_type & MOVETYPES_NOT_TOUCHING_GROUND) || !density)
		return
	playsound(src, 'sound/weapons/punch1.ogg', 50, TRUE)
	if(mob_hurt)
		return
	if(!self_hurt)
		take_organ_damage(damage)
	C.take_organ_damage(damage)
	C.Weaken(3 SECONDS)
	C.visible_message(span_danger("[C.name] вреза[pluralize_ru(src.gender,"ет","ют")]ся в [name], сбивая друг друга с ног!"),
					span_userdanger("Вы жестко врезаетесь в [name]!"))


/mob/living/proc/get_visible_species()	// Used only in /mob/living/carbon/human and /mob/living/simple_animal/hostile/morph
	return "Unknown"


/**
 * Can this mob see in the dark
 *
 * Cursed version of checking lighting_cutoffs, just making orientation on nightvision see_in_dark analog
 *
**/
/mob/proc/has_nightvision()
	return nightvision >= 4

/mob/living/run_examinate(atom/target)
	var/datum/status_effect/staring/user_staring_effect = has_status_effect(STATUS_EFFECT_STARING)

	if(user_staring_effect || hindered_inspection(target))
		return

	if(isturf(target) && !(sight & SEE_TURFS) && !(target in view(client ? client.view : world.view, src)))
		// shift-click catcher may issue examinate() calls for out-of-sight turfs
		return

	var/turf/examine_turf = get_turf(target)

	if(examine_turf && !(examine_turf.luminosity || examine_turf.dynamic_lumcount) && \
		get_dist(src, examine_turf) > 1 && \
		!has_nightvision()) // If you aren't blind, it's in darkness (that you can't see) and farther then next to you
		return

	var/examine_time = target.get_examine_time()
	if(examine_time && target != src)
		var/visible_gender = target.get_visible_gender()
		var/visible_species = "Unknown"

		// If we did not see the target with our own eyes when starting the examine, then there is no need to check whether it is close.
		var/near_target = examine_distance_check(target)

		if(isliving(target))
			var/mob/living/target_living = target
			visible_species = target_living.get_visible_species()

			if(ishuman(target))	// Yep. Only humans affected by catched looks.
				var/datum/status_effect/staring/target_staring_effect = target_living.has_status_effect(STATUS_EFFECT_STARING)
				if(target_staring_effect)
					target_staring_effect.catch_look(src)

		user_staring_effect = apply_status_effect(STATUS_EFFECT_STARING, examine_time, target, visible_gender, visible_species)
		if(do_after(src, examine_time, src, ALL))
			if(hindered_inspection(target) || (near_target && !examine_distance_check(target)))
				return
			..()
	else
		..()


/mob/living/proc/examine_distance_check(atom/target)
	if(target in view(client.maxview(), client.eye))
		return TRUE


/mob/living/proc/hindered_inspection(atom/target)
	if(QDELETED(src) || QDELETED(target))
		return TRUE
	face_atom(target)
	if(!has_vision(information_only = TRUE))
		to_chat(src, chat_box_regular(span_notice("Здесь что-то есть, но вы не видите — что именно.")), MESSAGE_TYPE_INFO, confidential = TRUE)
		return TRUE
	return FALSE


/**
  * Sets the mob's direction lock towards a given atom.
  *
  * Arguments:
  * * a - The atom to face towards.
  * * track - If TRUE, updates our direction relative to the atom when moving.
  */
/mob/living/proc/set_forced_look(atom/A, track = FALSE)
	forced_look = track ? A.UID() : get_cardinal_dir(src, A)
	setDir()
	add_movespeed_modifier(/datum/movespeed_modifier/forced_look)
	to_chat(src, span_userdanger("You are now facing [track ? A : dir2text(forced_look)]. To cancel this, shift-middleclick yourself."))
	throw_alert(ALERT_DIRECTION_LOCK, /atom/movable/screen/alert/direction_lock)


/**
  * Clears the mob's direction lock if enabled.
  *
  * Arguments:
  * * quiet - Whether to display a chat message.
  */
/mob/living/proc/clear_forced_look(quiet = FALSE)
	if(!forced_look)
		return
	forced_look = null
	remove_movespeed_modifier(/datum/movespeed_modifier/forced_look)
	if(!quiet)
		to_chat(src, span_notice("Cancelled direction lock."))
	clear_alert(ALERT_DIRECTION_LOCK)


/mob/living/face_atom(atom/A)
	. = ..()
	if(. && isliving(pulling) && pulling.loc == loc)
		set_pull_offsets(pulling, grab_state)


/mob/living/setDir(newdir)
	if(forced_look)	// this should be an element at least
		if(isnum(forced_look))
			newdir = forced_look
		else
			var/atom/look_at = locateUID(forced_look)
			if(istype(look_at))
				newdir = get_cardinal_dir(src, look_at)
	return ..()


///Reports the event of the change in value of the buckled variable.
/mob/living/proc/set_buckled(new_buckled)
	if(new_buckled == buckled)
		return
	SEND_SIGNAL(src, COMSIG_LIVING_SET_BUCKLED, new_buckled)
	. = buckled
	buckled = new_buckled

	if(buckled)
		if(!HAS_TRAIT(buckled, TRAIT_NO_IMMOBILIZE))
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, BUCKLED_TRAIT)
		switch(buckled.buckle_lying)
			if(NO_BUCKLE_LYING) // The buckle doesn't force a lying angle.
				REMOVE_TRAIT(src, TRAIT_FLOORED, BUCKLED_TRAIT)
			if(0) // Forcing to a standing position.
				REMOVE_TRAIT(src, TRAIT_FLOORED, BUCKLED_TRAIT)
				set_body_position(STANDING_UP)
			else // Forcing to a lying position.
				ADD_TRAIT(src, TRAIT_FLOORED, BUCKLED_TRAIT)
				set_body_position(LYING_DOWN)
				set_lying_angle(buckled.buckle_lying)
	else
		remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_FLOORED), BUCKLED_TRAIT)
		if(.) // We unbuckled from something.
			var/atom/movable/old_buckled = .
			if(old_buckled.buckle_lying == 0) // The buckle forced us to stay up (like a chair)
				if(HAS_TRAIT(src, TRAIT_FLOORED)) // We want to rest or are otherwise floored, so let's drop on the ground.
					on_fall()
					set_body_position(LYING_DOWN)
				else if(resting)
					set_lying_on_rest()


/mob/living/set_pulledby(new_pulledby)
	. = ..()
	if(. == FALSE) //null is a valid value here, we only want to return if FALSE is explicitly passed.
		return .
	/*
	if(pulledby)
		if(!. && stat == SOFT_CRIT)
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, PULLED_WHILE_SOFTCRIT_TRAIT)
	else if(. && stat == SOFT_CRIT)
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, PULLED_WHILE_SOFTCRIT_TRAIT)
	*/


/// Updates the grab state of the mob and updates movespeed
/mob/living/setGrabState(newstate)
	. = ..()
	update_hands_HUD()
	switch(grab_state)
		if(GRAB_PASSIVE)
			remove_movespeed_modifier(MOVESPEED_ID_MOB_GRAB_STATE)
		if(GRAB_AGGRESSIVE)
			add_movespeed_modifier(/datum/movespeed_modifier/grab_slowdown/aggressive)
		if(GRAB_NECK)
			add_movespeed_modifier(/datum/movespeed_modifier/grab_slowdown/neck)
		if(GRAB_KILL)
			add_movespeed_modifier(/datum/movespeed_modifier/grab_slowdown/kill)


/// Proc to append behavior to the condition of being handsblocked. Called when the condition starts.
/mob/living/proc/on_handsblocked_start()
	drop_from_hands()
	stop_pulling()
	add_traits(list(TRAIT_UI_BLOCKED, TRAIT_PULL_BLOCKED), TRAIT_HANDS_BLOCKED)


/// Proc to append behavior to the condition of being handsblocked. Called when the condition ends.
/mob/living/proc/on_handsblocked_end()
	remove_traits(list(TRAIT_UI_BLOCKED, TRAIT_PULL_BLOCKED), TRAIT_HANDS_BLOCKED)


/**
 * Changes the inclination angle of a mob, used by humans and others to differentiate between standing up and prone positions.
 *
 * In BYOND-angles 0 is NORTH, 90 is EAST, 180 is SOUTH and 270 is WEST.
 * This usually means that 0 is standing up, 90 and 270 are horizontal positions to right and left respectively, and 180 is upside-down.
 * Mobs that do now follow these conventions due to unusual sprites should require a special handling or redefinition of this proc, due to the density and layer changes.
 * The return of this proc is the previous value of the modified lying_angle if a change was successful (might include zero), or null if no change was made.
 */
/mob/living/proc/set_lying_angle(new_lying)
	if(new_lying == lying_angle)
		return
	. = lying_angle
	lying_angle = new_lying
	if(lying_angle != lying_prev)
		update_transform()
		lying_prev = lying_angle
		pulledby?.set_pull_offsets(src, pulledby.grab_state)


/// Changes the value of the [living/body_position] variable. Call this before set_lying_angle()
/mob/living/proc/set_body_position(new_value)
	if(body_position == new_value)
		return
	if((new_value == LYING_DOWN) && !(mobility_flags & MOBILITY_LIEDOWN))
		return
	. = body_position
	body_position = new_value
	SEND_SIGNAL(src, COMSIG_LIVING_SET_BODY_POSITION, new_value, .)
	if(new_value == LYING_DOWN) // From standing to lying down.
		on_lying_down()
	else // From lying down to standing up.
		on_standing_up()


/// Proc to append behavior to the condition of being floored. Called when the condition starts.
/mob/living/proc/on_floored_start()
	if(body_position == STANDING_UP) //force them on the ground
		on_fall()
		set_body_position(LYING_DOWN)


/// Proc to append behavior to the condition of being floored. Called when the condition ends.
/mob/living/proc/on_floored_end()
	if(!resting)
		get_up()


/// Proc to append behavior related to lying down.
/mob/living/proc/on_lying_down(new_lying_angle)
	update_layer()
	add_traits(list(TRAIT_UI_BLOCKED, TRAIT_PULL_BLOCKED, TRAIT_UNDENSE), LYING_DOWN_TRAIT)
	if(HAS_TRAIT(src, TRAIT_FLOORED) && !(dir & (NORTH|SOUTH)))
		setDir(pick(NORTH, SOUTH)) // We are and look helpless.
	if(rotate_on_lying)
		body_position_pixel_y_offset = PIXEL_Y_OFFSET_LYING
	if(!buckled || buckled.buckle_lying == NO_BUCKLE_LYING)
		lying_angle_on_lying_down(new_lying_angle)


/// Special interaction on lying down, to transform its sprite by a rotation. Used on carbon level.
/mob/living/proc/lying_angle_on_lying_down(new_lying_angle)
	return


/// Proc to append behavior related to lying down.
/mob/living/proc/on_standing_up()
	update_layer()
	remove_traits(list(TRAIT_UI_BLOCKED, TRAIT_PULL_BLOCKED, TRAIT_UNDENSE), LYING_DOWN_TRAIT)
	// Make sure it doesn't go out of the southern bounds of the tile when standing.
	body_position_pixel_y_offset = get_pixel_y_offset_standing(current_size)
	set_lying_angle(0)


/// Returns what the body_position_pixel_y_offset should be if the current size were `value`
/mob/living/proc/get_pixel_y_offset_standing(value)
	var/icon/living_icon = icon(icon)
	var/height = living_icon.Height()
	return (value-1) * height * 0.5


/mob/living/proc/toggle_resting()
	set name = "Rest"
	set category = "IC"

	set_resting(!resting, silent = FALSE)


///Proc to hook behavior to the change of value in the resting variable.
/mob/living/proc/set_resting(new_resting, silent = TRUE, instant = FALSE)
	if(!(mobility_flags & MOBILITY_REST))
		return
	if(new_resting == resting)
		return

	. = resting
	resting = new_resting
	if(new_resting)
		if(body_position == LYING_DOWN)
			if(!silent)
				to_chat(src, span_notice("You will now try to stay lying down on the floor."))
		else if(HAS_TRAIT(src, TRAIT_FORCED_STANDING) || (buckled && buckled.buckle_lying != NO_BUCKLE_LYING))
			if(!silent)
				to_chat(src, span_notice("You will now lay down as soon as you are able to."))
		else
			if(!silent)
				to_chat(src, span_notice("You lay down."))
			set_lying_on_rest(instant)
	else
		if(body_position == STANDING_UP)
			if(!silent)
				to_chat(src, span_notice("You will now try to remain standing up."))
		else if(HAS_TRAIT(src, TRAIT_FLOORED) || (buckled && buckled.buckle_lying != NO_BUCKLE_LYING))
			if(!silent)
				to_chat(src, span_notice("You will now stand up as soon as you are able to."))
		else
			if(!silent)
				to_chat(src, span_notice("You stand up."))
			get_up(instant)

	SEND_SIGNAL(src, COMSIG_LIVING_RESTING, new_resting, silent, instant)
	update_resting()


/// Proc to append and redefine behavior to the change of the [/mob/living/var/resting] variable.
/mob/living/proc/update_resting()
	//update_rest_hud_icon()


/// Change the [body_position] to [LYING_DOWN] and update associated behavior.
/mob/living/proc/set_lying_on_rest(instant = FALSE)
	set waitfor = FALSE

	if(!instant && !do_after(src, 1 SECONDS, src, DA_IGNORE_USER_LOC_CHANGE|DA_IGNORE_HELD_ITEM|DA_IGNORE_RESTRAINED, extra_checks = CALLBACK(src, TYPE_PROC_REF(/mob/living, lying_down_checks_callback)), interaction_key = DOAFTER_SOURCE_LYING_DOWN, max_interact_count = 1))
		return
	if(!lying_down_checks_callback())
		return

	set_body_position(LYING_DOWN)
	post_lying_on_rest()


/// Any post effects like icons changes place here
/mob/living/proc/post_lying_on_rest()
	return


/mob/living/proc/lying_down_checks_callback()
	if(!resting || body_position == LYING_DOWN || HAS_TRAIT(src, TRAIT_FORCED_STANDING) || (buckled && buckled.buckle_lying != NO_BUCKLE_LYING))
		return FALSE
	return TRUE


/// Change the [body_position] to [STANDING_UP] and update associated behavior.
/mob/living/proc/get_up(instant = FALSE)
	set waitfor = FALSE

	if(!instant && !do_after(src, 1 SECONDS, src, DA_IGNORE_USER_LOC_CHANGE|DA_IGNORE_LYING|DA_IGNORE_HELD_ITEM|DA_IGNORE_RESTRAINED, extra_checks = CALLBACK(src, TYPE_PROC_REF(/mob/living, get_up_checks_callback)), interaction_key = DOAFTER_SOURCE_GETTING_UP, max_interact_count = 1))
		return
	if(!get_up_checks_callback())
		return
	set_body_position(STANDING_UP)
	post_get_up()


/// Any post effects like icons changes place here
/mob/living/proc/post_get_up()
	return


/mob/living/proc/get_up_checks_callback()
	if(resting || body_position == STANDING_UP || HAS_TRAIT(src, TRAIT_FLOORED) || (buckled && buckled.buckle_lying != NO_BUCKLE_LYING))
		return FALSE
	return TRUE


/// Called when mob changes from a standing position into a prone while lacking the ability to stand up at the moment.
/mob/living/proc/on_fall()
	return


/mob/living/set_stat(new_stat)
	. = ..()
	if(isnull(.))
		return .

	switch(.) //Previous stat.
		if(CONSCIOUS)
			if(stat >= UNCONSCIOUS)
				ADD_TRAIT(src, TRAIT_IMMOBILIZED, TRAIT_KNOCKEDOUT)
			add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_INCAPACITATED, TRAIT_FLOORED), STAT_TRAIT)
			set_typing_indicator(FALSE)
			update_sight()
			update_blind_effects()
			update_blurry_effects()
			update_unconscious_overlay()
		if(UNCONSCIOUS)
			update_sight()
			update_blind_effects()
			update_blurry_effects()
			update_unconscious_overlay()
		if(DEAD)
			update_sight()
			update_blind_effects()
			update_blurry_effects()
			update_unconscious_overlay()
			GLOB.alive_mob_list += src
			GLOB.dead_mob_list -= src

	switch(stat) //Current stat.
		if(CONSCIOUS)
			if(. >= UNCONSCIOUS)
				REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, TRAIT_KNOCKEDOUT)
			remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_INCAPACITATED, TRAIT_FLOORED), STAT_TRAIT)
		if(DEAD)
			SetDizzy(0)
			SetJitter(0)
			SetLoseBreath(0)
			SetDisgust(0)
			SetEyeBlurry(0)
			GLOB.alive_mob_list -= src
			GLOB.dead_mob_list += src


/// Updates hands HUD element.
/mob/living/proc/update_hands_HUD()
	if(!hud_used)
		return
	for(var/atom/movable/screen/inventory/hand/hand_box as anything in hud_used.hand_slots)
		hand_box.update_icon(UPDATE_OVERLAYS)


/// Gets movable in currently active hand.
/mob/living/proc/get_active_pull_hand(skip_handless_pull = TRUE)
	if(!pulling || isnull(pull_hand))
		return null
	if(!skip_handless_pull && pull_hand == PULL_WITHOUT_HANDS)
		return pulling
	if(pull_hand == hand)
		return pulling
	return null


/// Gets movable in currently inactive hand.
/mob/living/proc/get_inactive_pull_hand(skip_handless_pull = TRUE)
	if(!pulling || isnull(pull_hand))
		return null
	if(!skip_handless_pull && pull_hand == PULL_WITHOUT_HANDS)
		return pulling
	if(pull_hand != hand)
		return pulling
	return null


/// Proc used to correctly update current layer for living mobs.
/mob/living/proc/update_layer()
	if(pulledby && loc == pulledby.loc)
		layer = (pulledby.dir & NORTH) ? pulledby.layer - 0.001 : pulledby.layer + 0.001
		return
	layer = (body_position == LYING_DOWN) ? LYING_MOB_LAYER : initial(layer)


/**
 * Updates mob's SSD status with all the necessaey checks.
 *
 * Arguments:
 * * enable (boolean) - `TRUE` to set SSD status, `FALSE` to remove.
 *
 * Returns `TRUE` on success, `FALSE` otherwise.
 */
/mob/living/proc/set_SSD(enable)
	if(!mind || !last_known_ckey)	// mindless / non player mobs are skipped
		return FALSE

	if(enable)
		if(stat == DEAD)	// dead mobs are skipped, unless we are removing SSD status
			return FALSE
		if(!mind.active || (ckey && ckey[1] == "@")) 	// aghosting will do this, we want to avoid SSDing admemes
			return FALSE
		if(!isnull(player_logged))	// already in SSD, return TRUE and we are done
			return TRUE
		// this causes instant sleep and tags a player as SSD. See [/proc/handle_SSD()] for furthering SSD
		player_logged = 0
		Sleeping(4 SECONDS)
		. = TRUE
	else
		if(isnull(player_logged))	// SSD status is removed already, return TRUE and we are done
			return TRUE
		player_logged = null
		. = TRUE

	update_ssd_overlay()	// special SSD overlay handling

/mob/living/verb/succumb()
	set hidden = TRUE
	// if you use the verb you better mean it
	do_succumb(FALSE)

/mob/living/proc/do_succumb(cancel_on_no_words)
	if(stat == DEAD)
		to_chat(src, span_notice("It's too late, you're already dead!"))
		return
	if(health >= HEALTH_THRESHOLD_CRIT)
		to_chat(src, span_warning("You are unable to succumb to death! This life continues!"))
		return

	last_words = null // In case we kept some from last time
	var/final_words = tgui_input_text(src, "Do you have any last words?", "Goodnight, Sweet Prince", encode = FALSE)

	if(isnull(final_words) && cancel_on_no_words)
		to_chat(src, span_notice("You decide you aren't quite ready to die."))
		return

	if(stat == DEAD)
		return

	if(health >= HEALTH_THRESHOLD_CRIT)
		to_chat(src, span_warning("You are unable to succumb to death! This life continues!"))
		return

	if(!isnull(final_words))
		last_words = final_words
		whisper(final_words)

	create_log(MISC_LOG, "has succumbed to death with [round(health, 0.1)] points of health")
	adjustOxyLoss(max(health - HEALTH_THRESHOLD_DEAD, 0))
	// super check for weird mobs, including ones that adjust hp
	// we don't want to go overboard and gib them, though
	for(var/i in 1 to 5)
		if(health < HEALTH_THRESHOLD_DEAD)
			break
		take_overall_damage(max(5, health - HEALTH_THRESHOLD_DEAD), 0)

	if(!isnull(final_words))
		addtimer(CALLBACK(src, PROC_REF(death)), 1 SECONDS)
	else
		death()
	to_chat(src, span_notice("You have given up life and succumbed to death."))
	apply_status_effect(STATUS_EFFECT_RECENTLY_SUCCUMBED)

/// Updates damage slowdown accordingly to the current health
/mob/living/proc/update_movespeed_damage_modifiers()
	return

