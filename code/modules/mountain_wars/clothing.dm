// Одежда и броня Mountain Wars.
// Спрайты портированы из TerraGov Marine Corps (github.com/tgstation/TerraGov-Marine-Corps),
// ассеты под CC BY-NC-SA 3.0 — атрибуция обязательна в PR.

// MARK: Морпехи
/obj/item/clothing/suit/armor/vest/mw_marine
	name = "бронежилет IOTV"
	desc = "Тяжёлый армейский бронежилет с керамическими пластинами. Держит пулю, но в нём жарко."
	icon = 'icons/mountain_wars/armor.dmi'
	icon_state = "tanker"
	item_state = "tanker"
	onmob_sheets = list(
		ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mountain_wars/armor_mob.dmi',
	)
	armor = list(MELEE = 30, BULLET = 35, LASER = 30, ENERGY = 20, BOMB = 25, BIO = 0, FIRE = 40, ACID = 40)

/obj/item/clothing/suit/armor/vest/mw_marine/leader
	name = "офицерский бронежилет"
	desc = "Разгрузка командира отделения: меньше пластин, больше подсумков под карты и связь."
	icon_state = "officer"
	item_state = "officer"

// Санитар и сапёр берут спрайты из другого листа: в armor.dmi под них были только
// состояния семейства xarmor — экзоскелетные скафандры выше человеческого роста.
// Для пехоты в горах это мимо, нужен обычный носимый броник.
/obj/item/clothing/suit/armor/vest/mw_marine/medic
	name = "бронежилет санитара"
	desc = "Облегчённый жилет с красным крестом. Пластины сняты — вместо них сумки."
	icon = 'icons/mountain_wars/armor_ert.dmi'
	icon_state = "guardmedicarmor"
	item_state = "guardmedicarmor"
	onmob_sheets = list(
		ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mountain_wars/armor_ert_mob.dmi',
	)
	armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 20, BOMB = 20, BIO = 0, FIRE = 40, ACID = 40)

/obj/item/clothing/suit/armor/vest/mw_marine/engineer
	name = "сапёрный бронежилет"
	desc = "Жилет с огнестойкой подкладкой. Пуля возьмёт не хуже обычного, огонь — куда хуже."
	icon = 'icons/mountain_wars/armor_ert.dmi'
	icon_state = "guardarmor"
	item_state = "guardarmor"
	onmob_sheets = list(
		ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mountain_wars/armor_ert_mob.dmi',
	)
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 20, BOMB = 35, BIO = 0, FIRE = 80, ACID = 60)

/obj/item/clothing/suit/armor/vest/mw_marine/heavy
	name = "штурмовой бронекомплект"
	desc = "Полный комплект с паховой и плечевой защитой. В нём не побегаешь."
	icon_state = "marine_riot"
	item_state = "marine_riot"
	armor = list(MELEE = 45, BULLET = 50, LASER = 40, ENERGY = 25, BOMB = 40, BIO = 0, FIRE = 50, ACID = 50)
	slowdown = 0.5

/obj/item/clothing/head/helmet/mw_marine
	name = "шлем MICH"
	desc = "Армейский композитный шлем с креплением под обвес."
	icon = 'icons/mountain_wars/helmets.dmi'
	icon_state = "helmet"
	item_state = "helmet"
	onmob_sheets = list(
		ITEM_SLOT_HEAD_STRING = 'icons/mountain_wars/helmets_mob.dmi',
	)

/obj/item/clothing/head/helmet/mw_marine/leader
	name = "шлем командира отделения"
	desc = "Чёрный шлем с гарнитурой. По нему командира видно и своим, и чужим."
	icon_state = "k_helmet"
	item_state = "k_helmet"

/obj/item/clothing/head/helmet/mw_marine/medic
	name = "шлем санитара"
	desc = "Светлый шлем с медицинской маркировкой."
	icon_state = "s_helmet"
	item_state = "s_helmet"

/obj/item/clothing/head/helmet/mw_marine/engineer
	name = "сапёрный шлем"
	desc = "Оливковый шлем с опускающимся щитком."
	icon_state = "m_helmet"
	item_state = "m_helmet"

