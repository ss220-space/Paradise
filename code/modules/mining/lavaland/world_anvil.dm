/obj/structure/world_anvil
	name = "World Anvil"
	desc = "Кузня, соединённая лавовыми резервуарами с ядром Лазиса. Последний, кто ей пользовался, создавал нечто могущественное."
	ru_names = list(
		NOMINATIVE = "Мировая Кузня",
		GENITIVE = "Мировой Кузни",
		DATIVE = "Мировой Кузне",
		ACCUSATIVE = "Мировую Кузню",
		INSTRUMENTAL = "Мировой Кузней",
		PREPOSITIONAL = "Мировой Кузне"
	)
	icon = 'icons/obj/lavaland/anvil.dmi'
	icon_state = "anvil"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	climbable = TRUE
	pass_flags = LETPASSTHROW
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// What is currently forging in source
	var/atom/movable/forging
	var/forge_charges = 0
	var/obj/item/gps/internal

/obj/item/gps/internal/world_anvil
	icon_state = null
	gpstag = "Tempered Signal"
	desc = "An ancient anvil rests at this location."
	invisibility = 100

/obj/structure/world_anvil/Initialize()
	. = ..()
	internal = new /obj/item/gps/internal/world_anvil(src)

/obj/structure/world_anvil/Destroy()
	QDEL_NULL(internal)
	. = ..()

/obj/structure/world_anvil/update_icon_state()
	icon_state = forge_charges > 0 ? "anvil_a" : "anvil"


/obj/structure/world_anvil/update_overlays()
	. = ..()
	if(forging)
		. += forging.appearance


/obj/structure/world_anvil/proc/update_state()
	update_icon()
	if(forge_charges > 0)
		set_light(4,1,LIGHT_COLOR_ORANGE, l_on = TRUE)
	else
		set_light_on(FALSE)


/obj/structure/world_anvil/examine(mob/user)
	. = ..()
	. += span_notice("Доступно [forge_charges] ковочн[declension_ru(forge_charges,"ый заряд","ых заряда","ых заряда")].")


/obj/structure/world_anvil/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	add_fingerprint(user)
	if(istype(I, /obj/item/twohanded/required/gibtonite))
		var/obj/item/twohanded/required/gibtonite/gibtonite = I
		if(forging)
			to_chat(user, span_warning("Кто-то уже использует Мировую Кузню!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(gibtonite, src))
			return ..()
		forge_charges = forge_charges + gibtonite.quality
		to_chat(user, span_notice("Вы помещаете гибтонит на Мировую Кузню, наблюдая как он плавится. Теперь наковальня достаточно нагрета для <b>[forge_charges]</b> ковочн[declension_ru(forge_charges,"ого заряда","ых зарядов","ых зарядов")]."))
		qdel(gibtonite)
		update_state()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/gem/amber))
		var/obj/item/gem/amber/gem = I
		if(forging)
			to_chat(user, span_warning("Кто-то уже использует Мировую Кузню!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(gem, src))
			return ..()
		forge_charges += 3
		to_chat(user, span_notice("Вы помещаете драконий янтарь на Мировую Наковальню, наблюдая как он плавится. Теперь наковальня достаточно нагрета для <b>[forge_charges]</b> ковочн[declension_ru(forge_charges,"ого заряда","ых зарядов","ых зарядов")]."))
		qdel(gem)
		update_state()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(forge_charges <= 0)
		to_chat(user, span_warning("Мировая Кузня недостаточно нагрета для использования!"))
		return ATTACK_CHAIN_PROCEED

	if(istype(I, /obj/item/magmite))
		if(forging)
			to_chat(user, span_warning("Кто-то уже использует Мировую Кузню!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		forging = I
		update_icon(UPDATE_OVERLAYS)
		var/atom/drop_loc = drop_location()
		playsound(loc, 'sound/effects/anvil_start.ogg', 50)
		if(!do_after(user, 7 SECONDS, src, max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_warning("You stop forging."), category = DA_CAT_TOOL))
			forging = null
			I.forceMove(drop_loc)
			update_icon(UPDATE_OVERLAYS)
			return ATTACK_CHAIN_PROCEED
		forging = null
		to_chat(user, span_notice("Вы искусно выковали из грубого плазменного магмита комплект улучшений."))
		playsound(loc, 'sound/effects/anvil_end.ogg', 50)
		var/obj/item/magmite_parts/parts = new(drop_loc)
		parts.add_fingerprint(user)
		qdel(I)
		forge_charges--
		update_state()
		if(forge_charges <= 0)
			visible_message(span_notice("Мировая Кузня остывает."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/magmite_parts))
		var/obj/item/magmite_parts/parts = I
		if(!parts.inert)
			to_chat(user, span_warning("Детали из магмита уже раскалены и готовы к использованию!"))
			return ATTACK_CHAIN_PROCEED
		if(forging)
			to_chat(user, span_warning("Кто-то уже использует Мировую Кузню!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(parts, src))
			return ..()
		forging = parts
		update_icon(UPDATE_OVERLAYS)
		var/atom/drop_loc = drop_location()
		playsound(loc, 'sound/effects/anvil_end.ogg', 50)
		if(!do_after(user, 3 SECONDS, src, max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_warning("You stop forging."), category = DA_CAT_TOOL))
			forging = null
			parts.forceMove(drop_loc)
			update_icon(UPDATE_OVERLAYS)
			return ATTACK_CHAIN_PROCEED
		forging = null
		to_chat(user, span_notice("Вы успешно переплавили детали улучшений. Теперь они снова раскалены и готовы к использованию."))
		playsound(loc, 'sound/effects/anvil_end.ogg', 50)
		parts.forceMove(drop_loc)
		parts.restore()
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	to_chat(user, span_warning("Вы не знаете, что можно выковать из [I.declent_ru(GENITIVE)]!"))
	return ATTACK_CHAIN_PROCEED

