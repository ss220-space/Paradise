
/mob/living/simple_animal/hostile/evil_pine
	name = "Giant pine"
	desc = "A very angry and big pine. Doesn't look like it wants to be Xmas tree..."
	icon = 'icons/mob/evil_pine.dmi'
	icon_state = "evil_pine"

	health = 300
	maxHealth = 300
	healable = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	robust_searching = 1
	armour_penetration = 30
	melee_damage_lower = 35
	melee_damage_upper = 35
	speed = 2
	del_on_death = TRUE
	universal_speak = TRUE
	loot = list()
	deathmessage = ""
	death_sound = 'sound/misc/demon_dies.ogg'

	faction = list("hostile", "winter")
	weather_immunities = list("snow")

	speak = list()
	speak_chance = 10
	turns_per_move = 1
	turns_since_move = 0
