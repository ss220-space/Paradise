/**
 * master220 compatibility shims for the tg-derived heretic code.
 *
 * Small adapter procs that bridge API-name differences between the heretic source
 * (Paradise-selfharm / tg) and master220. Kept in the heretic module so core files stay clean.
 */

// --- Organ damage API ---
// tg/selfharm uses mob.adjustOrganLoss(slot, amount, ...); master220 organs use
// internal_receive_damage(amount, silent) / heal_internal_damage(amount, robo_repair).

/mob/living/proc/adjustOrganLoss(slot, amount, maximum, required_organ_flag)
	return FALSE

/mob/living/carbon/adjustOrganLoss(slot, amount, maximum, required_organ_flag = NONE)
	var/obj/item/organ/affected_organ = get_organ_slot(slot)
	if(!affected_organ || HAS_TRAIT(src, TRAIT_GODMODE))
		return FALSE
	if(required_organ_flag && !(affected_organ.status & required_organ_flag))
		return FALSE
	if(amount >= 0)
		return affected_organ.internal_receive_damage(amount)
	affected_organ.heal_internal_damage(-amount)
	return TRUE

// tg reads current organ damage via mob.get_organ_loss(slot); master220's base /mob/living/get_organ_loss
// (damage_procs.dm) is an empty stub that ALWAYS returns null. Without this carbon override every
// get_organ_loss(INTERNAL_ORGAN_BRAIN) call in the moon path read 0 - which silently broke the moon amulet
// curse, the moon armor's berserk gate, AND the moon ascension (its is_valid_sacrifice rejected every corpse
// because their "brain damage" always read 0). Mirror adjustOrganLoss above: resolve the organ and report
// its real `damage`.
/mob/living/carbon/get_organ_loss(slot, required_organ_flag)
	var/obj/item/organ/affected_organ = get_organ_slot(slot)
	if(!affected_organ)
		return 0
	if(required_organ_flag && !(affected_organ.status & required_organ_flag))
		return 0
	return affected_organ.damage

/// Returns whether the given organ is robotic. tg helper not present in master220.
/proc/isroboticorgan(obj/item/organ/checked_organ)
	return checked_organ?.is_robotic()

/// tg's dismember() on a limb maps to master220's droplimb().
/obj/item/organ/external/proc/dismember()
	return droplimb()

/// tg's set_organ_damage(amount) — master220 organs have a `damage` var + max_damage.
/obj/item/organ/proc/set_organ_damage(amount, required_organ_flag)
	damage = clamp(amount, 0, max_damage)

// --- Misc behaviour shims (master220 lacks these tg procs; no-ops for now, behaviour = runtime polish) ---

/// tg stun-absorption buff (blade path "Furious Steel"). No-op until ported; stun immunity won't apply yet.
/mob/living/proc/add_stun_absorption(source, message, self_message, examine_message, max_seconds_of_stuns_blocked, delete_after_passing_max, recharge_time)
	return TRUE

/// tg "can this mob give up / be finished off" check. master220 approximation: in crit or dead.
/mob/living/proc/CanSuccumb()
	return (stat == UNCONSCIOUS || stat == DEAD)

/// tg freezes an object solid. master220 lacks it; report "not frozen" so callers skip the freeze visual.
/obj/proc/freeze_add()
	return FALSE

// --- Hallucination compat ---
// master220 has no tg-style typed cause_hallucination()/hallucination datums, but it DOES have a working
// hallucination engine: /obj/effect/hallucination/delusion warps the on-screen crew into monsters, and an
// ambient strength-based status (Hallucinate()) sprinkles random ones over time.
//
// The ambient status ALONE is why "галюны не работают": its first hallucination is scheduled at
// rand(20s,50s)/(strength*0.003) - at the low strengths these spells used (e.g. a 10s effect => strength
// 100 => a 66-166s cooldown) the status expires LONG before it ever rolls a hallucination, so none fired.
//
// So cause_hallucination() now fires one delusion IMMEDIATELY (guaranteed and visible) and tops up the
// ambient status for the rest of the duration as flavour. The specific delusion type is ignored (we use
// the generic "everyone looks like a monster" delusion to approximate the moon/gate visuals).
/mob/living/proc/cause_hallucination(hallucination_type, reason, duration = 30 SECONDS, affects_us = TRUE, affects_others = FALSE)
	if(affects_us)
		fire_eldritch_hallucination(src, duration)
	// affects_others (e.g. a moon-converted madman radiating insanity) makes the nearby crew hallucinate too.
	if(affects_others)
		for(var/mob/living/carbon/nearby in view(7, src) - src)
			fire_eldritch_hallucination(nearby, duration)

