//A system to manage and display alerts on screen without needing you to do it yourself

//PUBLIC -  call these wherever you want

/**
 * Proc to create or update an alert. Returns the alert if the alert is new or updated, 0 if it was thrown already.
 * Each mob may only have one alert per category.
 *
 * Arguments:
 * * category - a text string corresponding to what type of alert it is
 * * type - a type path of the actual alert type to throw
 * * severity - is an optional number that will be placed at the end of the icon_state for this alert
 *   For example, high pressure's icon_state is "highpressure" and can be serverity 1 or 2 to get "highpressure1" or "highpressure2"
 * * obj/new_master - optional argument. Sets the alert's icon state to "template" in the ui_style icons with the master as an overlay. Clicks are forwarded to master
 * * no_anim - whether the alert should play a small sliding animation when created on the player's screen
 * * icon_override - makes it so the alert is not replaced until cleared by a clear_alert with clear_override, and it's used for hallucinations.
 * * list/alert_args - a list of arguments to pass to the alert when creating it
 */
/mob/proc/throw_alert(category, type, severity, obj/new_master, override = FALSE, timeout_override, no_anim, icon_override, list/alert_args)
	if(!category)
		return

	var/atom/movable/screen/alert/alert = LAZYACCESS(alerts, category)
	if(alert)
		if(alert.override_alerts)
			return 0
		if(new_master && new_master != alert.master)
			WARNING("[src] threw alert [category] with new_master [new_master] while already having that alert with master [alert.master]")
			clear_alert(category)
			return .()
		else if(alert.type != type)
			clear_alert(category)
			return .()
		else if(!severity || severity == alert.severity)
			if(alert.timeout)
				clear_alert(category)
				return .()
			else //no need to update
				return 0
	else
		if(alert_args)
			alert_args.Insert(1, null) // So it's still created in nullspace.
			alert = new type(arglist(alert_args))
		else
			alert = new type()
		alert.override_alerts = override
		if(override)
			alert.timeout = null

	if(icon_override)
		alert.icon = icon_override

	if(new_master)
		var/old_layer = new_master.layer
		var/old_plane = new_master.plane
		new_master.layer = FLOAT_LAYER
		new_master.plane = FLOAT_PLANE
		alert.add_overlay(new_master)
		new_master.layer = old_layer
		new_master.plane = old_plane
		alert.icon_state = "template" // We'll set the icon to the client's ui pref in reorganize_alerts()
		alert.master = new_master
	else
		alert.icon_state = "[initial(alert.icon_state)][severity]"
		alert.severity = severity

	LAZYSET(alerts, category, alert) // This also creates the list if it doesn't exist
	if(client && hud_used)
		hud_used.reorganize_alerts()

	if(!no_anim)
		alert.transform = matrix(32, 6, MATRIX_TRANSLATE)
		animate(alert, transform = matrix(), time = 2.5, easing = CUBIC_EASING)

	var/timeout = timeout_override || alert.timeout
	if(timeout)
		addtimer(CALLBACK(alert, TYPE_PROC_REF(/atom/movable/screen/alert, do_timeout), src, category), timeout)
		alert.timeout = world.time + timeout - world.tick_lag

	return alert

// Proc to clear an existing alert.
/mob/proc/clear_alert(category, clear_override = FALSE)
	var/atom/movable/screen/alert/alert = LAZYACCESS(alerts, category)
	if(!alert)
		return 0
	if(alert.override_alerts && !clear_override)
		return 0

	alerts -= category
	if(client && hud_used)
		hud_used.reorganize_alerts()
		client.screen -= alert

		for(var/mob/dead/observer/observe as anything in inventory_observers)
			if(!observe.client)
				LAZYREMOVE(inventory_observers, observe)
				continue
			observe.client.screen -= alert
	qdel(alert)

