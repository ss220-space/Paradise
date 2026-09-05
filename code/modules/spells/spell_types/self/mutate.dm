/datum/action/cooldown/spell/mutate
	name = "Mutate"
	desc = "This spell causes you to turn into a hulk and gain laser vision for a short while."

	school = "transmutation"
	cooldown_time = 40 SECONDS
	cooldown_reduction_per_rank = 2.5 SECONDS
	invocation = "BIRUZ BENNAR"
	invocation_type = INVOCATION_SHOUT

	button_icon_state = "mutate"
	sound = 'sound/magic/mutate.ogg'

/datum/action/cooldown/spell/mutate/cast(atom/cast_on)
	.=..()
	if(!ishuman(cast_on))
		return
	var/mob/living/carbon/human/target = cast_on
	if(!target.dna)
		to_chat(target, span_warning("У вас нет ДНК, вы не можете мутировать!"))
		return

	target.apply_status_effect(STATUS_EFFECT_MUTATION)

/datum/action/cooldown/spell/mutate/Remove(mob/living/remove_from)
	. = ..()
	remove_from.remove_status_effect(STATUS_EFFECT_MUTATION)

/datum/status_effect/mutation
	id = "mutation"
	alert_type = /atom/movable/screen/alert/status_effect/mutation
	on_remove_on_mob_delete = TRUE
	duration = 30 SECONDS
	var/mob/living/carbon/human/mutated

/datum/status_effect/mutation/on_apply()
	mutated = owner
	mutated.force_gene_block(GLOB.hulkblock, TRUE)
	ADD_TRAIT(mutated, TRAIT_LASEREYES, TRAIT_STATUS_EFFECT(id))
	mutated.regenerate_icons()
	to_chat(mutated, span_notice_alt("You feel strong! You feel a pressure building behind your eyes!"))
	return TRUE

/datum/status_effect/mutation/on_remove()
	mutated.force_gene_block(GLOB.hulkblock, FALSE)
	REMOVE_TRAIT(mutated, TRAIT_LASEREYES, TRAIT_STATUS_EFFECT(id))
	mutated.regenerate_icons()

/atom/movable/screen/alert/status_effect/mutation
	name = "Мутация"
	desc = "Вы можете стать халком и стрелять лазерами из глаз!"
	icon_state = "mutation"
