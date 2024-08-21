// All signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// global signals
// These are signals which can be listened to by any component on any parent
// start global signals with "!", this used to be necessary but now it's just a formatting choice

///from base of datum/controller/subsystem/mapping/proc/add_new_zlevel(): (list/args)
#define COMSIG_GLOB_NEW_Z "!new_z"
/// called after a successful var edit somewhere in the world: (list/args)
#define COMSIG_GLOB_VAR_EDIT "!var_edit"
/// called after an explosion happened : (epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
#define COMSIG_GLOB_EXPLOSION "!explosion"
/// mob was created somewhere : (mob)
#define COMSIG_GLOB_MOB_CREATED "!mob_created"
/// mob died somewhere : (mob , gibbed)
#define COMSIG_GLOB_MOB_DEATH "!mob_death"
/// global living say plug - use sparingly: (mob/speaker , message)
#define COMSIG_GLOB_LIVING_SAY_SPECIAL "!say_special"
/// called by datum/cinematic/play() : (datum/cinematic/new_cinematic)
#define COMSIG_GLOB_PLAY_CINEMATIC "!play_cinematic"
	#define COMPONENT_GLOB_BLOCK_CINEMATIC (1<<0)
/// ingame button pressed (/obj/machinery/button/button)
#define COMSIG_GLOB_BUTTON_PRESSED "!button_pressed"
/// cable was placed or joined somewhere : (turf)
#define COMSIG_GLOB_CABLE_UPDATED "!cable_updated"

/// signals from globally accessible objects

///from SSsun when the sun changes position : (azimuth)
#define COMSIG_SUN_MOVED "sun_moved"

//////////////////////////////////////////////////////////////////

// /datum signals
/// when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_ADDED "component_added"
/// before a component is removed from a datum because of ClearFromParent(): (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"
/// before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
#define COMSIG_PREQDELETED "parent_preqdeleted"
/// just before a datum's Destroy() is called: (force), at this point none of the other components chose to interrupt qdel and Destroy will be called
#define COMSIG_QDELETING "parent_qdeleting"
/// generic topic handler (usr, href_list)
#define COMSIG_TOPIC "handle_topic"

/// fires on the target datum when an element is attached to it (/datum/element)
#define COMSIG_ELEMENT_ATTACH "element_attach"
/// fires on the target datum when an element is attached to it  (/datum/element)
#define COMSIG_ELEMENT_DETACH "element_detach"

// /atom signals
///from base of atom/proc/Initialize(): sent any time a new atom is created
#define COMSIG_ATOM_CREATED "atom_created"
//from SSatoms InitAtom - Only if the  atom was not deleted or failed initialization
#define COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE "atom_init_success"
//from SSatoms InitAtom - Only if the  atom was not deleted or failed initialization and has a loc
#define COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON "atom_init_success_on"
///from base of /obj/item//attack(): (/obj/item, /atom/source, params) sends singal on user who attacked source
#define COMSIG_ATOM_ATTACK "atom_attack"
///called when the atom sucessfully has it's density var changed, from base atom/set_density(): (value)
#define COMSIG_ATOM_SET_DENSITY "atom_set_density"
///from base of atom/set_opacity(): (new_opacity)
#define COMSIG_ATOM_SET_OPACITY "atom_set_opacity"
///from base of atom/experience_pressure_difference(): (pressure_difference, direction, pressure_resistance_prob_delta)
#define COMSIG_ATOM_PRE_PRESSURE_PUSH "atom_pre_pressure_push"
	///prevents pressure movement
	#define COMSIG_ATOM_BLOCKS_PRESSURE (1<<0)
///signal sent out by an atom when it checks if it can be pulled, for additional checks
#define COMSIG_ATOM_CAN_BE_PULLED "movable_can_be_pulled"
	#define COMSIG_ATOM_CANT_PULL (1 << 0)
///signal sent out by an atom when it is no longer being pulled by something else : (atom/puller)
#define COMSIG_ATOM_NO_LONGER_PULLED "movable_no_longer_pulled"
///signal sent out by an atom when it is no longer pulling something : (atom/pulling)
#define COMSIG_ATOM_NO_LONGER_PULLING "movable_no_longer_pulling"

///from base of atom/attackby(): (/obj/item, /mob/living, params)
#define COMSIG_PARENT_ATTACKBY "atom_attackby"
///from base of atom/attack_hulk(): (/mob/living/carbon/human)
#define COMSIG_ATOM_HULK_ATTACK "hulk_attack"
///from base of atom/animal_attack(): (/mob/user)
#define COMSIG_ATOM_ATTACK_ANIMAL "attack_animal"
///from base of atom/examine(): (/mob)
#define COMSIG_PARENT_EXAMINE "atom_examine"
///from base of atom/get_examine_name(): (/mob, list/overrides)
#define COMSIG_ATOM_GET_EXAMINE_NAME "atom_examine_name"
	//Positions for overrides list
	#define EXAMINE_POSITION_ARTICLE (1<<0)
	#define EXAMINE_POSITION_BEFORE (1<<1)
	//End positions
	#define COMPONENT_EXNAME_CHANGED (1<<0)
	///from base of [/atom/proc/update_appearance]: (updates)
	#define COMSIG_ATOM_UPDATE_APPEARANCE "atom_update_appearance"
	/// If returned from [COMSIG_ATOM_UPDATE_APPEARANCE] it prevents the atom from updating its name.
	#define COMSIG_ATOM_NO_UPDATE_NAME UPDATE_NAME
	/// If returned from [COMSIG_ATOM_UPDATE_APPEARANCE] it prevents the atom from updating its desc.
	#define COMSIG_ATOM_NO_UPDATE_DESC UPDATE_DESC
	/// If returned from [COMSIG_ATOM_UPDATE_APPEARANCE] it prevents the atom from updating its icon.
	#define COMSIG_ATOM_NO_UPDATE_ICON UPDATE_ICON
///from base of [/atom/proc/update_name]: (updates)
#define COMSIG_ATOM_UPDATE_NAME "atom_update_name"
///from base of [/atom/proc/update_desc]: (updates)
#define COMSIG_ATOM_UPDATE_DESC "atom_update_desc"
///from base of [/atom/update_icon]: ()
#define COMSIG_ATOM_UPDATE_ICON "atom_update_icon"
	/// If returned from [COMSIG_ATOM_UPDATE_ICON] it prevents the atom from updating its icon state.
	#define COMSIG_ATOM_NO_UPDATE_ICON_STATE UPDATE_ICON_STATE
	/// If returned from [COMSIG_ATOM_UPDATE_ICON] it prevents the atom from updating its overlays.
	#define COMSIG_ATOM_NO_UPDATE_OVERLAYS UPDATE_OVERLAYS
///Sent after [atom/update_icon_state] is called by [/atom/update_icon]: ()
#define COMSIG_ATOM_UPDATE_ICON_STATE "atom_update_icon_state"
///Sent after [atom/update_overlays] is called by [/atom/update_icon]: (list/new_overlays)
#define COMSIG_ATOM_UPDATE_OVERLAYS "atom_update_overlays"
///from base of [/atom/update_icon]: (signalOut, did_anything)
#define COMSIG_ATOM_UPDATED_ICON "atom_updated_icon"
///from base of atom/Entered(): (atom/movable/arrived, atom/old_loc, list/atom/old_locs)
#define COMSIG_ATOM_ENTERED "atom_entered"
/// Sent from the atom that just Entered src. From base of atom/Entered(): (/atom/destination, atom/old_loc, list/atom/old_locs)
#define COMSIG_ATOM_ENTERING "atom_entering"
///from base of atom/movable/Moved(): (atom/movable/arrived, atom/old_loc, list/atom/old_locs)
#define COMSIG_ATOM_ABSTRACT_ENTERED "atom_abstract_entered"
///from base of atom/Exit(): (/atom/movable/exiting, /atom/newloc)
#define COMSIG_ATOM_EXIT "atom_exit"
	#define COMPONENT_ATOM_BLOCK_EXIT (1<<0)
