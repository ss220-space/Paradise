//This should hold all the vampire related powers

/obj/effect/proc_holder/spell/vampire
	panel = "Vampire"
	school = "vampire"
	clothes_req = 0
	range = 1
	charge_max = 1800
	action_background_icon_state = "bg_vampire"
	var/required_blood = 0
	var/gain_desc = null
	var/ru_gain_desc = null

/obj/effect/proc_holder/spell/vampire/New()
	..()
	if(!gain_desc)
		gain_desc = "You have gained \the [src] ability."
		ru_gain_desc = "Вы получили способность «[src]»."

/obj/effect/proc_holder/spell/vampire/cast_check(charge_check = TRUE, start_recharge = TRUE, mob/living/user = usr)
	if(!user.mind)
		return 0
	if(!ishuman(user))
		to_chat(user, pick_translation("<span class='warning'>You are in too weak of a form to do this!</span>",
			"<span class='warning'>Ваша форма для этого недостаточно сильна!</span>"))
		return 0

	var/datum/vampire/vampire = user.mind.vampire

	if(!vampire)
		return 0

	var/fullpower = vampire.get_ability(/datum/vampire_passive/full)

	if(user.stat >= DEAD)
		to_chat(user, pick_translation("<span class='warning'>Not when you're dead!</span>",
			"<span class='warning'>Но вы же мертвы!</span>"))
		return 0

	if(vampire.nullified && !fullpower)
		to_chat(user, pick_translation("<span class='warning'>Something is blocking your powers!</span>",
			"<span class='warning'>Что-то блокирует ваши силы!</span>"))
		return 0
	if(vampire.bloodusable < required_blood)
		to_chat(user, pick_translation("<span class='warning'>You require at least [required_blood] units of usable blood to do that!</span>",
			"<span class='warning'>Для этого вам потребуется не менее [required_blood] единиц крови!</span>"))
		return 0
	//chapel check
	if(istype(loc.loc, /area/chapel) && !fullpower)
		to_chat(user, pick_translation("<span class='warning'>Your powers are useless on this holy ground.</span>",
			"<span class='warning'>Ваши силы не действуют на этой святой земле.</span>"))
		return 0
	return ..()

/obj/effect/proc_holder/spell/vampire/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(!user.mind)
		return 0
	if(!ishuman(user))
		return 0

	var/datum/vampire/vampire = user.mind.vampire

	if(!vampire)
		return 0

	var/fullpower = vampire.get_ability(/datum/vampire_passive/full)

	if(user.stat >= DEAD)
		return 0

	if(vampire.nullified && !fullpower)
		return 0
	if(vampire.bloodusable < required_blood)
		return 0
	if(istype(loc.loc, /area/chapel) && !fullpower)
		return 0
	return ..()

/obj/effect/proc_holder/spell/vampire/proc/affects(mob/target, mob/user = usr)
	//Other vampires aren't affected
	if(target.mind && target.mind.vampire)
		return 0
	//Vampires who have reached their full potential can affect nearly everything
	if(user.mind.vampire.get_ability(/datum/vampire_passive/full))
		return 1
	//Holy characters are resistant to vampire powers
	if(target.mind && target.mind.isholy)
		return 0
	return 1

/obj/effect/proc_holder/spell/vampire/proc/can_reach(mob/M as mob)
	if(M.loc == usr.loc)
		return 1 //target and source are in the same thing
	return M in oview_or_orange(range, usr, selection_type)

/obj/effect/proc_holder/spell/vampire/before_cast(list/targets)
	// sanity check before we cast
	if(!usr.mind || !usr.mind.vampire)
		targets.Cut()
		return

	if(!required_blood)
		return

	// enforce blood
	var/datum/vampire/vampire = usr.mind.vampire

	if(required_blood <= vampire.bloodusable)
		vampire.bloodusable -= required_blood
	else
		// stop!!
		targets.Cut()

	if(targets.len)
		to_chat(usr, pick_translation("<span class='notice'><b>You have [vampire.bloodusable] left to use.</b></span>",
			"<span class='notice'><b>У вас осталось [vampire.bloodusable] единиц крови.</b></span>"))