/// Fires guaranteed hallucinations on a carbon RIGHT NOW and keeps them coming for the duration.
/proc/fire_eldritch_hallucination(mob/living/carbon/who, duration = 30 SECONDS)
	if(!iscarbon(who))
		return
	// 1) GUARANTEED, self-contained hallucinations via hallucinate_living() - the exact 100%-reliable trick
	//    the madness mask uses (sounds/whispers/fake messages/battle visions/self-delusion the victim
	//    experiences directly, so they fire even with nobody else around). Fired ASYNC because
	//    hallucinate_living() can sleep for several seconds (animated hallucinations); this proc runs inside
	//    the mansus-grasp attack chain (a signal handler), and a synchronous sleep there stalled afterattack
	//    so the grasp hand was never removed or put on cooldown (spam-clickable). INVOKE_ASYNC returns at once.
	INVOKE_ASYNC(who, TYPE_PROC_REF(/mob/living, hallucinate_living), pickweight(GLOB.minor_hallutinations + GLOB.medium_hallutinations))
	INVOKE_ASYNC(who, TYPE_PROC_REF(/mob/living, hallucinate_living), pickweight(GLOB.minor_hallutinations + GLOB.medium_hallutinations))
	// 2) Themed "everyone looks like a monster" delusion on top, for when bystanders ARE around (the moon
	//    visual). skip_nearby = FALSE so people right next to the victim transform too. (Does not sleep.)
	new /obj/effect/hallucination/delusion(who.loc, who, null, duration, FALSE)
	// 3) Pin the ambient hallucination status near TG's 120s cap so more keep trickling in afterwards.
	who.Hallucinate(max(duration, 120 SECONDS))

// Stub types so the typepath literals the heretic spells pass as `hallucination_type` still resolve.
/datum/hallucination/delusion/preset/moon
/datum/hallucination/delusion/preset/heretic/gate

// --- More master220 compat shims ---

/// tg AdjustAllImmobility (stun/knockdown/immobilize); master220 closest = AdjustImmobilized.
/mob/living/proc/AdjustAllImmobility(amount, ignore_canstun = FALSE)
	return AdjustImmobilized(amount, ignore_canstun)

/// tg calls this after editing turf air; master220 MILLA propagates automatically. No-op.
/turf/proc/air_update_turf(update = FALSE, update_visuals = FALSE)
	return

/// tg "does this mob need a heart to live"; master220 approximation: carbons do.
/mob/living/carbon/proc/needs_heart()
	return TRUE

/// tg unequip_everything strips a mob; master220 approximation drops held items (worn = runtime polish).
/mob/living/proc/unequip_everything()
	drop_all_held_items()

/// tg's is_centcomm(z); master220 treats centcom as an admin z-level.
/proc/is_centcomm(z)
	return is_admin_level(z)

/// tg timed-examine hook; master220 examine is instant. Base returns 0; heretic influence overrides it
/// for flavor but master220 won't honor the delay (runtime polish).
/atom/proc/get_examine_time()
	return 0

// tg cultblade "free_use" var (lets non-cultists wield without backlash). Behaviour wiring = runtime polish.
/obj/item/melee/cultblade
	var/free_use = FALSE

// --- Projectile helper ---
// tg's /obj/projectile/proc/is_hostile_projectile() isn't present in master220.
// A projectile counts as hostile here if it deals damage.
/obj/projectile/proc/is_hostile_projectile()
	return damage > 0

// --- Rust system base hooks ---
// Base no-op; specific atoms/turfs override rust_heretic_act() to define what rusting does to them.
// /turf rusting is handled by rust_turf.dm.
/atom/proc/rust_heretic_act(strength)
	return

