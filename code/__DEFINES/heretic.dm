// Heretic antagonist defines.
// Ported from /tg/station (via Paradise-selfharm) onto Paradise master220.

// Heretic path defines.
#define PATH_START "Start Path"
#define PATH_SIDE "Side Path"
#define PATH_ASH "Ash Path"
#define PATH_RUST "Rust Path"
#define PATH_FLESH "Flesh Path"
#define PATH_VOID "Void Path"
#define PATH_BLADE "Blade Path"
#define PATH_COSMIC "Cosmic Path"
#define PATH_LOCK "Lock Path"
#define PATH_MOON "Moon Path"

// Heretic knowledge tree defines (keys used in the knowledge tree assoc lists).
#define HKT_NEXT "next"
#define HKT_BAN "ban"
#define HKT_DEPTH "depth"
#define HKT_ROUTE "route"
#define HKT_UI_BGR "ui_bgr"

/// Used in /proc/has_living_heart() to report heart state.
#define HERETIC_NO_HEART_ORGAN -1
#define HERETIC_NO_LIVING_HEART 0
#define HERETIC_HAS_LIVING_HEART 1

/// Ritual priority ceiling for heretic knowledge.
#define MAX_KNOWLEDGE_PRIORITY 100

#define FACTION_HERETIC "heretic"

/// Checks if the passed mob can become a heretic ghoul.
/// Must be a human (type, not species); skeletons and monkeys are excluded.
#define IS_VALID_GHOUL_MOB(mob) (ishuman(mob) && !isskeleton(mob) && !ismonkey(mob))

/// JSON string file for all of our heretic influence flavors.
#define HERETIC_INFLUENCE_FILE "heretic_influences.json"

/// TRUE if the given mob is in the Mansus (the heretic sacrifice arena z-level).
#define IS_IN_MANSUS(mob) (istype(get_area(mob), /area/centcom/heretic_sacrifice))

// --- Spell-system compatibility defines ---
// master220's /obj/effect/proc_holder/spell uses clothes_req / human_req / invocation_type
// natively. The tg-derived heretic spells additionally use a `spell_requirements` bitfield
// and `antimagic_flags`, so we provide those flag defines here (master220 has no magic.dm).

#define INVOCATION_NONE "none"
#define INVOCATION_SHOUT "shout"
#define INVOCATION_WHISPER "whisper"
#define INVOCATION_EMOTE "emote"

#define SPELL_REQUIRES_WIZARD_GARB (1 << 0)
/// SPELL_REQUIRES_WIZARD_GARB implies this, as carbons and below can't wear clothes.
#define SPELL_REQUIRES_HUMAN (1 << 1)
#define SPELL_CASTABLE_AS_BRAIN (1 << 2)
#define SPELL_REQUIRES_NO_ANTIMAGIC (1 << 4)
#define SPELL_REQUIRES_STATION (1 << 5)
#define SPELL_REQUIRES_MIND (1 << 6)
#define SPELL_REQUIRES_MIME_VOW (1 << 7)
#define SPELL_CASTABLE_WITHOUT_INVOCATION (1 << 8)

#define MAGIC_RESISTANCE (1 << 0)
#define MAGIC_RESISTANCE_MIND (1 << 1)
#define MAGIC_RESISTANCE_HOLY (1 << 2)

/// Spell "school" flavor tags (tg-derived). Stored in the spell's `school` var.
#define SCHOOL_UNSET "unset"
#define SCHOOL_HOLY "holy"
#define SCHOOL_PSYCHIC "psychic"
#define SCHOOL_MIME "mime"
#define SCHOOL_RESTORATION "restoration"
#define SCHOOL_EVOCATION "evocation"
#define SCHOOL_TRANSMUTATION "transmutation"
#define SCHOOL_TRANSLOCATION "translocation"
#define SCHOOL_CONJURATION "conjuration"
#define SCHOOL_NECROMANCY "necromancy"
#define SCHOOL_FORBIDDEN "forbidden"
#define SCHOOL_SANGUINE "sanguine"

/// Returned by a spell's before_cast hook to cancel the cast.
#define SPELL_CANCEL_CAST (1 << 0)
/// Returned by a spell hook to suppress the "can't do that" feedback / immediate cooldown.
#define SPELL_NO_FEEDBACK (1 << 1)
#define SPELL_NO_IMMEDIATE_COOLDOWN (1 << 2)

/// Blackboard keys used by some heretic monster AI (tg basic-mob AI; behaviour pending task #7).
#define BB_GENERIC_ACTION "BB_generic_action"
#define BB_TARGETED_ACTION "BB_TARGETED_action"
#define BB_SHAPESHIFT_ACTION "BB_shapeshift_action"

/// Overlay layer used by rust/cleanable decals.
#define ABOVE_CLEANABLES_LAYER 2.0475

/// TRUE if a hand index is a left hand (odd indices are left in tg's hand model).
#define IS_LEFT_INDEX(value) (value % 2 != 0)

/// Attack classification flags passed by the relay_attackers element via COMSIG_ATOM_WAS_ATTACKED.
#define ATTACKER_STAMINA_ATTACK (1 << 0)
#define ATTACKER_SHOVING (1 << 1)
#define ATTACKER_DAMAGING_ATTACK (1 << 2)

// Brain-trauma subsystem (ported for the heretic; master220 has no brain_trauma system).
// Resilience tiers — how hard a trauma is to cure.
#define TRAUMA_RESILIENCE_BASIC 1     // Curable with chems
#define TRAUMA_RESILIENCE_SURGERY 2   // Curable with brain surgery
#define TRAUMA_RESILIENCE_LOBOTOMY 3  // Curable with lobotomy
#define TRAUMA_RESILIENCE_WOUND 4     // Curable by healing the head wound
#define TRAUMA_RESILIENCE_MAGIC 5     // Curable only with magic
#define TRAUMA_RESILIENCE_ABSOLUTE 6  // Here to stay
// Per-resilience caps on how many traumas of that tier can be naturally gained.
#define TRAUMA_LIMIT_BASIC 3
#define TRAUMA_LIMIT_SURGERY 2
#define TRAUMA_LIMIT_WOUND 2
#define TRAUMA_LIMIT_LOBOTOMY 3
#define TRAUMA_LIMIT_MAGIC 3
#define TRAUMA_LIMIT_ABSOLUTE INFINITY
