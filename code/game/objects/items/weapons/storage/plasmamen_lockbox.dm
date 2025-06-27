/obj/item/storage/lockbox/plasma
	name = "Plasmamen equipment lockbox"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (N/A)",
		GENITIVE = "ящика снаряжения для плазмаменов (N/A)",
		DATIVE = "ящику снаряжения для плазмаменов (N/A)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (N/A)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (N/A)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (N/A)"
	)
	desc = "Ящик с замком, что содержит набор снаряжения для плазмаменов. Сомнительно, что любое разумное существо будет способно уложить содержимое столь же плотно."
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = WEIGHT_CLASS_SMALL
	storage_slots = 4

/obj/item/storage/lockbox/plasma/barmen
	name = "Plasmamen equipment (Bartender)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Bartender)",
		GENITIVE = "ящика снаряжения для плазмаменов (Bartender)",
		DATIVE = "ящику снаряжения для плазмаменов (Bartender)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Bartender)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Bartender)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Bartender)"
	)
	req_access = list(ACCESS_BAR)

/obj/item/storage/lockbox/plasma/barmen/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/white(src)
	new /obj/item/clothing/under/plasmaman/enviroslacks(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/nt_rep
	name = "Plasmamen equipment (NanoTrasen Representative)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (NanoTrasen Representative)",
		GENITIVE = "ящика снаряжения для плазмаменов (NanoTrasen Representative)",
		DATIVE = "ящику снаряжения для плазмаменов (NanoTrasen Representative)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (NanoTrasen Representative)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (NanoTrasen Representative)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (NanoTrasen Representative)"
	)
	req_access = list(ACCESS_NTREP)

/obj/item/storage/lockbox/plasma/nt_rep/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/nt_rep(src)
	new /obj/item/clothing/under/plasmaman/nt(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/chef
	name = "Plasmamen equipment (Chef)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Chef)",
		GENITIVE = "ящика снаряжения для плазмаменов (Chef)",
		DATIVE = "ящику снаряжения для плазмаменов (Chef)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Chef)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Chef)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Chef)"
	)
	req_access = list(ACCESS_KITCHEN)

/obj/item/storage/lockbox/plasma/chef/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/chef(src)
	new /obj/item/clothing/under/plasmaman/chef(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/botany
	name = "Plasmamen equipment (Botanist)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Botanist)",
		GENITIVE = "ящика снаряжения для плазмаменов (Botanist)",
		DATIVE = "ящику снаряжения для плазмаменов (Botanist)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Botanist)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Botanist)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Botanist)"
	)
	req_access = list(ACCESS_HYDROPONICS)

/obj/item/storage/lockbox/plasma/botany/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/botany(src)
	new /obj/item/clothing/under/plasmaman/botany(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/librarian
	name = "Plasmamen equipment (Librarian)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Librarian)",
		GENITIVE = "ящика снаряжения для плазмаменов (Librarian)",
		DATIVE = "ящику снаряжения для плазмаменов (Librarian)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Librarian)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Librarian)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Librarian)"
	)
	req_access = list(ACCESS_LIBRARY)

/obj/item/storage/lockbox/plasma/Librarian/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/chaplain(src)
	new /obj/item/clothing/under/plasmaman/chaplain(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/janitor
	name = "Plasmamen equipment (Janitor)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Janitor)",
		GENITIVE = "ящика снаряжения для плазмаменов (Janitor)",
		DATIVE = "ящику снаряжения для плазмаменов (Janitor)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Janitor)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Janitor)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Janitor)"
	)
	req_access = list(ACCESS_JANITOR)

/obj/item/storage/lockbox/plasma/janitor/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/janitor(src)
	new /obj/item/clothing/under/plasmaman/janitor(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/sec
	name = "Plasmamen equipment (Security Officer)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Security Officer)",
		GENITIVE = "ящика снаряжения для плазмаменов (Security Officer)",
		DATIVE = "ящику снаряжения для плазмаменов (Security Officer)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Security Officer)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Security Officer)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Security Officer)"
	)
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/plasma/sec/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/security(src)
	new /obj/item/clothing/under/plasmaman/security(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/pilot
	name = "Plasmamen equipment (Security Pod Pilot)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Security Pod Pilot)",
		GENITIVE = "ящика снаряжения для плазмаменов (Security Pod Pilot)",
		DATIVE = "ящику снаряжения для плазмаменов (Security Pod Pilot)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Security Pod Pilot)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Security Pod Pilot)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Security Pod Pilot)"
	)
	req_access = list(ACCESS_PILOT)

