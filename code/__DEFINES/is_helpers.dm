// simple is_type and similar inline helpers
#define in_range(source, user) (get_dist(source, user) <= 1 && (get_step(source, 0)?:z) == (get_step(user, 0)?:z))

/// Within given range, but not counting z-levels
#define IN_GIVEN_RANGE(source, other, given_range) (get_dist(source, other) <= given_range && (get_step(source, 0)?:z) == (get_step(other, 0)?:z))

// Atoms
#define isatom(A) (isloc(A))

#define isdatum(thing) (istype(thing, /datum))

#define is_screen_atom(A) istype(A, /atom/movable/screen)

#define isweakref(D) (istype(D, /datum/weakref))

// Mobs

#define ismegafauna(A) istype(A, /mob/living/simple_animal/hostile/megafauna)

#define isliving(A) (istype(A, /mob/living))

#define isbrain(A) (istype(A, /mob/living/carbon/brain))

// basic mobs
#define isbasicmob(A) (istype(A, /mob/living/basic))

// Carbon mobs
#define iscarbon(A) (istype(A, /mob/living/carbon))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

#define isalien(A) (istype(A, /mob/living/carbon/alien))

#define isdevil(A) (istype(A, /mob/living/carbon/true_devil))

#define isascendeddevil(A) (istype(A, /mob/living/carbon/true_devil/ascended))

#define islarva(A) (istype(A, /mob/living/carbon/alien/larva))

#define isalienadult(A) (istype(A, /mob/living/carbon/alien/humanoid))

#define isalienhunter(A) (istype(A, /mob/living/carbon/alien/humanoid/hunter))

#define isaliensentinel(A) (istype(A, /mob/living/carbon/alien/humanoid/sentinel))

#define isalienqueen(A) (istype(A, /mob/living/carbon/alien/humanoid/queen))
#define isfacehugger(A) (istype(A, /mob/living/simple_animal/hostile/facehugger))
#define isfacehugger_mask(A) (istype(A, /obj/item/clothing/mask/facehugger) && !istype(A, /obj/item/clothing/mask/facehugger/toy))

// Simple animals
// #define issimple_animal(A) (istype(A, /mob/living/simple_animal)) use isanimal(A) instead

#define isshade(A) (istype(A, /mob/living/simple_animal/shade))

#define isconstruct(A) (istype(A, /mob/living/simple_animal/hostile/construct))

#define isslime(A) (istype((A), /mob/living/simple_animal/slime))

#define ispulsedemon(A) (istype(A, /mob/living/simple_animal/demon/pulse_demon))

#define isvampireanimal(A) (istype((A), /mob/living/simple_animal/hostile/vampire))

// Objects
#define isobj(A) istype(A, /obj) //override the byond proc because it returns true on children of /atom/movable that aren't objs

#define isitem(A) (istype(A, /obj/item))

#define isstack(A) (istype(A, /obj/item/stack))

#define isstorage(A) (istype(A, /obj/item/storage))

#define isgrenade(A) (istype(A, /obj/item/grenade))

#define issupplypod(A) (istype(A, /obj/structure/closet/supplypod))

#define ismortarcasing(A) (istype(A, /obj/item/mortar_shell))

#define isammocasing(A) (istype(A, /obj/item/ammo_casing))

#define ismachinery(A) (istype(A, /obj/machinery))

#define isapc(A) (istype(A, /obj/machinery/power/apc))

#define ismecha(A) (istype(A, /obj/mecha))

#define isvampirecoffin(A) (istype(A, /obj/structure/closet/coffin/vampire))

#define isspacepod(A) (istype(A, /obj/spacepod))

#define iseffect(A) (istype(A, /obj/effect))

#define isvehicle(A) (istype(A, /obj/vehicle))

#define isprojectile(A) (istype(A, /obj/projectile))

#define isgun(A) (istype(A, /obj/item/gun))

#define isbaton(A) (istype(A, /obj/item/melee/baton))

#define is_pen(W) (istype(W, /obj/item/pen))

#define is_pda(W) (istype(W, /obj/item/pda))

#define is_id_card(W) (istype(W, /obj/item/card/id))

#define isradio(A) istype(A, /obj/item/radio)

#define isflower(A) istype(A, /obj/item/twohanded/required/kirbyplants)

#define isclothing(A) (istype(A, /obj/item/clothing))

#define is_internal_organ(A) istype(A, /obj/item/organ/internal)

#define	is_organ(A)			istype((A), /obj/item/organ)

#define isbluespacecrystal(A) istype(A, /obj/item/stack/ore/bluespace_crystal)

#define issyringe(A) istype(A, /obj/item/reagent_containers/syringe)

#define isglassreagentcontainer(A) istype(A, /obj/item/reagent_containers/glass)

GLOBAL_LIST_INIT(pointed_types, typecacheof(list(
	/obj/item/pen,
	/obj/item/screwdriver,
	/obj/item/reagent_containers/syringe,
	/obj/item/kitchen/utensil/fork)))

#define is_pointed(W) (is_type_in_typecache(W, GLOB.pointed_types))

