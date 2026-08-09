// Оружие Mountain Wars. Баланс по ГДД: M4 22, M249 20, АКМ 35, Мосинка 75.
// Спрайты винтовок и гранатомётов портированы из TerraGov Marine Corps
// (github.com/tgstation/TerraGov-Marine-Corps), ассеты под CC BY-NC-SA 3.0.
// Пулемёт и мосинка используют родные спрайты Paradise.
//
// В спрайтах TGMC суффикс "_e" = без магазина, поэтому состояние иконки
// считаем по `magazine`, а не по `chambered` (патрон в патроннике остаётся
// после извлечения магазина, из-за чего спрайт не менялся).

// MARK: Магазины
// Названия магазинов собираются из `gun_name` + маркировки патрона, поэтому
// правим их, а не `name`.

// M249 — 5,56x45 NATO. Родной l6saw-магазин заряжен 7,62x51, что и вылезало в
// названии. Баллистику не меняем: пуля та же, что у L6 SAW.
/obj/item/ammo_casing/a556/mw_saw
	projectile_type = /obj/projectile/bullet/saw/weak

/obj/item/ammo_box/magazine/l6saw/mw_m249
	gun_name = "пулемёта M249 SAW"
	ammo_type = /obj/item/ammo_casing/a556/mw_saw
	caliber = CALIBER_5_DOT_56X45MM

// АКМ — 7,62x39. Родной ak814-магазин это АК-814 под 5,45x39: и маркировка
// патрона, и жёстко прописанное в его get_ru_names() название вылезали в игре.
// Наследуемся от корня, чтобы имя собиралось штатно из gun_name и маркировки.
/obj/item/ammo_casing/mw_akm
	ammo_marking = "7,62x39 мм"
	caliber = CALIBER_7_DOT_62X39MM
	projectile_type = /obj/projectile/bullet/midbullet3
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL

/obj/item/ammo_box/magazine/mw_akm
	gun_name = "АКМ"
	icon_state = "ak814"
	ammo_type = /obj/item/ammo_casing/mw_akm
	caliber = CALIBER_7_DOT_62X39MM
	max_ammo = 30
	multiple_sprites = 2

// M16A4 — STANAG на 30. Спрайт из TGMC (icons/obj/items/ammo/rifle.dmi, стейт
// "m16"): родной "5.56m" рисует не магазин, а цилиндр.
/obj/item/ammo_box/magazine/m556/mw_m16a4
	gun_name = "M16A4"
	extra_info = "Штатный магазин STANAG."
	icon = 'icons/mountain_wars/ammo_mags.dmi'
	icon_state = "m16"
	multiple_sprites = 0

// Пустой магазин отличается от полного. Штатный multiple_sprites сюда не годится:
// он умеет только суффикс "-[патронов]", а в спрайтах TGMC пустой кадр это "_e".
/obj/item/ammo_box/magazine/m556/mw_m16a4/update_icon_state()
	icon_state = "m16[length(stored_ammo) ? "" : "_e"]"

// MARK: M16A4 (Морпехи) — 5,56x45, точная, отсечка по три
// Автоматического огня у неё нет: на M16A4 стоит именно отсечка, и морпеху она
// подходит больше, чем шквал — плотность огня в отряде даёт пулемётчик.
/obj/item/gun/projectile/automatic/arg/mw_m16a4
	name = "M16A4"
	desc = "Штурмовая винтовка Корпуса морской пехоты. Точная, с мягкой отдачей. Одиночными или отсечкой по три."
	icon = 'icons/mountain_wars/guns_rifles.dmi'
	icon_state = "m16a4"
	item_state = "m16a4"
	lefthand_file = 'icons/mountain_wars/inhands_rifles_left.dmi'
	righthand_file = 'icons/mountain_wars/inhands_rifles_right.dmi'
	mag_type = /obj/item/ammo_box/magazine/m556/mw_m16a4
	damage_mod = 0.611 // 36 -> 22
	recoil = GUN_RECOIL_LOW
	accuracy = GUN_ACCURACY_RIFLE_UPLINK
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE)
	burst_amount = 3
	// Из всех модулей винтовке разрешён только подствол — под него есть и планка,
	// и спрайт. Рельса и дуло закрыты: оверлеев под них в спрайтшите TGMC нет.
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_UNDER
	starting_attachment_types = list(/obj/item/gun_module/rail/scope/mw/iron)
	// Посадка модулей своя, а не родительская от ARG. Итоговый сдвиг оверлея — это
	// сумма посадки оружия и overlay_offset модуля, а числа ARG (8, -5) подогнаны под
	// парадайзовский спрайт в кадре 32x32. Наш кадр 64x32 и рисунок другой, так что
	// от них подствол уезжал вправо и вниз. Всё смещение держим на модуле, здесь нули.
	attachable_offset = list(
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 0),
	)

/obj/item/gun/projectile/automatic/arg/mw_m16a4/update_icon_state()
	icon_state = "m16a4[magazine ? "" : "_e"]"

