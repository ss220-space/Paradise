#define WAND_OPEN "Открыть/Закрыть"
#define WAND_BOLT "Поднять/Опустить болты"
#define WAND_EMERGENCY "Включить/Отключить аварийный доступ"
#define WAND_SPEED "Изменить скорость закрытия"
#define WAND_ELECTRIFY "Подать напряжение"

/obj/item/door_remote
	name = "control wand"
	desc = "Дистанционно управляет дверями."
	icon_state = "gangtool-white"
	item_state = "electronic"
	icon = 'icons/obj/device.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	var/mode = WAND_OPEN
	var/region_access = list()
	var/additional_access = list()
	var/obj/item/card/id/ID
	var/z_cross = TRUE //Allows using remoters cross-sectory

/obj/item/door_remote/get_ru_names()
	return alist(
		NOMINATIVE = "пульт от дверей",
		GENITIVE = "пульта от дверей",
		DATIVE = "пульту от дверей",
		ACCUSATIVE = "пульт от дверей",
		INSTRUMENTAL = "пультом от дверей",
		PREPOSITIONAL = "пульте от дверей",
	)

/obj/item/door_remote/Initialize(mapload)
	. = ..()
	ID = new /obj/item/card/id
	for(var/region in region_access)
		ID.access += get_region_accesses(region)
	ID.access += additional_access
	ID.access = unique_list(ID.access)

/obj/item/door_remote/Destroy()
	QDEL_NULL(ID)
	return ..()

/obj/item/door_remote/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	if(user)
		to_chat(user, span_warning("Вы замыкаете предохранители на [declent_ru(PREPOSITIONAL)]"))
	return TRUE

/obj/item/door_remote/attack_self(mob/user)
	. = ..()
	select_mode(user)

/obj/item/door_remote/proc/select_mode(mob/user)
	var/list/options = list(
		WAND_OPEN = mutable_appearance(icon = 'icons/mob/radial.dmi', icon_state = "radial_open"),
		WAND_BOLT = mutable_appearance(icon = 'icons/mob/radial.dmi', icon_state = "radial_bolt"),
		WAND_EMERGENCY = mutable_appearance(icon = 'icons/mob/radial.dmi', icon_state = "radial_ea"),
		WAND_SPEED = mutable_appearance(icon = 'icons/mob/radial.dmi', icon_state = "radial_speed"),
	)
	if(obj_flags & EMAGGED)
		options[WAND_ELECTRIFY] =  mutable_appearance(icon = 'icons/mob/radial.dmi', icon_state = "radial_electro")
	var/image/part_image = options[mode]
	// scuffed, but allows you to easily show whats the currently selected one
	part_image.underlays += mutable_appearance(icon = 'icons/mob/radial.dmi', icon_state = "radial_slice_focus")
	var/choice = show_radial_menu(user, src, options)
	if(!choice || user.stat || !in_range(user, src) || QDELETED(src))
		return
	if(choice == mode) // they didn't change their choice, don't do the to_chat
		return
	mode = choice

	to_chat(user, span_notice("Текущий режим: [mode]."))

/obj/item/door_remote/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!istype(target))
		target = locate() in get_turf(target)
	if(!istype(target))
		return
	if(is_airlock(target))
		access_airlock(target, user)
		return ITEM_INTERACT_SUCCESS
	if(istype(target, /obj/machinery/door/window))
		access_windoor(target, user)
		return ITEM_INTERACT_SUCCESS

/obj/item/door_remote/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!istype(target))
		target = locate() in get_turf(target)
	if(!istype(target))
		return
	if(is_airlock(target))
		access_airlock(target, user)
		return ITEM_INTERACT_SUCCESS
	if(istype(target, /obj/machinery/door/window))
		access_windoor(target, user)
		return ITEM_INTERACT_SUCCESS