GLOBAL_LIST_INIT(glass_sheet_types, typecacheof(list(
	/obj/item/stack/sheet/glass,
	/obj/item/stack/sheet/rglass,
	/obj/item/stack/sheet/plasmaglass,
	/obj/item/stack/sheet/plasmarglass,
	/obj/item/stack/sheet/titaniumglass,
	/obj/item/stack/sheet/plastitaniumglass,
	/obj/item/stack/sheet/abductorglass)))

#define is_glass_sheet(O) (is_type_in_typecache(O, GLOB.glass_sheet_types))

// Assembly
#define isassembly(O) (istype(O, /obj/item/assembly))
#define isigniter(O) (istype(O, /obj/item/assembly/igniter))
#define isinfared(O) (istype(O, /obj/item/assembly/infra))
#define isprox(O) (istype(O, /obj/item/assembly/prox_sensor))
#define issignaler(O) (istype(O, /obj/item/assembly/signaler))
#define istimer(O) (istype(O, /obj/item/assembly/timer))
#define iscoret1(O) (istype(O, /obj/item/assembly/signaler/core) && O.tier == 1)
#define iscoret2(O) (istype(O, /obj/item/assembly/signaler/core) && O.tier == 2)
#define iscoret3(O) (istype(O, /obj/item/assembly/signaler/core) && O.tier == 3)
#define iscell(O) (istype(O, /obj/item/stock_parts/cell)) // Not assembly, but neaely.


//Turfs
#define issimulatedturf(A) istype(A, /turf/simulated)

#define isspaceturf(A) istype(A, /turf/space)

#define isopenspaceturf(A) (istype(A, /turf/simulated/openspace) || istype(A, /turf/space/openspace))

#define is_space_or_openspace(A) (isopenspaceturf(A) || isspaceturf(A))

#define isfloorturf(A) istype(A, /turf/simulated/floor)

#define iswallturf(A) istype(A, /turf/simulated/wall)

#define isreinforcedwallturf(A) istype(A, /turf/simulated/wall/r_wall)

#define ismineralturf(A) istype(A, /turf/simulated/mineral)

#define isancientturf(A) istype(A, /turf/simulated/mineral/ancient)

#define islava(A) (istype(A, /turf/simulated/floor/lava))

#define ischasm(A) (istype(A, /turf/simulated/floor/chasm))

#define issingularity(atom) (istype(atom, /obj/singularity))

//Structures
#define isstructure(A) (istype(A, /obj/structure))
#define istable(A) (istype(A, /obj/structure/table))

// Misc
#define isclient(A) istype(A, /client)

#define ispill(A) istype(A, /obj/item/reagent_containers/food/pill)

#define isthrowingmatart(A) istype(A, /datum/martial_art/throwing)

GLOBAL_LIST_INIT(turfs_without_ground, typecacheof(list(
	/turf/space,
	/turf/simulated/floor/chasm,
	/turf/simulated/openspace,
)))

#define isgroundlessturf(A) (is_type_in_typecache(A, GLOB.turfs_without_ground))


#define is_ventcrawler(A) (HAS_TRAIT(A, TRAIT_VENTCRAWLER_NUDE) || HAS_TRAIT(A, TRAIT_VENTCRAWLER_ALWAYS) || HAS_TRAIT(A, TRAIT_VENTCRAWLER_ITEM_BASED) || HAS_TRAIT(A, TRAIT_VENTCRAWLER_ALIEN))

#define is_multi_tile_object(atom) (atom.bound_width > ICON_SIZE_X || atom.bound_height > ICON_SIZE_Y)

#define is_proximity(A) istype(A, /obj/effect/abstract/proximity_checker)

#define is_light(A) istype(A, /atom/movable/lighting_object)

#define ischest(A) (istype(A, /obj/item/organ/external/chest))

#define isgroin(A) (istype(A, /obj/item/organ/external/groin))

/// in some situations we can't rely on dynamic typing and use if(statement)
#define istrue(statement) (statement == TRUE)


#define isbeachwater(A) (istype(A, /turf/simulated/floor/beach/water))
#define isbeachwater_i(A) (istype(A, /turf/simulated/floor/indestructible/beach/water))

#define isanimal(A)		(istype((A), /mob/living/simple_animal) || istype(A, /mob/living/basic))
#define iscat(A)		(istype((A), /mob/living/simple_animal/pet/cat))
#define isdog(A)		(istype((A), /mob/living/simple_animal/pet/dog))
#define iscorgi(A)		(istype((A), /mob/living/simple_animal/pet/dog/corgi))
#define ismouse(A)		(istype((A), /mob/living/simple_animal/mouse))
#define isbot(A)		(istype((A), /mob/living/simple_animal/bot))
#define isswarmer(A)	(istype((A), /mob/living/simple_animal/hostile/swarmer))
#define isguardian(A)	(istype((A), /mob/living/simple_animal/hostile/guardian))
#define isnymph(A)      (istype((A), /mob/living/simple_animal/diona))
#define ishostile(A)	(istype(A, /mob/living/simple_animal/hostile))
#define isterrorspider(A) (istype((A), /mob/living/simple_animal/hostile/poison/terror_spider))
#define isslaughterdemon(A) (istype((A), /mob/living/simple_animal/demon/slaughter))
#define isdemon(A)			(istype((A), /mob/living/simple_animal/demon))
#define ismorph(A)		(istype((A), /mob/living/simple_animal/hostile/morph))
#define isborer(A)		(istype((A), /mob/living/simple_animal/borer))
#define isairmob(A)		(istype(A, /mob/living/simple_animal/hostile/airmob))
#define isancientrobot(A) (istype(A, /mob/living/simple_animal/hostile/megafauna/ancient_robot))
#define isancientrobotleg(A) (istype(A, /mob/living/simple_animal/hostile/ancient_robot_leg))
#define ismarauder(A)	(istype(A, /mob/living/simple_animal/hostile/clockwork/marauder))


