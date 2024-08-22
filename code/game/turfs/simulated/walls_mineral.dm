/turf/simulated/wall/mineral
	name = "mineral wall"
	desc = "This shouldn't exist"
	icon_state = ""
	var/last_event = 0
	var/active = null
	canSmoothWith = null
	smooth = SMOOTH_TRUE

/turf/simulated/wall/mineral/shuttleRotate(rotation)
	return // This override is needed to properly rotate the object when on a shuttle that is rotated.

/turf/simulated/wall/mineral/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon = 'icons/turf/walls/gold_wall.dmi'
	icon_state = "gold"
	sheet_type = /obj/item/stack/sheet/mineral/gold
	explosion_block = 0 //gold is a soft metal you dingus.
	base_icon_state = "gold_wall"
	canSmoothWith = SMOOTH_GROUP_GOLD_WALLS
	smoothing_groups = SMOOTH_GROUP_GOLD_WALLS
	smooth = SMOOTH_BITMASK


/turf/simulated/wall/mineral/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny!"
	icon = 'icons/turf/walls/silver_wall.dmi'
	icon_state = "silver"
	sheet_type = /obj/item/stack/sheet/mineral/silver
	base_icon_state = "silver_wall"
	canSmoothWith = SMOOTH_GROUP_SILVER_WALLS
	smoothing_groups = SMOOTH_GROUP_SILVER_WALLS
	smooth = SMOOTH_BITMASK

/turf/simulated/wall/mineral/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon = 'icons/turf/walls/diamond_wall.dmi'
	icon_state = "diamond"
	sheet_type = /obj/item/stack/sheet/mineral/diamond
	explosion_block = 3
	base_icon_state = "diamond_wall"
	canSmoothWith = SMOOTH_GROUP_DIAMOND_WALLS
	smoothing_groups = SMOOTH_GROUP_DIAMOND_WALLS
	smooth = SMOOTH_BITMASK

/turf/simulated/wall/mineral/bananium
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon = 'icons/turf/walls/bananium_wall.dmi'
	icon_state = "bananium_wall-0"
	base_icon_state = "bananium_wall"
	sheet_type = /obj/item/stack/sheet/mineral/bananium
	canSmoothWith = SMOOTH_GROUP_BANANIUM_WALLS
	smoothing_groups = SMOOTH_GROUP_BANANIUM_WALLS
	smooth = SMOOTH_BITMASK

/turf/simulated/wall/mineral/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon = 'icons/turf/walls/sandstone_wall.dmi'
	icon_state = "sandstone"
	sheet_type = /obj/item/stack/sheet/mineral/sandstone
	explosion_block = 0
	base_icon_state = "sandstone_wall"
	canSmoothWith = SMOOTH_GROUP_SANDSTONE_WALLS
	smoothing_groups = SMOOTH_GROUP_SANDSTONE_WALLS
	smooth = SMOOTH_BITMASK

/turf/simulated/wall/mineral/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium"
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	base_icon_state = "uranium_wall"
	canSmoothWith = SMOOTH_GROUP_URANIUM_WALLS
	smoothing_groups = SMOOTH_GROUP_URANIUM_WALLS
	smooth = SMOOTH_BITMASK

/turf/simulated/wall/mineral/uranium/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/radioactivity, \
				rad_per_interaction = 12, \
				rad_interaction_radius = 3, \
				rad_interaction_cooldown = 1.5 SECONDS \
	)

/turf/simulated/wall/mineral/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definately a bad idea."
	icon = 'icons/turf/walls/plasma_wall.dmi'
	icon_state = "plasma"
	sheet_type = /obj/item/stack/sheet/mineral/plasma
	thermal_conductivity = 0.04
	base_icon_state = "plasma_wall"
	canSmoothWith = SMOOTH_GROUP_PLASMA_WALLS
	smoothing_groups = SMOOTH_GROUP_PLASMA_WALLS


/turf/simulated/wall/mineral/plasma/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .
	var/hot_temp = is_hot(I)
	if(hot_temp <= 300)	//If the temperature of the object is over 300, then ignite
		return .
	. |= ATTACK_CHAIN_BLOCKED_ALL
	add_attack_logs(user, src, "Ignited using [I]", ATKLOG_FEW)
	investigate_log("was <span class='warning'>ignited</span> by [key_name_log(user)]",INVESTIGATE_ATMOS)
	ignite(hot_temp)



/turf/simulated/wall/mineral/plasma/welder_act(mob/user, obj/item/I)
	if(I.tool_enabled)
		ignite(2500) //The number's big enough
		user.visible_message(span_danger("[user] sets [src] on fire!"),\
							span_danger("[src] disintegrates into a cloud of plasma!"),\
							span_italics("You hear a 'whoompf' and a roar."))
		add_attack_logs(user, src, "Ignited using [I]", ATKLOG_FEW)
		investigate_log("was <span class='warning'>ignited</span> by [key_name_log(user)]",INVESTIGATE_ATMOS)

/turf/simulated/wall/mineral/plasma/proc/PlasmaBurn(temperature)
	new girder_type(src)
	ChangeTurf(/turf/simulated/floor/plating)
	atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, 400)

