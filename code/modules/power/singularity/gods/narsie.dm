#define NARSIE_CHANCE_TO_PICK_NEW_TARGET 5

/obj/god/narsie
	name = "Нар'Си"
	gender = FEMALE

	icon = 'icons/obj/narsie.dmi'
	icon_state = "narsie"
	pixel_x = -236
	pixel_y = -256

	light_color = COLOR_CULT_RED
	light_power = 0.7
	light_range = 6

	consume_range = 12
	grav_pull = 10
	mesmerize_range = 12

	spawn_anim_icon = 'icons/obj/narsie_spawn_anim.dmi'
	apocalypse_god_name = "Nar'Sie"

	rise_sound = 'sound/effects/narsie_risen.ogg'
	ghost_alert_icon = 'icons/effects/cult_effects.dmi'
	ghost_alert_state = "ghostalertsie"
	ghost_alert_message = "Нар'Си восстала в"

/obj/god/narsie/wrap_announce(text)
	return span_narsie(text)

/obj/god/narsie/announce_summon()
	SSticker.mode?.cult_objs.succesful_summon()

/obj/god/narsie/announce_death()
	SSticker.mode?.cult_objs.narsie_death()

/obj/god/narsie/devotees()
	return SSticker.mode?.cult || list()

/obj/god/narsie/attack_ghost(mob/dead/observer/user)
	if(!jobban_isbanned(user.ckey, ROLE_CULTIST))
		return
	if(tgui_alert(user, "Вы хотите стать кровавым Жнецом?", "Стать Жнецом?", list("Да", "Нет"), timeout = 10 SECONDS) == "Да")
		make_new_construct(/mob/living/simple_animal/hostile/construct/harvester, user, cult_override = TRUE)

/obj/god/narsie/process()
	. = ..()
	var/datum/component/singularity/singularity_component = singularity?.resolve()
	if(!isnull(singularity_component) && (!singularity_component.target || prob(NARSIE_CHANCE_TO_PICK_NEW_TARGET)))
		pickcultist()

/obj/god/narsie/is_devotee(mob/living/carbon/mob)
	return iscultist(mob)

/// Called to make Nar'Sie convert objects to cult stuff, or to eat.
/obj/god/narsie/consume(atom/target)
	target.narsie_act(src)

/// Narsie rewards her cultists with being devoured first, then picks a ghost to follow.
/obj/god/narsie/proc/pickcultist()
	var/list/cultists = list()
	var/list/noncultists = list()
	var/list/connected_z = SSmapping.get_connected_levels(get_turf(src))
	for(var/mob/living/carbon/food in GLOB.alive_mob_list) //we don't care about constructs or cult-Ians or whatever. cult-monkeys are fair game i guess
		var/turf/pos = get_turf(food)
		if(!pos || !(pos.z in connected_z))
			continue

		if(iscultist(food))
			cultists += food
		else
			noncultists += food

		if(length(cultists)) //cultists get higher priority
			acquire(pick(cultists))
			return

		if(length(noncultists))
			acquire(pick(noncultists))
			return

	//no living humans, follow a ghost instead.
	for(var/mob/dead/observer/ghost in GLOB.player_list)
		if(!ghost.client)
			continue
		var/turf/pos = get_turf(ghost)
		if(!pos || !(pos.z in connected_z))
			continue
		cultists += ghost
	if(length(cultists))
		acquire(pick(cultists))

/obj/god/narsie/proc/acquire(atom/food)
	var/datum/component/singularity/singularity_component = singularity?.resolve()
	if(isnull(singularity_component))
		return

	var/atom/old_target = singularity_component.target
	if(food == old_target)
		return

	var/entity_name = SSticker.cultdat?.entity_name || name
	if(old_target)
		to_chat(old_target, span_cultlarge("ТЫ БОЛЬШЕ НЕ ИНТЕРЕСУЕШЬ [uppertext(entity_name)]!"))
	singularity_component.target = food
	if(ishuman(food))
		to_chat(food, span_cultlarge("[uppertext(entity_name)] ЖАЖДЕТ ТВОЮ ДУШУ!"))
	else
		to_chat(food, span_cultlarge("[uppertext(entity_name)] ВЫБРАЛА ТЕБЯ ПРОВОДНИКОМ К ЕЁ СЛЕДУЮЩЕЙ ЖЕРТВЕ!"))

/// Narsie's spawn animation pulls the icon/state from the active cult flavor instead of static defaults.
/obj/god/narsie/spawn_animation()
	icon = spawn_anim_icon
	setDir(SOUTH)
	flick(SSticker.cultdat?.entity_spawn_animation, src)
	addtimer(CALLBACK(src, PROC_REF(spawn_animation_end)), spawn_anim_duration)

/obj/god/narsie/spawn_animation_end()
	icon = initial(icon)
	icon_state = SSticker.cultdat?.entity_icon_state
	name = SSticker.cultdat?.entity_name
	var/datum/component/singularity/singularity_component = singularity?.resolve()
	singularity_component?.roaming = TRUE

#undef NARSIE_CHANCE_TO_PICK_NEW_TARGET
