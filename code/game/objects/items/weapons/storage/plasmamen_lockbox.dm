/obj/item/storage/lockbox/plasma
	name = "Plasmamen equipment lockbox"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов",
		GENITIVE = "ящика снаряжения для плазмаменов",
		DATIVE = "ящику снаряжения для плазмаменов",
		ACCUSATIVE = "ящик снаряжения для плазмаменов",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов"
	)
	desc = "Ящик с замком, что содержит набор снаряжения для плазмаменов. Сомнительно, что любое разумное существо будет способно уложить содержимое столь же плотно."
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = WEIGHT_CLASS_SMALL
	storage_slots = 4

/obj/item/storage/lockbox/plasma/barmen
	name = "Plasmamen equipment (Bartender)"
	req_access = list(ACCESS_BAR)

/obj/item/storage/lockbox/plasma/barmen/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/white(src)
	new /obj/item/clothing/under/plasmaman/enviroslacks(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/nt_rep
	name = "Plasmamen equipment (NanoTrasen Representative)"
	req_access = list(ACCESS_NTREP)

/obj/item/storage/lockbox/plasma/nt_rep/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/nt_rep(src)
	new /obj/item/clothing/under/plasmaman/nt(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/chef
	name = "Plasmamen equipment (Chef)"
	req_access = list(ACCESS_KITCHEN)

/obj/item/storage/lockbox/plasma/chef/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/chef(src)
	new /obj/item/clothing/under/plasmaman/chef(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/botany
	name = "Plasmamen equipment (Botanist)"
	req_access = list(ACCESS_HYDROPONICS)

/obj/item/storage/lockbox/plasma/botany/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/botany(src)
	new /obj/item/clothing/under/plasmaman/botany(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/librarian
	name = "Plasmamen equipment (Librarian)"
	req_access = list(ACCESS_LIBRARY)

/obj/item/storage/lockbox/plasma/Librarian/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/chaplain(src)
	new /obj/item/clothing/under/plasmaman/chaplain(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/janitor
	name = "Plasmamen equipment (Janitor)"
	req_access = list(ACCESS_JANITOR)

/obj/item/storage/lockbox/plasma/janitor/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/janitor(src)
	new /obj/item/clothing/under/plasmaman/janitor(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/sec
	name = "Plasmamen equipment (Security Officer)"
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/plasma/sec/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/security(src)
	new /obj/item/clothing/under/plasmaman/security(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/pilot
	name = "Plasmamen equipment (Security Pod Pilot)"
	req_access = list(ACCESS_PILOT)

/obj/item/storage/lockbox/plasma/pilot/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/security(src)
	new /obj/item/clothing/under/plasmaman/security(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/det
	name = "Plasmamen equipment (Detective)"
	req_access = list(ACCESS_FORENSICS_LOCKERS)

/obj/item/storage/lockbox/plasma/det/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/security/dec(src)
	new /obj/item/clothing/under/plasmaman/enviroslacks(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/warden
	name = "Plasmamen equipment (Warden)"
	req_access = list(ACCESS_ARMORY)

/obj/item/storage/lockbox/plasma/warden/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/security/warden(src)
	new /obj/item/clothing/under/plasmaman/security/warden(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/hos
	name = "Plasmamen equipment (Head of Security)"
	req_access = list(ACCESS_HOS)

/obj/item/storage/lockbox/plasma/hos/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/security/hos(src)
	new /obj/item/clothing/under/plasmaman/security/hos(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/cargo
	name = "Plasmamen equipment (Cargo Technician)"
	req_access = list(ACCESS_CARGO)

/obj/item/storage/lockbox/plasma/cargo/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/cargo(src)
	new /obj/item/clothing/under/plasmaman/cargo(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/qm
	name = "Plasmamen equipment (Quartermaster)"
	req_access = list(ACCESS_QM)

/obj/item/storage/lockbox/plasma/qm/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/qm(src)
	new /obj/item/clothing/under/plasmaman/qm(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/miner
	name = "Plasmamen equipment (Miner)"
	req_access = list(ACCESS_MINING)

/obj/item/storage/lockbox/plasma/miner/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/mining(src)
	new /obj/item/clothing/under/plasmaman/mining(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/medic
	name = "Plasmamen equipment (Medical Doctor)"
	req_access = list(ACCESS_MEDICAL)

/obj/item/storage/lockbox/plasma/medic/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/medical(src)
	new /obj/item/clothing/under/plasmaman/medical(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/brig_med
	name = "Plasmamen equipment (Brig Physician)"
	req_access = list(ACCESS_BRIG)

/obj/item/storage/lockbox/plasma/brig_med/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/medical/brigphysician(src)
	new /obj/item/clothing/under/plasmaman/brigphysician(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/paramedic
	name = "Plasmamen equipment (Paramedic)"
	req_access = list(ACCESS_PARAMEDIC)

/obj/item/storage/lockbox/plasma/paramedic/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/medical/paramedic(src)
	new /obj/item/clothing/under/plasmaman/paramedic(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/coroner
	name = "Plasmamen equipment (Coroner)"
	req_access = list(ACCESS_MORGUE)

/obj/item/storage/lockbox/plasma/coroner/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/medical/coroner(src)
	new /obj/item/clothing/under/plasmaman/coroner(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/cmo
	name = "Plasmamen equipment (Chief Medical Officer)"
	req_access = list(ACCESS_CMO)

/obj/item/storage/lockbox/plasma/cmo/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/cmo(src)
	new /obj/item/clothing/under/plasmaman/cmo(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/viro
	name = "Plasmamen equipment (Virologist)"
	req_access = list(ACCESS_VIROLOGY)

/obj/item/storage/lockbox/plasma/viro/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/viro(src)
	new /obj/item/clothing/under/plasmaman/viro(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/chemist
	name = "Plasmamen equipment (Chemist)"
	req_access = list(ACCESS_CHEMISTRY)

/obj/item/storage/lockbox/plasma/chemist/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/chemist(src)
	new /obj/item/clothing/under/plasmaman/chemist(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/genetic
	name = "Plasmamen equipment (Genetic)"
	req_access = list(ACCESS_GENETICS)

/obj/item/storage/lockbox/plasma/genetic/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/genetics(src)
	new /obj/item/clothing/under/plasmaman/genetics(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/scientist
	name = "Plasmamen equipment (Scientist)"
	req_access = list(ACCESS_RESEARCH)

/obj/item/storage/lockbox/plasma/scientist/populate_contents(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/science/xeno(src)
	new /obj/item/clothing/under/plasmaman/science(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/rd
	name = "Plasmamen equipment (Research Director)"
	req_access = list(ACCESS_RD)

/obj/item/storage/lockbox/plasma/rd/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/rd(src)
	new /obj/item/clothing/under/plasmaman/rd(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/robot
	name = "Plasmamen equipment (Robotician)"
	req_access = list(ACCESS_ROBOTICS)

/obj/item/storage/lockbox/plasma/robot/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/robotics(src)
	new /obj/item/clothing/under/plasmaman/robotics(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/engineer
	name = "Plasmamen equipment (Engineer)"
	req_access = list(ACCESS_ENGINE)

/obj/item/storage/lockbox/plasma/engineer/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/engineering(src)
	new /obj/item/clothing/under/plasmaman/engineering(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/mechanic
	name = "Plasmamen equipment (Mechanic)"
	req_access = list(ACCESS_MECHANIC)

/obj/item/storage/lockbox/plasma/mechanic/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/engineering/mecha(src)
	new /obj/item/clothing/under/plasmaman/mechanic(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/ce
	name = "Plasmamen equipment (Chief Engineer)"
	req_access = list(ACCESS_CE)

/obj/item/storage/lockbox/plasma/ce/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/engineering/ce
	new /obj/item/clothing/under/plasmaman/engineering/ce
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/atmos
	name = "Plasmamen equipment (Atmospheric Technician)"
	req_access = list(ACCESS_ATMOSPHERICS)

/obj/item/storage/lockbox/plasma/atmos/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/atmospherics(src)
	new /obj/item/clothing/under/plasmaman/atmospherics(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/mime
	name = "Plasmamen equipment (Mime)"
	req_access = list(ACCESS_MIME)

/obj/item/storage/lockbox/plasma/mime/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/mime(src)
	new /obj/item/clothing/under/plasmaman/mime(src)
	new /obj/item/clothing/mask/gas/mime(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)

/obj/item/storage/lockbox/plasma/clown
	name = "Plasmamen equipment (Clown)"
	req_access = list(ACCESS_CLOWN)

/obj/item/storage/lockbox/plasma/clown/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/clown(src)
	new /obj/item/clothing/under/plasmaman/clown(src)
	new /obj/item/clothing/mask/gas/clown_hat(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)

/obj/item/storage/lockbox/plasma/hop
	name = "Plasmamen equipment (Head of Personnel)"
	req_access = list(ACCESS_HOP)

/obj/item/storage/lockbox/plasma/hop/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/hop(src)
	new /obj/item/clothing/under/plasmaman/hop(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/blueshield
	name = "Plasmamen equipment (Blueshield)"
	req_access = list(ACCESS_BLUESHIELD)

/obj/item/storage/lockbox/plasma/blueshield/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/blueshield(src)
	new /obj/item/clothing/under/plasmaman/blueshield(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/captain
	name = "Plasmamen equipment (Captain)"
	req_access = list(ACCESS_CAPTAIN)

/obj/item/storage/lockbox/plasma/captain/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/captain(src)
	new /obj/item/clothing/under/plasmaman/captain(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)