/turf/simulated/wall/mineral/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)//Doesn't fucking work because walls don't interact with air :(
	..()
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/turf/simulated/wall/mineral/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/turf/simulated/wall/mineral/plasma/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage == 0)//lasertag guns and so on don't set off plasma anymore. can't use nodamage here because lasertag guns actually don't have it.
		return
	if(istype(Proj,/obj/item/projectile/beam))
		PlasmaBurn(2500)
	else if(istype(Proj,/obj/item/projectile/ion))
		PlasmaBurn(500)
	..()

/turf/simulated/wall/mineral/alien
	name = "alien wall"
	desc = "A strange-looking alien wall."
	icon = 'icons/turf/walls/plasma_wall.dmi'
	icon_state = "plasma_wall-0"
	base_icon_state = "plasma_wall"
	canSmoothWith = SMOOTH_GROUP_PLASMA_WALLS
	smoothing_groups = SMOOTH_GROUP_PLASMA_WALLS
	sheet_type = /obj/item/stack/sheet/mineral/abductor

/turf/simulated/wall/mineral/wood
	name = "wooden wall"
	desc = "A wall with wooden plating. Stiff."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood_wall-0"
	base_icon_state = "wood_wall"
	canSmoothWith = SMOOTH_GROUP_WOOD_WALLS
	smoothing_groups = SMOOTH_GROUP_WOOD_WALLS
	smooth = SMOOTH_BITMASK
	sheet_type = /obj/item/stack/sheet/wood
	hardness = 70
	explosion_block = 0


/turf/simulated/wall/mineral/wood/try_decon(obj/item/I, mob/user, params)
	if(is_sharp(I) && I.force)
		var/duration = (48 / I.force) * 2 //In seconds, for now.
		if(istype(I, /obj/item/hatchet) || istype(I, /obj/item/twohanded/fireaxe))
			duration /= 4 //Much better with hatchets and axes.
		if(do_after(user, duration * I.toolspeed, src, category = DA_CAT_TOOL))
			dismantle_wall(FALSE, FALSE)
			return TRUE
		return FALSE
	return ..()


/turf/simulated/wall/mineral/wood/nonmetal
	desc = "A solidly wooden wall. It's a bit weaker than a wall made with metal."
	girder_type = /obj/structure/barricade/wooden
	hardness = 50
	canSmoothWith = SMOOTH_GROUP_WOOD_WALLS
	smoothing_groups = SMOOTH_GROUP_WOOD_WALLS

/turf/simulated/wall/mineral/iron
	name = "rough metal wall"
	desc = "A wall with rough metal plating."
	icon = 'icons/turf/walls/iron_wall.dmi'
	icon_state = "iron"
	sheet_type = /obj/item/stack/rods
	sheet_amount = 5
	canSmoothWith = SMOOTH_GROUP_IRON_WALLS
	smoothing_groups = SMOOTH_GROUP_IRON_WALLS

/turf/simulated/wall/mineral/abductor
	name = "alien wall"
	desc = "A wall with alien alloy plating."
	icon = 'icons/turf/walls/abductor_wall.dmi'
	icon_state = "abductor_wall-0"
	base_icon_state = "abductor_wall"
	smooth = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	sheet_type = /obj/item/stack/sheet/mineral/abductor
	explosion_block = 3
	canSmoothWith = SMOOTH_GROUP_ABDUCTOR_WALLS
	smoothing_groups = SMOOTH_GROUP_ABDUCTOR_WALLS

/turf/simulated/wall/mineral/abductor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wall_regenerate)

/turf/simulated/wall/mineral/gingerbread
	name = "gingerbread wall"
	desc = "Don't even try to bite it!"
	icon = 'icons/turf/walls/gingerbread_wall.dmi'
	icon_state = "gingerbread"
	sheet_amount = 5
	sheet_type = /obj/item/stack/sheet/gingerbread
	base_icon_state = "gingerbread_wall"
	canSmoothWith = SMOOTH_GROUP_WALL_GINGERBREAD
	smoothing_groups = SMOOTH_GROUP_WALL_GINGERBREAD

/////////////////////Titanium walls/////////////////////

/turf/simulated/wall/mineral/titanium //has to use this path due to how building walls works
	name = "wall"
	desc = "A light-weight titanium wall used in shuttles."
	icon = 'icons/turf/walls/shuttle/shuttle_wall.dmi'
	icon_state = "shuttle-0"
	base_icon_state = "shuttle"
	explosion_block = 3
	flags = CHECK_RICOCHET
	sheet_type = /obj/item/stack/sheet/mineral/titanium
	smooth = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	canSmoothWith = SMOOTH_GROUP_TITANIUM_WALLS + SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE + SMOOTH_GROUP_AIRLOCK
	smoothing_groups = SMOOTH_GROUP_TITANIUM_WALLS

/turf/simulated/wall/mineral/titanium/nodiagonal //currently broken, do not use
	smooth = SMOOTH_BITMASK
	icon_state = "shuttle_nd"