///from base of atom/Exited(): (atom/movable/departed, atom/newloc)
#define COMSIG_ATOM_EXITED "atom_exited"
///from base of atom/movable/Moved(): (atom/movable/gone, direction)
#define COMSIG_ATOM_ABSTRACT_EXITED "atom_abstract_exited"
///from base of atom/Bumped(): (/atom/movable)
#define COMSIG_ATOM_BUMPED "atom_bumped"
///from base of atom/ex_act(): (severity, target)
#define COMSIG_ATOM_EX_ACT "atom_ex_act"
///from base of atom/emp_act(): (severity)
#define COMSIG_ATOM_EMP_ACT "atom_emp_act"
///from base of atom/fire_act(): (exposed_temperature, exposed_volume)
#define COMSIG_ATOM_FIRE_ACT "atom_fire_act"
///from base of atom/bullet_act(): (/obj/projectile, def_zone)
#define COMSIG_ATOM_BULLET_ACT "atom_bullet_act"
///from base of atom/blob_act(): (/obj/structure/blob)
#define COMSIG_ATOM_BLOB_ACT "atom_blob_act"
///from base of atom/acid_act(): (acidpwr, acid_volume)
#define COMSIG_ATOM_ACID_ACT "atom_acid_act"
///from base of atom/emag_act(): (/mob/user)
#define COMSIG_ATOM_EMAG_ACT "atom_emag_act"
///from base of atom/rad_act(intensity)
#define COMSIG_ATOM_RAD_ACT "atom_rad_act"
///from base of atom/narsie_act(): ()
#define COMSIG_ATOM_NARSIE_ACT "atom_narsie_act"
///from base of atom/rcd_act(): (/mob, /obj/item/construction/rcd, passed_mode)
#define COMSIG_ATOM_RCD_ACT "atom_rcd_act"
///from base of atom/singularity_pull(): (S, current_size)
#define COMSIG_ATOM_SING_PULL "atom_sing_pull"
///from obj/machinery/bsa/full/proc/fire(): ()
#define COMSIG_ATOM_BSA_BEAM "atom_bsa_beam_pass"
	#define COMSIG_ATOM_BLOCKS_BSA_BEAM (1<<0)

/// From base of atom/setDir(): (old_dir, new_dir). Called before the direction changes
#define COMSIG_ATOM_PRE_DIR_CHANGE "atom_pre_dir_change"
	#define COMPONENT_ATOM_BLOCK_DIR_CHANGE (1<<0)
///from base of atom/setDir(): (old_dir, new_dir). Called before the direction changes.
#define COMSIG_ATOM_DIR_CHANGE "atom_dir_change"
///from base of atom/setDir(): (old_dir, new_dir). Called after the direction changes.
#define COMSIG_ATOM_POST_DIR_CHANGE "atom_dir_change"
///from base of atom/movable/keybind_face_direction(): (dir). Called before turning with the movement lock key.
#define COMSIG_MOVABLE_KEYBIND_FACE_DIR "keybind_face_dir"
	///ignores the movement lock key, used for turning while strafing in a mech
	#define COMSIG_IGNORE_MOVEMENT_LOCK (1<<0)

///from base of atom/handle_atom_del(): (atom/deleted)
#define COMSIG_ATOM_CONTENTS_DEL "atom_contents_del"
///from base of atom/has_gravity(): (turf/location, list/forced_gravities)
#define COMSIG_ATOM_HAS_GRAVITY "atom_has_gravity"
///from proc/get_rad_contents(): ()
#define COMSIG_ATOM_RAD_PROBE "atom_rad_probe"
	#define COMPONENT_BLOCK_RADIATION (1<<0)
///from base of datum/radiation_wave/radiate(): (strength)
#define COMSIG_ATOM_RAD_CONTAMINATING "atom_rad_contam"
	#define COMPONENT_BLOCK_CONTAMINATION (1<<0)
///from base of datum/radiation_wave/check_obstructions(): (datum/radiation_wave, width)
#define COMSIG_ATOM_RAD_WAVE_PASSING "atom_rad_wave_pass"
  #define COMPONENT_RAD_WAVE_HANDLED (1<<0)
///from internal loop in atom/movable/proc/CanReach(): (list/next)
#define COMSIG_ATOM_CANREACH "atom_can_reach"
	#define COMPONENT_BLOCK_REACH (1<<0)
///from base of atom/screwdriver_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_SCREWDRIVER_ACT "atom_screwdriver_act"
///from base of atom/wrench_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_WRENCH_ACT "atom_wrench_act"
///from base of atom/multitool_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_MULTITOOL_ACT "atom_multitool_act"
///from base of atom/welder_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_WELDER_ACT "atom_welder_act"
///from base of atom/wirecutter_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_WIRECUTTER_ACT "atom_wirecutter_act"
///from base of atom/crowbar_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_CROWBAR_ACT "atom_crowbar_act"
///from base of atom/analyser_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_ANALYSER_ACT "atom_analyser_act"
	#define COMPONENT_BLOCK_TOOL_ATTACK (1<<0)
///called when teleporting into a possibly protected turf: (turf/origin)
#define COMSIG_ATOM_INTERCEPT_TELEPORTING "intercept_teleporting"
	#define COMPONENT_BLOCK_TELEPORT (1<<0)
///called when an atom is added to the hearers on get_hearers_in_view(): (list/processing_list, list/hearers)
#define COMSIG_ATOM_HEARER_IN_VIEW "atom_hearer_in_view"
///called when an atom starts orbiting another atom: (atom)
#define COMSIG_ATOM_ORBIT_BEGIN "atom_orbit_begin"
///called when an atom stops orbiting another atom: (atom)
#define COMSIG_ATOM_ORBIT_STOP "atom_orbit_stop"
///from base of atom/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
#define COMSIG_ATOM_HITBY "atom_hitby"
/// Called when an atom is sharpened or dulled.
#define COMSIG_ATOM_UPDATE_SHARPNESS "atom_update_sharpness"

// Attack signals. These should share the returned flags, to standardize the attack chain.
// The chain currently works like:
// tool_act -> pre_attackby -> target.attackby (item.attack) -> afterattack
// You can use these signal responses to cancel the attack chain at a certain point from most attack signal types.
	/// This response cancels the attack chain entirely. If sent early, it might cause some later effects to be skipped.
	#define COMPONENT_CANCEL_ATTACK_CHAIN (1<<0)
	///Return this in response if you don't want afterattack to be called
	#define COMPONENT_NO_AFTERATTACK (1<<1)
	///Skips the specific attack step, continuing for the next one to happen.
	#define COMPONENT_SKIP_ATTACK (1<<2)

/////////////////
///from base of atom/attack_ghost(): (mob/dead/observer/ghost)
#define COMSIG_ATOM_ATTACK_GHOST "atom_attack_ghost"
///from base of atom/attack_hand(): (mob/user)
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"
///from base of atom/attack_paw(): (mob/user)
#define COMSIG_ATOM_ATTACK_PAW "atom_attack_paw"
	#define COMPONENT_NO_ATTACK_HAND (1<<0)								//works on all 3.
//This signal return value bitflags can be found in __DEFINES/misc.dm

///called on a movable (NOT living) when someone starts pulling it (atom/movable/puller, state, force)
#define COMSIG_ATOM_START_PULL "movable_start_pull"
/// called on /atom when something attempts to pass through it (atom/movable/source, atom/movable/passing, dir)
#define COMSIG_ATOM_TRIED_PASS "atom_tried_pass"
	#define COMSIG_COMPONENT_PERMIT_PASSAGE (1 << 0)
///called for each movable in a turf contents on /turf/zImpact(): (atom/movable/A, levels)
#define COMSIG_ATOM_INTERCEPT_Z_FALL "movable_intercept_z_impact"
///signal sent out by an atom upon onZImpact : (turf/impacted_turf, levels)
#define COMSIG_ATOM_ON_Z_IMPACT "movable_on_z_impact"
///From base of mob/living/ZImpactDamage() (mob/living, levels, turf/t)
#define COMSIG_LIVING_Z_IMPACT "living_z_impact"
/// Just for the signal return, does not run normal living handing of z fall damage for mobs
	#define ZIMPACT_CANCEL_DAMAGE (1<<0)
	/// Do not show default z-impact message
	#define ZIMPACT_NO_MESSAGE (1<<1)
	/// Do not do the spin animation when landing
	#define ZIMPACT_NO_SPIN (1<<2)

/////////////////

