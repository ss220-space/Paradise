/* smoothing_flags */
/// Smoothing system in where adjacencies are calculated and used to build an image by mounting each corner at runtime.
#define SMOOTH_CORNERS (1<<0)
/// Smoothing system in where adjacencies are calculated and used to select a pre-baked icon_state, encoded by bitmasking.
#define SMOOTH_BITMASK (1<<1)
/// Atom has diagonal corners, with underlays under them.
#define SMOOTH_DIAGONAL_CORNERS (1<<2)
/// Atom will smooth with the borders of the map.
#define SMOOTH_BORDER (1<<3)
/// Atom is currently queued to smooth.
#define SMOOTH_QUEUED (1<<4)
/// Smooths with objects, and will thus need to scan turfs for contents.
#define SMOOTH_OBJ (1<<5)
/// Uses directional object smoothing, so we care not only about something being on the right turf, but also its direction
/// Changes the meaning of smoothing_junction, instead of representing the directions we are smoothing in
/// it represents the sides of our directional border object that have a neighbor
/// Is incompatible with SMOOTH_CORNERS because border objects don't have corners
#define SMOOTH_BORDER_OBJECT (1<<6)
/// Has a smooth broken sprite, used to decide whether to apply an offset to the broken overlay or not. For /turf/open only.
#define SMOOTH_BROKEN_TURF (1<<7)
/// Has a smooth burnt sprite, used to decide whether to apply an offset to the burnt overlay or not. For /turf/open only.
#define SMOOTH_BURNT_TURF (1<<8)

#define SMOOTH_FALSE	(1 << 9) //not smooth

#define SMOOTH_TRUE		(1 << 10) //smooths with exact specified types or just itself

#define SMOOTH_MORE		(1 << 11) //smooths with all subtypes of specified types or just itself (this value can replace SMOOTH_TRUE)

#define SMOOTH_DIAGONAL	(1 << 12) //if atom should smooth diagonally, this should be present in 'smooth' var

DEFINE_BITFIELD(smoothing_flags, list(
	"SMOOTH_CORNERS" = SMOOTH_CORNERS,
	"SMOOTH_BITMASK" = SMOOTH_BITMASK,
	"SMOOTH_DIAGONAL_CORNERS" = SMOOTH_DIAGONAL_CORNERS,
	"SMOOTH_BORDER" = SMOOTH_BORDER,
	"SMOOTH_QUEUED" = SMOOTH_QUEUED,
	"SMOOTH_OBJ" = SMOOTH_OBJ,
	"SMOOTH_BORDER_OBJECT" = SMOOTH_BORDER_OBJECT,
	"SMOOTH_BROKEN_TURF" = SMOOTH_BROKEN_TURF,
	"SMOOTH_BURNT_TURF" = SMOOTH_BURNT_TURF,
))

/// Components of a smoothing junction
/// Redefinitions of the diagonal directions so they can be stored in one var without conflicts
#define NORTH_JUNCTION NORTH //(1<<0)
#define SOUTH_JUNCTION SOUTH //(1<<1)
#define EAST_JUNCTION EAST  //(1<<2)
#define WEST_JUNCTION WEST  //(1<<3)
#define NORTHEAST_JUNCTION (1<<4)
#define SOUTHEAST_JUNCTION (1<<5)
#define SOUTHWEST_JUNCTION (1<<6)
#define NORTHWEST_JUNCTION (1<<7)

DEFINE_BITFIELD(smoothing_junction, list(
	"NORTH_JUNCTION" = NORTH_JUNCTION,
	"SOUTH_JUNCTION" = SOUTH_JUNCTION,
	"EAST_JUNCTION" = EAST_JUNCTION,
	"WEST_JUNCTION" = WEST_JUNCTION,
	"NORTHEAST_JUNCTION" = NORTHEAST_JUNCTION,
	"SOUTHEAST_JUNCTION" = SOUTHEAST_JUNCTION,
	"SOUTHWEST_JUNCTION" = SOUTHWEST_JUNCTION,
	"NORTHWEST_JUNCTION" = NORTHWEST_JUNCTION,
))

/*smoothing macros*/

#define QUEUE_SMOOTH(thing_to_queue) if(thing_to_queue.smooth & (SMOOTH_CORNERS|SMOOTH_BITMASK)) {SSicon_smooth.add_to_queue(thing_to_queue)}

