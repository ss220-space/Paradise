//////////////////////////////Construct Spells/////////////////////////

/obj/effect/proc_holder/spell/aoe/conjure/construct/lesser
	base_cooldown = 3 MINUTES
	action_icon_state = "artificer"
	action_background_icon_state = "bg_cult"
	human_req = FALSE


/obj/effect/proc_holder/spell/aoe/conjure/construct/lesser/holy
	action_icon_state = "artificer_holy"
	action_background_icon_state = "bg_spell"
	summon_type = list(/obj/structure/constructshell/holy)


/obj/effect/proc_holder/spell/aoe/conjure/build
	aoe_range = 0


/obj/effect/proc_holder/spell/aoe/conjure/build/floor
	name = "Summon Cult Floor"
	desc = "Это заклинание создаст пол культа."
	action_icon_state = "floorconstruct"
	action_background_icon_state = "bg_cult"
	school = "conjuration"
	base_cooldown = 2 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	centcom_cancast = FALSE //Stop crashing the server by spawning turfs on transit tiles
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_type = list(/turf/simulated/floor/engine/cult)


/obj/effect/proc_holder/spell/aoe/conjure/build/floor/holy
	name = "Summon Holy Floor"
	desc = "Это заклинание создаст святой пол."
	action_icon_state = "holyfloorconstruct"
	action_background_icon_state = "bg_spell"
	summon_type = list(/turf/simulated/floor/engine/cult/holy)


/obj/effect/proc_holder/spell/aoe/conjure/build/wall
	name = "Summon Cult Wall"
	desc = "Это заклинание создаст стену культа."
	action_icon_state = "cultforcewall"
	action_background_icon_state = "bg_cult"
	school = "conjuration"
	base_cooldown = 10 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	centcom_cancast = FALSE //Stop crashing the server by spawning turfs on transit tiles
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_type = list(/turf/simulated/wall/cult/artificer) //we don't want artificer-based runed metal farms


/obj/effect/proc_holder/spell/aoe/conjure/build/wall/holy
	name = "Summon Holy Wall"
	desc = "Это заклинание создаст святую стену, способную сдержать врагов. Впрочем, вы можете легко её разрушить."
	action_icon_state = "holyforcewall"
	action_background_icon_state = "bg_spell"
	summon_type = list(/turf/simulated/wall/cult/artificer/holy)


/obj/effect/proc_holder/spell/aoe/conjure/build/wall/reinforced
	name = "Greater Construction"
	desc = "Это заклинание создаст укреплённую металлическую стену."
	school = "conjuration"
	base_cooldown = 30 SECONDS
	delay = 5 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	centcom_cancast = FALSE //Stop crashing the server by spawning turfs on transit tiles
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_type = list(/turf/simulated/wall/r_wall)


/obj/effect/proc_holder/spell/aoe/conjure/build/soulstone
	name = "Summon Soulstone"
	desc = "Это заклинание использует Редспейс для призыва одного из легендарных осколков сквозь пространство и время."
	action_icon_state = "summonsoulstone"
	action_background_icon_state = "bg_cult"
	school = "conjuration"
	base_cooldown = 5 MINUTES
	clothes_req = FALSE
	human_req = FALSE
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_type = list(/obj/item/soulstone)


/obj/effect/proc_holder/spell/aoe/conjure/build/soulstone/holy
	action_icon_state = "summonsoulstone_holy"
	action_background_icon_state = "bg_spell"
	summon_type = list(/obj/item/soulstone/anybody/purified)


/obj/effect/proc_holder/spell/aoe/conjure/build/pylon
	name = "Cult Pylon"
	desc = "Это заклинание призывает хрупкий кристал из Редспейса. Неплохой источник освещения."
	action_icon_state = "pylon"
	action_background_icon_state = "bg_cult"
	school = "conjuration"
	base_cooldown = 20 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_type = list(/obj/structure/cult/functional/pylon)


/obj/effect/proc_holder/spell/aoe/conjure/build/pylon/holy
	name = "Holy Pylon"
	desc = "Это заклинание создаст кристалл, что будет немного лечить конструктов"
	action_icon_state = "holy_pylon"
	action_background_icon_state = "bg_spell"
	summon_type = list(/obj/structure/cult/functional/pylon/holy)


