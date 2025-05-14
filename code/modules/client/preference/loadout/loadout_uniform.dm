// Uniform slot
/datum/gear/uniform
	subtype_path = /datum/gear/uniform
	slot = ITEM_SLOT_CLOTH_INNER
	sort_category = "Uniforms and Casual Dress"

/datum/gear/uniform/suit
	subtype_path = /datum/gear/uniform/suit

//there's a lot more colors than I thought there were @_@

/datum/gear/uniform/suit/jumpsuit
	index_name = "jumpsuit, select"
	display_name = "jumpsuit"
	path = /obj/item/clothing/under/color/grey

/datum/gear/uniform/suit/jumpsuit/New()
	..()
	var/list/suits = list(/obj/item/clothing/under/color/grey,
						  /obj/item/clothing/under/color/black,
						  /obj/item/clothing/under/color/blue,
						  /obj/item/clothing/under/color/green,
						  /obj/item/clothing/under/color/orange,
						  /obj/item/clothing/under/color/pink,
						  /obj/item/clothing/under/color/red,
						  /obj/item/clothing/under/color/white,
						  /obj/item/clothing/under/color/yellow,
						  /obj/item/clothing/under/color/lightblue,
						  /obj/item/clothing/under/color/aqua,
						  /obj/item/clothing/under/color/purple,
						  /obj/item/clothing/under/color/lightpurple,
						  /obj/item/clothing/under/color/lightgreen,
						  /obj/item/clothing/under/color/lightblue,
						  /obj/item/clothing/under/color/lightbrown,
						  /obj/item/clothing/under/color/brown,
						  /obj/item/clothing/under/color/yellowgreen,
						  /obj/item/clothing/under/color/darkblue,
						  /obj/item/clothing/under/color/lightred,
						  /obj/item/clothing/under/color/darkred,)
	gear_tweaks += new /datum/gear_tweak/path(suits, src, TRUE)

/datum/gear/uniform/suit/soviet
	index_name = "USSP uniform"
	path = /obj/item/clothing/under/soviet

/datum/gear/uniform/suit/federal
	index_name = "Solar Federation uniform"
	path = /obj/item/clothing/under/solgov/civ

/datum/gear/uniform/suit/kilt
	index_name = "a kilt"
	path = /obj/item/clothing/under/kilt

/datum/gear/uniform/suit/executive
	index_name = "executive suit"
	path = /obj/item/clothing/under/suit_jacket/really_black

/datum/gear/uniform/suit/amish_suit
	index_name = "amish suit"
	path = /obj/item/clothing/under/sl_suit

/datum/gear/uniform/chaps
	index_name = "chaps, select"
	display_name = "chaps"
	path = /obj/item/clothing/under/red_chaps

/datum/gear/uniform/chaps/New()
	..()
	var/list/chaps = list(/obj/item/clothing/under/red_chaps,
						  /obj/item/clothing/under/white_chaps,
						  /obj/item/clothing/under/tan_chaps,
						  /obj/item/clothing/under/brown_chaps,
						  )
	gear_tweaks += new /datum/gear_tweak/path(chaps, src, TRUE)
/datum/gear/uniform/skirt
	subtype_path = /datum/gear/uniform/skirt

/datum/gear/uniform/skirt/syndi
	index_name = "skirt, tactical"
	path = /obj/item/clothing/under/syndicate/tacticool/skirt

/datum/gear/uniform/skirt/dyeable
	index_name = "dyeable skirt, color"
	path = /obj/item/clothing/under/colour/skirt


/datum/gear/uniform/skirt/dyeable/New()
	..()
	gear_tweaks += new /datum/gear_tweak/color(parent = src)


/datum/gear/uniform/skirt/plaid
	index_name = "plaid skirt, select"
	display_name = "plaid skirt"
	path = /obj/item/clothing/under/dress/plaid_blue

/datum/gear/uniform/skirt/plaid/New()
	..()
	var/list/skirts = list(/obj/item/clothing/under/dress/plaid_blue,
						   /obj/item/clothing/under/dress/plaid_purple,
						   /obj/item/clothing/under/dress/plaid_red,)
	gear_tweaks += new /datum/gear_tweak/path(skirts, src, TRUE)