/turf/simulated/wall/mineral/titanium/nosmooth
	icon = 'icons/turf/shuttle/shuttle.dmi'
	icon_state = "wall"
	smooth = NONE

/turf/simulated/wall/mineral/titanium/overspace
	icon_state = "overspace"
	fixed_underlay = list("space"=1)

//sub-type to be used for interior shuttle walls
//won't get an underlay of the destination turf on shuttle move
/turf/simulated/wall/mineral/titanium/interior/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(T.color != color)
		T.color = color
	if(T.dir != dir)
		T.dir = dir
	T.transform = transform
	return T

/turf/simulated/wall/mineral/titanium/copyTurf(turf/T)
	. = ..()
	T.transform = transform

/turf/simulated/wall/mineral/titanium/survival
	name = "pod wall"
	desc = "An easily-compressable wall used for temporary shelter."
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "smooth"
	base_icon_state = "survival_pod_walls"
	smooth = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	canSmoothWith = SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE + SMOOTH_GROUP_AIRLOCK
	smoothing_groups = SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS

/turf/simulated/wall/mineral/titanium/survival/nodiagonal
	smooth = SMOOTH_BITMASK

/turf/simulated/wall/mineral/titanium/survival/pod
	canSmoothWith = SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE + SMOOTH_GROUP_AIRLOCK

//undeconstructable type for derelict
//these walls are undeconstructable/unthermitable
/turf/simulated/wall/mineral/titanium/nodecon
	name = "russian wall"
	desc = "Like regular titanium, but able to deflect capitalist aggressors."

/turf/simulated/wall/mineral/titanium/nodecon/tileblend
	fixed_underlay = list("icon"='icons/turf/floors.dmi', "icon_state"="darkredfull")

/turf/simulated/wall/mineral/titanium/nodecon/nodiagonal
	smooth = SMOOTH_BITMASK
	icon_state = "shuttle_nd"

/turf/simulated/wall/mineral/titanium/nodecon/nosmooth
	smooth = NONE
	icon_state = "shuttle_ns"

//properties for derelict sub-type to prevent said deconstruction/thermiting
/turf/simulated/wall/mineral/titanium/nodecon/try_decon(obj/item/I, mob/user, params)
	return

/turf/simulated/wall/mineral/titanium/nodecon/thermitemelt(mob/user, time)
	return

/turf/simulated/wall/mineral/titanium/nodecon/burn_down()
	return

/turf/simulated/wall/mineral/titanium/nodecon/welder_act()
	return

/turf/simulated/wall/mineral/titanium/nodecon/rcd_deconstruct_act()
	return RCD_NO_ACT

/////////////////////Plastitanium walls/////////////////////

/turf/simulated/wall/mineral/plastitanium
	name = "wall"
	desc = "An evil wall of plasma and titanium."
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-0"
	base_icon_state = "plastitanium_wall"
	explosion_block = 4
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium
	smooth = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	smoothing_groups = SMOOTH_GROUP_PLASTITANIUM_WALLS
	canSmoothWith = SMOOTH_GROUP_PLASTITANIUM_WALLS

/turf/simulated/wall/mineral/plastitanium/nodiagonal
	smooth = SMOOTH_BITMASK
	icon_state = "shuttle_nd"

/turf/simulated/wall/mineral/plastitanium/nosmooth
	icon = 'icons/turf/shuttle/shuttle.dmi'
	icon_state = "wall"
	smooth = NONE

/turf/simulated/wall/mineral/plastitanium/overspace
	icon_state = "overspace"
	fixed_underlay = list("space"=1)

/turf/simulated/wall/mineral/plastitanium/coated
	name = "coated wall"
	max_temperature = INFINITY
	icon_state = "shuttle_nd"
	smooth = SMOOTH_BITMASK

/turf/simulated/wall/mineral/plastitanium/coated/Initialize(mapload)
	. = ..()
	desc += " It seems to have additional plating to protect against heat."

/turf/simulated/wall/mineral/plastitanium/explosive
	var/explosive_wall_group = EXPLOSIVE_WALL_GROUP_SYNDICATE_BASE
	icon_state = "shuttle_nd"
	smooth = SMOOTH_BITMASK

/turf/simulated/wall/mineral/plastitanium/explosive/Initialize(mapload)
	. = ..()
	GLOB.explosive_walls += src

/turf/simulated/wall/mineral/plastitanium/explosive/Destroy()
	GLOB.explosive_walls -= src
	return ..()

/turf/simulated/wall/mineral/plastitanium/explosive/proc/self_destruct()
	var/obj/item/bombcore/large/explosive_wall/bombcore = new(get_turf(src))
	bombcore.detonate()

/turf/simulated/wall/mineral/plastitanium/explosive/ex_act(severity)
	return

//have to copypaste this code
/turf/simulated/wall/mineral/plastitanium/interior/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(T.color != color)
		T.color = color
	if(T.dir != dir)
		T.dir = dir
	T.transform = transform
	return T

/turf/simulated/wall/mineral/plastitanium/copyTurf(turf/T)
	. = ..()
	T.transform = transform