// Structures shatter under rust - tg's /obj/structure/rust_heretic_act (take_damage 500 brute). This is
// the identity that lets Aggressive Spread break adjacent grilles and weaker windows, and lets the
// secondary Mansus Grasp smash structures. Reinforced/strong windows survive the 500, flimsy ones don't.
// (mawed_crucible / eldritch structures keep their own more-specific override, so they're unaffected.)
/obj/structure/rust_heretic_act(strength)
	take_damage(500, BRUTE, MELEE, TRUE)

// Machines crumble harder the stronger the heretic - tg's /obj/machinery/rust_heretic_act
// (500 + rust_strength * 200 brute). A bare call (null strength) is treated as 0 → a flat 500.
/obj/machinery/rust_heretic_act(strength)
	take_damage(500 + strength * 200, BRUTE, BOMB, TRUE)

// Airlocks: vanilla tg (and the /obj/machinery path above) destroys the airlock but leaves a
// /obj/structure/door_assembly frame behind, so corroding a door took two grasps (door -> frame -> gone).
// Per design we want the Rust grasp to crumble the WHOLE door to rust in a single grasp. Setting
// NODECONSTRUCT makes the airlock's deconstruct() skip spawning the assembly (and electronics) and just
// qdel, so one corrode fully removes the door with nothing left to block the way.
/obj/machinery/door/airlock/rust_heretic_act(strength)
	obj_flags |= NODECONSTRUCT
	return ..()

/// Wrapper proc that passes our mob's rust_strength to the target we are rusting.
/mob/proc/do_rust_heretic_act(atom/target)
	var/datum/antagonist/heretic/heretic_data = mind?.has_antag_datum(/datum/antagonist/heretic)
	target.rust_heretic_act(heretic_data?.rust_strength)

// Synthetics crumble to rust instantly (ported from TG: silicon 500 brute, bots 400). This is what makes
// the Rust path's "Mansus Grasp instantly destroys silicons/synthetics" identity actually do something -
// without these the grasp's issilicon() branch called the /atom no-op and nothing happened.
/mob/living/silicon/rust_heretic_act(strength)
	adjustBruteLoss(500)

/mob/living/simple_animal/bot/rust_heretic_act(strength)
	adjustBruteLoss(400)

// Mechs crumble to rust too - tg's /obj/vehicle/sealed/mecha/rust_heretic_act (take_damage 500 brute).
// master220 mechs are /obj/mecha (an /obj, NOT /obj/machinery), so without this they'd hit the /atom
// no-op and shrug off the grasp. This is the "Mansus Grasp instantly wrecks mechs" part of the Rust identity.
/obj/mecha/rust_heretic_act(strength)
	take_damage(500, BRUTE)

// --- Misc compat ---
// tg gates phasing per-z via ZTRAIT_NOPHASE, which master220 doesn't have. Default to allowed.
/proc/is_phase_allowed(z)
	return TRUE

// tg objectives recompute their explanation_text via this hook; master220 sets it directly.
// Base no-op so heretic objective overrides (and calls on plain objectives) resolve.
/datum/objective/proc/update_explanation_text()
	return

// Russian "in the <dir>" helper used by the living-heart compass.
// (dir2rustext already exists in master220's type2type.dm; only this wrapper is missing.)
/proc/dir2rustext_where(direction)
	return "на [dir2rustext(direction)]е"

// --- Jaunt compat ---
// master220 defines its own /obj/effect/dummy/spell_jaunt (ethereal_jaunt.dm) but lacks the tg API
// the heretic jaunt spells (mirror_walk/space_crawl/ash_jaunt) use. Add the missing bits here.
// NOTE: full reconciliation of the two jaunt models is task #8 (runtime); this unblocks compile +
// gives working behaviour for the heretic flow which sets `jaunter` itself.
/obj/effect/dummy/spell_jaunt
	/// The movable currently jaunting inside this dummy (tg API).
	var/atom/movable/jaunter
	/// Icon we draw the jaunter's position indicator from (tg uses the projectiles sheet).
	var/phased_mob_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	/// Icon state for the jaunter's position indicator (set by some heretic jaunt subtypes, e.g. ash = "red_1").
	var/phased_mob_icon_state
	/// The client image shown to the jaunter so they can see where they are (the "red dot").
	var/image/position_indicator

