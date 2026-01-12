/*
 * MARK: WARNING
 *
 * Do NOT touch the values associated with these defines, as they are
 * used by the game database to keep track of job flags. Do NOT touch
 */

// MARK: Department identificators
#define STATION_DEPARTMENT_COMMAND "Command"
#define STATION_DEPARTMENT_MEDICAL "Medical"
#define STATION_DEPARTMENT_ENGINEERING "Engineering"
#define STATION_DEPARTMENT_SCIENCE "Science"
#define STATION_DEPARTMENT_SECURITY "Security"
#define STATION_DEPARTMENT_SUPPLY "Supply"
#define STATION_DEPARTMENT_SERVICE "Service"
#define STATION_DEPARTMENT_LEGAL "Legal"
#define STATION_DEPARTMENT_SILICON "Silicon"
#define STATION_DEPARTMENT_CIVILIAN "Civilian"
#define STATION_DEPARTMENT_OTHER "other"

// MARK: Job flags
#define JOBCAT_ENGSEC (1<<0)

#define JOB_FLAG_CAPTAIN (1<<0)
#define JOB_FLAG_HOS (1<<1)
#define JOB_FLAG_WARDEN (1<<2)
#define JOB_FLAG_DETECTIVE (1<<3)
#define JOB_FLAG_OFFICER (1<<4)
#define JOB_FLAG_CHIEF (1<<5)
#define JOB_FLAG_ENGINEER (1<<6)
#define JOB_FLAG_ATMOSTECH (1<<7)
#define JOB_FLAG_AI (1<<8)
#define JOB_FLAG_CYBORG (1<<9)
#define JOB_FLAG_CENTCOM (1<<10)
#define JOB_FLAG_SYNDICATE (1<<11)
#define JOB_FLAG_ENGINEER_TRAINEE (1<<12)

#define JOBCAT_MEDSCI (1<<1)

#define JOB_FLAG_RD (1<<0)
#define JOB_FLAG_SCIENTIST (1<<1)
#define JOB_FLAG_CHEMIST (1<<2)
#define JOB_FLAG_CMO (1<<3)
#define JOB_FLAG_DOCTOR (1<<4)
#define JOB_FLAG_GENETICIST (1<<5)
#define JOB_FLAG_VIROLOGIST (1<<6)
#define JOB_FLAG_PSYCHIATRIST (1<<7)
#define JOB_FLAG_ROBOTICIST (1<<8)
#define JOB_FLAG_PARAMEDIC (1<<9)
#define JOB_FLAG_CORONER (1<<10)
#define JOB_FLAG_SCIENTIST_STUDENT (1<<11)
#define JOB_FLAG_INTERN (1<<12)

#define JOBCAT_SUPPORT (1<<2)

#define JOB_FLAG_HOP (1<<0)
#define JOB_FLAG_BARTENDER (1<<1)
#define JOB_FLAG_BOTANIST (1<<2)
#define JOB_FLAG_CHEF (1<<3)
#define JOB_FLAG_JANITOR (1<<4)
#define JOB_FLAG_LIBRARIAN (1<<5)
#define JOB_FLAG_QUARTERMASTER (1<<6)
#define JOB_FLAG_CARGOTECH (1<<7)
#define JOB_FLAG_MINER (1<<8)
#define JOB_FLAG_LAWYER (1<<9)
#define JOB_FLAG_CHAPLAIN (1<<10)
#define JOB_FLAG_CLOWN (1<<11)
#define JOB_FLAG_MIME (1<<12)
#define JOB_FLAG_CIVILIAN (1<<13)
#define JOB_FLAG_EXPLORER (1<<14)
#define JOB_FLAG_MINING_MEDIC (1<<15)
#define JOB_FLAG_PRISONER (1<<16)

#define JOBCAT_KARMA (1<<3) // DELETE THIS SHIT!!!

#define JOB_FLAG_REPRESENTATIVE (1<<0)
#define JOB_FLAG_BLUESHIELD (1<<1)
#define JOB_FLAG_MECHANIC (1<<4)
#define JOB_FLAG_BRIGDOC (1<<5)
#define JOB_FLAG_JUDGE (1<<6)
#define JOB_FLAG_PILOT (1<<7)

#define JOBCAT_COMBAT_TEAM (1<<4)
#define JOB_FLAG_TEAM1 (1<<0)
#define JOB_FLAG_TEAM2 (1<<1)
#define JOB_FLAG_TEAM3 (1<<2)

/// MARK: Taipan huds
#define TAIPAN_HUD_SCIENTIST 1
#define TAIPAN_HUD_MEDIC 2
#define TAIPAN_HUD_BOTANIST 3
#define TAIPAN_HUD_CARGO 4
#define TAIPAN_HUD_CHEF 5
#define TAIPAN_HUD_ENGINEER 6
#define TAIPAN_HUD_COMMS 7
#define TAIPAN_HUD_RD 8
#define TAIPAN_HUD_CYBORG 9