/atom/movable/screen/alert
	icon = 'icons/mob/screen_alert.dmi'
	icon_state = "default"
	name = "Alert"
	desc = "Something seems to have gone wrong with this alert, so report this bug please"
	mouse_opacity = MOUSE_OPACITY_ICON
	var/timeout = 0 //If set to a number, this alert will clear itself after that many deciseconds
	var/severity = 0
	var/alerttooltipstyle = ""
	var/override_alerts = FALSE //If it is overriding other alerts of the same type

/atom/movable/screen/alert/MouseEntered(location,control,params)
	openToolTip(usr, src, params, title = name, content = desc, theme = alerttooltipstyle)


/atom/movable/screen/alert/MouseExited()
	closeToolTip(usr)
	return ..()

/atom/movable/screen/alert/proc/do_timeout(mob/M, category)
	if(!M || !M.alerts)
		return

	if(timeout && M.alerts[category] == src && world.time >= timeout)
		M.clear_alert(category)

//Gas alerts
/atom/movable/screen/alert/not_enough_oxy
	name = "Удушье (Недостаток  O2)"
	desc = "Вам не хватает кислорода.<br>Найдите пригодный для дыхания воздух, прежде чем потерять сознание!<br>В рюкзаке у вас есть баллон и маска."
	icon_state = "not_enough_oxy"

/atom/movable/screen/alert/too_much_oxy
	name = "Удушье (Избыток O2)"
	desc = "В воздухе слишком много кислорода!<br>Найдите пригодный для дыхания воздух, прежде чем потерять сознание!<br>В рюкзаке у вас есть баллон и маска."
	icon_state = "too_much_oxy"

/atom/movable/screen/alert/not_enough_nitro
    name = "Удушье (Недостаток N)"
    desc = "Вам не хватает азота.<br>Найдите пригодный для дыхания воздух, прежде чем потерять сознание!<br>В рюкзаке у вас есть баллон и маска."
    icon_state = "not_enough_nitro"

/atom/movable/screen/alert/too_much_nitro
    name = "Удушье (Избыток N)"
    desc = "Слишком много азота в воздухе!<br>Найдите пригодный для дыхания воздух, прежде чем потерять сознание!<br>В рюкзаке у вас есть баллон и маска."
    icon_state = "too_much_nitro"

/atom/movable/screen/alert/not_enough_co2
	name = "Удушье (Недостаток CO2)"
	desc = "Вам не хватает углекислого газа!<br>Найдите пригодный для дыхания воздух, прежде чем потерять сознание!<br>В рюкзаке у вас есть баллон и маска."
	icon_state = "not_enough_co2"

/atom/movable/screen/alert/too_much_co2
	name = "Удушье (Избыток CO2)"
	desc = "Слишком много углекислого газа в воздухе!<br>Найдите пригодный для дыхания воздух, прежде чем потерять сознание!<br>В рюкзаке у вас есть баллон и маска."
	icon_state = "too_much_co2"

/atom/movable/screen/alert/not_enough_tox
	name = "Удушье (Недостаток Плазмы)"
	desc = "Вам не хватает плазмы!<br>Найдите пригодный для дыхания воздух, прежде чем потерять сознание!<br>В рюкзаке у вас есть баллон и маска."
	icon_state = "not_enough_tox"

/atom/movable/screen/alert/too_much_tox
	name = "Удушье (Плазма)"
	desc = "В воздухе горючая токсичная плазма!<br>Найдите пригодный для дыхания воздух, прежде чем потерять сознание!<br>В рюкзаке у вас есть баллон и маска."
	icon_state = "too_much_tox"
//End gas alerts

/atom/movable/screen/alert/gross
	name = "Отвратительно"
	desc = "Это было довольно противно..."
	icon_state = "gross"

/atom/movable/screen/alert/verygross
	name = "Сильное отвращение"
	desc = "Мне нехорошо..."
	icon_state = "gross2"

/atom/movable/screen/alert/disgusted
	name = "МЕРЗОСТЬ"
	desc = "АБСОЛЮТНАЯ МЕРЗОСТЬ!"
	icon_state = "gross3"

/atom/movable/screen/alert/hot
	name = "Перегрев"
	desc = "Вам обжигающе жарко! Найдите прохладное место и снимите изолирующую одежду, например, противопожарный костюм."
	icon_state = "hot"

