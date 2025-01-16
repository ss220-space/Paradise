#define DEFAULT_CHIP_SLOTS	1
#define UPGRADE_SLOTS_GREY 	2


	// TRANSLATORS //

// Translators also fulfil the role of ‘vocal cords’ when there is a TRAIT_NO_VOCAL_CORDS in species inherent traits.
// With translator any mob can speak even muted, unless being emped.
// ANY Duct tape forcing mob with translator to whisper and keeps it off the radio

/obj/item/organ/internal/cyberimp/mouth/translator // Lets make it some easier to make a new one. Write this if you want to make non-species translator.
	name = "Just An Empty Translator"  // You cant get it in-game. At least now
	desc = "Может быть, учёные NanoTrasen заставят работать его позже..."
	//icon =
	//icon_state =
	//origin_tech =
	slot = INTERNAL_ORGAN_SPEECH_TRANSLATOR
	w_class = WEIGHT_CLASS_TINY
	/// List of languages, stored in this translator
	var/list/datum/language/given_languages
	/// Russian list of languages, stored in this translator
	var/list/given_languages_rus
	/// What types of translator storage upgrades can be attached to this translator. Empty = nothing
	var/list/upgrade_with
	/// List of stored languages chips
	var/list/stored_chips
	/// You cant place anything without opening lid with screwriver
	var/open = FALSE
	/// Inactive translator don't give you any languages. Affects by EMP
	var/active = TRUE
	/// Slot for stored storage upgrade module
	var/obj/item/translator_upgrade/stored_upgrade
	/// Maximum basic slots for translator without storage upgrade
	var/maximum_slots = DEFAULT_CHIP_SLOTS
	/// Toggles by decoder action, allows you to speak clearly with Wingdings disability
	var/can_wingdings = FALSE

	action_icon = list(/datum/action/item_action/organ_action/translator_select_language = 'icons/mob/actions/actions.dmi',)
	action_icon_state = list(/datum/action/item_action/organ_action/translator_select_language = "select_language")
	actions_types = list(/datum/action/item_action/organ_action/translator_select_language)
	var/datum/action/item_action/organ_action/wingdings_decoder/decoder


/obj/item/organ/internal/cyberimp/mouth/translator/grey_retraslator
	name = "Psionic Voice Retranslator"
	desc = "Необычный инопланетный имплант с маленьким экранчиком. Судя по всему, создан специально для греев."
	ru_names = list(
		NOMINATIVE = "ретранслятор псионического голоса",
		GENITIVE = "ретранслятора псионического голоса",
		DATIVE = "ретранслятору псионического голоса",
		ACCUSATIVE = "ретранслятор псионического голоса",
		INSTRUMENTAL = "ретранслятором псионического голоса",
		PREPOSITIONAL = "ретрансляторе псионического голоса",
	)
	icon = 'icons/obj/voice_translator.dmi'
	icon_state = "pvr_implant"
	given_languages = list()
	upgrade_with = list(/obj/item/translator_upgrade/grey_retraslator)
	origin_tech = "materials=2;biotech=3;engineering=3;programming=3;abductor=2"
	species_restrictions = list(SPECIES_GREY, SPECIES_ABDUCTOR)


/obj/item/organ/internal/cyberimp/mouth/translator/New()
	if(!..())
		return

	if(!LAZYLEN(given_languages))
		return

	for(var/lang_name in given_languages)
		LAZYADD(given_languages, GLOB.all_languages[lang_name])

	return TRUE


/obj/item/organ/internal/cyberimp/mouth/translator/grey_retraslator/New()
	LAZYADD(given_languages, GLOB.all_languages[LANGUAGE_GALACTIC_COMMON]) // basic galcom for greys
	LAZYADD(given_languages_rus, "Общегалактический")

	. = ..()


/obj/item/organ/internal/cyberimp/mouth/translator/examine(mob/user)
	. = ..()
	if(!Adjacent(user)) // Too far!
		return

	var/message = (open ? "Крышка открыта. " : "Крышка закрыта. ")
	message += "Установленные языки: "
	message += english_list(given_languages_rus, nothing_text = "Отсутствуют", and_text = "и", final_comma_text = ".")
	. += span_notice(message)


