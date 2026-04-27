// MARK: .38 Mars Special
/obj/item/gun/projectile/revolver/detective
	name = "MS-R38 revolver"
	desc = "Бюджетный револьвер производства \"Mars Special\" калибра .38. Простая конструкция из композитных материалов, шестизарядный барабан, \
			отсутствие направляющих для тактических модулей. Популярен на гражданском рынке за счёт своей доступности."
	icon_state = "detective"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38
	fire_sound = 'sound/weapons/gunshots/1rev38.ogg'
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_MEDIUM
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/projectile/revolver/detective/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins)

/obj/item/gun/projectile/revolver/detective/get_ru_names()
	return list(
		NOMINATIVE = "револьвер MS-R38 .38",
		GENITIVE = "револьвера MS-R38 .38",
		DATIVE = "револьверу MS-R38 .38",
		ACCUSATIVE = "револьвер MS-R38 .38",
		INSTRUMENTAL = "револьвером MS-R38 .38",
		PREPOSITIONAL = "револьвере MS-R38 .38",
	)

/obj/item/gun/projectile/revolver/detective/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Популярный образец гражданского и полицейского оружия от \"Mars Special\". Маломощный, минималистичный, дешёвый.<br>\
		<br>\
		Фурнитура выполнена из лёгкого ударопрочного полимера, снижающего вес оружия и стоимость производства. \
		Направляющие для крепления тактических модулей отсутствуют. Использование стандартного револьверного патрона .38, \
		производящегося во множестве вариантов и модификаций, подчёркивает доступность и универсальность MS-R38.<br>\
		<br>\
		Данный револьвер можно нередко встретить в руках охранного персонала, частных детективов и гражданских лиц."\
	)

// MARK: Taurus
/obj/item/gun/projectile/rйvolver/taurus
	name = "MS-R45 \"Taurus\" revolver"
	desc = "Тяжёлый шестизарядный револьвер калибра .45 Colt производства \"Mars Special\". Отличается высокой убойной силой, \
			модульностью и надёжностью. Закупается \"Нанотрейзен\" для снабжения сотрудников корпоративной службы безопасности."
	icon_state = "taurus"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/taurus
	fire_sound = 'sound/weapons/gunshots/1rev38.ogg'
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_MEDIUM
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_PISTOL_UNDER | GUN_MODULE_CLASS_PISTOL_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 20, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 6, ATTACHMENT_OFFSET_Y = 6),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = -6),
	)
	can_air_shoot = FALSE

/obj/item/gun/projectile/revolver/taurus/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins)

/obj/item/gun/projectile/revolver/taurus/get_ru_names()
	return list(
		NOMINATIVE = "револьвер MS-R45 \"Таурус\"",
		GENITIVE = "револьвера MS-R45 \"Таурус\"",
		DATIVE = "револьверу MS-R45 \"Таурус\"",
		ACCUSATIVE = "револьверу MS-R45 \"Таурус\"",
		INSTRUMENTAL = "револьвером MS-R45 \"Таурус\"",
		PREPOSITIONAL = "револьвере MS-R45 \"Таурус\"",
	)

/obj/item/gun/projectile/revolver/taurus/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Мощный самозарядный револьвер, разработанный для гражданского и профессионального рынка. \
		Конструкция рассчитана на использование патронов .45 Colt, обладающих высокой убойной силой.<br>\
		<br>\
		Корпус изготовлен из высокопрочного композита с использованием стали, что обеспечивает баланс между весом и прочностью \
		при работе с мощным боеприпасом. Существенным отличием от многих аналогов в классе является наличие ряда направляющих для \
		установки тактических модулей, что позволяет адаптировать оружие под различные задачи.<br>\
		<br>\
		\"Таурус\" сыскал популярность, заняв свою нишу в сегменте тактических крупнокалиберных револьверов. \
		Его нередко закупают как государственные силовые структуры, так и частные компании. В 2567 году \"Нанотрейзен\" \
		приобрела крупную партию MS-R45 для обеспечения высокоэффективным личным оружием сотрудников службы безопасности в ряде секторов."\
	)