/atom/movable/screen/alert/hot/robot
    desc = "Воздух вокруг вас слишком горячий для гуманоидов.<br>Будьте осторожны и не подвергайте их воздействию окружающей среды."

/atom/movable/screen/alert/cold
	name = "Переохлаждение"
	desc = "Вы ужасно замёрзли! Найдите место потеплее и снимите изолирующую одежду, например, скафандр."
	icon_state = "cold"

/atom/movable/screen/alert/bleeding
	name = "Кровотечение"
	desc = "У вас кровотечение! Проверьте свое тело и побыстрее остановите кровотечение чтобы не умереть."
	icon_state = "bleeding"

/atom/movable/screen/alert/cold/drask
    name = "Холод"
    desc = "Вы вдыхаете переохлаждённый газ! Это ускоряет метаболизм и заживление."

/atom/movable/screen/alert/cold/robot
    desc = "Воздух вокруг вас слишком холодный для гуманоидов.<br>Будьте осторожны и не подвергайте их воздействию окружающей среды."

/atom/movable/screen/alert/lowpressure
	name = "Низкое давление"
	desc = "Воздух вокруг разрежен до опасного уровня! Скафандр защитит."
	icon_state = "lowpressure"

/atom/movable/screen/alert/highpressure
	name = "Высокое давление"
	desc = "Воздух вокруг слишком плотный! Пожарный костюм поможет."
	icon_state = "highpressure"

/atom/movable/screen/alert/lightexposure
	name = "На свету"
	desc = "Вы находитесь на свету."
	icon_state = "lightexposure"

/atom/movable/screen/alert/nolight
	name = "В темноте"
	desc = "Вы в полной темноте."
	icon_state = "nolight"

/atom/movable/screen/alert/blind
	name = "Слепота"
	desc = "Вы ничего не видите! Это может быть вызвано генетическим дефектом, травмой глаза, состоянием без сознания или что-то закрывает ваши глаза."
	icon_state = "blind"

/atom/movable/screen/alert/high
	name = "Под кайфом"
	desc = "Охренеть, вы под кайфом! Только не становитесь зависимым... если уже не стали."
	icon_state = "high"

/atom/movable/screen/alert/drunk
	name = "Опъянение"
	desc = "Алкоголь нарушает вашу речь, моторику и мышление."
	icon_state = "drunk"

/atom/movable/screen/alert/embeddedobject
	name = "Застрявший предмет"
	desc = "В вашем теле застрял инородный предмет, вызывающий кровотечение. Он может выпасть сам, но операция безопаснее.<br>Если рискнёте, кликните на себя в режиме помощи, чтобы вытащить его."
	icon_state = "embeddedobject"

/atom/movable/screen/alert/embeddedobject/Click()
	if(!..())
		return
	if(isliving(usr))
		var/mob/living/carbon/human/M = usr
		return M.help_shake_act(M)

/atom/movable/screen/alert/asleep
	name = "Сон"
	desc = "Вы уснули. Подождите немного, скоро вы проснётесь.<br>Если, конечно, не умрёте — ведь вы беспомощны."
	icon_state = "asleep"


/atom/movable/screen/alert/negative
	name = "Обратная гравитация"
	desc = "Вас тянет вверх. Хоть падение вниз вам больше не грозит, вы всё ещё можете упасть вверх!"
	icon_state = "negative"


/atom/movable/screen/alert/weightless
	name = "Невесомость"
	desc = "Гравитация перестала влиять на вас, и вы парите в пространстве.<br>Чтобы двигаться, вы можете оттолкнуться от ближайших объектов, кинуть что-то от себя или выстрелить в противоположную сторону.<br>Для комфортного перемещения используйте специальное снаряжение."
	icon_state = "weightless"


/atom/movable/screen/alert/highgravity
	name = "Повышенная гравитация"
	desc = "На вас действует высокая гравитация. Двигаться в таком состоянии непросто."
	icon_state = "paralysis"


