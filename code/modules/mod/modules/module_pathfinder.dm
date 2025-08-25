///Pathfinder - Can fly the suit from a long distance to an implant installed in someone.
/obj/item/mod/module/pathfinder
	name = "MOD pathfinder module"
	desc = "Данный модуль, разработанный корпорацией \"Решения Пайзо\" состоит из двух компонентов. \
		Первый компонент, установливаемый в модульный костюм, представляет из себя множество \
		двигателей и подруливателей, вместе с матрицей отслеживания. Всё это позволяет костюму \
		самостоятельно перемещаться в пространстве навстречу второму компоненту - био-чипу \
		\"Первопроходец\". Био-чип, вживляемый в тело, позволяет пользователю вызвать свой \
		модульный костюм в любое время. Био-чип установлен в модуль и его нужно достать перед использованием."
	icon_state = "pathfinder"
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 200
	incompatible_modules = list(/obj/item/mod/module/pathfinder)
	/// The pathfinding implant.
	var/obj/item/implant/mod/implant

/obj/item/mod/module/anomaly_locked/kinesis/get_ru_names()
	return list(
		NOMINATIVE = "Модуль для модульного костюма \"Первопроходец\"",
		GENITIVE = "Модуля для модульного костюма \"Первопроходец\"",
		DATIVE = "Модулю для модульного костюма \"Первопроходец\"",
		ACCUSATIVE = "Модуль для модульного костюма \"Первопроходец\"",
		INSTRUMENTAL = "Модулем для модульного костюма \"Первопроходец\"",
		PREPOSITIONAL = "Модуле для модульного костюма \"Первопроходец\"",
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
		. += span_warning("Внутри нет био-чипа.")

/obj/item/mod/module/pathfinder/attack(mob/living/target, mob/living/user, params)
	if(!ishuman(target) || !implant)
		return
	if(!do_after(user, 1.5 SECONDS, target = target))
		return
	if(!implant.implant(target, user))
		balloon_alert(user, "невозможно установить био-чип!")
		return
	if(target == user)
		balloon_alert(user, "био-чип установлен")
	else
		target.visible_message(span_notice("[user] устанавливает био-чип в [target]."), span_notice("[user] устанавливает вам [implant.declent_ru(NOMINATIVE)]."))
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
	drain_power(use_power_cost)