// MARK: Finger gun (Mime)
// Summoned by the Finger Gun spell, from advanced mimery traitor item
/obj/item/gun/projectile/revolver/fingergun
	name = "finger gun"
	desc = "Ваши пальцы, превращённые в оружие."
	gender = PLURAL
	icon_state = "fingergun"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38/invisible
	origin_tech = ""
	item_flags = ABSTRACT|DROPDEL
	slot_flags = NONE
	fire_sound = null
	fire_sound_text = null
	lefthand_file = null
	righthand_file = null
	can_holster = FALSE // Get your fingers out of there!
	clumsy_check = FALSE //Stole your uplink! Honk!
	needs_permit = FALSE //go away beepsky
	var/obj/effect/proc_holder/spell/mime/fingergun/parent_spell
	accuracy = GUN_ACCURACY_DEFAULT
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/projectile/revolver/fingergun/get_ru_names()
	return list(
		NOMINATIVE = "пальцы-пистолеты",
		GENITIVE = "пальцев-пистолетов",
		DATIVE = "пальцам-пистолетам",
		ACCUSATIVE = "пальцы-пистолеты",
		INSTRUMENTAL = "пальцами-пистолетами",
		PREPOSITIONAL = "пальцах-пистолетах",
	)

/obj/item/gun/projectile/revolver/fingergun/Initialize(mapload, new_parent_spell)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	parent_spell = new_parent_spell
	verbs -= /obj/item/gun/projectile/revolver/verb/spin

/obj/item/gun/projectile/revolver/fingergun/fake
	desc = "Ваши пальцы, превращённые в оружие. Безвредное оружие."
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38/invisible/fake

/obj/item/gun/projectile/revolver/fingergun/Destroy()
	if(parent_spell)
		parent_spell.current_gun = null
		parent_spell.UnregisterSignal(parent_spell.action.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
		parent_spell = null
	return ..()

/obj/item/gun/projectile/revolver/fingergun/shoot_with_empty_chamber(mob/living/user)
	balloon_alert(user, "нечем стрелять!")
	qdel(src)
	return

/obj/item/gun/projectile/revolver/fingergun/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!user.mind?.miming)
		balloon_alert(user, "вы не приняли обет молчания!")
		return
	return ..()

/obj/item/gun/projectile/revolver/fingergun/attackby(obj/item/I, mob/user, params)
	return ATTACK_CHAIN_PROCEED

/obj/item/gun/projectile/revolver/fingergun/attack_self(mob/living/user)
	. = ..()
	if(istype(user))
		balloon_alert(user, "пальцы разжаты")
	qdel(src)

/obj/item/gun/projectile/revolver/fingergun/unload_act(mob/user)
	return

// MARK: Unica-6
/obj/item/gun/projectile/revolver/mateba // я не знаю какой корпе эту хероту можно дать
	name = "Unica 6 revolver"
	desc = "Тяжёлый револьвер калибра .357. Классическая конструкция, барабан на 6 патронов, высокая убойная сила."
	icon_state = "mateba"
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_HIGH
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 18, ATTACHMENT_OFFSET_Y = 2),
	)

/obj/item/gun/projectile/revolver/mateba/get_ru_names()
	return list(
		NOMINATIVE = "револьвер Уника-6 .357",
		GENITIVE = "револьвера Уника-6 .357",
		DATIVE = "револьверу Уника-6 .357",
		ACCUSATIVE = "револьвер Уника-6 .357",
		INSTRUMENTAL = "револьвером Уника-6 .357",
		PREPOSITIONAL = "револьвере Уника-6 .357",
	)