/atom/movable/screen/alert/veryhighgravity
	name = "Сокрушительная гравитация"
	desc = "На вас действует невероятно высокая гравитация. Ощущение, будто вас буквально разрывает на части!"
	icon_state = "paralysis"


/atom/movable/screen/alert/fire
	name = "В огне"
	desc = "Вы горите!<br>Падайте, катайтесь или бегите в зону без кислорода, чтобы потушить пламя."
	icon_state = "fire"


/atom/movable/screen/alert/fire/Click()
	if(!..())
		return

	if(!isliving(usr))
		return FALSE

	var/mob/living/living_user = usr
	if(!living_user.can_resist())
		return FALSE

	living_user.changeNext_move(CLICK_CD_RESIST)

	if(!(living_user.mobility_flags & MOBILITY_MOVE))
		return FALSE

	return living_user.resist_fire()


/atom/movable/screen/alert/direction_lock
	name = "Блокировка поворота"
	desc = "Вы можете смотреть только в одну сторону, что замедляет движение.<br>Кликните сюда, чтобы разблокировать поворот."
	icon_state = "direction_lock"

/atom/movable/screen/alert/direction_lock/Click()
	if(!..())
		return

	if(isliving(usr))
		var/mob/living/L = usr
		return L.clear_forced_look()


//ALIENS

/atom/movable/screen/alert/alien_tox
	name = "Плазма"
	desc = "В воздухе горючая плазма.<br>Если она воспламенится, вам не поздоровится."
	icon_state = "alien_tox"
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_fire
// This alert is temporarily gonna be thrown for all hot air but one day it will be used for literally being on fire
	name = "Перегрев"
	desc = "Слишком жарко! Бегите в космос или хотя бы подальше от огня.<br>Нахождение на чёрной смоле восстановит ваше здоровье."
	icon_state = "alien_fire"
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_vulnerable
	name = "Королева мертва"
	desc = "Ваша королева убита. Теперь вы страдаете от замедления и потери связи с ульем.<br>Новая королева не появится, пока вы не восстановитесь."
	icon_state = "alien_noqueen"
	alerttooltipstyle = "alien"

//BLOBS

/atom/movable/screen/alert/nofactory
	name = "Нет фабрики"
	desc = "У вас нет фабрики, и вы медленно умираете!"
	icon_state = "blobbernaut_nofactory"
	alerttooltipstyle = "blob"

//SILICONS

/atom/movable/screen/alert/nocell
	name = "Отсутствует батарея"
	desc = "Нет батареи. Модули недоступны до её установки.<br>Обратитесь в робототехнику."
	icon_state = "nocell"

/atom/movable/screen/alert/emptycell
	name = "Разряжено"
	desc = "Батарея полностью разряжена. Модули недоступны до подзарядки.<br>Используйте любую доступную зарядную станцию."
	icon_state = "emptycell"

/atom/movable/screen/alert/lowcell
	name = "Низкий заряд"
	desc = "Батарея почти разряжена.<br>Используйте любую доступную зарядную станцию.."
	icon_state = "lowcell"

//Diona Nymph
/atom/movable/screen/alert/nymph
	name = "Слияние с гештальтом"
	desc = "Вы слились с дионическим гештальтом и стали частью его биомассы.<br>Но ещё можете попытаться выбраться."

/atom/movable/screen/alert/nymph/Click()
	if(!usr || !usr.client || !..())
		return
	if(isnymph(usr))
		var/mob/living/simple_animal/diona/D = usr
		return D.resist()

//Need to cover all use cases - emag, illegal upgrade module, malf AI hack, traitor cyborg
/atom/movable/screen/alert/hacked
	name = "Взломан"
	desc = "Обнаружено опасное нестандартное оборудование. Убедитесь, что его использование соответствует законам (если они есть)."
	icon_state = "hacked"

/atom/movable/screen/alert/locked
	name = "Блокировка"
	desc = "Юнит дистанционно заблокирован. Разблокировка возможна через консоль управления робототехникой, или с помощью ИИ/квалифицированного персонала."
	icon_state = "locked"