#define QUEUE_SMOOTH_NEIGHBORS(thing_to_queue) for(var/atom/atom_neighbor as anything in orange(1, thing_to_queue)) {QUEUE_SMOOTH(atom_neighbor)}

/**SMOOTHING GROUPS
 * Groups of things to smooth with.
 * * Contained in the `list/smoothing_groups` variable.
 * * Matched with the `list/canSmoothWith` variable to check whether smoothing is possible or not.
 * Note: May not represent real smoothing groups (Porting issue, refactor later)
 */

#define S_TURF(num) (#num + ",")

/* /turf only */

#define SMOOTH_GROUP_FLOOR S_TURF(0) ///turf/simulated/floor
#define SMOOTH_GROUP_TURF_CHASM S_TURF(1) ///turf/simulated/chasm, /turf/simulated/floor/fakepit
#define SMOOTH_GROUP_FLOOR_LAVA S_TURF(2) ///turf/simulated/lava/smooth
#define SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS S_TURF(3) ///turf/simulated/floor/glass

#define SMOOTH_GROUP_OPEN_FLOOR S_TURF(4) ///turf/simulated/floor

#define SMOOTH_GROUP_FLOOR_GRASS S_TURF(5) ///turf/simulated/misc/grass
#define SMOOTH_GROUP_FLOOR_ASH S_TURF(6) ///turf/simulated/misc/ashplanet/ash
#define SMOOTH_GROUP_FLOOR_ASH_ROCKY S_TURF(7) ///turf/simulated/misc/ashplanet/rocky
#define SMOOTH_GROUP_FLOOR_ICE S_TURF(8) ///turf/simulated/misc/ice
#define SMOOTH_GROUP_FLOOR_SNOWED S_TURF(9) ///turf/simulated/floor/plating/snowed

#define SMOOTH_GROUP_CARPET S_TURF(10) ///turf/simulated/floor/carpet
#define SMOOTH_GROUP_CARPET_BLACK S_TURF(11) ///turf/simulated/floor/carpet/black
#define SMOOTH_GROUP_CARPET_BLUE S_TURF(12) ///turf/simulated/floor/carpet/blue
#define SMOOTH_GROUP_CARPET_CYAN S_TURF(13) ///turf/simulated/floor/carpet/cyan
#define SMOOTH_GROUP_CARPET_GREEN S_TURF(14) ///turf/simulated/floor/carpet/green
#define SMOOTH_GROUP_CARPET_ORANGE S_TURF(15) ///turf/simulated/floor/carpet/orange
#define SMOOTH_GROUP_CARPET_PURPLE S_TURF(16) ///turf/simulated/floor/carpet/purple
#define SMOOTH_GROUP_CARPET_RED S_TURF(17) ///turf/simulated/floor/carpet/red
#define SMOOTH_GROUP_CARPET_ROYAL_BLACK S_TURF(18) ///turf/simulated/floor/carpet/royalblack
#define SMOOTH_GROUP_CARPET_ROYAL_BLUE S_TURF(19) ///turf/simulated/floor/carpet/royalblue
#define SMOOTH_GROUP_CARPET_EXECUTIVE S_TURF(20) ///turf/simulated/floor/carpet/executive
#define SMOOTH_GROUP_CARPET_STELLAR S_TURF(21) ///turf/simulated/floor/carpet/stellar
#define SMOOTH_GROUP_CARPET_DONK S_TURF(22) ///turf/simulated/floor/carpet/donk
#define SMOOTH_GROUP_CARPET_NEON S_TURF(23) //![turf/simulated/floor/carpet/neon]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON S_TURF(24) //![turf/simulated/floor/carpet/neon/simple]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_WHITE S_TURF(25) //![turf/simulated/floor/carpet/neon/simple/white]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLACK S_TURF(26) //![turf/simulated/floor/carpet/neon/simple/black]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_RED S_TURF(27) //![turf/simulated/floor/carpet/neon/simple/red]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_ORANGE S_TURF(28) //![turf/simulated/floor/carpet/neon/simple/orange]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_YELLOW S_TURF(29) //![turf/simulated/floor/carpet/neon/simple/yellow]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_LIME S_TURF(30) //![turf/simulated/floor/carpet/neon/simple/lime]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_GREEN S_TURF(31) //![turf/simulated/floor/carpet/neon/simple/green]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_TEAL S_TURF(32) //![turf/simulated/floor/carpet/neon/simple/teal]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_CYAN S_TURF(33) //![turf/simulated/floor/carpet/neon/simple/cyan]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLUE S_TURF(34) //![turf/simulated/floor/carpet/neon/simple/blue]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_PURPLE S_TURF(35) //![turf/simulated/floor/carpet/neon/simple/purple]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_VIOLET S_TURF(36) //![turf/simulated/floor/carpet/neon/simple/violet]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_PINK S_TURF(37) //![turf/simulated/floor/carpet/neon/simple/pink]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_NODOTS S_TURF(38) //![turf/simulated/floor/carpet/neon/simple/nodots]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_WHITE_NODOTS S_TURF(39) //![turf/simulated/floor/carpet/neon/simple/white/nodots]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLACK_NODOTS S_TURF(40) //![turf/simulated/floor/carpet/neon/simple/black/nodots]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_RED_NODOTS S_TURF(41) //![turf/simulated/floor/carpet/neon/simple/red/nodots]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_ORANGE_NODOTS S_TURF(42) //![turf/simulated/floor/carpet/neon/simple/orange/nodots]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_YELLOW_NODOTS S_TURF(43) //![turf/simulated/floor/carpet/neon/simple/yellow/nodots]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_LIME_NODOTS S_TURF(44) //![turf/simulated/floor/carpet/neon/simple/lime/nodots]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_GREEN_NODOTS S_TURF(45) //![turf/simulated/floor/carpet/neon/simple/green/nodots]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_TEAL_NODOTS S_TURF(46) //![turf/simulated/floor/carpet/neon/simple/teal/nodots]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_CYAN_NODOTS S_TURF(47) //![turf/simulated/floor/carpet/neon/simple/cyan/nodots]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLUE_NODOTS S_TURF(48) //![turf/simulated/floor/carpet/neon/simple/blue/nodots]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_PURPLE_NODOTS S_TURF(49) //![turf/simulated/floor/carpet/neon/simple/purple/nodots]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_VIOLET_NODOTS S_TURF(50) //![turf/simulated/floor/carpet/neon/simple/violet/nodots]
#define SMOOTH_GROUP_CARPET_SIMPLE_NEON_PINK_NODOTS S_TURF(51) //![turf/simulated/floor/carpet/neon/simple/pink/nodots]
#define SMOOTH_GROUP_BAMBOO_FLOOR S_TURF(52) //![/turf/simulated/floor/bamboo]

