/* Misc toys
 *	Contains:
 *		Snap pops
 *		Codex gigas
 *		Mini gibber
 *		Toy big red button
 *		Fake cuffs
 *		Office desk toys
 */

/*
 * Snap pops
 */
/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = WEIGHT_CLASS_TINY
	var/ash_type = /obj/effect/decal/cleanable/ash

/obj/item/toy/snappop/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/toy/snappop/proc/pop_burst(number = 3, cardinal_only = TRUE)
	do_sparks(number, cardinal_only, src)
	new ash_type(loc)
	visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] взрывается!"), span_warning("Вы слышите хлопок!"))
	playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
	qdel(src)

/obj/item/toy/snappop/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	pop_burst()

/obj/item/toy/snappop/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	pop_burst()

/obj/item/toy/snappop/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	var/is_silicon = issilicon(arrived)
	if(!ishuman(arrived) && !is_silicon) //i guess carp and shit shouldn't set them off
		return

	var/mob/living/arrived_mob = arrived
	if(is_silicon || arrived_mob.m_intent == MOVE_INTENT_RUN)
		to_chat(arrived_mob, span_danger("Вы наступаете на хлопушку!"))
		pop_burst(2, FALSE)

/obj/item/toy/snappop/phoenix
	name = "phoenix snap pop"
	desc = "Wow! And wow! And wow!"
	ash_type = /obj/effect/decal/cleanable/ash/snappop_phoenix

/obj/effect/decal/cleanable/ash/snappop_phoenix
	var/respawn_time = 300

/obj/effect/decal/cleanable/ash/snappop_phoenix/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(respawn)), respawn_time)

/obj/effect/decal/cleanable/ash/snappop_phoenix/proc/respawn()
	new /obj/item/toy/snappop/phoenix(get_turf(src))
	qdel(src)

/*
 * Codex gigas
 */
/obj/item/toy/codex_gigas
	name = "Toy Codex Gigas"
	desc = "A tool to help you write fictional devils!"
	icon = 'icons/obj/library.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/library_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/library_righthand.dmi'
	icon_state = "demonomicon"
	item_state = "demonomicon"
	w_class = WEIGHT_CLASS_SMALL
	COOLDOWN_DECLARE(cooldown)

/obj/item/toy/codex_gigas/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, cooldown))
		return

	user.visible_message(
		span_notice("[user] нажима[PLUR_ET_YUT(user)] кнопку на [declent_ru(PREPOSITIONAL)]."),
		span_notice("Вы нажимаете кнопку на [declent_ru(PREPOSITIONAL)]."),
		span_sinister("Слышишь тихий щелчок."))

	var/list/messages = list()
	var/datum/devilinfo/devil = new

	LAZYADD(messages, "Интересные факты о: [devil.truename]")
	LAZYADD(messages, devil.bane.law)
	LAZYADD(messages, devil.ban.law)
	LAZYADD(messages, devil.obligation.law)
	LAZYADD(messages, devil.banish.law)

	playsound(loc, 'sound/machines/click.ogg', 20, TRUE)
	COOLDOWN_START(src, cooldown, 2 SECONDS)

	for(var/message in messages)
		user.loc.visible_message(span_danger("[get_examine_icon(viewers(user.loc))] [message]"))
		sleep(1 SECONDS)

	return

/*
 * Mini gibber
 */
/obj/item/toy/minigibber
	name = "miniature gibber"
	desc = "A miniature recreation of Nanotrasen's famous meat grinder."
	icon_state = "minigibber"
	attack_verb = list("перемолол", "гибнул")
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0
	var/obj/stored_minature = null

/obj/item/toy/minigibber/attack_self(mob/user)

	if(stored_minature)
		user.visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] издаёт жуткий скрежет, уничтожая миниатюрную фигурку внутри!"))
		QDEL_NULL(stored_minature)
		playsound(user, 'sound/goonstation/effects/gib.ogg', 20, TRUE)
		cooldown = world.time

	if(cooldown < world.time - 8)
		to_chat(user, span_notice("Вы нажимаете кнопку гиба на [declent_ru(PREPOSITIONAL)]."))
		playsound(user, 'sound/goonstation/effects/gib.ogg', 20, TRUE)
		cooldown = world.time

/obj/item/toy/minigibber/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/character))
		add_fingerprint(user)
		if(stored_minature)
			to_chat(user, span_warning("Внутри уже есть [stored_minature.declent_ru(NOMINATIVE)]!"))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(span_notice("[user] вставляет [icon2html(I, viewers(I))] [I.declent_ru(ACCUSATIVE)] в мини-приёмник [declent_ru(GENITIVE)]..."))
		if(!do_after(user, 1 SECONDS, src, category = DA_CAT_TOOL) || stored_minature)
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("Вы вставили [icon2html(I, user)] [I.declent_ru(ACCUSATIVE)] в [declent_ru(GENITIVE)]!"))
		stored_minature = I
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/*
 * Toy big red button
 */
