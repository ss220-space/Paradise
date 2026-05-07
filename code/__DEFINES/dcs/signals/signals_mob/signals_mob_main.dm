// /mob signals
///from base of /mob/Login(): ()
#define COMSIG_MOB_LOGIN "mob_login"
///from base of /mob/Logout(): ()
#define COMSIG_MOB_LOGOUT "mob_logout"
///from base of /mob/mind_initialize
#define COMSIG_MOB_MIND_INITIALIZED "mob_mind_inited"
///from base of mob/death(): (gibbed)
#define COMSIG_MOB_DEATH "mob_death"
///from base of mob/ghostize(): (mob/dead/observer/ghost)
#define COMSIG_MOB_GHOSTIZE "mob_ghostize"
///from base of mob/set_stat(): (new_stat)
#define COMSIG_MOB_STATCHANGE "mob_statchange"
///from base of mob/clickon(): (atom/A, params)
#define COMSIG_MOB_CLICKON "mob_clickon"
///from base of mob/MiddleClickOn(): (atom/A)
#define COMSIG_MOB_MIDDLECLICKON "mob_middleclickon"
///from base of mob/AltClickOn(): (atom/A)
#define COMSIG_MOB_ALTCLICKON "mob_altclickon"
	#define COMSIG_MOB_CANCEL_CLICKON (1<<0)
///from base of mob/alt_click_on_secodary(): (atom/A)
#define COMSIG_MOB_ALTCLICKON_SECONDARY "mob_altclickon_secondary"

///from base of mob/key_down(): (_key, client/user)
#define COMSIG_MOB_KEY_DROP_ITEM_DOWN "mob_key_drop_item_down"
	#define COMPONENT_CANCEL_DROP (1<<0)
/// from /mob/proc/key_down(): (key, client/client, full_key)
#define COMSIG_MOB_KEYDOWN "mob_key_down"

///sent when a mob/login() finishes: (client)
#define COMSIG_MOB_CLIENT_LOGIN "comsig_mob_client_login"
//from base of client/MouseDown(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEDOWN "client_mousedown"
//from base of client/MouseUp(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEUP "client_mouseup"
	#define COMPONENT_CLIENT_MOUSEUP_INTERCEPT (1<<0)
//from base of client/MouseUp(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEDRAG "client_mousedrag"

/// From base of /client/Move(): (new_loc, direction)
#define COMSIG_MOB_CLIENT_PRE_MOVE "mob_client_pre_move"
	/// Should always match COMPONENT_MOVABLE_BLOCK_PRE_MOVE as these are interchangeable and used to block movement.
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	/// The argument of move_args which corresponds to the loc we're moving to
	#define MOVE_ARG_NEW_LOC 1
	/// The arugment of move_args which dictates our movement direction
	#define MOVE_ARG_DIRECTION 2
/// From base of /client/Move(): (direction, old_dir)
#define COMSIG_MOB_CLIENT_MOVED "mob_client_moved"

/// From base of /client/Move(), invoked when a non-living mob is attempting to move: (list/move_args)
#define COMSIG_MOB_CLIENT_PRE_NON_LIVING_MOVE "mob_client_pre_non_living_move"
	/// Cancels the move attempt
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_NON_LIVING_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// From base of /client/Move(): (list/move_args)
#define COMSIG_MOB_CLIENT_PRE_LIVING_MOVE "mob_client_pre_living_move"
	/// Should we stop the current living movement attempt
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE

///from base of obj/allowed(mob/M): (/obj) returns bool, if TRUE the mob has id access to the obj
#define COMSIG_MOB_ALLOWED "mob_allowed"
///from base of mob/anti_magic_check(): (mob/user, magic, holy, tinfoil, chargecost, self, protection_sources)
#define COMSIG_MOB_RECEIVE_MAGIC "mob_receive_magic"
	#define COMPONENT_BLOCK_MAGIC (1<<0)

///from base of mob/create_mob_hud(): ()
#define COMSIG_MOB_HUD_CREATED "mob_hud_created"
///from base of hud/show_to(): (datum/hud/hud_source)
#define COMSIG_MOB_HUD_REFRESHED "mob_hud_refreshed"

///from base of mob/set_sight(): (new_sight, old_sight)
#define COMSIG_MOB_SIGHT_CHANGE "mob_sight_changed"
///from base of mob/set_invis_see(): (new_invis, old_invis)
#define COMSIG_MOB_SEE_INVIS_CHANGE "mob_see_invis_change"
///from base of mob/set_see_in_dark(): (new_range, old_range)
#define COMSIG_MOB_SEE_IN_DARK_CHANGE "mob_see_in_dark_change"

