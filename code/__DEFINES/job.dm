///////////////////////////////
//          WARNING          //
////////////////////////////////////////////////////////////////////////
// Do NOT touch the values associated with these defines, as they are //
// used by the game database to keep track of job flags. Do NOT touch //
////////////////////////////////////////////////////////////////////////

#define JOBCAT_ENGSEC			(1<<0)

#define JOB_FLAG_CAPTAIN			(1<<0)
#define JOB_FLAG_HOS				(1<<1)
#define JOB_FLAG_WARDEN			(1<<2)
#define JOB_FLAG_DETECTIVE			(1<<3)
#define JOB_FLAG_OFFICER			(1<<4)
#define JOB_FLAG_CHIEF				(1<<5)
#define JOB_FLAG_ENGINEER			(1<<6)
#define JOB_FLAG_ATMOSTECH			(1<<7)
#define JOB_FLAG_AI				(1<<8)
#define JOB_FLAG_CYBORG			(1<<9)
#define JOB_FLAG_CENTCOM			(1<<10)
#define JOB_FLAG_SYNDICATE			(1<<11)
#define JOB_FLAG_ENGINEER_TRAINEE	(1<<12)

#define JOBCAT_MEDSCI			(1<<1)

#define JOB_FLAG_RD				(1<<0)
#define JOB_FLAG_SCIENTIST			(1<<1)
#define JOB_FLAG_CHEMIST			(1<<2)
#define JOB_FLAG_CMO				(1<<3)
#define JOB_FLAG_DOCTOR			(1<<4)
#define JOB_FLAG_GENETICIST		(1<<5)
#define JOB_FLAG_VIROLOGIST		(1<<6)
#define JOB_FLAG_PSYCHIATRIST		(1<<7)
#define JOB_FLAG_ROBOTICIST		(1<<8)
#define JOB_FLAG_PARAMEDIC			(1<<9)
#define JOB_FLAG_CORONER			(1<<10)
#define JOB_FLAG_SCIENTIST_STUDENT	(1<<11)
#define JOB_FLAG_INTERN			(1<<12)


#define JOBCAT_SUPPORT			(1<<2)

#define JOB_FLAG_HOP				(1<<0)
#define JOB_FLAG_BARTENDER			(1<<1)
#define JOB_FLAG_BOTANIST			(1<<2)
#define JOB_FLAG_CHEF				(1<<3)
#define JOB_FLAG_JANITOR			(1<<4)
#define JOB_FLAG_LIBRARIAN			(1<<5)
#define JOB_FLAG_QUARTERMASTER		(1<<6)
#define JOB_FLAG_CARGOTECH			(1<<7)
#define JOB_FLAG_MINER				(1<<8)
#define JOB_FLAG_LAWYER			(1<<9)
#define JOB_FLAG_CHAPLAIN			(1<<10)
#define JOB_FLAG_CLOWN				(1<<11)
#define JOB_FLAG_MIME				(1<<12)
#define JOB_FLAG_CIVILIAN			(1<<13)
#define JOB_FLAG_EXPLORER			(1<<14)

#define JOBCAT_KARMA				(1<<3)

#define JOB_FLAG_NANO				(1<<0)
#define JOB_FLAG_BLUESHIELD		(1<<1)
#define JOB_FLAG_BARBER			(1<<3)
#define JOB_FLAG_MECHANIC			(1<<4)
#define JOB_FLAG_BRIGDOC			(1<<5)
#define JOB_FLAG_JUDGE				(1<<6)
#define JOB_FLAG_PILOT				(1<<7)

///Defines below used as jobs' titles (from /tg/), credit to JohnFulpWillard
#define JOB_TITLE_CIVILIAN "Civilian"

#define JOB_TITLE_CHIEF "Chief Engineer"
#define JOB_TITLE_ENGINEER "Station Engineer"
#define JOB_TITLE_ENGINEER_TRAINEE "Trainee Engineer"
#define JOB_TITLE_ATMOSTECH "Life Support Specialist"
#define JOB_TITLE_MECHANIC "Mechanic"