///from base of atom/Click(): (location, control, params, mob/user)
#define COMSIG_CLICK "atom_click"
///from base of atom/ShiftClick(): (/mob)
#define COMSIG_CLICK_SHIFT "shift_click"
	#define COMPONENT_ALLOW_EXAMINATE (1<<0) 							//Allows the user to examinate regardless of client.eye.
///from base of atom/CtrlClickOn(): (/mob)
#define COMSIG_CLICK_CTRL "ctrl_click"
///from base of atom/AltClick(): (/mob)
#define COMSIG_CLICK_ALT "alt_click"
///from base of atom/CtrlShiftClick(/mob)
#define COMSIG_CLICK_CTRL_SHIFT "ctrl_shift_click"
///from base of atom/MouseDrop(): (/atom/over, /mob/user)
#define COMSIG_MOUSEDROP_ONTO "mousedrop_onto"
	#define COMPONENT_NO_MOUSEDROP (1<<0)
///from base of atom/MouseDrop_T: (/atom/from, /mob/user)
#define COMSIG_MOUSEDROPPED_ONTO "mousedropped_onto"

// /area signals

///from base of area/proc/power_change(): ()
#define COMSIG_AREA_POWER_CHANGE "area_power_change"
///from base of area/Entered(): (atom/movable/arrived, area/old_area)
#define COMSIG_AREA_ENTERED "area_entered"
///from base of area/Exited(): (atom/movable/departed, area/new_area)
#define COMSIG_AREA_EXITED "area_exited"
///from base of area/Entered(): (area/current_area, area/old_area)
#define COMSIG_ATOM_ENTERED_AREA "atom_entered_area"
///from base of area/Exited(): (area/current_area, area/new_area)
#define COMSIG_ATOM_EXITED_AREA "atom_exited_area"

// /turf signals

///from base of turf/ChangeTurf(): (path, list/new_baseturf, flags, list/transferring_comps)
#define COMSIG_TURF_CHANGE "turf_change"
///from base of atom/has_gravity(): (atom/asker, list/forced_gravities)
#define COMSIG_TURF_HAS_GRAVITY "turf_has_gravity"
///from base of turf/multiz_turf_del(): (turf/source, direction)
#define COMSIG_TURF_MULTIZ_DEL "turf_multiz_del"
///from base of turf/multiz_turf_new: (turf/source, direction)
#define COMSIG_TURF_MULTIZ_NEW "turf_multiz_new"
// /atom/movable signals

///from base of atom/movable/Move(): (/atom/new_loc)
#define COMSIG_MOVABLE_PRE_MOVE "movable_pre_move"
	#define COMPONENT_MOVABLE_BLOCK_PRE_MOVE (1<<0)
///from base of atom/movable/Moved(): (atom/old_loc, dir, forced, list/old_locs, momentum_change)
#define COMSIG_MOVABLE_MOVED "movable_moved"
///from base of atom/movable/Cross(): (/atom/movable)
#define COMSIG_MOVABLE_CROSS "movable_cross"
///from base of atom/movable/Cross(): (/atom/movable)
#define COMSIG_MOVABLE_CROSS_OVER "movable_cross_am"
///from base of atom/movable/Bump(): (/atom/bumped_atom)
#define COMSIG_MOVABLE_BUMP "movable_bump"
///from base of atom/movable/throw_impact(): (/atom/hit_atom, /datum/thrownthing/throwingdatum)
#define COMSIG_MOVABLE_IMPACT "movable_impact"
	#define COMPONENT_MOVABLE_IMPACT_FLIP_HITPUSH (1<<0)				//if true, flip if the impact will push what it hits
	#define COMPONENT_MOVABLE_IMPACT_NEVERMIND (1<<1)					//return true if you destroyed whatever it was you're impacting and there won't be anything for hitby() to run on
///from base of mob/living/hitby(): (mob/living/target, hit_zone)
#define COMSIG_MOVABLE_IMPACT_ZONE "item_impact_zone"
///from base of atom/movable/buckle_mob(): (mob, force)
#define COMSIG_MOVABLE_BUCKLE "buckle"
///from base of atom/movable/unbuckle_mob(): (mob, force)
#define COMSIG_MOVABLE_UNBUCKLE "unbuckle"
///from base of atom/movable/throw_at(): (list/args)
#define COMSIG_MOVABLE_PRE_THROW "movable_pre_throw"
	#define COMPONENT_CANCEL_THROW (1<<0)
///from base of atom/movable/throw_at(): (datum/thrownthing, spin)
#define COMSIG_MOVABLE_POST_THROW "movable_post_throw"
///from base of datum/thrownthing/finalize(): (obj/thrown_object, datum/thrownthing) used for when a throw is finished
#define COMSIG_MOVABLE_THROW_LANDED "movable_throw_landed"
///from base of atom/movable/on_changed_z_level(): (turf/old_turf, turf/new_turf, same_z_layer)
#define COMSIG_MOVABLE_Z_CHANGED "movable_ztransit"
///called when the movable is placed in an unaccessible area, used for stationloving: ()
#define COMSIG_MOVABLE_SECLUDED_LOCATION "movable_secluded"
///from base of atom/movable/Hear(): (proc args list(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode))
#define COMSIG_MOVABLE_HEAR "movable_hear"
	#define HEARING_MESSAGE 1
	#define HEARING_SPEAKER 2
//	#define HEARING_LANGUAGE 3
	#define HEARING_RAW_MESSAGE 4
	/* #define HEARING_RADIO_FREQ 5
	#define HEARING_SPANS 6
	#define HEARING_MESSAGE_MODE 7 */
///called when the movable sucessfully has it's anchored var changed, from base atom/movable/set_anchored(): (value)
#define COMSIG_MOVABLE_SET_ANCHORED "movable_set_anchored"
///from base of atom/movable/setGrabState(): (newstate)
#define COMSIG_MOVABLE_SET_GRAB_STATE "living_set_grab_state"
/// Called when something is pushed by a living mob bumping it: (mob/living/pusher, push force)
#define COMSIG_MOVABLE_BUMP_PUSHED "movable_bump_pushed"
	/// Stop it from moving
	#define COMPONENT_NO_PUSH (1<<0)

///called when the movable is added to a disposal holder object for disposal movement: (obj/structure/disposalholder/holder, obj/machinery/disposal/source)
#define COMSIG_MOVABLE_DISPOSING "movable_disposing"
///called when the movable is removed from a disposal holder object: /obj/structure/disposalpipe/proc/expel(): (obj/structure/disposalholder/H, turf/T, direction)
// called when movable is expelled from a disposal pipe, bin or outlet on obj/pipe_eject: (direction)
#define COMSIG_MOVABLE_PIPE_EJECTING "movable_pipe_ejecting"
///From base of /datum/move_loop/process() after attempting to move a movable: (datum/move_loop/loop, old_dir)
#define COMSIG_MOVABLE_MOVED_FROM_LOOP "movable_moved_from_loop"
///called when the movable's glide size is updated: (new_glide_size)
#define COMSIG_MOVABLE_UPDATE_GLIDE_SIZE "movable_glide_size"
/// from base of atom/movable/Process_Spacemove(): (movement_dir, continuous_move)
#define COMSIG_MOVABLE_SPACEMOVE "spacemove"
	#define COMSIG_MOVABLE_STOP_SPACEMOVE (1<<0)
///from base of atom/movable/newtonian_move(): (inertia_direction, start_delay)
#define COMSIG_MOVABLE_NEWTONIAN_MOVE "movable_newtonian_move"
	#define COMPONENT_MOVABLE_NEWTONIAN_BLOCK (1<<0)
///from datum/component/drift/apply_initial_visuals(): ()
#define COMSIG_MOVABLE_DRIFT_VISUAL_ATTEMPT "movable_drift_visual_attempt"
	#define DRIFT_VISUAL_FAILED (1<<0)
///from datum/component/drift/allow_final_movement(): ()
#define COMSIG_MOVABLE_DRIFT_BLOCK_INPUT "movable_drift_block_input"
	#define DRIFT_ALLOW_INPUT (1<<0)
///Called before a movable is being teleported from `initTeleport()`: (turf/origin, turf/destination)
#define COMSIG_MOVABLE_TELEPORTING "movable_teleporting"

// /datum/mind signals

///from base of /datum/mind/proc/transfer_to(mob/living/new_character)
#define COMSIG_MIND_TRANSER_TO "mind_transfer_to"
///called on the mob instead of the mind
#define COMSIG_BODY_TRANSFER_TO "body_transfer_to"
// /mob signals

