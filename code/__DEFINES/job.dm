///////////////////////////////
//          WARNING          //
////////////////////////////////////////////////////////////////////////
// Do NOT touch the values associated with these defines, as they are //
// used by the game database to keep track of job flags. Do NOT touch //
////////////////////////////////////////////////////////////////////////

#define JOBCAT_ENGSEC			(1<<0)

#define JOB_CAPTAIN			(1<<0)
#define JOB_HOS				(1<<1)
#define JOB_WARDEN			(1<<2)
#define JOB_DETECTIVE			(1<<3)
#define JOB_OFFICER			(1<<4)
#define JOB_CHIEF				(1<<5)
#define JOB_ENGINEER			(1<<6)
#define JOB_ATMOSTECH			(1<<7)
#define JOB_AI				(1<<8)
#define JOB_CYBORG			(1<<9)
#define JOB_CENTCOM			(1<<10)
#define JOB_SYNDICATE			(1<<11)
#define JOB_ENGINEER_TRAINEE	(1<<12)

#define JOBCAT_MEDSCI			(1<<1)

#define JOB_RD				(1<<0)
#define JOB_SCIENTIST			(1<<1)
#define JOB_CHEMIST			(1<<2)
#define JOB_CMO				(1<<3)
#define JOB_DOCTOR			(1<<4)
#define JOB_GENETICIST		(1<<5)
#define JOB_VIROLOGIST		(1<<6)
#define JOB_PSYCHIATRIST		(1<<7)
#define JOB_ROBOTICIST		(1<<8)
#define JOB_PARAMEDIC			(1<<9)
#define JOB_CORONER			(1<<10)
#define JOB_SCIENTIST_STUDENT	(1<<11)
#define JOB_INTERN			(1<<12)


#define JOBCAT_SUPPORT			(1<<2)

#define JOB_HOP				(1<<0)
#define JOB_BARTENDER			(1<<1)
#define JOB_BOTANIST			(1<<2)
#define JOB_CHEF				(1<<3)
#define JOB_JANITOR			(1<<4)
#define JOB_LIBRARIAN			(1<<5)
#define JOB_QUARTERMASTER		(1<<6)
#define JOB_CARGOTECH			(1<<7)
#define JOB_MINER				(1<<8)
#define JOB_LAWYER			(1<<9)
#define JOB_CHAPLAIN			(1<<10)
#define JOB_CLOWN				(1<<11)
#define JOB_MIME				(1<<12)
#define JOB_CIVILIAN			(1<<13)
#define JOB_EXPLORER			(1<<14)

#define JOBCAT_KARMA				(1<<3)

#define JOB_NANO				(1<<0)
#define JOB_BLUESHIELD		(1<<1)
#define JOB_BARBER			(1<<3)
#define JOB_MECHANIC			(1<<4)
#define JOB_BRIGDOC			(1<<5)
#define JOB_JUDGE				(1<<6)
#define JOB_PILOT				(1<<7)

///Defines below used as jobs' titles (kinda like /tg/), credit to JohnFulpWillard
#define TITLE_CIVILIAN /datum/job/civilian::title

#define TITLE_CHIEF /datum/job/chief_engineer::title
#define TITLE_ENGINEER /datum/job/engineer::title
#define TITLE_ENGINEER_TRAINEE /datum/job/engineer/trainee::title
#define TITLE_ATMOSTECH /datum/job/atmos::title
#define TITLE_MECHANIC /datum/job/mechanic::title

#define TITLE_CMO /datum/job/cmo::title
#define TITLE_DOCTOR /datum/job/doctor::title
#define TITLE_INTERN /datum/job/doctor/intern::title
#define TITLE_CORONER /datum/job/coroner::title
#define TITLE_CHEMIST /datum/job/chemist::title
#define TITLE_GENETICIST /datum/job/geneticist::title
#define TITLE_VIROLOGIST /datum/job/virologist::title
#define TITLE_PSYCHIATRIST /datum/job/psychiatrist::title
#define TITLE_PARAMEDIC /datum/job/paramedic::title

#define TITLE_RD /datum/job/rd::title
#define TITLE_SCIENTIST /datum/job/scientist::title
#define TITLE_ROBOTICIST /datum/job/roboticist::title
#define TITLE_SCIENTIST_STUDENT /datum/outfit/job/scientist/student::title

#define TITLE_HOS /datum/job/hos::title
#define TITLE_WARDEN /datum/job/warden::title
#define TITLE_DETECTIVE /datum/job/detective::title
#define TITLE_OFFICER /datum/job/officer::title
#define TITLE_BRIGDOC /datum/job/brigdoc::title
#define TITLE_PILOT /datum/job/pilot::title

#define TITLE_AI /datum/job/ai::title
#define TITLE_CYBORG /datum/job/cyborg::title

#define TITLE_CAPTAIN /datum/job/captain::title
#define TITLE_HOP /datum/job/hop::title
#define TITLE_NANO /datum/job/nanotrasenrep::title
#define TITLE_BLUESHIELD /datum/job/blueshield::title
#define TITLE_JUDGE /datum/job/judge::title
#define TITLE_LAWYER /datum/job/lawyer::title

#define TITLE_CHAPLAIN /datum/job/chaplain::title

#define TITLE_QUARTERMASTER /datum/job/qm::title
#define TITLE_CARGOTECH /datum/job/cargo_tech::title
#define TITLE_MINER /datum/job/mining::title

#define TITLE_BARTENDER /datum/job/bartender::title
#define TITLE_CHEF /datum/job/chef::title
#define TITLE_BOTANIST /datum/job/hydro::title
#define TITLE_CLOWN /datum/job/clown::title
#define TITLE_MIME /datum/job/mime::title
#define TITLE_JANITOR /datum/job/janitor::title
#define TITLE_LIBRARIAN /datum/job/librarian::title
#define TITLE_BARBER /datum/job/barber::title
#define TITLE_EXPLORER /datum/job/explorer::title

#define TITLE_SYNDICATE /datum/job/syndicateofficer::title
#define TITLE_CCOFFICER /datum/job/ntnavyofficer::title
#define TITLE_CCFIELD /datum/job/ntnavyofficer/field::title
#define TITLE_CCSPECOPS /datum/job/ntspecops::title
#define TITLE_CCSUPREME /datum/job/ntspecops/supreme::title
#define TITLE_CCSOLGOV /datum/job/ntspecops/solgovspecops::title

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
