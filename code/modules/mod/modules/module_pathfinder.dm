///Pathfinder - Can fly the suit from a long distance to an implant installed in someone.
/obj/item/mod/module/pathfinder
	name = "MOD pathfinder module"
	desc = "Модуль для МЭК, состоящий из двух компонентов — набора ионных двигателей с матрицей отслеживания, \
			устанавливаемых в костюм, и био-чипа \"Первопроходец\". Последний, после вживления в тело, позволяет пользователю вызвать к себе \
			модульный костюм. Био-чип встроен в модуль, и перед использованием его необходимо извлечь."
	icon_state = "pathfinder"
	complexity = 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 200
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	incompatible_modules = list(/obj/item/mod/module/pathfinder)
	/// The pathfinding implant.
	var/obj/item/implant/mod/implant

/obj/item/mod/module/pathfinder/get_ru_names()
	return list(
		NOMINATIVE = "модуль \"Первопроходец\"",
		GENITIVE = "модуля \"Первопроходец\"",
		DATIVE = "модулю \"Первопроходец\"",
		ACCUSATIVE = "модуль \"Первопроходец\"",
		INSTRUMENTAL = "модулем \"Первопроходец\"",
		PREPOSITIONAL = "модуле \"Первопроходец\"",
	)

/obj/item/mod/module/pathfinder/Initialize(mapload)
	. = ..()
	implant = new(src)

/obj/item/mod/module/pathfinder/Destroy()
	implant = null
	return ..()

/obj/item/mod/module/pathfinder/examine(mob/user)
	. = ..()
	if(implant)
		. += span_notice("Внутри находится био-чип. Используйте модуль на себе, чтобы вживить его в тело.")
	else
		. += span_warning("Слот для био-чипа пуст.")

/obj/item/mod/module/pathfinder/attack(mob/living/target, mob/living/user, def_zone, skip_attack_anim)
	if(!ishuman(target) || !implant)
		return
	if(!do_after(user, 1.5 SECONDS, target = target))
		return
	if(!implant.implant(target, user))
		balloon_alert(user, "невозможно!")
		return
	if(target == user)
		balloon_alert(user, "био-чип установлен")
	else
		target.visible_message(
			span_notice("[user] вживля[PLUR_ET_UT(user)] [implant.declent_ru(ACCUSATIVE)] в тело [target.declent_ru(GENITIVE)]."),
			span_notice("[user] вживля[PLUR_ET_UT(user)] [implant.declent_ru(ACCUSATIVE)] в ваше тело.")
		)
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)
	icon_state = "pathfinder_empty"
	implant = null

/obj/item/mod/module/pathfinder/proc/attach(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(human_user.get_item_by_slot(ITEM_SLOT_BACK) && !human_user.drop_item_ground(human_user.get_item_by_slot(ITEM_SLOT_BACK)))
		return
	if(!human_user.equip_to_slot_if_possible(mod, ITEM_SLOT_BACK, disable_warning = TRUE))
		return
	mod.quick_deploy(user)
	human_user.update_action_buttons(TRUE)
	playsound(mod, 'sound/machines/ping.ogg', 50, TRUE)
	drain_power(use_energy_cost)