///from base of atom/attack_hand(): (mob/user)
#define COMSIG_MOB_ATTACK_HAND "mob_attack_hand"
///from base of /obj/item/attack(): (mob/M, mob/user)
#define COMSIG_MOB_ITEM_ATTACK "mob_item_attack"
	#define COMPONENT_ITEM_NO_ATTACK (1<<0)

///from base of /mob/living/proc/get_incoming_damage_modifier(): (list/damage_mods, damage, damagetype, def_zone, sharp, used_weapon)
#define COMSIG_MOB_APPLY_DAMAGE_MODIFIERS "mob_apply_damage_modifiers"
///from base of /mob/living/proc/get_blocking_resistance(): (list/damage_resistances, damage, damagetype, def_zone, sharp, used_weapon)
#define COMSIG_MOB_APPLY_BLOCKING_RESISTANCES "mob_apply_blocking_resistances"
///from base of /mob/living/proc/apply_damage(): (damage, damagetype, def_zone, blocked, sharp, used_weapon, spread_damage, forced)
#define COMSIG_MOB_APPLY_DAMAGE "mob_apply_damage"

///from base of obj/item/afterattack(): (atom/target, mob/user, proximity_flag, click_parameters)
#define COMSIG_MOB_ITEM_AFTERATTACK "mob_item_afterattack"
	/// Flag for when /afterattack potentially acts on an item.
	/// Used for the swap hands/drop tutorials to know when you might just be trying to do something normally.
	/// Does not necessarily imply success, or even that it did hit an item, just intent.
	#define COMPONENT_AFTERATTACK_PROCESSED_ITEM (1<<0)
///from base of obj/item/attack_qdeleted(): (atom/target, mob/user, proxiumity_flag, click_parameters)
#define COMSIG_MOB_ITEM_ATTACK_QDELETED "mob_item_attack_qdeleted"
///from base of mob/RangedAttack(): (atom/A, params)
#define COMSIG_MOB_ATTACK_RANGED "mob_attack_ranged"
///from base of mob/ranged_secondary_attack(): (atom/target, modifiers)
#define COMSIG_MOB_ATTACK_RANGED_SECONDARY "mob_attack_ranged_secondary"
///from base of mob/RangedAttack(): (atom/A, params) after being range attacked
#define COMSIG_MOB_ATTACKED_RANGED "mob_attack_ranged"
///from base of /mob/throw_item(): (atom/target)
#define COMSIG_MOB_THROW "mob_throw"

///from base of /mob/verb/examinate(): (atom/target, list/examine_strings)
#define COMSIG_MOB_EXAMINING "mob_examining"
///from base of /mob/verb/examinate(): (atom/target)
#define COMSIG_MOB_EXAMINATE "mob_examinate"
///from /mob/living/handle_eye_contact(): (mob/living/other_mob)
#define COMSIG_MOB_EYECONTACT "mob_eyecontact"
	/// return this if you want to block printing this message to this person, if you want to print your own (does not affect the other person's message)
	#define COMSIG_BLOCK_EYECONTACT (1<<0)

///called when a user is getting new weapon and we want to remove previous weapon to clear hands
#define COMSIG_MOB_WEAPON_APPEARS "mob_weapon_appears"
/// from base of /mob/verb/examinate(): (atom/target)
#define COMSIG_MOB_VERB_EXAMINATE "mob_examinate"
/// from base of /mob/proc/run_examinate(): (atom/target, list/result)
#define COMSIG_MOB_RUN_EXAMINATE "mob_run_examinate"
/// from /datum/element/halo_attach
#define COMSIG_MOB_HALO_GAINED "mob_halo_gained"
///from base of /mob/update_sight(): ()
#define COMSIG_MOB_UPDATE_SIGHT "mob_update_sight"
////from /mob/living/say(): ()
#define COMSIG_MOB_SAY "mob_say"
	#define COMPONENT_UPPERCASE_SPEECH (1<<0)
	#define COMPONENT_SMALL_SPEECH (1<<1)
	// used to access COMSIG_MOB_SAY argslist
	#define SPEECH_MESSAGE 1
	// #define SPEECH_BUBBLE_TYPE 2
	#define SPEECH_SPANS 3
	/* #define SPEECH_SANITIZE 4
	#define SPEECH_LANGUAGE 5
	#define SPEECH_IGNORE_SPAM 6
	#define SPEECH_FORCED 7 */
////from mob/living/adjust_fire_stacks()
#define COMSIG_MOB_ADJUST_FIRE "mob_adjust_fire"
/// from base of /mob/living/attack_alien(): (user)
#define COMSIG_MOB_ATTACK_ALIEN "mob_attack_alien"

