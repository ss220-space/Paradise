// Given to heretic monsters.
/obj/effect/proc_holder/spell/emplosion/eldritch
	name = "Энергетический импульс"
	desc = "Заклинание, вызывающее вокруг вас сильный ЭМИ, выводящий из строя электронику."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS

	invocation = "М'П'ЛС"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	emp_heavy = 3
	emp_light = 6