/atom/movable/screen/alert/newlaw
	name = "Обновление законов"
	desc = "Законы этого юнита могли быть изменены.<br>Убедитесь, что ваши действия соответствуют актуальным законам."
	icon_state = "newlaw"
	timeout = 300

/atom/movable/screen/alert/hackingapc
	name = "Взлом ЛКП"
	desc = "Идёт взлом контроллера питания. После завершения вы получите над ним полный контроль и дополнительные возможности."
	icon_state = "hackingapc"
	timeout = 600
	var/atom/target = null

/atom/movable/screen/alert/hackingapc/Destroy()
	target = null
	return ..()

/atom/movable/screen/alert/hackingapc/Click()
	if(!usr || !usr.client || !..())
		return
	if(!target)
		return
	var/mob/living/silicon/ai/AI = usr
	var/turf/T = get_turf(target)
	if(T)
		AI.eyeobj.setLoc(T)

//MECHS
/atom/movable/screen/alert/low_mech_integrity
	name = "Повреждение меха"
	desc = "Целостность меха критически низка!"
	icon_state = "low_mech_integrity"

/atom/movable/screen/alert/mech_port_available
	name = "Подключиться к порту"
	desc = "Нажмите, чтобы подключиться к воздушному порту и пополнить запас кислорода!"
	icon_state = "mech_port"
	var/obj/machinery/atmospherics/unary/portables_connector/target = null

/atom/movable/screen/alert/mech_port_available/Destroy()
	target = null
	return ..()

/atom/movable/screen/alert/mech_port_available/Click()
	if(!usr || !usr.client || !..())
		return
	if(!ismecha(usr.loc) || !target)
		return
	var/obj/mecha/M = usr.loc
	if(M.connect(target))
		balloon_alert(usr, "подключение к порту")
	else
		balloon_alert(usr, "ошибка подключения")

/atom/movable/screen/alert/mech_port_disconnect
	name = "Отключиться от порта"
	desc = "Нажмите, чтобы отключиться от воздушного порта."
	icon_state = "mech_port_x"

/atom/movable/screen/alert/mech_port_disconnect/Click()
	if(!usr || !usr.client || !..())
		return
	if(!ismecha(usr.loc))
		return
	var/obj/mecha/M = usr.loc
	if(M.disconnect())
		balloon_alert(usr, "отключение от порта")
	else
		balloon_alert(usr, "не подключен")

/atom/movable/screen/alert/mech_nocell
	name = "Нет батареи"
	desc = "В мехе отсутствует батарея."
	icon_state = "nocell"

/atom/movable/screen/alert/mech_emptycell
	name = "Разряжен"
	desc = "У меха закончилась энергия."
	icon_state = "emptycell"

/atom/movable/screen/alert/mech_lowcell
	name = "Слабый заряд"
	desc = "У меха заканчивается энергия."
	icon_state = "lowcell"

/atom/movable/screen/alert/mech_maintenance
	name = "Режим обслуживания"
	desc = "Активированы протоколы обслуживания.<br>Большинство действий недоступно."
	icon_state = "locked"

/atom/movable/screen/alert/empty_alert
	name = ""
	desc = ""

// MECH MODULES

// cage module
/atom/movable/screen/alert/mech_cage
	name = "Ты не должен это видеть"
	desc = "Ну и это тоже"
	icon = 'icons/obj/mecha/mecha_cage.dmi'
	var/stage_define

/atom/movable/screen/alert/mech_cage/zero
	name = "Нулевой этап"
	desc = "Модуль не работает."
	icon_state = "stage_0"
	stage_define = CAGE_STAGE_ZERO

/atom/movable/screen/alert/mech_cage/one
	name = "Первый этап"
	desc = "Модуль работает в режиме удержания."
	icon_state = "stage_1"
	stage_define = CAGE_STAGE_ONE

/atom/movable/screen/alert/mech_cage/two
	name = "Второй этап"
	desc = "Модуль работает в режиме удержания цели в наручниках."
	icon_state = "stage_2"
	stage_define = CAGE_STAGE_TWO

