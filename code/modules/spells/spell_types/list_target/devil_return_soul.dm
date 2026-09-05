/datum/action/cooldown/spell/list_target/return_soul
	name = "Вернуть душу"
	desc = "Это заклинание возвращает душу выбраному существу."
	choose_target_message = "Кому вы хотите вернуть душу?"
	invocation_type = INVOCATION_WHISPER
	invocation = "Et resuscita me; et retribuam eis!"

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	school = SCHOOL_CONJURATION
	cooldown_time = 5 SECONDS
	var/datum/antagonist/devil/devil
	background_icon_state = "bg_demon"

/datum/action/cooldown/spell/list_target/return_soul/Grant(mob/grant_to)
	. = ..()
	devil = owner.mind?.has_antag_datum(/datum/antagonist/devil)

/datum/action/cooldown/spell/list_target/return_soul/get_list_targets(atom/center, target_radius)
	var/list/mobs
	for(var/datum/mind/mind in devil.soulsOwned - devil.ritualSouls)
		if(!mind.current)
			continue
		LAZYADDASSOC(mobs, mind.current.real_name, mind)
	return mobs

/datum/action/cooldown/spell/list_target/return_soul/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/target = cast_on
	ADD_TRAIT(target.mind, TRAIT_BAD_SOUL, DEVIL_CONTRACT_TRAIT)
	devil.remove_soul(target.mind)