// master220's base do_jaunt forceMoves the jaunter straight into the dummy (no set_jaunter call), so we
// hook Entered to wire up tg's position indicator: an ABOVE_LIGHTING client image the jaunter alone sees,
// telling them where their ashen/phased form is. Only fires for dummies that opted in via phased_mob_icon_state,
// so the vampire jaunts that share this base type are unaffected.
/obj/effect/dummy/spell_jaunt/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!ismob(arrived) || arrived == jaunter)
		return
	// Always track the jaunter: exit_jaunt() validates jaunt.jaunter (CRASHing on mismatch)
	// and eject_jaunter() needs it. Previously this was gated behind phased_mob_icon_state,
	// so mirror_walk (which sets no position indicator) left jaunter null and could never exit.
	jaunter = arrived
	if(!phased_mob_icon_state)
		return
	var/mob/mob_jaunter = arrived
	position_indicator = image(phased_mob_icon, src, phased_mob_icon_state, ABOVE_LIGHTING_PLANE)
	position_indicator.appearance_flags |= RESET_ALPHA
	SET_PLANE_EXPLICIT(position_indicator, ABOVE_LIGHTING_PLANE, src)
	RegisterSignal(mob_jaunter, COMSIG_MOB_LOGIN, PROC_REF(show_client_image), override = TRUE)
	show_client_image(mob_jaunter)

/// Shows our position indicator to the jaunter's client (re-shown on relog).
/obj/effect/dummy/spell_jaunt/proc/show_client_image(mob/show_to)
	SIGNAL_HANDLER
	show_to.client?.images |= position_indicator

/obj/effect/dummy/spell_jaunt/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != jaunter)
		return
	var/mob/mob_jaunter = jaunter
	mob_jaunter.client?.images -= position_indicator
	UnregisterSignal(mob_jaunter, COMSIG_MOB_LOGIN)
	jaunter = null
	position_indicator = null

/// Ejects the jaunter to our turf and deletes the dummy.
/obj/effect/dummy/spell_jaunt/proc/eject_jaunter()
	if(!jaunter)
		return
	var/turf/eject_spot = get_turf(src)
	if(!eject_spot)
		return
	// forceMove fires Exited(), which nulls jaunter, so capture it first for the signal
	// that drives on_jaunt_exited() (exit feedback, mirror_walk's cold air, etc.).
	var/atom/movable/exiting = jaunter
	jaunter.forceMove(eject_spot)
	SEND_SIGNAL(src, COMSIG_MOB_EJECTED_FROM_JAUNT, exiting)
	qdel(src)

/// TRUE if the given mob is currently inside a jaunt dummy.
/proc/is_jaunting(mob/living/possibly_jaunting)
	return istype(possibly_jaunting?.loc, /obj/effect/dummy/spell_jaunt)

// tg item visual-only equip hook; master220 uses equipped(). Base no-op so mutant-hand overrides compile.
// NOTE: master220 won't auto-call this, so mutant-hand visuals are cosmetic-TODO (runtime polish).
/obj/item/proc/visual_equipped(mob/user, slot, initial = FALSE)
	return

// tg helper: which body zones are covered by the mob's clothing. master220 lacks it; return none
// (so noticable organs are always considered visible — slight over-reveal, runtime polish).
/mob/living/carbon/proc/get_covered_body_zones()
	return list()

/// tg's get_held_items() — master220 exposes hands via get_active_hand()/get_inactive_hand().
/mob/living/proc/get_held_items()
	. = list()
	var/obj/item/active = get_active_hand()
	var/obj/item/inactive = get_inactive_hand()
	if(active)
		. += active
	if(inactive)
		. += inactive

/// Returns the furthest unblocked turf from target_atom in `direction`, up to `range`.
/proc/get_freeway_ranged_target_turf(atom/target_atom, direction, range, min_range = 0)
	var/result_loc = get_turf(target_atom)
	for(var/moved_len = 0; moved_len < range; moved_len++)
		var/turf/checking = get_ranged_target_turf(target_atom, direction, moved_len + 1)
		var/blocked = iswallturf(checking)
		var/checked = 0
		for(var/obj/blocker in checking)
			if(checked++ > 20)
				break
			if(!blocker.density)
				continue
			blocked = TRUE
			break
		if(!blocked)
			result_loc = checking
			continue
		if(moved_len < min_range)
			return
		else
			break
	return result_loc