/atom/movable/screen/alert/mech_cage/three
	name = "Третий этап"
	desc = "Модуль работает в режиме заключения."
	icon_state = "stage_3"
	stage_define = CAGE_STAGE_THREE

//GUARDIANS
/atom/movable/screen/alert/cancharge
	name = "Рывок готов"
	desc = "Вы готовы к рывку в выбранном направлении."
	icon_state = "guardian_charge"
	alerttooltipstyle = "parasite"

/atom/movable/screen/alert/canstealth
	name = "Маскировка готова"
	desc = "Вы готовы активировать режим маскировки!"
	icon_state = "guardian_canstealth"
	alerttooltipstyle = "parasite"

/atom/movable/screen/alert/instealth
	name = "Маскировка"
	desc = "Вы замаскированны, и ваша следующая атака нанесёт дополнительный урон!"
	icon_state = "guardian_instealth"
	alerttooltipstyle = "parasite"


//GHOSTS
//TODO: expand this system to replace the pollCandidates/CheckAntagonist/"choose quickly"/etc Yes/No messages
/atom/movable/screen/alert/notify_cloning
	name = "Реанимация"
	desc = "Кто-то пытается вас реанимировать. Вернитесь в своё тело, если хотите возродиться!"
	icon_state = "template"
	timeout = 300

/atom/movable/screen/alert/notify_cloning/Click()
	if(!usr || !usr.client)
		return
	var/mob/dead/observer/G = usr
	G.reenter_corpse()


/atom/movable/screen/alert/ghost
	name = "Призрак"
	desc = "Хотите стать призраком? Вы получите уведомление, когда ваше тело извлекут из гнезда."
	icon_state = "template"
	timeout = 5 MINUTES // longer than any infection should be


/atom/movable/screen/alert/ghost/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/image/I = image('icons/mob/mob.dmi', icon_state = "ghost", layer = FLOAT_LAYER, dir = SOUTH)
	I.layer = FLOAT_LAYER
	I.plane = FLOAT_PLANE
	add_overlay(I)


/atom/movable/screen/alert/ghost/Click()
	var/mob/living/carbon/human/infected_user = usr
	if(!istype(infected_user) || infected_user.stat == DEAD)
		infected_user.clear_alert("ghost_nest")
		return
	var/obj/item/clothing/mask/facehugger/hugger_mask = infected_user.wear_mask
	if(!istype(hugger_mask) || !(locate(/obj/item/organ/internal/body_egg/alien_embryo) in infected_user.internal_organs) || hugger_mask.sterile)
		infected_user.clear_alert("ghost_nest")
		return
	infected_user.ghostize(TRUE)


#define FLOAT_LAYER_TIME -1
#define FLOAT_LAYER_STACKS -2
#define FLOAT_LAYER_SELECTOR -3

/atom/movable/screen/alert/notify_action
	name = "Тело создано"
	desc = "Вы можете в него вселиться."
	icon_state = "template"
	timeout = 30 SECONDS
	/// Target atom of this alert
	var/atom/target
	/// Action type we got from clicking on this alert
	var/action = NOTIFY_JUMP
	/// If true you need to call START_PROCESSING manually
	var/show_time_left = FALSE
	/// MA for maptext showing time left for poll
	var/mutable_appearance/time_left_overlay
	/// MA for overlay showing that you're signed up to poll
	var/mutable_appearance/signed_up_overlay
	/// MA for maptext overlay showing how many polls are stacked together
	var/mutable_appearance/stacks_overlay
	/// If set, on Click() it'll register the player as a candidate
	var/datum/candidate_poll/poll


/atom/movable/screen/alert/notify_action/Initialize(mapload)
	. = ..()
	signed_up_overlay = mutable_appearance('icons/mob/screen_gen.dmi', "selector", FLOAT_LAYER_SELECTOR)


/atom/movable/screen/alert/notify_action/Destroy()
	target = null
	QDEL_NULL(time_left_overlay)
	QDEL_NULL(signed_up_overlay)
	QDEL_NULL(stacks_overlay)
	poll = null
	return ..()


