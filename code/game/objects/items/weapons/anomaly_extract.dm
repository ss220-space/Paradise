#define COOLDOWN_TO_SLIMEPERSON (10 SECONDS)
#define COOLDOWN_TO_SLIME_MOB (40 SECONDS)
/obj/item/anomaly_extract
	name = "Strange syringe"
	desc = "Syringe with a blunt needle."
	icon_state = "slime_extract1"
	item_state = "syringe_0"
	w_class = WEIGHT_CLASS_TINY
	var/used = FALSE

/obj/item/anomaly_extract/attack_self(mob/user)
	if(used)
		to_chat(user, span_notice("Looks like somebody already used it."))
		return FALSE

	if(!isslimeperson(user))
		to_chat(user, span_notice("Looks like your skin is too hard for this syringe."))
		return FALSE

	var/mob/living/carbon/human/attacker = user
	if(attacker.get_int_organ(/obj/item/organ/internal/heart/slime/anomaly))
		to_chat(user, span_notice("You already have the abilities that this extract can provide."))
		return FALSE

	var/obj/item/organ/internal/heart/slime/anomaly/H = new
	H.replaced(user)
	to_chat(user, span_warning("Something changes inside you. It feel SOO warm!"))
	used = TRUE
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/item/anomaly_extract/update_icon_state()
	icon_state = "slime_extract[used ? "0" : "1"]"

/obj/item/anomaly_extract/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(target == user && attack_self(user))
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ATTACK_CHAIN_PROCEED

/datum/action/cooldown/spell/slime_degradation
	name = "Slime degradation"
	desc = "Transform into anomaly slime and back!"
	button_icon_state = "slime_degradation"
	background_icon_state = "bg_default"
	sound = 'sound/effects/mob_effects/slime_squish.ogg'
	spell_requirements = NONE
	var/active_transform = FALSE
	var/is_transformed = FALSE
	var/mob/living/carbon/human/original_body

/datum/action/cooldown/spell/slime_degradation/Destroy()
	original_body = null
	return ..()

/datum/action/cooldown/spell/slime_degradation/can_cast_spell(feedback)
	var/mob/living/caster = owner
	if(!original_body && is_transformed)
		stack_trace("No original body in spell [src]!")
		return FALSE

	if(!caster.mind)
		return

	if(caster.incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB))
		if(feedback)
			to_chat(caster, span_warning("You can't use this ability right now!"))
		return FALSE

	if(ishuman(caster) && caster.health <= 0)
		if(feedback)
			to_chat(caster, span_warning("You are too weak to use this ability!"))
		return FALSE

	if(!isturf(caster.loc))
		if(feedback)
			to_chat(caster, span_warning("You can't use this ability inside [caster.loc]!"))
		return FALSE

	return ..()

/datum/action/cooldown/spell/slime_degradation/before_cast(atom/cast_on)
	. = ..()
	if(is_transformed)
		cooldown_time = COOLDOWN_TO_SLIME_MOB
	else
		cooldown_time = COOLDOWN_TO_SLIMEPERSON

/datum/action/cooldown/spell/slime_degradation/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/user = cast_on
	if(!is_transformed && istype(user))
		slime_transform(user)
	else if(is_transformed && original_body)
		slime_transform_back(user)

/datum/action/cooldown/spell/slime_degradation/proc/slime_transform(mob/living/carbon/human/user)
	if(active_transform)
		return
	active_transform = TRUE
	for(var/obj/item/check as anything in user.get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD))
		user.drop_item_ground(check, force = TRUE)

	user.underwear = "Nude"
	user.undershirt = "Nude"
	user.socks = "Nude"
	user.regenerate_icons()

	var/mob/living/simple_animal/slime/invalid/slimeme = new /mob/living/simple_animal/slime/invalid(user.loc, "red", new /datum/slime_age/adult, 1200,  user, src)

	user.visible_message(span_warning("[user] shape becomes fuzzy before it takes the [slimeme] form!"), \
						span_notice("You start to transform into the [slimeme]."), \
						span_notice("You hear something squishing..."))

	original_body = user
	original_body.add_traits(list(TRAIT_NO_TRANSFORM, TRAIT_GODMODE), UNIQUE_TRAIT_SOURCE(src))
	slimeme.add_traits(list(TRAIT_NO_TRANSFORM, TRAIT_GODMODE), UNIQUE_TRAIT_SOURCE(src))
	user.mind.transfer_to(slimeme)
	slimeme.update_sight()
	user.move_to_null_space()

	new /obj/effect/temp_visual/wizard(get_turf(slimeme))

	var/matrix/animation_matrix = new(slimeme.transform)
	slimeme.transform = matrix().Scale(0)
	animate(slimeme, time = 1 SECONDS, transform = animation_matrix, easing = CUBIC_EASING)

	sleep(1 SECONDS)

	if(QDELETED(src) || QDELETED(slimeme))
		return

	slimeme.remove_traits(list(TRAIT_NO_TRANSFORM, TRAIT_GODMODE), UNIQUE_TRAIT_SOURCE(src))
	is_transformed = TRUE
	active_transform = FALSE

