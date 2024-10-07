// Uniform slot
/datum/gear/uniform
	subtype_path = /datum/gear/uniform
	slot = ITEM_SLOT_CLOTH_INNER
	sort_category = "Uniforms and Casual Dress"

/datum/gear/uniform/suit
	subtype_path = /datum/gear/uniform/suit

//there's a lot more colors than I thought there were @_@

/datum/gear/uniform/suit/jumpsuit
	display_name = "jumpsuit, select"
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
	display_name = "USSP uniform"
	path = /obj/item/clothing/under/soviet

/datum/gear/uniform/suit/federal
	display_name = "Solar Federation uniform"
	path = /obj/item/clothing/under/solgov/civ

/datum/gear/uniform/suit/kilt
	display_name = "a kilt"
	path = /obj/item/clothing/under/kilt

/datum/gear/uniform/suit/executive
	display_name = "executive suit"
	path = /obj/item/clothing/under/suit_jacket/really_black

/datum/gear/uniform/suit/amish_suit
	display_name = "amish suit"
	path = /obj/item/clothing/under/sl_suit

/datum/gear/uniform/chaps
	display_name = "chaps, select"
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
	display_name = "skirt, tactical"
	path = /obj/item/clothing/under/syndicate/tacticool/skirt

/datum/gear/uniform/skirt/dyeable
	display_name = "dyeable skirt, color"
	path = /obj/item/clothing/under/colour/skirt


/datum/gear/uniform/skirt/dyeable/New()
	..()
	gear_tweaks += new /datum/gear_tweak/color(parent = src)


/datum/gear/uniform/skirt/plaid
	display_name = "plaid skirt, select"
	path = /obj/item/clothing/under/dress/plaid_blue

/datum/gear/uniform/skirt/plaid/New()
	..()
	var/list/skirts = list(/obj/item/clothing/under/dress/plaid_blue,
						   /obj/item/clothing/under/dress/plaid_purple,
						   /obj/item/clothing/under/dress/plaid_red,)
	gear_tweaks += new /datum/gear_tweak/path(skirts, src, TRUE)

/datum/gear/uniform/skirt/redeveninggown
	display_name = "red evening gown"
	path = /obj/item/clothing/under/redeveninggown

/datum/gear/uniform/skirt/black
	display_name = "skirt, black"
	path = /obj/item/clothing/under/blackskirt

/datum/gear/uniform/skirt/job
	subtype_path = /datum/gear/uniform/skirt/job
	subtype_cost_overlap = FALSE

/datum/gear/uniform/skirt/job/ce
	display_name = "skirt, ce"
	path = /obj/item/clothing/under/rank/chief_engineer/skirt
	allowed_roles = list(JOB_TITLE_CHIEF)

/datum/gear/uniform/skirt/job/atmos
	display_name = "skirt, atmos"
	path = /obj/item/clothing/under/rank/atmospheric_technician/skirt
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ATMOSTECH)

/datum/gear/uniform/skirt/job/eng
	display_name = "skirt, engineer"
	path = /obj/item/clothing/under/rank/engineer/skirt
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER)

/datum/gear/uniform/skirt/job/roboticist
	display_name = "skirt, roboticist"
	path = /obj/item/clothing/under/rank/roboticist/skirt
	allowed_roles = list(JOB_TITLE_RD, JOB_TITLE_ROBOTICIST)

/datum/gear/uniform/skirt/job/cmo
	display_name = "skirt, cmo"
	path = /obj/item/clothing/under/rank/chief_medical_officer/skirt
	allowed_roles = list(JOB_TITLE_CMO)

/datum/gear/uniform/skirt/job/paramedic
	display_name = "skirt, paramedic"
	path = /obj/item/clothing/under/rank/medical/paramedic/skirt
	allowed_roles = list(JOB_TITLE_PARAMEDIC)

/datum/gear/uniform/skirt/job/chem
	display_name = "skirt, chemist"
	path = /obj/item/clothing/under/rank/chemist/skirt
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_CHEMIST)

/datum/gear/uniform/skirt/job/viro
	display_name = "skirt, virologist"
	path = /obj/item/clothing/under/rank/virologist/skirt
	allowed_roles = list(JOB_TITLE_VIROLOGIST)

