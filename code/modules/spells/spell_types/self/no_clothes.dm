/datum/action/cooldown/spell/no_clothes
	name = "No Clothes"
	desc = "This always-on spell allows you to cast magic without your garments."
	button_icon_state = "no_clothes"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

/datum/action/cooldown/spell/no_clothes/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/no_clothes/cast(atom/cast_on)
	. = ..()
	var/mob/living/caster = cast_on
	to_chat(caster, span_notice("Вы активировали заклинание, отныне вам не нужна одежда для использования заклинаний!"))
	ADD_TRAIT(caster.mind, TRAIT_NO_WIZARD_CLOTHES, MAGIC_TRAIT)
	qdel(src)
