// Uniform slot
/datum/gear/uniform
	subtype_path = /datum/gear/uniform
	slot = slot_w_uniform
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

/datum/gear/uniform/suit/kilt
	display_name = "a kilt"
	path = /obj/item/clothing/under/kilt

/datum/gear/uniform/suit/executive
	display_name = "executive suit"
	path = /obj/item/clothing/under/suit_jacket/really_black

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
	allowed_roles = list("Chief Engineer")

/datum/gear/uniform/skirt/job/atmos
	display_name = "skirt, atmos"
	path = /obj/item/clothing/under/rank/atmospheric_technician/skirt
	allowed_roles = list("Chief Engineer","Life Support Specialist")

/datum/gear/uniform/skirt/job/eng
	display_name = "skirt, engineer"
	path = /obj/item/clothing/under/rank/engineer/skirt
	allowed_roles = list("Chief Engineer","Station Engineer")

/datum/gear/uniform/skirt/job/roboticist
	display_name = "skirt, roboticist"
	path = /obj/item/clothing/under/rank/roboticist/skirt
	allowed_roles = list("Research Director","Roboticist")

/datum/gear/uniform/skirt/job/cmo
	display_name = "skirt, cmo"
	path = /obj/item/clothing/under/rank/chief_medical_officer/skirt
	allowed_roles = list("Chief Medical Officer")

/datum/gear/uniform/skirt/job/chem
	display_name = "skirt, chemist"
	path = /obj/item/clothing/under/rank/chemist/skirt
	allowed_roles = list("Chief Medical Officer","Chemist")

/datum/gear/uniform/skirt/job/viro
	display_name = "skirt, virologist"
	path = /obj/item/clothing/under/rank/virologist/skirt
	allowed_roles = list("Virologist")

/datum/gear/uniform/skirt/job/med
	display_name = "skirt, medical"
	path = /obj/item/clothing/under/rank/medical/skirt
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Psychiatrist", "Paramedic", "Coroner", "Intern")

/datum/gear/uniform/skirt/job/phys
	display_name = "skirt, physician"
	path = /obj/item/clothing/under/rank/security/brigphys/skirt
	allowed_roles = list("Brig Physician")

/datum/gear/uniform/skirt/job/physalt
	display_name = "skirt, physician alt"
	path = /obj/item/clothing/under/rank/security/brigmedical/skirt
	allowed_roles = list("Brig Physician")

/datum/gear/uniform/skirt/job/hydro
	display_name = "skirt, botanist"
	path = /obj/item/clothing/under/rank/hydroponics/skirt
	allowed_roles = list("Botanist")

/datum/gear/uniform/skirt/job/sci
	display_name = "skirt, scientist"
	path = /obj/item/clothing/under/rank/scientist/skirt
	allowed_roles = list("Research Director","Scientist", "Student Scientist")

/datum/gear/uniform/skirt/job/cargo
	display_name = "skirt, cargo"
	path = /obj/item/clothing/under/rank/cargotech/skirt
	allowed_roles = list("Quartermaster","Cargo Technician")

/datum/gear/uniform/skirt/job/qm
	display_name = "skirt, QM"
	path = /obj/item/clothing/under/rank/cargo/skirt
	allowed_roles = list("Quartermaster")

/datum/gear/uniform/skirt/job/warden
	display_name = "skirt, warden"
	path = /obj/item/clothing/under/rank/warden/skirt
	allowed_roles = list("Head of Security", "Warden")

/datum/gear/uniform/skirt/job/security
	display_name = "skirt, security"
	path = /obj/item/clothing/under/rank/security/skirt
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer", "Security Pod Pilot")

/datum/gear/uniform/skirt/job/podpilot
	display_name = "skirt, podpilot"
	path = /obj/item/clothing/under/rank/security/pod_pilot/skirt
	allowed_roles = list("Head of Security", "Security Pod Pilot")

