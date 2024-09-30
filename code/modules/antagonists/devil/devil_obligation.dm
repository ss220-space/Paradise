/datum/devil_obligation
    var/name

    var/desc
    var/law

    var/mob/living/carbon/owner
    var/datum/antagonist/devil/devil

    var/list/obligation_spells

/datum/devil_obligation/proc/link_obligation(mob/living/carbon/carbon)
    owner = carbon
    devil = carbon.mind?.has_antag_datum(/datum/antagonist/devil)

/datum/devil_obligation/proc/remove_obligation()
    remove_obligation_effect()

    owner = null
    devil = null

/datum/devil_obligation/Destroy(force)
    remove_obligation()

    return ..()

/datum/devil_obligation/proc/give_spells()
	for(var/obj/effect/proc_holder/spell/spell as anything in obligation_spells)
		owner.mind?.AddSpell(spell)

/datum/devil_obligation/proc/remove_spells()
	for(var/obj/effect/proc_holder/spell/spell as anything in owner.mind?.spell_list)
		if(!is_type_in_list(spell, obligation_spells))
			continue

		owner.mind?.RemoveSpell(spell)

/datum/devil_obligation/proc/apply_obligation_effect()
    return

/datum/devil_obligation/proc/remove_obligation_effect()
    return

/datum/devil_obligation/food
	name = OBLIGATION_FOOD

	desc = "This devil seems to always offer its victims food before slaughtering them."
	law = "When not acting in self defense, you must always offer your victim food before harming them."

	obligation_spells = list(/obj/effect/proc_holder/spell/conjure_item/violin)

/datum/devil_obligation/fiddle
	name = OBLIGATION_FIDDLE

	desc = "This devil will never turn down a musical challenge."
	law = "When not in immediate danger, if you are challenged to a musical duel, you must accept it.  You are not obligated to duel the same person twice."

/datum/devil_obligation/danceoff
	name = OBLIGATION_DANCEOFF

	desc = "This devil will never turn down a dance off."
	law = "When not in immediate danger, if you are challenged to a dance off, you must accept it. You are not obligated to face off with the same person twice."

	obligation_spells = list(/obj/effect/proc_holder/spell/summon_dancefloor)

/datum/devil_obligation/greet
	name = OBLIGATION_GREET

	desc = "This devil seems to only be able to converse with people it knows the name of."
	law = "You must always greet other people by their last name before talking with them."

/datum/devil_obligation/presenceknown
	name = OBLIGATION_PRESENCEKNOWN

	desc = "This devil seems to be unable to attack from stealth."
	law = "You must always make your presence known before attacking."

/datum/devil_obligation/sayname
	name = OBLIGATION_SAYNAME

	desc = "He will always chant his name upon killing someone."
	law = "You must always say your true name after you kill someone."

/datum/devil_obligation/announcekill
	name = OBLIGATION_ANNOUNCEKILL

	desc = "This devil always loudly announces his kills for the world to hear."
	law = "Upon killing someone, you must make your deed known to all within earshot, over comms if reasonably possible."

/datum/devil_obligation/answertotruename
	name = OBLIGATION_ANSWERTONAME

	desc = "This devil always responds to his truename."
	law = "If you are not under attack, you must always respond to your true name."