/obj/item/organ/internal/cyberimp/mouth/translator/can_insert(mob/living/user, mob/living/carbon/target)
	if(!..())
		return FALSE

	if(!open)
		return TRUE

	if(user)
		balloon_alert(user, "крышка открыта!")

	return FALSE


/obj/item/organ/internal/cyberimp/mouth/translator/insert(mob/living/carbon/target, special)
	. = ..()

	RegisterSignal(target, COMSIG_LANG_PRE_ACT, PROC_REF(check_language))

	for(var/datum/language/lang as anything in given_languages)
		target.add_language(lang.name)


/obj/item/organ/internal/cyberimp/mouth/translator/remove(mob/living/carbon/target, special)
	if(!istype(target))
		return

	UnregisterSignal(target, COMSIG_LANG_PRE_ACT)

	for(var/datum/language/lang as anything in given_languages)
		target.remove_language(lang.name)

	. = ..()


/obj/item/organ/internal/cyberimp/mouth/translator/proc/check_language(mob/living/carbon/C, language_name)
	SIGNAL_HANDLER

	for(var/datum/language/lang as anything in given_languages)
		if(language_name == lang.name)
			return COMSIG_LANG_SECURED


/obj/item/organ/internal/cyberimp/mouth/translator/update_desc(updates)
	. = ..()

	if(stored_upgrade)
		desc += " Имеет установленный расширитель слотов."
	else
		desc = initial(desc)


/obj/item/organ/internal/cyberimp/mouth/translator/attackby(obj/item/I, mob/user, params)
	if((istype(I, /obj/item/translator_chip)))
		var/obj/item/translator_chip/chip = I
		return install_chip(user, chip, silent = FALSE)

	else if(istype(I, /obj/item/translator_upgrade))
		if(stored_upgrade)
			balloon_alert(user, "уже установлено!")
			return FALSE

		return install_upgrade(user, I)


/obj/item/organ/internal/cyberimp/mouth/translator/proc/install_upgrade(mob/living/carbon/human/user, obj/item/translator_upgrade/upgrade)
	if(!open)
		balloon_alert(user, "крышка закручена!")
		return

	if(!LAZYLEN(upgrade_with))
		balloon_alert(user, "не подлежит улучшению!")
		return

	if(!(upgrade.type in upgrade_with))
		balloon_alert(user, "несовместимо!")
		return

	balloon_alert(user, "установлено")
	maximum_slots += upgrade.extra_slots
	user.drop_transfer_item_to_loc(upgrade, src)
	stored_upgrade = upgrade
	update_appearance(UPDATE_DESC)


/obj/item/organ/internal/cyberimp/mouth/translator/attack_self(mob/user)
	if(!open)
		return FALSE

	if(!LAZYLEN(stored_chips))
		balloon_alert(user, "пусто!")
		return FALSE

	var/obj/item/translator_chip/chip
	if(LAZYLEN(stored_chips) == 1)
		chip = stored_chips[1]
	else
		var/list/chip_languages = list()
		for(var/obj/item/translator_chip/check_chip in stored_chips)
			chip_languages[check_chip.stored_language_rus] = check_chip

		chip = tgui_input_list(user, "Выберите, чип какого языка вы хотите достать:", "Извлечение чипа", chip_languages)
		chip = chip_languages[chip]

	if(!chip) // closed
		return FALSE

	remove_chip(user, chip)


/obj/item/organ/internal/cyberimp/mouth/translator/proc/remove_chip(mob/living/carbon/human/user, obj/item/translator_chip/chip)
	// user = who operates or who places the chip into translator
	// chip = translator chip we are removing
	if(!user || !chip)
		return FALSE

	if(owner && chip.stored_language) //if translator inside someone
		owner.remove_language(chip.stored_language.name)

	user.put_in_hands(chip)
	LAZYREMOVE(stored_chips, chip)

	if(chip.stored_language)
		LAZYREMOVE(given_languages, chip.stored_language)

	LAZYREMOVE(given_languages_rus, chip.stored_language_rus)
	chip.on_remove(owner, src)