/obj/effect/proc_holder/spell/vampire/targetted/choose_targets(mob/user = usr)
	var/list/possible_targets[0]
	for(var/mob/living/carbon/C in oview_or_orange(range, user, selection_type))
		possible_targets += C
	var/mob/living/carbon/T = input(user, pick_translation("Choose your victim.",
		"Выберите жертву."), name) as null|mob in possible_targets

	if(!T || !can_reach(T))
		revert_cast(user)
		return

	perform(list(T), user = user)

/obj/effect/proc_holder/spell/vampire/self/choose_targets(mob/user = usr)
	perform(list(user))

/obj/effect/proc_holder/spell/vampire/mob_aoe/choose_targets(mob/user = usr)
	var/list/targets[0]
	for(var/mob/living/carbon/C in oview_or_orange(range, user, selection_type))
		targets += C

	if(!targets.len)
		revert_cast(user)
		return

	perform(targets, user = user)

/datum/vampire_passive
	var/gain_desc
	var/ru_gain_desc

/datum/vampire_passive/New()
	..()
	if(!gain_desc)
		gain_desc = "You have gained \the [src] ability."
		ru_gain_desc = "Вы получили способность «[src]»."

////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/vampire/self/rejuvenate
	name = "Rejuvenate"
	desc = "Use reserve blood to enliven your body, removing any incapacitating effects."
	ru_name = "Восстановление"
	ru_desc = "Используйте накопленную кровь, чтобы влить в тело новые силы, устраняя любое ошеломление"
	action_icon_state = "vampire_rejuvinate"
	charge_max = 200
	stat_allowed = 1

/obj/effect/proc_holder/spell/vampire/self/rejuvenate/cast(list/targets, mob/user = usr)
	var/mob/living/U = user

	user.SetWeakened(0)
	user.SetStunned(0)
	user.SetParalysis(0)
	user.SetSleeping(0)
	U.adjustStaminaLoss(-60)
	to_chat(user, pick_translation("<span class='notice'>You instill your body with clean blood and remove any incapacitating effects.</span>",
		"<span class='notice'>Ваше тело наполняется чистой кровью, снимая все ошеломляющие эффекты.</span>"))
	spawn(1)
		if(usr.mind.vampire.get_ability(/datum/vampire_passive/regen))
			for(var/i = 1 to 5)
				U.adjustBruteLoss(-2)
				U.adjustOxyLoss(-5)
				U.adjustToxLoss(-2)
				U.adjustFireLoss(-2)
				U.adjustStaminaLoss(-10)
				sleep(35)

/obj/effect/proc_holder/spell/vampire/targetted/hypnotise
	name = "Hypnotise (25)"
	desc = "A piercing stare that incapacitates your victim for a good length of time."
	ru_name = "Гипноз (25)"
	ru_desc = "Пронзающий взгляд, ошеломляющий жертву на довольно долгое время"
	action_icon_state = "vampire_hypnotise"
	required_blood = 25

/obj/effect/proc_holder/spell/vampire/targetted/hypnotise/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		user.visible_message("<span class='warning'>[user]'s eyes flash briefly as [user.p_they()] stare[user.p_s()] into [target]'s eyes</span>",
			ru_message = "<span class='warning'>Глаза [user] вспыхивают, когда [user.p_they()] пристально смотрит в глаза [target]</span>")
		if(do_mob(user, target, 60))
			if(!affects(target))
				to_chat(user, pick_translation("<span class='warning'>Your piercing gaze fails to knock out [target].</span>",
					"<span class='warning'>Ваш пронзительный взгляд не смог заворожить [target].</span>"))
				to_chat(target, pick_translation("<span class='notice'>[user]'s feeble gaze is ineffective.</span>",
					"<span class='notice'>Невыразительный взгляд [user] ничего вам не делает.</span>", target = target.client))
			else
				to_chat(user, pick_translation("<span class='warning'>Your piercing gaze knocks out [target].</span>",
					"<span class='warning'>Ваш пронзающий взгляд завораживает [target].</span>"))
				to_chat(target, pick_translation("<span class='warning'>You suddenly feel very weak.</span>",
					"<span class='warning'>Вы чувствуете сильную слабость.</span>", target = target.client))
				target.SetSleeping(20)
		else
			revert_cast(usr)
			to_chat(usr, pick_translation("<span class='warning'>You broke your gaze.</span>",
				"<span class='warning'>Вы смотрите в никуда.</span>"))

