/obj/effect/lock_portal
	name = "трещина в реальности"
	desc = "Трещина в реальности, невероятно глубокая. На неё больно смотреть. Определённо небезопасна."
	gender = FEMALE
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "realitycrack"
	light_color = COLOR_GREEN
	light_range = 3
	opacity = TRUE
	///The knock portal we teleport to
	var/obj/effect/lock_portal/destination
	///The airlock we are linked to, we delete if it is destroyed
	var/obj/machinery/door/our_airlock
	/// if true the heretic is teleported to a random airlock, nonheretics are sent to the target
	var/inverted = FALSE


/obj/effect/lock_portal/get_ru_names()
	return list(
		NOMINATIVE = "трещина в реальности",
		GENITIVE = "трещины в реальности",
		DATIVE = "трещине в реальности",
		ACCUSATIVE = "трещину в реальности",
		INSTRUMENTAL = "трещиной в реальности",
		PREPOSITIONAL = "трещине в реальности",
	)


/obj/effect/lock_portal/Initialize(mapload, target, invert = FALSE)
	. = ..()
	if(target)
		our_airlock = target
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(delete_on_door_delete))

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	inverted = invert


///Deletes us and our destination portal if our_airlock is destroyed
/obj/effect/lock_portal/proc/delete_on_door_delete(datum/source)
	SIGNAL_HANDLER
	qdel(src)


///Signal handler for when our location is entered, calls teleport on the victim, if their old_loc didnt contain a portal already (to prevent loops)
/obj/effect/lock_portal/proc/on_entered(datum/source, mob/living/loser, atom/old_loc)
	SIGNAL_HANDLER
	if(!istype(loser) || (locate(type) in old_loc))
		return

	teleport(loser)


/obj/effect/lock_portal/Destroy()
	if(!isnull(destination) && !QDELING(destination))
		QDEL_NULL(destination)

	destination = null
	our_airlock = null
	return ..()


///Teleports the teleportee, to a random airlock if the teleportee isnt a heretic, or the other portal if they are one
/obj/effect/lock_portal/proc/teleport(mob/living/teleportee)
	if(isnull(destination)) //dumbass
		qdel(src)
		return

	if(!is_phase_allowed(z) || !is_phase_allowed(destination.z))
		qdel(src)
		return

	//get it?
	var/obj/machinery/door/doorstination = (inverted ? !IS_HERETIC_OR_MONSTER(teleportee) : IS_HERETIC_OR_MONSTER(teleportee)) ? destination.our_airlock : find_random_airlock()
	if(!do_teleport(teleportee, get_turf(doorstination)))
		return

	teleportee.client?.move_delay = 0 //make moving through smoother

	if(!IS_HERETIC_OR_MONSTER(teleportee))
		teleportee.apply_damage(20, BRUTE) //so they dont roll it like a jackpot machine to see if they can land in the armory
		to_chat(teleportee, span_userdanger("Вы падаете сквозь [declent_ru(ACCUSATIVE)], сталкиваясь с силами, находящимися за пределами вашего понимания, и приземляетесь где угодно, но только не там, куда, как вы думали, вы попадёте."))

	INVOKE_ASYNC(src, PROC_REF(async_opendoor), doorstination)


///Returns a random airlock on the same Z level as our portal, that isnt our airlock
/obj/effect/lock_portal/proc/find_random_airlock()
	var/list/turf/possible_destinations = list()
	for(var/obj/machinery/door/airlock/airlock as anything in GLOB.airlocks)
		if(airlock.z != z)
			continue

		if(airlock.loc == loc)
			continue

		possible_destinations += airlock

	return pick(possible_destinations)


///Asynchronous proc to unbolt, then open the passed door
/obj/effect/lock_portal/proc/async_opendoor(obj/machinery/door/door)
	if(!istype(door, /obj/machinery/door/airlock)) //they can create portals on ANY door, but we should unlock airlocks so they can actually open
		door.open()
		return

	var/obj/machinery/door/airlock/as_airlock = door
	as_airlock.unlock()
	door.open()


///An ID card capable of shapeshifting to other IDs given by the Key Keepers Burden knowledge
/obj/item/card/id/advanced/heretic
	///List of IDs this card consumed
	var/list/obj/item/card/id/fused_ids = list()
	///The first portal in the portal pair, so we can clear it later
	var/obj/effect/lock_portal/portal_one
	///The second portal in the portal pair, so we can clear it later
	var/obj/effect/lock_portal/portal_two
	///The first door we are linking in the pair, so we can create a portal pair
	var/datum/weakref/link
	/// are our created portals inverted? (heretics get sent to a random airlock, crew get sent to the target)
	var/inverted = FALSE


