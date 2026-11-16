//MISC EFFECTS

//This file is for effects that are less than 20 lines and don't fit very well in any other category.

/*CURRENT CONTENTS
	Strange Present
	Mark
	Beam
	Laser
	Begin
	Stop
	Projection
	Shut_controller
	Showcase
	Spawner
	List_container
	falling pipe
*/

//The effect when you wrap a dead body in gift wrap
/obj/effect/spresent
	name = "strange present"
	desc = "It's a ... present?"
	icon = 'icons/obj/items.dmi'
	icon_state = "strangepresent"
	density = TRUE
	anchored = FALSE

/obj/effect/spresent/relaymove(mob/user)
	if(user.stat)
		return
	to_chat(user, span_notice("Вы не можете двигаться."))

/obj/effect/spresent/wirecutter_act(mob/living/user, obj/item/item)
	. = TRUE
	if(!item.use_tool(src, user, volume = item.tool_volume))
		return

	user.balloon_alert(user, "подарок открыт!")
	for(var/atom/movable/thing as anything in contents) //Should only be one but whatever.
		thing.forceMove(loc)

	qdel(src)

/obj/effect/mark
		var/mark = ""
		icon = 'icons/misc/mark.dmi'
		icon_state = "blank"
		layer = 99
		plane = HUD_PLANE
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/beam
	name = "beam"
	var/def_zone
	pass_flags = PASSTABLE

/obj/effect/laser
	name = "laser"
	desc = "IT BURNS!!!"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	var/damage = 0
	var/range = 10

/obj/effect/projection
	name = "Projection"
	desc = "This looks like a projection of something."

/obj/effect/shut_controller
	name = "shut controller"
	var/moving = null
	var/list/parts = list()

/obj/structure/showcase
	name = "Showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = TRUE
	anchored = TRUE

/obj/effect/spawner
	name = "object spawner"

/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null
	var/list/container = list()

/obj/structure/showcase/horrific_experiment
	name = "horrific experiment"
	desc = "Some sort of pod filled with blood and vicerea. You swear you can see it moving..."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_mess"

//Makes a tile fully lit no matter what
/obj/effect/fullbright
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	plane = LIGHTING_PLANE
	layer = LIGHTING_ABOVE_ALL
	blend_mode = BLEND_ADD

/obj/effect/frosty_breath //used only for unathi firebreath, so... yeah..
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_LAYER

/obj/effect/frosty_breath/Initialize(mapload, mob/living/carbon/C)
	. = ..()
	dir = C.dir
	if(dir == NORTH)
		layer = BELOW_MOB_LAYER
	flick("breath_[C.lying_prev]", src)
	QDEL_IN(src, 2 SECONDS)

/obj/effect/falling_pipe
	name = "falling pipe"
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/pipes.dmi'
	icon_state = "exposed00"
	dir = EAST
	layer = ABOVE_ALL_MOB_LAYER
	pixel_z = 224
	var/fall_duration = 1 SECONDS

/obj/effect/falling_pipe/Initialize(mapload, mob/shooter)
	. = ..()
	visible_message(span_biggerdanger("Труба отрывается от потолка!"))
	animate(src, pixel_z = 0, time = fall_duration, easing = QUAD_EASING|EASE_IN)
	addtimer(CALLBACK(src, PROC_REF(land), shooter), fall_duration)

/obj/effect/falling_pipe/proc/land(mob/shooter)
	var/turf/landing_turf = get_turf(src)
	if(!isfloorturf(landing_turf))
		qdel(src)
		return

	var/obj/item/pipe/fallen_pipe = new(landing_turf, 0, dir)
	fallen_pipe.name = "fallen pipe"
	fallen_pipe.ru_names = alist(
		NOMINATIVE = "упавшая труба",
		GENITIVE = "упавшей трубы",
		DATIVE = "упавшей трубе",
		ACCUSATIVE = "упавшую трубу",
		INSTRUMENTAL = "упавшей трубой",
		PREPOSITIONAL = "упавшей трубе",
	)
	fallen_pipe.desc = "Участок трубопровода, проложенного над головой. Похоже, в нём есть довольно крупное пулевое отверстие..."
	playsound(landing_turf, 'sound/misc/metal_pipe_falling.ogg', 100, FALSE)

	var/has_victims = FALSE
	for(var/mob/living/victim in landing_turf)
		has_victims = TRUE
		victim.visible_message(
			span_biggerdanger("БА-БАХ! Труба приземляется прямо на голову [victim.declent_ru(ACCUSATIVE)]!"),
			span_biggerdanger("ОХ БЛЯТЬ! ТРУБА ПАДАЕТ ПРЯМО ТЕБЕ НА ГОЛОВУ!!")
		)
		victim.emote("scream")
		victim.apply_damage(50, BRUTE, BODY_ZONE_HEAD, used_weapon = fallen_pipe)
		victim.EyeBlurry(10 SECONDS)
		victim.Stun(5 SECONDS)
		victim.Knockdown(5 SECONDS)

	if(!has_victims)
		visible_message(span_biggerdanger("БА-БАХ! Труба с грохотом падает на пол."))
	qdel(src)
