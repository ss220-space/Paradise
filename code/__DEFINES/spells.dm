// Spell target defines
#define SPELL_TARGET_CLOSEST 1
#define SPELL_TARGET_RANDOM 2

// Spell target selection
#define SPELL_SELECTION_RANGE "range"
#define SPELL_SELECTION_VIEW "view"

// Smoke spell defines
#define SMOKE_NONE 0
#define SMOKE_HARMLESS 1
#define SMOKE_COUGHING 2
#define SMOKE_SLEEPING 3

// Recharge spell defines
#define RECHARGE_SUCCESSFUL (1<<0)
#define RECHARGE_BURNOUT (1<<1)

#define SUMMON_GUNS "guns"
#define SUMMON_MAGIC "magic"

// Spell invocation types
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