// Родительский проц навешивает оверлеи режима огня из спрайтшита Paradise — в файлах
// TGMC их нет, поэтому собираем список сами. Модули при этом рисоваться должны:
// вернуть пустой список — значит стереть и подствол.
/obj/item/gun/projectile/automatic/arg/mw_m16a4/update_overlays()
	. = list()
	for(var/slot, overlay in attachment_overlays)
		if(overlay)
			. += overlay

// MARK: M203 — подствольный гранатомёт
// Механика подствола в Paradise своя и рабочая: модуль в слот ATTACHMENT_SLOT_UNDER
// с гранатомётом внутри, выстрел правой кнопкой, перезарядка выстрелом по стволу.
// Берём её как есть, меняем только боеприпас.
//
// Штатный 40 мм HE поджигает всё в трёх клетках. Для горного склона это лишнее:
// каждый выстрел оставлял бы пожар, а тушить его некому и нечем. Свой снаряд —
// та же фугасность без огня.
/obj/projectile/bullet/mw_40mm
	name = "40мм граната"
	icon_state = "bolter"
	damage = 60
	ricochets_max = 0

/obj/projectile/bullet/mw_40mm/on_hit(atom/target, blocked = 0)
	. = ..()
	explosion(
		target,
		devastation_range = -1,
		heavy_impact_range = 0,
		light_impact_range = 2,
		flash_range = 1,
		cause = "[type] fired by [key_name(firer)]",
	)

/obj/item/ammo_casing/a40mm/mw_he
	extra_info = "Осколочно-фугасный выстрел к подствольному гранатомёту."
	projectile_type = /obj/projectile/bullet/mw_40mm

/obj/item/ammo_box/magazine/internal/grenadelauncher/mw
	ammo_type = /obj/item/ammo_casing/a40mm/mw_he

/obj/item/gun/projectile/revolver/grenadelauncher/mw_m203
	name = "M203"
	mag_type = /obj/item/ammo_box/magazine/internal/grenadelauncher/mw

// Спрайты подствола из TGMC: icons/obj/items/guns/attachments/gun.dmi, стейты
// "grenade" и "grenade_a" (суффикс _a у них означает кадр оверлея на стволе).
/obj/item/gun_module/under/gun/grenade_launcher/mw_m203
	name = "M203"
	desc = "Подствольный гранатомёт под 40 мм выстрел. Один заряд: выстрелил — перезаряжай."
	icon = 'icons/mountain_wars/attachments.dmi'
	icon_state = "m203"
	// В руках модуль рисуется общим спрайтом планки: своего кадра для подствола в
	// инхендах Paradise нет, а без item_state рука выходит пустой.
	item_state = "comp"
	overlay_state = "m203_o"
	// Посадка взята из самого TGMC, а не подобрана на глаз: у них оверлей ставится
	// как attachable_offset["under_*"] оружия минус pixel_shift_* модуля. Для M16A4
	// это 29-14 по X и 15-18 по Y. Спрайты те же, значит и числа те же.
	overlay_offset = list(ATTACHMENT_OFFSET_X = 15, ATTACHMENT_OFFSET_Y = -3)
	internal_gun_type = /obj/item/gun/projectile/revolver/grenadelauncher/mw_m203

// Заряжен подствол или пуст, видно по стволу — отдельные кадры есть и у самого
// модуля, и у оверлея. Слушаем перерисовку внутреннего ствола: её зовут и после
// выстрела (gun.dm, конец process_fire), и после зарядки, и после разрядки, так
// что одного сигнала хватает на все три случая.
/obj/item/gun_module/under/gun/grenade_launcher/mw_m203/Initialize(mapload)
	. = ..()
	if(internal_gun)
		RegisterSignal(internal_gun, COMSIG_ATOM_UPDATE_ICON, PROC_REF(on_internal_gun_updated))

/**
 * Выстрел из подствола.
 *
 * Базовый модуль стреляет через start_fire(), а тот на пятой проверке требует, чтобы
 * стреляющий ствол лежал в активной руке:
 *
 *   if(!user.is_in_active_hand(src) && user.a_intent != INTENT_HARM)
 *
 * Подствол лежит не в руке, а в винтовке. Значит выстрел проходил только в интенте
 * вреда и молча не проходил во всех остальных — то есть «не стреляет».
 *
 * fast_fire() идёт сразу в process_fire, мимо проверок руки и отката. Отката тут и не
 * надо: заряд один, после выстрела гранатомёт всё равно перезаряжают вручную. Пустой
 * патронник и пацифизм process_fire проверяет сам.
 */
/obj/item/gun_module/under/gun/grenade_launcher/mw_m203/fire_internal_gun(obj/item/item, mob/user, atom/target, list/modifiers)
	if(!internal_gun || QDELETED(target))
		return
	internal_gun.fast_fire(target, user)