/datum/action/cooldown/spell/slime_degradation/proc/slime_transform_back(mob/living/simple_animal/slime/invalid/user, death_provoked = FALSE)
	if(active_transform)
		return
	active_transform = TRUE
	var/self_message = death_provoked ? span_userdanger("You can't take the strain of sustaining [user]'s shape in this condition, it begins to fall apart!") : span_notice("You start to transform back into human.")
	user.visible_message(span_warning("[user] shape becomes fuzzy before it takes human form!"), self_message, span_notice("You hear something squishing..."))
	if(death_provoked)
		cooldown_time = COOLDOWN_TO_SLIME_MOB
		StartCooldown()
		playsound(get_turf(usr), sound, 50, TRUE)
	user.set_density(FALSE)
	original_body.dir = SOUTH
	original_body.forceMove(get_turf(user))
	user.mind.transfer_to(original_body)

	var/matrix/animation_matrix1 = new(user.transform)
	animation_matrix1.Scale(0)
	animate(user, time = 0.5 SECONDS, transform = animation_matrix1, easing = CUBIC_EASING)

	var/matrix/animation_matrix2 = new(original_body.transform)
	original_body.transform = matrix().Scale(0)
	animate(original_body, time = 1 SECONDS, transform = animation_matrix2, easing = CUBIC_EASING)

	sleep(1 SECONDS)

	if(!QDELETED(user))
		qdel(user)
	if(QDELETED(src) || QDELETED(original_body))
		stack_trace("Spell or original_body was qdeled during the [src] work.")
		return

	original_body.remove_traits(list(TRAIT_NO_TRANSFORM, TRAIT_GODMODE), UNIQUE_TRAIT_SOURCE(src))
	is_transformed = FALSE
	original_body = null
	active_transform = FALSE

/datum/action/cooldown/spell/slime_selfheat
	name = "Slime heat"
	desc = "Heats up your body a little."
	button_icon_state = "slime_selfheat"
	background_icon_state = "bg_default"
	sound = 'sound/goonstation/misc/fuse.ogg'
	spell_requirements = NONE
	cooldown_time = 30 SECONDS

/datum/action/cooldown/spell/slime_selfheat/can_cast_spell(feedback)
	var/mob/living/caster = owner
	if(!caster.mind)
		return

	if(caster.incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB))
		if(feedback)
			to_chat(caster, span_warning("You can't use this ability right now!"))
		return FALSE

	if(ishuman(caster) && caster.health <= 0)
		if(feedback)
			to_chat(caster, span_warning("You are too weak to use this ability!"))
		return FALSE

	if(!isturf(caster.loc))
		if(feedback)
			to_chat(caster, span_warning("You can't use this ability inside [caster.loc]!"))
		return FALSE

	return ..()

/datum/action/cooldown/spell/slime_selfheat/cast(atom/cast_on)
	. = ..()
	owner.adjust_bodytemperature(50)
	var/self_message = isslime(owner) ? span_notice("You feel nothing can stop you right now.") : span_userdanger("You feel HOT inside yourself.")
	to_chat(owner, self_message)

/obj/item/organ/internal/heart/slime/anomaly
	name = "anomaly slime heart"
	desc = "Anomaly core grow from thing which had to be slime heart"
	icon_state = "anomaly_heart"

/obj/item/organ/internal/heart/slime/anomaly/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	M.mind.AddSpell(new /datum/action/cooldown/spell/slime_degradation)
	M.mind.AddSpell(new /datum/action/cooldown/spell/slime_selfheat)

/obj/item/organ/internal/heart/slime/anomaly/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	M.mind.RemoveSpell(/datum/action/cooldown/spell/slime_degradation)
	M.mind.RemoveSpell(/datum/action/cooldown/spell/slime_selfheat)
	. = ..()

#undef COOLDOWN_TO_SLIMEPERSON
#undef COOLDOWN_TO_SLIME_MOB