/obj/item/door_remote/proc/common_checks(obj/machinery/door/target, mob/user)
	if(obj_flags & CMAGGED)
		to_chat(user, span_danger("Дверь не реагирует на [declent_ru(ACCUSATIVE)]"))
		return FALSE
	if(!target.requiresID())
		to_chat(user, span_danger("Сканирование ID у [target.declent_ru(GENITIVE)] отключено!"))
		return FALSE
	if(!target.check_access(src.ID))
		to_chat(user, span_danger("У [declent_ru(GENITIVE)] нет доступа к этой двери."))
		return FALSE
	var/turf/user_location = get_turf(user)
	if((target.z != user_location.z) && !z_cross)
		to_chat(user, span_danger("[DECLENT_RU_CAP(target, NOMINATIVE)] слишком далеко для управления!"))
		return FALSE
	return TRUE

/obj/item/door_remote/proc/access_airlock(obj/machinery/door/airlock/target, mob/user)
	if(!common_checks(target, user))
		return

	if(!(target.arePowerSystemsOn()))
		to_chat(user, span_danger("У [target.declent_ru(GENITIVE)] нет питания!"))
		return

	target.add_hiddenprint(user)
	switch(mode)
		if(WAND_OPEN)
			if(target.density)
				target.open()
				add_attack_logs(user, target, "opened")
			else
				target.close()
				add_attack_logs(user, target, "closed")
		if(WAND_BOLT)
			if(target.locked)
				target.unlock()
				add_attack_logs(user, target, "unlocked")
			else
				target.lock()
				add_attack_logs(user, target, "locked")
		if(WAND_EMERGENCY)
			target.emergency = !target.emergency
			add_attack_logs(user, target, "toggled [target.emergency? "on" : "off"] emergency access")
			target.update_icon()
		if(WAND_SPEED)
			target.normalspeed = !target.normalspeed
			to_chat(user, span_notice("[DECLENT_RU_CAP(target, NOMINATIVE)] теперь в [target.normalspeed ? "обычном" : "быстром"] режиме."))
			add_attack_logs(user, target, "changed speed mode")
		if(WAND_ELECTRIFY)
			if(!(obj_flags & EMAGGED))
				return
			if(target.electrified_until == -1)
				target.electrified_until = 0
				to_chat(user, span_notice("[DECLENT_RU_CAP(target, NOMINATIVE)] больше не под напряжением."))
				add_attack_logs(user, target, "un-electrified")
			else
				target.electrified_until = -1
				to_chat(user, span_notice("Вы подаёте напряжение на [target.declent_ru(ACCUSATIVE)]."))
				add_attack_logs(user, target, "electrified")

/obj/item/door_remote/proc/access_windoor(obj/machinery/door/window/target, mob/user)
	if(!common_checks(target, user))
		return

	if(!target.hasPower())
		to_chat(user, span_danger("У [target.declent_ru(GENITIVE)] нет питания!"))
		return

	target.add_hiddenprint(user)
	switch(mode)
		if(WAND_OPEN)
			if(target.density)
				target.open()
				add_attack_logs(user, target, "opened")
			else
				target.close()
				add_attack_logs(user, target, "closed")
		if(WAND_BOLT)
			to_chat(user, span_danger("У [target.declent_ru(GENITIVE)] нет болтов."))
		if(WAND_EMERGENCY)
			to_chat(user, span_danger("У [target.declent_ru(GENITIVE)] нет функции аварийного доступа."))
		if(WAND_SPEED)
			to_chat(user, span_danger("У [target.declent_ru(GENITIVE)] нет функции изменения скорости."))
		if(WAND_ELECTRIFY)
			if(!(obj_flags & EMAGGED))
				return
			to_chat(user, span_danger("У [target.declent_ru(GENITIVE)] нет функции подачи напряжения."))

/obj/item/door_remote/omni
	name = "omni door remote"
	desc = "Этот пульт имеет доступ к любой двери на станции."
	icon_state = "gangtool-yellow"
	region_access = list(REGION_ALL)

