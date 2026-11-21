/datum/lightfloor_mode
	abstract_type = /datum/lightfloor_mode
	var/name
	var/icon_state
	var/light_color
	var/legacy_state

/datum/lightfloor_mode/cyan
	name = "Cyan"
	icon_state = "light_on"
	light_color = LIGHT_COLOR_BLUE
	legacy_state = 1

/datum/lightfloor_mode/white
	name = "White"
	icon_state = "light_on-w"
	light_color = COLOR_WHITE
	legacy_state = 2

/datum/lightfloor_mode/red
	name = "Red"
	icon_state = "light_on-r"
	light_color = COLOR_SOFT_RED
	legacy_state = 3

/datum/lightfloor_mode/green
	name = "Green"
	icon_state = "light_on-g"
	light_color = LIGHT_COLOR_ELECTRIC_GREEN
	legacy_state = 4

/datum/lightfloor_mode/yellow
	name = "Yellow"
	icon_state = "light_on-y"
	light_color = LIGHT_COLOR_DIM_YELLOW
	legacy_state = 5

/datum/lightfloor_mode/blue
	name = "Blue"
	icon_state = "light_on-b"
	light_color = LIGHT_COLOR_DARK_BLUE
	legacy_state = 6

/datum/lightfloor_mode/purple
	name = "Purple"
	icon_state = "light_on-p"
	light_color = LIGHT_COLOR_PURPLE
	legacy_state = 7

/datum/lightfloor_mode/rainbow
	name = "Rainbow"
	icon_state = "light_on-cycle_all"
	light_color = COLOR_WHITE
	legacy_state = 8

/datum/lightfloor_mode/dancefloor_a
	name = "Dancefloor A"
	icon_state = "light_on-dancefloor_A"
	light_color = COLOR_RED
	legacy_state = 9

/datum/lightfloor_mode/dancefloor_b
	name = "Dancefloor B"
	icon_state = "light_on-dancefloor_B"
	light_color = LIGHT_COLOR_DARK_BLUE
	legacy_state = 10