// MARK: Tkach Ya-Sui
/obj/item/gun/projectile/revolver/ga12
	name = "UC-12 \"Dragon\" revolver"
	desc = "Массивный реввольвер 12-го калибра производства \"Дядя Чанг\". Колоссальная огневая мощь компенсируется \
			экстремальной отдачей, низкой скорострельностью и барабаном на 3 патрона. Популярен среди наёмников и бандитов пограничных секторов."
	icon_state = "12garevolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/ga12
	fire_sound = 'sound/weapons/gunshots/1rev12.ogg'
	fire_delay = 5
	accuracy = new /datum/gun_accuracy/pistol/extends_spread()
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_HIGH
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 16, ATTACHMENT_OFFSET_Y = 2),
	)

/obj/item/gun/projectile/revolver/ga12/get_ru_names()
	return list(
		NOMINATIVE = "револьвер UC-12 \"Дракон\" 12g",
		GENITIVE = "револьвера UC-12 \"Дракон\" 12g",
		DATIVE = "револьверу UC-12 \"Дракон\" 12g",
		ACCUSATIVE = "револьвер UC-12 \"Дракон\" 12g",
		INSTRUMENTAL = "револьвером UC-12 \"Дракон\" 12g",
		PREPOSITIONAL = "револьвере UC-12 \"Дракон\" 12g",
	)

/obj/item/gun/projectile/revolver/ga12/add_deep_lore()
	AddElement(/datum/element/examine_lore, \
		lore = "Конструкция \"Дракона\" представляет собой упрощённую копию дробовика револьверного типа, \
		чертежи которого попали на чёрный рынок в ещё в 2540-х. Инженеры \"Дядя Чанг\" адаптировали проект под \
		массовое производство, значительно урезав качество и конечную стоимость.<br>\
		<br>\
		Высокая инерция барабана и тяжёлый ударник требуют долгой паузы между выстрелами. Лёгкая полимерная рамка \
		плохо справляется с гашением энергии 12-го калибра. Отсутствие каких-либо креплений под дополнительные модули усугубляет \
		и без того малую модульность.<br>\
		<br>\
		UC-12 не был принят для регулярных войск какой-либо армии из-за малой надёжности и специфичности использования. \
		Однако в пограничных секторах, где цены на лицензированное оружие высоки, а убойная сила и низкая стоимость стоят \
		превыше всего, он занял свою нишу, став популярным выбором ЧВК с сомнительной репутацией, криминальных элементов и охотников."\
	)

// MARK: Golder revolver
/obj/item/gun/projectile/revolver/golden
	name = "golden revolver"
	desc = "Золотой револьвер калибра .357."
	icon_state = "goldrevolver"
	fire_sound = 'sound/weapons/resonator_blast.ogg'
	accuracy = new /datum/gun_accuracy/pistol/extends_spread()
	accuracy = GUN_ACCURACY_PISTOL_UPLINK
	recoil = GUN_RECOIL_MEGA
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/projectile/revolver/golden/get_ru_names()
	return list(
		NOMINATIVE = "золотой револьвер .357",
		GENITIVE = "золотого револьвера .357",
		DATIVE = "золотому револьверу .357",
		ACCUSATIVE = "золотой револьвер .357",
		INSTRUMENTAL = "золотым револьвером .357",
		PREPOSITIONAL = "золотом револьвере .357",
	)

// MARK: Nagant
/obj/item/gun/projectile/revolver/nagant
	name = "nagant revolver"
	desc = "Старинный револьвер калибра 7,62x38."
	icon_state = "nagant"
	origin_tech = "combat=3"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev762
	accuracy = GUN_ACCURACY_PISTOL_UPLINK
	recoil = GUN_RECOIL_MEDIUM
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 17, ATTACHMENT_OFFSET_Y = 3),
	)

/obj/item/gun/projectile/revolver/nagant/get_ru_names()
	return list(
		NOMINATIVE = "револьвер Нагана 7,62x38",
		GENITIVE = "револьвера Нагана 7,62x38",
		DATIVE = "револьверу Нагана 7,62x38",
		ACCUSATIVE = "револьвер Нагана 7,62x38",
		INSTRUMENTAL = "револьвером Нагана 7,62x38",
		PREPOSITIONAL = "револьвере Нагана 7,62x38",
	)

