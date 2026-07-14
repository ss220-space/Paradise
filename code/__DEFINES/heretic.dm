// Heretic antagonist defines.
// Ported from /tg/station (via Paradise-selfharm) onto Paradise master220.

// Heretic path defines.
#define PATH_START "Стартовый Путь"
#define PATH_SIDE "Вторичный Путь"
#define PATH_ASH "Путь Пепла"
#define PATH_RUST "Путь Ржавчины"
#define PATH_FLESH "Путь Плоти"
#define PATH_VOID "Путь Пустоты"
#define PATH_BLADE "Путь Клинка"
#define PATH_COSMIC "Путь Космоса"
#define PATH_LOCK "Путь Замка́"
#define PATH_MOON "Путь Луны"

// Heretic knowledge tree defines (keys used in the knowledge tree assoc lists).
#define HKT_NEXT "next"
#define HKT_BAN "ban"
#define HKT_DEPTH "depth"
#define HKT_ROUTE "route"
#define HKT_UI_BGR "ui_bgr"
/// Shop tier ("Тир N") a side knowledge sits in (and what tier-knowledge unlocks it). Set on the metadata.
#define HKT_DRAFT_TIER "draft_tier"
/// The knowledge-tree node that, once researched, unlocks this side/draft node.
#define HKT_PARENT "parent"
/// Point cost stored on a per-heretic draft/shop metadata entry.
#define HKT_COST "cost"

// TG-style research-tree depths (vertical position of each node row in the UI). Main line interleaves
// with the per-tier DRAFT rows. Used by the Ash (TG-format) path; the legacy paths still use 1..11.
#define HKT_DEPTH_START 2
#define HKT_DEPTH_TIER_1 3
#define HKT_DEPTH_DRAFT_1 4
#define HKT_DEPTH_TIER_2 5
#define HKT_DEPTH_DRAFT_2 6
#define HKT_DEPTH_ROBES 7
#define HKT_DEPTH_TIER_3 8
#define HKT_DEPTH_DRAFT_3 9
#define HKT_DEPTH_ARMOR 10
#define HKT_DEPTH_TIER_4 11
#define HKT_DEPTH_DRAFT_4 12
#define HKT_DEPTH_ASCENSION 13

/// The highest drafting tier a side knowledge can belong to.
#define HERETIC_DRAFT_TIER_MAX 5
/// Default UI background icon_state for a (side) node.
#define BGR_SIDE "node_side"

/// Used in /proc/has_living_heart() to report heart state.
#define HERETIC_NO_HEART_ORGAN -1
#define HERETIC_NO_LIVING_HEART 0
#define HERETIC_HAS_LIVING_HEART 1

/// Ritual priority ceiling for heretic knowledge.
#define MAX_KNOWLEDGE_PRIORITY 100

#define FACTION_HERETIC "heretic"
#define FACTION_HOSTILE "hostile"

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
#define SCHOOL_TRANSMUTATION "transmutation"
#define SCHOOL_FORBIDDEN "forbidden"

/// Returned by a spell's before_cast hook to cancel the cast.
#define SPELL_CANCEL_CAST (1 << 0)
/// Returned by a spell hook to suppress the "can't do that" feedback / immediate cooldown.
#define SPELL_NO_FEEDBACK (1 << 1)
#define SPELL_NO_IMMEDIATE_COOLDOWN (1 << 2)

// (BB_GENERIC_ACTION / BB_TARGETED_ACTION / BB_SHAPESHIFT_ACTION moved to code/__DEFINES/ai.dm
//  together with the rest of the ported basic-mob AI blackboard keys.)

/// Overlay layer used by rust/cleanable decals.
#define ABOVE_CLEANABLES_LAYER 2.0475

// How resistant a turf is to a heretic's rust. A turf only rusts when the heretic's rust_strength is
// >= the turf's rust_resistance (see /turf/rust_heretic_act). Mirrors tgstation 1:1 so weak heretics
// can only rust plating/basic walls, while reinforced/titanium turfs require a stronger heretic.
#define RUST_RESISTANCE_BASIC 1
#define RUST_RESISTANCE_REINFORCED 2
#define RUST_RESISTANCE_TITANIUM 3
#define RUST_RESISTANCE_ORGANIC 4
/// Never rusts by normal means (space, indestructible turfs, ...).
#define RUST_RESISTANCE_ABSOLUTE 5

/// TRUE if a hand index is a left hand (odd indices are left in tg's hand model).
#define IS_LEFT_INDEX(value) (value % 2 != 0)

// Component / signal-handler return flags used by heretic code.
#define LADDER_TRAVEL_BLOCK (1<<0)
#define COMPONENT_CAST_HANDLESS (1<<0)
#define COMPONENT_CANT_Z_MOVE (1<<0)
#define COMPONENT_AFTERATTACK_STOP (1<<1)
#define ACCESS_DISALLOWED (1<<1)

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
