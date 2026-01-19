/obj/item/mod/construction
	desc = "Деталь модульного экзокостюма, используемая при его строительстве. Вы можете установить это в оболочку МЭК."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "skinapplier"

/obj/item/mod/construction/helmet
	name = "MOD helmet"
	desc = "Универсальный каркас шлема, используемый в создании модульных экзокостюмов. Бесполезен вне оболочки."
	icon_state = "helmet"

/obj/item/mod/construction/helmet/get_ru_names()
	return list(
		NOMINATIVE = "шлем МЭК",
		GENITIVE = "шлема МЭК",
		DATIVE = "шлему МЭК",
		ACCUSATIVE = "шлем МЭК",
		INSTRUMENTAL = "шлемом МЭК",
		PREPOSITIONAL = "шлеме МЭК"
	)

/obj/item/mod/construction/chestplate
	name = "MOD chestplate"
	desc = "Тяжелая металлическая бронепластина, используемая в создании модульных экзокостюмов. Бесполезна вне оболочки."
	icon_state = "chestplate"

/obj/item/mod/construction/chestplate/get_ru_names()
	return list(
		NOMINATIVE = "нагрудник МЭК",
		GENITIVE = "нагрудника МЭК",
		DATIVE = "нагруднику МЭК",
		ACCUSATIVE = "шлем МЭК",
		INSTRUMENTAL = "нагрудником МЭК",
		PREPOSITIONAL = "нагруднике МЭК"
	)

/obj/item/mod/construction/gauntlets
	name = "MOD gauntlets"
	desc = "Пара уродливых электрических перчаток, используемых в создании модульных экзокостюмов. Бесполезны вне оболочки."
	icon_state = "gauntlets"

/obj/item/mod/construction/gauntlets/get_ru_names()
	return list(
		NOMINATIVE = "перчатки МЭК",
		GENITIVE = "перчаток МЭК",
		DATIVE = "перчаткам МЭК",
		ACCUSATIVE = "перчатки МЭК",
		INSTRUMENTAL = "перчатками МЭК",
		PREPOSITIONAL = "перчатках МЭК"
	)

/obj/item/mod/construction/boots
	name = "MOD boots"
	desc = "Пара электрических сапог, используемых в создании модульных экзокостюмов. Бесполезны вне оболочки."
	icon_state = "boots"

/obj/item/mod/construction/boots/get_ru_names()
	return list(
		NOMINATIVE = "ботинки МЭК",
		GENITIVE = "ботинок МЭК",
		DATIVE = "ботинкам МЭК",
		ACCUSATIVE = "ботинки МЭК",
		INSTRUMENTAL = "ботинками МЭК",
		PREPOSITIONAL = "ботинках МЭК"
	)

/obj/item/mod/construction/broken_core
	name = "broken MOD core"
	desc = "Внутренний источник питания для модульного экзокостюма. Конкретно этот экземпляр уже ничего не запитает."
	icon_state = "mod-core"

/obj/item/mod/construction/broken_core/get_ru_names()
	return list(
		NOMINATIVE = "сломанное ядро МЭК",
		GENITIVE = "сломанного ядра МЭК",
		DATIVE = "сломанному ядру МЭК",
		ACCUSATIVE = "сломанное ядро МЭК",
		INSTRUMENTAL = "сломанном ядре МЭК",
		PREPOSITIONAL = "сломанному ядру МЭК"
	)

/obj/item/mod/construction/broken_core/examine(mob/user)
	. = ..()
	. += span_notice("Вы могли бы починить ядро с помощью <b>отвёртки</b>...")

/obj/item/mod/construction/broken_core/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	balloon_alert(user, "починка...")
	if(!tool.use_tool(src, user, 5 SECONDS, volume = 30))
		balloon_alert(user, "прервано!")
		return
	new /obj/item/mod/core/standard(drop_location())
	qdel(src)