/obj/item/clothing/head/helmet/mw_marine/heavy
	name = "штурмовой шлем"
	desc = "Утяжелённый шлем с забралом. Обзор так себе, зато голова целая."
	icon_state = "heavyhelmet"
	item_state = "heavyhelmet"
	armor = list(MELEE = 45, BULLET = 50, LASER = 40, ENERGY = 25, BOMB = 40, BIO = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/under/mw_marine
	name = "полевая форма морпеха"
	desc = "Камуфляжная форма Корпуса морской пехоты."
	icon = 'icons/mountain_wars/uniforms.dmi'
	icon_state = "marine_jumpsuit"
	item_state = "marine_jumpsuit"
	onmob_sheets = list(
		ITEM_SLOT_CLOTH_INNER_STRING = 'icons/mountain_wars/uniforms_mob.dmi',
	)

// MARK: Повстанцы
/obj/item/clothing/under/mw_insurgent
	name = "полевая одежда повстанца"
	desc = "Потрёпанная полевая одежда. Не защищает ни от чего, кроме солнца."
	icon = 'icons/mountain_wars/uniforms.dmi'
	icon_state = "red_fatigues"
	item_state = "red_fatigues"
	onmob_sheets = list(
		ITEM_SLOT_CLOTH_INNER_STRING = 'icons/mountain_wars/uniforms_mob.dmi',
	)

// Повстанцам достаётся не броня, а разгрузки: пулю они почти не держат, зато у
// каждого класса свой силуэт.
/obj/item/clothing/suit/armor/mw_insurgent
	name = "разгрузка боевика"
	desc = "Самошитая разгрузка из брезента. Держит магазины, но не пули."
	icon = 'icons/mountain_wars/armor_ert.dmi'
	icon_state = "rebel_armor"
	item_state = "rebel_armor"
	onmob_sheets = list(
		ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mountain_wars/armor_ert_mob.dmi',
	)
	armor = list(MELEE = 15, BULLET = 15, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/suit/armor/mw_insurgent/leader
	name = "трофейный бронежилет"
	desc = "Армейский жилет чужой армии, снятый с убитого. Латаный, но настоящий."
	icon_state = "upp_armor"
	item_state = "upp_armor"
	armor = list(MELEE = 25, BULLET = 30, LASER = 25, ENERGY = 15, BOMB = 20, BIO = 0, FIRE = 30, ACID = 30)

/obj/item/clothing/suit/armor/mw_insurgent/marksman
	name = "стрелковая накидка"
	desc = "Длинная пыльная накидка. В ней проще слиться со склоном, чем поймать пулю."
	icon_state = "mercenary_miner_armor"
	item_state = "mercenary_miner_armor"

/obj/item/clothing/suit/armor/mw_insurgent/medic
	name = "санитарная разгрузка"
	desc = "Разгрузка с нашитыми подсумками под бинты и жгуты."
	icon_state = "mercenary_engineer_armor"
	item_state = "mercenary_engineer_armor"

/obj/item/clothing/head/helmet/mw_insurgent
	name = "платок"
	desc = "Намотанный на голову платок. От солнца спасает, от пули нет."
	icon = 'icons/mountain_wars/helmets_ert.dmi'
	icon_state = "rebel_hood"
	item_state = "rebel_hood"
	onmob_sheets = list(
		ITEM_SLOT_HEAD_STRING = 'icons/mountain_wars/helmets_ert_mob.dmi',
	)
	armor = list(MELEE = 10, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 5, BIO = 0, FIRE = 10, ACID = 10)

/obj/item/clothing/head/helmet/mw_insurgent/leader
	name = "берет полевого командира"
	desc = "Выцветший берет. Знаков различия нет — все и так знают, кто здесь главный."
	icon_state = "upp_beret"
	item_state = "upp_beret"

/obj/item/clothing/head/helmet/mw_insurgent/marksman
	name = "полевое кепи"
	desc = "Кепи с длинным козырьком. Не бликует прицел."
	icon_state = "upp_cap"
	item_state = "upp_cap"

// MARK: Пояс смертника
// Механика с боевым кличем и подрывом по кнопке взята у TGMC (bombvest.dm), плюс
// то, чего у них нет: замыкание при смерти носителя.
/obj/item/clothing/suit/armor/mw_insurgent/boomvest
	name = "пояс смертника"
	desc = "Брикеты взрывчатки, обмотанные скотчем поверх разгрузки. Провод уходит к кнопке в кармане. \
		Замыкает и от кнопки, и от остановки сердца."
	// Спрайт из марин-набора: у TGMC пояс лежит именно там.
	icon = 'icons/mountain_wars/armor.dmi'
	icon_state = "boom_vest"
	item_state = "boom_vest"
	onmob_sheets = list(
		ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mountain_wars/armor_mob.dmi',
	)
	// Взрывчатка вместо пластин: не защищает вообще ни от чего.
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	actions_types = list(/datum/action/item_action/mw_boomvest)
	/// Сколько смертник тянет кнопку. Есть шанс его застрелить.
	var/detonate_time = 2 SECONDS
	/// Что он кричит перед подрывом.
	var/warcry
	/// Замыкание уже пошло — второй раз не запускаем.
	var/detonating = FALSE

/obj/item/clothing/suit/armor/mw_insurgent/boomvest/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot != ITEM_SLOT_CLOTH_OUTER)
		return
	RegisterSignal(user, COMSIG_LIVING_DEATH, PROC_REF(on_wearer_death), override = TRUE)

/obj/item/clothing/suit/armor/mw_insurgent/boomvest/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	UnregisterSignal(user, COMSIG_LIVING_DEATH)

/// Смерть носителя размыкает цепь — рвёт сразу, без клича и без задержки.
/obj/item/clothing/suit/armor/mw_insurgent/boomvest/proc/on_wearer_death(mob/living/wearer, gibbed)
	SIGNAL_HANDLER
	if(gibbed || detonating)
		return
	detonating = TRUE
	INVOKE_ASYNC(src, PROC_REF(detonate), wearer)

/obj/item/clothing/suit/armor/mw_insurgent/boomvest/ui_action_click(mob/user, datum/action/action, leftclick = TRUE)
	if(leftclick)
		return ..()
	set_warcry(user)

/obj/item/clothing/suit/armor/mw_insurgent/boomvest/attack_self(mob/user)
	if(!isliving(user))
		return
	INVOKE_ASYNC(src, PROC_REF(try_detonate), user)

/obj/item/clothing/suit/armor/mw_insurgent/boomvest/proc/set_warcry(mob/user)
	var/new_warcry = stripped_input(user, "Что вы крикнете перед подрывом?", "Боевой клич", warcry, MAX_MESSAGE_LEN)
	if(isnull(new_warcry) || QDELETED(src) || QDELETED(user))
		return
	warcry = new_warcry
	to_chat(user, span_notice("Боевой клич: «[warcry]»."))

/obj/item/clothing/suit/armor/mw_insurgent/boomvest/proc/try_detonate(mob/living/user)
	if(detonating)
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/wearer = user
	if(wearer.wear_suit != src)
		balloon_alert(user, "нужно надеть!")
		return
	detonating = TRUE
	if(warcry)
		wearer.say(warcry)
	// Клич слышен, руки заняты — соседи ещё успеют застрелить смертника.
	wearer.visible_message(span_userdanger("[wearer] хватается за пояс!"))
	if(!do_after(wearer, detonate_time, src, DA_IGNORE_USER_LOC_CHANGE))
		detonating = FALSE
		return
	detonate(wearer)

/obj/item/clothing/suit/armor/mw_insurgent/boomvest/proc/detonate(mob/living/wearer)
	var/turf/epicenter = get_turf(wearer) || get_turf(src)
	if(!epicenter)
		return
	wearer.investigate_log("подорвал[GEND_A_O_I(wearer)] пояс смертника[warcry ? " с кличем «[warcry]»" : ""]", INVESTIGATE_BOMB)
	message_admins("[key_name_admin(wearer)] подорвал пояс смертника в [ADMIN_VERBOSEJMP(epicenter)][warcry ? " с кличем «[warcry]»" : ""].")
	explosion(
		epicenter,
		devastation_range = 1,
		heavy_impact_range = 2,
		light_impact_range = 4,
		flash_range = 4,
		cause = "пояс смертника",
	)
	wearer.gib()
	qdel(src)

/datum/action/item_action/mw_boomvest
	name = "Подорвать пояс"
	desc = "ЛКМ — подрыв. ПКМ — задать боевой клич."

// ПКМ по кнопке действия — это обычный Trigger с TRIGGER_SECONDARY_ACTION;
// AltTrigger в Paradise висит на Ctrl+ЛКМ (action_button.dm). Без этой развилки
// правый клик уходил в основную ветку и просто подрывал пояс.
/datum/action/item_action/mw_boomvest/do_effect(trigger_flags)
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		return do_alt_effect(trigger_flags)
	return ..()