/obj/item/card/id/advanced/heretic/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		return

	. += span_purple("Благославлена Мансусом")
	. += span_purple("Использование на другой карте, поглотит её переняв все доступы.")
	. += span_purple("<b>Использование в руке</b> позволяет вам изменить внешний вид этой карты.")
	. += span_purple("<b>Использование на паре дверей</b>, позволит соединить их. Входя в одну дверь, вы перенесётесь к другой, в то время как язычники телепортируются к случайному шлюзу.")
	. += span_purple("<b>Альтклик по карте</b> заставляет идентификатор создавать инвертированные порталы, которые будут телепортировать вас в случайный шлюз на станции, в то время как язычники телепортируются в пункт назначения.")


/obj/item/card/id/advanced/heretic/attack_self(mob/user)
	. = ..()
	if(!isheretic(user))
		return

	if(!fused_ids)
		user.balloon_alert(user, "нет поглощенных карт")
		return

	var/cardname = tgui_input_list(user, "Превратиться в?", "Превращение", fused_ids)
	if(!cardname)
		balloon_alert(user, "нет вариантов!")
		return ..()

	var/obj/item/card/id/card = fused_ids[cardname]
	shapeshift(card)


/obj/item/card/id/advanced/heretic/click_alt(mob/user)
	if(!isheretic(user))
		return CLICK_ACTION_BLOCKING

	inverted = !inverted
	balloon_alert(user, "[inverted ? "теперь" : "больше не"] инвертирована")
	return CLICK_ACTION_SUCCESS


///Changes our appearance to the passed ID card
/obj/item/card/id/advanced/heretic/proc/shapeshift(obj/item/card/id/advanced/card)
	if(ishuman(loc))
		var/mob/living/carbon/human/wearing = loc
		wearing.sec_hud_set_ID()

	icon = card.icon
	icon_state = card.icon_state
	assignment = card.assignment
	rank = card.rank
	sex = card.sex
	age = card.age
	photo = card.photo
	dat = card.dat
	name = card.name //not update_label because of the captains spare moment
	update_icon()


///Deletes and nulls our portal pair
/obj/item/card/id/advanced/heretic/proc/clear_portals()
	QDEL_NULL(portal_one)
	QDEL_NULL(portal_two)


///Clears portal references
/obj/item/card/id/advanced/heretic/proc/clear_portal_refs()
	SIGNAL_HANDLER
	portal_one = null
	portal_two = null


///Creates a portal pair at door1 and door2, displays a balloon alert to user
/obj/item/card/id/advanced/heretic/proc/make_portal(mob/user, obj/machinery/door/door1, obj/machinery/door/door2)
	var/message = "привазка"
	if(portal_one || portal_two)
		clear_portals()
		message += ", старые стёрты"

	portal_one = new(get_turf(door2), door2, inverted)
	portal_two = new(get_turf(door1), door1, inverted)
	portal_one.destination = portal_two
	RegisterSignal(portal_one, COMSIG_QDELETING, PROC_REF(clear_portal_refs))  //we only really need to register one because they already qdel both portals if one is destroyed
	portal_two.destination = portal_one
	balloon_alert(user, "[message]")


/obj/item/card/id/advanced/heretic/melee_attack_chain(mob/user, atom/target, params)
	if(!isheretic(user))
		return ..()

	if(istype(target, /obj/item/card/id))
		eat_card(target, user)
		return ATTACK_CHAIN_SUCCESS

	if(istype(target, /obj/effect/lock_portal))
		clear_portals()
		return ATTACK_CHAIN_SUCCESS

	if(!istype(target, /obj/machinery/door))
		return ..()

	if(!is_phase_allowed(target.z))
		return ..()

	var/reference_resolved = link?.resolve()
	if(reference_resolved == target)
		return ATTACK_CHAIN_BLOCKED

	if(!reference_resolved)
		link = WEAKREF(target)
		balloon_alert(user, "привязка 1/2")
		return ATTACK_CHAIN_SUCCESS

	make_portal(user, reference_resolved, target)
	to_chat(user, span_notice("Вы использовали [declent_ru(ACCUSATIVE)], чтобы связать шлюзы вместе."))
	link = null
	balloon_alert(user, "привязка 2/2")
	return ATTACK_CHAIN_SUCCESS


/obj/item/card/id/advanced/heretic/proc/eat_card(obj/item/card/id/card, mob/user)
	if(card == src)
		return //no self vore

	fused_ids[card.name] = card
	card.moveToNullspace()
	access |= card.access
	if(isnull(user))
		return

	playsound(drop_location(), 'sound/items/eatfood.ogg', rand(10,30), TRUE)
	balloon_alert(user, "карта поглощена")


/obj/item/card/id/advanced/heretic/Destroy()
	QDEL_LIST_ASSOC_VAL(fused_ids)
	link = null
	clear_portals()
	return ..()
