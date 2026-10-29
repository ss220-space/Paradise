#define INVISIBILITY_REVENANT 50
///Harvest
/mob/living/simple_animal/revenant/ClickOn(atom/A, params) //Copypaste from ghost code - revenants can't interact with the world directly.

	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		MiddleClickOn(A)
		return

	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		ShiftClickOn(A)
		return

	if(LAZYACCESS(modifiers, ALT_CLICK))
		AltClickOn(A)
		return

	if(LAZYACCESS(modifiers, CTRL_CLICK))
		CtrlClickOn(A)
		return

	if(world.time <= next_move)
		return

	A.attack_ghost(src)
	if(ishuman(A) && in_range(src, A))
		if(isLivingSSD(A) && client.send_ssd_warning(A)) //Do NOT Harvest SSD people unless you accept the warning
			return

		Harvest(A)

/mob/living/simple_animal/revenant/proc/Harvest(mob/living/carbon/human/target)
	if(!castcheck(0))
		return

	if(draining)
		to_chat(src, span_revenwarning("Вы уже вытягиваете эссенцию души!"))
		return

	var/mob_UID = target.UID()
	if(LAZYIN(drained_mobs, mob_UID))
		to_chat(src, span_revenwarning("Душа [target] мертва и пуста."))
		return

	if(!target.stat)
		to_chat(src, span_revennotice("Душа этого существа слишком сильна для поглощения."))
		if(prob(10))
			to_chat(target, "Вы чувствуете, будто за вами наблюдают.")
		return

	draining = TRUE
	essence_drained = rand(15, 20)
	to_chat(src, span_revennotice("Вы ищете душу [target]."))

	if(do_after(src, 1 SECONDS, target, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM)) //did they get deleted in that second?
		if(target.ckey)
			to_chat(src, span_revennotice("Их душа пылает интеллектом."))
			essence_drained += rand(20, 30)

		if(target.stat != DEAD)
			to_chat(src, span_revennotice("Их душа полыхает жизнью!"))
			essence_drained += rand(40, 50)
		else
			to_chat(src, span_revennotice("Их душа слаба и колеблется."))

		if(do_after(src, 2 SECONDS, target, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM)) //did they get deleted NOW?
			switch(essence_drained)
				if(1 to 30)
					to_chat(src, span_revennotice("[target] не даст много эссенции. Но каждая капля имеет значение."))
				if(30 to 70)
					to_chat(src, span_revennotice("[target] даст среднее количество эссенции."))
				if(70 to 90)
					to_chat(src, span_revenboldnotice("Какой пир! [target] даст вам много эссенции."))
				if(90 to INFINITY)
					to_chat(src, span_revenbignotice("Ах, идеальная душа. [target] даст вам огромное количество эссенции."))
			if(do_after(src, 2 SECONDS, target, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM)) //how about now
				if(!target.stat)
					to_chat(src, span_revenwarning("Теперь они достаточно сильны, чтобы сопротивляться вашему поглощению."))
					to_chat(target, span_boldannounceic("Вы чувствуете, как что-то дёргает ваше тело, а затем отпускает."))
					draining = FALSE
					return //hey, wait a minute...

				to_chat(src, span_revenminor("Вы начинаете вытягивать эссенцию души [target]."))
				if(target.stat != DEAD)
					to_chat(target, span_warning("Вы чувствуете ужасное ощущение истощения, как будто ваша хватка за жизнь ослабевает..."))

				reveal(27)
				stun(27)
				target.visible_message(span_warning("[target] внезапно слегка поднима[PLUR_ET_YUT(target)]ся в воздух, [GEND_HIS_HER(target)] кожа становится пепельно-серой."))
				target.Beam(src,icon_state="drain_life",icon='icons/effects/effects.dmi',time=26)

				if(do_after(src, 3 SECONDS, target, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM)) //As one cannot prove the existance of ghosts, ghosts cannot prove the existance of the target they were draining.
					change_essence_amount(essence_drained, 0, target)
					if(essence_drained > 90)
						essence_regen_cap += 25
						perfectsouls += 1
						var/datum/hud/revenant/hud = hud_used
						hud.update_huds()
						to_chat(src, span_revenboldnotice("Совершенство души [target] увеличило ваш максимальный уровень эссенции. Ваш новый максимум эссенции: [essence_regen_cap]."))
					to_chat(src, span_revennotice("Душа [target] значительно ослабла и больше не даст эссенции в ближайшее время."))
					target.visible_message(span_warning("[target] пада[PLUR_ET_YUT(target)] на землю."), span_revenwarning("Фиолетовые огни танцуют в вашем поле зрения, приближаясь..."))
					LAZYADD(drained_mobs, mob_UID)
					add_attack_logs(src, target, "revenant harvested soul")
					target.death()
				else
					to_chat(src, span_revenwarning("[target ? "Душа [target]":"Их душа"] вырвалась из вашей хватки. Связь разорвана."))
					draining = 0
					essence_drained = 0
					if(target) //Wait, target is WHERE NOW?
						target.visible_message(span_warning("[target] пада[PLUR_ET_YUT(target)] на землю."), span_revenwarning("Фиолетовые огни танцуют в вашем поле зрения, отдаляясь..."))
					return
			else
				to_chat(src, span_revenwarning("Вы недостаточно близко, чтобы вытягивать эссенцию [target ? "души [target]":"их души"]. Связь разорвана."))
				draining = FALSE
				essence_drained = 0
				return

	draining = FALSE
	essence_drained = 0

