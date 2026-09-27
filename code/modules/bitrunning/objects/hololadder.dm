/obj/structure/hololadder
	name = "hololadder"
	desc = "Абстрактное воплощение способа покинуть виртуальный домен."
	icon_state = "ladder11"
	anchored = TRUE
	var/travel_time = 3 SECONDS
	var/datum/weakref/server_ref

/obj/structure/hololadder/Initialize(mapload, obj/machinery/quantum_server/origin)
	. = ..()
	server_ref = WEAKREF(origin)
	RegisterSignal(loc, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	register_context()

/obj/structure/hololadder/Destroy()
	if(loc)
		UnregisterSignal(loc, COMSIG_ATOM_ENTERED)
	server_ref = null
	return ..()

/obj/structure/hololadder/get_ru_names()
	return alist(
		NOMINATIVE = "гололестница",
		GENITIVE = "гололестницы",
		DATIVE = "гололестнице",
		ACCUSATIVE = "гололестницу",
		INSTRUMENTAL = "гололестницей",
		PREPOSITIONAL = "гололестнице",
	)

/obj/structure/hololadder/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_LMB] = "Отключиться"
	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/hololadder/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += span_notice("Нажмите, чтобы переместиться к серверу, с которым связана лестница.")
		return

	. += span_notice("Нажмите на лестницу или встаньте на неё, чтобы отключиться от аватара.")

/obj/structure/hololadder/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return

	disconnect(user)

/obj/structure/hololadder/attack_ghost(mob/dead/observer/user)
	var/obj/machinery/quantum_server/server = server_ref?.resolve()
	if(isnull(server))
		return ..()

	user.forceMove(get_turf(server))

/obj/structure/hololadder/proc/disconnect(mob/living/user)
	if(!HAS_TRAIT(user, TRAIT_TEMPORARY_BODY))
		balloon_alert(user, "соединение не обнаружено")
		return

	var/obj/machinery/quantum_server/server = server_ref?.resolve()
	if(server && !server.domain_complete && server.has_awake_glitch())
		to_chat(user, span_danger("Что-то в симуляции держит вас и не даёт уйти. Сначала доставьте груз или разберитесь с помехой."))
		return

	balloon_alert(user, "отключение...")
	if(!do_after(user, travel_time, src))
		return

	SEND_SIGNAL(user, COMSIG_BITRUNNER_LADDER_SEVER)

/obj/structure/hololadder/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!isliving(arrived))
		return

	INVOKE_ASYNC(src, PROC_REF(disconnect), arrived)