/obj/item/organ/internal/cyberimp/mouth/translator/proc/install_chip(mob/living/carbon/human/user, obj/item/translator_chip/chip, silent = TRUE, ignore_lid = FALSE)
	if(!user || !chip)
		return FALSE

	if(!open && !ignore_lid) // Forced installation ignoring the closed lid. Used on after_equip chip installation
		if(!silent)
			balloon_alert(user, "крышка закрыта!")

		return FALSE

	if(LAZYLEN(stored_chips) >= maximum_slots)
		if(!silent)
			balloon_alert(user, "нет места под чип!")

		return FALSE

	if(!chip.stored_language_rus)
		if(!silent)
			balloon_alert(user, "чип пустой!")

		return FALSE

	if(chip.stored_language_rus in given_languages_rus)
		if(!silent)
			balloon_alert(user, "уже установлено!")

		return FALSE

	if(!silent)
		balloon_alert(user, "чип установлен")

	user.drop_transfer_item_to_loc(chip, src)
	LAZYADD(stored_chips, chip)

	if(chip.stored_language)
		LAZYADD(given_languages, chip.stored_language)

	LAZYADD(given_languages_rus, chip.stored_language_rus)

	if(owner && chip.stored_language)
		owner.add_language(chip.stored_language.name)

	chip.on_install(owner, src)

	return TRUE


/obj/item/organ/internal/cyberimp/mouth/translator/screwdriver_act(mob/living/user, obj/item/I)
	if(I.tool_behaviour != TOOL_SCREWDRIVER)
		return

	if(!(I.use_tool(src, user, 2 SECONDS, volume = 50)))
		return

	open = !open
	balloon_alert(user, "крышка [open ? "откручена" : "закручена"]")


/obj/item/organ/internal/cyberimp/mouth/translator/multitool_act(mob/living/user, obj/item/I)
	// you can remove an upgrade with multitool
	if(!open || (I.tool_behaviour != TOOL_MULTITOOL))
		return

	if(!(I.use_tool(src, user, 2 SECONDS, volume = 50)))
		return

	uninstall_upgrade(user)


/obj/item/organ/internal/cyberimp/mouth/translator/proc/uninstall_upgrade(mob/living/carbon/human/user)
	if(!stored_upgrade)
		balloon_alert(user, "нечего доставать!")
		return FALSE

	if(LAZYLEN(stored_chips) > DEFAULT_CHIP_SLOTS)
		balloon_alert(user, "мешают чипы!")
		return FALSE

	maximum_slots -= stored_upgrade.extra_slots
	user.put_in_hands(stored_upgrade)
	balloon_alert(user, "улучшение извлечено")
	stored_upgrade = null


/obj/item/organ/internal/cyberimp/mouth/translator/emp_act(severity)
	if(emp_proof)
		return

	if(!owner)
		return

	turn_languages_off()
	addtimer(CALLBACK(src, PROC_REF(turn_languages_on)), 20 SECONDS)


/obj/item/organ/internal/cyberimp/mouth/translator/proc/turn_languages_on()
	active = TRUE
	if(!owner)
		return

	to_chat(owner, span_notice("<font color=green>[capitalize(declent_ru(NOMINATIVE))] снова работает!</font>"))
	for(var/datum/language/lang as anything in given_languages)
		owner.add_language(lang.name)

	decoder.update_button_state()


/obj/item/organ/internal/cyberimp/mouth/translator/proc/turn_languages_off()
	active = FALSE
	can_wingdings = FALSE
	to_chat(owner, span_warning("[capitalize(declent_ru(NOMINATIVE))] временно вышел из строя из-за воздействия ЭМИ!"))
	do_sparks(3, FALSE, owner)
	for(var/datum/language/lang as anything in given_languages)
		owner.remove_language(lang.name)

	decoder.update_button_state()


	// TRANSLATOR ACTION BUTTONS //

/datum/action/item_action/organ_action/translator_select_language
	name = "Выбрать используемый язык"
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "select_language"


/datum/action/item_action/organ_action/translator_select_language/Trigger(left_click = TRUE)
	if(!owner)
		return

	owner.check_languages()


/datum/action/item_action/organ_action/wingdings_decoder
	name = "Переключить дешифратор Вингдингс"
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "wingdings_off"
	use_itemicon = FALSE


/datum/action/item_action/organ_action/wingdings_decoder/proc/update_button_state()
	var/obj/item/organ/internal/cyberimp/mouth/translator/translator = owner.get_organ_slot(INTERNAL_ORGAN_SPEECH_TRANSLATOR)
	if(!translator)
		return FALSE

	if(translator.can_wingdings)
		button_icon_state = "wingdings_on"
	else
		button_icon_state = initial(button_icon_state)

	UpdateButtonIcon()

	return TRUE