/**
 * Toggle night vision: lets the revenant toggle its night vision
 */
/datum/action/cooldown/spell/nightvision/revenant
	button_icon_state = "r_nightvision"
	background_icon_state = "bg_revenant"

//Transmit: the revemant's only direct way to communicate. Sends a single message silently to a single mob
/datum/action/cooldown/spell/pointed/revenant_transmit
	name = "Шёпот"
	desc = "Телепатически передаёт сообщение цели."
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	button_icon_state = "r_transmit"
	background_icon_state = "bg_revenant"
	background_icon_state_active = "bg_revenant"

/datum/action/cooldown/spell/pointed/revenant_transmit/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/pointed/revenant_transmit/cast(atom/cast_on)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(cast_async), target)

/datum/action/cooldown/spell/pointed/revenant_transmit/proc/cast_async(mob/living/target)
	var/msg = tgui_input_text(usr, "Что вы хотите передать [target]?", null, "")

	if(!msg)
		reset_spell_cooldown()
		return

	log_say("(REVENANT to [key_name(target)]) [msg]", owner)
	to_chat(owner, "[span_revenboldnotice("Вы передаёте [target]:")] [span_revennotice(msg)]")
	target.balloon_alert(target, "вы слышите жуткий голос")
	to_chat(target, "[span_revenboldnotice("Голос из ниоткуда раздаётся вокруг...")] [span_italics(msg)]")

/datum/action/cooldown/spell/revenantinvis
	name = "Переключить невидимость"
	desc = "Позволяет вам добровольно показать себя смертным."
	button_icon_state = "revenanttoggle"
	background_icon_state = "bg_revenant"
	spell_requirements = NONE

/datum/action/cooldown/spell/revenantinvis/cast(atom/cast_on)
	. = ..()
	var/mob/living/simple_animal/revenant/caster = cast_on
	if(caster.invisibility != INVISIBILITY_REVENANT)
		if(caster.unreveal_time >= world.time)
			caster.balloon_alert(caster, "слишком рано!")
			return
		caster.invisibility = INVISIBILITY_REVENANT
		caster.incorporeal_move = INCORPOREAL_REVENANT
		caster.update_appearance(UPDATE_ICON)
		return
	if(caster.essence <= 0)
		caster.balloon_alert(caster, "слишком мало эссенции!")
		return
	caster.invisibility = 0
	caster.incorporeal_move = INCORPOREAL_NONE
	caster.update_appearance(UPDATE_ICON)

/datum/action/cooldown/spell/aoe/revenant
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	background_icon_state = "bg_revenant"
	spell_max_level = 3
	/// How long it reveals the revenant in deciseconds
	var/reveal = 8 SECONDS
	/// How long it stuns the revenant in deciseconds
	var/stun = 2 SECONDS
	/// How much essence it costs to use
	var/cast_amount = 50
	var/cast_increase_per_level = 0
	var/max_cast_amount = 10000 // just random big numbers for max numbers
	var/max_radius = 100 SECONDS
	var/radius_increase_per_level = 0
	var/stun_increase_per_level = 0
	var/max_stun = 100 SECONDS
	var/reveal_increase_per_level = 0
	var/max_reveal = 100 SECONDS
	var/cooldown_increase_per_level = 0
	var/max_cooldown = 1000 SECONDS

/datum/action/cooldown/spell/aoe/revenant/New(Target, original)
	. = ..()
	name = "[get_spell_title()][initial(name)]"

/datum/action/cooldown/spell/aoe/revenant/create_new_handler()
	var/datum/spell_handler/revenant/handler = new(cast_amount)
	return handler