/datum/gear/uniform/skirt/redeveninggown
	index_name = "red evening gown"
	path = /obj/item/clothing/under/redeveninggown

/datum/gear/uniform/skirt/black
	index_name = "skirt, black"
	path = /obj/item/clothing/under/blackskirt

/datum/gear/uniform/skirt/job
	subtype_path = /datum/gear/uniform/skirt/job
	subtype_cost_overlap = FALSE

/datum/gear/uniform/skirt/job/ce
	index_name = "skirt, ce"
	path = /obj/item/clothing/under/rank/chief_engineer/skirt
	allowed_roles = list(JOB_TITLE_CHIEF)

/datum/gear/uniform/skirt/job/atmos
	index_name = "skirt, atmos"
	path = /obj/item/clothing/under/rank/atmospheric_technician/skirt
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ATMOSTECH)

/datum/gear/uniform/skirt/job/eng
	index_name = "skirt, engineer"
	path = /obj/item/clothing/under/rank/engineer/skirt
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER)

/datum/gear/uniform/skirt/job/roboticist
	index_name = "skirt, roboticist"
	path = /obj/item/clothing/under/rank/roboticist/skirt
	allowed_roles = list(JOB_TITLE_RD, JOB_TITLE_ROBOTICIST)

/datum/gear/uniform/skirt/job/cmo
	index_name = "skirt, cmo"
	path = /obj/item/clothing/under/rank/chief_medical_officer/skirt
	allowed_roles = list(JOB_TITLE_CMO)

/datum/gear/uniform/skirt/job/paramedic
	index_name = "skirt, paramedic"
	path = /obj/item/clothing/under/rank/medical/paramedic/skirt
	allowed_roles = list(JOB_TITLE_PARAMEDIC)

/datum/gear/uniform/skirt/job/chem
	index_name = "skirt, chemist"
	path = /obj/item/clothing/under/rank/chemist/skirt
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_CHEMIST)

/datum/gear/uniform/skirt/job/viro
	index_name = "skirt, virologist"
	path = /obj/item/clothing/under/rank/virologist/skirt
	allowed_roles = list(JOB_TITLE_VIROLOGIST)

/datum/gear/uniform/skirt/job/med
	index_name = "skirt, medical"
	path = /obj/item/clothing/under/rank/medical/skirt
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_MINING_MEDIC, JOB_TITLE_INTERN, JOB_TITLE_PSYCHIATRIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_CORONER)

/datum/gear/uniform/skirt/job/phys
	index_name = "skirt, physician"
	path = /obj/item/clothing/under/rank/security/brigphys/skirt
	allowed_roles = list(JOB_TITLE_BRIGDOC)

/datum/gear/uniform/skirt/job/physalt
	index_name = "skirt, physician alt"
	path = /obj/item/clothing/under/rank/security/brigmedical/skirt
	allowed_roles = list(JOB_TITLE_BRIGDOC)

/datum/gear/uniform/skirt/job/hydro
	index_name = "skirt, botanist"
	path = /obj/item/clothing/under/rank/hydroponics/skirt
	allowed_roles = list(JOB_TITLE_BOTANIST)

/datum/gear/uniform/skirt/job/sci
	index_name = "skirt, scientist"
	path = /obj/item/clothing/under/rank/scientist/skirt
	allowed_roles = list(JOB_TITLE_RD, JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENTIST_STUDENT)

/datum/gear/uniform/skirt/job/cargo
	index_name = "skirt, cargo"
	path = /obj/item/clothing/under/rank/cargotech/skirt
	allowed_roles = list(JOB_TITLE_QUARTERMASTER, JOB_TITLE_CARGOTECH)

/datum/gear/uniform/skirt/job/qm
	index_name = "skirt, QM"
	path = /obj/item/clothing/under/rank/cargo/skirt
	allowed_roles = list(JOB_TITLE_QUARTERMASTER)

/datum/gear/uniform/skirt/job/warden
	index_name = "skirt, warden"
	path = /obj/item/clothing/under/rank/warden/skirt
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN)

/datum/gear/uniform/skirt/job/security
	index_name = "skirt, security"
	path = /obj/item/clothing/under/rank/security/skirt
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/uniform/skirt/job/podpilot
	index_name = "skirt, podpilot"
	path = /obj/item/clothing/under/rank/security/pod_pilot/skirt
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_PILOT)

