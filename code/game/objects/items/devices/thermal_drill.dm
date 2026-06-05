/obj/item/thermal_drill
	name = "thermal safe drill"
	desc = "Дрель из карбида вольфрама с магнитными креплениями для бурения укрепленных объектов. Гарантируется 100% защита от заклинивания."
	icon_state = "hardened_drill"
	w_class = WEIGHT_CLASS_GIGANTIC
	force = 15
	var/payback = FALSE
	var/spotted = FALSE
	var/time_multiplier = 1
	var/datum/song/thermal_drill/song
	var/datum/looping_sound/thermal_drill/soundloop
	var/datum/effect_system/spark_spread/spark_system
	/// When drilling security case
	var/security_alert_chance = 10

/obj/item/thermal_drill/get_ru_names()
	return alist(
		NOMINATIVE = "термальная дрель для сейфов",
		GENITIVE = "термальной дрели для сейфов",
		DATIVE = "термальной дрели для сейфов",
		ACCUSATIVE = "термальную дрель для сейфов",
		INSTRUMENTAL = "термальной дрелью для сейфов",
		PREPOSITIONAL = "термальной дрели для сейфов",
	)

/obj/item/thermal_drill/Initialize(mapload)
	. = ..()
	song = new(src, SSinstruments.synthesizer_instrument_ids)
	soundloop = new(src, FALSE)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(1, 0, src)
	spark_system.attach(src)

/obj/item/thermal_drill/Destroy()
	QDEL_NULL(song)
	QDEL_NULL(soundloop)
	QDEL_NULL(spark_system)
	return ..()

/obj/item/thermal_drill/attack_self(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/item/thermal_drill/ui_data(mob/user)
	return song.ui_data(user)

/obj/item/thermal_drill/ui_interact(mob/user, datum/tgui/ui = null)
	if(!payback)
		return
	song.ui_interact(user, ui)

/obj/item/thermal_drill/ui_act(action, params)
	if(..())
		return
	return song.ui_act(action, params)

/obj/item/thermal_drill/proc/should_stop_playing(mob/user)
	if(!payback && spotted)
		return TRUE
	return FALSE

/obj/item/thermal_drill/syndicate
	name = "amplified thermal safe drill"
	desc = "Дрель из карбида вольфрама с магнитными креплениями для бурения укрепленных объектов. Поставляется со встроенной моральной поддержкой и детектором службы безопасности, для помощи в бурении. При вскрытии защищенных кейсов с меньшим шансом активирует сигнализацию."
	payback = TRUE
	security_alert_chance = 4

/obj/item/thermal_drill/syndicate/get_ru_names()
	return alist(
		NOMINATIVE = "усиленная термальная дрель для сейфов",
		GENITIVE = "усиленной термальной дрели для сейфов",
		DATIVE = "усиленной термальной дрели для сейфов",
		ACCUSATIVE = "усиленную термальную дрель для сейфов",
		INSTRUMENTAL = "усиленной термальной дрелью для сейфов",
		PREPOSITIONAL = "усиленной термальной дрели для сейфов",
	)

/obj/item/thermal_drill/diamond_drill
	name = "diamond tipped thermal safe drill"
	desc = "Дрель из карбида вольфрама с алмазным напылением и магнитными креплениями для бурения укрепленных объектов. Гарантируется 100% защита от заклинивания."
	icon_state = "diamond_drill"
	time_multiplier = 0.5

/obj/item/thermal_drill/diamond_drill/get_ru_names()
	return alist(
		NOMINATIVE = "термальная дрель для сейфов с алмазным напылением",
		GENITIVE = "термальной дрели для сейфов с алмазным напылением",
		DATIVE = "термальной дрели для сейфов с алмазным напылением",
		ACCUSATIVE = "термальную дрель для сейфов с алмазным напылением",
		INSTRUMENTAL = "термальной дрелью для сейфов с алмазным напылением",
		PREPOSITIONAL = "термальной дрели для сейфов с алмазным напылением",
	)

/obj/item/thermal_drill/diamond_drill/syndicate
	name = "amplified diamond tipped thermal safe drill"
	desc = "Дрель из карбида вольфрама с алмазным напылением и магнитными креплениями для бурения укрепленных объектов. Поставляется со встроенной моральной поддержкой и детектором службы безопасности, для помощи в бурении. При вскрытии защищенных кейсов с меньшим шансом активирует сигнализацию."
	payback = TRUE
	security_alert_chance = 4

/obj/item/thermal_drill/diamond_drill/syndicate/get_ru_names()
	return alist(
		NOMINATIVE = "усиленная термальная дрель для сейфов с алмазным напылением",
		GENITIVE = "усиленной термальной дрели для сейфов с алмазным напылением",
		DATIVE = "усиленной термальной дрели для сейфов с алмазным напылением",
		ACCUSATIVE = "усиленную термальную дрель для сейфов с алмазным напылением",
		INSTRUMENTAL = "усиленной термальной дрелью для сейфов с алмазным напылением",
		PREPOSITIONAL = "усиленной термальной дрели для сейфов с алмазным напылением",
	)