/datum/action/cooldown/spell/aoe/revenant/level_spell(bypass_cap)
	. = ..()
	aoe_radius = min(aoe_radius + radius_increase_per_level, max_radius)
	stun = min(stun + stun_increase_per_level, max_stun)
	reveal = min(reveal + reveal_increase_per_level, max_reveal)
	cast_amount = min(cast_amount + cast_increase_per_level, max_cast_amount)
	cooldown_time = min(cooldown_time + cooldown_increase_per_level, max_cooldown)
	QDEL_NULL(spell_handlers[/datum/spell_handler/revenant])
	spell_handlers[/datum/spell_handler/revenant] = create_new_handler()

//Overload Light: Breaks a light that's online and sends out lightning bolts to all nearby people.
/datum/action/cooldown/spell/aoe/revenant/overload
	name = "перегрузка сети"
	desc = "Направляет большое количество эссенции в ближайшие источники света, заставляя их бить током окружающих."
	cooldown_time = 15 SECONDS
	cooldown_increase_per_level = 5 SECONDS
	stun = 0.5 SECONDS
	stun_increase_per_level = 0.5 SECONDS
	reveal = 3 SECONDS
	reveal_increase_per_level = 3 SECONDS
	cast_amount = 30
	cast_increase_per_level = 15
	button_icon_state = "r_overload_lights"
	aoe_radius = 3
	radius_increase_per_level = 3
	targeting_type = /datum/aoe_targeting/light
	var/shock_range = 2
	var/shock_damage = 10

/datum/action/cooldown/spell/aoe/revenant/overload/level_spell(bypass_cap)
	. = ..()
	shock_damage += 10

/datum/action/cooldown/spell/aoe/revenant/overload/cast_on_thing_in_aoe(atom/victim, atom/caster)
	INVOKE_ASYNC(src, PROC_REF(shock_lights), victim, caster)

/datum/action/cooldown/spell/aoe/revenant/overload/proc/shock_lights(obj/machinery/light/L, mob/living/simple_animal/revenant/user)
	if(!L.on)
		return

	L.visible_message(span_boldwarning("[DECLENT_RU_CAP(L, NOMINATIVE)] внезапно вспыхивает и начинает искрить!"))
	do_sparks(4, FALSE, L)
	new /obj/effect/temp_visual/revenant(L.loc)
	sleep(2 SECONDS)
	if(!L.on) //wait, wait, don't shock me
		return

	flick("[L.base_icon_state]2", L)
	for(var/mob/living/M in view(shock_range, L))
		if(M == user)
			continue

		M.Beam(L, icon_state = "purple_lightning", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)
		M.electrocute_act(shock_damage, L, flags = SHOCK_NOGLOVES)
		if(spell_level == 3)
			M.apply_status_effect(/datum/status_effect/cursed_flame, 5 SECONDS, owner)
		do_sparks(4, FALSE, M)
		playsound(M, 'sound/machines/defib_zap.ogg', 50, TRUE, -1)

/datum/action/cooldown/spell/aoe/revenant/overload/get_spell_title()
	switch(spell_level)
		if(1)
			return "Незначительная "
		if(3)
			return "Полная "

//Defile: Corrupts nearby stuff, unblesses floor tiles.
/datum/action/cooldown/spell/aoe/revenant/defile
	name = "осквернение"
	desc = "Искажает и оскверняет ближайшую территорию, а также рассеивает святую ауру на полу."
	cooldown_time = 20 SECONDS
	cooldown_increase_per_level = 5 SECONDS
	stun = 0.5 SECONDS
	reveal = 3 SECONDS
	reveal_increase_per_level = 3 SECONDS
	cast_amount = 20
	cast_increase_per_level = 10
	button_icon_state = "r_defile"
	aoe_radius = 5
	radius_increase_per_level = 2
	max_radius = 7
	stun_increase_per_level = 0.5 SECONDS
	targeting_type = /datum/aoe_targeting/turfs

/datum/action/cooldown/spell/aoe/revenant/defile/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/turf/turf = victim
	turf.defile()
	if(spell_level >= 3 && prob(50))
		new /obj/effect/cursed_floor(turf, owner)
	for(var/atom/A as anything in turf.contents)
		A.defile()

/datum/action/cooldown/spell/aoe/revenant/defile/get_spell_title()
	switch(spell_level)
		if(1)
			return "Малое "
		if(2)
			return "Умеренное "
		if(3)
			return "Ужасающее "

//Malfunction: Makes bad stuff happen to robots and machines.
/datum/action/cooldown/spell/aoe/revenant/malfunction
	name = "Вызвать сбой"
	desc = "Повреждает и искажает ближайшие механизмы и технические объекты."
	cooldown_time = 10 SECONDS
	cooldown_increase_per_level = 5 SECONDS
	cast_amount = 30
	cast_increase_per_level = 15
	button_icon_state = "r_malfunction"
	aoe_radius = 5
	radius_increase_per_level = 4
	stun = 0.5 SECONDS
	stun_increase_per_level = 0.5 SECONDS
	reveal = 3 SECONDS
	reveal_increase_per_level = 3 SECONDS
	targeting_type = /datum/aoe_targeting/turfs

