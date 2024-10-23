/datum/devil_ban
    var/name
    
    var/desc
    var/law

    var/mob/living/carbon/owner
    var/datum/antagonist/devil/devil

/datum/devil_ban/proc/link_ban(mob/living/carbon/carbon)
    owner = carbon
    devil = carbon.mind?.has_antag_datum(/datum/antagonist/devil)

/datum/devil_ban/proc/remove_ban()
    remove_ban_effect()

    owner = null
    devil = null

/datum/devil_ban/Destroy(force)
    remove_ban()

    return ..()

/datum/devil_ban/proc/apply_ban_effect()
    return

/datum/devil_ban/proc/remove_ban_effect()
    return

/datum/devil_ban/hurtwoman
	name = BAN_HURTWOMAN
	
	desc = "This devil seems to prefer hunting men."
	law = "You must never harm a female outside of self defense."

/datum/devil_ban/chapel
	name = BAN_CHAPEL

	desc = "This devil avoids holy ground."
	law = "You must never attempt to enter the chapel."

/datum/devil_ban/hurtpriest
	name = BAN_HURTPRIEST

	desc = "The annointed clergy appear to be immune to his powers."
	law = "You must never attack a priest."

/datum/devil_ban/avoidwater
	name = BAN_AVOIDWATER

	desc = "The devil seems to have some sort of aversion to water, though it does not appear to harm him."
	law = "You must never willingly touch a wet surface."

/datum/devil_ban/strikeunconscious
	name = BAN_STRIKEUNCONCIOUS

	desc = "This devil only shows interest in those who are awake."
	law = "You must never strike an unconscious person."

/datum/devil_ban/hurtlizard
	name = BAN_HURTLIZARD

	desc = "This devil will not strike a lizardman first."
	law = "You must never harm a lizardman outside of self defense."

/datum/devil_ban/hurtanimal
	name = BAN_HURTANIMAL

	desc = "This devil avoids hurting animals."
	law = "You must never harm a non-sentient creature or robot outside of self defense."