#define SMOOTH_GROUP_CLOSED_TURFS S_TURF(53) ///turf/closed
#define SMOOTH_GROUP_MATERIAL_WALLS S_TURF(54) ///turf/simulated/wall/material
#define SMOOTH_GROUP_SYNDICATE_WALLS S_TURF(55) ///turf/simulated/wall/r_wall/syndicate, /turf/closed/indestructible/syndicate
#define SMOOTH_GROUP_HOTEL_WALLS S_TURF(56) ///turf/closed/indestructible/hotelwall
#define SMOOTH_GROUP_MINERAL_WALLS S_TURF(57) ///turf/closed/mineral, /turf/closed/indestructible
#define SMOOTH_GROUP_BOSS_WALLS S_TURF(58) ///turf/closed/indestructible/riveted/boss
#define SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS S_TURF(59) ///turf/simulated/wall/mineral/titanium/survival
#define SMOOTH_GROUP_FLOOR_CLIFF S_TURF(60) ///turf/simulated/cliff

#define MAX_S_TURF 60 //Always match this value with the one above it.

#define S_OBJ(num) ("-" + #num + ",")
/* /obj included */

#define SMOOTH_GROUP_WALLS S_OBJ(1) ///turf/simulated/wall, /obj/structure/falsewall
#define SMOOTH_GROUP_URANIUM_WALLS S_OBJ(2) ///turf/simulated/wall/mineral/uranium, /obj/structure/falsewall/uranium
#define SMOOTH_GROUP_GOLD_WALLS S_OBJ(3) ///turf/simulated/wall/mineral/gold, /obj/structure/falsewall/gold
#define SMOOTH_GROUP_SILVER_WALLS S_OBJ(4) ///turf/simulated/wall/mineral/silver, /obj/structure/falsewall/silver
#define SMOOTH_GROUP_DIAMOND_WALLS S_OBJ(5) ///turf/simulated/wall/mineral/diamond, /obj/structure/falsewall/diamond
#define SMOOTH_GROUP_PLASMA_WALLS S_OBJ(6) ///turf/simulated/wall/mineral/plasma, /obj/structure/falsewall/plasma
#define SMOOTH_GROUP_BANANIUM_WALLS S_OBJ(7) ///turf/simulated/wall/mineral/bananium, /obj/structure/falsewall/bananium
#define SMOOTH_GROUP_SANDSTONE_WALLS S_OBJ(8) ///turf/simulated/wall/mineral/sandstone, /obj/structure/falsewall/sandstone
#define SMOOTH_GROUP_WOOD_WALLS S_OBJ(9) ///turf/simulated/wall/mineral/wood, /obj/structure/falsewall/wood
#define SMOOTH_GROUP_IRON_WALLS S_OBJ(10) ///turf/simulated/wall/mineral/iron, /obj/structure/falsewall/iron
#define SMOOTH_GROUP_ABDUCTOR_WALLS S_OBJ(11) ///turf/simulated/wall/mineral/abductor, /obj/structure/falsewall/abductor
#define SMOOTH_GROUP_TITANIUM_WALLS S_OBJ(12) ///turf/simulated/wall/mineral/titanium, /obj/structure/falsewall/titanium
#define SMOOTH_GROUP_PLASTITANIUM_WALLS S_OBJ(14) ///turf/simulated/wall/mineral/plastitanium, /obj/structure/falsewall/plastitanium
#define SMOOTH_GROUP_SURVIVAL_TITANIUM_POD S_OBJ(15) ///turf/simulated/wall/mineral/titanium/survival/pod, /obj/machinery/door/airlock/survival_pod, /obj/structure/window/reinforced/shuttle/survival_pod
#define SMOOTH_GROUP_HIERO_WALL S_OBJ(16) ///obj/effect/temp_visual/elite_tumor_wall, /obj/effect/temp_visual/hierophant/wall
#define SMOOTH_GROUP_BAMBOO_WALLS S_OBJ(17) //![/turf/simulated/wall/mineral/bamboo, /obj/structure/falsewall/bamboo]
#define SMOOTH_GROUP_PLASTINUM_WALLS S_OBJ(18) //![turf/closed/indestructible/riveted/plastinum]
#define SMOOTH_GROUP_HIERO_FLOOR S_OBJ(19)
#define SMOOTH_GROUP_HIERO_VORTEX S_OBJ(20)