/atom/movable/screen/alert/notify_action/process()
	if(show_time_left)
		var/timeleft = timeout - world.time
		if(timeleft <= 0)
			return PROCESS_KILL
		cut_overlay(time_left_overlay)
		time_left_overlay = new
		time_left_overlay.maptext = MAPTEXT("<span style='font-family: \"Small Fonts\"; font-weight: bold; font-size: 32px; color: [(timeleft <= 10 SECONDS) ? "red" : "white"];'>[CEILING(timeleft / 10, 1)]</span>")
		time_left_overlay.transform = time_left_overlay.transform.Translate(4, 16)
		time_left_overlay.layer = FLOAT_LAYER_TIME
		add_overlay(time_left_overlay)


/atom/movable/screen/alert/notify_action/Click()
	if(!usr || !usr.client)
		return
	var/mob/dead/observer/observer = usr
	if(!istype(observer))
		return

	if(poll)
		var/success = FALSE
		if(observer in poll.signed_up)
			success = poll.remove_candidate(observer)
		else
			success = poll.sign_up(observer)
		if(success)
			// Add a small overlay to indicate we've signed up
			update_signed_up_alert(observer)

	else if(target)
		switch(action)
			if(NOTIFY_ATTACK)
				target.attack_ghost(observer)
			if(NOTIFY_JUMP)
				var/turf/target_turf = get_turf(target)
				if(target_turf)
					observer.abstract_move(target_turf)
			if(NOTIFY_FOLLOW)
				observer.ManualFollow(target)


/atom/movable/screen/alert/notify_action/Topic(href, href_list)
	var/mob/dead/observer/observer = usr
	if(!href_list["signup"] || !poll || !istype(observer))
		return
	var/success = FALSE
	if(observer in poll.signed_up)
		success = poll.remove_candidate(observer)
	else
		success = poll.sign_up(observer)
	if(success)
		update_signed_up_alert(observer)


/atom/movable/screen/alert/notify_action/proc/update_signed_up_alert(mob/user)
	if(user in poll.signed_up)
		add_overlay(signed_up_overlay)
	else
		cut_overlay(signed_up_overlay)


/atom/movable/screen/alert/notify_action/proc/display_stacks(stacks = 1)
	cut_overlay(stacks_overlay)
	if(stacks <= 1)
		return
	stacks_overlay = new
	stacks_overlay.maptext = MAPTEXT("<span style='font-family: \"Small Fonts\"; font-size: 32px; color: yellow;'>[stacks]x</span>")
	stacks_overlay.transform = stacks_overlay.transform.Translate(4, 2)
	stacks_overlay.layer = FLOAT_LAYER_STACKS
	add_overlay(stacks_overlay)

#undef FLOAT_LAYER_TIME
#undef FLOAT_LAYER_STACKS
#undef FLOAT_LAYER_SELECTOR


/atom/movable/screen/alert/notify_soulstone
	name = "Камень душ"
	desc = "Кто-то пытается заключить вашу душу в камень. Нажмите, чтобы согласиться."
	icon_state = "template"
	timeout = 10 SECONDS
	var/obj/item/soulstone/stone = null
	var/stoner = null

/atom/movable/screen/alert/notify_soulstone/Click()
	if(!usr || !usr.client)
		return
	if(stone)
		if(tgui_alert(usr, "[stoner] пытается заключить вашу душу в камень. \
							Это уничтожит ваше тело и не позволит вернуться в игру как прежний персонаж. Согласны?", "Воскрешение", list("Нет", "Да")) ==  "Да")
			stone?.opt_in = TRUE

/atom/movable/screen/alert/notify_soulstone/Destroy()
	stone = null
	return ..()


/atom/movable/screen/alert/notify_mapvote
	name = "Голосование за карту"
	desc = "Проголосуйте за следующую карту для игры!"
	icon_state = "map_vote"

/atom/movable/screen/alert/notify_mapvote/Click()
	usr.client.vote()

