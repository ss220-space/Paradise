//Preference toggles
#define SOUND_ADMINHELP		(1<<0)
#define SOUND_MIDI			(1<<1)
#define SOUND_AMBIENCE		(1<<2)
#define SOUND_LOBBY			(1<<3)
#define SOUND_HEARTBEAT		(1<<5) // 16 is lost, don't touch because it's prefs
#define SOUND_BUZZ			(1<<6)
#define SOUND_INSTRUMENTS	(1<<7)
#define SOUND_MENTORHELP	(1<<8)
#define SOUND_DISCO			(1<<9)
#define SOUND_AI_VOICE		(1<<10)
#define SOUND_PRAYERNOTIFY	(1<<11)

#define SOUND_DEFAULT (SOUND_ADMINHELP|SOUND_MIDI|SOUND_AMBIENCE|SOUND_LOBBY|SOUND_HEARTBEAT|SOUND_BUZZ|SOUND_INSTRUMENTS|SOUND_MENTORHELP|SOUND_DISCO|SOUND_AI_VOICE|SOUND_PRAYERNOTIFY)

#define PREFTOGGLE_CHAT_OOC					(1<<0)
#define PREFTOGGLE_CHAT_DEAD				(1<<1)
#define PREFTOGGLE_CHAT_GHOSTEARS			(1<<2)
#define PREFTOGGLE_CHAT_GHOSTSIGHT			(1<<3)
#define PREFTOGGLE_CHAT_PRAYER				(1<<4)
#define PREFTOGGLE_CHAT_RADIO				(1<<5)
#define PREFTOGGLE_AZERTY					(1<<6)
#define PREFTOGGLE_CHAT_DEBUGLOGS 			(1<<7)
#define PREFTOGGLE_CHAT_LOOC 				(1<<8)
#define PREFTOGGLE_CHAT_GHOSTRADIO 			(1<<9)
#define PREFTOGGLE_SHOW_TYPING 				(1<<10)
#define PREFTOGGLE_DISABLE_SCOREBOARD 		(1<<11)
#define PREFTOGGLE_DISABLE_KARMA_REMINDER	(1<<12)
#define PREFTOGGLE_MEMBER_PUBLIC			(1<<13)
#define PREFTOGGLE_CHAT_NO_ADMINLOGS 		(1<<14)
#define PREFTOGGLE_DONATOR_PUBLIC			(1<<15)
#define PREFTOGGLE_CHAT_NO_TICKETLOGS 		(1<<16)
#define PREFTOGGLE_UI_DARKMODE 				(1<<17)
#define PREFTOGGLE_DISABLE_KARMA 			(1<<18)
#define PREFTOGGLE_CHAT_NO_MENTORTICKETLOGS (1<<19)
#define PREFTOGGLE_TYPING_ONCE 				(1<<20)
#define PREFTOGGLE_AMBIENT_OCCLUSION 		(1<<21)
#define PREFTOGGLE_CHAT_GHOSTPDA 			(1<<22)
#define PREFTOGGLE_NUMPAD_TARGET 			(1<<23)

#define TOGGLES_TOTAL 						16777215 // If you add or remove a preference toggle above, make sure you update this define with the total value of the toggles combined.

#define TOGGLES_DEFAULT (PREFTOGGLE_CHAT_OOC|PREFTOGGLE_CHAT_DEAD|PREFTOGGLE_CHAT_GHOSTEARS|PREFTOGGLE_CHAT_GHOSTSIGHT|PREFTOGGLE_CHAT_PRAYER|PREFTOGGLE_CHAT_RADIO|PREFTOGGLE_CHAT_LOOC|PREFTOGGLE_MEMBER_PUBLIC|PREFTOGGLE_DONATOR_PUBLIC|PREFTOGGLE_UI_DARKMODE|PREFTOGGLE_AMBIENT_OCCLUSION|PREFTOGGLE_CHAT_GHOSTPDA|PREFTOGGLE_NUMPAD_TARGET)