/obj/item/gun_module/under/gun/grenade_launcher/mw_m203/proc/on_internal_gun_updated(datum/source)
	SIGNAL_HANDLER
	update_icon(UPDATE_ICON_STATE)
	gun?.add_attachment_overlay(src)

/obj/item/gun_module/under/gun/grenade_launcher/mw_m203/update_icon_state()
	icon_state = "m203[is_loaded() ? "" : "_e"]"

// Без буфера, в отличие от базового проца: кадр меняется на каждый выстрел, и
// закэшированная картинка осталась бы от прошлого состояния.
/obj/item/gun_module/under/gun/grenade_launcher/mw_m203/create_overlay()
	return mutable_appearance(icon, "m203[is_loaded() ? "" : "_e"]_o", layer = FLOAT_LAYER - 1)

/// Есть ли в стволе живая граната. Штатный get_ammo() тут врёт: он считает и
/// стреляную гильзу, которая после выстрела остаётся в патроннике.
/obj/item/gun_module/under/gun/grenade_launcher/mw_m203/proc/is_loaded()
	var/obj/item/gun/projectile/launcher = internal_gun
	if(!istype(launcher))
		return FALSE
	if(launcher.chambered?.BB)
		return TRUE
	return launcher.magazine?.ammo_count(FALSE)

/obj/item/gun_module/under/gun/grenade_launcher/mw_m203/get_ru_names()
	return alist(
		NOMINATIVE = "гранатомёт M203",
		GENITIVE = "гранатомёта M203",
		DATIVE = "гранатомёту M203",
		ACCUSATIVE = "гранатомёт M203",
		INSTRUMENTAL = "гранатомётом M203",
		PREPOSITIONAL = "гранатомёте M203",
	)

/obj/item/gun/projectile/automatic/arg/mw_m16a4/m203
	desc = "Штурмовая винтовка Корпуса морской пехоты с подствольным гранатомётом M203. Кнопка «Гранатомёт» — навести и ударить."
	// Список переопределяется целиком, поэтому прицельные приходится повторять.
	starting_attachment_types = list(
		/obj/item/gun_module/rail/scope/mw/iron,
		/obj/item/gun_module/under/gun/grenade_launcher/mw_m203,
	)
	actions_types = list(/datum/action/item_action/mw_m203)

/obj/item/gun/projectile/automatic/arg/mw_m16a4/m203/examine(mob/user)
	. = ..()
	var/obj/item/gun_module/under/gun/grenade_launcher/mw_m203/launcher = attachments_by_slot?[ATTACHMENT_SLOT_UNDER]
	if(istype(launcher))
		. += span_notice(launcher.is_loaded() ? "Гранатомёт заряжен." : "Гранатомёт пуст.")

// Стрельба из подствола идёт через кнопку с наведением, а не правым кликом. Правый
// клик до модуля не доходит: у оружия в руках клики забирает сам ствол, и по дороге
// к сигналу COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM_SECONDARY выстрел теряется.
// Кнопка вешает на клиента перехват — тот же приём, что у турели техники, — и первый
// же клик по цели уходит гранатой. Перехват снимается сам.
/obj/item/gun/projectile/automatic/arg/mw_m16a4/m203/ui_action_click(mob/user, datum/action/action, leftclick)
	if(!istype(action, /datum/action/item_action/mw_m203))
		return ..()
	aim_grenade(user)
	return TRUE

/obj/item/gun/projectile/automatic/arg/mw_m16a4/m203/proc/aim_grenade(mob/living/user)
	if(!user?.client)
		return
	var/datum/click_intercept/mw_m203/aiming = user.client.click_intercept
	if(istype(aiming))
		qdel(aiming)
		balloon_alert(user, "наводка сброшена")
		return
	if(user.client.click_intercept)
		balloon_alert(user, "руки заняты!")
		return
	var/obj/item/gun_module/under/gun/grenade_launcher/mw_m203/launcher = attachments_by_slot?[ATTACHMENT_SLOT_UNDER]
	if(!istype(launcher))
		return
	if(!launcher.is_loaded())
		balloon_alert(user, "гранатомёт пуст!")
		return
	new /datum/click_intercept/mw_m203(user.client, launcher)
	balloon_alert(user, "гранатомёт наведён")

/obj/item/gun/projectile/automatic/arg/mw_m16a4/m203/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	var/datum/click_intercept/mw_m203/aiming = user?.client?.click_intercept
	// Чужой перехват не трогаем: наводка могла быть не от этой винтовки.
	if(istype(aiming) && aiming.launcher?.gun == src)
		qdel(aiming)

/datum/action/item_action/mw_m203
	name = "Гранатомёт"
	desc = "Навести подствольный гранатомёт. Следующий клик по цели — выстрел."

/// Один клик — одна граната. Перехват снимается сразу после выстрела, чтобы боец не
/// остался с заблокированными руками, если промазал по чему-то ненужному.
/datum/click_intercept/mw_m203
	var/obj/item/gun_module/under/gun/grenade_launcher/mw_m203/launcher

