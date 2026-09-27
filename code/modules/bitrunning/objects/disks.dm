/obj/item/disk/bitrunning
	name = "bitrunning program"
	desc = "Диск с исходным кодом. Его нужно принести с собой в нетпод."
	abstract_type = /obj/item/disk/bitrunning
	var/choice_made
	var/list/selectable
	var/selected_path

/obj/item/disk/bitrunning/Initialize(mapload)
	. = ..()
	icon_state = "datadisk[rand(0, 6)]"
	AddComponent(/datum/component/loads_avatar_gear, CALLBACK(src, PROC_REF(load_onto_avatar)))

/obj/item/disk/bitrunning/get_ru_names()
	return alist(
		NOMINATIVE = "программа битраннера",
		GENITIVE = "программы битраннера",
		DATIVE = "программе битраннера",
		ACCUSATIVE = "программу битраннера",
		INSTRUMENTAL = "программой битраннера",
		PREPOSITIONAL = "программе битраннера",
	)

/obj/item/disk/bitrunning/examine(mob/user)
	. = ..()
	if(isnull(choice_made))
		. += span_notice("Запись ещё не выбрана. Активируйте диск в руке.")
		return

	. += span_notice("Записано: <b>[choice_made]</b>. Перезаписать нельзя.")

/obj/item/disk/bitrunning/attack_self(mob/user)
	if(choice_made)
		balloon_alert(user, "диск уже записан!")
		return

	var/choice = tgui_input_list(user, "Что записать на диск?", "Программа битраннера", selectable)
	if(isnull(choice) || !user.is_in_hands(src))
		return

	selected_path = selectable[choice]
	choice_made = choice
	balloon_alert(user, "записано")
	playsound(user, 'sound/items/pshoom.ogg', 30, TRUE)

/obj/item/disk/bitrunning/proc/load_onto_avatar(mob/living/carbon/human/pilot, mob/living/carbon/human/avatar, domain_flags)
	return NONE

/obj/item/disk/bitrunning/item
	abstract_type = /obj/item/disk/bitrunning/item
	desc = "Диск с исходным кодом. Подгружает предмет в виртуальный домен."

/obj/item/disk/bitrunning/item/load_onto_avatar(mob/living/carbon/human/pilot, mob/living/carbon/human/avatar, domain_flags)
	if(domain_flags & DOMAIN_FORBIDS_ITEMS)
		return BITRUNNER_GEAR_LOAD_BLOCKED

	if(isnull(selected_path))
		return BITRUNNER_GEAR_LOAD_FAILED

	avatar.put_in_hands(new selected_path(avatar.loc))
	return NONE

/obj/item/disk/bitrunning/item/tier1
	name = "bitrunning program: simple gear"
	selectable = list(
		"Медицинский луч" = /obj/item/gun/medbeam,
		"Заряд C-4" = /obj/item/grenade/plastic/c4,
		"Бесконечная пицца" = /obj/item/pizzabox/infinite,
	)

/obj/item/disk/bitrunning/item/tier2
	name = "bitrunning program: complex gear"
	selectable = list(
		"Люксовый медипен" = /obj/item/reagent_containers/hypospray/autoinjector/survival/luxury,
		"Пистолет" = /obj/item/gun/projectile/automatic/pistol,
		"Бронежилет" = /obj/item/clothing/suit/armor/vest,
	)

/obj/item/disk/bitrunning/item/tier3
	name = "bitrunning program: advanced gear"
	selectable = list(
		"Ядерный энергопистолет" = /obj/item/gun/energy/gun/nuclear,
		"Двойной энергомеч" = /obj/item/twohanded/dualsaber,
		"Синди-минибомба" = /obj/item/grenade/syndieminibomb,
	)

/obj/item/disk/bitrunning/ability
	abstract_type = /obj/item/disk/bitrunning/ability
	desc = "Диск с исходным кодом. Подгружает способность в виртуальный домен. Повторные способности игнорируются."