/datum/action/item_action/organ_action/wingdings_decoder/Trigger(left_click = TRUE)
	if(!owner)
		return FALSE

	var/obj/item/organ/internal/cyberimp/mouth/translator/translator = owner.get_organ_slot(INTERNAL_ORGAN_SPEECH_TRANSLATOR)
	if(!translator)
		Remove(owner)

	if(!translator.active)
		owner.balloon_alert(owner, "дешифратор не работает!")
		return FALSE

	translator.can_wingdings = !translator.can_wingdings
	owner.balloon_alert(owner, "дешифратор [translator.can_wingdings ? "включён" : "выключен"]")
	update_button_state()

	return TRUE


/datum/action/item_action/organ_action/wingdings_decoder/IsAvailable()
	if(!..())
		return FALSE

	var/obj/item/organ/internal/cyberimp/mouth/translator/translator = owner.get_organ_slot(INTERNAL_ORGAN_SPEECH_TRANSLATOR)
	if(!translator)
		Remove(owner)
		return FALSE

	if(!translator.active)
		return FALSE

	return TRUE


	// TRANSLATOR STORAGE UPGRADES //

/obj/item/translator_upgrade // just adminspawn now
	name = "translator upgrade"
	desc = "Учёные NanoTrasen ещё не поняли, как он работает. Может быть, позже..."
	w_class = WEIGHT_CLASS_TINY
	var/extra_slots = 1


/obj/item/translator_upgrade/grey_retraslator
	name = "PVR storage upgrade"
	desc = "Маленькое инопланетное устройство с мелким экраном, показывающим только помехи. Видимо, что-то из технологий греев."
	ru_names = list(
		NOMINATIVE = "модуль улучшения РПГ",
		GENITIVE = "модуля улучшения РПГ",
		DATIVE = "модулю улучшения РПГ",
		ACCUSATIVE = "модуль улучшения РПГ",
		INSTRUMENTAL = "модулем улучшения РПГ",
		PREPOSITIONAL = "модуле улучшения РПГ",
	)
	icon = 'icons/obj/voice_translator.dmi'
	icon_state = "pvr_upgrade"
	origin_tech = "materials=2;programming=3;abductor=1"
	extra_slots = UPGRADE_SLOTS_GREY


	// LANGUAGE TRANSLATOR CHIPS //

/obj/item/translator_chip
	name = "language chip"
	desc = "Крошечный чип с мигающим индикатором."
	ru_names = list(
		NOMINATIVE = "языковой чип",
		GENITIVE = "языкового чипа",
		DATIVE = "языковому чипу",
		ACCUSATIVE = "языковой чип",
		INSTRUMENTAL = "языковым чипом",
		PREPOSITIONAL = "языковом чипе",
	)
	icon = 'icons/obj/voice_translator.dmi'
	icon_state = "chip_empty"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;programming=2"
	var/datum/language/stored_language
	var/stored_language_rus


/obj/item/translator_chip/New()
	. = ..()
	if(stored_language)
		stored_language = GLOB.all_languages[stored_language]


/obj/item/translator_chip/proc/on_install(mob/living/carbon/human/H, obj/item/organ/internal/cyberimp/mouth/translator/translator)
	return TRUE


/obj/item/translator_chip/proc/on_remove(mob/living/carbon/human/H, obj/item/organ/internal/cyberimp/mouth/translator/translator)
	return TRUE


/obj/item/translator_chip/attack_self(mob/living/user)
	if(stored_language_rus)
		return

	var/list/available_languages = list()
	var/obj/item/translator_chip/chip
	for(chip as anything in subtypesof(/obj/item/translator_chip))
		available_languages[chip.stored_language_rus] = chip

	var/answer = tgui_input_list(user, "Выберите язык для загрузки в чип:", "Выбор прошивки", available_languages)
	if(!answer || stored_language_rus) //double check to prevent multispec
		return

	user.drop_item_ground(src, silent = TRUE)
	chip = available_languages[answer]
	var/obj/item/translator_chip/new_chip = new chip(null)
	user.put_in_hands(new_chip, silent = TRUE)
	qdel(src)