/// tg-style global visibility helper; master220 exposes this as atom/proc/can_see().
/proc/can_see(atom/source, atom/target, range = 5)
	return source?.can_see(target, length = range)

/// tg-style blackboard helpers used by some imported AI support datums.
/datum/ai_controller/proc/set_blackboard_key(key, value)
	blackboard[key] = value
	if(pawn)
		SEND_SIGNAL(pawn, COMSIG_AI_BLACKBOARD_KEY_SET(key))

/datum/ai_controller/proc/clear_blackboard_key(key)
	if(pawn)
		SEND_SIGNAL(pawn, COMSIG_AI_BLACKBOARD_KEY_CLEARED(key))
	blackboard -= key

/datum/ai_controller/proc/blackboard_key_exists(key)
	return !isnull(blackboard[key])

/datum/ai_behavior/proc/set_movement_target(datum/ai_controller/controller, atom/target)
	controller.current_movement_target = target

/proc/isspacecola(datum/reagent/reagent)
	return istype(reagent, /datum/reagent/consumable/drink/cold/space_cola)

/proc/isacid(datum/reagent/reagent)
	return istype(reagent, /datum/reagent/acid)

/datum/status_effect/rust_corruption
	alert_type = null
	id = "rust_turf_effects"
	tick_interval = 2 SECONDS

/datum/status_effect/rust_corruption/tick(seconds_between_ticks)
	if(issilicon(owner))
		owner.adjustBruteLoss(10 * seconds_between_ticks)
		return
	owner.Disgust(5 * seconds_between_ticks)
	owner.reagents?.remove_all(0.75 * seconds_between_ticks)

// --- Painting/wallframe ---
// The canvas/easel/wallframe/painting system now lives in
// code/game/objects/structures/art/paintings.dm (ported from /tg/station, drawing-only scope).
// The eldritch paintings (items/eldritch_painting.dm) subclass those real base types.

// --- HUD compat ---
// The source heretic module has team/antag-filtered alternate appearances. master220 has the
// generic alternate appearance system, so only the visibility predicate is missing here.

/datum/atom_hud/alternate_appearance/basic/heretic
	add_ghost_version = TRUE

/datum/atom_hud/alternate_appearance/basic/heretic/mob_should_see(mob/viewer)
	return IS_HERETIC_OR_MONSTER(viewer) || isobserver(viewer)

/datum/atom_hud/alternate_appearance/basic/has_antagonist
	var/antag_datum_type

/datum/atom_hud/alternate_appearance/basic/has_antagonist/mob_should_see(mob/viewer)
	if(isobserver(viewer))
		return TRUE
	return viewer?.mind?.has_antag_datum(antag_datum_type)

/proc/add_team_hud(mob/living/target, datum/antagonist/antag_type)
	return

// --- Construct/simplemob compat ---

/mob/living/simple_animal/hostile/construct
	var/seeking = FALSE
	var/can_repair = TRUE
	var/mob/living/construct_master

/datum/game_mode
	var/list/heretics = list()

// --- Object/gib compat ---

/obj/proc/unfreeze()
	return FALSE

/obj/effect/decal/cleanable/blood/gibs/torso
	random_icon_states = list("gibtorso")

/obj/effect/gibspawner/human/bodypartless
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs, /obj/effect/decal/cleanable/blood/gibs/core, /obj/effect/decal/cleanable/blood/gibs, /obj/effect/decal/cleanable/blood/gibs/core, /obj/effect/decal/cleanable/blood/gibs, /obj/effect/decal/cleanable/blood/gibs/torso)
	gibamounts = list(1, 1, 1, 1, 1, 1)

/obj/effect/gibspawner/human/bodypartless/Initialize(mapload, datum/dna/mob_dna)
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST), list(SOUTH, SOUTHEAST, SOUTHWEST), list(WEST, NORTHWEST, SOUTHWEST), list(EAST, NORTHEAST, SOUTHEAST), GLOB.alldirs, list())
	return ..()

// --- Misc proc/type compat ---

/proc/bicon(atom/thing)
	return icon2html(thing, usr)

/mob/living/carbon/proc/mob_light2()
	return

