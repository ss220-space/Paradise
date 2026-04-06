//I still dont think this should be a closet but whatever
/obj/structure/closet/fireaxecabinet
	name = "fire axe cabinet"
	desc = "There is small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	desc = "Там есть небольшая этикетка с надписью: \"Использовать только при чрезвычайной ситуации.\" а также подробная информация о безопасном использовании топора. Как будто."
	icon_state = "fireaxe_full_0hits"
	icon_closed = "fireaxe_full_0hits"
	icon_opened = "fireaxe_full_open"
	anchored = TRUE
	density = FALSE
	no_overlays = TRUE
	armor = list(MELEE = 50, BULLET = 20, LASER = 0, ENERGY = 100, BOMB = 10, FIRE = 90, ACID = 50)
	var/obj/item/twohanded/fireaxe/fireaxe
	var/localopened = FALSE //Setting this to keep it from behaviouring like a normal closet and obstructing movement in the map. -Agouri
	opened = TRUE
	var/hitstaken = FALSE
	locked = TRUE
	var/smashed = FALSE
	var/operating = FALSE
	var/has_axe = null // Use a string over a boolean value to make the sprite names more readable

/obj/structure/closet/fireaxecabinet/get_ru_names()
    return list(
        NOMINATIVE = "шкаф для пожарного топора",
        GENITIVE = "шкафа для пожарного топора",
        DATIVE = "шкафу для пожарного топора",
        ACCUSATIVE = "шкаф для пожарного топора",
        INSTRUMENTAL = "шкафом для пожарного топора",
        PREPOSITIONAL = "шкафе для пожарного топора",
    )

/obj/structure/closet/fireaxecabinet/Destroy()
	if(!obj_integrity)
		if(fireaxe)
			fireaxe.forceMove(loc)
			fireaxe = null
		else
			QDEL_NULL(fireaxe)
	return ..()

/obj/structure/closet/fireaxecabinet/populate_contents()
	fireaxe = new(src)
	has_axe = "full"
	update_icon(UPDATE_ICON_STATE)	// So its initial icon doesn't show it without the fireaxe

/obj/structure/closet/fireaxecabinet/examine(mob/user)
	. = ..()
	if(!smashed)
		. += span_notice("Use a multitool to lock/unlock it.")
		. += span_notice("Используйте мультиметр, чтобы открыть/закрыть это.")
	else
		. += span_notice("It is damaged beyond repair.")
		. += span_notice("Оно повреждено настолько, что восстановление невозможно.")

/obj/structure/closet/fireaxecabinet/multitool_act(mob/living/user, obj/item/I)
	if(smashed)
		return FALSE

	. = TRUE
	if(locked)
		to_chat(user, span_warning("Resetting circuitry..."))
		to_chat(user, span_warning("Сброс схемы..."))
		if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume) || smashed || !locked)
			return .
		locked = FALSE
		to_chat(user, span_caution("You disable the locking modules."))
		to_chat(user, span_caution("Вы отключаете модуль блокировки."))
		update_icon(UPDATE_ICON_STATE)
		return .

	if(localopened)
		add_fingerprint(user)
		operate_panel()
		return .

	to_chat(user, span_warning("Resetting circuitry..."))
	to_chat(user, span_warning("Сброс схемы..."))
	playsound(user, 'sound/machines/lockenable.ogg', 50, TRUE)
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume) || smashed || locked)
		return .

	locked = TRUE
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_caution("You re-enable the locking modules."))
	to_chat(user, span_caution("Вы повторно активируете модуль блокировки."))

/obj/structure/closet/fireaxecabinet/attackby(obj/item/I, mob/living/user, params)
	. = ATTACK_CHAIN_BLOCKED_ALL
	add_fingerprint(user)

	if(isrobot(user) || locked)
		if(smashed || localopened)
			if(localopened)
				operate_panel()
			return .

		user.do_attack_animation(src)
		playsound(user, 'sound/effects/glasshit.ogg', 100, TRUE) //We don't want this playing every time
		if(I.force < 15)
			to_chat(user, span_notice("The cabinet's protective glass glances off the hit."))
			to_chat(user, span_notice("Ударная поверхность скользит по защитному стеклу шкафа."))
			return .

		hitstaken++
		if(hitstaken == 4)
			playsound(user, 'sound/effects/glassbr3.ogg', 100, TRUE) //Break cabinet, receive goodies. Cabinet's fucked for life after that.
			smashed = TRUE
			locked = FALSE
			localopened = TRUE
		update_icon(UPDATE_ICON_STATE)
		return .

	if(istype(I, /obj/item/twohanded/fireaxe) && localopened)
		if(!fireaxe)
			var/obj/item/twohanded/fireaxe/placed_axe = I
			if(HAS_TRAIT(placed_axe, TRAIT_WIELDED))
				to_chat(user, span_warning("Unwield [placed_axe] first."))
				to_chat(user, span_warning("Сначала возьмите [placed_axe] в одну руку."))
				return .
			if(!user.drop_transfer_item_to_loc(placed_axe, src))
				to_chat(user, span_warning("[placed_axe] stays stuck to your hands!"))
				return .
			fireaxe = placed_axe
			has_axe = "full"
			to_chat(user, span_notice("You place [placed_axe] back in the [name]."))
			to_chat(user, span_notice("Вы кладёте [placed_axe] обратно в [name]."))
			update_icon(UPDATE_ICON_STATE)
			return .

		if(smashed)
			return .

		operate_panel()
		return .

	if(smashed)
		return .

	operate_panel()

