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

	desc = "Этот дьявол, похоже, предпочитает охотиться на мужчин."
	law = "Никогда не причиняйте вреда существам женского пола, за исключением случаев самообороны."

/datum/devil_ban/chapel
	name = BAN_CHAPEL

	desc = "Этот дьявол избегает святой земли."
	law = "Никогда не пытайтесь войти в церковь."

/datum/devil_ban/hurtpriest
	name = BAN_HURTPRIEST

	desc = "Помазанное духовенство, похоже, невосприимчиво к его силам."
	law = "Никогда не нападайте на священника."

/datum/devil_ban/avoidwater
	name = BAN_AVOIDWATER

	desc = "Дьявол, похоже, испытывает какое-то отвращение к воде, хотя она, по-видимому, не причиняет ему вреда."
	law = "Никогда не следует намеренно прикасаться к мокрой поверхности."

/datum/devil_ban/strikeunconscious
	name = BAN_STRIKEUNCONCIOUS

	desc = "Этот дьявол проявляет интерес только к тем, кто бодрствует."
	law = "Никогда не бейте существо, находящееся без сознания."

/datum/devil_ban/hurtlizard
	name = BAN_HURTLIZARD

	desc = "Этот дьявол не станет атаковать ящеров первым."
	law = "Никогда не причиняйте вред ящерам, за исключением случаев самообороны."

/datum/devil_ban/hurtanimal
	name = BAN_HURTANIMAL

	desc = "Этот дьявол избегает причинения вреда животным."
	law = "Никогда не причиняйте вред неразумным существам или роботам, за исключением случаев самообороны."