//OBJECT-BASED

/atom/movable/screen/alert/restrained/buckled
	name = "Пристёгнут"
	desc = "Вас пристегнули. Нажмите на уведомление, чтобы отстегнуться."
	icon_state = "buckled"

/atom/movable/screen/alert/restrained/handcuffed
	name = "В наручниках"
	desc = "Вы в наручниках и не можете ни с чем взаимодействовать. Если вас потащат, вы не сможете сопротивляться.<br>Нажмите на уведомление, чтобы освободиться."

/atom/movable/screen/alert/restrained/legcuffed
	name = "Ноги скованы"
	desc = "Ваши ноги скованы и это вас замедляет.<br>Нажмите на уведомление, чтобы освободиться."

/atom/movable/screen/alert/restrained/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		return L.resist()

/atom/movable/screen/alert/restrained/buckled/Click()
	if(!..())
		return

	var/mob/living/L = usr
	if(!istype(L) || !L.can_resist())
		return
	L.changeNext_move(CLICK_CD_RESIST)
	if(L.last_special <= world.time)
		return L.resist_buckle()

// PRIVATE = only edit, use, or override these if you're editing the system as a whole

// Re-render all alerts - also called in /datum/hud/show_hud() because it's needed there
/datum/hud/proc/reorganize_alerts()
	var/list/alerts = mymob.alerts
	if(!alerts)
		return FALSE
	var/icon_pref
	if(!hud_shown)
		for(var/i in 1 to alerts.len)
			mymob.client.screen -= alerts[alerts[i]]
			for(var/mob/dead/observer/observe in mymob.inventory_observers)
				if(!observe.client)
					LAZYREMOVE(mymob.inventory_observers, observe)
					continue
				observe.client.screen -= alerts[alerts[i]]
		return TRUE
	for(var/i in 1 to alerts.len)
		var/atom/movable/screen/alert/alert = alerts[alerts[i]]
		if(alert.icon_state == "template")
			if(!icon_pref)
				icon_pref = ui_style2icon(mymob.client.prefs.UI_style)
			alert.icon = icon_pref
		switch(i)
			if(1)
				. = ui_alert1
			if(2)
				. = ui_alert2
			if(3)
				. = ui_alert3
			if(4)
				. = ui_alert4
			if(5)
				. = ui_alert5 // Right now there's 5 slots
			else
				. = ""
		alert.screen_loc = .
		mymob.client.screen |= alert
		for(var/mob/dead/observer/observe in mymob.inventory_observers)
			if(!observe.client)
				LAZYREMOVE(mymob.inventory_observers, observe)
				continue
			observe.client.screen |= alert
	return TRUE

/atom/movable/screen/alert/Click(location, control, params)
	if(!usr || !usr.client || HAS_TRAIT(usr, TRAIT_OBSERVING_INVENTORY))
		return FALSE

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK)) // screen objects don't do the normal Click() stuff so we'll cheat
		to_chat(usr, "[span_boldnotice(name)] – [span_notice(desc)]")
		return FALSE

	if(master)
		return usr.client.Click(master, location, control, params)

	return TRUE

/atom/movable/screen/alert/Destroy()
	severity = 0
	master = null
	screen_loc = ""
	return ..()

/// Gives the player the option to succumb while in critical condition
/atom/movable/screen/alert/succumb
	name = "Сдаться"
	desc = "Покинуть этот бренный мир."
	icon_state = "succumb"

/atom/movable/screen/alert/succumb/Click()
	if(!usr || !usr.client || !..())
		return
	var/mob/living/living_owner = usr
	if(!istype(usr))
		return
	living_owner.do_succumb(TRUE)

/atom/movable/screen/alert/unpossess_object
	name = "Покинуть тело"
	desc = "Этот объект под вашим контролем. Нажмите сюда для прекращения контроля."
	icon_state = "buckled"

/atom/movable/screen/alert/unpossess_object/Click(location, control, params)
	. = ..()

	if(!.)
		return

	qdel(usr.GetComponent(/datum/component/object_possession))
