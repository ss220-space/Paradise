GLOBAL_LIST_INIT(station_departments, list("Command", "Medical", "Engineering", "Science", "Security", "Cargo", "Support", "Civilian", "Silicon", "Law", "Representative", "Antag", "Central"))

// The department the job belongs to.
/datum/job/var/department = null

// Whether this is a head position
/datum/job/var/head_position = 0


//============КОМАНДОВАНИЕ============

/datum/job/captain/department = "Command"
/datum/job/captain/head_position = 1

//============ПРЕДСТАВИТЕЛЬСТВО============

/datum/job/nanotrasenrep/department = "Representative"
/datum/job/nanotrasenrep/head_position = 1

/datum/job/blueshield/department = "Representative"


//============ЗАКОН============

/datum/job/judge/department = "Law"
/datum/job/judge/head_position = 1

/datum/job/lawyer/department = "Law"


//============РНД============

/datum/job/rd/department = "Science"
/datum/job/rd/head_position = 1

/datum/job/scientist/department = "Science"

/datum/job/roboticist/department = "Science"


//============СБ============

/datum/job/hos/department = "Security"
/datum/job/hos/head_position = 1

/datum/job/warden/department = "Security"

/datum/job/detective/department = "Security"

/datum/job/officer/department = "Security"

/datum/job/brigdoc/department = "Security"

/datum/job/pilot/department = "Security"


//============МЕДИЦИНА============

/datum/job/cmo/department = "Medical"
/datum/job/cmo/head_position = 1

/datum/job/doctor/department = "Medical"

/datum/job/chemist/department = "Medical"

/datum/job/geneticist/department = "Medical"

/datum/job/psychiatrist/department = "Medical"

/datum/job/coroner/department = "Medical"

/datum/job/virologist/department = "Medical"

/datum/job/paramedic/department = "Medical"


//============ИНЖЕНЕРИЯ============

/datum/job/chief_engineer/department = "Engineering"
/datum/job/chief_engineer/head_position = 1

/datum/job/engineer/department = "Engineering"

/datum/job/atmos/department = "Engineering"

/datum/job/mechanic/department = "Engineering"


//============СЕРВИС============

/datum/job/hop/department = "Support"
/datum/job/hop/head_position = 1

/datum/job/bartender/department = "Support"

/datum/job/chef/department = "Support"

/datum/job/hydro/department = "Support"

/datum/job/janitor/department = "Support"

/datum/job/librarian/department = "Support"

/datum/job/chaplain/department = "Support"

/datum/job/clown/department = "Support"

/datum/job/mime/department = "Support"

/datum/job/barber/department = "Support"

/datum/job/explorer/department = "Support"

//============СНАБЖЕНИЕ============

/datum/job/qm/department = "Cargo"
/datum/job/qm/head_position = 1

/datum/job/cargo_tech/department = "Cargo"

/datum/job/mining/department = "Cargo"


//============ОБЩИЙ============

/datum/job/civilian/department = "Civilian"


//============АНТАГОНИЗМ============

/datum/job/syndicateofficer/department = "Antag"


//============СИНТЕТИКИ============

/datum/job/ai/department = "Silicon"
/datum/job/ai/head_position = 1

/datum/job/cyborg/department = "Silicon"

//============ЦЕНТРАЛЬНОЕ КОМАНДОВАНИЕ============

/datum/job/ntnavyofficer/department = "Central"
/datum/job/ntnavyofficer/head_position = 1

/datum/job/ntspecops/department = "Central"
/datum/job/ntspecops/head_position = 1