/datum/click_intercept/mw_m203/New(client/holder, obj/item/gun_module/under/gun/grenade_launcher/mw_m203/launcher)
	src.launcher = launcher
	return ..(holder)

/datum/click_intercept/mw_m203/Destroy()
	launcher = null
	return ..()

/datum/click_intercept/mw_m203/InterceptClickOn(mob/user, params, atom/object)
	if(QDELETED(launcher) || !isliving(user) || !user.is_in_hands(launcher.gun))
		qdel(src)
		return TRUE
	if(object)
		launcher.fire_internal_gun(launcher.gun, user, object, params2list(params))
	qdel(src)
	return TRUE

// MARK: АКМ (Повстанцы) — 7,62x39, большой урон, высокая отдача
/obj/item/gun/projectile/automatic/ak814/mw_akm
	name = "АКМ"
	desc = "Старый добрый автомат Калашникова. Бьёт больно, но брыкается."
	mag_type = /obj/item/ammo_box/magazine/mw_akm
	icon = 'icons/mountain_wars/guns_rifles.dmi'
	icon_state = "ak47"
	item_state = "ak47"
	lefthand_file = 'icons/mountain_wars/inhands_rifles_left.dmi'
	righthand_file = 'icons/mountain_wars/inhands_rifles_right.dmi'
	damage_mod = 1.061 // 33 -> 35
	recoil = GUN_RECOIL_HIGH
	burst_amount = 1
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	attachable_allowed = 0
	starting_attachment_types = list(/obj/item/gun_module/rail/scope/mw/iron)

// У АКМа магазин нарисован отдельным спрайтом, а не внутри базового, поэтому
// "ak47" и "ak47_e" — одна и та же картинка. Держим базу постоянной и вешаем
// магазин оверлеем. У M16 наоборот: магазин внутри спрайта.
//
// Сливовый бакелит: в TGMC у МПи-КМ по умолчанию стоит именно он
// (default_ammo_type = /obj/item/ammo_magazine/rifle/mpi_km/plum), а "ak_30" —
// это их же чёрный полимер, который на старом автомате смотрится не к месту.
/obj/item/gun/projectile/automatic/ak814/mw_akm/update_icon_state()
	icon_state = "ak47"

/obj/item/gun/projectile/automatic/ak814/mw_akm/update_overlays()
	return magazine ? list("ak_30_plum") : list()

// MARK: ППШ (Повстанцы) — 7,62x25, шквал вблизи и ничего вдали
// Спрайты и диск на 71 патрон родные: ППШ в Paradise уже есть целиком, вместе с
// магазином и звуками, поэтому своего тут только баланс.
//
// Ниша — не «АКМ поменьше», а бой на дистанции броска гранаты: в посёлке, в
// туннелях, в отсеке. Пуля пистолетная, поэтому урон вдвое ниже автоматного, зато
// отдача низкая и диск не кончается. Дальше десятка клеток из него можно только
// шуметь — этим занимается кучность пистолетного датума, она у ППШ уже стоит.
/obj/item/gun/projectile/automatic/smg/ppsh/mw_ppsh
	name = "ППШ"
	desc = "Пистолет-пулемёт Шпагина. Диск на 71 патрон и никакой меткости — оружие ближнего боя и тесноты."
	damage_mod = 2 // 9 -> 18
	recoil = GUN_RECOIL_LOW
	// Отсечки нет: у ППШ переводчик на два положения, одиночные и непрерывный.
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	burst_amount = 1
	starting_attachment_types = list(/obj/item/gun_module/rail/scope/mw/iron)

// MARK: M249 SAW (Морпехи) — лента 100, плотность огня, штраф к ходьбе
// Спрайты родные (l6 SAW): у него есть анимация крышки и лента патронов.
//
// Смысл пулемёта — не бегать с ним, а лечь и держать сектор. С рук он проигрывает
// винтовке по всем статьям и должен проигрывать; отыгрывается всё на сошках.
/// Прибавка к кучности по зонам, когда пулемёт стоит на сошках.
#define MW_BIPOD_ACCURACY 15
/// Насколько при этом поджимается конус разброса.
#define MW_BIPOD_SPREAD 8
/// Множитель темпа стрельбы: лёжа на сошках ствол не уводит, можно чаще.
#define MW_BIPOD_FIRERATE 0.7

/obj/item/gun/projectile/automatic/l6_saw/mw_m249
	name = "M249 SAW"
	desc = "Ручной пулемёт огневой поддержки. Тяжёлый — с ним не побегаешь. Складные сошки: разложить и не двигаться, тогда бьёт кучно и часто."
	mag_type = /obj/item/ammo_box/magazine/l6saw/mw_m249
	damage_mod = 0.667 // 30 -> 20
	slowdown = 0.5
	actions_types = list(/datum/action/item_action/mw_bipod)
	starting_attachment_types = list(/obj/item/gun_module/rail/scope/mw/iron)
	/// Сошки разложены.
	var/bipod_deployed = FALSE
	/// Темп и разброс до раскладки: вернуть надо ровно исходные, а не пересчитанные.
	var/folded_fire_delay
	var/folded_spread

