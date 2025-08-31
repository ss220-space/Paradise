/atom/movable/screen/wind_up_timer
	name = "Заводной механизм"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "windup_display-1"
	screen_loc = ui_cogscarab_timer

/atom/movable/screen/wind_up_timer/examine(mob/user, infix, suffix)
	. = ..()
	var/mob/living/silicon/robot/cogscarab/cog = user
	. += span_notice("Осталось времени: [cog.wind_up_timer].<br>")