/datum/gear/uniform/skirt/job/med
	display_name = "skirt, medical"
	path = /obj/item/clothing/under/rank/medical/skirt
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN, JOB_TITLE_PSYCHIATRIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_CORONER)

/datum/gear/uniform/skirt/job/phys
	display_name = "skirt, physician"
	path = /obj/item/clothing/under/rank/security/brigphys/skirt
	allowed_roles = list(JOB_TITLE_BRIGDOC)

/datum/gear/uniform/skirt/job/physalt
	display_name = "skirt, physician alt"
	path = /obj/item/clothing/under/rank/security/brigmedical/skirt
	allowed_roles = list(JOB_TITLE_BRIGDOC)

/datum/gear/uniform/skirt/job/hydro
	display_name = "skirt, botanist"
	path = /obj/item/clothing/under/rank/hydroponics/skirt
	allowed_roles = list(JOB_TITLE_BOTANIST)

/datum/gear/uniform/skirt/job/sci
	display_name = "skirt, scientist"
	path = /obj/item/clothing/under/rank/scientist/skirt
	allowed_roles = list(JOB_TITLE_RD, JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENTIST_STUDENT)

/datum/gear/uniform/skirt/job/cargo
	display_name = "skirt, cargo"
	path = /obj/item/clothing/under/rank/cargotech/skirt
	allowed_roles = list(JOB_TITLE_QUARTERMASTER, JOB_TITLE_CARGOTECH)

/datum/gear/uniform/skirt/job/qm
	display_name = "skirt, QM"
	path = /obj/item/clothing/under/rank/cargo/skirt
	allowed_roles = list(JOB_TITLE_QUARTERMASTER)

/datum/gear/uniform/skirt/job/warden
	display_name = "skirt, warden"
	path = /obj/item/clothing/under/rank/warden/skirt
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN)

/datum/gear/uniform/skirt/job/security
	display_name = "skirt, security"
	path = /obj/item/clothing/under/rank/security/skirt
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/uniform/skirt/job/podpilot
	display_name = "skirt, podpilot"
	path = /obj/item/clothing/under/rank/security/pod_pilot/skirt
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_PILOT)

/datum/gear/uniform/skirt/job/head_of_security
	display_name = "skirt, hos"
	path = /obj/item/clothing/under/rank/head_of_security/skirt
	allowed_roles = list(JOB_TITLE_HOS)

/datum/gear/uniform/skirt/job/ntrep
	display_name = "skirt, nt rep"
	path = /obj/item/clothing/under/rank/ntrep/skirt
	allowed_roles = list(JOB_TITLE_REPRESENTATIVE)

/datum/gear/uniform/skirt/job/blueshield
	display_name = "skirt, blueshield"
	path = /obj/item/clothing/under/rank/blueshield/skirt
	allowed_roles = list(JOB_TITLE_BLUESHIELD)

/datum/gear/uniform/skirt/job/librarian
	display_name = "skirt, librarian"
	path = /obj/item/clothing/under/suit_jacket/red/skirt
	allowed_roles = list(JOB_TITLE_LIBRARIAN)

/datum/gear/uniform/skirt/job/bartender
	display_name = "skirt, bartender"
	path = /obj/item/clothing/under/rank/bartender/skirt
	allowed_roles = list(JOB_TITLE_BARTENDER)

/datum/gear/uniform/skirt/job/chaplain
	display_name = "skirt, chaplain"
	path = /obj/item/clothing/under/rank/chaplain/skirt
	allowed_roles = list(JOB_TITLE_CHAPLAIN)

/datum/gear/uniform/skirt/job/barber
	display_name = "skirt, barber"
	path = /obj/item/clothing/under/barber/skirt
	allowed_roles = list(JOB_TITLE_BARBER)

/datum/gear/uniform/skirt/job/nanotrasenofficer
	display_name = "skirt, NNO"
	path = /obj/item/clothing/under/rank/centcom/officer/skirt
	allowed_roles = list(JOB_TITLE_CCOFFICER)

/datum/gear/uniform/skirt/job/internalaffairs
	display_name = "skirt, internalaffairs"
	path = /obj/item/clothing/under/rank/internalaffairs/skirt
	allowed_roles = list(JOB_TITLE_LAWYER)

