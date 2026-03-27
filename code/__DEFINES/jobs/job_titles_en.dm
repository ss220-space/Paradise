// MARK: Job Titles
// Defines below used as jobs' titles (from /tg/), credit to JohnFulpWillard

// Command (Solo command, not department heads)
#define JOB_TITLE_CAPTAIN "Captain"
#define JOB_TITLE_REPRESENTATIVE "Nanotrasen Representative"
#define JOB_TITLE_BLUESHIELD "Blueshield"

// Engineeering
#define JOB_TITLE_CHIEF_ENGINEER "Chief Engineer"
#define JOB_TITLE_ENGINEER "Station Engineer"
#define JOB_TITLE_ENGINEER_TRAINEE "Trainee Engineer"
#define JOB_TITLE_ATMOSTECH "Life Support Specialist"

// Medical
#define JOB_TITLE_CMO "Chief Medical Officer"
#define JOB_TITLE_DOCTOR "Medical Doctor"
#define JOB_TITLE_MEDICAL_INTERN "Intern"
#define JOB_TITLE_CORONER "Coroner"
#define JOB_TITLE_CHEMIST "Chemist"
#define JOB_TITLE_GENETICIST "Geneticist"
#define JOB_TITLE_VIROLOGIST "Virologist"
#define JOB_TITLE_PSYCHIATRIST "Psychiatrist"
#define JOB_TITLE_PARAMEDIC "Paramedic"

// Science
#define JOB_TITLE_RD "Research Director"
#define JOB_TITLE_SCIENTIST "Scientist"
#define JOB_TITLE_SCIENCE_STUDENT "Student Scientist"
#define JOB_TITLE_ROBOTICIST "Roboticist"
#define JOB_TITLE_SPACEPOD_TECHNICIAN "Spacepod Technician"

// Security
#define JOB_TITLE_HOS "Head of Security"
#define JOB_TITLE_WARDEN "Warden"
#define JOB_TITLE_DETECTIVE "Detective"
#define JOB_TITLE_OFFICER "Security Officer"
#define JOB_TITLE_BRIGDOC "Brig Physician"
#define JOB_TITLE_PILOT "Security Pod Pilot"

// Legal
#define JOB_TITLE_MAGISTRATE "Magistrate"
#define JOB_TITLE_LAWYER "Lawyer"

// Supply
#define JOB_TITLE_QUARTERMASTER "Quartermaster"
#define JOB_TITLE_CARGOTECH "Cargo Technician"
#define JOB_TITLE_MINER "Shaft Miner"
#define JOB_TITLE_MINING_MEDIC "Mining Medic"

// Service
#define JOB_TITLE_HOP "Head of Personnel"
#define JOB_TITLE_BARTENDER "Bartender"
#define JOB_TITLE_CHEF "Chef"
#define JOB_TITLE_BOTANIST "Botanist"
#define JOB_TITLE_CHAPLAIN "Chaplain"
#define JOB_TITLE_CLOWN "Clown"
#define JOB_TITLE_MIME "Mime"
#define JOB_TITLE_JANITOR "Janitor"
#define JOB_TITLE_LIBRARIAN "Librarian"
#define JOB_TITLE_EXPLORER "Explorer"

// Assistant
#define JOB_TITLE_CIVILIAN "Civilian"
#define JOB_TITLE_PRISONER "Prisoner"

// Silicons
#define JOB_TITLE_AI "AI"
#define JOB_TITLE_CYBORG "Cyborg"

// Central Command
#define JOB_TITLE_CCOFFICER "Nanotrasen Navy Officer"
#define JOB_TITLE_CCFIELD "Nanotrasen Navy Field Officer"
#define JOB_TITLE_CCSPECOPS "Special Operations Officer"
#define JOB_TITLE_CCSUPREME "Supreme Commander"
#define JOB_TITLE_CCSOLGOV "Solar Federation General"

// Emergency Response Team (ERT)
#define JOB_TITLE_ERT_MEMBER "Emergency Response Team Member"
#define JOB_TITLE_ERT_LEADER "Emergency Response Team Leader"
#define JOB_TITLE_ERT_OFFICER "Emergency Response Team Officer"
#define JOB_TITLE_ERT_ENGINEER "Emergency Response Team Engineer"
#define JOB_TITLE_ERT_MEDIC "Emergency Response Team Medic"
#define JOB_TITLE_ERT_INQUISITOR "Emergency Response Team Inquisitor"
#define JOB_TITLE_ERT_JANITOR "Emergency Response Team Janitor"

// Syndicate
#define JOB_TITLE_SYNDICATE_OFFICER "Syndicate Officer"
#define JOB_TITLE_SYNDICATE_OPERATIVE "Syndicate Operative"
#define JOB_TITLE_SYNDICATE_OPERATIVE_LEADER "Syndicate Operative Leader"
#define JOB_TITLE_SYNDICATE_AGENT "Syndicate Agent"
#define JOB_TITLE_SYNDICATE_COMMANDO "Syndicate Commando"

// Vox
#define JOB_TITLE_VOX_RAIDER "Vox Raider"
#define JOB_TITLE_VOX_TRADER "Vox Trader"

// Battle teams de_kerberos_2
#define JOB_TITLE_TEAM1 "Team 1"
#define JOB_TITLE_TEAM2 "Team 2"
#define JOB_TITLE_TEAM3 "Team 3"

// Taipan
#define JOB_TITLE_TAIPAN_SCIENTIST "Space Base Syndicate Scientist"
#define JOB_TITLE_TAIPAN_MEDIC "Space Base Syndicate Medic"
#define JOB_TITLE_TAIPAN_BOTANIST "Space Base Syndicate Botanist"
#define JOB_TITLE_TAIPAN_CARGO "Space Base Syndicate Cargo Technician"
#define JOB_TITLE_TAIPAN_CHEF "Space Base Syndicate Chef"
#define JOB_TITLE_TAIPAN_ENGINEER "Space Base Syndicate Engineer"
#define JOB_TITLE_TAIPAN_COMMS "Space Base Syndicate Comms Officer"
#define JOB_TITLE_TAIPAN_RD "Space Base Syndicate Research Director"
#define JOB_TITLE_TAIPAN_CYBORG "Cyborg"

/// MARK: Job lists
GLOBAL_LIST_INIT(ai_death_alarm_jobs, list(
	JOB_TITLE_CAPTAIN,
	JOB_TITLE_CHIEF_ENGINEER,
	JOB_TITLE_RD,
))

GLOBAL_LIST_INIT(station_departments, list(
	STATION_DEPARTMENT_COMMAND,
	STATION_DEPARTMENT_MEDICAL,
	STATION_DEPARTMENT_ENGINEERING,
	STATION_DEPARTMENT_SCIENCE,
	STATION_DEPARTMENT_SECURITY,
	STATION_DEPARTMENT_SUPPLY,
	STATION_DEPARTMENT_SERVICE,
	STATION_DEPARTMENT_LEGAL,
	STATION_DEPARTMENT_CIVILIAN,
))