/obj/effect/proc_holder/spell/aoe/conjure/build/lesserforcewall
	name = "Shield"
	desc = "Это заклинание ненадолго создаёт силовую стену. Неплохое укрытие для вас и ваших союзников."
	action_icon_state = "cultforcewall"
	action_background_icon_state = "bg_cult"
	school = "transmutation"
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_lifespan = 20 SECONDS
	summon_type = list(/obj/effect/forcefield/cult)


/obj/effect/proc_holder/spell/aoe/conjure/build/lesserforcewall/holy
	action_icon_state = "holyforcewall"
	action_background_icon_state = "bg_spell"
	summon_type = list(/obj/effect/forcefield/holy)


/obj/effect/forcefield/cult

	desc = "Это зловещее препятствие, кажется, вытащили из другого измерения грубой силой."
	name = "eldritch wall"
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "m_shield_cult"
	light_color = LIGHT_COLOR_PURE_RED


/obj/effect/forcefield/holy
	desc = "Этот щит так и светится! Не похоже что его можно будет убрать так просто."
	name = "holy field"
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "holy_field"
	light_color = LIGHT_COLOR_DARK_BLUE


/obj/effect/proc_holder/spell/ethereal_jaunt/shift
	name = "Phase Shift"
	desc = "Это заклинание позволяет ходить через стены."
	action_icon_state = "phaseshift"
	action_background_icon_state = "bg_cult"
	base_cooldown = 20 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	jaunt_in_time = 12
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/wraith
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/wraith/out


/obj/effect/proc_holder/spell/ethereal_jaunt/shift/do_jaunt(mob/living/target)
	target.set_light_on(FALSE)
	..()
	if(isconstruct(target))
		var/mob/living/simple_animal/hostile/construct/construct = target
		if(construct.holy)
			construct.set_light_range_power_color(3, 5, LIGHT_COLOR_DARK_BLUE)
		else
			construct.set_light_range_power_color(2, 3, SSticker.cultdat ? SSticker.cultdat.construct_glow : LIGHT_COLOR_BLOOD_MAGIC)


/obj/effect/proc_holder/spell/ethereal_jaunt/shift/jaunt_steam(mobloc)
	return


/obj/effect/proc_holder/spell/ethereal_jaunt/shift/holy
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/holy_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/holy_shift/out
	action_icon_state = "holyphaseshift"
	action_background_icon_state = "bg_spell"


/obj/effect/proc_holder/spell/projectile/magic_missile/lesser
	name = "Lesser Magic Missile"
	desc = "Это заклинание выпускает несколько медленно движущихся магических снарядов по ближайшим целям."
	action_background_icon_state = "bg_cult"
	school = "evocation"
	base_cooldown = 40 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	proj_lifespan = 10
	max_targets = 6
	proj_type = "/obj/effect/proc_holder/spell/inflict_handler/magic_missile/lesser"


/obj/effect/proc_holder/spell/inflict_handler/magic_missile/lesser
	amt_weakened = 4 SECONDS


/obj/effect/proc_holder/spell/smoke/disable
	name = "Paralysing Smoke"
	desc = "Это заклинание создаёт облако парализующего дыма."
	action_icon_state = "parasmoke"
	action_background_icon_state = "bg_cult"
	school = "conjuration"
	base_cooldown = 20 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	cooldown_min = 2 SECONDS //25 deciseconds reduction per rank
	smoke_type = SMOKE_SLEEPING
	smoke_amt = 10


/obj/effect/proc_holder/spell/smoke/disable
	name = "Paralysing Smoke"
	desc = "Это заклинание создаёт облако парализующего дыма."
	action_icon_state = "parasmoke"
	action_background_icon_state = "bg_cult"
	school = "conjuration"
	base_cooldown = 20 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	cooldown_min = 2 SECONDS //25 deciseconds reduction per rank

	smoke_type = SMOKE_SLEEPING
	smoke_amt = 10