/obj/effect/proc_holder/spell/vampire/targetted/disease
	name = "Diseased Touch (50)"
	desc = "Touches your victim with infected blood giving them Grave Fever, which will, left untreated, causes toxic building and frequent collapsing."
	gain_desc = "You have gained the Diseased Touch ability which causes those you touch to become weak unless treated medically."
	ru_name = "Заражающее касание (50)"
	ru_desc = "Ваше касание инфицирует кровь жертвы, заражая её могильной лихорадкой. Пока лихорадку не вылечат, жертва будет с трудом держаться на ногах, а её кровь будет наполняться токсинами."
	ru_gain_desc = "Вы получили способность «Заражающее касание». Она позволит вам ослаблять тех, кого вы коснётесь до тех пор, пока их не вылечат."
	action_icon_state = "vampire_disease"
	required_blood = 50

/obj/effect/proc_holder/spell/vampire/targetted/disease/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/target in targets)
		to_chat(user, pick_translation("<span class='warning'>You stealthily infect [target] with your diseased touch.</span>",
			"<span class='warning'>Вы незаметно инфицируете [target] заражающим касанием.</span>"))
		target.help_shake_act(user)
		if(!affects(target))
			to_chat(user, pick_translation("<span class='warning'>They seem to be unaffected.</span>",
				"<span class='warning'>Вам кажется, что заражающее касание не подействовало на [target].</span>"))
			continue
		var/datum/disease/D = new /datum/disease/vampire
		target.ForceContractDisease(D)

/obj/effect/proc_holder/spell/vampire/mob_aoe/glare
	name = "Glare"
	desc = "A scary glare that incapacitates people for a short while around you."
	ru_name = "Вспышка"
	ru_desc = "Вы сверкаете глазами, ненадолго ошеломляя всех людей вокруг"
	action_icon_state = "vampire_glare"
	charge_max = 300
	stat_allowed = 1

/obj/effect/proc_holder/spell/vampire/mob_aoe/glare/cast(list/targets, mob/user = usr)
	user.visible_message("<span class='warning'>[user]'s eyes emit a blinding flash!</span>",
		ru_message = "<span class='warning'>Глаза [user] ослепительно вспыхивают!</span>")
	if(istype(user:glasses, /obj/item/clothing/glasses/sunglasses/blindfold))
		to_chat(user, pick_translation("<span class='warning'>You're blindfolded!</span>",
			"<span class='warning'>У вас на глазах повязка!</span>"))
		return
	for(var/mob/living/target in targets)
		if(!affects(target))
			continue
		target.Stun(2)
		target.Weaken(2)
		target.stuttering = 20
		target.adjustStaminaLoss(20)
		to_chat(target, pick_translation("<span class='warning'>You are blinded by [user]'s glare.</span>",
			"<span class='warning'>Вы ослеплены вспышкой из глаз [user].</span>", target = target.client))
		add_attack_logs(user, target, pick_translation("(Vampire) Glared at",
			"(Vampire) слепит"))
		target.apply_status_effect(STATUS_EFFECT_STAMINADOT)

/obj/effect/proc_holder/spell/vampire/self/shapeshift
	name = "Shapeshift (50)"
	desc = "Changes your name and appearance at the cost of 50 blood and has a cooldown of 3 minutes."
	gain_desc = "You have gained the shapeshifting ability, at the cost of stored blood you can change your form permanently."
	ru_name = "Превращение (50)"
	ru_desc = "Изменяет ваше имя и внешность, тратя 50 крови, с откатом в 3 минуты."
	ru_gain_desc = "Вы получили способность «Превращение», позволяющую навсегда обернуться другим обликом, затратив часть накопленной крови."
	action_icon_state = "genetic_poly"
	required_blood = 50