//A note to future coders: do not replace this with an EMP because it will wreck malf AIs and gang dominators and everyone will hate you.
/datum/action/cooldown/spell/aoe/revenant/malfunction/cast_on_thing_in_aoe(atom/victim, atom/caster)
		INVOKE_ASYNC(src, PROC_REF(effect), caster, victim)

/datum/action/cooldown/spell/aoe/revenant/malfunction/proc/effect(mob/living/simple_animal/revenant/user, turf/T)
	T.rev_malfunction(TRUE, spell_level)
	for(var/atom/A in T.contents)
		A.rev_malfunction(TRUE, spell_level)

/**
 * Makes objects be haunted and then throws them at conscious people to do damage, spooky!
 */
/datum/action/cooldown/spell/aoe/revenant/haunt_object
	name = "Призрачные предметы"
	desc = "Наполняет ближайшие предметы призрачной энергией, заставляя их атаковать живых. Предметы ближе к вам имеют больше шансов быть одержимыми."
	button_icon_state = "r_haunt"
	cooldown_time = 60 SECONDS
	cast_amount = 30
	cast_increase_per_level = 25
	stun = 0.5 SECONDS
	stun_increase_per_level = 0.5 SECONDS
	reveal = 3 SECONDS
	reveal_increase_per_level = 2 SECONDS
	/// The maximum number of objects to haunt
	max_targets = 7
	/// Self explanatory
	var/haunt_time = 10 SECONDS
	/// A list of all attack timers started by this spell being cast
	var/list/attack_timers = list()
	targeting_type = /datum/aoe_targeting/rev_haunt

/datum/action/cooldown/spell/aoe/revenant/haunt_object/level_spell(bypass_cap)
	. = ..()
	haunt_time += 10 SECONDS

/datum/action/cooldown/spell/aoe/revenant/haunt_object/cast(atom/cast_on)
	. = ..()
	// Stop the looping attacks after 20 SECONDS, roughly 4-5 attack cycles depending on lag
	addtimer(CALLBACK(src, PROC_REF(stop_timers)), haunt_time, TIMER_UNIQUE)

/datum/action/cooldown/spell/aoe/revenant/haunt_object/cast_on_thing_in_aoe(atom/victim, atom/caster)
	make_spooky(victim, caster)

/**
 * Handles making an object haunted and setting it up to attack.
 */
/datum/action/cooldown/spell/aoe/revenant/haunt_object/proc/make_spooky(obj/item/item_to_possess, mob/living/simple_animal/revenant/user)
	new /obj/effect/temp_visual/revenant(get_turf(item_to_possess)) // Thematic spooky visuals
	var/mob/living/simple_animal/possessed_object/possessed_object = new(item_to_possess) // Begin haunting object
	item_to_possess.throwforce = min(item_to_possess.throwforce + 5, 15) // Damage it should do? throwforce+5 or 15, whichever is lower
	set_outline(possessed_object)
	possessed_object.maxHealth = 75*spell_level // Double the regular HP of possessed objects
	possessed_object.health = possessed_object.maxHealth
	possessed_object.escape_chance = 100 // We cannot be contained

	addtimer(CALLBACK(src, PROC_REF(attack), possessed_object, user), 1 SECONDS, TIMER_UNIQUE) // Short warm-up for floaty ambience
	attack_timers.Add(addtimer(CALLBACK(src, PROC_REF(attack), possessed_object, user), 4 SECONDS, TIMER_UNIQUE|TIMER_LOOP|TIMER_STOPPABLE)) // 5 second looping attacks
	addtimer(CALLBACK(possessed_object, TYPE_PROC_REF(/mob/living/simple_animal/possessed_object, death)), haunt_time + 4 SECONDS, TIMER_UNIQUE) // De-haunt the object

/**
 * Handles finding a valid target and throwing us at it.
 */
/datum/action/cooldown/spell/aoe/revenant/haunt_object/proc/attack(mob/living/simple_animal/possessed_object/possessed_object, mob/living/simple_animal/revenant/user)
	var/list/potential_victims = list()

	for(var/mob/living/carbon/potential_victim in range(aoe_radius, get_turf(possessed_object)))
		if(!possessed_object.can_see(potential_victim, aoe_radius)) // You can't see me
			continue

		if(potential_victim.stat != CONSCIOUS) // Don't kill our precious essence-filled sleepy mobs
			continue

		potential_victims.Add(potential_victim)

	if(!length(potential_victims))
		possessed_object.possessed_item.throwforce = min(possessed_object.possessed_item.throwforce + 5, 15) // If an item is stood still for a while it can gather power
		set_outline(possessed_object)
		return

	var/mob/living/carbon/victim = pick(potential_victims)
	possessed_object.throw_at(victim, aoe_radius, 2, user)
	possessed_object.possessed_item.attack(victim, possessed_object)

