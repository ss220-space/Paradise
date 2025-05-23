/obj/singularity/god/ratvar
	name = "Ratvar, the Clockwork Justiciar"
	desc = "..."
	icon = 'icons/obj/512x512.dmi'
	icon_state = "ratvar"
	pixel_x = -235
	pixel_y = -248
	current_size = 12
	move_self = TRUE
	contained = FALSE
	dissipate = FALSE
	move_self = TRUE
	grav_pull = 10
	consume_range = 12
	gender = NEUTER

/obj/singularity/god/ratvar/admin_investigate_setup()
	return

/obj/singularity/god/ratvar/New()
	..()
	set_light(15, 1, "#BE8700")
	to_chat(world, span_ratvar("И СНОВА МОЙ СВЕТ СИЯЕТ СРЕДИ ЭТИХ ЖАЛКИХ ЗВЕЗД."))
	SEND_SOUND(world, 'sound/effects/ratvar_reveal.ogg')

	var/datum/game_mode/gamemode = SSticker.mode
	if(gamemode)
		gamemode.clocker_objs.succesful_summon()

	var/area/A = get_area(src)
	if(A)
		var/image/alert_overlay = image('icons/effects/clockwork_effects.dmi', "ghostalert")
		notify_ghosts("Свет Судьи взывает к вам! Обратитесь к Ратвару в [A.name], чтобы получить оболочку для распространения его славы!", source = src, alert_overlay = alert_overlay, action = NOTIFY_ATTACK)

	ratvar_spawn_animation()
	addtimer(CALLBACK(SSticker.mode, TYPE_PROC_REF(/datum/game_mode, apocalypse)), 10 SECONDS)


/obj/singularity/god/ratvar/update_icon_state()
	return

/obj/singularity/god/ratvar/Destroy()
	to_chat(world, span_ratvar("РАТВАР ПАЛ"))
	SEND_SOUND(world, 'sound/hallucinations/wail.ogg')
	var/datum/game_mode/gamemode = SSticker.mode
	if(gamemode)
		gamemode.clocker_objs.ratvar_death()
		for(var/datum/mind/clock_mind in SSticker.mode.clockwork_cult)
			if(clock_mind && clock_mind.current)
				to_chat(clock_mind.current, span_clocklarge("МЕСТЬ!"))
				to_chat(clock_mind.current, span_clock("Текущая цель: уничтожить не верных!"))
	return ..()

/obj/singularity/god/ratvar/attack_ghost(mob/dead/observer/user)
	var/mob/living/simple_animal/hostile/clockwork/marauder/cog = new (get_turf(src))
	cog.key = user.key
	SSticker.mode.add_clocker(cog.mind)


/obj/singularity/god/ratvar/process()
	eat()
	move()
	if(prob(25))
		mezzer()


/obj/singularity/god/ratvar/Bump(atom/bumped_atom, effect_applied = TRUE)//you dare stand before a god?!
	. = ..()
	if(.)
		return .
	godsmack(bumped_atom)


/obj/singularity/god/ratvar/Bumped(atom/movable/moving_atom, effect_applied = TRUE)
	. = ..()
	godsmack(moving_atom)


/obj/singularity/god/ratvar/proc/godsmack(atom/A)
	if(istype(A,/obj/))
		var/obj/O = A
		O.ex_act(1)
		if(O) qdel(O)

	else if(isturf(A))
		var/turf/T = A
		T.ChangeTurf(/turf/simulated/floor/clockwork)

/obj/singularity/god/ratvar/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(M.stat == CONSCIOUS)
			if(!isclocker(M))
				to_chat(M, span_warning("Вы чувствуете, как ваше здравомыслие рушится в одно мгновение, когда вы смотрите на [src.name]..."))
				M.Stun(6 SECONDS)

/obj/singularity/god/ratvar/consume(atom/A)
	A.ratvar_act(FALSE, src)

/obj/singularity/god/ratvar/ex_act()
	return

/obj/singularity/god/ratvar/singularity_act() //handled in /obj/singularity/proc/consume
	return

/obj/singularity/god/ratvar/proc/ratvar_spawn_animation()
	icon = 'icons/obj/ratvar_spawn_anim.dmi'
	dir = SOUTH
	move_self = FALSE
	flick("ratvar", src)
	sleep(1.1 SECONDS)
	move_self = TRUE
	icon = initial(icon)