#define SMOOTH_GROUP_PAPERFRAME S_OBJ(21) ///obj/structure/window/paperframe, /obj/structure/mineral_door/paperframe

#define SMOOTH_GROUP_WINDOW_FULLTILE S_OBJ(22) ///turf/closed/indestructible/fakeglass, /obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile, /obj/structure/window/plasma/fulltile, /obj/structure/window/reinforced/plasma/fulltile
#define SMOOTH_GROUP_WINDOW_FULLTILE_BRONZE S_OBJ(23) ///obj/structure/window/bronze/fulltile
#define SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM S_OBJ(24) ///turf/closed/indestructible/opsglass, /obj/structure/window/reinforced/plasma/plastitanium
#define SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE S_OBJ(25) ///obj/structure/window/reinforced/shuttle

#define SMOOTH_GROUP_LATTICE S_OBJ(31) ///obj/structure/lattice
#define SMOOTH_GROUP_CATWALK S_OBJ(32) ///obj/structure/lattice/catwalk

#define SMOOTH_GROUP_AIRLOCK S_OBJ(41) ///obj/machinery/door/airlock

#define SMOOTH_GROUP_INDUSTRIAL_LIFT S_OBJ(46) ///obj/structure/transport/linear
#define SMOOTH_GROUP_TRAM_STRUCTURE S_OBJ(47) //obj/structure/tram

#define SMOOTH_GROUP_TABLES S_OBJ(51) ///obj/structure/table
#define SMOOTH_GROUP_WOOD_TABLES S_OBJ(52) ///obj/structure/table/wood
#define SMOOTH_GROUP_FANCY_WOOD_TABLES S_OBJ(53) ///obj/structure/table/wood/fancy
#define SMOOTH_GROUP_BRONZE_TABLES S_OBJ(54) ///obj/structure/table/bronze
#define SMOOTH_GROUP_ABDUCTOR_TABLES S_OBJ(55) ///obj/structure/table/abductor
#define SMOOTH_GROUP_GLASS_TABLES S_OBJ(56) ///obj/structure/table/glass