///from base of /mob/Login(): ()
#define COMSIG_MOB_LOGIN "mob_login"
///from base of /mob/Logout(): ()
#define COMSIG_MOB_LOGOUT "mob_logout"
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

///from base of mob/key_down(): (_key, client/user)
#define COMSIG_MOB_KEY_DROP_ITEM_DOWN "mob_key_drop_item_down"
	#define COMPONENT_CANCEL_DROP (1<<0)

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
#define COMSIG_MOB_APPLY_DAMAGE	"mob_apply_damage"

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
///from base of /mob/throw_item(): (atom/target)
#define COMSIG_MOB_THROW "mob_throw"
///called when a user is getting new weapon and we want to remove previous weapon to clear hands
#define COMSIG_MOB_WEAPON_APPEARS "mob_weapon_appears"
///from base of /mob/verb/examinate(): (atom/target)
#define COMSIG_MOB_EXAMINATE "mob_examinate"
///from base of /mob/update_sight(): ()
#define COMSIG_MOB_UPDATE_SIGHT "mob_update_sight"
////from /mob/living/say(): ()
#define COMSIG_MOB_SAY "mob_say"
	#define COMPONENT_UPPERCASE_SPEECH (1<<0)
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

///from base of /mob/living/toggle_move_intent(): (old_move_intent)
#define COMSIG_MOB_MOVE_INTENT_TOGGLE "mob_move_intent_toggle"
	#define COMPONENT_BLOCK_INTENT_TOGGLE (1<<0)

#define COMSIG_MOB_MOVE_INTENT_TOGGLED "mob_move_intent_toggled"

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

///From base of mob/update_movespeed():area
#define COMSIG_MOB_MOVESPEED_UPDATED "mob_update_movespeed"

/// from /mob/proc/slip(): (weaken, obj/slipped_on, lube_flags [mobs.dm], tilesSlipped)
#define COMSIG_MOB_SLIPPED "mob_slipped"

/// From base of /mob/proc/reset_perspective() : ()
#define COMSIG_MOB_RESET_PERSPECTIVE "mob_reset_perspective"
/// from base of /client/proc/set_eye() : (atom/old_eye, atom/new_eye)
#define COMSIG_CLIENT_SET_EYE "client_set_eye"
// from /client/proc/change_view() : (new_size)
#define COMSIG_VIEW_SET "view_set"

// /mob/living signals

///from base of mob/living/resist() (/mob/living)
#define COMSIG_LIVING_RESIST "living_resist"
///from base of mob/living/IgniteMob() (/mob/living)
#define COMSIG_LIVING_IGNITED "living_ignite"
///from base of mob/living/ExtinguishMob() (/mob/living)
#define COMSIG_LIVING_EXTINGUISHED "living_extinguished"
///from base of mob/living/electrocute_act(): (shock_damage, source, siemens_coeff, flags)
#define COMSIG_LIVING_ELECTROCUTE_ACT "living_electrocute_act"
	/// Block the electrocute_act() proc from proceeding
	#define COMPONENT_LIVING_BLOCK_SHOCK (1<<0)
///sent when items with siemen coeff. of 0 block a shock: (power_source, source, siemens_coeff, dist_check)
#define COMSIG_LIVING_SHOCK_PREVENTED "living_shock_prevented"
///sent by stuff like stunbatons and tasers: ()
#define COMSIG_LIVING_MINOR_SHOCK "living_minor_shock"
///from base of mob/living/revive() (full_heal, admin_revive)
#define COMSIG_LIVING_REVIVE "living_revive"
///from base of /mob/living/regenerate_limbs(): (noheal, excluded_limbs)
#define COMSIG_LIVING_REGENERATE_LIMBS "living_regen_limbs"
///from base of /obj/item/bodypart/proc/attach_limb(): (new_limb, special) allows you to fail limb attachment
#define COMSIG_LIVING_ATTACH_LIMB "living_attach_limb"
	#define COMPONENT_NO_ATTACH (1<<0)
///sent from borg recharge stations: (amount, repairs)
#define COMSIG_PROCESS_BORGCHARGER_OCCUPANT "living_charge"
///sent when a mob/login() finishes: (client)
#define COMSIG_MOB_CLIENT_LOGIN "comsig_mob_client_login"
//from base of client/MouseDown(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEDOWN "client_mousedown"
//from base of client/MouseUp(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEUP "client_mouseup"
	#define COMPONENT_CLIENT_MOUSEUP_INTERCEPT (1<<0)
//from base of client/MouseUp(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEDRAG "client_mousedrag"
///sent from borg mobs to itself, for tools to catch an upcoming destroy() due to safe decon (rather than detonation)
#define COMSIG_BORG_SAFE_DECONSTRUCT "borg_safe_decon"
///sent from living mobs every tick of fire
#define COMSIG_LIVING_FIRE_TICK "living_fire_tick"
//sent from living mobs when they are ahealed
#define COMSIG_LIVING_AHEAL "living_aheal"
///From living/Life(). (deltatime, times_fired)
#define COMSIG_LIVING_LIFE "living_life"
///from base of mob/living/death(): (gibbed)
#define COMSIG_LIVING_DEATH "living_death"
//sent from mobs when they exit their body as a ghost
#define COMSIG_LIVING_GHOSTIZED "ghostized"
//sent from mobs when they re-enter their body as a ghost
#define COMSIG_LIVING_REENTERED_BODY "reentered_body"
//sent from a mob when they set themselves to DNR
#define COMSIG_LIVING_SET_DNR "set_dnr"
///from base of mob/living/set_buckled(): (new_buckled)
#define COMSIG_LIVING_SET_BUCKLED "living_set_buckled"
///from base of mob/living/set_body_position()
#define COMSIG_LIVING_SET_BODY_POSITION  "living_set_body_position"
///From living/set_resting(): (new_resting, silent, instant)
#define COMSIG_LIVING_RESTING "living_resting"
///from base of mob/update_transform()
#define COMSIG_LIVING_POST_UPDATE_TRANSFORM "living_post_update_transform"

///called on /living when someone starts pulling (atom/movable/pulled, state, force)
#define COMSIG_LIVING_START_PULL "living_start_pull"
///called on /living when someone is pulled (mob/living/puller)
#define COMSIG_LIVING_GET_PULLED "living_start_pulled"
///called on /living, when pull is attempted, but before it completes, from base of [/mob/living/start_pulling]: (atom/movable/thing, force)
#define COMSIG_LIVING_TRY_PULL "living_try_pull"
	#define COMSIG_LIVING_CANCEL_PULL (1<<0)
#define COMSIG_LIVING_TRYING_TO_PULL "living_tried_pulling"
/// Called from /mob/living/update_pull_movespeed
#define COMSIG_LIVING_UPDATING_PULL_MOVESPEED "living_updating_pull_movespeed"
/// Called from /mob/living/PushAM -- Called when this mob is about to push a movable, but before it moves
/// (aotm/movable/being_pushed)
#define COMSIG_LIVING_PUSHING_MOVABLE "living_pushing_movable"

///from base of mob/living/Stun() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_STUN "living_stun"
///from base of mob/living/Weaken() (amount, ignore_canweaken)
#define COMSIG_LIVING_STATUS_WEAKEN "living_weaken"
///from base of mob/living/Knockdown() (amount, ignore_canknockdown)
#define COMSIG_LIVING_STATUS_KNOCKDOWN "living_knockdown"
///from base of mob/living/Immobilize() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_IMMOBILIZE "living_immobilize"
///from base of mob/living/Paralyze() (amount, ignore_canparalyse)
#define COMSIG_LIVING_STATUS_PARALYZE "living_paralyze"
///from base of mob/living/Sleeping() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_SLEEP "living_sleeping"
/// from mob/living/check_incapacitating_immunity(): (check_flags, force_apply)
#define COMSIG_LIVING_GENERIC_INCAPACITATE_CHECK "living_check_incapacitate"
	#define COMPONENT_NO_EFFECT (1<<0) //For all of them

/// Sent to a mob grabbing another mob: (mob/living/grabbing)
#define COMSIG_LIVING_GRAB "living_grab"
	// Return COMPONENT_CANCEL_ATTACK_CHAIN to stop the grab