/obj/item/gun/projectile/revolver/nagant/rusted
	desc = "Старинный револьвер калибра 7,62x38. Очень ржавый."

/obj/item/gun/projectile/revolver/nagant/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 20, destroy_max_chance = 8, malf_low_bound = 0, malf_high_bound = 3)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 5, misfire_low_bound = 0, misfire_high_bound = 1)

// MARK: .36
/obj/item/gun/projectile/revolver/c36
	name = ".36 revolver"
	desc = "An old fashion .36 chambered revolver."
	icon_state = "detective"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev36
	fire_sound = 'sound/weapons/gunshots/1rev38.ogg'
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_MEDIUM
	attachable_allowed = GUN_MODULE_CLASS_NONE

// MARK: Russian Roulette gun
/obj/item/gun/projectile/revolver/russian
	name = "russian roulette revolver"
	desc = "Револьвер калибра .357, предназначенный для игры в русскую рулетку. Автоматически вращает барабан после каждого выстрела."
	origin_tech = "combat=2;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/rus357
	var/spun = FALSE
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_MEDIUM
	can_air_shoot = FALSE
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 19, ATTACHMENT_OFFSET_Y = 3),
	)

/obj/item/gun/projectile/revolver/russian/get_ru_names()
	return list(
		NOMINATIVE = "револьвер для русской рулетки .357",
		GENITIVE = "револьвера для русской рулетки .357",
		DATIVE = "револьверу для русской рулетки .357",
		ACCUSATIVE = "револьвер для русской рулетки .357",
		INSTRUMENTAL = "револьвером для русской рулетки .357",
		PREPOSITIONAL = "револьвере для русской рулетки .357",
	)

/obj/item/gun/projectile/revolver/russian/Initialize(mapload)
	. = ..()
	Spin()

/obj/item/gun/projectile/revolver/russian/proc/Spin()
	chambered = null
	var/random = rand(1, magazine.max_ammo)
	if(random <= get_ammo(FALSE, FALSE))
		chamber_round()
	spun = TRUE

/obj/item/gun/projectile/revolver/russian/attackby(obj/item/I, mob/user, params)
	if(isspeedloader(I) || isammocasing(I))
		if(get_ammo() > 0)
			balloon_alert(user, "уже заряжено!")
			return ATTACK_CHAIN_PROCEED
		var/loaded = magazine.reload(I, user, silent = TRUE)
		if(loaded)
			user.visible_message(
				span_notice("[user] заряжа[PLUR_ET_YUT(user)] патрон в [declent_ru(ACCUSATIVE)]."),
				span_notice("Вы заряжаете патрон в [declent_ru(ACCUSATIVE)].")
			)
			Spin()
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED

	return ..()

