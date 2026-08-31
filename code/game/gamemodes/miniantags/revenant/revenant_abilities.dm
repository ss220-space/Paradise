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
	to_chat(target, "[span_revenboldnotice("Голос из ниоткуда раздаётся вокруг...")] [span_italics(msg)]")

/datum/action/cooldown/spell/aoe/revenant
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	background_icon_state = "bg_revenant"
	/// How long it reveals the revenant in deciseconds
	var/reveal = 8 SECONDS
	/// How long it stuns the revenant in deciseconds
	var/stun = 2 SECONDS
	/// If it's locked and needs to be unlocked before use
	var/locked = TRUE
	/// How much essence it costs to unlock
	var/unlock_amount = 100
	/// How much essence it costs to use
	var/cast_amount = 50

/datum/action/cooldown/spell/aoe/revenant/New(Target, original)
	. = ..()
	if(locked)
		name = "[initial(name)] ([unlock_amount]E)"
	else
		name = "[initial(name)] ([cast_amount]E)"

/datum/action/cooldown/spell/aoe/revenant/reset_spell_cooldown()
	. = ..()
	to_chat(owner, span_revennotice("Ваша способность дрогнула и исчезла!"))
	var/mob/living/simple_animal/revenant/R = owner
	R?.essence += cast_amount //refund the spell and reset

/datum/action/cooldown/spell/aoe/revenant/can_cast_spell(feedback)
	if(!istype(owner, /mob/living/simple_animal/revenant))
		return FALSE
	var/mob/living/simple_animal/revenant/user = owner
	if(user.inhibited)
		return FALSE

	if(locked)
		if(user.essence <= unlock_amount)
			return FALSE

	if(user.essence <= cast_amount)
		return FALSE

	return ..()

/datum/action/cooldown/spell/aoe/revenant/proc/attempt_cast(mob/living/simple_animal/revenant/user = owner)
	cooldown_time = initial(cooldown_time)
	if(locked)
		if(!user.castcheck(-unlock_amount))
			reset_spell_cooldown()
			return FALSE

		name = "[initial(name)] ([cast_amount]E)"
		to_chat(user, span_revenwarning("Вы открыли способность <b>\"[initial(name)]\"</b>!"))

		locked = FALSE
		cooldown_time = 0

		return FALSE

	if(!user.castcheck(-cast_amount))
		reset_spell_cooldown()
		return FALSE

	name = "[initial(name)] ([cast_amount]E)"
	user.reveal(reveal)
	user.stun(stun)

	UpdateButtonIcon()

	return TRUE

//Overload Light: Breaks a light that's online and sends out lightning bolts to all nearby people.
/datum/action/cooldown/spell/aoe/revenant/overload
	name = "Перегрузить сеть"
	desc = "Направляет большое количество эссенции в ближайшие источники света, заставляя их бить током окружающих."
	cooldown_time = 20 SECONDS
	stun = 3 SECONDS
	cast_amount = 45
	var/shock_range = 2
	var/shock_damage = 20
	button_icon_state = "r_overload_lights"
	aoe_radius = 5
	targeting_type = /datum/aoe_targeting/light

/datum/action/cooldown/spell/aoe/revenant/overload/cast(atom/cast_on)
	var/mob/living/simple_animal/revenant/user = owner
	if(!attempt_cast(user))
		return
	return ..()

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

		do_sparks(4, FALSE, M)
		playsound(M, 'sound/machines/defib_zap.ogg', 50, TRUE, -1)

//Defile: Corrupts nearby stuff, unblesses floor tiles.
/datum/action/cooldown/spell/aoe/revenant/defile
	name = "Осквернить"
	desc = "Искажает и оскверняет ближайшую территорию, а также рассеивает святую ауру на полу."
	cooldown_time = 15 SECONDS
	stun = 1 SECONDS
	reveal = 4 SECONDS
	unlock_amount = 75
	cast_amount = 30
	button_icon_state = "r_defile"
	aoe_radius = 4
	targeting_type = /datum/aoe_targeting/turfs

/datum/action/cooldown/spell/aoe/revenant/defile/cast(atom/cast_on)
	var/mob/living/simple_animal/revenant/user = owner
	if(!attempt_cast(user))
		return
	. = ..()

/datum/action/cooldown/spell/aoe/revenant/defile/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/turf/turf = victim
	turf.defile()

	for(var/atom/A as anything in turf.contents)
		A.defile()

//Malfunction: Makes bad stuff happen to robots and machines.
/datum/action/cooldown/spell/aoe/revenant/malfunction
	name = "Вызвать сбой"
	desc = "Повреждает и искажает ближайшие механизмы и технические объекты."
	cooldown_time = 20 SECONDS
	cast_amount = 45
	unlock_amount = 150
	button_icon_state = "r_malfunction"
	aoe_radius = 2
	targeting_type = /datum/aoe_targeting/turfs

/datum/action/cooldown/spell/aoe/revenant/malfunction/cast(atom/cast_on)
	var/mob/living/simple_animal/revenant/user = owner
	if(!attempt_cast(user))
		return
	return ..()