///from base of /mob/living/can_track(): (mob/user)
#define COMSIG_LIVING_CAN_TRACK "mob_cantrack"
	#define COMPONENT_CANT_TRACK (1<<0)

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

/// From base of /client/Move(): (list/move_args)
#define COMSIG_MOB_CLIENT_PRE_LIVING_MOVE "mob_client_pre_living_move"
	/// Should we stop the current living movement attempt
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// from base of /client/proc/handle_popup_close() : (window_id)
#define COMSIG_POPUP_CLEARED "popup_cleared"

// /mob/living/carbon signals

///from base of mob/living/carbon/soundbang_act(): (list(intensity))
#define COMSIG_CARBON_SOUNDBANG "carbon_soundbang"
///from /item/organ/proc/Insert() (/obj/item/organ/)
#define COMSIG_CARBON_GAIN_ORGAN "carbon_gain_organ"
///from /item/organ/proc/Remove() (/obj/item/organ/)
#define COMSIG_CARBON_LOSE_ORGAN "carbon_lose_organ"
///from /mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop, silent)
#define COMSIG_CARBON_EQUIP_HAT "carbon_equip_hat"
///from /mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop, silent)
#define COMSIG_CARBON_UNEQUIP_HAT "carbon_unequip_hat"
///defined twice, in carbon and human's topics, fired when interacting with a valid embedded_object to pull it out (mob/living/carbon/target, /obj/item, /obj/item/bodypart/L)
#define COMSIG_CARBON_EMBED_RIP "item_embed_start_rip"
///called when removing a given item from a mob, from mob/living/carbon/remove_embedded_object(mob/living/carbon/target, /obj/item)
#define COMSIG_CARBON_EMBED_REMOVAL "item_embed_remove_safe"
// called when carbon receiving a /obj/item/organ/external/proc/fracture
#define COMSIG_CARBON_RECEIVE_FRACTURE "carbon_receive_fracture"
///called when something thrown hits a mob, from /mob/living/carbon/human/hitby(mob/living/carbon/target, /obj/item)
#define COMSIG_CARBON_HITBY "carbon_hitby"
/// From /mob/living/carbon/human/hitby()
#define COMSIG_CARBON_THROWN_ITEM_CAUGHT "carbon_thrown_item_caught"
/// From /mob/living/carbon/toggle_throw_mode()
#define COMSIG_CARBON_TOGGLE_THROW "carbon_toggle_throw"
///When a carbon slips. Called on /turf/simulated/handle_slip()
#define COMSIG_ON_CARBON_SLIP "carbon_slip"
///called on /carbon when attempting to pick up an item, from base of /mob/living/carbon/put_in_hand_check(obj/item/I, hand_id)
#define COMSIG_CARBON_TRY_PUT_IN_HAND "carbon_try_put_in_hand"
	/// Can't pick up
	#define COMPONENT_CARBON_CANT_PUT_IN_HAND (1<<0)
/// from /mob/living/carbon/enter_stamcrit()
#define COMSIG_CARBON_ENTER_STAMCRIT "carbon_enter_stamcrit"
///Called from apply_overlay(cache_index, overlay)
#define COMSIG_CARBON_APPLY_OVERLAY "carbon_apply_overlay"
///Called from remove_overlay(cache_index, overlay)
#define COMSIG_CARBON_REMOVE_OVERLAY "carbon_remove_overlay"

// /mob/living/simple_animal signals
///from /mob/living/attack_animal():	(mob/living/simple_animal/M)
#define COMSIG_SIMPLE_ANIMAL_ATTACKEDBY "simple_animal_attackedby"
	#define COMPONENT_SIMPLE_ANIMAL_NO_ATTACK (1<<0)

// /mob/living/simple_animal/hostile signals
#define COMSIG_HOSTILE_ATTACKINGTARGET "hostile_attackingtarget"
	#define COMPONENT_HOSTILE_NO_ATTACK (1<<0)

/// Called when a /mob/living/simple_animal/hostile fines a new target: (atom/source, give_target)
#define COMSIG_HOSTILE_FOUND_TARGET "comsig_hostile_found_target"

/// from /mob/living/can_z_move, sent to whatever the mob is buckled to. Only ridable movables should be ridden up or down btw.
#define COMSIG_BUCKLED_CAN_Z_MOVE "ridden_pre_can_z_move"
	#define COMPONENT_RIDDEN_STOP_Z_MOVE 1
	#define COMPONENT_RIDDEN_ALLOW_Z_MOVE 2

// /obj signals

///from base of obj/deconstruct(): (disassembled)
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"
///called in /obj/structure/setAnchored(): (value)
#define COMSIG_OBJ_SETANCHORED "obj_setanchored"
///from base of code/game/machinery
#define COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH "obj_default_unfasten_wrench"
///from base of /turf/proc/levelupdate(). (intact) true to hide and false to unhide
#define COMSIG_OBJ_HIDE	"obj_hide"
///from base of /proc/possess(): (mob/user)
#define COMSIG_OBJ_POSSESSED "obj_possessed"
///from base of /proc/release(): (mob/user)
#define COMSIG_OBJ_RELEASED "obj_released"

// /obj/machinery signals

///from /obj/machinery/obj_break(damage_flag): (damage_flag)
#define COMSIG_MACHINERY_BROKEN "machinery_broken"
///from base power_change() when power is lost
#define COMSIG_MACHINERY_POWER_LOST "machinery_power_lost"
///from base power_change() when power is restored
#define COMSIG_MACHINERY_POWER_RESTORED "machinery_power_restored"

// /obj/item signals

///from base of obj/item/attack(): (/mob/living/target, /mob/living/user, params, def_zone)
#define COMSIG_ITEM_ATTACK "item_attack"
///from base of obj/item/attack_self(): (/mob)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"
	#define COMPONENT_NO_INTERACT (1<<0)
///from base of obj/item/attack_obj(): (/obj, /mob)
#define COMSIG_ITEM_ATTACK_OBJ "item_attack_obj"
///from base of obj/item/pre_attackby(): (atom/target, mob/user, params)
#define COMSIG_ITEM_PRE_ATTACKBY "item_pre_attackby"
///from base of obj/item/afterattack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_AFTERATTACK "item_afterattack"
///from base of obj/item/attack_qdeleted(): (atom/target, mob/user, params)
#define COMSIG_ITEM_ATTACK_QDELETED "item_attack_qdeleted"
///from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_EQUIPPED "item_equip"
///called on [/obj/item] before unequip from base of [mob/proc/do_Equip]: (force, atom/newloc, no_move, invdrop)
#define COMSIG_ITEM_PRE_UNEQUIP "item_pre_unequip"
	///only the pre unequip can be cancelled
	#define COMPONENT_ITEM_BLOCK_UNEQUIP (1<<0)
///called on [/obj/item] AFTER unequip from base of [mob/proc/do_unEquip]: (force, atom/newloc, no_move, invdrop, silent)
#define COMSIG_ITEM_POST_UNEQUIP "item_post_unequip"
///from base of obj/item/dropped(): (mob/user)
#define COMSIG_ITEM_DROPPED "item_drop"
///from base of obj/item/pickup(): (/mob/taker)
#define COMSIG_ITEM_PICKUP "item_pickup"
///return a truthy value to prevent ensouling, checked in /obj/effect/proc_holder/spell/lichdom/cast(): (mob/user)
#define COMSIG_ITEM_IMBUE_SOUL "item_imbue_soul"
///called before marking an object for retrieval, checked in /obj/effect/proc_holder/spell/summonitem/cast() : (mob/user)
#define COMSIG_ITEM_MARK_RETRIEVAL "item_mark_retrieval"
	#define COMPONENT_BLOCK_MARK_RETRIEVAL (1<<0)
///from base of obj/item/hit_reaction(): (list/args)
#define COMSIG_ITEM_HIT_REACT "item_hit_react"
	#define COMPONENT_BLOCK_SUCCESSFUL (1 << 0)
///called on item when crossed by something (): (/atom/movable, mob/living/crossed)
#define COMSIG_ITEM_WEARERCROSSED "wearer_crossed"
///called on item when microwaved (): (obj/machinery/microwave/M)
#define COMSIG_ITEM_MICROWAVE_ACT "microwave_act"
///from base of item/sharpener/attackby(): (amount, max)
#define COMSIG_ITEM_SHARPEN_ACT "sharpen_act"
	#define COMPONENT_BLOCK_SHARPEN_APPLIED (1<<0)
	#define COMPONENT_BLOCK_SHARPEN_BLOCKED (1<<1)
	#define COMPONENT_BLOCK_SHARPEN_ALREADY (1<<2)
	#define COMPONENT_BLOCK_SHARPEN_MAXED (1<<3)