/obj/item/door_remote/omni/get_ru_names()
	return alist(
		NOMINATIVE = "пульт от дверей с абсолютным доступом",
		GENITIVE = "пульта от дверей с абсолютным доступом",
		DATIVE = "пульту от дверей с абсолютным доступом",
		ACCUSATIVE = "пульт от дверей с абсолютным доступом",
		INSTRUMENTAL = "пультом от дверей с абсолютным доступом",
		PREPOSITIONAL = "пульте от дверей с абсолютным доступом",
	)

/obj/item/door_remote/captain
	name = "command door remote"
	icon_state = "gangtool-yellow"
	region_access = list(REGION_COMMAND)

/obj/item/door_remote/captain/get_ru_names()
	return alist(
		NOMINATIVE = "пульт от дверей командования",
		GENITIVE = "пульта от дверей командования",
		DATIVE = "пульту от дверей командования",
		ACCUSATIVE = "пульт от дверей командования",
		INSTRUMENTAL = "пультом от дверей командования",
		PREPOSITIONAL = "пульте от дверей командования",
	)

/obj/item/door_remote/chief_engineer
	name = "engineering door remote"
	icon_state = "gangtool-orange"
	region_access = list(REGION_ENGINEERING)

/obj/item/door_remote/chief_engineer/get_ru_names()
	return alist(
		NOMINATIVE = "пульт от дверей инженерного отдела",
		GENITIVE = "пульта от дверей инженерного отдела",
		DATIVE = "пульту от дверей инженерного отдела",
		ACCUSATIVE = "пульт от дверей инженерного отдела",
		INSTRUMENTAL = "пультом от дверей инженерного отдела",
		PREPOSITIONAL = "пульте от дверей инженерного отдела",
	)

/obj/item/door_remote/research_director
	name = "research door remote"
	icon_state = "gangtool-purple"
	region_access = list(REGION_RESEARCH)

/obj/item/door_remote/research_director/get_ru_names()
	return alist(
		NOMINATIVE = "пульт от дверей отдела исследований",
		GENITIVE = "пульта от дверей отдела исследований",
		DATIVE = "пульту от дверей отдела исследований",
		ACCUSATIVE = "пульт от дверей отдела исследований",
		INSTRUMENTAL = "пультом от дверей отдела исследований",
		PREPOSITIONAL = "пульте от дверей отдела исследований",
	)

/obj/item/door_remote/head_of_security
	name = "security door remote"
	icon_state = "gangtool-red"
	region_access = list(REGION_SECURITY)

/obj/item/door_remote/head_of_security/get_ru_names()
	return alist(
		NOMINATIVE = "пульт от дверей службы безопасности",
		GENITIVE = "пульта от дверей службы безопасности",
		DATIVE = "пульту от дверей службы безопасности",
		ACCUSATIVE = "пульт от дверей службы безопасности",
		INSTRUMENTAL = "пультом от дверей службы безопасности",
		PREPOSITIONAL = "пульте от дверей службы безопасности",
	)

/obj/item/door_remote/quartermaster
	name = "supply door remote"
	icon_state = "gangtool-green"
	region_access = list(REGION_SUPPLY)

/obj/item/door_remote/quartermaster/get_ru_names()
	return alist(
		NOMINATIVE = "пульт от дверей отдела снабжения",
		GENITIVE = "пульта от дверей отдела снабжения",
		DATIVE = "пульту от дверей отдела снабжения",
		ACCUSATIVE = "пульт от дверей отдела снабжения",
		INSTRUMENTAL = "пультом от дверей отдела снабжения",
		PREPOSITIONAL = "пульте от дверей отдела снабжения",
	)

/obj/item/door_remote/chief_medical_officer
	name = "medical door remote"
	icon_state = "gangtool-blue"
	region_access = list(REGION_MEDBAY)

/obj/item/door_remote/chief_medical_officer/get_ru_names()
	return alist(
		NOMINATIVE = "пульт от дверей медицинского отдела",
		GENITIVE = "пульта от дверей медицинского отдела",
		DATIVE = "пульту от дверей медицинского отдела",
		ACCUSATIVE = "пульт от дверей медицинского отдела",
		INSTRUMENTAL = "пультом от дверей медицинского отдела",
		PREPOSITIONAL = "пульте от дверей медицинского отдела",
	)