/datum/gear/uniform/medical
	subtype_path = /datum/gear/uniform/medical

/datum/gear/uniform/medical/scrubs
	display_name = "medical scrubs, select"
	path = /obj/item/clothing/under/rank/medical/purple
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN)

/datum/gear/uniform/medical/scrubs/New()
	..()
	var/list/scrubs = list(/obj/item/clothing/under/rank/medical/purple,
						   /obj/item/clothing/under/rank/medical/lightgreen,
						   /obj/item/clothing/under/rank/medical/green,)
	gear_tweaks += new /datum/gear_tweak/path(scrubs, src, TRUE)

/datum/gear/uniform/sec
	subtype_path = /datum/gear/uniform/sec

/datum/gear/uniform/sec/formal
	display_name = "security uniform, formal"
	path = /obj/item/clothing/under/rank/security/formal
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/uniform/sec/secorporate
	display_name = "security uniform, corporate"
	path = /obj/item/clothing/under/rank/security/corp
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/uniform/sec/dispatch
	display_name = "security uniform, dispatch"
	path = /obj/item/clothing/under/rank/dispatch
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/uniform/sec/casual
	display_name = "security uniform, casual"
	path = /obj/item/clothing/under/rank/security2
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/uniform/cargo
	subtype_path = /datum/gear/uniform/cargo

/datum/gear/uniform/cargo/qm
	display_name = "quartermaster dress"
	path = /obj/item/clothing/under/rank/cargo/alt
	allowed_roles = list(JOB_TITLE_QUARTERMASTER)

/datum/gear/uniform/cargo/tech
	display_name = "cargo technician dress"
	path = /obj/item/clothing/under/rank/cargotech/alt
	allowed_roles = list(JOB_TITLE_QUARTERMASTER, JOB_TITLE_CARGOTECH)

/datum/gear/uniform/cargo/miner
	display_name = "shaft miner sweater"
	path = /obj/item/clothing/under/rank/miner/alt
	allowed_roles = list(JOB_TITLE_QUARTERMASTER, JOB_TITLE_MINER)

/datum/gear/uniform/shorts
	display_name = "shorts, select"
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
	display_name = "jeans, select"
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
	display_name = "pants, select"
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
	display_name = "tacticool turtleneck"
	description = "A sleek black turtleneck paired with some khakis (WARNING DOES NOT HAVE SUIT SENSORS)"
	path = /obj/item/clothing/under/syndicate/tacticool

/datum/gear/uniform/hawaii
	display_name = "hawaiian shirt (red)"
	description = "Sometimes you just want to shoot the guy who brought the chainsaw to the drug deal"
	path = /obj/item/clothing/under/redhawaiianshirt

/datum/gear/uniform/hawaii/pink
	display_name = "hawaiian shirt (pink)"
	description = "Sometimes you just want some pink in your life. For what? Who knows"
	path = /obj/item/clothing/under/pinkhawaiianshirt

/datum/gear/uniform/hawaii/blue
	display_name = "hawaiian shirt (blue)"
	description = "Be careful around water! Some guys in blue shirt like you can't swim"
	path = /obj/item/clothing/under/bluehawaiianshirt

/datum/gear/uniform/hawaii/orange
	display_name = "hawaiian shirt (orange)"
	description = "Come one step closer and I will knock his teeth out!"
	path = /obj/item/clothing/under/orangehawaiianshirt

/datum/gear/uniform/ussptracksuit_red
	display_name = "track suit (red)"
	description = "A classic track suit. There is a small tag on the clothes that says \"Made in the USSP\"."
	path = /obj/item/clothing/under/ussptracksuit_red

/datum/gear/uniform/ussptracksuit_blue
	display_name = "track suit (blue)"
	description = "A classic track suit. There is a small tag on the clothes that says \"Made in the USSP\"."
	path = /obj/item/clothing/under/ussptracksuit_blue

/datum/gear/uniform/dress50s
	display_name = "old Soviet dress"
	path = /obj/item/clothing/under/dress50s

/datum/gear/uniform/galifepants
	display_name = "check breeches"
	path = /obj/item/clothing/under/pants/galifepants

/datum/gear/uniform/sandpants
	display_name = "long sand pants"
	path = /obj/item/clothing/under/pants/sandpants
