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

	desc = "Этот дьявол всегда предлагает его жертвам еду, прежде чем убивает их."
	law = "Пока вы не самообороняетесь, вы должны предлагать вашим жертвам еду, прежде чем вредить им."

	obligation_spells = list(/obj/effect/proc_holder/spell/conjure_item/violin)

/datum/devil_obligation/fiddle
	name = OBLIGATION_FIDDLE

	desc = "Этот дьявол никогда не откажется от музыкального поединка"
	law = "Пока вы не находитесь в опасности, при предложении музыкального поединка, то вы обязаны его принять."

/datum/devil_obligation/danceoff
	name = OBLIGATION_DANCEOFF

	desc = "Этот дьявол никогда не откажется от танцевального поединка."
	law = "Когда вам ничего не угрожает и вас вызвали на танцевальный поединок, то вы обязаны его принять."

	obligation_spells = list(/obj/effect/proc_holder/spell/summon_dancefloor)

/datum/devil_obligation/greet
	name = OBLIGATION_GREET

	desc = "Этот дьявол, похоже, может общаться только с теми, чьи имена он знает."
	law = "Вы должны всегда здороваться с людьми, называя их по фамилии, прежде чем заговорить с ними."

/datum/devil_obligation/presenceknown
	name = OBLIGATION_PRESENCEKNOWN

	desc = "Этот дьявол, похоже, не может нападать из-за укрытия."
	law = "Вы должны всегда заявлять о своем присутствии перед атакой."

/datum/devil_obligation/sayname
	name = OBLIGATION_SAYNAME

	desc = "Он всегда произносит свое имя, убивая кого-либо."
	law = "Вы должны всегда произносить свое истинное имя после того, как убьете кого-либо."

/datum/devil_obligation/announcekill
	name = OBLIGATION_ANNOUNCEKILL

	desc = "Этот дьявол всегда громко объявляет о своих убийствах, чтобы это услышал весь мир."
	law = "Убив кого-либо, вы должны известить всех в пределах слышимости о своем поступке, через связь, если это возможно."

/datum/devil_obligation/answertotruename
	name = OBLIGATION_ANSWERTONAME

	desc = "Этот дьявол всегда отвечает на свое истинное имя."
	law = "Если на вас не нападают, вы должны всегда откликаться на свое истинное имя."
