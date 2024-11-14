#define ANOMALY_TYPE_RANDOM			"random"
#define ANOMALY_TYPE_ATMOS			"pyroclastic"
#define ANOMALY_TYPE_BLUESPACE		"bluespace"
#define ANOMALY_TYPE_GRAV			"gravitational"
#define ANOMALY_TYPE_VORTEX			"vortex"
#define ANOMALY_TYPE_FLUX			"flux"

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