/**
 * Sets the glow on the haunted object, scales up based on throwforce.
 */
/datum/action/cooldown/spell/aoe/revenant/haunt_object/proc/set_outline(mob/living/simple_animal/possessed_object/possessed_object)
	possessed_object.remove_filter("haunt_glow")
	var/outline_size = min((possessed_object.possessed_item.throwforce / 15) * 3, 3)
	possessed_object.add_filter("haunt_glow", 2, list("type" = "outline", "color" = "#7A4FA9", "size" = outline_size)) // Give it spooky purple outline

/**
 * Stop all attack timers cast by the previous spell use.
 */
/datum/action/cooldown/spell/aoe/revenant/haunt_object/proc/stop_timers()
	for(var/I in attack_timers)
		deltimer(I)

/**
 * Gives everyone in a 7 tile radius 2 minutes of hallucinations
 */
/datum/action/cooldown/spell/aoe/revenant/hallucinations
	name = "Аура галлюцинации"
	desc = "Играйте с живыми, показывая им видения того, что было или могло бы быть."
	button_icon_state = "r_hallucinations"
	cooldown_time = 15 SECONDS
	cast_amount = 15
	cast_increase_per_level = 10
	stun = 0
	stun_increase_per_level = 1 SECONDS
	max_stun = 1 SECONDS
	reveal = 3 SECONDS
	aoe_radius = 5
	radius_increase_per_level = 2
	reveal_increase_per_level = 2 SECONDS
	targeting_type = /datum/aoe_targeting/living

/datum/action/cooldown/spell/aoe/revenant/hallucinations/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/mob/living/carbon/human/target = victim
	target.AdjustHallucinate(60 SECONDS, bound_upper = 300 SECONDS) //Lets not let them get more than 5 minutes of hallucinations
	if(spell_level >= 3)
		target.apply_status_effect(/datum/status_effect/revenant_hallucinations, owner)
	new /obj/effect/temp_visual/revenant(get_turf(target))

/**
 * Infects targets with a ectoplasmic disease
 */
/datum/action/cooldown/spell/aoe/revenant/blight
	name = "Мор"
	desc = "Заражает ближайших людей болезнью, которая постепенно ослабляет их."
	button_icon_state = "r_blight"
	cooldown_time = 60 SECONDS
	cast_amount = 40
	stun = 3 SECONDS
	reveal = 7 SECONDS
	aoe_radius = 4
	spell_max_level = 1
	targeting_type = /datum/aoe_targeting/rev_blight

/datum/action/cooldown/spell/aoe/revenant/blight/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/mob/living/carbon/human/human = victim
	var/datum/disease/ectoplasmic/disease = new
	disease.Contract(human)
	new /obj/effect/temp_visual/revenant(get_turf(human))

/datum/action/cooldown/spell/aoe/revenant/mirage
	name = "Призрачный мираж"
	desc = "Создайте свою призрачную копию чтобы обмануть смертных. Нажатие ПКМ по способности при достаточной прокачке позволяет один раз поменяться местами с копией."
	button_icon_state = "revenantcopy"
	cast_amount = 15
	cast_increase_per_level = 15
	cooldown_time = 5 SECONDS
	cooldown_increase_per_level = 5 SECONDS
	stun_increase_per_level = 0.5 SECONDS
	reveal = 1 SECONDS
	reveal_increase_per_level = 2 SECONDS
	aoe_radius = 0
	var/obj/structure/revenant_mirage/mirage

/datum/action/cooldown/spell/aoe/revenant/mirage/cast(atom/cast_on)
	. = ..()
	if(mirage)
		qdel(mirage)
	mirage = new /obj/structure/revenant_mirage(owner.loc, spell_level, owner)

/datum/action/cooldown/spell/aoe/revenant/mirage/Trigger(mob/clicker, trigger_flags, atom/target)
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		if(spell_level < 3 && !(mirage in range(9, owner)))
			owner.balloon_alert(owner, "слишком далеко!")
			return CLICK_ACTION_BLOCKING
		if(!mirage.can_swap || mirage.swapped)
			owner.balloon_alert(owner, "мираж слишком слаб!")
			return CLICK_ACTION_BLOCKING
		mirage.Swap(owner)
		return CLICK_ACTION_SUCCESS
	return ..()

/obj/structure/revenant_mirage
	icon = 'icons/mob/mob.dmi'
	icon_state = "revenant_revealed"
	max_integrity = 100
	var/can_swap = FALSE
	var/swapped = FALSE
	var/explosion = FALSE
	var/mob/living/simple_animal/revenant/spawner

