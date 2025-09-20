/obj/item/restraints/legcuffs
	name = "leg cuffs"
	desc = "Используйте это, чтобы держать заключённых в узде."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	item_state = "legcuff"
	flags = CONDUCT
	throwforce = 0
	slot_flags = ITEM_SLOT_LEGCUFFED
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "engineering=3;combat=3"
	slowdown = 7
	breakout_time = 30 SECONDS


/obj/item/restraints/legcuffs/get_ru_names()
	return list(
		NOMINATIVE = "кандалы",
		GENITIVE = "кандалов",
		DATIVE = "кандалам",
		ACCUSATIVE = "кандалы",
		INSTRUMENTAL = "кандалами",
		PREPOSITIONAL = "кандалах"
	)


/obj/item/restraints/legcuffs/beartrap
	name = "bear trap"
	gender = MALE
	throw_speed = 1
	throw_range = 1
	icon_state = "beartrap"
	desc = "Капкан для поимки медведей и тех, кому тоже не повезёт иметь ноги."
	origin_tech = "engineering=4"
	var/armed = FALSE
	var/trap_damage = 20
	var/obj/item/grenade/iedcasing/IED = null
	var/obj/item/assembly/signaler/sig = null


/obj/item/restraints/legcuffs/beartrap/get_ru_names()
	return list(
		NOMINATIVE = "капкан",
		GENITIVE = "капкана",
		DATIVE = "капкану",
		ACCUSATIVE = "капкан",
		INSTRUMENTAL = "капканом",
		PREPOSITIONAL = "капкане"
	)


/obj/item/restraints/legcuffs/beartrap/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/item/restraints/legcuffs/beartrap/Destroy()
	QDEL_NULL(IED)
	QDEL_NULL(sig)
	return ..()


/obj/item/restraints/legcuffs/beartrap/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] засовыва[pluralize_ru(user.gender, "ет", "ют")] свою голову в [declent_ru(NOMINATIVE)]! Похоже, что [genderize_ru(user.gender, "он", "она", "оно", "они")] пыта[pluralize_ru(user.gender, "ет", "ют")]ся совершить самоубийство!"))
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, TRUE, -1)
	return BRUTELOSS


/obj/item/restraints/legcuffs/beartrap/update_icon_state()
	icon_state = "[initial(icon_state)][armed]"