/obj/item/gun/projectile/revolver/russian/attack_self(mob/user)
	add_fingerprint(user)
	if(!spun && can_shoot(user))
		user.visible_message(
			span_notice("[user] прокручива[PLUR_ET_YUT(user)] барабан [declent_ru(GENITIVE)]."),
			span_notice("Вы прокручиваете барабан [declent_ru(GENITIVE)].")
		)
		Spin()
		return
	var/num_unloaded = 0
	var/atom/drop_loc = drop_location()
	while(get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round()
		chambered = null
		CB.forceMove(drop_loc)
		CB.pixel_x = rand(-10, 10)
		CB.pixel_y = rand(-10, 10)
		CB.setDir(pick(GLOB.alldirs))
		CB.update_appearance()
		CB.SpinAnimation(10, 1)
		playsound(drop_loc, CB.casing_drop_sound, 60, TRUE)
		num_unloaded++
	if(num_unloaded)
		balloon_alert(user, "[declension_ru(num_unloaded, "разряжен [num_unloaded] патрон",  "разряжено [num_unloaded] патрона",  "разряжено [num_unloaded] патронов")]")
	else
		balloon_alert(user, "уже разряжено!")

/obj/item/gun/projectile/revolver/russian/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(proximity_flag)
		if(!(target in user.contents) && ismob(target))
			if(user.a_intent == INTENT_HARM) // Flogging action
				return

	if(isliving(user))
		if(!can_trigger_gun(user))
			return
	if(target != user)
		if(ismob(target))
			balloon_alert(user, "не подходящая цель!")
		return

	if(ishuman(user))
		if(!spun)
			balloon_alert(user, "прокрутите барабан!")
			return

		spun = FALSE

		if(chambered)
			var/obj/item/ammo_casing/AC = chambered
			if(AC.fire(user, user, firer_source_atom = src))
				playsound(user, fire_sound, 50, TRUE)
				var/zone = check_zone(user.zone_selected)
				if(zone == BODY_ZONE_HEAD || zone == BODY_ZONE_PRECISE_EYES || zone == BODY_ZONE_PRECISE_MOUTH)
					shoot_self(user, zone)
				else
					user.visible_message(
						span_danger("[user] стреля[PLUR_ET_YUT(user)] [declent_ru(INSTRUMENTAL)] себе в [GLOB.body_zone[zone][ACCUSATIVE]]!"),
						span_userdanger("Вы стреляете [declent_ru(INSTRUMENTAL)] себе в [GLOB.body_zone[zone][ACCUSATIVE]]!"),
						span_italics("Вы слышите выстрел!")
					)
				chambered.after_fire()
				return
			chambered.after_fire()

		user.visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] сухо щёлкает."))
		playsound(user, 'sound/weapons/empty.ogg', 100, TRUE)

/obj/item/gun/projectile/revolver/russian/proc/shoot_self(mob/living/carbon/human/user, affecting = BODY_ZONE_HEAD)
	user.apply_damage(300, BRUTE, affecting)
	user.visible_message(
		span_danger("[user] стреля[PLUR_ET_YUT(user)] [declent_ru(INSTRUMENTAL)] себе в [GLOB.body_zone[affecting][ACCUSATIVE]]!"),
		span_userdanger("Вы стреляете [declent_ru(INSTRUMENTAL)] себе в [GLOB.body_zone[affecting][ACCUSATIVE]]!"),
		span_italics("Вы слышите выстрел!"),
		projectile_message = TRUE
	)

/obj/item/gun/projectile/revolver/russian/soul
	desc = "Револьвер калибра .357, предназначенный для игры в русскую рулетку. Автоматически вращает барабан после каждого выстрела. \
			Проклят и обладает способностью захватывать души своих жертв."

/obj/item/gun/projectile/revolver/russian/soul/shoot_self(mob/living/user)
	..()
	var/obj/item/soulstone/anybody/SS = new /obj/item/soulstone/anybody(get_turf(src))
	if(!SS.transfer_soul("FORCE", user)) //Something went wrong
		qdel(SS)
		return
	user.visible_message(
		span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] поглощает душу [user]!"),
		span_userdanger("[DECLENT_RU_CAP(src, NOMINATIVE)] поглощает вашу душу!")
	)

// MARK: Capgun
/obj/item/gun/projectile/revolver/capgun
	name = "cap gun"
	desc = "Игрушка, имитирующая револьвер калибра .357. Стреляет холостыми."
	origin_tech = null
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/cap
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_MEDIUM
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 19, ATTACHMENT_OFFSET_Y = 3),
	)

/obj/item/gun/projectile/revolver/capgun/get_ru_names()
	return list(
		NOMINATIVE = "игрушечный револьвер",
		GENITIVE = "игрушечного револьвера",
		DATIVE = "игрушечному револьверу",
		ACCUSATIVE = "игрушечный револьвер",
		INSTRUMENTAL = "игрушечным револьвером",
		PREPOSITIONAL = "игрушечном револьвере",
	)

