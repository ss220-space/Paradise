/obj/item/mounted/frame/light_fixture
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	mount_requirements = MOUNTED_FRAME_SIMFLOOR
	wall_external = TRUE
	/// Specifies which type of light fixture this frame will build
	var/fixture_type = "tube"

/obj/item/mounted/frame/light_fixture/do_build(turf/on_wall, mob/user)
	to_chat(user, "You begin attaching [src] to [on_wall].")
	playsound(get_turf(src), 'sound/machines/click.ogg', 75, TRUE)
	var/constrdir = user.dir
	var/constrloc = get_turf(user)
	if(!do_after(user, 3 SECONDS, on_wall))
		return
	var/obj/machinery/light_construct/newlight
	switch(fixture_type)
		if("bulb")
			newlight = new /obj/machinery/light_construct/small(constrloc)
		if("tube")
			newlight = new /obj/machinery/light_construct(constrloc)
		if("floor")
			newlight = new /obj/machinery/light_construct/floor(on_wall)
		else
			newlight = new /obj/machinery/light_construct/small(constrloc)
	newlight.dir = constrdir
	newlight.fingerprints = src.fingerprints
	newlight.fingerprintshidden = src.fingerprintshidden
	newlight.fingerprintslast = src.fingerprintslast

	user.visible_message(
		"[user] attaches [src] to [on_wall].",
		"You attach [src] to [on_wall].",
	)
	qdel(src)

/obj/item/mounted/frame/light_fixture/small
	name = "small light fixture frame"
	desc = "Used for building small lights."
	icon_state = "bulb-construct-item"
	fixture_type = "bulb"
	metal_sheets_refunded = 1

/obj/item/mounted/frame/light_fixture/floor
	name = "floor light fixture frame"
	desc = "Used for building floor lights."
	icon_state = "floor-construct-item"
	fixture_type = "floor"
	metal_sheets_refunded = 3
	buildon_types = list(/turf/simulated/floor)
	allow_floor_mounting = TRUE

/obj/item/mounted/frame/light_fixture/floor/get_ru_names()
	return list(
		NOMINATIVE = "каркас напольного светильника",
		GENITIVE = "каркаса напольного светильника",
		DATIVE = "каркасу напольного светильника",
		ACCUSATIVE = "каркас напольного светильника",
		INSTRUMENTAL = "каркасом напольного светильника",
		PREPOSITIONAL = "каркасе напольного светильника"
	)
