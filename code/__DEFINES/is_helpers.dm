// Atoms
#define isatom(A) (isloc(A))

// Mobs
#define ismegafauna(A) istype(A, /mob/living/simple_animal/hostile/megafauna)

//Simple animals
#define isshade(A) (istype(A, /mob/living/simple_animal/shade))

#define isconstruct(A) (istype(A, /mob/living/simple_animal/hostile/construct))

//Objects
#define isobj(A) istype(A, /obj) //override the byond proc because it returns true on children of /atom/movable that aren't objs

#define isitem(A) (istype(A, /obj/item))

#define ispda(A) (istype(A, /obj/item/pda))

#define ismachinery(A) (istype(A, /obj/machinery))

#define ismecha(A) (istype(A, /obj/mecha))

#define isspacepod(A) (istype(A, /obj/spacepod))

#define iseffect(A) (istype(A, /obj/effect))

#define isprojectile(A) (istype(A, /obj/item/projectile))

#define is_cleanable(A) (istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/rune)) //if something is cleanable

#define is_pen(W) (istype(W, /obj/item/pen))

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
	/obj/item/stack/sheet/plastitaniumglass)))

#define is_glass_sheet(O) (is_type_in_typecache(O, GLOB.glass_sheet_types))

//Assembly
#define isassembly(O) (istype(O, /obj/item/assembly))
#define isigniter(O) (istype(O, /obj/item/assembly/igniter))
#define isinfared(O) (istype(O, /obj/item/assembly/infra))
#define isprox(O) (istype(O, /obj/item/assembly/prox_sensor))
#define issignaler(O) (istype(O, /obj/item/assembly/signaler))
#define istimer(O) (istype(O, /obj/item/assembly/timer))


//Turfs
#define issimulatedturf(A) istype(A, /turf/simulated)

#define isspaceturf(A) istype(A, /turf/space)

#define isfloorturf(A) istype(A, /turf/simulated/floor)

#define iswallturf(A) istype(A, /turf/simulated/wall)

#define isreinforcedwallturf(A) istype(A, /turf/simulated/wall/r_wall)

#define ismineralturf(A) istype(A, /turf/simulated/mineral)

#define isancientturf(A) istype(A, /turf/simulated/mineral/ancient)

#define islava(A) (istype(A, /turf/simulated/floor/plating/lava))

#define ischasm(A) (istype(A, /turf/simulated/floor/chasm))

//Mobs
#define isliving(A) (istype(A, /mob/living))

#define isbrain(A) (istype(A, /mob/living/carbon/brain))

//Carbon mobs
#define iscarbon(A) (istype(A, /mob/living/carbon))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

//Human sub-species
#define isshadowling(A) (is_species(A, /datum/species/shadow/ling))
#define isshadowlinglesser(A) (is_species(A, /datum/species/shadow/ling/lesser))
#define isabductor(A) (is_species(A, /datum/species/abductor))
#define isgolem(A) (is_species(A, /datum/species/golem))
#define ismonkeybasic(A) (is_species(A, /datum/species/monkey))
#define isfarwa(A) (is_species(A, /datum/species/monkey/tajaran))
#define iswolpin(A) (is_species(A, /datum/species/monkey/vulpkanin))
#define isneara(A) (is_species(A, /datum/species/monkey/skrell))
#define isstok(A) (is_species(A, /datum/species/monkey/unathi))
#define isplasmaman(A) (is_species(A, /datum/species/plasmaman))
#define isshadowperson(A) (is_species(A, /datum/species/shadow))
#define isskeleton(A) (is_species(A, /datum/species/skeleton))
#define ishumanbasic(A) (is_species(A, /datum/species/human))
#define isunathi(A) (is_species(A, /datum/species/unathi))
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

//more carbon mobs
#define isalien(A) (istype(A, /mob/living/carbon/alien))

#define islarva(A) (istype(A, /mob/living/carbon/alien/larva))

#define isalienadult(A) (istype(A, /mob/living/carbon/alien/humanoid))

#define isalienhunter(A) (istype(A, /mob/living/carbon/alien/humanoid/hunter))

#define isaliensentinel(A) (istype(A, /mob/living/carbon/alien/humanoid/sentinel))

#define isslime(A)		(istype((A), /mob/living/simple_animal/slime))

#define issimplemob(A)		(istype((A), /mob/living/simple_animal))

//Simple animals
#define isanimal(A)		(istype((A), /mob/living/simple_animal))
#define isdog(A)		(istype((A), /mob/living/simple_animal/pet/dog))
#define iscorgi(A)		(istype((A), /mob/living/simple_animal/pet/dog/corgi))
#define ismouse(A)		(istype((A), /mob/living/simple_animal/mouse))
#define isbot(A)		(istype((A), /mob/living/simple_animal/bot))
#define isswarmer(A)	(istype((A), /mob/living/simple_animal/hostile/swarmer))
#define isguardian(A)	(istype((A), /mob/living/simple_animal/hostile/guardian))
#define isnymph(A)      (istype((A), /mob/living/simple_animal/diona))
#define ishostile(A) 	(istype(A, /mob/living/simple_animal/hostile))
#define isterrorspider(A) (istype((A), /mob/living/simple_animal/hostile/poison/terror_spider))

//Silicon mobs
#define issilicon(A)	(istype((A), /mob/living/silicon))
#define isAI(A)			(istype((A), /mob/living/silicon/ai))
#define isrobot(A)		(istype((A), /mob/living/silicon/robot))
#define ispAI(A)		(istype((A), /mob/living/silicon/pai))
#define isdrone(A)		(istype((A), /mob/living/silicon/robot/drone))
#define iscogscarab(A)	(istype((A), /mob/living/silicon/robot/cogscarab))

//For tools

#define gettoolspeedmod(A) (ishuman(A) ? A.dna.species.toolspeedmod : 1)

//For the tcomms monitor
#define ispathhuman(A)		(ispath(A, /mob/living/carbon/human))
#define ispathbrain(A)		(ispath(A, /mob/living/carbon/brain))
#define ispathslime(A)		(ispath(A, /mob/living/simple_animal/slime))
#define ispathbot(A)			(ispath(A, /mob/living/simple_animal/bot))
#define ispathsilicon(A)	(ispath(A, /mob/living/silicon))
#define ispathanimal(A)		(ispath(A, /mob/living/simple_animal))

#define isAutoAnnouncer(A)	(istype((A), /mob/living/automatedannouncer))

#define isAIEye(A)		(istype((A), /mob/camera/aiEye))
#define isovermind(A)	(istype((A), /mob/camera/blob))

#define isSpirit(A)		(istype((A), /mob/spirit))
#define ismask(A)		(istype((A), /mob/spirit/mask))

#define isobserver(A)	(istype((A), /mob/dead/observer))

#define isnewplayer(A)  (istype((A), /mob/new_player))

#define isorgan(A)		(istype((A), /obj/item/organ/external))
#define hasorgans(A)	(ishuman(A))

#define is_admin(user)	(check_rights(R_ADMIN, 0, (user)) != 0)

#define SLEEP_CHECK_DEATH(X) sleep(X); if(QDELETED(src) || stat == DEAD) return;

//Locations
#define is_ventcrawling(A)  (istype(A.loc, /obj/machinery/atmospherics))

//Structures
#define isstructure(A)	(istype((A), /obj/structure))

// Misc
#define isclient(A) istype(A, /client)
#define isradio(A) istype(A, /obj/item/radio)
#define ispill(A) istype(A, /obj/item/reagent_containers/food/pill)