/obj/item/storage/lockbox/plasma/pilot/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/security(src)
	new /obj/item/clothing/under/plasmaman/security(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/det
	name = "Plasmamen equipment (Detective)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Detective)",
		GENITIVE = "ящика снаряжения для плазмаменов (Detective)",
		DATIVE = "ящику снаряжения для плазмаменов (Detective)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Detective)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Detective)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Detective)"
	)
	req_access = list(ACCESS_FORENSICS_LOCKERS)

/obj/item/storage/lockbox/plasma/det/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/security/dec(src)
	new /obj/item/clothing/under/plasmaman/enviroslacks(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/warden
	name = "Plasmamen equipment (Warden)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Warden)",
		GENITIVE = "ящика снаряжения для плазмаменов (Warden)",
		DATIVE = "ящику снаряжения для плазмаменов (Warden)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Warden)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Warden)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Warden)"
	)
	req_access = list(ACCESS_ARMORY)

/obj/item/storage/lockbox/plasma/warden/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/security/warden(src)
	new /obj/item/clothing/under/plasmaman/security/warden(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/hos
	name = "Plasmamen equipment (Head of Security)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Head of Security)",
		GENITIVE = "ящика снаряжения для плазмаменов (Head of Security)",
		DATIVE = "ящику снаряжения для плазмаменов (Head of Security)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Head of Security)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Head of Security)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Head of Security)"
	)
	req_access = list(ACCESS_HOS)

/obj/item/storage/lockbox/plasma/hos/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/security/hos(src)
	new /obj/item/clothing/under/plasmaman/security/hos(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/cargo
	name = "Plasmamen equipment (Cargo Technician)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Cargo Technician)",
		GENITIVE = "ящика снаряжения для плазмаменов (Cargo Technician)",
		DATIVE = "ящику снаряжения для плазмаменов (Cargo Technician)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Cargo Technician)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Cargo Technician)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Cargo Technician)"
	)
	req_access = list(ACCESS_CARGO)

/obj/item/storage/lockbox/plasma/cargo/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/cargo(src)
	new /obj/item/clothing/under/plasmaman/cargo(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/qm
	name = "Plasmamen equipment (Quartermaster)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Quartermaster)",
		GENITIVE = "ящика снаряжения для плазмаменов (Quartermaster)",
		DATIVE = "ящику снаряжения для плазмаменов (Quartermaster)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Quartermaster)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Quartermaster)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Quartermaster)"
	)
	req_access = list(ACCESS_QM)

/obj/item/storage/lockbox/plasma/qm/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/qm(src)
	new /obj/item/clothing/under/plasmaman/qm(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/miner
	name = "Plasmamen equipment (Miner)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Miner)",
		GENITIVE = "ящика снаряжения для плазмаменов (Miner)",
		DATIVE = "ящику снаряжения для плазмаменов (Miner)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Miner)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Miner)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Miner)"
	)
	req_access = list(ACCESS_MINING)

/obj/item/storage/lockbox/plasma/miner/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/mining(src)
	new /obj/item/clothing/under/plasmaman/mining(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/medic
	name = "Plasmamen equipment (Medical Doctor)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Medical Doctor)",
		GENITIVE = "ящика снаряжения для плазмаменов (Medical Doctor)",
		DATIVE = "ящику снаряжения для плазмаменов (Medical Doctor)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Medical Doctor)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Medical Doctor)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Medical Doctor)"
	)
	req_access = list(ACCESS_MEDICAL)

/obj/item/storage/lockbox/plasma/medic/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/medical(src)
	new /obj/item/clothing/under/plasmaman/medical(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/brig_med
	name = "Plasmamen equipment (Brig Physician)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Brig Physician)",
		GENITIVE = "ящика снаряжения для плазмаменов (Brig Physician)",
		DATIVE = "ящику снаряжения для плазмаменов (Brig Physician)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Brig Physician)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Brig Physician)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Brig Physician)"
	)
	req_access = list(ACCESS_BRIG)

/obj/item/storage/lockbox/plasma/brig_med/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/medical/brigphysician(src)
	new /obj/item/clothing/under/plasmaman/brigphysician(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/paramedic
	name = "Plasmamen equipment (Paramedic)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Paramedic)",
		GENITIVE = "ящика снаряжения для плазмаменов (Paramedic)",
		DATIVE = "ящику снаряжения для плазмаменов (Paramedic)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Paramedic)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Paramedic)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Paramedic)"
	)
	req_access = list(ACCESS_PARAMEDIC)

