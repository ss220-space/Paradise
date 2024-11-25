#define ANOMALY_TYPE_RANDOM			"random"
#define ANOMALY_TYPE_ATMOS			"atmospheric"
#define ANOMALY_TYPE_BLUESPACE		"bluespace"
#define ANOMALY_TYPE_GRAV			"gravitational"
#define ANOMALY_TYPE_VORTEX			"vortex"
#define ANOMALY_TYPE_FLUX			"energetic"

#define isanomaly(A)	(istype((A), /obj/effect/anomaly))

#define iscore(A)			(istype((A), /obj/item/assembly/signaler/core))
#define iscoret1(A)			(istype((A), /obj/item/assembly/signaler/core/tier1))
#define iscoret2(A)			(istype((A), /obj/item/assembly/signaler/core/tier2))
#define iscoret3(A)			(istype((A), /obj/item/assembly/signaler/core/tier3))

#define iscoreempty(A)		((A.type == /obj/item/assembly/signaler/core/tier1) || \
							(A.type == /obj/item/assembly/signaler/core/tier2) || \
							(A.type == /obj/item/assembly/signaler/core/tier3))
#define iscoreatmos(A)		((A.type == /obj/item/assembly/signaler/core/tier1/atmospheric) || \
							(A.type == /obj/item/assembly/signaler/core/tier2/atmospheric) || \
							(A.type == /obj/item/assembly/signaler/core/tier3/atmospheric))
#define iscorebluespace(A)	((A.type == /obj/item/assembly/signaler/core/tier1/bluespace) || \
							(A.type == /obj/item/assembly/signaler/core/tier2/bluespace) || \
							(A.type == /obj/item/assembly/signaler/core/tier3/bluespace))
#define iscoregrav(A)		((A.type == /obj/item/assembly/signaler/core/tier1/gravitational) || \
							(A.type == /obj/item/assembly/signaler/core/tier2/gravitational) || \
							(A.type == /obj/item/assembly/signaler/core/tier3/gravitational))
#define iscorevortex(A)		((A.type == /obj/item/assembly/signaler/core/tier1/vortex) || \
							(A.type == /obj/item/assembly/signaler/core/tier2/vortex) || \
							(A.type == /obj/item/assembly/signaler/core/tier3/vortex))
#define iscoreflux(A)		((A.type == /obj/item/assembly/signaler/core/tier1/energetic) || \
							(A.type == /obj/item/assembly/signaler/core/tier2/energetic) || \
							(A.type == /obj/item/assembly/signaler/core/tier3/energetic))

GLOBAL_LIST_INIT(anomaly_types, list(
	"1" = list(
		ANOMALY_TYPE_ATMOS = /datum/anomaly_gen_datum/tier1/pyroclastic,
		ANOMALY_TYPE_BLUESPACE = /datum/anomaly_gen_datum/tier1/bluespace,
		ANOMALY_TYPE_GRAV = /datum/anomaly_gen_datum/tier1/gravitational,
		ANOMALY_TYPE_VORTEX = /datum/anomaly_gen_datum/tier1/vortex,
		ANOMALY_TYPE_FLUX = /obj/item/assembly/signaler/core/tier1/energetic,
	),
	"2" = list(
		ANOMALY_TYPE_ATMOS = /datum/anomaly_gen_datum/tier2/pyroclastic,
		ANOMALY_TYPE_BLUESPACE = /datum/anomaly_gen_datum/tier2/bluespace,
		ANOMALY_TYPE_GRAV = /datum/anomaly_gen_datum/tier2/gravitational,
		ANOMALY_TYPE_VORTEX = /datum/anomaly_gen_datum/tier2/vortex,
		ANOMALY_TYPE_FLUX = /obj/item/assembly/signaler/core/tier2/energetic,
	),
	"3" = list(
		ANOMALY_TYPE_ATMOS = /datum/anomaly_gen_datum/tier3/pyroclastic,
		ANOMALY_TYPE_BLUESPACE = /datum/anomaly_gen_datum/tier3/bluespace,
		ANOMALY_TYPE_GRAV = /datum/anomaly_gen_datum/tier3/gravitational,
		ANOMALY_TYPE_VORTEX = /datum/anomaly_gen_datum/tier3/vortex,
		ANOMALY_TYPE_FLUX = /obj/item/assembly/signaler/core/tier3/energetic,
	),
))

GLOBAL_LIST_INIT(created_anomalies, list(
	ANOMALY_TYPE_ATMOS = 0,
	ANOMALY_TYPE_BLUESPACE = 0,
	ANOMALY_TYPE_GRAV = 0,
	ANOMALY_TYPE_VORTEX = 0,
	ANOMALY_TYPE_FLUX = 0,
))

#define ANOMALY_GROW_STABILITY			30
#define ANOMALY_DECREASE_STABILITY		70
#define ANOMALY_MOVE_MAX_STABILITY		59
