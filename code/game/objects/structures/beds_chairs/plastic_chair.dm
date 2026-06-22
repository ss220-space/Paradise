/obj/structure/chair/plastic
	name = "\improper складной пластиковый стул"
	desc = "Как бы вы ни ёрзали, все равно будет неудобно."
	icon_state = "plastic_chair"
	resistance_flags = FLAMMABLE
	max_integrity = 50
	buildstacktype = /obj/item/stack/sheet/plastic
	buildstackamount = 2
	item_chair = /obj/item/chair/plastic

/obj/structure/chair/plastic/post_buckle_mob(mob/living/target)
	target.add_offsets(type, z_add = 2)
	. = ..()

	if(!iscarbon(target))
		return

	INVOKE_ASYNC(src, PROC_REF(snap_check), target)

/obj/structure/chair/plastic/post_unbuckle_mob(mob/living/target)
	target.remove_offsets(type)
	return ..()

/obj/structure/chair/plastic/proc/snap_check(mob/living/carbon/target)
	if(target.nutrition < NUTRITION_LEVEL_FAT)
		return

	to_chat(target, span_warning("Стул начинает хрустеть и трещать, ты слишком тяжёлый!"))

	if(!do_after(target, 6 SECONDS, progress = FALSE))
		return

	target.visible_message(span_warning("[DECLENT_RU_CAP(target, NOMINATIVE)] садится на пластиковый стул, и проламывает его своим весом!"))
	new /obj/effect/decal/cleanable/plastic(loc)
	target.Knockdown(5 SECONDS)
	target.emote("scream")
	playsound(src, 'sound/effects/snap.ogg', 50, 1, -1)
	qdel(src)

/obj/item/chair/plastic
	name = "\improper складной пластиковый стул"
	desc = "Почему-то, всегда можно найти под рингом."
	icon_state = "folded_chair"
	item_state = "folded_chair"
	w_class = WEIGHT_CLASS_NORMAL
	force = 7
	throw_range = 5
	break_chance = 25
	origin_type = /obj/structure/chair/plastic

/obj/effect/decal/cleanable/plastic
	name = "\improper пластиковые осколки"
	desc = "Куски рваного, сломанного, никчёмного пластика."
	icon = 'icons/obj/objects.dmi'
	icon_state = "shards"
	color = "#c6f4ff"