/datum/gear/uniform/skirt/job/head_of_security
	display_name = "skirt, hos"
	path = /obj/item/clothing/under/rank/head_of_security/skirt
	allowed_roles = list("Head of Security")

/datum/gear/uniform/skirt/job/ntrep
	display_name = "skirt, nt rep"
	path = /obj/item/clothing/under/rank/ntrep/skirt
	allowed_roles = list("Nanotrasen Representative")

/datum/gear/uniform/skirt/job/blueshield
	display_name = "skirt, blueshield"
	path = /obj/item/clothing/under/rank/blueshield/skirt
	allowed_roles = list("Blueshield")

/datum/gear/uniform/skirt/job/librarian
	display_name = "skirt, librarian"
	path = /obj/item/clothing/under/suit_jacket/red/skirt
	allowed_roles = list("Librarian")

/datum/gear/uniform/skirt/job/bartender
	display_name = "skirt, bartender"
	path = /obj/item/clothing/under/rank/bartender/skirt
	allowed_roles = list("Bartender")

/datum/gear/uniform/skirt/job/chaplain
	display_name = "skirt, chaplain"
	path = /obj/item/clothing/under/rank/chaplain/skirt
	allowed_roles = list("Chaplain")

/datum/gear/uniform/skirt/job/barber
	display_name = "skirt, barber"
	path = /obj/item/clothing/under/barber/skirt
	allowed_roles = list("Barber")

/datum/gear/uniform/skirt/job/nanotrasenofficer
	display_name = "skirt, NNO"
	path = /obj/item/clothing/under/rank/centcom/officer/skirt
	allowed_roles = list("Nanotrasen Navy Officer")

/datum/gear/uniform/skirt/job/internalaffairs
	display_name = "skirt, internalaffairs"
	path = /obj/item/clothing/under/rank/internalaffairs/skirt
	allowed_roles = list("Internal Affairs Agent")

/datum/gear/uniform/medical
	subtype_path = /datum/gear/uniform/medical

/datum/gear/uniform/medical/scrubs
	display_name = "medical scrubs, select"
	path = /obj/item/clothing/under/rank/medical/purple
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Intern")

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
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer", "Security Pod Pilot")

/datum/gear/uniform/sec/secorporate
	display_name = "security uniform, corporate"
	path = /obj/item/clothing/under/rank/security/corp
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Security Pod Pilot")

/datum/gear/uniform/sec/dispatch
	display_name = "security uniform, dispatch"
	path = /obj/item/clothing/under/rank/dispatch
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Security Pod Pilot")

/datum/gear/uniform/sec/casual
	display_name = "security uniform, casual"
	path = /obj/item/clothing/under/rank/security2
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Detective", "Security Pod Pilot")

/datum/gear/uniform/cargo
	subtype_path = /datum/gear/uniform/cargo

/datum/gear/uniform/cargo/qm
	display_name = "quartermaster dress"
	path = /obj/item/clothing/under/rank/cargo/alt
	allowed_roles = list("Quartermaster")

/datum/gear/uniform/cargo/tech
	display_name = "cargo technician dress"
	path = /obj/item/clothing/under/rank/cargotech/alt
	allowed_roles = list("Quartermaster","Cargo Technician")

/datum/gear/uniform/cargo/miner
	display_name = "shaft miner sweater"
	path = /obj/item/clothing/under/rank/miner/alt
	allowed_roles = list("Quartermaster", "Shaft Miner")

/datum/gear/uniform/shorts
	display_name = "shorts, select"
	path = /obj/item/clothing/under/shorts/red

/datum/gear/uniform/shorts/New()
	..()
	var/list/shorts = list(/obj/item/clothing/under/shorts/red,
						   /obj/item/clothing/under/shorts/green,
						   /obj/item/clothing/under/shorts/blue,
						   /obj/item/clothing/under/shorts/black,
						   /obj/item/clothing/under/shorts/grey,)
	gear_tweaks += new /datum/gear_tweak/path(shorts, src, TRUE)

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
