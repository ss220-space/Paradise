/datum/component/animal_temperature
	dupe_mode =  COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Min body temp
	var/minbodytemp = 250
	/// Max body temp
	var/maxbodytemp = 350
	/// Damage when below min temp
	var/cold_damage = 2
	/// Damage when above max temp
	var/heat_damage = 2
    /// If true - alert will be shown
	var/show_alert = FALSE

/datum/component/animal_temperature/Initialize(
    minbodytemp,
    maxbodytemp,
    cold_damage,
    heat_damage,
    show_alert
)
	if(!isanimal(parent))
		return COMPONENT_INCOMPATIBLE

	if(!isnull(minbodytemp))
		src.minbodytemp = minbodytemp

	if(!isnull(maxbodytemp))
		src.maxbodytemp = maxbodytemp

	if(!isnull(cold_damage))
		src.cold_damage = cold_damage

	if(!isnull(heat_damage))
		src.heat_damage = heat_damage

	if(!isnull(show_alert))
		src.show_alert = show_alert

/datum/component/animal_temperature/InheritComponent(
	datum/component/animal_temperature/new_comp,
	i_am_original,
	minbodytemp,
    maxbodytemp,
    cold_damage,
    heat_damage,
    show_alert
)
	if(!i_am_original)
		return

	if(!isnull(minbodytemp))
		src.minbodytemp = minbodytemp

	if(!isnull(maxbodytemp))
		src.maxbodytemp = maxbodytemp

	if(!isnull(cold_damage))
		src.cold_damage = cold_damage

	if(!isnull(heat_damage))
		src.heat_damage = heat_damage

	if(!isnull(show_alert))
		src.show_alert = show_alert

/datum/component/animal_temperature/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ANIMAL_HANDLE_ENVIRONMENT, PROC_REF(handle_environment))
	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(check_temperature))

/datum/component/animal_temperature/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ANIMAL_HANDLE_ENVIRONMENT, COMSIG_LIVING_LIFE))

/datum/component/animal_temperature/proc/handle_environment(datum/source, datum/gas_mixture/environment)
	SIGNAL_HANDLER

	var/mob/living/simple_animal/animal = source

	INVOKE_ASYNC(src, PROC_REF(regulate_temperature), animal, environment)

/datum/component/animal_temperature/proc/regulate_temperature(mob/living/simple_animal/animal, datum/gas_mixture/environment)
	var/areatemp = animal.get_temperature(environment)

	if(abs(areatemp - animal.bodytemperature) > 5)
		var/diff = areatemp - animal.bodytemperature
		diff = diff / 5
		animal.adjust_bodytemperature(diff)

	return

/datum/component/animal_temperature/proc/check_temperature(mob/living/simple_animal/animal, deltatime, times_fired)
	SIGNAL_HANDLER

	if(animal.bodytemperature < minbodytemp)
		animal.adjustHealth(cold_damage)

		if(show_alert)
			animal.throw_alert("temp", /atom/movable/screen/alert/cold, get_severity(animal))

		return TRUE

	if(animal.bodytemperature > maxbodytemp)
		animal.adjustHealth(heat_damage)

		if(show_alert)
			animal.throw_alert("temp", /atom/movable/screen/alert/hot, get_severity(animal))

		return TRUE

	animal.clear_alert("temp")
	return FALSE

/datum/component/animal_temperature/proc/get_severity(mob/living/simple_animal/animal)
	var/multiplier = animal.bodytemperature < minbodytemp ? (1 / minbodytemp) : (1 / maxbodytemp)
	var/severity = CEILING(abs(animal.bodytemperature / multiplier), 1)
	return min(severity, 3)