//A note to future coders: do not replace this with an EMP because it will wreck malf AIs and gang dominators and everyone will hate you.
/datum/action/cooldown/spell/aoe/revenant/malfunction/cast_on_thing_in_aoe(atom/victim, atom/caster)
		INVOKE_ASYNC(src, PROC_REF(effect), caster, victim)

/datum/action/cooldown/spell/aoe/revenant/malfunction/proc/effect(mob/living/simple_animal/revenant/user, turf/T)
	T.rev_malfunction(TRUE)

	for(var/atom/A in T.contents)
		A.rev_malfunction(TRUE)

/**
 * Makes objects be haunted and then throws them at conscious people to do damage, spooky!
 */
/datum/action/cooldown/spell/aoe/revenant/haunt_object
	name = "Призрачные предметы"
	desc = "Наполняет ближайшие предметы призрачной энергией, заставляя их атаковать живых. Предметы ближе к вам имеют больше шансов быть одержимыми."
	button_icon_state = "r_haunt"
	cooldown_time = 60 SECONDS
	unlock_amount = 150
	stun = 3 SECONDS
	reveal = 10 SECONDS
	/// The maximum number of objects to haunt
	max_targets = 7
	/// Self explanatory
	var/haunt_time = 20 SECONDS
	/// A list of all attack timers started by this spell being cast
	var/list/attack_timers = list()
	targeting_type = /datum/aoe_targeting/rev_haunt

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
	possessed_object.maxHealth = 100 // Double the regular HP of possessed objects
	possessed_object.health = 100
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
	desc = "Играйте с живыми, показывая им видения того, что могло бы быть или было."
	button_icon_state = "r_hallucinations"
	cooldown_time = 15 SECONDS
	unlock_amount = 50
	cast_amount = 25
	stun = 1 SECONDS
	reveal = 3 SECONDS
	targeting_type = /datum/aoe_targeting/living

/datum/action/cooldown/spell/aoe/revenant/hallucinations/cast(atom/cast_on)
	var/mob/living/simple_animal/revenant/user = owner
	if(!attempt_cast(user))
		return
	. = ..()

/datum/action/cooldown/spell/aoe/revenant/hallucinations/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/mob/living/carbon/human/target = victim
	target.AdjustHallucinate(60 SECONDS, bound_upper = 300 SECONDS) //Lets not let them get more than 5 minutes of hallucinations
	new /obj/effect/temp_visual/revenant(get_turf(target))

/**
 * Infects targets with a ectoplasmic disease
 */
/datum/action/cooldown/spell/aoe/revenant/blight
	name = "Мор"
	desc = "Заражает ближайших людей болезнью, которая постепенно ослабляет их."
	button_icon_state = "blight"
	cooldown_time = 60 SECONDS
	unlock_amount = 200
	cast_amount = 40
	stun = 3 SECONDS
	reveal = 7 SECONDS
	aoe_radius = 4
	targeting_type = /datum/aoe_targeting/rev_blight

/datum/action/cooldown/spell/aoe/revenant/blight/cast(atom/cast_on)
	var/mob/living/simple_animal/revenant/user = owner
	if(!attempt_cast(user))
		return
	. = ..()

/datum/action/cooldown/spell/aoe/revenant/blight/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/mob/living/carbon/human/human = victim
	var/datum/disease/ectoplasmic/disease = new
	disease.Contract(human)
	new /obj/effect/temp_visual/revenant(get_turf(human))

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

/obj/structure/closet/defile()
	open()

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

/mob/living/carbon/human/rev_malfunction(cause_emp = TRUE)
	to_chat(src, span_warning("Вы чувствуете [pick("потерю ориентации", "резкую боль в голове", "как мозг заполняет ледяная статика")]."))
	new /obj/effect/temp_visual/revenant(loc)
	if(cause_emp)
		emp_act(1)

/mob/living/simple_animal/bot/rev_malfunction(cause_emp = TRUE)
	if(!emagged)
		new /obj/effect/temp_visual/revenant(loc)
		locked = FALSE
		open = TRUE
		emag_act(null)

/mob/living/silicon/robot/rev_malfunction(cause_emp = TRUE)
	playsound(src, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
	new /obj/effect/temp_visual/revenant(loc)
	spark_system.start()
	if(cause_emp)
		emp_act(1)

/obj/rev_malfunction(cause_emp = TRUE)
	if(prob(20))
		if(prob(50))
			new /obj/effect/temp_visual/revenant(loc)
		emag_act(null)
	else if(cause_emp)
		emp_act(1)

/obj/machinery/clonepod/rev_malfunction(cause_emp = TRUE)
	..(cause_emp = FALSE)

/atom/proc/rev_malfunction(cause_emp = TRUE)
	return

/obj/machinery/power/apc/rev_malfunction(cause_emp = TRUE)
	return

/obj/machinery/power/smes/rev_malfunction(cause_emp = TRUE)
	return