/obj/structure/closet/fireaxecabinet/attack_hand(mob/user)
	if(locked)
		to_chat(user, span_warning("The cabinet won't budge!"))
		to_chat(user, span_warning("Шкаф не сдвигается с места!"))
		return

	if(localopened && fireaxe)
		fireaxe.forceMove_turf()
		user.put_in_hands(fireaxe, ignore_anim = FALSE)
		to_chat(user, span_notice("You take [fireaxe] from [src]."))
		has_axe = "empty"
		fireaxe = null

		add_fingerprint(user)
		update_icon(UPDATE_ICON_STATE)
		return

	if(smashed)
		return

	operate_panel()

/obj/structure/closet/fireaxecabinet/blob_act(obj/structure/blob/B)
	if(fireaxe)
		fireaxe.forceMove(loc)
	qdel(src)

/obj/structure/closet/fireaxecabinet/attack_tk(mob/user)
	if(localopened && fireaxe)
		fireaxe.forceMove(loc)
		to_chat(user, span_notice("You telekinetically remove \the [fireaxe]."))
		to_chat(user, span_notice("Вы телекинетически удаляете [fireaxe]."))
		has_axe = "empty"
		fireaxe = null
		update_icon(UPDATE_ICON_STATE)
		return
	attack_hand(user)

/obj/structure/closet/fireaxecabinet/attack_ai(mob/user)
	if(smashed)
		to_chat(user, span_warning("The security of the cabinet is compromised."))
		to_chat(user, span_warning("Безопасность шкафа скомпрометирована.."))
		return

	locked = !locked
	if(locked)
		to_chat(user, span_warning("Cabinet locked."))
		to_chat(user, span_warning("Шкаф заблокирован."))
	else
		to_chat(user, span_notice("Cabinet unlocked."))
		to_chat(user, span_notice("Шкаф разблокирован."))

/obj/structure/closet/fireaxecabinet/shove_impact(mob/living/target, mob/living/attacker)
	// no, you can't shove people into a fireaxe cabinet either
	return FALSE

/obj/structure/closet/fireaxecabinet/proc/operate_panel()
	if(operating)
		return
	operating = TRUE
	localopened = !localopened
	do_animate()
	operating = FALSE

/obj/structure/closet/fireaxecabinet/proc/do_animate()
	if(!localopened)
		flick("fireaxe_[has_axe]_closing", src)
	else
		flick("fireaxe_[has_axe]_opening", src)
	sleep(1 SECONDS)
	update_icon(UPDATE_ICON_STATE)

/obj/structure/closet/fireaxecabinet/update_icon_state()
	if(localopened && !smashed)
		icon_state = "fireaxe_[has_axe]_open"
	else
		icon_state = "fireaxe_[has_axe]_[hitstaken]hits"

/obj/structure/closet/fireaxecabinet/open()
	return

/obj/structure/closet/fireaxecabinet/close()
	return

/obj/structure/closet/fireaxecabinet/welder_act(mob/user, obj/item/I) //A bastion of sanity in a sea of madness
	return

//mining "fireaxe"
/obj/structure/fishingrodcabinet
	name = "fishing cabinet"
	desc = "There is a small label that reads \"Fo* Em**gen*y u*e *nly\". All the other text is scratched out and replaced with various fish weights."
	desc = "Там есть небольшая этикетка с надписью: \"Ис*о*ьзо**ть *о*ько п*и ч*ез*ыча**ой си*уа**и.\". Весь остальной текст зачеркнут и заменен различными значениями веса рыбы."
	icon = 'icons/obj/closet.dmi'
	icon_state = "fishingrod"
	anchored = TRUE
	var/obj/item/twohanded/fishing_rod/olreliable //what the fuck?

