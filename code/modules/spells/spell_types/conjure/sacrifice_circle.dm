/datum/action/cooldown/spell/conjure/sacrifice_circle
	name = "Создать жертвенный круг"
	desc = "Создает руну для жертвоприношений и ритуалов."

	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "sintouch"
	summon_type = /obj/effect/decal/cleanable/devil
	cooldown_time = 100 SECONDS
	create_summon_timer = 5 SECONDS
	summon_radius = 0
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

/datum/action/cooldown/spell/conjure/sacrifice_circle/create_new_handler()
	var/datum/spell_handler/devil/devil = new
	return devil

/datum/action/cooldown/spell/conjure/sacrifice_circle/post_summon(atom/summoned_object, atom/cast_on)
	. = ..()
	var/mob/living/carbon/carbon = cast_on
	var/datum/antagonist/devil/devil = carbon.mind?.has_antag_datum(/datum/antagonist/devil)
	var/obj/effect/decal/cleanable/devil/devil_rune = summoned_object

	devil_rune.AddComponent( \
		/datum/component/ritual_object, \
		allowed_categories = /datum/ritual/devil, \
		allowed_special_role = list(ROLE_DEVIL), \
	)

	devil_rune.devil = devil
	devil_rune.update_appearance(UPDATE_DESC)