/obj/item/storage/lockbox/plasma/paramedic/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/medical/paramedic(src)
	new /obj/item/clothing/under/plasmaman/paramedic(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/coroner
	name = "Plasmamen equipment (Coroner)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Coroner)",
		GENITIVE = "ящика снаряжения для плазмаменов (Coroner)",
		DATIVE = "ящику снаряжения для плазмаменов (Coroner)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Coroner)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Coroner)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Coroner)"
	)
	req_access = list(ACCESS_MORGUE)

/obj/item/storage/lockbox/plasma/coroner/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/medical/coroner(src)
	new /obj/item/clothing/under/plasmaman/coroner(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/cmo
	name = "Plasmamen equipment (Chief Medical Officer)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Chief Medical Officer))",
		GENITIVE = "ящика снаряжения для плазмаменов (Chief Medical Officer))",
		DATIVE = "ящику снаряжения для плазмаменов (Chief Medical Officer))",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Chief Medical Officer))",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Chief Medical Officer))",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Chief Medical Officer))"
	)
	req_access = list(ACCESS_CMO)

/obj/item/storage/lockbox/plasma/cmo/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/cmo(src)
	new /obj/item/clothing/under/plasmaman/cmo(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/viro
	name = "Plasmamen equipment (Virologist)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Virologist)",
		GENITIVE = "ящика снаряжения для плазмаменов (Virologist)",
		DATIVE = "ящику снаряжения для плазмаменов (Virologist)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Virologist)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Virologist)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Virologist)"
	)
	req_access = list(ACCESS_VIROLOGY)

/obj/item/storage/lockbox/plasma/viro/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/viro(src)
	new /obj/item/clothing/under/plasmaman/viro(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/chemist
	name = "Plasmamen equipment (Chemist)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Chemist)",
		GENITIVE = "ящика снаряжения для плазмаменов (Chemist)",
		DATIVE = "ящику снаряжения для плазмаменов (Chemist)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Chemist)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Chemist)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Chemist)"
	)
	req_access = list(ACCESS_CHEMISTRY)

/obj/item/storage/lockbox/plasma/chemist/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/chemist(src)
	new /obj/item/clothing/under/plasmaman/chemist(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/genetic
	name = "Plasmamen equipment (Genetic)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Genetic)",
		GENITIVE = "ящика снаряжения для плазмаменов (Genetic)",
		DATIVE = "ящику снаряжения для плазмаменов (Genetic)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Genetic)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Genetic)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Genetic)"
	)
	req_access = list(ACCESS_GENETICS)

/obj/item/storage/lockbox/plasma/genetic/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/genetics(src)
	new /obj/item/clothing/under/plasmaman/genetics(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/scientist
	name = "Plasmamen equipment (Scientist)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Scientist)",
		GENITIVE = "ящика снаряжения для плазмаменов (Scientist)",
		DATIVE = "ящику снаряжения для плазмаменов (Scientist)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Scientist)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Scientist)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Scientist)"
	)
	req_access = list(ACCESS_RESEARCH)

/obj/item/storage/lockbox/plasma/scientist/populate_contents(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/science/xeno(src)
	new /obj/item/clothing/under/plasmaman/science(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/rd
	name = "Plasmamen equipment (Research Director)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Research Director)",
		GENITIVE = "ящика снаряжения для плазмаменов (Research Director)",
		DATIVE = "ящику снаряжения для плазмаменов (Research Director)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Research Director)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Research Director)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Research Director)"
	)
	req_access = list(ACCESS_RD)

/obj/item/storage/lockbox/plasma/rd/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/rd(src)
	new /obj/item/clothing/under/plasmaman/rd(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/robot
	name = "Plasmamen equipment (Robotician)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Robotician)",
		GENITIVE = "ящика снаряжения для плазмаменов (Robotician)",
		DATIVE = "ящику снаряжения для плазмаменов (Robotician)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Robotician)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Robotician)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Robotician)"
	)
	req_access = list(ACCESS_ROBOTICS)

/obj/item/storage/lockbox/plasma/robot/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/robotics(src)
	new /obj/item/clothing/under/plasmaman/robotics(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/engineer
	name = "Plasmamen equipment (Engineer)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Engineer)",
		GENITIVE = "ящика снаряжения для плазмаменов (Engineer)",
		DATIVE = "ящику снаряжения для плазмаменов (Engineer)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Engineer)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Engineer)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Engineer)"
	)
	req_access = list(ACCESS_ENGINE)

/obj/item/storage/lockbox/plasma/engineer/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/engineering(src)
	new /obj/item/clothing/under/plasmaman/engineering(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/mechanic
	name = "Plasmamen equipment (Mechanic)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Mechanic)",
		GENITIVE = "ящика снаряжения для плазмаменов (Mechanic)",
		DATIVE = "ящику снаряжения для плазмаменов (Mechanic)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Mechanic)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Mechanic)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Mechanic)"
	)
	req_access = list(ACCESS_MECHANIC)

/obj/item/storage/lockbox/plasma/mechanic/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/engineering/mecha(src)
	new /obj/item/clothing/under/plasmaman/mechanic(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/ce
	name = "Plasmamen equipment (Chief Engineer)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Chief Engineer)",
		GENITIVE = "ящика снаряжения для плазмаменов (Chief Engineer)",
		DATIVE = "ящику снаряжения для плазмаменов (Chief Engineer)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Chief Engineer)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Chief Engineer)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Chief Engineer)"
	)
	req_access = list(ACCESS_CE)

/obj/item/storage/lockbox/plasma/ce/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/engineering/ce
	new /obj/item/clothing/under/plasmaman/engineering/ce
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/atmos
	name = "Plasmamen equipment (Atmospheric Technician)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Atmospheric Technician)",
		GENITIVE = "ящика снаряжения для плазмаменов (Atmospheric Technician)",
		DATIVE = "ящику снаряжения для плазмаменов (Atmospheric Technician)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Atmospheric Technician)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Atmospheric Technician)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Atmospheric Technician)"
	)
	req_access = list(ACCESS_ATMOSPHERICS)