/obj/item/mod/construction/plating
	name = "MOD external plating"
	desc = "Внешняя обшивка, используемая для создания блока управления модульного экзокостюма."
	icon_state = "standard-plating"
	var/datum/mod_theme/theme = /datum/mod_theme/civilian

/obj/item/mod/construction/plating/get_ru_names()
	return list(
		NOMINATIVE = "внешняя обшивка МЭК",
		GENITIVE = "внешней обшивки МЭК",
		DATIVE = "внешней обшивке МЭК",
		ACCUSATIVE = "внешнюю обшивку МЭК",
		INSTRUMENTAL = "внешней обшивкой МЭК",
		PREPOSITIONAL = "внешней обшивке МЭК"
	)

/obj/item/mod/construction/plating/Initialize(mapload)
	. = ..()
	var/datum/mod_theme/used_theme = GLOB.mod_themes[theme]
	name = "MOD [used_theme.name] external plating"

	if(!ru_names)
		ru_names = get_ru_names_cached()

	ru_names = list(
		NOMINATIVE = ru_names[NOMINATIVE] + " [used_theme.name]",
		GENITIVE = ru_names[GENITIVE] + " [used_theme.name]",
		DATIVE = ru_names[DATIVE] + " [used_theme.name]",
		ACCUSATIVE = ru_names[ACCUSATIVE] + " [used_theme.name]",
		INSTRUMENTAL = ru_names[INSTRUMENTAL] + " [used_theme.name]",
		PREPOSITIONAL = ru_names[PREPOSITIONAL] + " [used_theme.name]",
	)

	desc = "[desc] </p> [used_theme.desc]"
	icon_state = "[used_theme.default_skin]-plating"

/obj/item/mod/construction/plating/engineering
	theme = /datum/mod_theme/engineering

/obj/item/mod/construction/plating/atmospheric
	theme = /datum/mod_theme/atmospheric

/obj/item/mod/construction/plating/medical
	theme = /datum/mod_theme/medical

/obj/item/mod/construction/plating/security
	theme = /datum/mod_theme/security

/obj/item/mod/construction/plating/brig_pilot
	theme = /datum/mod_theme/brig_pilot

/obj/item/mod/construction/plating/cosmohonk
	theme = /datum/mod_theme/cosmohonk

/obj/item/mod/construction/plating/rescue
	theme = /datum/mod_theme/rescue

/obj/item/mod/construction/plating/security_medical
	theme = /datum/mod_theme/security_medical

/obj/item/mod/construction/plating/safeguard_mk_one
	theme = /datum/mod_theme/safeguard_mk_one

/obj/item/mod/construction/plating/safeguard_mk_two
	theme = /datum/mod_theme/safeguard_mk_two

/obj/item/mod/construction/plating/advanced
	theme = /datum/mod_theme/advanced

/obj/item/mod/construction/plating/research
	theme = /datum/mod_theme/research

#define START_STEP "start"
#define CORE_STEP "core"
#define SCREWED_CORE_STEP "screwed_core"
#define HELMET_STEP "helmet"
#define CHESTPLATE_STEP "chestplate"
#define GAUNTLETS_STEP "gauntlets"
#define BOOTS_STEP "boots"
#define WRENCHED_ASSEMBLY_STEP "wrenched_assembly"
#define SCREWED_ASSEMBLY_STEP "screwed_assembly"

/obj/item/mod/construction/shell
	name = "MOD shell"
	desc = "Явно незавершённое устройство с десятками проводов и коннекторов, предназначенное для хранения, развёртывания и использования модульных экзокостюмов."
	icon_state = "mod-construction_start"
	var/obj/item/core
	var/obj/item/helmet
	var/obj/item/chestplate
	var/obj/item/gauntlets
	var/obj/item/boots
	var/construction_step = START_STEP

/obj/item/mod/construction/shell/get_ru_names()
	return list(
		NOMINATIVE = "оболочка МЭК",
		GENITIVE = "оболочки МЭК",
		DATIVE = "оболочке МЭК",
		ACCUSATIVE = "оболочку МЭК",
		INSTRUMENTAL = "оболочкой МЭК",
		PREPOSITIONAL = "оболочке МЭК"
	)