// Один slowdown ничего не делает: держимое в руках замедляет только с флагом
// SLOWS_WHILE_IN_HAND (см. equipped_speed_mods). Ставим в Initialize, чтобы не
// затереть флаги родителя.
/obj/item/gun/projectile/automatic/l6_saw/mw_m249/Initialize(mapload)
	. = ..()
	item_flags |= SLOWS_WHILE_IN_HAND

/obj/item/gun/projectile/automatic/l6_saw/mw_m249/examine(mob/user)
	. = ..()
	. += span_notice(bipod_deployed \
		? "Сошки разложены. Шаг в сторону — и пулемёт с них снимется." \
		: "Сошки сложены.")

/obj/item/gun/projectile/automatic/l6_saw/mw_m249/ui_action_click(mob/user, datum/action/action, leftclick)
	if(istype(action, /datum/action/item_action/mw_bipod))
		if(bipod_deployed)
			fold_bipod(user)
		else
			deploy_bipod(user)
		return TRUE
	return ..()

/obj/item/gun/projectile/automatic/l6_saw/mw_m249/proc/deploy_bipod(mob/living/user)
	if(bipod_deployed || !istype(user))
		return
	bipod_deployed = TRUE
	folded_fire_delay = fire_delay
	folded_spread = accuracy.max_spread
	// Датум кучности у каждого ствола свой (создаётся через new в объявлении вара),
	// так что правка не растекается на остальные пулемёты в раунде.
	accuracy.add_accuracy(MW_BIPOD_ACCURACY)
	accuracy.max_spread = max(0, accuracy.max_spread - MW_BIPOD_SPREAD)
	set_fire_delay(round(folded_fire_delay * MW_BIPOD_FIRERATE))
	// Сошки стоят на земле, а не на стрелке: сдвинулся — снялся.
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_user_moved), override = TRUE)
	playsound(user, 'sound/weapons/gun_interactions/sawopen.ogg', 40, TRUE)
	user.visible_message(
		span_notice("[user] раскладывает сошки [src]."),
		span_notice("Вы раскладываете сошки. Пока стоите на месте — бьёт кучно."))

/obj/item/gun/projectile/automatic/l6_saw/mw_m249/proc/fold_bipod(mob/living/user, silent = FALSE)
	if(!bipod_deployed)
		return
	bipod_deployed = FALSE
	accuracy.add_accuracy(-MW_BIPOD_ACCURACY)
	accuracy.max_spread = folded_spread
	set_fire_delay(folded_fire_delay)
	if(istype(user))
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		if(!silent)
			to_chat(user, span_warning("Пулемёт снят с сошек."))
	playsound(src, 'sound/weapons/gun_interactions/sawclose.ogg', 40, TRUE)

/obj/item/gun/projectile/automatic/l6_saw/mw_m249/proc/on_user_moved(mob/living/user)
	SIGNAL_HANDLER
	fold_bipod(user)

/obj/item/gun/projectile/automatic/l6_saw/mw_m249/dropped(mob/user, slot, silent = FALSE)
	fold_bipod(user, silent = TRUE)
	return ..()

/datum/action/item_action/mw_bipod
	name = "Сошки"
	desc = "Разложить или сложить сошки пулемёта."

#undef MW_BIPOD_ACCURACY
#undef MW_BIPOD_SPREAD
#undef MW_BIPOD_FIRERATE

// MARK: M67 (Морпехи) — ручная осколочная
// Штатная frag Paradise с четырёхсекундным запалом: три секунды на 255-клеточной
// карте означают, что кинувший чаще ложится сам. Радиус осколков ужат — иначе
// граната выкашивает всё звено на открытом склоне.
// Спрайт из TGMC (icons/obj/items/grenade.dmi, стейты "grenade_ex" и его _active).
/obj/item/grenade/frag/mw_m67
	name = "M67"
	desc = "Ручная осколочная граната. Выдернуть чеку, отпустить рычаг, бросить — четыре секунды."
	icon = 'icons/mountain_wars/grenades.dmi'
	icon_state = "m67"
	item_state = "m67"
	lefthand_file = 'icons/mountain_wars/inhands_grenades_left.dmi'
	righthand_file = 'icons/mountain_wars/inhands_grenades_right.dmi'
	det_time = 4 SECONDS
	shrapnel_radius = 3
	range = 4

/obj/item/grenade/frag/mw_m67/get_ru_names()
	return alist(
		NOMINATIVE = "граната M67",
		GENITIVE = "гранаты M67",
		DATIVE = "гранате M67",
		ACCUSATIVE = "гранату M67",
		INSTRUMENTAL = "гранатой M67",
		PREPOSITIONAL = "гранате M67",
	)