#define issilicon(A)	(istype((A), /mob/living/silicon))
#define isAI(A)			(istype((A), /mob/living/silicon/ai))
#define isrobot(A)		(istype((A), /mob/living/silicon/robot))
#define ispAI(A)		(istype((A), /mob/living/silicon/pai))
#define isdrone(A)		(istype((A), /mob/living/silicon/robot/drone))
#define iscogscarab(A)	(istype((A), /mob/living/silicon/robot/cogscarab))

// For the tcomms monitor
#define ispathhuman(A)		(ispath(A, /mob/living/carbon/human))
#define ispathbrain(A)		(ispath(A, /mob/living/carbon/brain))
#define ispathslime(A)		(ispath(A, /mob/living/simple_animal/slime))
#define ispathbot(A)			(ispath(A, /mob/living/simple_animal/bot))
#define ispathsilicon(A)	(ispath(A, /mob/living/silicon))
#define ispathanimal(A)		(ispath(A, /mob/living/simple_animal))

#define isAIEye(A)		(istype((A), /mob/camera/aiEye))
#define isovermind(A)	(istype((A), /mob/camera/blob))

#define isminion(A)		(istype((A), /mob/living/simple_animal/hostile/blob_minion))
#define isblobbernaut(M) istype((M), /mob/living/simple_animal/hostile/blob_minion/blobbernaut)

#define isSpirit(A)		(istype((A), /mob/spirit))
#define ismask(A)		(istype((A), /mob/spirit/mask))

#define isobserver(A)	(istype((A), /mob/dead/observer))

#define isnewplayer(A)  (istype((A), /mob/new_player))

#define isexternalorgan(A)		(istype((A), /obj/item/organ/external))

#define hasorgans(A)	(iscarbon(A))

#define is_admin(user)	(check_rights(R_ADMIN, 0, (user)) != 0)

#define is_developer(user) (check_rights(R_VIEWRUNTIMES, FALSE, user))

// Locations
#define is_ventcrawling(A)  (istype(A.loc, /obj/machinery/atmospherics))

//Human sub-species
#define isshadowling(A) (is_species(A, /datum/species/shadow/ling))
#define isshadowlinglesser(A) (is_species(A, /datum/species/shadow/ling/lesser))
#define isabductor(A) (is_species(A, /datum/species/abductor))
#define isgolem(A) (is_species(A, /datum/species/golem))
#define isfarwa(A) (is_species(A, /datum/species/monkey/tajaran))
#define iswolpin(A) (is_species(A, /datum/species/monkey/vulpkanin))
#define isneara(A) (is_species(A, /datum/species/monkey/skrell))
#define isstok(A) (is_species(A, /datum/species/monkey/unathi))
#define isplasmaman(A) (is_species(A, /datum/species/plasmaman))
#define isshadowperson(A) (is_species(A, /datum/species/shadow))
#define isskeleton(A) (is_species(A, /datum/species/skeleton))
#define ishumanbasic(A) (is_species(A, /datum/species/human))
#define isunathi(A) (is_species(A, /datum/species/unathi))
#define isashwalker(A) (is_species(A, /datum/species/unathi/ashwalker))
#define isashwalkershaman(A) (is_species(A, /datum/species/unathi/ashwalker/shaman))
#define isdraconid(A) (is_species(A, /datum/species/unathi/draconid))
#define istajaran(A) (is_species(A, /datum/species/tajaran))
#define isvulpkanin(A) (is_species(A, /datum/species/vulpkanin))
#define isskrell(A) (is_species(A, /datum/species/skrell))
#define isvox(A) (is_species(A, /datum/species/vox))
#define isvoxarmalis(A) (is_species(A, /datum/species/vox/armalis))
#define iskidan(A) (is_species(A, /datum/species/kidan))
#define isslimeperson(A) (is_species(A, /datum/species/slime))
#define isnucleation(A) (is_species(A, /datum/species/nucleation))
#define isgrey(A) (is_species(A, /datum/species/grey))
#define isdiona(A) (is_species(A, /datum/species/diona))
#define ismachineperson(A) (is_species(A, /datum/species/machine))
#define isdrask(A) (is_species(A, /datum/species/drask))
#define iswryn(A) (is_species(A, /datum/species/wryn))
#define ismoth(A) (is_species(A, /datum/species/moth))