/obj/item/door_remote/civillian
	name = "civilian door remote"
	region_access = list(REGION_GENERAL)
	additional_access = list(ACCESS_HOP)

/obj/item/door_remote/civillian/get_ru_names()
	return alist(
		NOMINATIVE = "пульт от дверей общего пользования",
		GENITIVE = "пульта от дверей общего пользования",
		DATIVE = "пульту от дверей общего пользования",
		ACCUSATIVE = "пульт от дверей общего пользования",
		INSTRUMENTAL = "пультом от дверей общего пользования",
		PREPOSITIONAL = "пульте от дверей общего пользования",
	)

/obj/item/door_remote/centcomm
	name = "centcomm door remote"
	desc = "Только для высокопоставленных чиновников \"Нанотрейзен\"."
	icon_state = "gangtool-blue"
	region_access = list(REGION_CENTCOMM)

/obj/item/door_remote/centcomm/get_ru_names()
	return alist(
		NOMINATIVE = "пульт от дверей Центрального Командования",
		GENITIVE = "пульта от дверей Центрального Командования",
		DATIVE = "пульту от дверей Центрального Командования",
		ACCUSATIVE = "пульт от дверей Центрального Командования",
		INSTRUMENTAL = "пультом от дверей Центрального Командования",
		PREPOSITIONAL = "пульте от дверей Центрального Командования",
	)

/obj/item/door_remote/taipan
	name = "Taipan door remote"
	desc = "Только для высокопоставленных агентов Синдиката."
	icon_state = "gangtool-syndie"
	region_access = list(REGION_TAIPAN)
	z_cross = FALSE

/obj/item/door_remote/taipan/get_ru_names()
	return alist(
		NOMINATIVE = "пульт от дверей Тайпана",
		GENITIVE = "пульта от дверей Тайпана",
		DATIVE = "пульту от дверей Тайпана",
		ACCUSATIVE = "пульт от дверей Тайпана",
		INSTRUMENTAL = "пультом от дверей Тайпана",
		PREPOSITIONAL = "пульте от дверей Тайпана",
	)

/obj/item/door_remote/omni/access_tuner
	name = "access tuner"
	desc = "Устройство для нелегального взаимодействия с дверями."
	icon_state = "hacktool"
	item_state = "hacktool"
	obj_flags = parent_type::obj_flags|EMAGGED
	var/hack_speed = 1 SECONDS
	var/busy = FALSE

/obj/item/door_remote/omni/access_tuner/get_ru_names()
	return alist(
		NOMINATIVE = "тюнер доступа",
		GENITIVE = "тюнера доступа",
		DATIVE = "тюнеру доступа",
		ACCUSATIVE = "тюнер доступа",
		INSTRUMENTAL = "тюнером доступа",
		PREPOSITIONAL = "тюнере доступа",
	)

/obj/item/door_remote/omni/access_tuner/update_icon_state()
	icon_state = "hacktool[busy ? "-g" : ""]"

/obj/item/door_remote/omni/access_tuner/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(hack(target, user))	// if the hack is successful, calls the parent proc and does the door stuff
		return ..()

/obj/item/door_remote/omni/access_tuner/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(hack(target, user))
		return ..()

/obj/item/door_remote/omni/access_tuner/proc/hack(atom/target, mob/user)
	if(!istype(target))
		return
	if(obj_flags & CMAGGED)
		to_chat(user, span_danger("Дверь не реагирует на [declent_ru(ACCUSATIVE)]!"))
		return
	if(busy)
		to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] уже взаимодействует с дверью!"))
		return
	busy = TRUE
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] пытается подключиться к [target.declent_ru(DATIVE)]..."))
	if(do_after(user, hack_speed, target))
		update_icon(UPDATE_ICON_STATE)
		busy = FALSE
		return TRUE
	busy = FALSE
	update_icon(UPDATE_ICON_STATE)