///from base of [/obj/item/proc/tool_check_callback]: (mob/living/user)
#define COMSIG_TOOL_IN_USE "tool_in_use"
///from base of [/obj/item/proc/tool_start_check]: (mob/living/user)
#define COMSIG_TOOL_START_USE "tool_start_use"
///from [/obj/item/proc/disableEmbedding]:
#define COMSIG_ITEM_DISABLE_EMBED "item_disable_embed"
///from [/obj/effect/mine/proc/triggermine]:
#define COMSIG_MINE_TRIGGERED "minegoboom"
///from [/obj/item/organ/internal/remove]:
#define COMSIG_ORGAN_REMOVED "organ_removed"

/// Defib-specific signals

/// Called when a defibrillator is first applied to someone. (mob/living/user, mob/living/target, harmful)
#define COMSIG_DEFIB_PADDLES_APPLIED "defib_paddles_applied"
	/// Defib is out of power.
	#define COMPONENT_BLOCK_DEFIB_DEAD (1<<0)
	/// Something else: we won't have a custom message for this and should let the defib handle it.
	#define COMPONENT_BLOCK_DEFIB_MISC (1<<1)
/// Called when a defib has been successfully used, and a shock has been applied. (mob/living/user, mob/living/target, harmful, successful)
#define COMSIG_DEFIB_SHOCK_APPLIED "defib_zap"
/// Called when a defib's cooldown has run its course and it is once again ready. ()
#define COMSIG_DEFIB_READY "defib_ready"

// /obj/item signals for economy
///called when an item is sold by the exports subsystem
#define COMSIG_ITEM_SOLD "item_sold"
///called when a wrapped up structure is opened by hand
#define COMSIG_STRUCTURE_UNWRAPPED "structure_unwrapped"
#define COMSIG_ITEM_UNWRAPPED "item_unwrapped"
///called when a wrapped up item is opened by hand
	#define COMSIG_ITEM_SPLIT_VALUE  (1<<0)
///called when getting the item's exact ratio for cargo's profit.
#define COMSIG_ITEM_SPLIT_PROFIT "item_split_profits"
///called when getting the item's exact ratio for cargo's profit, without selling the item.
#define COMSIG_ITEM_SPLIT_PROFIT_DRY "item_split_profits_dry"

// /obj/item/clothing signals

///from [/mob/living/carbon/human/Move]: ()
#define COMSIG_SHOES_STEP_ACTION "shoes_step_action"
///from base of /obj/item/clothing/suit/space/proc/toggle_spacesuit(): (obj/item/clothing/suit/space/suit)
#define COMSIG_SUIT_SPACE_TOGGLE "suit_space_toggle"

// /obj/item/implant signals
///from base of /obj/item/implant/proc/activate(): ()
#define COMSIG_IMPLANT_ACTIVATED "implant_activated"
///from base of /obj/item/implant/proc/implant(): (list/args)
#define COMSIG_IMPLANT_IMPLANTING "implant_implanting"
	#define COMPONENT_STOP_IMPLANTING (1<<0)
///called on already installed implants when a new one is being added in /obj/item/implant/proc/implant(): (list/args, obj/item/implant/new_implant)
#define COMSIG_IMPLANT_OTHER "implant_other"
	//#define COMPONENT_STOP_IMPLANTING (1<<0) //The name makes sense for both
	#define COMPONENT_DELETE_NEW_IMPLANT (1<<1)
	#define COMPONENT_DELETE_OLD_IMPLANT (1<<2)
///called on implants being implanted into someone with an uplink implant: (datum/component/uplink)
#define COMSIG_IMPLANT_EXISTING_UPLINK "implant_uplink_exists"
	//This uses all return values of COMSIG_IMPLANT_OTHER

// /obj/item/pda signals

///called on pda when the user changes the ringtone: (mob/living/user, new_ringtone)
#define COMSIG_PDA_CHANGE_RINGTONE "pda_change_ringtone"
	#define COMPONENT_STOP_RINGTONE_CHANGE (1<<0)
#define COMSIG_PDA_CHECK_DETONATE "pda_check_detonate"
	#define COMPONENT_PDA_NO_DETONATE (1<<0)

// /obj/item/radio signals

///called from base of /obj/item/radio/proc/set_frequency(): (list/args)
#define COMSIG_RADIO_NEW_FREQUENCY "radio_new_frequency"

// /obj/item/pen signals

///called after rotation in /obj/item/pen/attack_self(): (rotation, mob/living/carbon/user)
#define COMSIG_PEN_ROTATED "pen_rotated"

// /obj/item/gun signals

///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_MOB_FIRED_GUN "mob_fired_gun"

///called in /obj/item/gun/process_fire (user, target)
#define COMSIG_GUN_FIRED "gun_fired"

// /obj/item/grenade signals

///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_PRIME "grenade_prime"
///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_ARMED "grenade_armed"

// /obj/projectile signals (sent to the firer)

///from base of /obj/projectile/proc/on_hit(): (atom/movable/firer, atom/target, Angle)
#define COMSIG_PROJECTILE_SELF_ON_HIT "projectile_self_on_hit"
///from base of /obj/projectile/proc/on_hit(): (atom/movable/firer, atom/target, Angle)
#define COMSIG_PROJECTILE_ON_HIT "projectile_on_hit"
///from base of /obj/projectile/proc/fire(): (obj/projectile, atom/original_target)
#define COMSIG_PROJECTILE_BEFORE_FIRE "projectile_before_fire"
///from the base of /obj/projectile/proc/fire(): ()
#define COMSIG_PROJECTILE_FIRE "projectile_fire"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_PREHIT "com_proj_prehit"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_RANGE_OUT "projectile_range_out"
///sent when trying to force an embed (mainly for projectiles, only used in the embed element)
#define COMSIG_EMBED_TRY_FORCE "item_try_embed"

///sent to targets during the process_hit proc of projectiles
#define COMSIG_PELLET_CLOUD_INIT "pellet_cloud_init"

// /obj/mecha signals

///sent from mecha action buttons to the mecha they're linked to
#define COMSIG_MECHA_ACTION_ACTIVATE "mecha_action_activate"

// /mob/living/carbon/human signals

///from mob/living/carbon/human/UnarmedAttack(): (atom/target, proximity)
#define COMSIG_HUMAN_EARLY_UNARMED_ATTACK "human_early_unarmed_attack"
///from mob/living/carbon/human/UnarmedAttack(): (atom/target, proximity)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK "human_melee_unarmed_attack"
///from mob/living/carbon/human/UnarmedAttack(): (mob/living/carbon/human/attacker)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACKBY "human_melee_unarmed_attackby"
///Hit by successful disarm attack (mob/living/carbon/human/attacker,zone_targeted)
#define COMSIG_HUMAN_DISARM_HIT	"human_disarm_hit"
///Whenever EquipRanked is called, called after job is set
#define COMSIG_JOB_RECEIVED "job_received"
// called after DNA is updated
#define COMSIG_HUMAN_UPDATE_DNA "human_update_dna"
/// From mob/living/carbon/human/change_body_accessory(): (mob/living/carbon/human/H, body_accessory_style)
#define COMSIG_HUMAN_CHANGE_BODY_ACCESSORY "human_change_body_accessory"
	#define COMSIG_HUMAN_NO_CHANGE_APPEARANCE (1<<0)
/// From mob/living/carbon/human/change_head_accessory(): (mob/living/carbon/human/H, head_accessory_style)
#define COMSIG_HUMAN_CHANGE_HEAD_ACCESSORY "human_change_head_accessory"
///From mob/living/carbon/human/do_suicide()
#define COMSIG_HUMAN_SUICIDE_ACT "human_suicide_act"
///From mob/living/carbon/human/regenerate_icons()
#define COMSIG_HUMAN_REGENERATE_ICONS "human_regenerate_icons"
///From /mob/living/carbon/human/proc/set_species(): (datum/species/old_species)
#define COMSIG_HUMAN_SPECIES_CHANGED "human_species_changed"