// MARK: Винтовка Мосина (Повстанцы) — 7,62x54R, болтовка, 75 урона
// Спрайты родные: у болтовки есть состояние открытого затвора.
//
// Изготовка: постоял на месте — разброс ушёл в ноль, шагнул — вернулся. Так
// болтовка перестаёт быть автоматом для бегущего и начинает работать как то, чем
// она и является: позиция, ожидание, один выстрел. Механика только у мосинки.
/// Сколько стоять неподвижно до нулевого разброса.
#define MW_MOSIN_STEADY_TIME 3 SECONDS
/// Категория экранного индикатора. Одна на моба, поэтому две мосинки в руках не
/// перетирают чужой значок — вторая просто обновит свой же.
#define MW_MOSIN_ALERT "mw_mosin_steady"

/obj/item/gun/projectile/shotgun/boltaction/mw_mosin
	name = "винтовка Мосина"
	desc = "Трёхлинейка с прицелом ПУ. Одно попадание — и конечность можно списывать."
	damage_mod = 1.5 // 50 -> 75
	starting_attachment_types = list(/obj/item/gun_module/rail/scope/mw/pu)
	/// Ствол замер, разброса нет.
	var/steady = FALSE
	/// Разброс на ходу. Читается с датума кучности при создании: он свой у каждой
	/// винтовки, так что правка не растекается на остальные мосинки в раунде.
	var/walk_spread = 0
	var/steady_timer
	/// В чьих руках винтовка сейчас. По нему ловим шаги и ему показываем значок.
	var/mob/living/holder

/obj/item/gun/projectile/shotgun/boltaction/mw_mosin/Initialize(mapload)
	. = ..()
	walk_spread = accuracy.max_spread

/obj/item/gun/projectile/shotgun/boltaction/mw_mosin/Destroy()
	release_holder()
	return ..()

/obj/item/gun/projectile/shotgun/boltaction/mw_mosin/examine(mob/user)
	. = ..()
	. += span_notice(steady \
		? "Винтовка стоит намертво: разброса нет." \
		: "Постойте на месте пару секунд — ствол перестанет гулять.")

/obj/item/gun/projectile/shotgun/boltaction/mw_mosin/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		take_holder(user)
	else
		release_holder()

/obj/item/gun/projectile/shotgun/boltaction/mw_mosin/dropped(mob/user, slot, silent = FALSE)
	release_holder()
	return ..()

/obj/item/gun/projectile/shotgun/boltaction/mw_mosin/proc/take_holder(mob/living/user)
	if(holder == user)
		return
	release_holder()
	if(!isliving(user))
		return
	holder = user
	RegisterSignal(holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_holder_moved))
	break_aim()

/obj/item/gun/projectile/shotgun/boltaction/mw_mosin/proc/release_holder()
	if(steady_timer)
		deltimer(steady_timer)
		steady_timer = null
	steady = FALSE
	accuracy.max_spread = walk_spread
	if(!holder)
		return
	UnregisterSignal(holder, COMSIG_MOVABLE_MOVED)
	holder.clear_alert(MW_MOSIN_ALERT)
	holder = null

/obj/item/gun/projectile/shotgun/boltaction/mw_mosin/proc/on_holder_moved()
	SIGNAL_HANDLER
	break_aim()

/// Сбить наводку и начать отсчёт заново. Зовётся на каждый шаг, поэтому дешёвый:
/// throw_alert с той же серьёзностью выходит первой же проверкой.
/obj/item/gun/projectile/shotgun/boltaction/mw_mosin/proc/break_aim()
	steady = FALSE
	accuracy.max_spread = walk_spread
	// Сразу полный конус, а не ноль. Угол выстрела считается из current_spread, а тот
	// набирается очередью: за выстрел прибавляется spread_increase_step. Обнулять его
	// на каждый шаг — значит выдавать болтовке на ходу первый выстрел с разбросом в
	// два градуса, то есть точнее, чем с изготовки. Спад накопленного в этой ветке
	// не реализован вовсе (spread_restore_duration нигде не читается), поэтому «на
	// ходу» — это ровно max_spread.
	accuracy.current_spread = walk_spread
	if(!holder)
		return
	holder.throw_alert(MW_MOSIN_ALERT, /atom/movable/screen/alert/mw_steady, 1)
	deltimer(steady_timer)
	steady_timer = addtimer(CALLBACK(src, PROC_REF(settle)), MW_MOSIN_STEADY_TIME, TIMER_STOPPABLE)

/obj/item/gun/projectile/shotgun/boltaction/mw_mosin/proc/settle()
	steady_timer = null
	if(!holder)
		return
	steady = TRUE
	// Ноль в max_spread — это не «мало», а именно выключенный разброс: при пустом
	// max_spread randomize_spread() выходит сразу, не заглядывая в накопленный.
	accuracy.max_spread = 0
	accuracy.current_spread = 0
	holder.throw_alert(MW_MOSIN_ALERT, /atom/movable/screen/alert/mw_steady, 2)
	holder.balloon_alert(holder, "винтовка замерла")