/datum/gear/uniform/skirt/job/head_of_security
	index_name = "skirt, hos"
	path = /obj/item/clothing/under/rank/head_of_security/skirt
	allowed_roles = list(JOB_TITLE_HOS)

/datum/gear/uniform/skirt/job/ntrep
	index_name = "skirt, nt rep"
	path = /obj/item/clothing/under/rank/ntrep/skirt
	allowed_roles = list(JOB_TITLE_REPRESENTATIVE)

/datum/gear/uniform/skirt/job/blueshield
	index_name = "skirt, blueshield"
	path = /obj/item/clothing/under/rank/blueshield/skirt
	allowed_roles = list(JOB_TITLE_BLUESHIELD)

/datum/gear/uniform/skirt/job/librarian
	index_name = "skirt, librarian"
	path = /obj/item/clothing/under/suit_jacket/red/skirt
	allowed_roles = list(JOB_TITLE_LIBRARIAN)

/datum/gear/uniform/skirt/job/bartender
	index_name = "skirt, bartender"
	path = /obj/item/clothing/under/rank/bartender/skirt
	allowed_roles = list(JOB_TITLE_BARTENDER)

/datum/gear/uniform/skirt/job/chaplain
	index_name = "skirt, chaplain"
	path = /obj/item/clothing/under/rank/chaplain/skirt
	allowed_roles = list(JOB_TITLE_CHAPLAIN)

/datum/gear/uniform/skirt/job/nanotrasenofficer
	index_name = "skirt, NNO"
	path = /obj/item/clothing/under/rank/centcom/officer/skirt
	allowed_roles = list(JOB_TITLE_CCOFFICER)

/datum/gear/uniform/skirt/job/internalaffairs
	index_name = "skirt, internalaffairs"
	path = /obj/item/clothing/under/rank/internalaffairs/skirt
	allowed_roles = list(JOB_TITLE_LAWYER)

/datum/gear/uniform/medical
	subtype_path = /datum/gear/uniform/medical

/datum/gear/uniform/medical/scrubs
	index_name = "medical scrubs, select"
	display_name = "medical scrubs"
	path = /obj/item/clothing/under/rank/medical/purple
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_MINING_MEDIC, JOB_TITLE_INTERN)

/datum/gear/uniform/medical/scrubs/New()
	..()
	var/list/scrubs = list(/obj/item/clothing/under/rank/medical/purple,
						   /obj/item/clothing/under/rank/medical/lightgreen,
						   /obj/item/clothing/under/rank/medical/green,)
	gear_tweaks += new /datum/gear_tweak/path(scrubs, src, TRUE)

/datum/gear/uniform/sec
	subtype_path = /datum/gear/uniform/sec

/datum/gear/uniform/sec/formal
	index_name = "security uniform, formal"
	path = /obj/item/clothing/under/rank/security/formal
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/uniform/sec/secorporate
	index_name = "security uniform, corporate"
	path = /obj/item/clothing/under/rank/security/corp
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/uniform/sec/dispatch
	index_name = "security uniform, dispatch"
	path = /obj/item/clothing/under/rank/dispatch
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/uniform/sec/casual
	index_name = "security uniform, casual"
	path = /obj/item/clothing/under/rank/security2
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/uniform/cargo
	subtype_path = /datum/gear/uniform/cargo

/datum/gear/uniform/cargo/qm
	index_name = "quartermaster dress"
	path = /obj/item/clothing/under/rank/cargo/alt
	allowed_roles = list(JOB_TITLE_QUARTERMASTER)

/datum/gear/uniform/cargo/tech
	index_name = "cargo technician dress"
	path = /obj/item/clothing/under/rank/cargotech/alt
	allowed_roles = list(JOB_TITLE_QUARTERMASTER, JOB_TITLE_CARGOTECH)

/datum/gear/uniform/cargo/miner
	index_name = "shaft miner sweater"
	path = /obj/item/clothing/under/rank/miner/alt
	allowed_roles = list(JOB_TITLE_QUARTERMASTER, JOB_TITLE_MINER, JOB_TITLE_MINING_MEDIC)

