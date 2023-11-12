/obj/structure/pit
	name = "pit"
	desc = "Watch your step, partner."
	icon = 'icons/obj/pit.dmi'
	icon_state = "pit1"
	blend_mode = BLEND_DEFAULT
	density = FALSE
	anchored = TRUE
	layer = 2.9
	var/datum/gas_mixture/igm = new //inside gas mixture
	var/open = 1
	var/icon_floor_type = null

/obj/structure/pit/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/shovel))
		visible_message("<span class='notice'>\The [user] starts [open ? "filling" : "digging open"] \the [src]</span>")
		if(do_after(user, 5 SECONDS * W.toolspeed * gettoolspeedmod(user), target = src))
			visible_message("<span class='notice'>\The [user] [open ? "fills" : "digs open"] \the [src]!</span>")
			if(open)
				close(user)
			else
				open()
		else
			to_chat(user, "<span class='notice'>You stop shoveling.</span>")
		return
	if (!open && istype(W,/obj/item/stack/sheet/wood))
		if(locate(/obj/structure/gravemarker) in src.loc)
			to_chat(user, "<span class='notice'>There's already a grave marker here.</span>")
		else
			visible_message("<span class='notice'>\The [user] starts making a grave marker on top of \the [src]</span>")
			if(do_after(user, 5 SECONDS * W.toolspeed * gettoolspeedmod(user), target = src))
				visible_message("<span class='notice'>\The [user] finishes the grave marker</span>")
				var/obj/item/stack/sheet/wood/plank = W
				plank.use(2)
				new/obj/structure/gravemarker(src.loc)
			else
				to_chat(user, "<span class='notice'>You stop making a grave marker.</span>")
		return
	..()

/obj/structure/pit/update_icon()
	icon_state = "pit[open][icon_floor_type]"

/obj/structure/pit/New()
	if(istype(loc, /turf/simulated/floor/plating/asteroid))
		icon_floor_type = "mud"
	if(istype(loc, /turf/simulated/floor/plating/asteroid/basalt))
		icon_floor_type = "asteroid"
	if(istype(loc, /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface))
		icon_floor_type = ""
	if(istype(loc, /turf/simulated/floor/beach/sand))
		icon_floor_type = "sand"
	if(istype(loc, /turf/simulated/floor/grass))
		icon_floor_type = "mud"
	update_icon()
	..()

/obj/structure/pit/proc/open()
	name = "pit"
	desc = "Watch your step, partner."
	open = 1
	for(var/atom/movable/A in src)
		A.forceMove(src.loc)
	update_icon()
	igm = src.return_air()

/obj/structure/pit/proc/close(var/user)
	name = "mound"
	desc = "Some things are better left buried."
	open = 0
	for(var/atom/movable/A in src.loc)
		if(!A.anchored && A != user)
			A.forceMove(src)
	update_icon()
	var/turf/simulated/turf = get_turf(src)
	var/datum/gas_mixture/gm = turf.return_air()
	igm = gm

/obj/structure/pit/return_air()
	if(open && loc)	//opened
		return loc.return_air()
	if(loc)  //closed
		return igm
	else
		return null

/obj/structure/pit/container_resist(mob/escapee)
	var/breakout_time = 1 //2 minutes by default

	if(open)
		return

	if(escapee.stat || escapee.restrained())
		return

	escapee.changeNext_click(CLICK_CD_CLICK_ABILITY)
	to_chat(escapee, "<span class='warning'>You start digging your way out of \the [src] (this will take about [breakout_time] minute\s)</span>")
	visible_message("<span class='danger'>Something is scratching its way out of \the [src]!</span>")

	for(var/i in 1 to (6*breakout_time * 2)) //minutes * 6 * 5seconds * 2
		playsound(src.loc, 'sound/effects/squelch1.ogg', 100, 1)

		if(!do_after(escapee, 50))
			to_chat(escapee, "<span class='warning'>You have stopped digging.</span>")
			return
		if(open)
			return

		if(i == 6*breakout_time)
			to_chat(escapee, "<span class='warning'>Halfway there...</span>")

	to_chat(escapee, "<span class='warning'>You successfuly dig yourself out!</span>")
	visible_message("<span class='danger'>\the [escapee] emerges from \the [src]!</span>")
	playsound(src.loc, 'sound/effects/squelch1.ogg', 100, 1)
	open()

/obj/structure/pit/closed
	name = "mound"
	desc = "Some things are better left buried."
	icon_state = "pit0"
	open = 0

/obj/structure/pit/closed/Initialize()
	. = ..()
	close()

//invisible until unearthed first
/obj/structure/pit/closed/hidden
	invisibility = INVISIBILITY_OBSERVER

/obj/structure/pit/closed/hidden/open()
	..()
	invisibility = null

//spoooky
/obj/structure/pit/closed/grave
	name = "grave"
	icon_state = "pit0"

/obj/structure/pit/closed/grave/Initialize()
	var/obj/structure/closet/coffin/C = new(src.loc)
	var/obj/effect/decal/remains/bones = new(C)
	bones.layer = LYING_MOB_LAYER
	var/obj/structure/gravemarker/random/R = new(src.loc)
	R.generate()
	. = ..()

/obj/structure/gravemarker
	name = "grave marker"
	desc = "You're not the first."
	icon = 'icons/obj/pit.dmi'
	icon_state = "wood"
	pixel_x = 15
	pixel_y = 8
	anchored = TRUE
	var/message = "Unknown."

/obj/structure/gravemarker/cross
	icon_state = "cross"

/obj/structure/gravemarker/examine(mob/user)
	. = ..()
	to_chat(user, "It says: '[message]'")

/obj/structure/gravemarker/random/Initialize()
	generate()
	. = ..()

/obj/structure/gravemarker/random/proc/generate()
	var/nam
	icon_state = pick("wood","cross")
	var/female = (prob(1) ?  TRUE : FALSE)
	if(female)
		name = pick(GLOB.first_names_female)
		nam += " " + pick(GLOB.last_names_female)
	else
		nam = pick(GLOB.first_names_male)
		nam += " " + pick(GLOB.last_names)
	var/cur_year = GLOB.game_year
	var/born = cur_year - rand(5,150)
	var/died = max(cur_year - rand(0,70),born)

	message = "Here lies [nam], [born] - [died]."

/obj/structure/gravemarker/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/hatchet)) //просто томагавк
		visible_message("<span class = 'warning'>\The [user] starts hacking away at \the [src] with \the [W].</span>")
		if(!do_after(user, 30))
			visible_message("<span class = 'warning'>\The [user] hacks \the [src] apart.</span>")
			new /obj/item/stack/sheet/wood(src)
			new /obj/item/stack/sheet/wood(src)
			qdel(src)
	if(istype(W,/obj/item/pen))
		var/msg = sanitize(input(user, "What should it say?", "Grave marker", message) as text|null)
		if(msg)
			message = msg
