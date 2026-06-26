/datum/action/cooldown/spell/pointed/dark_conversion
	name = "Теневое искажение"
	desc = "Превращает гуманоида в тенечеловека и искажает его восприятие реальности."

	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "horror"
	cast_range = 5
	cooldown_time = 300 SECONDS
	var/cast_time = 5 SECONDS
	var/fail_cooldown = 5 SECONDS
	var/say_name_prob = 40
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

/datum/action/cooldown/spell/pointed/dark_conversion/create_new_handler()
	var/datum/spell_handler/devil/devil = new
	return devil

/datum/action/cooldown/spell/pointed/dark_conversion/is_valid_target(atom/cast_on)
	. = ..()
	if(!ishuman(cast_on))
		return FALSE
	var/mob/living/carbon/human/target = cast_on
	return target.mind && !isshadowperson(target)

/datum/action/cooldown/spell/pointed/dark_conversion/cast(atom/cast_on)
	. = ..()
	cooldown_time = initial(cooldown_time)
	var/mob/living/carbon/human/human = cast_on
	var/mob/living/carbon/carbon = owner
	var/datum/antagonist/devil/devil = carbon.mind?.has_antag_datum(/datum/antagonist/devil)

	if(prob(say_name_prob))
		carbon.say("INF' [devil.info.truename] NO")
	playsound(get_turf(carbon), 'sound/magic/narsie_attack.ogg', 100, TRUE)
	human.Knockdown(1 SECONDS)

	if(!do_after(carbon, cast_time, carbon, NONE))
		cooldown_time = fail_cooldown
		return

	make_shadow(human, devil)

/datum/objective/assassinate/shadow_kill
	antag_menu_name = "Убить по воле проклятия"

/datum/action/cooldown/spell/pointed/dark_conversion/proc/make_shadow(mob/living/carbon/human/human, datum/antagonist/devil/devil)
	human.set_species(/datum/species/shadow)
	var/text = "Вы — создание тьмы. Старайтесь сохранить свою истинную форму и выполнить свои цели."
	human.store_memory(text, TRUE)
	to_chat(human, custom_boxed_message("red_box center", text))