/obj/item/mod/construction/shell/examine(mob/user)
	. = ..()
	var/display_text
	switch(construction_step)
		if(START_STEP)
			display_text = "Судя по всему, нужно установить <b>ядро МЭК</b>..."
		if(CORE_STEP)
			display_text = "Ядро <b>не прикручено</b>..."
		if(SCREWED_CORE_STEP)
			display_text = "Судя по всему, нужно установить <b>шлем</b>..."
		if(HELMET_STEP)
			display_text = "Судя по всему, нужно установить <b>нагрудник</b>..."
		if(CHESTPLATE_STEP)
			display_text = "Судя по всему, нужно установить <b>перчатки</b>..."
		if(GAUNTLETS_STEP)
			display_text = "Судя по всему, нужно установить <b>ботинки</b>..."
		if(BOOTS_STEP)
			display_text = "Заготовка костюма, судя по всему, <b>плохо закреплена</b>..."
		if(WRENCHED_ASSEMBLY_STEP)
			display_text = "Заготовка костюма, судя по всему, <b>не прикручена</b>..."
		if(SCREWED_ASSEMBLY_STEP)
			display_text = "Всё, что осталось для завершения, это <b>внешняя обшивка</b>..."
	. += span_notice("[display_text]")

/obj/item/mod/construction/shell/attackby(obj/item/part, mob/user, params)
	. = ..()
	switch(construction_step)

		if(START_STEP)
			if(!ismodcore(part))
				return
			if(!user.drop_from_active_hand())
				balloon_alert(user, "невозможно!")
				return
			playsound(src, 'sound/machines/click.ogg', 30, TRUE)
			balloon_alert(user, "установлено")
			core = part
			core.forceMove(src)
			construction_step = CORE_STEP

		if(CORE_STEP)
			if(part.tool_behaviour == TOOL_SCREWDRIVER) //Construct
				if(part.use_tool(src, user, 0, volume = 30))
					balloon_alert(user, "ядро прикручено")
				construction_step = SCREWED_CORE_STEP
			else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(part.use_tool(src, user, 0, volume = 30))
					core.forceMove(drop_location())
					balloon_alert(user, "ядро извлечено")
				construction_step = START_STEP

		if(SCREWED_CORE_STEP)
			if(istype(part, /obj/item/mod/construction/helmet)) //Construct
				if(!user.drop_from_active_hand())
					balloon_alert(user, "невозможно!")
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				balloon_alert(user, "шлем установлен")
				helmet = part
				helmet.forceMove(src)
				construction_step = HELMET_STEP
			else if(part.tool_behaviour == TOOL_SCREWDRIVER) //Deconstruct
				if(part.use_tool(src, user, 0, volume = 30))
					balloon_alert(user, "ядро откручено")
					construction_step = CORE_STEP

		if(HELMET_STEP)
			if(istype(part, /obj/item/mod/construction/chestplate)) //Construct
				if(!user.drop_from_active_hand())
					balloon_alert(user, "невозможно!")
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				balloon_alert(user, "нагрудник установлен")
				chestplate = part
				chestplate.forceMove(src)
				construction_step = CHESTPLATE_STEP
			else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(part.use_tool(src, user, 0, volume = 30))
					helmet.forceMove(drop_location())
					balloon_alert(user, "шлем отсоединён")
					helmet = null
					construction_step = SCREWED_CORE_STEP

		if(CHESTPLATE_STEP)
			if(istype(part, /obj/item/mod/construction/gauntlets)) //Construct
				if(!user.drop_from_active_hand())
					balloon_alert(user, "невозможно!")
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				balloon_alert(user, "перчатки закреплены")
				gauntlets = part
				gauntlets.forceMove(src)
				construction_step = GAUNTLETS_STEP
			else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(part.use_tool(src, user, 0, volume = 30))
					chestplate.forceMove(drop_location())
					balloon_alert(user, "нагрудник отсоединён")
					chestplate = null
					construction_step = HELMET_STEP

		if(GAUNTLETS_STEP)
			if(istype(part, /obj/item/mod/construction/boots)) //Construct
				if(!user.drop_from_active_hand())
					balloon_alert(user, "невозможно!")
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				balloon_alert(user, "ботинки закреплены")
				boots = part
				boots.forceMove(src)
				construction_step = BOOTS_STEP
			else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(part.use_tool(src, user, 0, volume = 30))
					gauntlets.forceMove(drop_location())
					balloon_alert(user, "перчатки отсоединены")
					gauntlets = null
					construction_step = CHESTPLATE_STEP

		if(BOOTS_STEP)
			if(part.tool_behaviour == TOOL_WRENCH) //Construct
				if(part.use_tool(src, user, 0, volume = 30))
					balloon_alert(user, "детали закреплены")
					construction_step = WRENCHED_ASSEMBLY_STEP
			else if(part.tool_behaviour == TOOL_CROWBAR) //Deconstruct
				if(part.use_tool(src, user, 0, volume = 30))
					boots.forceMove(drop_location())
					balloon_alert(user, "ботинки отсоединены")
					boots = null
					construction_step = GAUNTLETS_STEP

		if(WRENCHED_ASSEMBLY_STEP)
			if(part.tool_behaviour == TOOL_SCREWDRIVER) //Construct
				if(part.use_tool(src, user, 0, volume = 30))
					balloon_alert(user, "запчасти прикручены")
					construction_step = SCREWED_ASSEMBLY_STEP
			else if(part.tool_behaviour == TOOL_WRENCH) //Deconstruct
				if(part.use_tool(src, user, 0, volume = 30))
					balloon_alert(user, "запчасти откреплены")
					construction_step = BOOTS_STEP

		if(SCREWED_ASSEMBLY_STEP)
			if(istype(part, /obj/item/mod/construction/plating)) //Construct
				var/obj/item/mod/construction/plating/external_plating = part
				if(!user.drop_from_active_hand())
					return
				playsound(src, 'sound/machines/click.ogg', 30, TRUE)
				var/obj/item/mod = new /obj/item/mod/control(drop_location(), external_plating.theme, null, core)
				core = null
				qdel(external_plating)
				qdel(src)
				user.put_in_hands(mod)
				mod.balloon_alert(user, "сборка завершена")
			else if(part.tool_behaviour == TOOL_SCREWDRIVER) //Deconstruct
				if(part.use_tool(src, user, 0, volume = 30))
					balloon_alert(user, "запчасти откручены")
					construction_step = WRENCHED_ASSEMBLY_STEP

	update_icon(UPDATE_ICON_STATE)

/obj/item/mod/construction/shell/update_icon_state()
	icon_state = "mod-construction_[construction_step]"

/obj/item/mod/construction/shell/Destroy()
	QDEL_NULL(core)
	QDEL_NULL(helmet)
	QDEL_NULL(chestplate)
	QDEL_NULL(gauntlets)
	QDEL_NULL(boots)
	return ..()

/obj/item/mod/construction/shell/handle_atom_del(atom/deleted_atom)
	if(deleted_atom == core)
		core = null
	if(deleted_atom == helmet)
		helmet = null
	if(deleted_atom == chestplate)
		chestplate = null
	if(deleted_atom == gauntlets)
		gauntlets = null
	if(deleted_atom == boots)
		boots = null
	return ..()

#undef START_STEP
#undef CORE_STEP
#undef SCREWED_CORE_STEP
#undef HELMET_STEP
#undef CHESTPLATE_STEP
#undef GAUNTLETS_STEP
#undef BOOTS_STEP
#undef WRENCHED_ASSEMBLY_STEP
#undef SCREWED_ASSEMBLY_STEP