/obj/structure/revenant_mirage/New(loc, spell_level, mob/living/simple_animal/revenant/original)
	. = ..()
	max_integrity = max_integrity*spell_level
	obj_integrity = max_integrity
	name = original.name
	desc = original.desc
	spawner = original
	update_appearance()
	if(spell_level < 2)
		return
	can_swap =  TRUE
	if(spell_level < 3)
		return
	explosion = TRUE

/obj/structure/revenant_mirage/proc/Swap(mob/to_swap)
	swapped = TRUE
	var/turf/selfloc = loc
	loc = to_swap.loc
	to_swap.loc = selfloc

/obj/structure/revenant_mirage/Destroy(force)
	if(!explosion)
		return ..()
	revenant_fire_ring(src.loc, 3)
	for(var/mob/living/carbon/human/target in range(3, src))
		target.adjustStaminaLoss(25)
		target.apply_status_effect(/datum/status_effect/cursed_flame, 5 SECONDS, spawner)
	. = ..()

/datum/action/cooldown/spell/aoe/revenant/soul_lamp
	name = "Призвать маяк душ"
	desc = "Создайте маяк душ, который будет высасывать жизненную эссенцию из ближайших смертных и позволит использовать более мощные заклинания."
	button_icon_state = "spiritualstreetlight"
	cooldown_time = 120 SECONDS
	cast_amount = 100
	cast_increase_per_level = 50
	stun = 1 SECONDS
	stun_increase_per_level = 1 SECONDS
	reveal = 4 SECONDS
	reveal_increase_per_level = 2 SECONDS
	aoe_radius = 0
	var/list/spawned_lamps = list()

/datum/action/cooldown/spell/aoe/revenant/soul_lamp/cast(atom/cast_on)
	. = ..()
	spawned_lamps += new /obj/structure/revenant_lamp(owner.loc, src)

/datum/action/cooldown/spell/aoe/revenant/soul_lamp/level_spell(bypass_cap)
	. = ..()
	for(var/obj/structure/revenant_lamp/lamp as anything in spawned_lamps)
		lamp.update_level()

/datum/action/cooldown/spell/aoe/revenant/soul_lamp/Grant(mob/grant_to)
	. = ..()
	var/mob/living/simple_animal/revenant/r_owner = grant_to
	r_owner.have_lamp = TRUE
	r_owner.update_appearance()

/datum/action/cooldown/spell/aoe/revenant/soul_fire
	name = "Призрачное пламя"
	desc = "Выпустите волну призрачного пламени из вашего фонаря."
	button_icon_state = "lanternsflame"
	background_icon_state = "bg_revenant"
	cast_amount = 20
	cast_increase_per_level = 20
	cooldown_time = 25 SECONDS
	cooldown_increase_per_level = -5 SECONDS
	stun = 0.5 SECONDS
	stun_increase_per_level = 0.5 SECONDS
	reveal = 2 SECONDS
	reveal_increase_per_level = 2 SECONDS
	aoe_radius = 3
	radius_increase_per_level = 2
	targeting_type = /datum/aoe_targeting/human

/datum/action/cooldown/spell/aoe/revenant/soul_fire/cast(atom/cast_on)
	. = ..()
	revenant_fire_ring(owner.loc, aoe_radius)

/datum/action/cooldown/spell/aoe/revenant/soul_fire/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!ishuman(victim))
		return
	var/mob/living/carbon/human/target = victim
	target.apply_damage(10*spell_level, BURN)
	target.apply_status_effect(/datum/status_effect/cursed_flame, 5*spell_level SECONDS, owner)

/datum/action/cooldown/spell/pointed/revenant
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	background_icon_state = "bg_revenant"
	background_icon_state_active = "bg_revenant"
	spell_max_level = 3
	/// How long it reveals the revenant in deciseconds
	var/reveal = 8 SECONDS
	/// How long it stuns the revenant in deciseconds
	var/stun = 2 SECONDS
	/// How much essence it costs to use
	var/cast_amount = 50
	var/cast_increase_per_level = 0
	var/max_cast_amount = 10000 // just random big numbers for max numbers
	var/max_radius = 100 SECONDS
	var/radius_increase_per_level = 0
	var/stun_increase_per_level = 0
	var/max_stun = 100 SECONDS
	var/reveal_increase_per_level = 0
	var/max_reveal = 100 SECONDS
	var/cooldown_increase_per_level = 0
	var/max_cooldown = 1000 SECONDS

/datum/action/cooldown/spell/pointed/revenant/New(Target, original)
	. = ..()
	name = "[get_spell_title()][initial(name)]"

