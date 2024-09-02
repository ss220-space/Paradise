//A set of constants used to determine which type of mute an admin wishes to apply:
//Please read and understand the muting/automuting stuff before changing these. MUTE_IC_AUTO etc = (MUTE_IC << 1)
//Therefore there needs to be a gap between the flags for the automute flags
#define MUTE_IC			(1<<0)
#define MUTE_OOC		(1<<1)
#define MUTE_PRAY		(1<<2)
#define MUTE_ADMINHELP	(1<<3)
#define MUTE_DEADCHAT	(1<<4)
#define MUTE_TTS		(1<<5)
#define MUTE_EMOTE		(1<<6)
#define MUTE_ALL		(~0)

//Number of identical messages required to get the spam-prevention automute thing to trigger warnings and automutes
#define SPAM_TRIGGER_WARNING 5
#define SPAM_TRIGGER_AUTOMUTE 10

//Some constants for DB_Ban
#define BANTYPE_PERMA		1
#define BANTYPE_TEMP		2
#define BANTYPE_JOB_PERMA	3
#define BANTYPE_JOB_TEMP	4
#define BANTYPE_ANY_FULLBAN	5 //used to locate stuff to unban.
#define BANTYPE_APPEARANCE  6
#define BANTYPE_ADMIN_PERMA	7
#define BANTYPE_ADMIN_TEMP	8

//Please don't edit these values without speaking to Errorage first	~Carn
//Admin Permissions
#define R_BUILDMODE		(1<<0)
#define R_ADMIN			(1<<1)
#define R_BAN			(1<<2)
#define R_EVENT			(1<<3)
#define R_SERVER		(1<<4)
#define R_DEBUG			(1<<5)
#define R_POSSESS		(1<<6)
#define R_PERMISSIONS	(1<<7)
#define R_STEALTH		(1<<8)
#define R_REJUVINATE	(1<<9)
#define R_VAREDIT		(1<<10)
#define R_SOUNDS		(1<<11)
#define R_SPAWN			(1<<12)
#define R_MOD			(1<<13)
#define R_MENTOR		(1<<14)
#define R_PROCCALL		(1<<15)
#define R_VIEWRUNTIMES	(1<<16)
#define R_DEV			(1<<17)
#define R_PEPELOPMENT	(1<<18)

#define R_MAXPERMISSION (1<<18)//This holds the maximum value for a permission. It is used in iteration, so keep it updated.

#define R_HOST			(~0) // Sum of all permissions to allow easy setting

#define ADMIN_QUE(user,display) "<a href='byond://?_src_=holder;adminmoreinfo=[user.UID()]'>[display]</a>"
#define ADMIN_FLW(user,display) "<a href='byond://?_src_=holder;adminplayerobservefollow=[user.UID()]'>[display]</a>"
#define ADMIN_PP(user,display) "<a href='byond://?_src_=holder;adminplayeropts=[user.UID()]'>[display]</a>"
#define ADMIN_VV(atom,display) "<a href='byond://?_src_=vars;Vars=[atom.UID()]'>[display]</a>"
#define ADMIN_SM(user,display) "<a href='byond://?_src_=holder;subtlemessage=[user.UID()]'>[display]</a>"
#define ADMIN_TP(user,display) "<a href='byond://?_src_=holder;traitor=[user.UID()]'>[display]</a>"
#define ADMIN_ALERT(user, display) "<a href='byond://?_src_=holder;adminalert=[user.UID()]'>[display]</a>"
#define ADMIN_BSA(user,display) "<a href='byond://?_src_=holder;BlueSpaceArtillery=[user.UID()]'>[display]</a>"
#define ADMIN_CENTCOM_REPLY(user,display) "<a href='byond://?_src_=holder;CentcommReply=[user.UID()]'>[display]</a>"
#define ADMIN_SYNDICATE_REPLY(user,display) "<a href='byond://?_src_=holder;SyndicateReply=[user.UID()]'>[display]</a>"
#define ADMIN_SC(user,display) "<a href='byond://?_src_=holder;adminspawncookie=[user.UID()]'>[display]</a>"
#define ADMIN_LOOKUP(user) "[key_name_admin(user)]([ADMIN_QUE(user,"?")])"
#define ADMIN_LOOKUPFLW(user) "[key_name_admin(user)]([ADMIN_QUE(user,"?")]) ([ADMIN_FLW(user,"FLW")])"
#define ADMIN_FULLMONTY(user) "[key_name_admin(user)] ([ADMIN_QUE(user,"?")]) ([ADMIN_PP(user,"PP")]) ([ADMIN_VV(user,"VV")]) ([ADMIN_SM(user,"SM")]) ([ADMIN_FLW(user,"FLW")]) ([ADMIN_TP(user,"TP")])"
#define ADMIN_JMP(src) "(<a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)"
#define COORD(src) "[src ? "([src.x],[src.y],[src.z])" : "nonexistent location"]"
#define AREACOORD(src) "[src ? "[get_area_name(src, TRUE)] [COORD(src)]" : "nonexistent location" ]"
#define ADMIN_COORDJMP(src) "[src ? "[COORD(src)] [ADMIN_JMP(src)]" : "nonexistent location"]"
#define ADMIN_VERBOSEJMP(src) "[src ? "[AREACOORD(src)] [ADMIN_JMP(src)]" : "nonexistent location"]"
#define ADMIN_SHOWDETAILS(mask, content) "<a href='byond://?_src_=holder;showdetails=[html_encode(content)]'>[mask]</a>"