/obj/item/translator_chip/examine(mob/user)
	. = ..()

	if(!Adjacent(user))
		return

	if(stored_language_rus)
		. += span_notice("Загруженный язык: [stored_language_rus].")
	else
		. += span_notice("Судя по всему, не активирован.")


/obj/item/translator_chip/update_icon_state()
	for(var/obj/item/translator_chip/chip as anything in subtypesof(/obj/item/translator_chip))
		if(stored_language_rus != chip.stored_language_rus)
			continue

		icon_state = chip.icon_state
		return


	// CHIP SUBTYPES //

/obj/item/translator_chip/sol
	icon_state = "chip_solcom"
	stored_language = LANGUAGE_SOL_COMMON
	stored_language_rus = "Общесолнечный"

/obj/item/translator_chip/neorus
	icon_state = "chip_neorus"
	stored_language = LANGUAGE_NEO_RUSSIAN
	stored_language_rus = "Неорусский"

/obj/item/translator_chip/gutter
	icon_state = "chip_gutter"
	stored_language = LANGUAGE_GUTTER
	stored_language_rus = "Гангстерский"

/obj/item/translator_chip/clownish
	icon_state = "chip_clownish"
	stored_language = LANGUAGE_CLOWN
	stored_language_rus = "Клоунский"

/obj/item/translator_chip/tradeband
	icon_state = "chip_tradeband"
	stored_language = LANGUAGE_TRADER
	stored_language_rus = "Торговый"

/obj/item/translator_chip/canilunzt
	icon_state = "chip_canilunzt"
	stored_language = LANGUAGE_VULPKANIN
	stored_language_rus = "Канилунц"

/obj/item/translator_chip/sintaunathi
	icon_state = "chip_sintaunathi"
	stored_language = LANGUAGE_UNATHI
	stored_language_rus = "Синта'Унати"

/obj/item/translator_chip/siiktajr
	icon_state = "chip_siiktajr"
	stored_language = LANGUAGE_TAJARAN
	stored_language_rus = "Сик'тайр"

/obj/item/translator_chip/skrellian
	icon_state = "chip_skrellian"
	stored_language = LANGUAGE_SKRELL
	stored_language_rus = "Скреллианский"

/obj/item/translator_chip/bubblish
	icon_state = "chip_bubblish"
	stored_language = LANGUAGE_SLIME
	stored_language_rus = "Пузырчатый"

/obj/item/translator_chip/voxpidgin
	icon_state = "chip_voxpidgin"
	stored_language = LANGUAGE_VOX
	stored_language_rus = "Вокс-пиджин"

/obj/item/translator_chip/chittin
	icon_state = "chip_chittin"
	stored_language = LANGUAGE_KIDAN
	stored_language_rus = "Хитин"

/obj/item/translator_chip/tkachi
	icon_state = "chip_tkachi"
	stored_language = LANGUAGE_MOTH
	stored_language_rus = "Ткачий"

/obj/item/translator_chip/orluum
	icon_state = "chip_orluum"
	stored_language = LANGUAGE_DRASK
	stored_language_rus = "Орлуум"


/obj/item/translator_chip/wingdings
	icon_state = "chip_wingdings"
	stored_language = null
	stored_language_rus = "Вингдингс"

/obj/item/translator_chip/wingdings/on_install(mob/living/carbon/human/H, obj/item/organ/internal/cyberimp/mouth/translator/translator)
	if(!translator.decoder)
		translator.decoder = new(translator)

	if(H)
		translator.decoder.Grant(H)

	return TRUE

/obj/item/translator_chip/wingdings/on_remove(mob/living/carbon/human/H, obj/item/organ/internal/cyberimp/mouth/translator/translator)
	translator.can_wingdings = FALSE

	if(!translator.decoder)
		return

	if(H)
		translator.decoder.Remove(H)

	var/datum/action/item_action/organ_action/wingdings_decoder/used_decoder = locate() in translator.actions
	if(used_decoder)
		used_decoder.Destroy()

	translator.decoder = null

	return TRUE


/*	One day it will become a reality

/obj/item/translator_chip/sintatajr
	icon_state = "chip_sintatajr"
	stored_language =
	stored_language_rus = "Синта'Тайр"

*/


#undef DEFAULT_CHIP_SLOTS
#undef UPGRADE_SLOTS_GREY