/datum/action/cooldown/spell/pointed/revenant/create_new_handler()
	var/datum/spell_handler/revenant/handler = new(cast_amount)
	return handler

/datum/action/cooldown/spell/pointed/revenant/level_spell(bypass_cap)
	. = ..()
	cast_range = min(cast_range + radius_increase_per_level, max_radius)
	stun = min(stun + stun_increase_per_level, max_stun)
	reveal = min(reveal + reveal_increase_per_level, max_reveal)
	cast_amount = min(cast_amount + cast_increase_per_level, max_cast_amount)
	cooldown_time = min(cooldown_time + cooldown_increase_per_level, max_cooldown)
	QDEL_NULL(spell_handlers[/datum/spell_handler/revenant])
	spell_handlers[/datum/spell_handler/revenant] = create_new_handler()

/datum/action/cooldown/spell/pointed/revenant/reflect
	name = "Отражение мук"
	desc = "Позволяет перенаправлять часть полученных повреждений в выбранного смертного."
	button_icon_state = "mirrorofsuffer"
	cast_amount = 20
	cast_increase_per_level = 15
	cooldown_time = 20 SECONDS
	cooldown_increase_per_level = 10 SECONDS
	stun = 0.5 SECONDS
	stun_increase_per_level = 0.5 SECONDS
	reveal = 3 SECONDS
	reveal_increase_per_level = 3 SECONDS

/datum/action/cooldown/spell/pointed/revenant/reflect/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/revenant/reflect/cast(atom/cast_on)
	. = ..()
	var/reflectpercent = 0.3*spell_level
	if(reflectpercent >= 0.9)
		reflectpercent = 1 // round to 100%
	var/mob/living/carbon/human/target = cast_on
	var/time = (10+(spell_level-1)*10) SECONDS
	target.apply_status_effect(/datum/status_effect/revenant_reflection, time, owner, reflectpercent)

/datum/action/cooldown/spell/pointed/revenant/gaze
	name = "Пугающий взор"
	desc = "Направьте пламя вашей лампы в смертного, ослепляя и оглушая его."
	button_icon_state = "laterngaze"
	cast_amount = 10
	cast_increase_per_level = 10
	cooldown_time = 15 SECONDS
	cooldown_increase_per_level = 5 SECONDS
	stun = 0
	stun_increase_per_level = 1 SECONDS
	reveal = 3 SECONDS
	reveal_increase_per_level = 2 SECONDS

/datum/action/cooldown/spell/pointed/revenant/gaze/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/revenant/gaze/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/target = cast_on
	target.Weaken(spell_level SECONDS)
	target.EyeBlind(spell_level SECONDS)
	target.Silence(spell_level SECONDS)
	target.AdjustJitter((5 + ((spell_level-1)*10)) SECONDS)
	target.AdjustConfused((5 + ((spell_level-1)*10)) SECONDS)
	target.AdjustDizzy((5 + ((spell_level-1)*10)) SECONDS)

/datum/action/cooldown/spell/pointed/revenant/tear
	name = "Слеза пламени"
	desc = "Выпустите в цель призрачную слезу из своего фонаря. При попадании слеза подожжет цель призрачным пламенем и нанесет урон ожогами."
	button_icon_state = "laterntear"
	cast_amount = 20
	cast_increase_per_level = 20
	cooldown_time = 20 SECONDS
	cooldown_increase_per_level = -10 SECONDS
	stun = 0.5 SECONDS
	stun_increase_per_level = 0.5 SECONDS
	reveal = 3 SECONDS
	reveal_increase_per_level = 3 SECONDS

/datum/action/cooldown/spell/pointed/revenant/tear/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/obj/projectile/rev_tear
	name = "ghostly fireball"
	icon = 'icons/effects/revenant.dmi'
	icon_state = "ghostlyfireball"
	speed = 3
	damage = 0
	damage_type = BURN
	forcedodge = -1
	ricochets_max = 0
	suppressed = TRUE

/obj/projectile/rev_tear/get_ru_names()
	return alist(
		NOMINATIVE = "снаряд призрачного пламени",
		GENITIVE = "снаряда призрачного пламени",
		DATIVE = "снаряду призрачного пламени",
		ACCUSATIVE = "снаряд призрачного пламени",
		INSTRUMENTAL = "снарядом призрачного пламени",
		PREPOSITIONAL = "снаряде призрачного пламени",
	)

/obj/projectile/rev_tear/on_hit(atom/target, blocked, hit_zone)
	if(target != original)
		return FALSE
	. = ..()
	var/mob/living/carbon/human/mobtarget = target
	mobtarget.apply_status_effect(/datum/status_effect/cursed_flame, jitter, firer)
	qdel(src)

