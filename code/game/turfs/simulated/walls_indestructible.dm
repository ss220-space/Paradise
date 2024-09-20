/turf/simulated/wall/indestructible
	name = "wall"
	desc = "Effectively impervious to conventional methods of destruction."
	explosion_block = 50
	explosion_vertical_block = 50
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	smooth = NONE


/turf/simulated/wall/indestructible/dismantle_wall(devastated = 0, explode = 0)
	return

/turf/simulated/wall/indestructible/take_damage(dam)
	return

/turf/simulated/wall/indestructible/welder_act()
	return

/turf/simulated/wall/indestructible/ex_act(severity)
	return

/turf/simulated/wall/indestructible/blob_act(obj/structure/blob/B)
	return

/turf/simulated/wall/indestructible/singularity_act()
	return

/turf/simulated/wall/indestructible/singularity_pull(S, current_size)
	return

/turf/simulated/wall/indestructible/narsie_act()
	return

/turf/simulated/wall/indestructible/ratvar_act()
	return

/turf/simulated/wall/indestructible/burn_down()
	return


/turf/simulated/wall/indestructible/attackby(obj/item/I, mob/user, params)
	return ATTACK_CHAIN_BLOCKED_ALL


/turf/simulated/wall/indestructible/attack_hand(mob/user)
	return

/turf/simulated/wall/indestructible/attack_animal(mob/living/simple_animal/M)
	return

/turf/simulated/wall/indestructible/mech_melee_attack(obj/mecha/M)
	return

/turf/simulated/wall/indestructible/rpd_act()
	return

/turf/simulated/wall/indestructible/acid_act(acidpwr, acid_volume, acid_id)
	return

/turf/simulated/wall/indestructible/try_decon(obj/item/I, mob/user, params)
	return

/turf/simulated/wall/indestructible/rcd_deconstruct_act()
	return RCD_NO_ACT

/turf/simulated/wall/indestructible/thermitemelt(mob/user, time)
	return

/turf/simulated/wall/indestructible/fakeglass
	name = "window"
	icon = 'icons/turf/walls/fake_glass.dmi'
	icon_state = "fake_glass"
	base_icon_state = "fake_glass"
	opacity = FALSE
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE

/turf/simulated/wall/indestructible/reinforced
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "r_wall-0"
	base_icon_state = "r_wall"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_WALLS


/turf/simulated/wall/indestructible/reinforced/rusted
	name = "rusted reinforced wall"
	desc = "A huge chunk of rusted reinforced metal."
	icon = 'icons/turf/walls/rusty_reinforced_wall.dmi'
	icon_state = "rusty_reinforced_wall-0"
	base_icon_state = "rusty_reinforced_wall"


/turf/simulated/wall/indestructible/wood
	name = "wooden wall"
	desc = "A wall with wooden plating against any method of destruction. Very stiff."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood_wall-0"
	base_icon_state = "wood_wall"
	canSmoothWith = SMOOTH_GROUP_WOOD_WALLS
	smoothing_groups = SMOOTH_GROUP_WOOD_WALLS
	smooth = SMOOTH_BITMASK

/turf/simulated/wall/indestructible/necropolis
	name = "necropolis wall"
	desc = "A seemingly impenetrable wall."
	icon = 'icons/turf/walls.dmi'
	icon_state = "necro"
	explosion_block = 50
	baseturf = /turf/simulated/wall/indestructible/necropolis

/turf/simulated/wall/indestructible/boss
	name = "necropolis wall"
	desc = "A thick, seemingly indestructible stone wall."
	icon = 'icons/turf/walls/boss_wall.dmi'
	icon_state = "wall"
	canSmoothWith = SMOOTH_GROUP_BOSS_WALLS
	explosion_block = 50
	baseturf = /turf/simulated/floor/plating/asteroid/basalt
	smooth = SMOOTH_BITMASK
	base_icon_state = "boss_wall"
	smoothing_groups = SMOOTH_GROUP_BOSS_WALLS

/turf/simulated/wall/indestructible/boss/see_through
	opacity = FALSE

/turf/simulated/wall/indestructible/hierophant
	name = "wall"
	desc = "A wall made out of a strange metal. The squares on it pulse in a predictable pattern."
	icon = 'icons/turf/walls/hierophant_wall.dmi'
	icon_state = "wall"
	base_icon_state = "hierophant_wall"
	smooth = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_HIERO_WALL
	canSmoothWith = SMOOTH_GROUP_HIERO_WALL

