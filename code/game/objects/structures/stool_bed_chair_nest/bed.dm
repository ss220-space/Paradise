/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * 		Beds
 *		Roller beds
 *		Dog Beds
 */

/*
 * Beds
 */

/obj/structure/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon = 'icons/obj/objects.dmi'
	icon_state = "bed"
	can_buckle = TRUE
	anchored = TRUE
	buckle_lying = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 100
	integrity_failure = 30
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 2
	buckle_offset = -6
	var/comfort = 2 // default comfort

/obj/structure/bed/post_buckle_mob(mob/living/M)
	. = ..()
	if(!M.resting)
		M.StartResting()

/obj/structure/bed/post_unbuckle_mob(mob/living/M)
	. = ..()
	if(M.resting)
		M.StopResting()

/obj/structure/bed/psych
	name = "psych bed"
	desc = "For prime comfort during psychiatric evaluations."
	icon_state = "psychbed"
	buildstackamount = 5

/obj/structure/bed/alien
	name = "resting contraption"
	desc = "This looks similar to contraptions from Earth. Could aliens be stealing our technology?"
	icon_state = "abed"
	comfort = 0.3

/obj/structure/bed/sandstone
	name = "sandstone plate"
	desc = "This is used to lie on, feels farm."
	icon_state = "bed_sand"
	resistance_flags = FIRE_PROOF
	max_integrity = 200
	buildstacktype = /obj/item/stack/sheet/mineral/sandstone
	buildstackamount = 15
	buckle_offset = -7

/obj/structure/bed/proc/handle_rotation()
	return

/obj/structure/bed/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(flags & NODECONSTRUCT)
		to_chat(user, "<span class='warning'>You can't figure out how to deconstruct [src]!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	deconstruct(TRUE)

/obj/structure/bed/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(buildstacktype)
			new buildstacktype(loc, buildstackamount)
	..()

/obj/structure/bed/strawnest
	name = "straw nest"
	desc = "This is used to lie on, feels itchy."
	icon_state = "strawnest"
	max_integrity = 50
	buckle_offset = -2
	comfort = 0.1
	buildstacktype = null
	buildstackamount = null
	anchored = FALSE
	resistance_flags = FLAMMABLE
	var/sounds = list('sound/effects/footstep/grass1.ogg', 'sound/effects/footstep/grass2.ogg', 'sound/effects/footstep/grass3.ogg', 'sound/effects/footstep/grass4.ogg')

/obj/structure/bed/strawnest/Move()
	. = ..()
	if(prob(5))
		new /obj/effect/decal/straw/light(get_turf(src))
		playsound(src, pick(sounds), 60)

/obj/structure/bed/strawnest/Crossed(atom/movable/AM, oldloc)
	playsound(src, pick(sounds), 60)

/obj/structure/bed/strawnest/deconstruct(disassembled = TRUE)
	new /obj/item/reagent_containers/food/snacks/grown/wheat(loc)
	..()

/obj/structure/bed/strawnest/wrench_act(mob/user, obj/item/I)
	return

/obj/structure/bed/strawnest/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(flags & NODECONSTRUCT)
		to_chat(user, "<span class='warning'>You can't figure out how to deconstruct [src]!</span>")
		return
	if(!is_sharp(I))
		to_chat(user, "<span class='warning'>You need something sharp to deconstruct [src]!</span>")
		return
	user.visible_message("<span class='warning'>[user] starts cutting through [src] with [I]!</span>", "<span class='danger'>You start cutting [src] with [I]!</span>")
	if(do_after(user, 2 SECONDS, target = user))
		deconstruct(TRUE)
	else
		to_chat(user, "<span class='warning'>Don't move while cutting [src]!</span>")

/*
 * Roller beds
 */

/obj/structure/bed/roller
	name = "roller bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	resistance_flags = NONE
	anchored = FALSE
	comfort = 1
	var/icon_up = "up"
	var/icon_down = "down"
	var/folded = /obj/item/roller
	pull_push_speed_modifier = 1

/obj/structure/bed/roller/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/roller_holder))
		if(has_buckled_mobs())
			add_fingerprint(user)
			if(buckled_mobs.len > 1)
				unbuckle_all_mobs()
				user.visible_message("<span class='notice'>[user] unbuckles all creatures from [src].</span>")
			else
				user_unbuckle_mob(buckled_mobs[1], user)
		else
			user.visible_message("<span class='notice'>[user] collapses \the [name].</span>", "<span class='notice'>You collapse \the [name].</span>")
			new folded(get_turf(src))
			qdel(src)
	else
		return ..()

