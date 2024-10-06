/obj/item/cartridge/request_console
	name = "Request Console"
	icon_state = "cart-req"
	programs = list(new/datum/data/pda/app/request_console)

/obj/item/cartridge/request_console/medical
	name = "Medical Request"
	programs = list(new/datum/data/pda/app/request_console/medbay, \
					new/datum/data/pda/app/request_console/morgue)

/obj/item/cartridge/request_console/viro
	name = "Virology Request"
	programs = list(new/datum/data/pda/app/request_console/medbay, \
					new/datum/data/pda/app/request_console/virology, \
					new/datum/data/pda/app/request_console/morgue)

/obj/item/cartridge/request_console/engineering
	name = "Engineering Request"
	programs = list(new/datum/data/pda/app/request_console/tech_storage, \
					new/datum/data/pda/app/request_console/mechanic, \
					new/datum/data/pda/app/request_console/engineering, \
					new/datum/data/pda/app/request_console/atmospherics)

/obj/item/cartridge/request_console/security
	name = "Security Request"
	programs = list(new/datum/data/pda/app/request_console/security)

/obj/item/cartridge/request_console/detective
	name = "Detective Request"
	programs = list(new/datum/data/pda/app/request_console/security, \
					new/datum/data/pda/app/request_console/detective)

/obj/item/cartridge/request_console/warden
	name = "Warden Request"
	programs = list(new/datum/data/pda/app/request_console/security, \
					new/datum/data/pda/app/request_console/warden)

/obj/item/cartridge/request_console/janitor
	name = "Janitor Request"
	programs = list(new/datum/data/pda/app/request_console/janitorial)

/obj/item/cartridge/request_console/toxins
	name = "Sciense Request"
	programs = list(new/datum/data/pda/app/request_console/science, \
					new/datum/data/pda/app/request_console/robotics, \
					new/datum/data/pda/app/request_console/research, \
					new/datum/data/pda/app/request_console/xenobiology)

/obj/item/cartridge/request_console/hop
	name = "HOP Request"
	programs = list(new/datum/data/pda/app/request_console/bar, \
					new/datum/data/pda/app/request_console/kitchen, \
					new/datum/data/pda/app/request_console/head_of_personnel_desk, \
					new/datum/data/pda/app/request_console/bridge, \
					new/datum/data/pda/app/request_console/hydroponics, \
					new/datum/data/pda/app/request_console/janitorial, \
					new/datum/data/pda/app/request_console/chapel)

/obj/item/cartridge/request_console/hos
	name = "HOS Request"
	programs = list(new/datum/data/pda/app/request_console/warden, \
					new/datum/data/pda/app/request_console/security, \
					new/datum/data/pda/app/request_console/head_of_security_desk, \
					new/datum/data/pda/app/request_console/bridge, \
					new/datum/data/pda/app/request_console/detective)

/obj/item/cartridge/request_console/ce
	name = "CE Request"
	programs = list(new/datum/data/pda/app/request_console/tech_storage, \
					new/datum/data/pda/app/request_console/ai, \
					new/datum/data/pda/app/request_console/bridge, \
					new/datum/data/pda/app/request_console/chief_engineer_desk, \
					new/datum/data/pda/app/request_console/mechanic, \
					new/datum/data/pda/app/request_console/engineering, \
					new/datum/data/pda/app/request_console/atmospherics)

/obj/item/cartridge/request_console/cmo
	name = "CMO Request"
	programs = list(new/datum/data/pda/app/request_console/medbay, \
					new/datum/data/pda/app/request_console/morgue, \
					new/datum/data/pda/app/request_console/genetics, \
					new/datum/data/pda/app/request_console/chief_medical_officer_desk, \
					new/datum/data/pda/app/request_console/virology, \
					new/datum/data/pda/app/request_console/chemistry)

/obj/item/cartridge/request_console/rd
	name = "RD Request"
	programs = list(new/datum/data/pda/app/request_console/ai, \
					new/datum/data/pda/app/request_console/research, \
					new/datum/data/pda/app/request_console/genetics, \
					new/datum/data/pda/app/request_console/bridge, \
					new/datum/data/pda/app/request_console/research_director_desk, \
					new/datum/data/pda/app/request_console/robotics, \
					new/datum/data/pda/app/request_console/xenobiology, \
					new/datum/data/pda/app/request_console/genetics, \
					new/datum/data/pda/app/request_console/science)