/atom/movable/screen/alert/mw_steady
	name = "Изготовка"
	desc = "Стойте на месте — винтовка перестанет гулять. Любой шаг сбивает наводку."
	icon = 'icons/mountain_wars/screen_alerts.dmi'
	icon_state = "mw_steady"

#undef MW_MOSIN_STEADY_TIME
#undef MW_MOSIN_ALERT

// MARK: Прицеливание
// Механика оптики в Paradise готовая: модуль в слот планки двигает экран вперёд и
// вешает кнопку. Берём её как есть и правим одно — поворот.
//
// Штатный zoom считает смещение экрана один раз, по направлению в момент включения.
// Для снайпера, который лёг и смотрит в одну сторону, этого хватало. Для прицела на
// каждом стволе — нет: повернулся, и вместо цели смотришь себе за спину, пока не
// выключишь и не включишь заново. Пересчитываем на каждый поворот.
//
// Снять модуль нельзя: прицельные и кронштейн — часть ствола, а отвинченные они на
// поле боя просто потеряются.
/obj/item/gun_module/rail/scope/mw
	can_detach = FALSE
	// Разброс прицеливание не трогает, хотя у станционной оптики трогает. Модуль
	// правит max_spread прибавкой, а изготовка мосинки и сошки пулемёта выставляют
	// его абсолютным числом: свёл и развёл прицел между их переключениями — и вместо
	// исходного разброса получил остаток от прибавки. Точность идёт бонусом к зонам,
	// он относительный и с ними складывается без последствий.
	spread_decrease_mod = 0

/obj/item/gun_module/rail/scope/mw/on_enter_sight_mode(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_ATOM_POST_DIR_CHANGE, PROC_REF(on_user_turn), override = TRUE)

/obj/item/gun_module/rail/scope/mw/on_leave_sight(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_ATOM_POST_DIR_CHANGE)

/obj/item/gun_module/rail/scope/mw/proc/on_user_turn(mob/living/user)
	SIGNAL_HANDLER
	// forced = TRUE, а не переключение: zoom при совпадении состояния не шлёт сигнал,
	// то есть не дёргает on_enter_sight_mode по кругу — просто пересчитывает экран.
	if(gun?.zoomed)
		gun.zoom(user, TRUE)

// Механические прицельные — на всё оружие режима, кроме мосинки с её ПУ. Две клетки:
// заглянуть за край обзора, а не простреливать полкарты. Своего спрайта у них нет и
// поверх ствола они не рисуются: это мушка и целик, они и так на стволе нарисованы.
/obj/item/gun_module/rail/scope/mw/iron
	name = "механические прицельные"
	desc = "Мушка и целик. Прицеливание чуть тянет обзор вперёд."
	// Не забыть: у базового модуля overlay_state = "comp", то есть по умолчанию он
	// клеит на ствол компенсатор. Здесь рисовать нечего — и не только ради вида:
	// посадку оверлея гранатомёты и пулемёт не считают вовсе, планки в их
	// attachable_offset нет, и оверлей ронял их инициализацию.
	overlay_state = null
	bonus_accuracy = 5
	movespeed_slowdown = 0.5
	zoom_amount = 2

// Прицел ПУ мосинки. Стёкла x4 без его типа: от родителя нужны были только цифры,
// а разброс и поворот здесь свои.
/obj/item/gun_module/rail/scope/mw/pu
	name = "прицел ПУ"
	desc = "Короткий оптический прицел на кронштейне. Даёт заглянуть за гребень, но с ним не побегаешь."
	icon_state = "x4"
	item_state = "x4"
	overlay_state = "x4_o"
	bonus_accuracy = 10
	movespeed_slowdown = 1.6
	zoom_amount = 5
	// Штатная посадка х4 рассчитана на другие стволы: на мосинке прицел висел над
	// цевьём в воздухе. Итоговый сдвиг складывается из планки оружия (7, 4 у болтовки)
	// и этой пары, то есть выходит 5 вправо и 3 вверх — прицел ложится на ствольную
	// коробку. Правил спрайт винтовки — пересчитай.
	overlay_offset = list(ATTACHMENT_OFFSET_X = -2, ATTACHMENT_OFFSET_Y = -1)

/obj/item/gun_module/rail/scope/mw/pu/get_ru_names()
	return alist(
		NOMINATIVE = "прицел ПУ",
		GENITIVE = "прицела ПУ",
		DATIVE = "прицелу ПУ",
		ACCUSATIVE = "прицел ПУ",
		INSTRUMENTAL = "прицелом ПУ",
		PREPOSITIONAL = "прицеле ПУ",
	)

