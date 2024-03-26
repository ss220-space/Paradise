
GLOBAL_LIST_EMPTY(assistant_occupations)


GLOBAL_LIST_INIT(command_positions, list(
	JOB_TITLE_CAPTAIN,
	JOB_TITLE_HOP,
	JOB_TITLE_HOS,
	JOB_TITLE_CHIEF,
	JOB_TITLE_RD,
	JOB_TITLE_CMO,
	JOB_TITLE_REPRESENTATIVE
))


GLOBAL_LIST_INIT(engineering_positions, list(
	JOB_TITLE_CHIEF,
	JOB_TITLE_ENGINEER,
	JOB_TITLE_ATMOSTECH,
	JOB_TITLE_MECHANIC,
	JOB_TITLE_ENGINEER_TRAINEE
))


GLOBAL_LIST_INIT(medical_positions, list(
	JOB_TITLE_CMO,
	JOB_TITLE_DOCTOR,
	JOB_TITLE_GENETICIST,
	JOB_TITLE_PSYCHIATRIST,
	JOB_TITLE_CHEMIST,
	JOB_TITLE_VIROLOGIST,
	JOB_TITLE_PARAMEDIC,
	JOB_TITLE_CORONER,
	JOB_TITLE_INTERN
))

GLOBAL_LIST_INIT(additional_medical_positions, list(
	JOB_TITLE_BRIGDOC // So they will not be part of medical in crew manifest
))

GLOBAL_LIST_INIT(science_positions, list(
	JOB_TITLE_RD,
	JOB_TITLE_SCIENTIST,
	JOB_TITLE_GENETICIST,	//Part of both medical and science
	JOB_TITLE_ROBOTICIST,
	JOB_TITLE_SCIENTIST_STUDENT
))

GLOBAL_LIST_INIT(security_positions, list(
	JOB_TITLE_HOS,
	JOB_TITLE_WARDEN,
	JOB_TITLE_DETECTIVE,
	JOB_TITLE_OFFICER,
	JOB_TITLE_BRIGDOC,
	JOB_TITLE_PILOT,
	JOB_TITLE_JUDGE
))

GLOBAL_LIST_INIT(technically_security_positions,(
	security_positions - list(JOB_TITLE_BRIGDOC) // Add here jobs, that are security, but **do not shitcurs** (or you dont want them give them exp)
))

//BS12 EDIT
GLOBAL_LIST_INIT(support_positions, list(
	JOB_TITLE_HOP,
	JOB_TITLE_BARTENDER,
	JOB_TITLE_BOTANIST,
	JOB_TITLE_CHEF,
	JOB_TITLE_JANITOR,
	JOB_TITLE_LIBRARIAN,
	JOB_TITLE_QUARTERMASTER,
	JOB_TITLE_CARGOTECH,
	JOB_TITLE_MINER,
	JOB_TITLE_LAWYER,
	JOB_TITLE_CHAPLAIN,
	JOB_TITLE_CLOWN,
	JOB_TITLE_MIME,
	JOB_TITLE_BARBER,
	JOB_TITLE_JUDGE,
	JOB_TITLE_REPRESENTATIVE,
	JOB_TITLE_BLUESHIELD,
	JOB_TITLE_EXPLORER
))

GLOBAL_LIST_INIT(supply_positions, list(
	JOB_TITLE_HOP,
	JOB_TITLE_QUARTERMASTER,
	JOB_TITLE_CARGOTECH,
	JOB_TITLE_MINER
))

GLOBAL_LIST_INIT(service_positions, (list(JOB_TITLE_HOP) + (support_positions - supply_positions)))

GLOBAL_LIST_INIT(civilian_positions, list(
	JOB_TITLE_CIVILIAN
))

GLOBAL_LIST_INIT(nonhuman_positions, list(
	JOB_TITLE_AI,
	JOB_TITLE_CYBORG,
	"Drone",
	"pAI"
))

GLOBAL_LIST_INIT(whitelisted_positions, list(
	JOB_TITLE_BLUESHIELD,
	JOB_TITLE_REPRESENTATIVE,
	JOB_TITLE_BARBER,
	JOB_TITLE_MECHANIC,
	JOB_TITLE_BRIGDOC,
	JOB_TITLE_JUDGE,
	JOB_TITLE_PILOT,
))


/proc/guest_jobbans(var/job)
	return (job in GLOB.whitelisted_positions)

/proc/get_job_datums()
	var/list/occupations = list()
	var/list/all_jobs = typesof(/datum/job)

	for(var/A in all_jobs)
		var/datum/job/job = new A()
		if(!job)	continue
		occupations += job

	return occupations

/proc/get_alternate_titles(var/job)
	var/list/jobs = get_job_datums()
	var/list/titles = list()

	for(var/datum/job/J in jobs)
		if(!J)	continue
		if(J.title == job)
			titles = J.alt_titles

	return titles

GLOBAL_LIST_INIT(exp_jobsmap, list(
	EXP_TYPE_LIVING = list(), // all living mobs
	EXP_TYPE_CREW = list(titles = command_positions | engineering_positions | medical_positions | science_positions | support_positions | supply_positions | security_positions | civilian_positions | list(JOB_TITLE_AI, JOB_TITLE_CYBORG) | whitelisted_positions), // crew positions
	EXP_TYPE_SPECIAL = list(), // antags, ERT, etc
	EXP_TYPE_GHOST = list(), // dead people, observers
	EXP_TYPE_EXEMPT = list(), // special grandfather setting
	EXP_TYPE_COMMAND = list(titles = command_positions),
	EXP_TYPE_ENGINEERING = list(titles = engineering_positions),
	EXP_TYPE_MEDICAL = list(titles = medical_positions | additional_medical_positions),
	EXP_TYPE_SCIENCE = list(titles = science_positions),
	EXP_TYPE_SUPPLY = list(titles = supply_positions),
	EXP_TYPE_SECURITY = list(titles = technically_security_positions),
	EXP_TYPE_SILICON = list(titles = list(JOB_TITLE_AI, JOB_TITLE_CYBORG)),
	EXP_TYPE_SERVICE = list(titles = service_positions),
	EXP_TYPE_WHITELIST = list(titles = whitelisted_positions), // karma-locked jobs
	EXP_TYPE_BASE_TUTORIAL = list(), // is basic tutorial complete
))