/obj/item/restraints/legcuffs/beartrap/attack_self(mob/user)
	..()
	if(ishuman(user) && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		armed = !armed
		update_icon(UPDATE_ICON_STATE)
		balloon_alert(user, "[armed ? "взведён" : "обезврежен"]")


/obj/item/restraints/legcuffs/beartrap/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/grenade/iedcasing))	//Let's get explosive.
		add_fingerprint(user)
		if(IED)
			to_chat(user, span_warning("[capitalize(IED.declent_ru(NOMINATIVE))] уже прикреплен[genderize_ru(IED.gender, "", "а", "о", "ы")] к [declent_ru(DATIVE)]!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		IED = I
		message_admins("[key_name_admin(user)] has rigged a beartrap with an IED.")
		add_game_logs("has rigged a beartrap with an IED.", user)
		to_chat(user, span_notice("Вы просовываете [IED.declent_ru(ACCUSATIVE)] под нажимную пластину и подсоединяете запал."))
		update_desc()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(issignaler(I))
		var/obj/item/assembly/signaler/signaler = I
		add_fingerprint(user)
		if(sig)
			to_chat(user, span_warning("[capitalize(signaler.declent_ru(NOMINATIVE))] уже подключен[genderize_ru(signaler.gender, "", "а", "о", "ы")] к [declent_ru(DATIVE)]!"))
			return ATTACK_CHAIN_PROCEED
		if(signaler.secured)
			to_chat(user, span_notice("[capitalize(signaler.declent_ru(NOMINATIVE))] не долж[genderize_ru(signaler.gender, "ен", "на", "но", "ны")] быть закрепл[genderize_ru(signaler.gender, "ён", "ена", "ено", "ены")]."))
			balloon_alert(user, "невозможно")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		sig = signaler
		to_chat(user, span_notice("Вы просовываете [sig.declent_ru(ACCUSATIVE)] под нажимную пластину и подсоединяете запал."))
		update_desc()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/restraints/legcuffs/beartrap/screwdriver_act(mob/user, obj/item/I)
	. = TRUE

	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	if(IED)
		IED.forceMove(get_turf(src))
		balloon_alert(user, "[IED.declent_ru(NOMINATIVE)] снят[genderize_ru(IED.gender, "", "а", "о", "ы")]")
		IED = null
		update_desc()
		return

	if(sig)
		sig.forceMove(get_turf(src))
		balloon_alert(user, "[sig.declent_ru(NOMINATIVE)] снят[genderize_ru(sig.gender, "", "а", "о", "ы")]")
		sig = null
		update_desc()
		return


/obj/item/restraints/legcuffs/beartrap/update_desc(updates = ALL)
	. = ..()
	desc = initial(desc)
	if(IED)
		desc += "\n[span_warning("К [genderize_ru(gender, "нему", "ней", "нему", "ним")] подсоединен[genderize_ru(IED.gender, "", "а", "о", "ы")] [IED.declent_ru(NOMINATIVE)]!")]"

	if(sig)
		desc += "\n[span_warning("К [genderize_ru(gender, "нему", "ней", "нему", "ним")] подсоединен[genderize_ru(sig.gender, "", "а", "о", "ы")] [sig.declent_ru(NOMINATIVE)].")]"

/obj/item/restraints/legcuffs/beartrap/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(triggered), arrived)


/obj/item/restraints/legcuffs/beartrap/proc/triggered(mob/living/moving_thing)
	if(!armed || !isturf(loc))
		return

	if(!iscarbon(moving_thing) && !isanimal(moving_thing))
		return

	if(moving_thing.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		return

	armed = FALSE
	update_icon(UPDATE_ICON_STATE)
	playsound(src.loc, 'sound/effects/snap.ogg', 50, TRUE)
	moving_thing.visible_message(span_danger("[moving_thing] активиру[pluralize_ru(moving_thing.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)]."),
								span_userdanger("Вы активируете [declent_ru(ACCUSATIVE)]!"))

	if(IED)
		IED.active = TRUE
		message_admins("[key_name_admin(usr)] has triggered an IED-rigged [name].")
		add_game_logs("has triggered an IED-rigged [name].", usr)
		addtimer(CALLBACK(src, PROC_REF(delayed_prime)), IED.det_time)

	if(sig)
		sig.signal()

	if(ishuman(moving_thing))
		var/mob/living/carbon/human/moving_human = moving_thing
		if(moving_human.body_position == LYING_DOWN)
			moving_human.apply_damage(trap_damage, BRUTE, BODY_ZONE_CHEST)
		else
			moving_human.apply_damage(trap_damage, BRUTE, (pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)))

		if(moving_human.apply_restraints(src, ITEM_SLOT_LEGCUFFED)) //beartrap can't cuff you leg if there's already a beartrap or legcuffs.
			SSblackbox.record_feedback("tally", "handcuffs", 1, type)

		return

	moving_thing.apply_damage(trap_damage, BRUTE)


/obj/item/restraints/legcuffs/beartrap/proc/delayed_prime()
	if(!QDELETED(src) && !QDELETED(IED))
		IED.prime()


/obj/item/restraints/legcuffs/bola
	name = "bola"
	desc = "Метательное оружие, предназначенное для сковывания движений цели. При попадании обвивается вокруг ног цели, затрудняя передвижение."
	icon_state = "bola"
	item_state = "bola"
	breakout_time = 6 SECONDS	//easy to apply, easy to break out of
	gender = FEMALE
	origin_tech = "engineering=3;combat=1"
	hitsound = 'sound/effects/snap.ogg'
	throw_range = 0 // increased when throw mode is enabled
	/// Number of spins till the bola gets the maximum throw distance. Each spin takes 1 second.
	var/max_spins = 3
	/// Current spin cycle.
	var/spin_cycle = 0
	/// Timer used for spinning bola.
	var/spin_timer_id
	/// Are we currently spinning the bola?
	var/spinning = FALSE
	/// Max range after the bola fully spins up. If your value for this isn't divisable by the value of `max_spins` it will be lower than the max.
	var/max_range = 6
	/// Max speed after the bola fully spins up. If your value for this isn't divisable by the value of `max_spins` it will be lower than the max.
	var/max_speed = 2
	/// Is the bola reusable?
	var/reusable = TRUE
	/// Duration of the weakening in seconds
	var/weaken_amt = 0
	/// Duration of the knockdown in seconds
	var/knockdown_amt = 0
	/// Cyclic bola spin sound.
	var/spin_sound = 'sound/items/bola_spin.ogg'


/obj/item/restraints/legcuffs/bola/get_ru_names()
	return list(
		NOMINATIVE = "бола",
		GENITIVE = "болы",
		DATIVE = "боле",
		ACCUSATIVE = "болу",
		INSTRUMENTAL = "болой",
		PREPOSITIONAL = "боле"
	)


/obj/item/restraints/legcuffs/bola/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_CARBON_TOGGLE_THROW, PROC_REF(spin_up_wrapper))