/turf/simulated/wall/indestructible/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium"
	base_icon_state = "uranium_wall"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_URANIUM_WALLS
	smoothing_groups = SMOOTH_GROUP_URANIUM_WALLS

/turf/simulated/wall/indestructible/metal
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall"
	base_icon_state = "wall"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_WALLS
	smoothing_groups = SMOOTH_GROUP_WALLS


/turf/simulated/wall/indestructible/abductor
	name = "alien wall"
	desc = "A wall with alien alloy plating."
	icon_state = "alien1"
	always_lit = TRUE
	smooth = NONE //Already smoothed by dear mappers


/turf/simulated/wall/indestructible/splashscreen
	name = "Splash Screen"
	icon = 'config/title_screens/images/blank.png'
	icon_state = ""
	plane = SPLASHSCREEN_PLANE
	layer = SPLASHSCREEN_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// Pixel shifts below are needed to centrally position the black icon within the start area at compile-time. This icon used as a background for title screens with smaller resolutions than required.
	pixel_x = -288
	pixel_y = -224
	/// Currently used screen. Defined in SStitle.
	var/obj/effect/abstract/current_screen

/turf/simulated/wall/indestructible/snow
	name = "snow wall"
	icon = 'icons/turf/walls/snow_wall.dmi'
	icon_state = "snow"
	base_icon_state = "snow_wall"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_WALLS_SNOW
	smoothing_groups = SMOOTH_GROUP_WALLS_SNOW

/turf/simulated/wall/indestructible/gingerbread
	name = "gingerbread wall"
	icon = 'icons/turf/walls/gingerbread_wall.dmi'
	icon_state = "gingerbread"
	base_icon_state = "gingerbread_wall"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_WALL_GINGERBREAD
	smoothing_groups = SMOOTH_GROUP_WALL_GINGERBREAD


/turf/simulated/wall/indestructible/rock
	name = "rock"
	icon_state = "rock"
	smooth = NONE


/turf/simulated/wall/indestructible/rock/dark
	color = "#91857C"


/turf/simulated/wall/indestructible/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon = 'icons/turf/walls/sandstone_wall.dmi'
	icon_state = "sandstone"
	base_icon_state = "sandstone_wall"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_SANDSTONE_WALLS
	smoothing_groups = SMOOTH_GROUP_SANDSTONE_WALLS


/turf/simulated/wall/indestructible/iron
	name = "rough metal wall"
	desc = "A wall with rough metal plating."
	icon = 'icons/turf/walls/iron_wall.dmi'
	icon_state = "iron"
	base_icon_state = "iron_wall"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_WALLS
	smoothing_groups = SMOOTH_GROUP_WALLS


/turf/simulated/wall/indestructible/bananium
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon = 'icons/turf/walls/bananium_wall.dmi'
	icon_state = "bananium"
	base_icon_state = "bananium_wall"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_BANANIUM_WALLS
	smoothing_groups = SMOOTH_GROUP_BANANIUM_WALLS


/turf/simulated/wall/indestructible/cult
	name = "runed metal wall"
	desc = "A cold metal wall engraved with indecipherable symbols. Studying them causes your head to pound."
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_CULT_WALLS
	smoothing_groups = SMOOTH_GROUP_CULT_WALLS


/turf/simulated/wall/indestructible/mineral_rock
	name = "rock"
	icon = 'icons/turf/smoothrocks.dmi'
	icon_state = "smoothrocks-0"
	base_icon_state = "smoothrocks"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_MINERAL_WALLS
	smoothing_groups = SMOOTH_GROUP_MINERAL_WALLS

/turf/simulated/wall/indestructible/mineral_rock/Initialize(mapload)
	var/matrix/M = new
	//M.Translate(-4, -4)
	transform = M
	. = ..()


/turf/simulated/wall/indestructible/invisible
	name = "Deep space"
	desc = "Deep space nothing"
	icon = null
	icon_state = null

// used with /effect/view_portal in order to get rid of dynamic lighting.
/turf/simulated/wall/indestructible/invisible/view_portal
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	always_lit = TRUE