/obj/item/cartridge/request_console/captain
	name = "Captain Request"
	programs = list(new/datum/data/pda/app/request_console/ai, \
					new/datum/data/pda/app/request_console/head_of_personnel_desk, \
					new/datum/data/pda/app/request_console/head_of_security_desk, \
					new/datum/data/pda/app/request_console/bridge, \
					new/datum/data/pda/app/request_console/research_director_desk, \
					new/datum/data/pda/app/request_console/chief_engineer_desk, \
					new/datum/data/pda/app/request_console/chief_medical_officer_desk, \
					new/datum/data/pda/app/request_console/quartermaster_desk, \
					new/datum/data/pda/app/request_console/captain_desk)


/obj/item/cartridge/request_console/ntrep
	name = "NTR Request"
	programs = list(new/datum/data/pda/app/request_console/nt_representative, \
					new/datum/data/pda/app/request_console/blueshield, \
					new/datum/data/pda/app/request_console/internal_affairs_office, \
					new/datum/data/pda/app/request_console/bridge)

/obj/item/cartridge/request_console/magistrate
	name = "Magistrate Request"
	programs = list(new/datum/data/pda/app/request_console/internal_affairs_office, \
					new/datum/data/pda/app/request_console/bridge)

/obj/item/cartridge/request_console/blueshield
	name = "Blueshield Request"
	programs = list(new/datum/data/pda/app/request_console/blueshield, \
					new/datum/data/pda/app/request_console/bridge)

/obj/item/cartridge/request_console/cargo
	name = "Cargo Request"
	programs = list(new/datum/data/pda/app/request_console/cargo_bay)

/obj/item/cartridge/request_console/quartermaster
	name = "QM Request"
	programs = list(new/datum/data/pda/app/request_console/cargo_bay, \
					new/datum/data/pda/app/request_console/quartermaster_desk, \
					new/datum/data/pda/app/request_console/bridge)

/obj/item/cartridge/request_console/shaftminer
	name = "Shaftminer Request"
	programs = list(new/datum/data/pda/app/request_console/cargo_bay)

/obj/item/cartridge/request_console/chaplain
	name = "Chaplain Request"
	programs = list(new/datum/data/pda/app/request_console/chapel)

/obj/item/cartridge/request_console/lawyer
	name = "Internal Affairs Request"
	programs = list(new/datum/data/pda/app/request_console/internal_affairs_office)

/obj/item/cartridge/request_console/botanist
	name = "Botanist Request"
	programs = list(new/datum/data/pda/app/request_console/hydroponics)

/obj/item/cartridge/request_console/roboticist
	name = "Roboticist Request"
	programs = list(new/datum/data/pda/app/request_console/robotics, \
					new/datum/data/pda/app/request_console/research, \
					new/datum/data/pda/app/request_console/science)

/obj/item/cartridge/request_console/chef
	name = "Chef Request"
	programs = list(new/datum/data/pda/app/request_console/kitchen)

/obj/item/cartridge/request_console/bar
	name = "Bartender Request"
	programs = list(new/datum/data/pda/app/request_console/bar)

/obj/item/cartridge/request_console/atmos
	name = "Atmospherics Request"
	programs = list(new/datum/data/pda/app/request_console/tech_storage, \
					new/datum/data/pda/app/request_console/atmospherics, \
					new/datum/data/pda/app/request_console/engineering)

/obj/item/cartridge/request_console/chemist
	name = "Chemist Request"
	programs = list(new/datum/data/pda/app/request_console/chemistry, \
					new/datum/data/pda/app/request_console/medbay)

/obj/item/cartridge/request_console/geneticist
	name = "Geneticist Request"
	programs = list(new/datum/data/pda/app/request_console/genetics, \
					new/datum/data/pda/app/request_console/medbay)

/obj/item/cartridge/request_console/clown_security
	name = "Clown Security Request"
	programs = list(new/datum/data/pda/app/request_console/security)

/obj/item/cartridge/request_console/centcom
	name = "Centcom Request"
	programs = list(new/datum/data/pda/app/request_console/ai, \
					new/datum/data/pda/app/request_console/blueshield, \
					new/datum/data/pda/app/request_console/internal_affairs_office, \
					new/datum/data/pda/app/request_console/bridge, \
					new/datum/data/pda/app/request_console/central_command, \
					new/datum/data/pda/app/request_console/nt_representative, \
					new/datum/data/pda/app/request_console/captain_desk)

