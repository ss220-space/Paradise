/obj/effect/decal/ash_rune_centre
	name = "ash sigil"
	ru_names = list(
		NOMINATIVE = "пепельный сигил",
		GENITIVE = "пепельного сигила",
		DATIVE = "пепельному сигилу",
		ACCUSATIVE = "пепельный сигил",
		INSTRUMENTAL = "пепельным сигилом",
		PREPOSITIONAL = "пепельном сигиле"
	)
	desc = "Незаконченная руна, нарисованная на пепле."
	icon = 'icons/effects/ash_runes.dmi'
	icon_state = "runaash_1"

	///Is our rune being transformed right now? Sanity check
	var/transforming = FALSE
	///Is our rune activated? Another sanity check, love it
	var/activated = FALSE

// Our little cheat in order to make first rune activation unforgetable
/obj/effect/rune_animation_landmark
	name = "ash rune"
	ru_names = list(
		NOMINATIVE = "пепельная руна",
		GENITIVE = "пепельной руны",
		DATIVE = "пепельной руне",
		ACCUSATIVE = "пепельную руну",
		INSTRUMENTAL = "пепельной руной",
		PREPOSITIONAL = "пепельной руне"
	)
	icon = 'icons/effects/ashwalker_rune.dmi'
	icon_state = "AshRun"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER

/obj/effect/rune_animation_landmark/Initialize(mapload)
	. = ..()
	icon_state = ""
	invisibility = INVISIBILITY_MAXIMUM

/obj/effect/rune_animation_landmark/proc/activate()
	invisibility = 0
	flick("3", src)
	icon_state = "AshRun"
	visible_message(span_notice("руна полностью готова к использованию!"))

/obj/effect/decal/ash_rune_centre/Initialize(mapload)
	. = ..()
	var/number = rand(1, 36)
	icon_state = "runaash_[number]"

/obj/effect/decal/ash_rune_centre/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/melee/touch_attack/healtouch))
		return ..()
	if(transforming)
		return ..()
	visible_message(span_notice("[user] прикасается рукой к руне."))
	transforming = TRUE
	var/obj/effect/rune_animation_landmark/our_landmark = locate() in orange(3, src)
	if(!our_landmark)
		visible_message(span_warning("но ничего не происходит."))
	if(!activated)
		our_landmark.activate()
	activate_rune()
	qdel(I)
	return ATTACK_CHAIN_PROCEED

/obj/effect/decal/ash_rune_centre/proc/activate_rune()
	if(activated)
		return
	activated = TRUE
	name = "ash rune"
	desc = "полностью функционирующая руна, готовая для ритуальных действий."
	AddComponent( \
		/datum/component/ritual_object, \
		/datum/ritual/ashwalker, \
	)
