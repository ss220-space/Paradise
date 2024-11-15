#define ANOMALY_TYPE_RANDOM			"random"
#define ANOMALY_TYPE_ATMOS			"pyroclastic"
#define ANOMALY_TYPE_BLUESPACE		"bluespace"
#define ANOMALY_TYPE_GRAV			"gravitational"
#define ANOMALY_TYPE_VORTEX			"vortex"
#define ANOMALY_TYPE_FLUX			"flux"

#define isanomaly(A)	(istype((A), /obj/effect/anomaly))

#define iscore(A)			(istype((A), /obj/item/assembly/signaler/anomaly))
#define iscoret1(A)			(istype((A), /obj/item/assembly/signaler/anomaly/tier1))
#define iscoret2(A)			(istype((A), /obj/item/assembly/signaler/anomaly/tier2))
#define iscoret3(A)			(istype((A), /obj/item/assembly/signaler/anomaly/tier3))

#define iscoreempty(A)		(type in list(/obj/item/assembly/signaler/anomaly/tier1, /obj/item/assembly/signaler/anomaly/tier2, /obj/item/assembly/signaler/anomaly/tier3))
#define iscoreatmos(A)		(type in list(/obj/item/assembly/signaler/anomaly/tier1/pyro, /obj/item/assembly/signaler/anomaly/tier2/pyro, /obj/item/assembly/signaler/anomaly/tier3/pyro))
#define iscorebluespace(A)	(type in list(/obj/item/assembly/signaler/anomaly/tier1/bluespace, /obj/item/assembly/signaler/anomaly/tier2/bluespace, /obj/item/assembly/signaler/anomaly/tier3/bluespace))
#define iscoregrav(A)		(type in list(/obj/item/assembly/signaler/anomaly/tier1/grav, /obj/item/assembly/signaler/anomaly/tier2/grav, /obj/item/assembly/signaler/anomaly/tier3/grav))
#define iscorevortex(A)		(type in list(/obj/item/assembly/signaler/anomaly/tier1/vortex, /obj/item/assembly/signaler/anomaly/tier2/vortex, /obj/item/assembly/signaler/anomaly/tier3/vortex))
#define iscoreflux(A)		(type in list(/obj/item/assembly/signaler/anomaly/tier1/flux, /obj/item/assembly/signaler/anomaly/tier2/flux, /obj/item/assembly/signaler/anomaly/tier3/flux))

GLOBAL_LIST_INIT(anomaly_types, list(
	"1" = list(
		ANOMALY_TYPE_ATMOS = /datum/anomaly_gen_datum/tier1/pyroclastic,
		ANOMALY_TYPE_BLUESPACE = /datum/anomaly_gen_datum/tier1/bluespace,
		ANOMALY_TYPE_GRAV = /datum/anomaly_gen_datum/tier1/grav,
		ANOMALY_TYPE_VORTEX = /datum/anomaly_gen_datum/tier1/vortex,
		ANOMALY_TYPE_FLUX = /obj/item/assembly/signaler/anomaly/tier1/flux,
	),
	"2" = list(
		ANOMALY_TYPE_ATMOS = /datum/anomaly_gen_datum/tier2/pyroclastic,
		ANOMALY_TYPE_BLUESPACE = /datum/anomaly_gen_datum/tier2/bluespace,
		ANOMALY_TYPE_GRAV = /datum/anomaly_gen_datum/tier2/grav,
		ANOMALY_TYPE_VORTEX = /datum/anomaly_gen_datum/tier2/vortex,
		ANOMALY_TYPE_FLUX = /obj/item/assembly/signaler/anomaly/tier2/flux,
	),
	"3" = list(
		ANOMALY_TYPE_ATMOS = /datum/anomaly_gen_datum/tier3/pyroclastic,
		ANOMALY_TYPE_BLUESPACE = /datum/anomaly_gen_datum/tier3/bluespace,
		ANOMALY_TYPE_GRAV = /datum/anomaly_gen_datum/tier3/grav,
		ANOMALY_TYPE_VORTEX = /datum/anomaly_gen_datum/tier3/vortex,
		ANOMALY_TYPE_FLUX = /obj/item/assembly/signaler/anomaly/tier3/flux,
	),
))