/obj/effect/proc_holder/spell/vampire/self/shapeshift/cast(list/targets, mob/user = usr)
	user.visible_message("<span class='warning'>[user] transforms!</span>",
		ru_message = "<span class='warning'>[user] изменяется!</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		scramble(1, H, 100)
		H.real_name = random_name(H.gender, H.dna.species.name) //Give them a name that makes sense for their species.
		H.sync_organ_dna(assimilate = 1)
		H.update_body()
		H.reset_hair() //No more winding up with hairstyles you're not supposed to have, and blowing your cover.
		H.reset_markings() //...Or markings.
		H.dna.ResetUIFrom(H)
		H.flavor_text = ""
	user.update_icons()

/obj/effect/proc_holder/spell/vampire/self/screech
	name = "Chiropteran Screech (30)"
	desc = "An extremely loud shriek that stuns nearby humans and breaks windows as well."
	gain_desc = "You have gained the Chiropteran Screech ability which stuns anything with ears in a large radius and shatters glass in the process."
	ru_name = "Визг рукокрылых (30)"
	ru_desc = "Невероятно громкий визг, разбивающий стёкла и ошеломляющий окружающих."
	ru_gain_desc = "Вы получили способность «Визг рукокрылых», в большом радиусе оглушающую всех, кто может слышать, и раскалывающую стёкла."
	action_icon_state = "vampire_screech"
	required_blood = 30

/obj/effect/proc_holder/spell/vampire/self/screech/cast(list/targets, mob/user = usr)
	user.visible_message("<span class='warning'>[user] lets out an ear piercing shriek!</span>",
		 "<span class='warning'>You let out a loud shriek.</span>",
			"<span class='warning'>You hear a loud painful shriek!</span>",
				"<span class='warning'>[user] издаёт ушераздирающий визг!</span>",
					"<span class='warning'>Вы громко визжите.</span>",
						"<span class='warning'>Вы слышите болезненно громкий визг!</span>")
	for(var/mob/living/carbon/C in hearers(4))
		if(C == user)
			continue
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(H.check_ear_prot() >= HEARING_PROTECTION_TOTAL)
				continue
		if(!affects(C))
			continue
		to_chat(C, pick_translation("<span class='warning'><font size='3'><b>You hear a ear piercing shriek and your senses dull!</font></b></span>",
			"<span class='warning'><font size='3'><b>Вы слышите ушераздирающий визг и ваши чувства притупляются!</font></b></span>", target = C.client))
		C.Weaken(2)
		C.MinimumDeafTicks(20)
		C.Stuttering(20)
		C.Stun(2)
		C.Jitter(150)
		C.adjustStaminaLoss(60)
	for(var/obj/structure/window/W in view(4))
		W.deconstruct(FALSE)
	playsound(user.loc, 'sound/effects/creepyshriek.ogg', 100, 1)


/proc/isvampirethrall(mob/living/M as mob)
	return istype(M) && M.mind && SSticker && SSticker.mode && (M.mind in SSticker.mode.vampire_enthralled)

/obj/effect/proc_holder/spell/vampire/targetted/enthrall
	name = "Enthrall (300)"
	desc = "You use a large portion of your power to sway those loyal to none to be loyal to you only."
	gain_desc = "You have gained the Enthrall ability which at a heavy blood cost allows you to enslave a human that is not loyal to any other for a random period of time."
	ru_name = "Порабощение (300)"
	ru_desc = "Вы используете большую часть своей силы, вынуждая тех, кто ещё никому не служит, служить только вам."
	ru_gain_desc = "Вы получили способность «Порабощение», которая тратит много крови, но позволяет вам поработить человека, который ещё никому не служит, на случайный период времени."
	action_icon_state = "vampire_enthrall"
	required_blood = 300

/obj/effect/proc_holder/spell/vampire/targetted/enthrall/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		user.visible_message("<span class='warning'>[user] bites [target]'s neck!</span>",
			"<span class='warning'>You bite [target]'s neck and begin the flow of power.</span>",
				ru_message = "<span class='warning'>[user] кусает [target] в шею!</span>",
					ru_self_message = "<span class='warning'>Вы кусаете [target] в шею и начинаете передачу части своей силы.</span>")
		to_chat(target, pick_translation("<span class='warning'>You feel the tendrils of evil invade your mind.</span>",
			"<span class='warning'>Вы ощущаете, как щупальца зла впиваются в ваш разум.</span>", target = target.client))
		if(!ishuman(target))
			to_chat(user, pick_translation("<span class='warning'>You can only enthrall humans.</span>",
				"<span class='warning'>Вы можете порабощать только гуманоидов.</span>"))
			break
		if(do_mob(user, target, 50))
			if(can_enthrall(user, target))
				handle_enthrall(user, target)
			else
				revert_cast(user)
				to_chat(user, pick_translation("<span class='warning'>You or your target either moved or you dont have enough usable blood.</span>",
					"<span class='warning'>Вы или цель сдвинулись, или вам не хватило запаса крови.</span>"))

/obj/effect/proc_holder/spell/vampire/targetted/enthrall/proc/can_enthrall(mob/living/user, mob/living/carbon/C)
	var/enthrall_safe = 0
	for(var/obj/item/implant/mindshield/L in C)
		if(L && L.implanted)
			enthrall_safe = 1
			break
	for(var/obj/item/implant/traitor/T in C)
		if(T && T.implanted)
			enthrall_safe = 1
			break
	if(!C)
		log_runtime(EXCEPTION("something bad happened on enthralling a mob, attacker is [user] [user.key] \ref[user]"), user)
		return 0
	if(!C.mind)
		to_chat(user, pick_translation("<span class='warning'>[C.name]'s mind is not there for you to enthrall.</span>",
			"<span class='warning'>Разум [C.name] сейчас не здесь, поэтому порабощение не удастся.</span>"))
		return 0
	if(enthrall_safe || ( C.mind in SSticker.mode.vampires )||( C.mind.vampire )||( C.mind in SSticker.mode.vampire_enthralled ))
		C.visible_message("<span class='warning'>[C] seems to resist the takeover!</span>",
			"<span class='notice'>You feel a familiar sensation in your skull that quickly dissipates.</span>",
				ru_message = "<span class='warning'>Похоже что [C] сопротивляется захвату!</span>",
					ru_self_message = "<span class='notice'>Вы ощущаете в голове знакомое ощущение, но оно быстро проходит.</span>")
		return 0
	if(!affects(C))
		C.visible_message("<span class='warning'>[C] seems to resist the takeover!</span>",
			"<span class='notice'>Your faith of [SSticker.Bible_deity_name] has kept your mind clear of all evil.</span>",
				ru_message = "<span class='warning'>Похоже что [C] сопротивляется захвату!</span>",
					ru_self_message = "<span class='notice'>Вера в [SSticker.Bible_deity_name] защищает ваш разум от всякого зла.</span>")
		return 0
	if(!ishuman(C))
		to_chat(user, pick_translation("<span class='warning'>You can only enthrall humans!</span>",
			"<span class='warning'>Вы можете порабощать только гуманоидов!</span>"))
		return 0
	return 1

/obj/effect/proc_holder/spell/vampire/targetted/enthrall/proc/handle_enthrall(mob/living/user, mob/living/carbon/human/H as mob)
	if(!istype(H))
		return 0
	var/ref = "\ref[user.mind]"
	if(!(ref in SSticker.mode.vampire_thralls))
		SSticker.mode.vampire_thralls[ref] = list(H.mind)
	else
		SSticker.mode.vampire_thralls[ref] += H.mind

	SSticker.mode.update_vampire_icons_added(H.mind)
	SSticker.mode.update_vampire_icons_added(user.mind)
	var/datum/mindslaves/slaved = user.mind.som
	H.mind.som = slaved
	slaved.serv += H
	slaved.add_serv_hud(user.mind, "vampire")//handles master servent icons
	slaved.add_serv_hud(H.mind, "vampthrall")

	SSticker.mode.vampire_enthralled.Add(H.mind)
	SSticker.mode.vampire_enthralled[H.mind] = user.mind
	H.mind.special_role = SPECIAL_ROLE_VAMPIRE_THRALL

	var/datum/objective/protect/serve_objective = new
	serve_objective.owner = user.mind
	serve_objective.target = H.mind
	serve_objective.explanation_text = pick_translation("You have been Enthralled by [user.real_name]. Follow [user.p_their()] every command.",
		"Вы были порабощены [user.real_name]. Выполняйте все [user.p_their()] приказы.", target = H.client)
	H.mind.objectives += serve_objective

	to_chat(H, pick_translation("<span class='biggerdanger'>You have been Enthralled by [user.real_name]. Follow [user.p_their()] every command.</span>",
		"<span class='biggerdanger'>Вы были порабощены [user.real_name]. Выполняйте все [user.p_their()] приказы.</span>", target = H.client))
	to_chat(user, pick_translation("<span class='warning'>You have successfully Enthralled [H]. <i>If [H.p_they()] refuse[H.p_s()] to do as you say just adminhelp.</i></span>",
		"<span class='warning'>Вы успешно поработили [H]. <i>Если [genderize_ru(H.gender, "он", "она", "оно", "они")] откажется вас слушаться, используйте adminhelp.</i></span>"))
	H.Stun(2)
	add_attack_logs(user, H, "Vampire-thralled")


/obj/effect/proc_holder/spell/vampire/self/cloak
	name = "Cloak of Darkness"
	desc = "Toggles whether you are currently cloaking yourself in darkness."
	gain_desc = "You have gained the Cloak of Darkness ability which when toggled makes you near invisible in the shroud of darkness."
	ru_name = "Покров тьмы"
	ru_desc = "Переключается, маскируя вас в темноте"
	ru_gain_desc = "Вы получили способность «Покров тьмы», которая, будучи включённой, делает вас практически невидимым в темноте."
	action_icon_state = "vampire_cloak"
	charge_max = 10

/obj/effect/proc_holder/spell/vampire/self/cloak/New()
	..()
	update_name()

/obj/effect/proc_holder/spell/vampire/self/cloak/proc/update_name()
	var/mob/living/user = loc
	if(!ishuman(user) || !user.mind || !user.mind.vampire)
		return
	name = "[initial(name)] ([user.mind.vampire.iscloaking ? pick_translation("Deactivate", "Выключить") : pick_translation("Activate", "Включить")]"

/obj/effect/proc_holder/spell/vampire/self/cloak/cast(list/targets, mob/user = usr)
	var/datum/vampire/V = user.mind.vampire
	V.iscloaking = !V.iscloaking
	update_name()
	to_chat(user, pick_translation("<span class='notice'>You will now be [V.iscloaking ? "hidden" : "seen"] in darkness.</span>",
		"<span class='notice'>Теперь вас будет <b>[V.iscloaking ? "не видно" : "видно"]</b> в темноте</span>"))

/obj/effect/proc_holder/spell/vampire/bats
	name = "Summon Bats (50)"
	desc = "You summon a pair of space bats who attack nearby targets until they or their target is dead."
	gain_desc = "You have gained the Summon Bats ability."
	ru_name = "Дети ночи (50)"
	ru_desc = "Вы вызываете пару космолетучих мышей, которые будут биться насмерть со всеми вокруг"
	ru_gain_desc = "Вы получили способность «Дети ночи», призывающую летучих мышей."
	action_icon_state = "vampire_bats"
	charge_max = 1200
	required_blood = 50
	var/num_bats = 2

/obj/effect/proc_holder/spell/vampire/bats/choose_targets(mob/user = usr)
	var/list/turf/locs = new
	for(var/direction in GLOB.alldirs) //looking for bat spawns
		if(locs.len == num_bats) //we found 2 locations and thats all we need
			break
		var/turf/T = get_step(usr, direction) //getting a loc in that direction
		if(AStar(user, T, /turf/proc/Distance, 1, simulated_only = 0)) // if a path exists, so no dense objects in the way its valid salid
			locs += T

	// pad with player location
	for(var/i = locs.len + 1 to num_bats)
		locs += user.loc

	perform(locs, user = user)

/obj/effect/proc_holder/spell/vampire/bats/cast(list/targets, mob/user = usr)
	for(var/T in targets)
		new /mob/living/simple_animal/hostile/scarybat(T, user)

/obj/effect/proc_holder/spell/vampire/self/jaunt
	name = "Mist Form (50)"
	desc = "You take on the form of mist for a short period of time."
	gain_desc = "You have gained the Mist Form ability which allows you to take on the form of mist for a short period and pass over any obstacle in your path."
	ru_name = "Облик тумана (50)"
	ru_desc = "Вы на короткое время превращаетесь в облако тумана"
	ru_gain_desc = "Вы получили способность «Облик тумана», которая позволит вам превращаться в облако тумана и проходить сквозь любые препятствия."
	action_icon_state = "jaunt"
	charge_max = 600
	required_blood = 50
	centcom_cancast = 0
	var/jaunt_duration = 50 //in deciseconds

/obj/effect/proc_holder/spell/vampire/self/jaunt/cast(list/targets, mob/user = usr)
	spawn(0)
		var/mob/living/U = user
		var/originalloc = get_turf(user.loc)
		var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt(originalloc)
		var/atom/movable/overlay/animation = new /atom/movable/overlay(originalloc)
		animation.name = "water"
		animation.density = 0
		animation.anchored = 1
		animation.icon = 'icons/mob/mob.dmi'
		animation.icon_state = "liquify"
		animation.layer = 5
		animation.master = holder
		U.ExtinguishMob()
		flick("liquify", animation)
		user.forceMove(holder)
		user.client.eye = holder
		var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread()
		steam.set_up(10, 0, originalloc)
		steam.start()
		sleep(jaunt_duration)
		var/mobloc = get_turf(user.loc)
		animation.loc = mobloc
		steam.location = mobloc
		steam.start()
		user.canmove = 0
		sleep(20)
		flick("reappear",animation)
		sleep(5)
		if(!user.Move(mobloc))
			for(var/direction in list(1,2,4,8,5,6,9,10))
				var/turf/T = get_step(mobloc, direction)
				if(T)
					if(user.Move(T))
						break
		user.canmove = 1
		user.client.eye = user
		qdel(animation)
		qdel(holder)

// Blink for vamps
// Less smoke spam.
/obj/effect/proc_holder/spell/vampire/shadowstep
	name = "Shadowstep (20)"
	desc = "Vanish into the shadows."
	gain_desc = "You have gained the ability to shadowstep, which makes you disappear into nearby shadows at the cost of blood."
	ru_name = "Шаг в тень (20)"
	ru_desc = "Растворитесь в тенях"
	ru_gain_desc = "Вы получили способность «Шаг в тень», позволяющую вам, затратив часть крови, оказаться в ближайшей доступной тени."
	action_icon_state = "blink"
	charge_max = 20
	required_blood = 20
	centcom_cancast = 0

	// Teleport radii
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6
	// Maximum lighting_lumcount.
	var/max_lum = 1

/obj/effect/proc_holder/spell/vampire/shadowstep/choose_targets(mob/user = usr)
	var/list/turfs = new/list()
	for(var/turf/T in range(user, outer_tele_radius))
		if(T in range(user, inner_tele_radius))
			continue
		if(istype(T, /turf/space))
			continue
		if(T.density)
			continue
		if(T.x > world.maxx-outer_tele_radius || T.x < outer_tele_radius)
			continue	//putting them at the edge is dumb
		if(T.y > world.maxy-outer_tele_radius || T.y < outer_tele_radius)
			continue

		var/lightingcount = T.get_lumcount(0.5) * 10

		// LIGHTING CHECK
		if(lightingcount > max_lum)
			continue
		turfs += T

	if(!turfs.len)
		revert_cast(user)
		to_chat(user, pick_translation("<span class='warning'>You cannot find darkness to step to.</span>",
			"<span class='warning'>Поблизости нет теней, куда можно было бы шагнуть.</span>"))
		return

	turfs = list(pick(turfs)) // Pick a single turf for the vampire to jump to.
	perform(turfs, user = user)

// `targets` should only ever contain the 1 valid turf we're jumping to, even though its a list, that's just how the cast() proc works.
/obj/effect/proc_holder/spell/vampire/shadowstep/cast(list/targets, mob/user = usr)
	spawn(0)
		if(!LAZYLEN(targets)) // If for some reason the turf got deleted.
			return
		var/mob/living/U = user
		U.ExtinguishMob()
		var/atom/movable/overlay/animation = new /atom/movable/overlay(get_turf(user))
		animation.name = user.name
		animation.density = 0
		animation.anchored = 1
		animation.icon = user.icon
		animation.alpha = 127
		animation.layer = 5
		//animation.master = src
		user.forceMove(targets[1])
		spawn(10)
			qdel(animation)

/datum/vampire_passive/regen
	gain_desc = "Your rejuvination abilities have improved and will now heal you over time when used."
	ru_gain_desc = "Ваша способность «Восстановление» улучшена. Теперь она будет постепенно исцелять вас после использования."

/datum/vampire_passive/vision
	gain_desc = "Your vampiric vision has improved."
	ru_gain_desc = "Ваше вампирское зрение улучшено."

/datum/vampire_passive/full
	gain_desc = "You have reached your full potential and are no longer weak to the effects of anything holy and your vision has been improved greatly."
	ru_gain_desc = "Вы достигли полной силы и ничто святое больше не может ослабить вас. Ваше зрение значительно улучшилось."

/obj/effect/proc_holder/spell/targeted/raise_vampires
	name = "Raise Vampires"
	desc = "Summons deadly vampires from bluespace."
	ru_name = "Поднятие вампиров"
	ru_desc = "Призовите смертоносных вампиров из блюспейса"
	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	human_req = 1
	invocation = "none"
	invocation_type = "none"
	max_targets = 0
	range = 3
	cooldown_min = 20
	action_icon_state = "revive_thrall"
	sound = 'sound/magic/wandodeath.ogg'

/obj/effect/proc_holder/spell/targeted/raise_vampires/cast(list/targets, mob/user = usr)
	new /obj/effect/temp_visual/cult/sparks(user.loc)
	var/turf/T = get_turf(user)
	to_chat(user, pick_translation("<span class='warning'>You call out within bluespace, summoning more vampiric spirits to aid you!</span>",
		"<span class='warning'>Ваш зов расходится в блюспейсе, на помощь созывая других вампирских духов!</span>"))
	for(var/mob/living/carbon/human/H in targets)
		T.Beam(H, "sendbeam", 'icons/effects/effects.dmi', time=30, maxdistance=7, beam_type=/obj/effect/ebeam)
		new /obj/effect/temp_visual/cult/sparks(H.loc)
		H.raise_vampire(user)


/mob/living/carbon/human/proc/raise_vampire(var/mob/M)
	if(!istype(M))
		log_debug("human/proc/raise_vampire called with invalid argument.")
		return
	if(!mind)
		visible_message("[src] looks to be too stupid to understand what is going on.",
			ru_message = "Кажется, [src] недостаёт ума, чтобы понять, о чём вы говорите.")
		return
	if(dna && (NO_BLOOD in dna.species.species_traits) || dna.species.exotic_blood || !blood_volume)
		visible_message("[src] looks unfazed!",
			ru_message = "[src] выглядит невозмутимо!")
		return
	if(mind.vampire || mind.special_role == SPECIAL_ROLE_VAMPIRE || mind.special_role == SPECIAL_ROLE_VAMPIRE_THRALL)
		visible_message("<span class='notice'>[src] looks refreshed!</span>",
			ru_message = "<span class='notice'>[src] выглядит обновлённо!</span>")
		adjustBruteLoss(-60)
		adjustFireLoss(-60)
		for(var/obj/item/organ/external/E in bodyparts)
			if(prob(25))
				E.mend_fracture()

		return
	if(stat != DEAD)
		if(IsWeakened())
			visible_message("<span class='warning'>[src] looks to be in pain!</span>",
				ru_message = "<span class='warning'>Кажется, [src] ощущает боль!</span>")
			adjustBrainLoss(60)
		else
			visible_message("<span class='warning'>[src] looks to be stunned by the energy!</span>",
				ru_message = "<span class='warning'>Кажется, энергия оглушает [src]!</span>")
			Weaken(20)
		return
	for(var/obj/item/implant/mindshield/L in src)
		if(L && L.implanted)
			qdel(L)
	for(var/obj/item/implant/traitor/T in src)
		if(T && T.implanted)
			qdel(T)
	visible_message("<span class='warning'>[src] gets an eerie red glow in their eyes!</span>",
		ru_message = "<span class='warning'>Глаза [src] начинают светиться жутким красным светом!</span>")
	var/datum/objective/protect/protect_objective = new
	protect_objective.owner = mind
	protect_objective.target = M.mind
	protect_objective.explanation_text = pick_translation("Protect [M.real_name].",
		"Защитите [M.real_name].")
	mind.objectives += protect_objective
	add_attack_logs(M, src, "Vampire-sired")
	mind.make_Vampire()
	revive()
	Weaken(20)