/datum/gear/uniform/shorts
	index_name = "shorts, select"
	display_name = "shorts"
	path = /obj/item/clothing/under/shorts/red

/datum/gear/uniform/shorts/New()
	..()
	var/list/shorts = list("red" = /obj/item/clothing/under/shorts/red,
						   "green" = /obj/item/clothing/under/shorts/green,
						   "blue" = /obj/item/clothing/under/shorts/blue,
						   "black" = /obj/item/clothing/under/shorts/black,
						   "grey" = /obj/item/clothing/under/shorts/grey,)
	gear_tweaks += new /datum/gear_tweak/path(shorts, src)

/datum/gear/uniform/pants
	subtype_path = /datum/gear/uniform/pants

/datum/gear/uniform/pants/jeans
	index_name = "jeans, select"
	display_name = "jeans"
	path = /obj/item/clothing/under/pants/classicjeans

/datum/gear/uniform/pants/jeans/New()
	..()
	var/list/jeans = list(/obj/item/clothing/under/pants/classicjeans,
						  /obj/item/clothing/under/pants/mustangjeans,
						  /obj/item/clothing/under/pants/blackjeans,
						  /obj/item/clothing/under/pants/youngfolksjeans,
						  )
	gear_tweaks += new /datum/gear_tweak/path(jeans, src, TRUE)

/datum/gear/uniform/pants/pants
	index_name = "pants, select"
	display_name = "pants"
	path = /obj/item/clothing/under/pants/white

/datum/gear/uniform/pants/pants/New()
	..()
	var/list/pants = list(/obj/item/clothing/under/pants/white,
						  /obj/item/clothing/under/pants/red,
						  /obj/item/clothing/under/pants/black,
						  /obj/item/clothing/under/pants/tan,
						  /obj/item/clothing/under/pants/blue,
						  /obj/item/clothing/under/pants/track,
						  /obj/item/clothing/under/pants/khaki,
						  /obj/item/clothing/under/pants/camo,
						  )
	gear_tweaks += new /datum/gear_tweak/path(pants, src, TRUE)

/datum/gear/uniform/suit/tacticool
	index_name = "tacticool turtleneck"
	description = "A sleek black turtleneck paired with some khakis (WARNING DOES NOT HAVE SUIT SENSORS)"
	path = /obj/item/clothing/under/syndicate/tacticool

/datum/gear/uniform/hawaii
	index_name = "hawaiian shirt (red)"
	description = "Sometimes you just want to shoot the guy who brought the chainsaw to the drug deal"
	path = /obj/item/clothing/under/redhawaiianshirt

/datum/gear/uniform/hawaii/pink
	index_name = "hawaiian shirt (pink)"
	description = "Sometimes you just want some pink in your life. For what? Who knows"
	path = /obj/item/clothing/under/pinkhawaiianshirt

/datum/gear/uniform/hawaii/blue
	index_name = "hawaiian shirt (blue)"
	description = "Be careful around water! Some guys in blue shirt like you can't swim"
	path = /obj/item/clothing/under/bluehawaiianshirt

/datum/gear/uniform/hawaii/orange
	index_name = "hawaiian shirt (orange)"
	description = "Come one step closer and I will knock his teeth out!"
	path = /obj/item/clothing/under/orangehawaiianshirt

/datum/gear/uniform/ussptracksuit_red
	index_name = "track suit (red)"
	description = "A classic track suit. There is a small tag on the clothes that says \"Made in the USSP\"."
	path = /obj/item/clothing/under/ussptracksuit_red

/datum/gear/uniform/ussptracksuit_blue
	index_name = "track suit (blue)"
	description = "A classic track suit. There is a small tag on the clothes that says \"Made in the USSP\"."
	path = /obj/item/clothing/under/ussptracksuit_blue

/datum/gear/uniform/dress50s
	index_name = "old Soviet dress"
	path = /obj/item/clothing/under/dress50s

/datum/gear/uniform/galifepants
	index_name = "check breeches"
	path = /obj/item/clothing/under/pants/galifepants

/datum/gear/uniform/sandpants
	index_name = "long sand pants"
	path = /obj/item/clothing/under/pants/sandpants
