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
		NOMINATIVE = "Термальная дрель для сейфов",
		GENITIVE = "Термальную дрель для сейфов",
		DATIVE = "Термальной дрели для сейфов",
		ACCUSATIVE = "Термальную дрель для сейфов",
		INSTRUMENTAL = "Термальной дрелью для сейфов",
		PREPOSITIONAL = "Термальной дрели для сейфов",
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
		NOMINATIVE = "Усиленная термальная дрель для сейфов",
		GENITIVE = "Усиленную термальную дрель для сейфов",
		DATIVE = "Усиленной термальной дрели для сейфов",
		ACCUSATIVE = "Усиленную термальную дрель для сейфов",
		INSTRUMENTAL = "Усиленной термальной дрелью для сейфов",
		PREPOSITIONAL = "Усиленной термальной дрели для сейфов",
	)

/obj/item/thermal_drill/diamond_drill
	name = "diamond tipped thermal safe drill"
	desc = "Дрель из карбида вольфрама с алмазным напылением и магнитными креплениями для бурения укрепленных объектов. Гарантируется 100% защита от заклинивания."
	icon_state = "diamond_drill"
	time_multiplier = 0.5

/obj/item/thermal_drill/diamond_drill/get_ru_names()
	return alist(
		NOMINATIVE = "Термальная дрель для сейфов с алмазным напылением",
		GENITIVE = "Термальную дрель для сейфов с алмазным напылением",
		DATIVE = "Термальной дрели для сейфов с алмазным напылением",
		ACCUSATIVE = "Термальную дрель для сейфов с алмазным напылением",
		INSTRUMENTAL = "Термальной дрелью для сейфов с алмазным напылением",
		PREPOSITIONAL = "Термальной дрели для сейфов с алмазным напылением",
	)

/obj/item/thermal_drill/diamond_drill/syndicate
	name = "amplified diamond tipped thermal safe drill"
	desc = "Дрель из карбида вольфрама с алмазным напылением и магнитными креплениями для бурения укрепленных объектов. Поставляется со встроенной моральной поддержкой и детектором службы безопасности, для помощи в бурении. При вскрытии защищенных кейсов с меньшим шансом активирует сигнализацию."
	payback = TRUE
	security_alert_chance = 4

/obj/item/thermal_drill/diamond_drill/syndicate/get_ru_names()
	return alist(
		NOMINATIVE = "Усиленная термальная дрель для сейфов с алмазным напылением",
		GENITIVE = "Усиленную термальную дрель для сейфов с алмазным напылением",
		DATIVE = "Усиленной термальной дрели для сейфов с алмазным напылением",
		ACCUSATIVE = "Усиленную термальную дрель для сейфов с алмазным напылением",
		INSTRUMENTAL = "Усиленной термальной дрелью для сейфов с алмазным напылением",
		PREPOSITIONAL = "Усиленной термальной дрели для сейфов с алмазным напылением",
	)