/datum/action/cooldown/spell/pointed/revenant/tear/cast(atom/cast_on)
	. = ..()
	var/obj/projectile/rev_tear/proj = new(owner.loc)
	proj.firer = owner
	proj.damage = 10+spell_level*10
	proj.jitter = 15 SECONDS
	if(spell_level >= 3)
		proj.jitter += 15 SECONDS
	proj.preparePixelProjectile(cast_on, owner.loc)
	proj.fire()

/**
 * Defiling atoms.
 */

/turf/defile()
	if(turf_flags & NOJAUNT)
		turf_flags &= ~NOJAUNT
		new /obj/effect/temp_visual/revenant(loc)

/turf/simulated/floor/defile()
	..()
	if(prob(15))
		broken = FALSE
		burnt = FALSE
		make_plating(intact)

/turf/simulated/floor/plating/defile()
	if(turf_flags & NOJAUNT)
		turf_flags &= ~NOJAUNT
		new /obj/effect/temp_visual/revenant(loc)

/turf/simulated/floor/engine/cult/defile()
	if(turf_flags & NOJAUNT)
		turf_flags &= ~NOJAUNT
		new /obj/effect/temp_visual/revenant(loc)

/turf/simulated/wall/defile()
	..()
	if(prob(15))
		new/obj/effect/temp_visual/revenant(loc)
		ChangeTurf(/turf/simulated/wall/rust)

/turf/simulated/wall/r_wall/defile()
	..()
	if(prob(15))
		new/obj/effect/temp_visual/revenant(loc)
		ChangeTurf(/turf/simulated/wall/r_wall/rust)

/obj/structure/window/defile()
	take_damage(rand(30,80))
	if(fulltile)
		new /obj/effect/temp_visual/revenant/cracks(loc)

/obj/machinery/light/defile()
	flicker(30)

/mob/living/carbon/human/defile()
	to_chat(src, span_warning("Вы внезапно чувствуете [pick("усталость и растерянность", "тошноту", "головокружение")]."))
	apply_damages(tox = 5, stamina = 60)
	AdjustConfused(40 SECONDS, bound_lower = 0, bound_upper = 60 SECONDS)
	new /obj/effect/temp_visual/revenant(loc)

/atom/proc/defile()
	return

/turf/simulated/wall/r_wall/rust/defile()
	return

/turf/simulated/wall/shuttle/defile()
	return

/turf/simulated/wall/rust/defile()
	return

/turf/simulated/wall/r_wall/defile()
	return

/turf/simulated/wall/indestructible/defile()
	return

/turf/simulated/floor/shuttle/defile()
	return

/turf/simulated/floor/plating/defile()
	return

/**
 * Malfunctioning atoms.
 */

/mob/living/carbon/human/rev_malfunction(cause_emp = TRUE, malfunction_level = 1)
	to_chat(src, span_warning("Вы чувствуете [pick("потерю ориентации", "резкую боль в голове", "как мозг заполняет ледяная статика")]."))
	new /obj/effect/temp_visual/revenant(loc)
	if(cause_emp)
		emp_act(EMP_HEAVY)

/mob/living/simple_animal/bot/rev_malfunction(cause_emp = TRUE, malfunction_level = 1)
	if(!emagged)
		new /obj/effect/temp_visual/revenant(loc)
		locked = FALSE
		open = TRUE
		emag_act(null)

/mob/living/silicon/robot/rev_malfunction(cause_emp = TRUE, malfunction_level = 1)
	playsound(src, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
	new /obj/effect/temp_visual/revenant(loc)
	spark_system.start()
	if(cause_emp)
		emp_act(EMP_HEAVY)

/obj/rev_malfunction(cause_emp = TRUE, malfunction_level = 1)
	if(prob(20*malfunction_level))
		if(prob(50))
			new /obj/effect/temp_visual/revenant(loc)
		emag_act(null)
	else if(cause_emp)
		emp_act(EMP_HEAVY)

/obj/machinery/clonepod/rev_malfunction(cause_emp = TRUE, malfunction_level = 1)
	..(cause_emp = FALSE)

/atom/proc/rev_malfunction(cause_emp = TRUE, malfunction_level = 1)
	return

/obj/machinery/power/apc/rev_malfunction(cause_emp = TRUE, malfunction_level = 1)
	if(malfunction_level < 3)
		return
	emp_act(1)

/obj/machinery/power/smes/rev_malfunction(cause_emp = TRUE, malfunction_level = 1)
	if(malfunction_level < 3)
		return
	emp_act(1)

/obj/item/gun/energy/rev_malfunction(cause_emp = TRUE, malfunction_level = 1)
	if(malfunction_level < 3)
		return
	emp_act(1)

#undef INVISIBILITY_REVENANT