////from mob/living/adjust_wet_stacks()
#define COMSIG_MOB_ADJUST_WET "mob_adjust_wet"

///from base of /mob/living/toggle_move_intent(): (old_move_intent)
#define COMSIG_MOB_MOVE_INTENT_TOGGLE "mob_move_intent_toggle"
	#define COMPONENT_BLOCK_INTENT_TOGGLE (1<<0)

#define COMSIG_MOB_MOVE_INTENT_TOGGLED "mob_move_intent_toggled"

/// from /mob/proc/combine_message (&msg)
#define COMSIG_COMBINE_MESSAGE_FOR_HEARER "combine_message_for_hearer"

///from /mob/say_dead(): (mob/speaker, message)
#define COMSIG_MOB_DEADSAY "mob_deadsay"
	#define MOB_DEADSAY_SIGNAL_INTERCEPT (1<<0)

/// Signal fired when an emote is used but before it's executed.
///from /datum/emote/proc/try_run_emote(): (key, intentional)
#define COMSIG_MOB_PREEMOTE "mob_preemote"
	// Use these to block execution of emotes from components.
	/// Return this to block an emote and let the user know the emote is unusable.
	#define COMPONENT_BLOCK_EMOTE_UNUSABLE (1<<0)
	/// Return this to block an emote silently.
	#define COMPONENT_BLOCK_EMOTE_SILENT (1<<1)
/// General signal fired when a mob does any old emote
///from /datum/emote/proc/run_emote(): (key, intentional)
#define COMSIG_MOB_EMOTE "mob_emote"
/// Specific signal used to track when a specific emote is used.
/// From /datum/emote/run_emote(): (P, key, m_type, message, intentional)
#define COMSIG_MOB_EMOTED(emote_key) "mob_emoted_[emote_key]"
/// From /datum/emote/select_param(): (target, key, intentional)
#define COMSIG_MOB_EMOTE_AT "mob_emote_at"
	#define COMPONENT_BLOCK_EMOTE_ACTION (1<<2)

///from base of /mob/verb/pointed: (atom/A)
#define COMSIG_MOB_POINTED "mob_pointed"

///from base of mob/swap_hand(): (obj/item/currently_held_item)
#define COMSIG_MOB_SWAPPING_HANDS "mob_swapping_hands"
	#define COMPONENT_BLOCK_SWAP (1<<0)
/// from base of mob/swap_hand(): ()
/// Performed after the hands are swapped.
#define COMSIG_MOB_SWAP_HANDS "mob_swap_hands"

#define COMSIG_MOB_AUTOMUTE_CHECK "automute_check"
	#define WAIVE_AUTOMUTE_CHECK (1<<0)

/// from mob/get_status_tab_items(): (list/items)
#define COMSIG_MOB_GET_STATUS_TAB_ITEMS "mob_get_status_tab_items"

///From base of mob/update_movespeed():area
#define COMSIG_MOB_MOVESPEED_UPDATED "mob_update_movespeed"

/// from /mob/proc/slip(): (weaken, obj/slipped_on, lube_flags [mobs.dm], tilesSlipped)
#define COMSIG_MOB_SLIPPED "mob_slipped"

/// From base of /mob/proc/reset_perspective() : ()
#define COMSIG_MOB_RESET_PERSPECTIVE "mob_reset_perspective"
/// from base of /client/proc/set_eye() : (atom/old_eye, atom/new_eye)
#define COMSIG_CLIENT_SET_EYE "client_set_eye"
/// from /mob/proc/change_mob_type() : ()
#define COMSIG_MOB_CHANGED_TYPE "mob_changed_type"

/// From /obj/item/melee/baton/baton_effect(): (datum/source, mob/living/user, /obj/item/melee/baton)
#define COMSIG_MOB_BATONED "mob_batoned"

/// A mob has just unequipped an item.
#define COMSIG_MOB_UNEQUIPPED_ITEM "mob_unequipped_item"
/// From base of /mob/proc/update_held_items
#define COMSIG_MOB_UPDATE_HELD_ITEMS "mob_update_held_items"

/// From /mob/add_language() (language_name)
#define COMSIG_MOB_LANGUAGE_ADD "mob_language_add"
/// From /mob/remove_language() (language_name)
#define COMSIG_MOB_LANGUAGE_REMOVE "mob_language_remove"

/// Sent from /proc/do_after if someone starts a do_after action bar.
#define COMSIG_DO_AFTER_BEGAN "mob_do_after_began"
/// Sent from /proc/do_after once a do_after action completes, whether via the bar filling or via interruption.
#define COMSIG_DO_AFTER_ENDED "mob_do_after_ended"
