/mob
	density = TRUE
	layer = MOB_LAYER
	animate_movement = SLIDE_STEPS
	pressure_resistance = 8
	throwforce = 10
	dont_save = TRUE //to avoid it messing up in buildmode saving
	pass_flags_self = PASSMOB

	/// The current client inhabiting this mob. Managed by login/logout
	/// This exists so we can do cleanup in logout for occasions where a client was transfere rather then destroyed
	/// We need to do this because the mob on logout never actually has a reference to client
	/// We also need to clear this var/do other cleanup in client/Destroy, since that happens before logout
	/// HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
	var/client/canon_client

	see_in_dark = DEFAULT_SEE_IN_DARK

	///Backward compatibility var for determining nightvision like it used to be see_in_dark and see_through_darkness screen-overlay
	var/nightvision = 0

	/// Contains /atom/movable/screen/alert only // On /mob so clientless mobs will throw alerts properly
	var/list/alerts

	var/bloody_hands = 0
	/// Basically a lazy list, copies the DNA of blood you step in
	var/list/feet_blood_DNA
	/// affects the blood color of your feet, color taken from the blood you step in
	var/feet_blood_color
	/// Weirdly named, effects how blood transfers onto objects
	var/blood_state = BLOOD_STATE_NOT_BLOODY
	/// Assoc list for tracking how "bloody" a mobs feet are, used for creating bloody foot/shoeprints on turfs when moving
	var/list/bloody_feet = list(BLOOD_STATE_HUMAN = 0, BLOOD_STATE_XENO = 0, BLOOD_STATE_NOT_BLOODY = 0, BLOOD_BASE_ALPHA = BLOODY_FOOTPRINT_BASE_ALPHA)

	/// Affects if you have a typing indicator
	var/typing
	/// Affects if you have a thinking indicator
	var/thinking
	/// Last thing we typed in to the typing indicator, probably does not need to exist
	var/last_typed
	/// Last time we typed something in to the typing popup
	var/last_typed_time

	var/datum/mind/mind
	blocks_emissive = EMISSIVE_BLOCK_GENERIC

	var/stat = CONSCIOUS //Whether a mob is alive or dead. TODO: Move this to living - Nodrak

	/// The zone this mob is currently targeting
	var/zone_selected = BODY_ZONE_CHEST

	var/atom/movable/screen/hands = null
	var/atom/movable/screen/pullin = null
	var/atom/movable/screen/i_select = null
	var/atom/movable/screen/m_select = null
	var/atom/movable/screen/healths = null
	var/atom/movable/screen/throw_icon = null
	var/atom/movable/screen/stamina_bar = null

	/*A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.   :resident_sleeper:
	*/
	var/atom/movable/screen/leap_icon = null
	var/atom/movable/screen/healthdoll/healthdoll = null

	var/use_me = 1 //Allows all mobs to use the me verb by default, will have to manually specify they cannot
	var/damageoverlaytemp = 0
	var/computer_id = null
	var/lastattacker = null // real name of the person  doing the attacking
	var/lastattackerckey = null // their ckey

	var/list/debug_log = null
	var/last_log = 0
	var/list/attack_log_old

	var/last_known_ckey = null	// Used in logging

	var/obj/machinery/machine = null
	var/memory = ""
	var/next_move = null
	/// Currently active mob's hand.
	var/hand = ACTIVE_HAND_RIGHT
	var/real_name = null
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/exploit_record = ""
	/// For speaking/listening.
	var/list/languages
	/// For reagents that grant language knowlege.
	var/list/temporary_languages
	var/list/speak_emote = list("says")   // Verbs used when speaking. Defaults to 'say' if speak_emote is null.
	/// Define emote default type, EMOTE_VISIBLE for seen emotes, EMOTE_AUDIBLE for heard emotes.
	var/emote_type = EMOTE_VISIBLE
	var/name_archive //For admin things like possession
	var/gunshot_residue

	var/timeofdeath = 0 //Living

	var/bodytemperature = BODYTEMP_NORMAL	//98.7 F
	var/nutrition = NUTRITION_LEVEL_FED + 50 //Carbon
	var/satiety = 0 //Carbon

	var/overeatduration = 0		// How long this guy is overeating //Carbon
	var/intent = null //Living
	var/a_intent = INTENT_HELP //Living
	var/m_intent = MOVE_INTENT_RUN //Living
	var/lastKnownIP = null
	/// movable atoms buckled to this mob
	var/atom/movable/buckled = null //Living
	/// movable atom we are buckled to
	var/atom/movable/buckling

	var/obj/item/l_hand = null //Living
	var/obj/item/r_hand = null //Living
	var/obj/item/back = null //Human
	var/obj/item/tank/internal = null //Human
	var/obj/item/storage/s_active = null //Carbon
	var/obj/item/clothing/mask/wear_mask = null //Carbon

	var/datum/hud/hud_used = null

	hud_possible = list(SPECIALROLE_HUD)

	var/research_scanner = 0 //For research scanner equipped mobs. Enable to show research data when examining.

	var/lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	var/list/mapobjs

	var/in_throw_mode = FALSE

	// See /datum/emote

	/// Cooldown on audio effects from emotes.
	var/audio_emote_cd_status = EMOTE_READY

	/// Cooldown on audio effects from unintentional emotes.
	var/audio_emote_unintentional_cd_status = EMOTE_READY

	/// Override for cooldowns on non-audio emotes. Should be a number in deciseconds.
	var/emote_cooldown_override = null

	/// Tracks last uses of emotes for cooldown purposes
	var/list/emotes_used

	var/job = null //Living

	var/datum/dna/dna = null //Carbon
	var/radiation = 0 //Carbon

	//see: setup.dm for list of mutations

	var/voice_name = "неизвестный голос"

	var/list/faction = list("neutral") //Used for checking whether hostile simple animals will attack you, possibly more stuff later

	var/move_on_shuttle = 1 // Can move on the shuttle.


	/// Whether antagHUD has been enabled previously.
	var/has_enabled_antagHUD = FALSE
	var/antagHUD = FALSE  // Whether AntagHUD is active right now
	var/thoughtsHUD = 0 //Just a handler for permanent/temporary THOUGHTS_HUD changing.
	var/can_change_intents = 1 //all mobs can change intents by default.
	///Override for sound_environments. If this is set the user will always hear a specific type of reverb (Instead of the area defined reverb)
	var/sound_environment_override = SOUND_ENVIRONMENT_NONE

	/// The last mob/living/carbon to push/drag/grab this mob (mostly used by slimes friend recognition)
	var/mob/living/carbon/LAssailant = null

	/// Construct spells and mime spells. Spells that do not transfer from one mob to another and can not be lost in mindswap.
	var/list/mob_spell_list

	/// List of active diseases in a mob
	var/list/diseases
	var/list/resistances

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	/// Bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)
	var/status_flags = CANSTUN|CANWEAKEN|CANKNOCKDOWN|CANPARALYSE|CANPUSH

	var/area/lastarea = null

	var/weakeyes = 0 //Are they vulnerable to flashes?

	var/has_unlimited_silicon_privilege = 0 // Can they interact with station electronics

	var/atom/movable/remote_control //Calls relaymove() to whatever it is

	var/obj/control_object //Used by admins to possess objects. All mobs should have this var

	//Whether or not mobs can understand other mobtypes. These stay in /mob so that ghosts can hear everything.
	var/universal_speak = 0 // Set to 1 to enable the mob to speak to everyone -- TLE
	var/universal_understand = 0 // Set to 1 to enable the mob to understand everyone, not necessarily speak

	///Whether this mob have any limbs he can move with
	var/has_limbs = TRUE

	///How many legs does this mob have by default. This shouldn't change at runtime.
	var/default_num_legs = 2
	///How many legs does this mob currently have. Should only be changed through set_num_legs()
	var/num_legs = 2
	///How many usable legs this mob currently has. Should only be changed through set_usable_legs()
	var/usable_legs = 2

	///How many hands does this mob have by default. This shouldn't change at runtime.
	var/default_num_hands = 2
	///How many hands hands does this mob currently have. Should only be changed through set_num_hands()
	var/num_hands = 2
	///How many usable hands does this mob currently have. Should only be changed through set_usable_hands()
	var/usable_hands = 2

	/// SSD var. When mob has SSD status it contains num value (in deciseconds), since last mob logout. Always null otherwise.
	var/player_logged

	//Ghosted var, set only if a player has manually ghosted out of this mob.
	var/player_ghosted = 0

	var/turf/listed_turf = null  //the current turf being examined in the stat panel

	var/list/active_genes

	var/last_movement = -100 // Last world.time the mob actually moved of its own accord.

	var/last_logout = 0

	var/datum/vision_override/vision_type = null //Vision override datum.

	var/list/huds_counter = list("huds" = list(), "icons" = list()) // Counters for huds and icon types

	var/list/actions = list()

	///List of progress bars this mob is currently seeing for actions
	var/list/progressbars = null	//for stacking do_after bars

	///For storing what do_after's someone has, key = string, value = amount of interactions of that type happening.
	var/list/do_afters

	var/list/tkgrabbed_objects = list() // Assoc list of items to TK grabs

	var/registered_z

	var/obj/effect/proc_holder/ranged_ability //Any ranged ability the mob has, as a click override

	/// The datum receiving keyboard input. src by default
	var/datum/focus

	var/last_emote = null

	var/ghost_orbiting = 0

	/// List of movement speed modifiers applying to this mob
	var/list/movespeed_modification //Lazy list, see mob_movespeed.dm
	/// List of movement speed modifiers ignored by this mob. List -> List (id) -> List (sources)
	var/list/movespeed_mod_immunities //Lazy list, see mob_movespeed.dm
	/// The calculated mob speed slowdown based on the modifiers list
	var/cached_multiplicative_slowdown
	/// List of action speed modifiers applying to this mob
	var/list/actionspeed_modification
	/// List of action speed modifiers ignored by this mob. List -> List (id) -> List (sources)
	var/list/actionspeed_mod_immunities
	/// The calculated mob action speed slowdown based on the modifiers list, sorted by category in associvative list
	var/list/cached_multiplicative_actions_slowdown

