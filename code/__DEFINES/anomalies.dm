#define ANOMALY_TYPE_RANDOM			"random"
#define ANOMALY_TYPE_ATMOS			"pyroclastic"
#define ANOMALY_TYPE_BLUESPACE		"bluespace"
#define ANOMALY_TYPE_GRAV			"gravitational"
#define ANOMALY_TYPE_VORTEX			"vortex"
#define ANOMALY_TYPE_FLUX			"energetic"
#define TIER1						"1"
#define TIER2						"2"
#define TIER3						"3"

#define isanomaly(A)	(istype((A), /obj/effect/anomaly))

#define iscore(A)			(istype((A), /obj/item/assembly/signaler/core))

#define iscoreempty(A)		((A.type == /obj/item/assembly/signaler/core/tier1) || \
							(A.type == /obj/item/assembly/signaler/core/tier2) || \
							(A.type == /obj/item/assembly/signaler/core/tier3))

#define iscoreatmos(A)		(istype((A), /obj/item/assembly/signaler/core/atmospheric))
#define iscorebluespace(A)	(istype((A), /obj/item/assembly/signaler/core/bluespace))
#define iscoregrav(A)		(istype((A), /obj/item/assembly/signaler/core/gravitational))
#define iscorevortex(A)		(istype((A), /obj/item/assembly/signaler/core/vortex))
#define iscoreflux(A)		(istype((A), /obj/item/assembly/signaler/core/energetic))

GLOBAL_LIST_INIT(anomaly_types, list(
	TIER1 = list(
		ANOMALY_TYPE_ATMOS = /datum/anomaly_gen_datum/tier1/pyroclastic,
		ANOMALY_TYPE_BLUESPACE = /datum/anomaly_gen_datum/tier1/bluespace,
		ANOMALY_TYPE_GRAV = /datum/anomaly_gen_datum/tier1/gravitational,
		ANOMALY_TYPE_VORTEX = /datum/anomaly_gen_datum/tier1/vortex,
		ANOMALY_TYPE_FLUX = /datum/anomaly_gen_datum/tier1/energetic,
	),
	TIER2 = list(
		ANOMALY_TYPE_ATMOS = /datum/anomaly_gen_datum/tier2/pyroclastic,
		ANOMALY_TYPE_BLUESPACE = /datum/anomaly_gen_datum/tier2/bluespace,
		ANOMALY_TYPE_GRAV = /datum/anomaly_gen_datum/tier2/gravitational,
		ANOMALY_TYPE_VORTEX = /datum/anomaly_gen_datum/tier2/vortex,
		ANOMALY_TYPE_FLUX = /datum/anomaly_gen_datum/tier2/energetic,
	),
	TIER3 = list(
		ANOMALY_TYPE_ATMOS = /datum/anomaly_gen_datum/tier3/pyroclastic,
		ANOMALY_TYPE_BLUESPACE = /datum/anomaly_gen_datum/tier3/bluespace,
		ANOMALY_TYPE_GRAV = /datum/anomaly_gen_datum/tier3/gravitational,
		ANOMALY_TYPE_VORTEX = /datum/anomaly_gen_datum/tier3/vortex,
		ANOMALY_TYPE_FLUX = /datum/anomaly_gen_datum/tier3/energetic,
	),
))

GLOBAL_LIST_INIT(created_anomalies, list(
	ANOMALY_TYPE_ATMOS = 0,
	ANOMALY_TYPE_BLUESPACE = 0,
	ANOMALY_TYPE_GRAV = 0,
	ANOMALY_TYPE_VORTEX = 0,
	ANOMALY_TYPE_FLUX = 0,
))


GLOBAL_LIST_INIT(anomalies_preffs_one, list(
	ANOMALY_TYPE_ATMOS = "атомсферная",
	ANOMALY_TYPE_BLUESPACE = "блюспейс",
	ANOMALY_TYPE_GRAV = "гравитационная",
	ANOMALY_TYPE_VORTEX = "вихревая",
	ANOMALY_TYPE_FLUX = "гиперэнергетическая потоковая",
))


GLOBAL_LIST_INIT(anomalies_preffs_many, list(
	ANOMALY_TYPE_ATMOS = "атомсферных",
	ANOMALY_TYPE_BLUESPACE = "блюспейс",
	ANOMALY_TYPE_GRAV = "гравитационных",
	ANOMALY_TYPE_VORTEX = "вихревых",
	ANOMALY_TYPE_FLUX = "гиперэнергетических потоковых",
))


GLOBAL_LIST_INIT(anomalies_sizes_one, list(
	TIER1 = "малая",
	TIER2 = "",
	TIER3 = "крупная",
))


GLOBAL_LIST_INIT(anomalies_sizes_many, list(
	TIER1 = "малых",
	TIER2 = "",
	TIER3 = "крупных",
))

#define ANOMALY_GROW_STABILITY			30
#define ANOMALY_DECREASE_STABILITY		70
#define ANOMALY_MOVE_MAX_STABILITY		59
