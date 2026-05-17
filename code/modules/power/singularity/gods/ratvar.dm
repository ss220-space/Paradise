/obj/god/ratvar
	name = "Ратвар, Заводной Юстициар"
	gender = MALE

	icon = 'icons/obj/512x512.dmi'
	icon_state = "ratvar"
	pixel_x = -235
	pixel_y = -248

	light_color = COLOR_CULT_RATVAR
	light_power = 0.7
	light_range = 6

	consume_range = 12
	grav_pull = 10

	spawn_anim_icon = 'icons/obj/ratvar_spawn_anim.dmi'
	spawn_anim_state = "ratvar"
	apocalypse_god_name = "Ратвар"

	rise_sound = 'sound/effects/ratvar_reveal.ogg'
	ghost_alert_icon = 'icons/effects/clockwork_effects.dmi'
	ghost_alert_state = "ghostalert"
	ghost_alert_message = "Ратвар восстал в"

/obj/god/ratvar/wrap_announce(text)
	return span_ratvar(text)

/obj/god/ratvar/announce_summon()
	SSticker.mode?.clocker_objs.succesful_summon()

/obj/god/ratvar/announce_death()
	SSticker.mode?.clocker_objs.ratvar_death()

/obj/god/ratvar/devotees()
	return SSticker.mode?.clockwork_cult || list()

/obj/god/ratvar/attack_ghost(mob/dead/observer/user)
	if(!jobban_isbanned(user.ckey, ROLE_CLOCKER))
		return
	if(tgui_alert(user, "Вы хотите стать заводным мародёром Ратвара?", "Стать мародром?", list("Да", "Нет"), timeout = 10 SECONDS) == "Да")
		var/mob/living/simple_animal/hostile/clockwork/marauder/cog = new(get_turf(src))
		cog.possess_by_player(user.key)
		SSticker.mode.add_clocker(cog.mind)

/obj/god/ratvar/is_devotee(mob/living/carbon/mob)
	return isclocker(mob)

/obj/god/ratvar/consume(atom/target)
	target.ratvar_act(FALSE, src)