/obj/item/storage/lockbox/plasma/atmos/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/atmospherics(src)
	new /obj/item/clothing/under/plasmaman/atmospherics(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/mime
	name = "Plasmamen equipment (Mime)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Mime)",
		GENITIVE = "ящика снаряжения для плазмаменов (Mime)",
		DATIVE = "ящику снаряжения для плазмаменов (Mime)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Mime)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Mime)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Mime)"
	)
	req_access = list(ACCESS_MIME)

/obj/item/storage/lockbox/plasma/mime/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/mime(src)
	new /obj/item/clothing/under/plasmaman/mime(src)
	new /obj/item/clothing/mask/gas/mime(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)

/obj/item/storage/lockbox/plasma/clown
	name = "Plasmamen equipment (Clown)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Clown)",
		GENITIVE = "ящика снаряжения для плазмаменов (Clown)",
		DATIVE = "ящику снаряжения для плазмаменов (Clown)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Clown)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Clown)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Clown)"
	)
	req_access = list(ACCESS_CLOWN)

/obj/item/storage/lockbox/plasma/clown/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/clown(src)
	new /obj/item/clothing/under/plasmaman/clown(src)
	new /obj/item/clothing/mask/gas/clown_hat(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)

/obj/item/storage/lockbox/plasma/hop
	name = "Plasmamen equipment (Head of Personnel)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Head of Personnel)",
		GENITIVE = "ящика снаряжения для плазмаменов (Head of Personnel)",
		DATIVE = "ящику снаряжения для плазмаменов (Head of Personnel)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Head of Personnel)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Head of Personnel)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Head of Personnel)"
	)
	req_access = list(ACCESS_HOP)

/obj/item/storage/lockbox/plasma/hop/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/hop(src)
	new /obj/item/clothing/under/plasmaman/hop(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/blueshield
	name = "Plasmamen equipment (Blueshield)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Blueshield)",
		GENITIVE = "ящика снаряжения для плазмаменов (Blueshield)",
		DATIVE = "ящику снаряжения для плазмаменов (Blueshield)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Blueshield)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Blueshield)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Blueshield)"
	)
	req_access = list(ACCESS_BLUESHIELD)

/obj/item/storage/lockbox/plasma/blueshield/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/blueshield(src)
	new /obj/item/clothing/under/plasmaman/blueshield(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)

/obj/item/storage/lockbox/plasma/captain
	name = "Plasmamen equipment (Captain)"
	ru_names = list(
		NOMINATIVE = "ящик снаряжения для плазмаменов (Captain)",
		GENITIVE = "ящика снаряжения для плазмаменов (Captain)",
		DATIVE = "ящику снаряжения для плазмаменов (Captain)",
		ACCUSATIVE = "ящик снаряжения для плазмаменов (Captain)",
		INSTRUMENTAL = "ящиком снаряжения для плазмаменов (Captain)",
		PREPOSITIONAL = "ящике снаряжения для плазмаменов (Captain)"
	)
	req_access = list(ACCESS_CAPTAIN)

/obj/item/storage/lockbox/plasma/captain/populate_contents()
	new /obj/item/clothing/head/helmet/space/plasmaman/captain(src)
	new /obj/item/clothing/under/plasmaman/captain(src)
	new /obj/item/tank/internals/plasmaman/belt/full(src)
	new /obj/item/clothing/mask/breath(src)