/obj/item/disk/bitrunning/ability/load_onto_avatar(mob/living/carbon/human/pilot, mob/living/carbon/human/avatar, domain_flags)
	if(domain_flags & DOMAIN_FORBIDS_ABILITIES)
		return BITRUNNER_GEAR_LOAD_BLOCKED

	if(isnull(selected_path))
		return BITRUNNER_GEAR_LOAD_FAILED

	if(locate(selected_path) in avatar.mob_spell_list)
		return BITRUNNER_GEAR_LOAD_FAILED

	avatar.AddSpell(new selected_path)
	return NONE

/obj/item/disk/bitrunning/ability/tier1
	name = "bitrunning program: basic abilities"
	selectable = list(
		"Призыв сыра" = /datum/action/cooldown/spell/conjure/bitrunner_cheese,
		"Малое исцеление" = /datum/action/cooldown/spell/bitrunner_heal,
	)

/obj/item/disk/bitrunning/ability/tier2
	name = "bitrunning program: complex abilities"
	selectable = list(
		"Огненный шар" = /datum/action/cooldown/spell/pointed/projectile/fireball,
		"Силовая стена" = /datum/action/cooldown/spell/forcewall,
		"Молния" = /datum/action/cooldown/spell/pointed/projectile/fireball/bitrunner_lightning,
	)

/obj/item/disk/bitrunning/ability/tier3
	name = "bitrunning program: elite abilities"
	selectable = list(
		"Форма дракона" = /datum/action/cooldown/spell/shapeshift/dragon,
		"Форма белого медведя" = /datum/action/cooldown/spell/shapeshift/bitrunner_polar_bear,
	)

/obj/item/disk/bitrunning/item/pka_mods
	name = "bitrunning gear: proto-kinetic accelerator mods"
	selectable = list(
		"Увеличение дальности" = /obj/item/borg/upgrade/modkit/range,
		"Увеличение урона" = /obj/item/borg/upgrade/modkit/damage,
		"Ускорение перезарядки" = /obj/item/borg/upgrade/modkit/cooldown,
		"Взрывная волна" = /obj/item/borg/upgrade/modkit/aoe/mobs,
		"Прохождение сквозь гуманоидов" = /obj/item/borg/upgrade/modkit/human_passthrough,
	)

/obj/item/disk/bitrunning/item/pka_mods/premium
	name = "bitrunning gear: premium proto-kinetic accelerator mods"
	selectable = list(
		"Скорострельный повторитель" = /obj/item/borg/upgrade/modkit/cooldown/repeater,
		"Кристалл кражи жизни" = /obj/item/borg/upgrade/modkit/lifesteal,
		"Резонаторные заряды" = /obj/item/borg/upgrade/modkit/resonator_blasts,
		"Сифон смерти" = /obj/item/borg/upgrade/modkit/bounty,
		"Гаситель давления" = /obj/item/borg/upgrade/modkit/indoors,
	)

/obj/item/disk/bitrunning/item/pkc_mods
	name = "bitrunning gear: proto-kinetic crusher mods"
	selectable = list(
		"Крыло смотрителя" = /obj/item/crusher_trophy/watcher_wing,
		"Крыло магмового смотрителя" = /obj/item/crusher_trophy/blaster_tubes/magma_wing,
		"Череп легиона" = /obj/item/crusher_trophy/legion_skull,
	)

/obj/item/disk/bitrunning/item/pkc_mods/premium
	name = "bitrunning gear: premium proto-kinetic crusher mods"
	selectable = list(
		"Крыло ледяного смотрителя" = /obj/item/crusher_trophy/watcher_wing/ice_wing,
		"Бластерные трубки" = /obj/item/crusher_trophy/blaster_tubes,
		"Глаз хмельного охотника" = /obj/item/crusher_trophy/miner_eye,
		"Хвостовой шип" = /obj/item/crusher_trophy/tail_spike,
		"Когти демона" = /obj/item/crusher_trophy/demon_claws,
		"Талисман вихря" = /obj/item/crusher_trophy/vortex_talisman,
	)