/obj/item/toy/redbutton
	name = "big red button"
	desc = "A big, plastic red button. Reads 'From HonkCo Pranks?' on the back."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/redbutton/attack_self(mob/user)
	if(cooldown < world.time)
		cooldown = (world.time + 300) // Sets cooldown at 30 seconds
		user.visible_message(span_warning("[user] нажима[PLUR_ET_YUT(user)] большую красную кнопку."), span_notice("Вы нажимаете кнопку, раздаётся громкий звук!"), span_notice("Кнопка громко щёлкает."))
		playsound(src, 'sound/effects/explosionfar.ogg', 50, FALSE, 0)
		for(var/mob/M in range(10, src)) // Checks range
			if(!M.stat && !isAI(M)) // Checks to make sure whoever's getting shaken is alive/not the AI
				sleep(8) // Short delay to match up with the explosion sound
				shake_camera(M, 2, 1) // Shakes player camera 2 squares for 1 second.

	else
		to_chat(user, span_alert("Ничего не происходит."))

/*
 * Fake cuffs (honk honk)
 */
/obj/item/restraints/handcuffs/toy
	desc = "Toy handcuffs. Plastic and extremely cheaply made."
	throwforce = 0
	breakout_time = 0
	ignoresClumsy = TRUE

/*
 * Magic 8-Ball
 */
/obj/item/toy/eight_ball
	name = "Magic 8-Ball"
	desc = "Mystical! Magical! Ages 8+!"
	icon_state = "eight-ball"
	var/use_action = "трясёт шар"
	var/cooldown = 0
	var/list/possible_answers = list("Определённо", "Все признаки указывают на \"да\".", "Скорее всего.", "Да.", "Спроси позже.", "Лучше не сейчас.", "Будущее неясно.", "Возможно.", "Сомнительно.", "Нет.", "Не рассчитывай на это.", "Никогда.")

/obj/item/toy/eight_ball/attack_self(mob/user as mob)
	if(!cooldown)
		var/answer = pick(possible_answers)
		user.visible_message(span_notice("[user] сосредотачива[PLUR_ET_YUT(user)]ся на своём вопросе и [use_action]..."))
		user.visible_message(span_notice("[get_examine_icon(viewers(user))] [DECLENT_RU_CAP(src, NOMINATIVE)] говорит: \"[answer]\""))
		spawn(30)
			cooldown = 0
		return

/obj/item/toy/eight_ball/conch
	name = "Magic Conch Shell"
	desc = "All hail the Magic Conch!"
	icon_state = "conch"
	use_action = "тянет за верёвочку"
	possible_answers = list("Да.", "Нет.", "Спроси ещё раз.", "Ничего.", "Я так не думаю.", "Ни то, ни другое.", "Может быть, когда-нибудь.")

/*
* Office desk toys
*/
/obj/item/toy/desk
	name = "desk toy master"
	desc = "A object that does not exist. Parent Item"
	layer = ABOVE_MOB_LAYER
	var/on = 0
	var/activation_sound = 'sound/items/buttonclick.ogg'

/obj/item/toy/desk/update_icon_state()
	if(on)
		icon_state = "[initial(icon_state)]-on"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/toy/desk/attack_self(mob/user)
	on = !on
	if(activation_sound)
		playsound(src.loc, activation_sound, 75, TRUE)
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/item/toy/desk/verb/rotate()
	set name = "Повернуть"
	set category = VERB_CATEGORY_OBJECT
	set src in oview(1)

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		to_chat(usr, span_warning("Сейчас ты не можешь этого сделать!"))
		return
	dir = turn(dir, 270)
	return TRUE

/obj/item/toy/desk/click_alt(mob/user)
	rotate()
	return CLICK_ACTION_SUCCESS

/obj/item/toy/desk/officetoy
	name = "office toy"
	desc = "A generic microfusion powered office desk toy. Only generates magnetism and ennui."
	icon_state= "desktoy"
/obj/item/toy/desk/dippingbird
	name = "dipping bird toy"
	desc = "A ancient human bird idol, worshipped by clerks and desk jockeys."
	icon_state= "dippybird"
/obj/item/toy/desk/newtoncradle
	name = "Newton's cradle"
	desc = "A ancient 21th century super-weapon model demonstrating that Sir Isaac Newton is the deadliest sonuvabitch in space."
	icon_state = "newtoncradle"
	var/datum/looping_sound/newtonballs/soundloop

/obj/item/toy/desk/newtoncradle/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)

/obj/item/toy/desk/newtoncradle/attack_self(mob/user)
	on = !on
	update_icon(UPDATE_ICON_STATE)
	if(on)
		soundloop.start()
	else
		soundloop.stop()

/obj/item/toy/desk/fan
	name = "office fan"
	desc = "Your greatest fan"
	icon_state = "fan"
	var/datum/looping_sound/fanblow/soundloop

/obj/item/toy/desk/fan/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)

/obj/item/toy/desk/fan/attack_self(mob/user)
	on = !on
	update_icon(UPDATE_ICON_STATE)
	if(on)
		soundloop.start()
	else
		soundloop.stop()