// toggles_2 variables. These MUST be prefixed with PREFTOGGLE_2
#define PREFTOGGLE_2_RANDOMSLOT				(1<<0) // 1
#define PREFTOGGLE_2_FANCYUI				(1<<1) // 2
#define PREFTOGGLE_2_ITEMATTACK				(1<<2) // 4
#define PREFTOGGLE_2_WINDOWFLASHING			(1<<3) // 8
#define PREFTOGGLE_2_ANON					(1<<4) // 16
#define PREFTOGGLE_2_AFKWATCH				(1<<5) // 32
#define PREFTOGGLE_2_RUNECHAT				(1<<6) // 64
#define PREFTOGGLE_2_DEATHMESSAGE			(1<<7) // 128
#define PREFTOGGLE_2_EMOTE_BUBBLE			(1<<8) // 256
#define PREFTOGGLE_2_SEE_ITEM_OUTLINES		(1<<9) // 512
// Yes I know this being an "enable to disable" is misleading, but it avoids having to tweak all existing pref entries
#define PREFTOGGLE_2_REVERB_DISABLE			(1<<10) // 1024
#define PREFTOGGLE_2_MC_TABS				(1<<11) // 2048
#define PREFTOGGLE_2_DISABLE_TGUI_LISTS		(1<<12) // 4096
#define PREFTOGGLE_2_PARALLAX_IN_DARKNESS	(1<<13) // 8192

#define TOGGLES_2_TOTAL						16383 // If you add or remove a preference toggle above, make sure you update this define with the total value of the toggles combined.

#define TOGGLES_2_DEFAULT (PREFTOGGLE_2_FANCYUI|PREFTOGGLE_2_ITEMATTACK|PREFTOGGLE_2_WINDOWFLASHING|PREFTOGGLE_2_RUNECHAT|PREFTOGGLE_2_DEATHMESSAGE|PREFTOGGLE_2_SEE_ITEM_OUTLINES)

// Sanity checks
#if TOGGLES_TOTAL > 16777215
#error toggles bitflag over 16777215. Please use toggles_2.
#endif

#if TOGGLES_2_TOTAL > 16777215
#error toggles_2 bitflag over 16777215. Please make an issue report and postpone the feature you are working on.
#endif



// Admin attack logs filter system, see /proc/add_attack_logs
#define ATKLOG_ALL	0 // All. no exceptions
#define ATKLOG_ALMOSTALL	1 // exceptions: NPC vs NPC, strip/equip, vamp bites and pushing
#define ATKLOG_MOST	2 // exceptions: player vs NPC, off-station areas
#define ATKLOG_FEW	3 // important: SSD interaction, explosives, gib, wiping AI, acid spray, messing with engine
#define ATKLOG_NONE	4 // None

// Playtime tracking system, see jobs_exp.dm
#define EXP_TYPE_LIVING			"Living"
#define EXP_TYPE_CREW			"Crew"
#define EXP_TYPE_SPECIAL		"Special"
#define EXP_TYPE_GHOST			"Ghost"
#define EXP_TYPE_EXEMPT			"Exempt"
#define EXP_TYPE_COMMAND		"Command"
#define EXP_TYPE_ENGINEERING	"Engineering"
#define EXP_TYPE_MEDICAL		"Medical"
#define EXP_TYPE_SCIENCE		"Science"
#define EXP_TYPE_SUPPLY			"Supply"
#define EXP_TYPE_SECURITY		"Security"
#define EXP_TYPE_SILICON		"Silicon"
#define EXP_TYPE_SERVICE		"Service"
#define EXP_TYPE_WHITELIST		"Whitelist"
#define EXP_TYPE_BASE_TUTORIAL  "TrainBase"

#define EXP_DEPT_TYPE_LIST		list(EXP_TYPE_SERVICE, EXP_TYPE_MEDICAL, EXP_TYPE_ENGINEERING, EXP_TYPE_SCIENCE, EXP_TYPE_SECURITY, EXP_TYPE_COMMAND, EXP_TYPE_SILICON, EXP_TYPE_SPECIAL)

// Defines just for parallax because its levels make storing it in the regular prefs a pain in the ass
// These dont need to be bitflags because there isnt going to be more than one at a time of these active
// But its gonna piss off my OCD if it isnt bitflags, so deal with it, -affected
#define PARALLAX_DISABLE		1
#define PARALLAX_LOW			2
#define PARALLAX_MED			4
#define PARALLAX_HIGH			8
#define PARALLAX_INSANE			16