///from /mob/living/carbon/human/proc/check_shields(): (atom/hit_by, damage, attack_text, attack_type, armour_penetration, damage_type)
#define COMSIG_HUMAN_CHECK_SHIELDS "human_check_shields"
	#define SHIELD_BLOCK (1<<0)

// /datum/species signals
///from datum/species/on_species_gain(): (datum/species/new_species, datum/species/old_species)
#define COMSIG_SPECIES_GAIN "species_gain"
///from datum/species/on_species_loss(): (datum/species/lost_species)
#define COMSIG_SPECIES_LOSS "species_loss"

// /datum/song signals

///sent to the instrument when a song starts playing
#define COMSIG_SONG_START 	"song_start"
///sent to the instrument when a song stops playing
#define COMSIG_SONG_END		"song_end"

/*******Component Specific Signals*******/
//Janitor

///(): Returns bitflags of wet values.
#define COMSIG_TURF_IS_WET "check_turf_wet"
///(max_strength, immediate, duration_decrease = INFINITY): Returns bool.
#define COMSIG_TURF_MAKE_DRY "make_turf_try"
///called on an object to clean it of cleanables. Usualy with soap: (num/strength)
#define COMSIG_COMPONENT_CLEAN_ACT "clean_act"

//Creamed

///called when you wash your face at a sink: (num/strength)
#define COMSIG_COMPONENT_CLEAN_FACE_ACT "clean_face_act"

//Food

///from base of obj/item/reagent_containers/food/snacks/attack(): (mob/living/eater, mob/feeder)
#define COMSIG_FOOD_EATEN "food_eaten"

//Gibs

///from base of /obj/effect/decal/cleanable/blood/gibs/streak(): (list/directions, list/diseases)
#define COMSIG_GIBS_STREAK "gibs_streak"

//Mood

///called when you send a mood event from anywhere in the code.
#define COMSIG_ADD_MOOD_EVENT "add_mood"
///Mood event that only RnD members listen for
#define COMSIG_ADD_MOOD_EVENT_RND "RND_add_mood"
///called when you clear a mood event from anywhere in the code.
#define COMSIG_CLEAR_MOOD_EVENT "clear_mood"

//NTnet

///called on an object by its NTNET connection component on receive. (sending_id(number), sending_netname(text), data(datum/netdata))
#define COMSIG_COMPONENT_NTNET_RECEIVE "ntnet_receive"

//Nanites

///() returns TRUE if nanites are found
#define COMSIG_HAS_NANITES "has_nanites"
///() returns TRUE if nanites have stealth
#define COMSIG_NANITE_IS_STEALTHY "nanite_is_stealthy"
///() deletes the nanite component
#define COMSIG_NANITE_DELETE "nanite_delete"
///(list/nanite_programs) - makes the input list a copy the nanites' program list
#define COMSIG_NANITE_GET_PROGRAMS	"nanite_get_programs"
///(amount) Returns nanite amount
#define COMSIG_NANITE_GET_VOLUME "nanite_get_volume"
///(amount) Sets current nanite volume to the given amount
#define COMSIG_NANITE_SET_VOLUME "nanite_set_volume"
///(amount) Adjusts nanite volume by the given amount
#define COMSIG_NANITE_ADJUST_VOLUME "nanite_adjust"
///(amount) Sets maximum nanite volume to the given amount
#define COMSIG_NANITE_SET_MAX_VOLUME "nanite_set_max_volume"
///(amount(0-100)) Sets cloud ID to the given amount
#define COMSIG_NANITE_SET_CLOUD "nanite_set_cloud"
///(method) Modify cloud sync status. Method can be toggle, enable or disable
#define COMSIG_NANITE_SET_CLOUD_SYNC "nanite_set_cloud_sync"
///(amount) Sets safety threshold to the given amount
#define COMSIG_NANITE_SET_SAFETY "nanite_set_safety"
///(amount) Sets regeneration rate to the given amount
#define COMSIG_NANITE_SET_REGEN "nanite_set_regen"
///(code(1-9999)) Called when sending a nanite signal to a mob.
#define COMSIG_NANITE_SIGNAL "nanite_signal"
///(comm_code(1-9999), comm_message) Called when sending a nanite comm signal to a mob.
#define COMSIG_NANITE_COMM_SIGNAL "nanite_comm_signal"
///(mob/user, full_scan) - sends to chat a scan of the nanites to the user, returns TRUE if nanites are detected
#define COMSIG_NANITE_SCAN "nanite_scan"
///(list/data, scan_level) - adds nanite data to the given data list - made for ui_data procs
#define COMSIG_NANITE_UI_DATA "nanite_ui_data"
///(datum/nanite_program/new_program, datum/nanite_program/source_program) Called when adding a program to a nanite component
#define COMSIG_NANITE_ADD_PROGRAM "nanite_add_program"
	///Installation successful
	#define COMPONENT_PROGRAM_INSTALLED		(1<<0)
	///Installation failed, but there are still nanites
	#define COMPONENT_PROGRAM_NOT_INSTALLED	(1<<1)
///(datum/component/nanites, full_overwrite, copy_activation) Called to sync the target's nanites to a given nanite component
#define COMSIG_NANITE_SYNC "nanite_sync"

// /datum/component/storage signals

///() - returns bool.
#define COMSIG_CONTAINS_STORAGE "is_storage"
///(obj/item/inserting, mob/user, silent, force) - returns bool
#define COMSIG_TRY_STORAGE_INSERT "storage_try_insert"
///(mob/show_to, force) - returns bool.
#define COMSIG_TRY_STORAGE_SHOW "storage_show_to"
///(mob/hide_from) - returns bool
#define COMSIG_TRY_STORAGE_HIDE_FROM "storage_hide_from"
///returns bool
#define COMSIG_TRY_STORAGE_HIDE_ALL "storage_hide_all"
///(newstate)
#define COMSIG_TRY_STORAGE_SET_LOCKSTATE "storage_lock_set_state"
///() - returns bool. MUST CHECK IF STORAGE IS THERE FIRST!
#define COMSIG_IS_STORAGE_LOCKED "storage_get_lockstate"
///(type, atom/destination, amount = INFINITY, check_adjacent, force, mob/user, list/inserted) - returns bool - type can be a list of types.
#define COMSIG_TRY_STORAGE_TAKE_TYPE "storage_take_type"
///(type, amount = INFINITY, force = FALSE). Force will ignore max_items, and amount is normally clamped to max_items.
#define COMSIG_TRY_STORAGE_FILL_TYPE "storage_fill_type"
///(obj, new_loc, force = FALSE) - returns bool
#define COMSIG_TRY_STORAGE_TAKE "storage_take_obj"
///(loc) - returns bool - if loc is null it will dump at parent location.
#define COMSIG_TRY_STORAGE_QUICK_EMPTY "storage_quick_empty"
///(list/list_to_inject_results_into, recursively_search_inside_storages = TRUE)
#define COMSIG_TRY_STORAGE_RETURN_INVENTORY "storage_return_inventory"
///(obj/item/insertion_candidate, mob/user, silent) - returns bool
#define COMSIG_TRY_STORAGE_CAN_INSERT "storage_can_equip"

// /datum/component/two_handed signals

///from base of datum/component/two_handed/proc/wield(mob/living/carbon/user): (/mob/user)
#define COMSIG_TWOHANDED_WIELD "twohanded_wield"
	#define COMPONENT_TWOHANDED_BLOCK_WIELD (1<<0)
///from base of datum/component/two_handed/proc/unwield(mob/living/carbon/user): (/mob/user)
#define COMSIG_TWOHANDED_UNWIELD "twohanded_unwield"

// /datum/action signals

///from base of datum/action/proc/Trigger(): (datum/action)
#define COMSIG_ACTION_TRIGGER "action_trigger"
	#define COMPONENT_ACTION_BLOCK_TRIGGER (1<<0)

//Xenobio hotkeys

///from slime CtrlClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_CTRL "xeno_slime_click_ctrl"
///from slime AltClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_ALT "xeno_slime_click_alt"
///from slime ShiftClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_SHIFT "xeno_slime_click_shift"
///from turf ShiftClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_SHIFT "xeno_turf_click_shift"
///from turf AltClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_CTRL "xeno_turf_click_alt"
///from monkey CtrlClickOn(): (/mob)
#define COMSIG_XENO_MONKEY_CLICK_CTRL "xeno_monkey_click_ctrl"

