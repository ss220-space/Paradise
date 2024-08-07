/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanite swarm"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	icon = 'icons/obj/nanopaste.dmi'
	icon_state = "tube"
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=2;engineering=3"
	amount = 6
	max_amount = 6
	toolspeed = 1


/obj/item/stack/nanopaste/cyborg
	is_cyborg = TRUE


/obj/item/stack/nanopaste/cyborg/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!get_amount())
		to_chat(user, span_danger("Not enough nanopaste!"))
		return ATTACK_CHAIN_PROCEED
	return ..()


/obj/item/stack/nanopaste/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(isrobot(target))	//Repairing cyborgs
		var/mob/living/silicon/robot/robot = target
		if(!robot.getBruteLoss() && !robot.getFireLoss() && !LAZYLEN(robot.diseases))
			to_chat(user, span_notice("All [robot]'s systems are nominal."))
			return .
		if(!use(1))
			return .
		robot.heal_overall_damage(15, 15)
		robot.CureAllDiseases(FALSE)
		user.visible_message(
			span_notice("[user] applied some [src] at [robot]'s damaged areas."),
			span_notice("You apply some [src] at [robot]'s damaged areas."),
		)
		return .|ATTACK_CHAIN_SUCCESS

	if(ismachineperson(target) && LAZYLEN(target.diseases) && use(1))
		target.CureAllDiseases()
		user.visible_message(
			span_notice("[user] applies some nanite paste at [target]."),
			span_notice("You have applied some nanite paste at [target].")
		)
		return .|ATTACK_CHAIN_SUCCESS

	if(!ishuman(target)) //Repairing robotic limbs and IPCs
		return .

	var/mob/living/carbon/human/human_target = target
	var/obj/item/organ/external/bodypart = human_target.get_organ(user.zone_selected)
	if(!bodypart || !bodypart.is_robotic())
		to_chat(user, span_notice("The [name] won't work on that."))
		return .

	if(!bodypart.get_damage())
		to_chat(user, span_notice("Nothing to fix here."))
		return .

	if(!use(1))
		return .

	. |= ATTACK_CHAIN_SUCCESS

	var/remheal = 15
	var/nremheal = 0
	var/list/childlist
	if(LAZYLEN(bodypart.children))
		childlist = bodypart.children.Copy()
	var/parenthealed = FALSE
	var/should_update_health = FALSE
	var/update_damage_icon = NONE
	while(remheal > 0)
		var/obj/item/organ/external/current_bodypart
		if(bodypart.get_damage())
			current_bodypart = bodypart
		else if(LAZYLEN(childlist))
			current_bodypart = pick_n_take(childlist)
			if(!current_bodypart.get_damage() || !current_bodypart.is_robotic())
				continue
		else if(bodypart.parent && !parenthealed)
			current_bodypart = bodypart.parent
			parenthealed = TRUE
			if(!current_bodypart.get_damage() || !current_bodypart.is_robotic())
				break
		else
			break
		nremheal = max(remheal - current_bodypart.get_damage(), 0)
		var/brute_was = current_bodypart.brute_dam
		var/burn_was = current_bodypart.burn_dam
		update_damage_icon |= current_bodypart.heal_damage(remheal, remheal, FALSE, TRUE, FALSE)
		if(current_bodypart.brute_dam != brute_was || current_bodypart.burn_dam != burn_was)
			should_update_health = TRUE
		remheal = nremheal

	if(should_update_health)
		human_target.updatehealth("nanopaste repair")
	if(update_damage_icon)
		human_target.UpdateDamageIcon()

	user.visible_message(
		span_notice("[user] applies some nanite paste at [human_target]."),
		span_notice("You have applied some nanite paste at [human_target].")
	)

	if(human_target.bleed_rate && ismachineperson(human_target))
		human_target.bleed_rate = 0

