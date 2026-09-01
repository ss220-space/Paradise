/datum/action/cooldown/spell/forcewall
	name = "Force Wall"
	desc = "This spell creates a small unbreakable wall that only you can pass through, and does not need wizard garb. Lasts 30 seconds."
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 10 SECONDS
	cooldown_reduction_per_rank = 1.2 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "TARCOL MINTI ZHERI"
	invocation_type = INVOCATION_WHISPER
	sound = 'sound/magic/forcewall.ogg'
	button_icon_state = "shield"
	var/wall_type = /obj/effect/forcefield/wizard

/datum/action/cooldown/spell/forcewall/cast(atom/cast_on)
	. = ..()
	new wall_type(get_turf(cast_on), cast_on)

/datum/action/cooldown/spell/forcewall/greater
	name = "Greater Force Wall"
	desc = "Create a larger magical barrier that only you can pass through, but requires wizard garb. Lasts 30 seconds."
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_WIZARD_GARB
	invocation = "TARCOL GRANDI ZHERI"
	invocation_type = INVOCATION_SHOUT
	button_icon_state = "shield_greater"

/datum/action/cooldown/spell/forcewall/greater/cast(atom/cast_on)
	. = ..()
	new wall_type(get_step(cast_on, turn(cast_on.dir, 90)), cast_on) //Extra THICK
	new wall_type(get_step(cast_on, turn(cast_on.dir, 270)), cast_on)

/datum/action/cooldown/spell/forcewall/greater/mime
	name = "Великая Невидимая стена"
	desc = "Создайте перед собой невидимую стену шириной в три тайла."
	school = SCHOOL_MIME
	spell_requirements = NONE
	wall_type = /obj/effect/forcefield/mime/advanced
	cooldown_time = 60 SECONDS
	sound =  null
	invocation = ""
	invocation_type = INVOCATION_EMOTE
	button_icon_state = "mime_bigwall"
	background_icon_state = "bg_mime"

/datum/action/cooldown/spell/forcewall/greater/mime/can_cast_spell(feedback)
	if(!HAS_MIND_TRAIT(owner, TRAIT_MIMING))
		if(feedback)
			to_chat(owner, span_warning("Сначала вы должны принять обет молчания!"))
		return FALSE
	return ..()

/datum/action/cooldown/spell/forcewall/greater/mime/cast(atom/cast_on)
	. = ..()
	var/mob/caster = cast_on
	cast_on.visible_message("<b>[caster]</b> выглядит так, как будто бы перед н[GEND_IM_EI_IM_IMI(caster)] находится стена.")

/datum/action/cooldown/spell/forcewall/mime
	name = "Невидимая стена"
	desc = "Мимическая постановка становится осязаемой."
	school = SCHOOL_MIME
	wall_type = /obj/effect/forcefield/mime
	spell_requirements = NONE
	cooldown_time = 30 SECONDS
	sound =  null
	invocation = ""
	invocation_type = INVOCATION_EMOTE
	button_icon_state = "mime"
	background_icon_state = "bg_mime"

/datum/action/cooldown/spell/forcewall/mime/can_cast_spell(feedback)
	if(!HAS_MIND_TRAIT(owner, TRAIT_MIMING))
		if(feedback)
			to_chat(owner, span_warning("Сначала вы должны принять обет молчания!"))
		return FALSE
	return ..()

/datum/action/cooldown/spell/forcewall/mime/cast(atom/cast_on)
	. = ..()
	var/mob/caster = cast_on
	cast_on.visible_message("<b>[caster]</b> выглядит так, как будто бы перед н[GEND_IM_EI_IM_IMI(caster)] находится стена.")