/obj/structure/fishingrodcabinet/get_ru_names()
    return list(
        NOMINATIVE = "рыболовный шкаф",
        GENITIVE = "рыболовного шкафа",
        DATIVE = "рыболовному шкафу",
        ACCUSATIVE = "рыболовный шкаф",
        INSTRUMENTAL = "рыболовным шкафом",
        PREPOSITIONAL = "рыболовном шкафе",
    )

/obj/structure/fishingrodcabinet/Initialize(mapload)
	. = ..()
	olreliable = new(src)
	update_icon(UPDATE_OVERLAYS)

/obj/structure/fishingrodcabinet/update_overlays()
	. = ..()
	if(olreliable)
		. += "rod"

/obj/structure/fishingrodcabinet/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/twohanded/fishing_rod))
		var/obj/item/twohanded/fishing_rod/rod = I
		if(HAS_TRAIT(rod, TRAIT_WIELDED))
			to_chat(user, span_warning("Unwield [rod] first."))
			to_chat(user, span_warning("Сначала возьмите [rod] в одну руку."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(rod, src))
			return ..()
		olreliable = rod
		to_chat(user, span_notice("You place [rod] back in [src]."))
		to_chat(user, span_notice("Вы кладёте [rod] обратно в [src]."))
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/fishingrodcabinet/blob_act(obj/structure/blob/B)
	if(olreliable)
		olreliable.forceMove(loc)
	qdel(src)

/obj/structure/fishingrodcabinet/attack_hand(mob/user)
	if(!olreliable)
		return ..()

	add_fingerprint(user)
	olreliable.forceMove_turf()
	user.put_in_hands(olreliable, ignore_anim = FALSE)
	to_chat(user, span_notice("You take [olreliable] from [src]."))
	to_chat(user, span_notice("Вы берёте [olreliable] из [src]."))
	olreliable = null
	update_icon(UPDATE_OVERLAYS)

/obj/structure/closet/sechammercabinet
	name = "tactical sledgehammer cabinet"
	desc = "Стойка, предназначенная для хранения тактической кувалды. Надпись гласит: \"Для особых случаев\"."
	icon_state = "sechammer_full"
	anchored = TRUE
	density = FALSE
	no_overlays = TRUE
	armor = list(MELEE = 50, BULLET = 20, LASER = 0, ENERGY = 100, BOMB = 10, FIRE = 90, ACID = 50)
	var/obj/item/twohanded/sechammer/sledgehammer
	opened = TRUE

/obj/structure/closet/sechammercabinet/get_ru_names()
	return list(
		NOMINATIVE = "стойка для тактической кувалды",
		GENITIVE = "стойки для тактической кувалды",
		DATIVE = "стойке для тактической кувалды",
		ACCUSATIVE = "стойку для тактической кувалды",
		INSTRUMENTAL = "стойкой для тактической кувалды",
		PREPOSITIONAL = "стойке для тактической кувалды",
	)

/obj/structure/closet/sechammercabinet/Destroy()
	if(!obj_integrity)
		if(sledgehammer)
			sledgehammer.forceMove(loc)
			sledgehammer = null
		else
			QDEL_NULL(sledgehammer)
	return ..()

/obj/structure/closet/sechammercabinet/populate_contents()
	sledgehammer = new(src)
	update_icon(UPDATE_ICON_STATE)	// So its initial icon doesn't show it without the fireaxe

/obj/structure/closet/sechammercabinet/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/twohanded/sechammer))
		var/obj/item/twohanded/sechammer/hammer = I
		if(!user.drop_transfer_item_to_loc(hammer, src))
			return ..()
		balloon_alert(user, "кувалда закреплена")
		sledgehammer = hammer
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/closet/sechammercabinet/attack_hand(mob/user)
	if(!sledgehammer)
		return

	add_fingerprint(user)
	sledgehammer.forceMove_turf()
	user.put_in_hands(sledgehammer, ignore_anim = FALSE)
	balloon_alert(user, "кувалда извлечена")
	sledgehammer = null
	update_icon(UPDATE_ICON_STATE)

/obj/structure/closet/sechammercabinet/blob_act(obj/structure/blob/B)
	if(sledgehammer)
		sledgehammer.forceMove(loc)
	qdel(src)

/obj/structure/closet/sechammercabinet/update_icon_state()
	if(sledgehammer)
		icon_state = "sechammer_full"
	else
		icon_state = "sechammer_empty"