///SSalarm signals
#define COMSIG_TRIGGERED_ALARM "ssalarm_triggered"
#define COMSIG_CANCELLED_ALARM "ssalarm_cancelled"

// /datum/objective signals
///from datum/objective/proc/find_target()
#define COMSIG_OBJECTIVE_TARGET_FOUND "objective_target_found"
///from datum/objective/is_invalid_target()
#define COMSIG_OBJECTIVE_CHECK_VALID_TARGET "objective_check_valid_target"
	#define OBJECTIVE_VALID_TARGET		(1<<0)
	#define OBJECTIVE_INVALID_TARGET	(1<<1)

// /datum/component/bluespace_rift_scanner signals
/// from scanner's `process()` : (seconds, emagged)
#define COMSIG_SCANNING_RIFTS "scanning_rifts"
	/// No rifts within the scanner's range
	#define COMPONENT_SCANNED_NOTHING (1<<0)
	/// There are some rifts within the scanner's range
	#define COMPONENT_SCANNED_NORMAL (1<<1)
	/// The scanner is within critical range of a rift
	#define COMPONENT_SCANNED_CRITICAL (1<<2)
	/// There are no servers available
	#define COMPONENT_SCANNED_NO_SERVERS (1<<3)

// /datum/component/overlay_lighting signals, (for-future-backporting)
///from base of atom/CheckParts(): (atom/movable/new_craft) - The atom has just been used in a crafting recipe and has been moved inside new_craft.
#define COMSIG_ATOM_USED_IN_CRAFT "atom_used_in_craft"

// Lighting:
///from base of [atom/proc/set_light]: (l_range, l_power, l_color, l_on)
#define COMSIG_ATOM_SET_LIGHT "atom_set_light"
	/// Blocks [/atom/proc/set_light], [/atom/proc/set_light_power], [/atom/proc/set_light_range], [/atom/proc/set_light_color], [/atom/proc/set_light_on], and [/atom/proc/set_light_flags].
	#define COMPONENT_BLOCK_LIGHT_UPDATE (1<<0)
///Called right before the atom changes the value of light_power to a different one, from base [atom/proc/set_light_power]: (new_power)
#define COMSIG_ATOM_SET_LIGHT_POWER "atom_set_light_power"
///Called right after the atom changes the value of light_power to a different one, from base of [/atom/proc/set_light_power]: (old_power)
#define COMSIG_ATOM_UPDATE_LIGHT_POWER "atom_update_light_power"
///Called right before the atom changes the value of light_range to a different one, from base [atom/proc/set_light_range]: (new_range)
#define COMSIG_ATOM_SET_LIGHT_RANGE "atom_set_light_range"
///Called right after the atom changes the value of light_range to a different one, from base of [/atom/proc/set_light_range]: (old_range)
#define COMSIG_ATOM_UPDATE_LIGHT_RANGE "atom_update_light_range"
///Called right before the atom changes the value of light_color to a different one, from base [atom/proc/set_light_color]: (new_color)
#define COMSIG_ATOM_SET_LIGHT_COLOR "atom_set_light_color"
///Called right after the atom changes the value of light_color to a different one, from base of [/atom/proc/set_light_color]: (old_color)
#define COMSIG_ATOM_UPDATE_LIGHT_COLOR "atom_update_light_color"
///Called right before the atom changes the value of light_on to a different one, from base [atom/proc/set_light_on]: (new_value)
#define COMSIG_ATOM_SET_LIGHT_ON "atom_set_light_on"
///Called right after the atom changes the value of light_on to a different one, from base of [/atom/proc/set_light_on]: (old_value)
#define COMSIG_ATOM_UPDATE_LIGHT_ON "atom_update_light_on"
///Called right before the atom changes the value of light_flags to a different one, from base [atom/proc/set_light_flags]: (new_flags)
#define COMSIG_ATOM_SET_LIGHT_FLAGS "atom_set_light_flags"
///Called right after the atom changes the value of light_flags to a different one, from base of [/atom/proc/set_light_flags]: (old_flags)
#define COMSIG_ATOM_UPDATE_LIGHT_FLAGS "atom_update_light_flags"

// /datum/element/light_eater
///from base of [/datum/element/light_eater/proc/table_buffet]: (list/light_queue, datum/light_eater)
#define COMSIG_LIGHT_EATER_QUEUE "light_eater_queue"
///from base of [/datum/element/light_eater/proc/devour]: (datum/light_eater)
#define COMSIG_LIGHT_EATER_ACT "light_eater_act"
	///Prevents the default light eater behavior from running in case of immunity or custom behavior
	#define COMPONENT_BLOCK_LIGHT_EATER (1<<0)
///from base of [/datum/element/light_eater/proc/devour]: (atom/eaten_light)
#define COMSIG_LIGHT_EATER_DEVOUR "light_eater_devour"


// /datum/element/movetype_handler signals
/// Called when the floating anim has to be temporarily stopped and restarted later: (timer)
#define COMSIG_PAUSE_FLOATING_ANIM "pause_floating_anim"
/// From base of datum/element/movetype_handler/on_movement_type_trait_gain: (flag, old_movement_type)
#define COMSIG_MOVETYPE_FLAG_ENABLED "movetype_flag_enabled"
/// From base of datum/element/movetype_handler/on_movement_type_trait_loss: (flag, old_movement_type)
#define COMSIG_MOVETYPE_FLAG_DISABLED "movetype_flag_disabled"

///called when a plant with slippery skin is slipped on (mob/victim)
#define COMSIG_PLANT_ON_SLIP "plant_on_slip"

/// Sent from /proc/do_after if someone starts a do_after action bar.
#define COMSIG_DO_AFTER_BEGAN "mob_do_after_began"
/// Sent from /proc/do_after once a do_after action completes, whether via the bar filling or via interruption.
#define COMSIG_DO_AFTER_ENDED "mob_do_after_ended"


// HUD:
/// Sent from /datum/hud/proc/eye_z_changed() : (old_offset, new_offset)
#define COMSIG_HUD_OFFSET_CHANGED "hud_offset_changed"


///from [/datum/move_loop/start_loop] ():
#define COMSIG_MOVELOOP_START "moveloop_start"
///from [/datum/move_loop/stop_loop] ():
#define COMSIG_MOVELOOP_STOP "moveloop_stop"
///from [/datum/move_loop/process] ():
#define COMSIG_MOVELOOP_PREPROCESS_CHECK "moveloop_preprocess_check"
	#define MOVELOOP_SKIP_STEP (1<<0)
///from [/datum/move_loop/process] (succeeded, visual_delay):
#define COMSIG_MOVELOOP_POSTPROCESS "moveloop_postprocess"
//from [/datum/move_loop/has_target/jps/recalculate_path] ():
#define COMSIG_MOVELOOP_JPS_REPATH "moveloop_jps_repath"
///from [/datum/move_loop/has_target/jps/on_finish_pathing]
#define COMSIG_MOVELOOP_JPS_FINISHED_PATHING "moveloop_jps_finished_pathing"

///from of mob/MouseDrop(): (/atom/over, /mob/user)
#define COMSIG_DO_MOB_STRIP "do_mob_strip"

// /datum/component/transforming signals
/// From /datum/component/transforming/proc/on_attack_self(obj/item/source, mob/user): (obj/item/source, mob/user, active)
#define COMSIG_TRANSFORMING_PRE_TRANSFORM "transforming_pre_transform"
	/// Return COMPONENT_BLOCK_TRANSFORM to prevent the item from transforming.
	#define COMPONENT_BLOCK_TRANSFORM (1<<0)
/// From /datum/component/transforming/proc/do_transform(obj/item/source, mob/user): (obj/item/source, mob/user, active)
#define COMSIG_TRANSFORMING_ON_TRANSFORM "transforming_on_transform"
	/// Return COMPONENT_NO_DEFAULT_MESSAGE to prevent the transforming component from displaying the default transform message / sound.
	#define COMPONENT_NO_DEFAULT_MESSAGE (1<<0)


///From base of datum/controller/subsystem/Initialize
#define COMSIG_SUBSYSTEM_POST_INITIALIZE "subsystem_post_initialize"