#define JOB_TITLE_CMO "Chief Medical Officer"
#define JOB_TITLE_DOCTOR "Medical Doctor"
#define JOB_TITLE_INTERN "Intern"
#define JOB_TITLE_CORONER "Coroner"
#define JOB_TITLE_CHEMIST "Chemist"
#define JOB_TITLE_GENETICIST "Geneticist"
#define JOB_TITLE_VIROLOGIST "Virologist"
#define JOB_TITLE_PSYCHIATRIST "Psychiatrist"
#define JOB_TITLE_PARAMEDIC "Paramedic"

#define JOB_TITLE_RD "Research Director"
#define JOB_TITLE_SCIENTIST "Scientist"
#define JOB_TITLE_SCIENTIST_STUDENT "Student Scientist"
#define JOB_TITLE_ROBOTICIST "Roboticist"

#define JOB_TITLE_HOS "Head of Security"
#define JOB_TITLE_WARDEN "Warden"
#define JOB_TITLE_DETECTIVE "Detective"
#define JOB_TITLE_OFFICER "Security Officer"
#define JOB_TITLE_BRIGDOC "Brig Physician"
#define JOB_TITLE_PILOT "Security Pod Pilot"

#define JOB_TITLE_AI "AI"
#define JOB_TITLE_CYBORG "Cyborg"

#define JOB_TITLE_CAPTAIN "Captain"
#define JOB_TITLE_HOP "Head of Personnel"
#define JOB_TITLE_NANO "Nanotrasen Representative"
#define JOB_TITLE_BLUESHIELD "Blueshield"
#define JOB_TITLE_JUDGE "Magistrate"
#define JOB_TITLE_LAWYER "Internal Affairs Agent"

#define JOB_TITLE_CHAPLAIN "Chaplain"

#define JOB_TITLE_QUARTERMASTER "Quartermaster"
#define JOB_TITLE_CARGOTECH "Cargo Technician"
#define JOB_TITLE_MINER "Shaft Miner"

#define JOB_TITLE_BARTENDER "Bartender"
#define JOB_TITLE_CHEF "Chef"
#define JOB_TITLE_BOTANIST "Botanist"
#define JOB_TITLE_CLOWN "Clown"
#define JOB_TITLE_MIME "Mime"
#define JOB_TITLE_JANITOR "Janitor"
#define JOB_TITLE_LIBRARIAN "Librarian"
#define JOB_TITLE_BARBER "Barber"
#define JOB_TITLE_EXPLORER "Explorer"

#define JOB_TITLE_SYNDICATE "Syndicate Officer"
#define JOB_TITLE_CCOFFICER "Nanotrasen Navy Officer"
#define JOB_TITLE_CCFIELD "Nanotrasen Navy Field Officer"
#define JOB_TITLE_CCSPECOPS "Special Operations Officer"
#define JOB_TITLE_CCSUPREME "Supreme Commander"
#define JOB_TITLE_CCSOLGOV "Solar Federation General"

///Taipan (ghost role) related stuff

#define TAIPAN_SCIENTIST	"Space Base Syndicate Scientist"
#define TAIPAN_MEDIC 		"Space Base Syndicate Medic"
#define TAIPAN_BOTANIST		"Space Base Syndicate Botanist"
#define TAIPAN_CARGO		"Space Base Syndicate Cargo Technician"
#define TAIPAN_CHEF			"Space Base Syndicate Chef"
#define TAIPAN_ENGINEER		"Space Base Syndicate Engineer"
#define TAIPAN_COMMS 		"Space Base Syndicate Comms Officer"
#define TAIPAN_RD			"Space Base Syndicate Research Director"
#define CYBORG				"Cyborg"

#define TAIPAN_HUD_SCIENTIST	1
#define TAIPAN_HUD_MEDIC 		2
#define TAIPAN_HUD_BOTANIST		3
#define TAIPAN_HUD_CARGO		4
#define TAIPAN_HUD_CHEF			5
#define TAIPAN_HUD_ENGINEER		6
#define TAIPAN_HUD_COMMS 		7
#define TAIPAN_HUD_RD			8
#define TAIPAN_HUD_CYBORG		9