/// How long before you can "jangle" your keyring again (to prevent spam)
#define JANGLE_COOLDOWN 10 SECONDS

/obj/item/door_remote/janikeyring
	name = "janitor's keyring"
	desc = "Абсолютно неудобная связка ключей на металлическом кольце. Ключи на кольце дают доступ в большинство отделов и в сервисный отдел!"
	icon_state = "keyring"
	item_state = null
	additional_access = list(ACCESS_MEDICAL, ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_MINING, ACCESS_KITCHEN, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CHAPEL_OFFICE)
	/// Are you already using the keyring?
	var/busy = FALSE
	/// How fast does the keyring open an airlock. It is not set here so that it can be set via the user's role.
	var/hack_speed
	/// Stores the last airlock opened, opens faster on repeated use
	var/datum/weakref/last_airlock_ref
	COOLDOWN_DECLARE(cooldown)

/obj/item/door_remote/janikeyring/get_ru_names()
	return alist(
		NOMINATIVE = "связка электронных ключей уборщика",
		GENITIVE = "связки электронных ключей уборщика",
		DATIVE = "связке электронных ключей уборщика",
		ACCUSATIVE = "связку электронных ключей уборщика",
		INSTRUMENTAL = "связкой электронных ключей уборщика",
		PREPOSITIONAL = "связке электронных ключей уборщика",
	)

/obj/item/door_remote/janikeyring/examine(mob/user)
	. = ..()
	. += span_notice("Эта связка электронных ключей имеет доступ в медицинский, научный, инженерный отдел, а так же в отдел снабжения, бар и кухню!")

/obj/item/door_remote/janikeyring/select_mode(mob/user)
	if(obj_flags & EMAGGED)
		return ..()

	if(!COOLDOWN_FINISHED(src, cooldown))
		return

	to_chat(user, span_warning("Вы трясёте [declent_ru(ACCUSATIVE)]!"))
	playsound(src, 'sound/items/keyring_shake.ogg', 50)
	COOLDOWN_START(src, cooldown, JANGLE_COOLDOWN)

/obj/item/door_remote/janikeyring/interact_with_atom(obj/machinery/door/target, mob/living/user, list/modifiers)
	if(unlock(target, user))
		return ..()

/obj/item/door_remote/janikeyring/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers) // THOSE AINT MAGICAL REMOTE KEYS
	return NONE

/obj/item/door_remote/janikeyring/proc/unlock(obj/machinery/door/target, mob/living/user)
	if(!is_airlock(target) && !istype(target, /obj/machinery/door/window))
		return
	if(busy)
		to_chat(user, span_warning("Вы уже используете [declent_ru(ACCUSATIVE)] на панели доступа [target.declent_ru(GENITIVE)]!"))
		return
	busy = TRUE
	var/mob/living/carbon/human/human_user = user
	GET_SKILL_LEVEL(human_user, /datum/skill/service/cleaning, skill_level)
	var/skill_check = skill_level > SKILL_LEVEL_BASIC
	var/datum/weakref/target_ref = WEAKREF(target)
	if(skill_check && last_airlock_ref == target_ref)
		to_chat(user, span_notice("Вы узнаёте [target.declent_ru(ACCUSATIVE)] и ищете ключ, который использовали..."))
		hack_speed = 5 SECONDS
	else
		to_chat(user, span_notice("Вы возитесь с [declent_ru(INSTRUMENTAL)], подбирая разные ключи, чтобы открыть [target.declent_ru(ACCUSATIVE)]..."))
		if(!skill_check)
			hack_speed = rand(30, 60) SECONDS
		else
			hack_speed = rand(5, 20) SECONDS
	playsound(src, 'sound/items/keyring_unlock.ogg', 50)
	if(do_after(user, hack_speed, target = target))
		if(target.check_access(ID))
			last_airlock_ref = target_ref
		busy = FALSE
		return TRUE
	busy = FALSE

#undef JANGLE_COOLDOWN
#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY
#undef WAND_SPEED
#undef WAND_ELECTRIFY
