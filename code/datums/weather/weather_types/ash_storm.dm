//Ash storms happen frequently on lavaland. They heavily obscure vision, and cause high fire damage to anyone caught outside.
/datum/weather/ash_storm
	name = "пепельная буря"
	desc = "Сильная буря поднимает раскалённый пепел с поверхности планеты и разносит его повсюду, обжигая всех, кто недостаточно хорошо укрыт."

	telegraph_message = "<span class='boldwarning'>Ветер начинает жутко завывать. Чёрная пелена горящего пепла закрывает горизонт. Ищите укрытие.</span>"
	telegraph_duration = 300
	telegraph_overlay = "light_ash"

	weather_message = "<span class='userdanger'><i>Вас окутывает жгучее облако раскалённого пепла! Скорее в укрытие!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_overlay = "ash_storm"

	end_message = "<span class='boldannounce'>Воющий ветер уносит остатки пепельного облака, его завывания стихают до обычного мягкого шёпота. Теперь выходить наружу должно быть безопасно.</span>"
	end_duration = 300
	end_overlay = "light_ash"

	area_type = /area/lavaland/surface/outdoors
	target_trait = ORE_LEVEL

	immunity_type = "ash"

	probability = 90

	barometer_predictable = TRUE

	var/datum/looping_sound/active_outside_ashstorm/sound_ao = new(list(), FALSE, TRUE)
	var/datum/looping_sound/active_inside_ashstorm/sound_ai = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_outside_ashstorm/sound_wo = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_inside_ashstorm/sound_wi = new(list(), FALSE, TRUE)

/datum/weather/ash_storm/telegraph()
	. = ..()
	var/list/inside_areas = list()
	var/list/outside_areas = list()
	var/list/eligible_areas = list()
	for(var/z in impacted_z_levels)
		eligible_areas += GLOB.space_manager.areas_in_z["[z]"]
	for(var/i in 1 to eligible_areas.len)
		var/area/place = eligible_areas[i]
		if(place.outdoors)
			outside_areas += place
		else
			inside_areas += place
		CHECK_TICK

	sound_ao.output_atoms = outside_areas
	sound_ai.output_atoms = inside_areas
	sound_wo.output_atoms = outside_areas
	sound_wi.output_atoms = inside_areas

	sound_wo.start()
	sound_wi.start()

/datum/weather/ash_storm/start()
	. = ..()
	sound_wo.stop()
	sound_wi.stop()

	sound_ao.start()
	sound_ai.start()

/datum/weather/ash_storm/wind_down()
	. = ..()
	sound_ao.stop()
	sound_ai.stop()

	sound_wo.start()
	sound_wi.start()

/datum/weather/ash_storm/end()
	. = ..()
	sound_wo.stop()
	sound_wi.stop()

/datum/weather/ash_storm/proc/is_ash_immune(atom/L)
	while(L && !isturf(L))
		if(ismecha(L)) //Mechs are immune
			return TRUE
		if(ishuman(L)) //Are you immune?
			var/mob/living/carbon/human/H = L
			var/thermal_protection = H.get_thermal_protection()
			if(thermal_protection >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
				return TRUE
		L = L.loc //Matryoshka check
	return FALSE //RIP you

/datum/weather/ash_storm/weather_act(mob/living/L)
	if(is_ash_immune(L))
		return
	L.adjustFireLoss(4)


//Emberfalls are the result of an ash storm passing by close to the playable area of lavaland. They have a 10% chance to trigger in place of an ash storm.
/datum/weather/ash_storm/emberfall
	name = "emberfall"
	desc = "Проходящая пепельная буря покрывает эту область слоем безвредного пепла."

	weather_message = "<span class='notice'>Мягкое облако потухшего пепла окружает вас, словно гротескный снег. Кажется, буря прошла стороной…</span>"
	weather_overlay = "light_ash"

	end_message = "<span class='notice'>Пеплопад постепенно стихает. Свежий слой затвердевшего пепла покрывает базальтовые скалы.</span>"
	end_sound = null

	aesthetic = TRUE

	probability = 10