// MARK: Improvised .257
/obj/item/gun/projectile/revolver/improvised
	name = "improvised revolver"
	desc = "Собранный из подручных материалов револьвер калибра .257. Экстремальная отдача, минимальная точность и \
			нулевое удобство использования."
	icon_state = "irevolver"
	item_state = "revolver"
	mag_type = null
	fire_sound = 'sound/weapons/gunshots/1rev257.ogg'
	var/unscrewed = TRUE
	var/obj/item/weaponcrafting/revolverbarrel/barrel
	accuracy = GUN_ACCURACY_MINIMAL
	recoil = GUN_RECOIL_MEGA
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/projectile/revolver/improvised/get_ru_names()
	return list(
		NOMINATIVE = "импровизированный револьвер .257",
		GENITIVE = "импровизированного револьвера .257",
		DATIVE = "импровизированному револьверу .257",
		ACCUSATIVE = "импровизированный револьвер .257",
		INSTRUMENTAL = "импровизированным револьвером .257",
		PREPOSITIONAL = "импровизированном револьвере .257",
	)

/obj/item/gun/projectile/revolver/improvised/Initialize(mapload)
	. = ..()
	barrel = new	// I just want it to spawn with barrel.
	update_icon(UPDATE_OVERLAYS)

/obj/item/gun/projectile/revolver/improvised/update_overlays()
	. = ..()
	if(magazine)
		. += mutable_appearance('icons/obj/weapons/projectile.dmi', magazine.icon_state)
	if(barrel)
		var/icon/barrel_icon = icon('icons/obj/weapons/projectile.dmi', barrel.icon_state)
		if(unscrewed)
			barrel_icon.Turn(-90)
			barrel_icon.Shift(WEST, 5)
		. += barrel_icon

/obj/item/gun/projectile/revolver/improvised/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(unscrewed)
		shoot_with_empty_chamber(user)
		return
	if(istype(barrel, /obj/item/weaponcrafting/revolverbarrel/steel) || prob(80))
		return ..()
	chamber_round(TRUE)
	balloon_alert(user, "клин!")
	playsound(user, 'sound/weapons/jammed.ogg', 140, TRUE)

/obj/item/gun/projectile/revolver/improvised/proc/radial_menu(mob/user)
	var/list/choices = list()

	if(barrel)
		choices["Ствол"] = image(icon = barrel.icon, icon_state = barrel.icon_state)
	if(magazine)
		choices["Барабан"] = image(icon = magazine.icon, icon_state = magazine.icon_state)
	var/choice = length(choices) == 1 ? pick(choices) : show_radial_menu(user, src, choices, require_near = TRUE)

	if(!choice || loc != user)
		return

	switch(choice)
		if("Ствол")
			if(!do_after(user, 8 SECONDS, src, NONE, category = DA_CAT_TOOL))
				return
			balloon_alert(user, "ствол снят")
			user.put_in_hands(barrel)
			barrel = null
		if("Барабан")
			balloon_alert(user, "барабан снят")
			user.put_in_hands(magazine)
			magazine = null
			verbs -= /obj/item/gun/projectile/revolver/verb/spin
	playsound(src, 'sound/items/screwdriver.ogg', 40, TRUE)
	update_icon(UPDATE_OVERLAYS)

/obj/item/gun/projectile/revolver/improvised/attack_hand(mob/user)
	if(loc == user && unscrewed)
		radial_menu(user)
		return
	return ..()

/obj/item/gun/projectile/revolver/improvised/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!magazine || !barrel)
		add_fingerprint(user)
		balloon_alert(user, "барабан и ствол отсутствуют!")
		return .
	balloon_alert(user, "[unscrewed ? "с" : "раз"]борка...")
	if(!I.use_tool(src, user, 8 SECONDS, volume = I.tool_volume) || !magazine || !barrel)
		return .
	unscrewed = !unscrewed
	balloon_alert(user, "[unscrewed ? "раз" : "с"]борка завершена")
	update_icon(UPDATE_OVERLAYS)