#define SMOOTH_GROUP_ALIEN_NEST S_OBJ(60) ///obj/structure/bed/nest
#define SMOOTH_GROUP_ALIEN_RESIN S_OBJ(61) ///obj/structure/alien/resin
#define SMOOTH_GROUP_ALIEN_WALLS S_OBJ(62) ///obj/structure/alien/resin/wall, /obj/structure/alien/resin/membrane
#define SMOOTH_GROUP_ALIEN_WEEDS S_OBJ(63) ///obj/structure/alien/weeds

#define SMOOTH_GROUP_SECURITY_BARRICADE S_OBJ(64) ///obj/structure/barricade/security
#define SMOOTH_GROUP_SANDBAGS S_OBJ(65) ///obj/structure/barricade/sandbags

#define SMOOTH_GROUP_HEDGE_FLUFF S_OBJ(66) ///obj/structure/hedge

#define SMOOTH_GROUP_SHUTTLE_PARTS S_OBJ(67) ///obj/structure/window/reinforced/shuttle, /obj/structure/window/reinforced/plasma/plastitanium, /turf/closed/indestructible/opsglass, /obj/machinery/power/shuttle_engine

#define SMOOTH_GROUP_CLEANABLE_DIRT S_OBJ(68) ///obj/effect/decal/cleanable/dirt

#define SMOOTH_GROUP_GAS_TANK S_OBJ(69)

#define SMOOTH_GROUP_SPIDER_WEB S_OBJ(70) // /obj/structure/spider/stickyweb
#define SMOOTH_GROUP_SPIDER_WEB_WALL S_OBJ(71) // /obj/structure/spider/stickyweb/sealed
#define SMOOTH_GROUP_SPIDER_WEB_ROOF S_OBJ(72) // /obj/structure/spider/passage
#define SMOOTH_GROUP_SPIDER_WEB_WALL_TOUGH S_OBJ(73) // /obj/structure/spider/stickyweb/sealed/thick
#define SMOOTH_GROUP_SPIDER_WEB_WALL_MIRROR S_OBJ(74) // /obj/structure/spider/stickyweb/sealed/reflector
#define SMOOTH_GROUP_FILLER S_OBJ(75) // /obj/structure/filler
#define SMOOTH_GROUP_WALL_GINGERBREAD S_OBJ(76) // /obj/structure/filler
#define SMOOTH_GROUP_WRYN_WAX S_OBJ(77) // /obj/structure/wryn/wax/wall
#define SMOOTH_GROUP_WRYN_WAX_WALL S_OBJ(78) // /obj/structure/wryn/wax/wall
#define SMOOTH_GROUP_WRYN_WAX_WINDOW S_OBJ(79) // /obj/structure/wryn/wax/window
#define SMOOTH_GROUP_BEACH S_OBJ(80)
#define SMOOTH_GROUP_WALLS_SNOW S_OBJ(81)
#define SMOOTH_GROUP_CLOCKWORK_WALLS S_OBJ(82)
#define SMOOTH_GROUP_RIPPLE S_OBJ(83)
#define SMOOTH_GROUP_CULT_WALLS S_OBJ(84)
#define SMOOTH_GROUP_TRANSPARENT_FLOOR S_OBJ(85)

/// Performs the work to set smoothing_groups and canSmoothWith.
/// An inlined function used in both turf/Initialize and atom/Initialize.
/// TODO: RETURN TESTS WHEN THEY ARE READY
#define SETUP_SMOOTHING(...) \
	if (smoothing_groups) { \
		SET_SMOOTHING_GROUPS(smoothing_groups); \
	} \
\
	if (canSmoothWith) { \
		/* S_OBJ is always negative, and we are guaranteed to be sorted. */ \
		if (canSmoothWith[1] == "-") { \
			smooth |= SMOOTH_OBJ; \
		} \
		SET_SMOOTHING_GROUPS(canSmoothWith); \
	}

/// Given a smoothing groups variable, will set out to the actual numbers inside it
#define UNWRAP_SMOOTHING_GROUPS(smoothing_groups, out) \
	json_decode("\[[##smoothing_groups]0\]"); \
	##out.len--;

#define ASSERT_SORTED_SMOOTHING_GROUPS(smoothing_group_variable) \
	var/list/unwrapped = UNWRAP_SMOOTHING_GROUPS(smoothing_group_variable, unwrapped); \
	assert_sorted(unwrapped, "[#smoothing_group_variable] ([type])"); \