/obj/item/restraints/legcuffs/bola/update_icon_state()
	item_state = spinning ? "[initial(item_state)]_spin" : initial(item_state)
	update_equipped_item(update_speedmods = FALSE)


/obj/item/restraints/legcuffs/bola/proc/spin_up_wrapper(datum/source, throw_mode_state) // so that signal handler works
	SIGNAL_HANDLER
	if(throw_mode_state) // if we actually turned throw mode on
		INVOKE_ASYNC(src, PROC_REF(spin_up))


/obj/item/restraints/legcuffs/bola/proc/get_spin_time(mob/owner)
	var/time = 1 SECONDS
	var/list/bola_modifiers = list()
	SEND_SIGNAL(owner, COMSIG_GET_BOLA_MODIFIERS, bola_modifiers)
	for(var/modifier in bola_modifiers)
		time *= modifier

	return time


/obj/item/restraints/legcuffs/bola/proc/spin_up()
	if(spinning)
		return
	var/mob/living/owner = loc // can only be called if the mob is holding the bola.
	spinning = TRUE
	update_icon(UPDATE_ICON_STATE)
	playsound(owner, spin_sound, 30, list(38000, 48000), SHORT_RANGE_SOUND_EXTRARANGE)
	spin_timer_id = addtimer(CALLBACK(src, PROC_REF(spin_loop), owner), get_spin_time(owner), TIMER_UNIQUE|TIMER_LOOP|TIMER_STOPPABLE|TIMER_DELETE_ME)
	do_spin_cycle(owner)


/obj/item/restraints/legcuffs/bola/proc/spin_loop(mob/living/user)
	if(QDELETED(src) || !spinning || !can_spin_check(user))
		reset_values(user)
		return

	playsound(user, spin_sound, 30, list(38000, 48000), SHORT_RANGE_SOUND_EXTRARANGE)

	if(spin_cycle < max_spins)
		do_spin_cycle(user)


/obj/item/restraints/legcuffs/bola/proc/do_spin_cycle(mob/living/user)
	if(do_after(user, get_spin_time(user), user, ALL, extra_checks = CALLBACK(src, PROC_REF(can_spin_check), user)))
		throw_range += round(max_range / max_spins)
		throw_speed += round(max_speed / max_spins)
		spin_cycle++
		return

	reset_values(user)


/**
 * If it returns `FALSE`, it breaks the loop, returning `TRUE`, continues the loop.
 */
/obj/item/restraints/legcuffs/bola/proc/can_spin_check(mob/living/user)
	if(QDELETED(user))
		return FALSE
	if(user.get_active_hand() != src)
		return FALSE
	if(!user.in_throw_mode)
		return FALSE
	return TRUE


/obj/item/restraints/legcuffs/bola/carbon_skip_catch_check(mob/living/carbon/user)
	return TRUE	// No one can catch a flying bola


/obj/item/restraints/legcuffs/bola/proc/reset_values(mob/living/user)
	throw_range = initial(throw_range)
	throw_speed = initial(throw_speed)
	spin_cycle = 0
	spinning = FALSE
	update_icon(UPDATE_ICON_STATE)
	if(spin_timer_id)
		deltimer(spin_timer_id)


/obj/item/restraints/legcuffs/bola/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback,force, dodgeable)
	playsound(loc, 'sound/weapons/bolathrow.ogg', 50, TRUE)
	..()