/obj/item/gun/projectile/revolver/improvised/attackby(obj/item/I, mob/user, params)
	if(!unscrewed)
		return ..()

	. = ATTACK_CHAIN_PROCEED
	add_fingerprint(user)
	if(istype(I, /obj/item/ammo_box/magazine/internal/cylinder/improvised))
		if(magazine)
			balloon_alert(user, "барабан уже установлен!")
			return .
		if(!user.drop_transfer_item_to_loc(I, src))
			return .
		magazine = I
		balloon_alert(user, "барабан установлен")
		verbs |= /obj/item/gun/projectile/revolver/verb/spin
		update_icon(UPDATE_OVERLAYS)
		playsound(loc, 'sound/items/screwdriver.ogg', 40, TRUE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/weaponcrafting/revolverbarrel))
		var/obj/item/weaponcrafting/revolverbarrel/new_barrel = I
		if(barrel)
			balloon_alert(user, "ствол уже установлен!")
			return .
		balloon_alert(user, "установка ствола...!")
		if(!do_after(user, 8 SECONDS, src, NONE, category = DA_CAT_TOOL) || barrel)
			return .
		if(!user.drop_transfer_item_to_loc(new_barrel, src))
			return .
		balloon_alert(user, "ствол установлен")
		barrel = new_barrel
		fire_sound = new_barrel.new_fire_sound
		update_icon(UPDATE_OVERLAYS)
		playsound(loc, 'sound/items/screwdriver.ogg', 40, TRUE)
		return ATTACK_CHAIN_BLOCKED_ALL

//MARK: Rsh-12
/obj/item/gun/projectile/revolver/rsh_12
	name = "RSh-12"
	desc = "Крупнокалиберный револьвер под калибр 12.7х55 мм. \
			Отличается высокой убойностью и страшной отдачей. Производитель неизвестен."
	icon_state = "rsh-12"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rsh_12
	fire_sound = 'sound/weapons/gunshots/bulldog.ogg'
	accuracy = GUN_ACCURACY_RIFLE
	recoil = GUN_RECOIL_MEGA
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_MUZZLE | GUN_MODULE_CLASS_PISTOL_UNDER | GUN_MODULE_CLASS_PISTOL_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 23, "y" = 1),
		ATTACHMENT_SLOT_RAIL = list("x" = 9, "y" = 8),
		ATTACHMENT_SLOT_UNDER = list("x" = 11, "y" = -5),
	)
	/// Opened state flag
	var/opened = FALSE

/obj/item/gun/projectile/revolver/rsh_12/get_ru_names()
	return list(
		NOMINATIVE = "револьвер \"РШ-12\"",
		GENITIVE = "револьвера \"РШ-12\"",
		DATIVE = "револьверу \"РШ-12\"",
		ACCUSATIVE = "револьвер \"РШ-12\"",
		INSTRUMENTAL = "револьвером \"РШ-12\"",
		PREPOSITIONAL = "револьвере \"РШ-12\"",
	)

/obj/item/gun/projectile/revolver/rsh_12/attack_self(mob/living/user)
	playsound(loc, 'sound/weapons/bombarda/pump.ogg', 60, TRUE)
	if(opened)
		opened = FALSE
		user.balloon_alert(user, "закрыто!")
	else
		opened = TRUE
		user.balloon_alert(user, "открыто!")
		unload_act(user)
	update_icon()

/obj/item/gun/projectile/revolver/rsh_12/update_icon_state()
	icon_state = "[initial(icon_state)][opened ? "_open" : ""]"

/obj/item/gun/projectile/revolver/rsh_12/can_shoot(mob/user)
	. = ..()
	if(. && opened)
		return FALSE

/obj/item/gun/projectile/revolver/rsh_12/attackby(obj/item/item, mob/user, params)
	if(!opened && isammocasing(item))
		user.balloon_alert(user, "барабан закрыт!")
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/gun/projectile/revolver/rsh_12/admin
	pb_knockback = 3
	starting_attachment_types = list(
		/obj/item/gun_module/rail/scope/collimator/pistol,
		/obj/item/gun_module/under/laser/point,
	)