/obj/structure/bed/roller/post_buckle_mob(mob/living/M)
	. = ..()
	density = TRUE
	icon_state = icon_up
	M.pixel_y = initial(M.pixel_y)

/obj/structure/bed/roller/post_unbuckle_mob(mob/living/M)
	. = ..()
	density = FALSE
	icon_state = icon_down
	M.pixel_x = M.get_standard_pixel_x_offset(M.lying_angle)
	M.pixel_y = M.get_standard_pixel_y_offset(M.lying_angle)

/obj/structure/bed/roller/holo
	name = "holo stretcher"
	icon_state = "holo_down"
	icon_up = "holo_up"
	icon_down = "holo_down"
	folded = /obj/item/roller/holo

/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	var/extended = /obj/structure/bed/roller
	w_class = WEIGHT_CLASS_BULKY // Can't be put in backpacks.

/obj/item/roller/attack_self(mob/user)
	var/obj/structure/bed/roller/R = new extended(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/roller/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/roller_holder))
		var/obj/item/roller_holder/RH = W
		if(!RH.held)
			user.visible_message("<span class='notice'>[user] collects \the [name].</span>", "<span class='notice'>You collect \the [name].</span>")
			forceMove(RH)
			RH.held = src


/obj/structure/bed/roller/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(!has_buckled_mobs() && over_object == usr && ishuman(usr) && !usr.incapacitated() && usr.Adjacent(src))
		usr.visible_message(
			span_notice("[usr] collapses [src]."),
			span_notice("You collapse [src]."),
		)
		new folded(get_turf(src))
		qdel(src)
		return FALSE
	return ..()


/obj/item/roller/holo
	name = "holo stretcher"
	desc = "A retracted hardlight stretcher that can be carried around."
	icon_state = "holo_retracted"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "magnets=3;biotech=4;powerstorage=3"
	extended = /obj/structure/bed/roller/holo

/obj/item/roller/holo/attackby(obj/item/W, mob/user, params)
	return

/obj/item/roller_holder
	name = "roller bed rack"
	desc = "A rack for carrying a collapsed roller bed."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	var/obj/item/roller/held

/obj/item/roller_holder/New()
	..()
	held = new /obj/item/roller(src)

/obj/item/roller_holder/attack_self(mob/user as mob)
	if(!held)
		to_chat(user, "<span class='info'> The rack is empty.</span>")
		return

	to_chat(user, "<span class='notice'>You deploy the roller bed.</span>")
	var/obj/structure/bed/roller/R = new /obj/structure/bed/roller(user.loc)
	R.add_fingerprint(user)
	QDEL_NULL(held)

/*
 * Dog beds
 */

/obj/structure/bed/dogbed
	name = "dog bed"
	icon_state = "dogbed"
	desc = "A comfy-looking dog bed. You can even strap your pet in, just in case the gravity turns off."
	anchored = FALSE
	buildstackamount = 10
	buildstacktype = /obj/item/stack/sheet/wood
	buckle_offset = 0
	comfort = 0.5

/obj/structure/bed/dogbed/ian
	name = "Ian's bed"
	desc = "Ian's bed! Looks comfy."
	anchored = TRUE

/obj/structure/bed/dogbed/renault
	desc = "Renault's bed! Looks comfy. A foxy person needs a foxy pet."
	name = "Renault's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/runtime
	desc = "A comfy-looking cat bed. You can even strap your pet in, in case the gravity turns off."
	name = "Runtime's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/pet
	name = "Удобная лежанка"
	desc = "Комфортная лежанка для любимейшего питомца отдела."
	anchored = TRUE