/obj/item/restraints/legcuffs/bola/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	reset_values()

	if(..() || !iscarbon(hit_atom))//if it gets caught or the target can't be cuffed,
		return TRUE	//abort

	var/mob/living/carbon/target = hit_atom
	if(target.legcuffed || !target.has_organ_for_slot(ITEM_SLOT_LEGCUFFED))
		return TRUE

	var/datum/antagonist/vampire/vamp = target.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vamp && HAS_TRAIT_FROM(target, TRAIT_DEFLECT_BOLAS, VAMPIRE_TRAIT))
		if(vamp.bloodusable)
			vamp.bloodusable = max(vamp.bloodusable - 10, 0)
			target.visible_message(span_danger("[target] отража[pluralize_ru(target.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)]!"),
									span_notice("Вы отражаете [declent_ru(ACCUSATIVE)], это стоит вам 10 крови."))
			return TRUE

		REMOVE_TRAIT(target, TRAIT_DEFLECT_BOLAS, VAMPIRE_TRAIT)

	if(HAS_TRAIT(target, TRAIT_DEFLECT_BOLAS))
		target.visible_message(span_danger("[target] отража[pluralize_ru(target.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)]!"))
		return TRUE

	target.visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] сковыва[pluralize_ru(target.gender, "ет", "ют")] ноги [target.declent_ru(GENITIVE)]!"))
	to_chat(target, span_userdanger("[capitalize(declent_ru(NOMINATIVE))] сковыва[pluralize_ru(target.gender, "ет", "ют")] ваши ноги!"))
	target.apply_restraints(src, ITEM_SLOT_LEGCUFFED)
	if(weaken_amt)
		target.Weaken(weaken_amt)
	if(knockdown_amt)
		target.Knockdown(knockdown_amt)
	playsound(loc, hitsound, 50, TRUE)
	SSblackbox.record_feedback("tally", "handcuffs", 1, type)
	if(!reusable)
		item_flags |= DROPDEL



/obj/item/restraints/legcuffs/bola/tactical //traitor variant
	name = "reinforced bola"
	desc = "Укреплённая бола, сделанная из длинной стальной цепи. Выглядит достаточно тяжёлой, чтобы сбить цель с ног."
	icon_state = "bola_r"
	item_state = "bola_r"
	origin_tech = "engineering=4;combat=3"
	breakout_time = 10 SECONDS
	weaken_amt = 2 SECONDS


/obj/item/restraints/legcuffs/bola/tactical/get_ru_names()
	return list(
		NOMINATIVE = "укреплённая бола",
		GENITIVE = "укреплённой болы",
		DATIVE = "укрёпленной боле",
		ACCUSATIVE = "укреплённую болу",
		INSTRUMENTAL = "укреплённой болой",
		PREPOSITIONAL = "укреплённой боле"
	)


/obj/item/restraints/legcuffs/bola/energy //For Security
	name = "energy bola"
	desc = "Бола из твёрдой энергии, разработанная специально для службы безопасности. Предназначена для поимки особо прытких преступников."
	icon_state = "ebola"
	item_state = "ebola"
	hitsound = 'sound/weapons/tase.ogg'
	w_class = WEIGHT_CLASS_SMALL
	breakout_time = 4 SECONDS
	reusable = FALSE


/obj/item/restraints/legcuffs/bola/energy/get_ru_names()
	return list(
		NOMINATIVE = "энергетическая бола",
		GENITIVE = "энергетической болы",
		DATIVE = "энергетической боле",
		ACCUSATIVE = "энергетическую болу",
		INSTRUMENTAL = "энергетической болой",
		PREPOSITIONAL = "энергетической боле"
	)


/obj/item/restraints/legcuffs/bola/sinew
	name = "skull bola"
	desc = "Это примитивное метательное оружие, созданное из останков врагов, может показаться ненадёжным, но оно демонстрирует поразительную эффективность."
	icon_state = "bola_watcher"
	item_state = "bola_watcher"
	reusable = FALSE

/obj/item/restraints/legcuffs/bola/sinew/get_ru_names()
	return list(
		NOMINATIVE = "бола из черепов",
		GENITIVE = "болы из черепов",
		DATIVE = "боле из черепов",
		ACCUSATIVE = "болу из черепов",
		INSTRUMENTAL = "болой из черепов",
		PREPOSITIONAL = "боле из черепов"
	)

/obj/item/restraints/legcuffs/bola/sinew/dropped(mob/living/carbon/user, slot, silent = FALSE)
	. = ..()

	if(!istype(user) || slot != ITEM_SLOT_LEGCUFFED)
		return .

	user.apply_damage(10, BRUTE, (pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)))
	new /obj/item/restraints/handcuffs/sinew(user.loc)
	new /obj/item/stack/sheet/bone(user.loc, 2)