// MARK: РПГ-7 (Повстанцы) — многоразовый, 84мм HE/HEDP
// Магента в спрайте "rpg" — это плейсхолдер: TGMC рисует боевую часть отдельным
// оверлеем поверх пустой трубы. Поэтому база — чистый "rpg_e", а ракета
// накладывается оверлеем "rpg_he", когда гранатомёт заряжен.
// Инхенды родные: "спрайты в руках" у TGMC для тяжёлого оружия — это
// маркеры дула, а не held-спрайты, они рендерятся другой системой.
/obj/item/gun/projectile/revolver/rocketlauncher/mw_rpg7
	name = "РПГ-7"
	desc = "Многоразовый ручной противотанковый гранатомёт. Заряжается ракетами HE (пехота) и HEDP (техника)."
	icon = 'icons/mountain_wars/guns_special.dmi'
	icon_state = "rpg_e"
	starting_attachment_types = list(/obj/item/gun_module/rail/scope/mw/iron)

// Родительский проц клеит оверлей "[icon_state]_empty", которого в спрайтшите
// TGMC нет — поэтому список собираем сами.
/obj/item/gun/projectile/revolver/rocketlauncher/mw_rpg7/update_overlays()
	return chambered ? list("rpg_he") : list()

// Выстрел и разряжание не трогают иконку сами — оверлей ракеты иначе залипает.
/obj/item/gun/projectile/revolver/rocketlauncher/mw_rpg7/process_chamber(eject_casing = FALSE, empty_chamber = TRUE)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/gun/projectile/revolver/rocketlauncher/mw_rpg7/unload_act(mob/user)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

// MARK: M72 LAW (Морпехи) — одноразовый тубус
// Носится сложенным: в таком виде влезает в рюкзак, но не стреляет. Раскладка
// необратима, как у настоящей трубы — раскрыл, значит дальше несёшь в руках.
// В спрайтшите TGMC под это лежат все четыре состояния: t72, t72_e и то же
// с _extended.
/obj/item/gun/projectile/revolver/rocketlauncher/mw_law
	name = "M72 LAW"
	desc = "Одноразовый противотанковый гранатомёт. Сложенный тубус влезает в рюкзак, но перед выстрелом его надо разложить — и обратно он уже не сложится."
	icon = 'icons/mountain_wars/guns_special.dmi'
	icon_state = "t72"
	mag_type = /obj/item/ammo_box/magazine/internal/rocketlauncher/mw_law
	starting_attachment_types = list(/obj/item/gun_module/rail/scope/mw/iron)
	// Сложенный проходит по габариту рюкзака: у того max_w_class как раз NORMAL.
	w_class = WEIGHT_CLASS_NORMAL
	/// Тубус разложен и готов к выстрелу. Обратно не складывается.
	var/extended = FALSE

/obj/item/ammo_box/magazine/internal/rocketlauncher/mw_law
	ammo_type = /obj/item/ammo_casing/caseless/rocket/hedp

/obj/item/gun/projectile/revolver/rocketlauncher/mw_law/update_icon_state()
	icon_state = "t72[extended ? "_extended" : ""][(chambered || magazine?.ammo_count()) ? "" : "_e"]"

/obj/item/gun/projectile/revolver/rocketlauncher/mw_law/update_overlays()
	return list()

/obj/item/gun/projectile/revolver/rocketlauncher/mw_law/examine(mob/user)
	. = ..()
	. += span_notice(extended \
		? "Тубус разложен. Сложить обратно уже не выйдет." \
		: "Тубус сложен и в таком виде не выстрелит. Разложить: активировать в руке.")

// Родительский attack_self вытряхивает магазин наружу. Тубусу это не нужно вдвойне:
// он одноразовый, а вытащенную ракету иначе можно было бы переставить в РПГ-7.
/obj/item/gun/projectile/revolver/rocketlauncher/mw_law/attack_self(mob/living/user)
	add_fingerprint(user)
	if(extended)
		balloon_alert(user, "уже разложен!")
		return TRUE
	extended = TRUE
	w_class = WEIGHT_CLASS_BULKY
	playsound(loc, 'sound/weapons/gun_interactions/shotgunpump.ogg', 50, TRUE)
	balloon_alert(user, "тубус разложен")
	update_icon(UPDATE_ICON_STATE)
	return TRUE

// Гасим выстрел до can_shoot: тот на отказ играет сухой щелчок, а сложенный тубус
// не «пустой», и стрелка надо ткнуть носом именно в это.
/obj/item/gun/projectile/revolver/rocketlauncher/mw_law/can_trigger_gun(mob/living/user)
	if(!extended)
		balloon_alert(user, "тубус сложен!")
		return FALSE
	return ..()

/obj/item/gun/projectile/revolver/rocketlauncher/mw_law/attackby(obj/item/I, mob/user, params)
	if(isammobox(I) || isammocasing(I))
		balloon_alert(user, "одноразовый тубус!")
		return ATTACK_CHAIN_PROCEED
	return ..()