/obj/effect/proc_holder/spell/watchers_look/heretic
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"

// --- Helgrasp reagent compat ---

/datum/reagent/inverse
	name = "Inverse reagent"
	id = "inverse"
	description = "An inverted reagent effect."

/datum/reagent/inverse/helgrasp
	name = "Helgrasp"
	id = "helgrasp"
	description = "A forbidden drink that calls grasping hands from beyond."
	reagent_state = LIQUID
	color = "#5d0f75"
	taste_description = "ice and old dust"
	metabolization_rate = 1 * REM
	var/list/timer_ids

/datum/reagent/inverse/helgrasp/on_mob_add(mob/living/carbon/human/user)
	. = ..()
	to_chat(user, span_hierophant("Вы слышите смех, когда перед вами появляются жуткие руки, жаждущие утащить вас в ад!.. Берегитесь!"))
	playsound(user.loc, 'sound/effects/ahaha.ogg', 80, TRUE, -1)

/datum/reagent/inverse/helgrasp/on_mob_life(mob/living/M)
	. = ..()
	if(!iscarbon(M))
		return
	var/mob/living/carbon/affected_mob = M
	spawn_hands(affected_mob)
	LAZYADD(timer_ids, addtimer(CALLBACK(src, PROC_REF(spawn_hands), affected_mob), 1 SECONDS, TIMER_STOPPABLE))

/datum/reagent/inverse/helgrasp/proc/spawn_hands(mob/living/carbon/affected_mob)
	if(!affected_mob && iscarbon(holder?.my_atom))
		affected_mob = holder.my_atom
	if(!affected_mob)
		return
	fire_curse_hand(affected_mob)

/datum/reagent/inverse/helgrasp/on_mob_delete(mob/living/carbon/human/user)
	. = ..()
	for(var/timer_id in timer_ids)
		deltimer(timer_id)
	timer_ids?.Cut()

/datum/reagent/inverse/helgrasp/heretic
	name = "Прикосновение Мансуса"
	id = "mansus_touch"
	description = "Чья-то рука у вашего горла..."


// --- Corrected projectile pacing for slow heretic projectiles ---
//
// master220's /obj/projectile/process() only refreshes `last_projectile_move` inside pixel_move(),
// i.e. ONLY on ticks where a full tile-move actually happens. For SLOW projectiles (speed > 1)
// most ticks make zero moves, so next tick the (world.time - last_projectile_move) delta re-counts
// time that was ALREADY folded into `time_offset` -> the projectile drifts noticeably faster, and
// in irregular bursts, than its `speed` implies. (This is why simply bumping `speed` never made the
// parade/curse hands move calmly - past a point the double-count cancels the increase and it just
// stutters.) /tg/ avoids this by refreshing last_projectile_move EVERY process tick (process_movement)
// and carrying only the sub-step remainder.
//
// We mirror /tg/'s accounting here, but ONLY for the heretic projectiles that opt in (below), so the
// rest of the game's speed>1 projectiles keep the exact pacing they were balanced against. With this,
// `speed` means what it should: tiles/sec = 10 / speed (e.g. speed 5 = 2 tiles/sec, matching /tg/'s
// parade; speed 2 = 5 tiles/sec, matching /tg/'s curse hand).
/obj/projectile/proc/process_paced()
	if(!loc || !trajectory)
		return PROCESS_KILL
	if(paused || !isturf(loc))
		last_projectile_move = world.time
		return
	var/elapsed_time_deciseconds = (world.time - last_projectile_move) + time_offset
	last_projectile_move = world.time // THE FIX: refresh every tick so elapsed isn't re-counted
	time_offset = 0
	// These heretic projectiles are never hitscan, so we skip the stock proc's MOVES_HITSCAN branch
	// (that define is file-local to projectile.dm anyway).
	var/required_moves = floor(elapsed_time_deciseconds / speed)
	if(required_moves > SSprojectiles.global_max_tick_moves)
		var/overrun = required_moves - SSprojectiles.global_max_tick_moves
		required_moves = SSprojectiles.global_max_tick_moves
		time_offset += overrun * speed
	time_offset += MODULUS(elapsed_time_deciseconds, speed)

	for(var/i in 1 to required_moves)
		pixel_move(1)
