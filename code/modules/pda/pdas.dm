/obj/item/pda/medical
	default_cartridge = /obj/item/cartridge/medical
	default_request_console_cartridge = /obj/item/cartridge/request_console/medical
	icon_state = "pda-medical"

/obj/item/pda/viro
	default_cartridge = /obj/item/cartridge/medical
	default_request_console_cartridge = /obj/item/cartridge/request_console/viro
	icon_state = "pda-virology"
	item_state = "pda-medical"

/obj/item/pda/engineering
	default_cartridge = /obj/item/cartridge/engineering
	default_request_console_cartridge = /obj/item/cartridge/request_console/engineering
	icon_state = "pda-engineer"

/obj/item/pda/security
	default_cartridge = /obj/item/cartridge/security
	default_request_console_cartridge = /obj/item/cartridge/request_console/security
	icon_state = "pda-security"

/obj/item/pda/detective
	default_cartridge = /obj/item/cartridge/detective
	default_request_console_cartridge = /obj/item/cartridge/request_console/detective
	icon_state = "pda-detective"

/obj/item/pda/warden
	default_cartridge = /obj/item/cartridge/security
	default_request_console_cartridge = /obj/item/cartridge/request_console/warden
	icon_state = "pda-warden"

/obj/item/pda/janitor
	default_cartridge = /obj/item/cartridge/janitor
	default_request_console_cartridge = /obj/item/cartridge/request_console/janitor
	icon_state = "pda-janitor"
	ttone = "slip"

/obj/item/pda/toxins
	default_cartridge = /obj/item/cartridge/signal/toxins
	icon_state = "pda-science"
	default_request_console_cartridge = /obj/item/cartridge/request_console/toxins
	ttone = "boom"

/obj/item/pda/clown
	default_cartridge = /obj/item/cartridge/clown
	icon_state = "pda-clown"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	ttone = "honk"

/obj/item/pda/clown/ComponentInitialize()
	AddComponent(/datum/component/slippery, 10 SECONDS, lube_flags = (NO_SLIP_WHEN_WALKING|SLIDE))

/obj/item/pda/mime
	default_cartridge = /obj/item/cartridge/mime
	icon_state = "pda-mime"
	ttone = "silence"

/obj/item/pda/mime/New()
	..()
	var/datum/data/pda/app/M = find_program(/datum/data/pda/app/messenger)
	if(M)
		M.notify_silent = 1

/obj/item/pda/heads
	default_cartridge = /obj/item/cartridge/head
	icon_state = "pda-h"

/obj/item/pda/heads/hop
	default_cartridge = /obj/item/cartridge/hop
	default_request_console_cartridge = /obj/item/cartridge/request_console/hop
	icon_state = "pda-hop"

/obj/item/pda/heads/hos
	default_cartridge = /obj/item/cartridge/hos
	default_request_console_cartridge = /obj/item/cartridge/request_console/hos
	icon_state = "pda-hos"

/obj/item/pda/heads/ce
	default_cartridge = /obj/item/cartridge/ce
	default_request_console_cartridge = /obj/item/cartridge/request_console/ce
	icon_state = "pda-ce"

/obj/item/pda/heads/cmo
	default_cartridge = /obj/item/cartridge/cmo
	default_request_console_cartridge = /obj/item/cartridge/request_console/cmo
	icon_state = "pda-cmo"

/obj/item/pda/heads/rd
	default_cartridge = /obj/item/cartridge/rd
	default_request_console_cartridge = /obj/item/cartridge/request_console/rd
	icon_state = "pda-rd"

/obj/item/pda/captain
	default_cartridge = /obj/item/cartridge/captain
	icon_state = "pda-captain"
	default_request_console_cartridge = /obj/item/cartridge/request_console/captain
	detonate = 0
	//toff = 1

/obj/item/pda/heads/ntrep
	default_cartridge = /obj/item/cartridge/supervisor
	default_request_console_cartridge = /obj/item/cartridge/request_console/ntrep
	icon_state = "pda-h"

/obj/item/pda/heads/magistrate
	default_cartridge = /obj/item/cartridge/supervisor
	default_request_console_cartridge = /obj/item/cartridge/request_console/magistrate
	icon_state = "pda-h"

/obj/item/pda/heads/blueshield
	default_cartridge = /obj/item/cartridge/hos
	default_request_console_cartridge = /obj/item/cartridge/request_console/blueshield
	icon_state = "pda-h"

/obj/item/pda/heads/ert

/obj/item/pda/heads/ert/engineering
	icon_state = "pda-engineer"

/obj/item/pda/heads/ert/security
	icon_state = "pda-security"

/obj/item/pda/heads/ert/medical
	icon_state = "pda-medical"


/obj/item/pda/cargo
	default_cartridge = /obj/item/cartridge/quartermaster
	default_request_console_cartridge = /obj/item/cartridge/request_console/cargo
	icon_state = "pda-cargo"

/obj/item/pda/quartermaster
	default_cartridge = /obj/item/cartridge/quartermaster
	default_request_console_cartridge = /obj/item/cartridge/request_console/quartermaster
	icon_state = "pda-qm"

/obj/item/pda/shaftminer
	icon_state = "pda-miner"
	default_request_console_cartridge = /obj/item/cartridge/request_console/shaftminer
	special_pen = /obj/item/pen/survival

/obj/item/pda/syndicate
	default_cartridge = /obj/item/cartridge/syndicate
	icon_state = "pda-syndi"
	name = "Military PDA"
	owner = "John Doe"

/obj/item/pda/syndicate/no_cartridge
	default_cartridge = null
	name = "NoName PDA"
	owner = "Серый Джо" //Не знаю почему Серый Джо, мне так просто захотелось

/obj/item/pda/syndicate/no_cartridge/comms
	icon_state = "pda-syndie-tc"

/obj/item/pda/syndicate/no_cartridge/rd
	icon_state = "pda-syndie-rd"

/obj/item/pda/syndicate/New()
	..()
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	if(M)
		M.m_hidden = 1

/obj/item/pda/chaplain
	icon_state = "pda-chaplain"
	default_request_console_cartridge = /obj/item/cartridge/request_console/chaplain
	ttone = "holy"

/obj/item/pda/lawyer
	default_cartridge = /obj/item/cartridge/lawyer
	default_request_console_cartridge = /obj/item/cartridge/request_console/lawyer
	icon_state = "pda-lawyer"
	ttone = "..."

/obj/item/pda/botanist
	//default_cartridge = /obj/item/cartridge/botanist
	default_request_console_cartridge = /obj/item/cartridge/request_console/botanist
	icon_state = "pda-hydro"

/obj/item/pda/roboticist
	icon_state = "pda-roboticist"
	default_request_console_cartridge = /obj/item/cartridge/request_console/roboticist

/obj/item/pda/librarian
	icon_state = "pda-library"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a WGW-11 series e-reader."
	model_name = "Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant"

/obj/item/pda/librarian/New()
	..()
	var/datum/data/pda/app/M = find_program(/datum/data/pda/app/messenger)
	if(M)
		M.notify_silent = 1 //Quiet in the library!

/obj/item/pda/clear
	icon_state = "pda-transp"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a special edition with a transparent case."
	model_name = "Thinktronic 5230 Personal Data Assistant Deluxe Special Max Turbo Limited Edition"

/obj/item/pda/chef
	default_request_console_cartridge = /obj/item/cartridge/request_console/chef
	icon_state = "pda-chef"

/obj/item/pda/bar
	icon_state = "pda-bartender"
	default_request_console_cartridge = /obj/item/cartridge/request_console/bar

/obj/item/pda/atmos
	default_cartridge = /obj/item/cartridge/atmos
	default_request_console_cartridge = /obj/item/cartridge/request_console/atmos
	icon_state = "pda-atmos"

/obj/item/pda/chemist
	default_cartridge = /obj/item/cartridge/chemistry
	icon_state = "pda-chemistry"
	default_request_console_cartridge = /obj/item/cartridge/request_console/chemist

/obj/item/pda/geneticist
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-genetics"
	default_request_console_cartridge = /obj/item/cartridge/request_console/geneticist

/obj/item/pda/centcom
	default_cartridge = /obj/item/cartridge/centcom
	default_request_console_cartridge = /obj/item/cartridge/request_console/centcom
	icon_state = "pda-h"

/obj/item/pda/centcom/New()
	..()
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	if(M)
		M.m_hidden = 1

//Some spare PDAs in a box
/obj/item/storage/box/PDAs
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdabox"

/obj/item/storage/box/PDAs/populate_contents()
	new /obj/item/pda(src)
	new /obj/item/pda(src)
	new /obj/item/pda(src)
	new /obj/item/pda(src)
	new /obj/item/cartridge/head(src)

	var/newcart = pick(	/obj/item/cartridge/engineering,
						/obj/item/cartridge/security,
						/obj/item/cartridge/medical,
						/obj/item/cartridge/signal/toxins,
						/obj/item/cartridge/quartermaster)
	new newcart(src)
