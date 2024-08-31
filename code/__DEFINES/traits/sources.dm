// This file contains all of the trait sources, or all of the things that grant traits.
// Several things such as `type` or `ref(src)` may be used in the ADD_TRAIT() macro as the "source", but this file contains all of the defines for immutable static strings.

/// The item is magically cursed
#define CURSED_ITEM_TRAIT(item_type) "cursed_item_[item_type]"
/// Gives a unique trait source for any given datum
#define UNIQUE_TRAIT_SOURCE(target) "unique_source_[UID_of(target)]"
/// Trait applied by element
#define ELEMENT_TRAIT(source) "element_trait_[source]"
/// A trait given by a specific status effect (not sure why we need both but whatever!)
#define TRAIT_STATUS_EFFECT(effect_id) "[effect_id]-trait"

// common trait sources
#define GENERIC_TRAIT "generic"
#define MAGIC_TRAIT "magic"
#define CULT_TRAIT "cult"
#define CLOCK_TRAIT "clockwork_cult"
#define INNATE_TRAIT "innate"
#define EAR_DAMAGE "ear_damage"
#define EYE_DAMAGE "eye_damage"

/// Trait sorce for "was recently shocked by something"
#define WAS_SHOCKED "was_shocked"

/// cannot be removed without admin intervention
#define ROUNDSTART_TRAIT "roundstart"

#define CINEMATIC_TRAIT "cinematic"

#define CHASM_TRAIT "chasm_trait"

// unique trait sources
#define CULT_EYES "cult_eyes"
#define CLOCK_HANDS "clock_hands"
#define PULSEDEMON_TRAIT "pulse_demon"
#define CHANGELING_TRAIT "changeling"
#define VAMPIRE_TRAIT "vampire"
#define NINJA_TRAIT "space-ninja"
#define REVENANT_TRAIT "revenant"
/// (B)admins only.
#define ADMIN_TRAIT "admin"

#define CMAGGED "clown_emag"

#define ABSTRACT_ITEM_TRAIT "abstract-item"
#define ABDUCTOR_VEST_TRAIT "abductor-vest"
#define CYBORG_ITEM_TRAIT "cyborg-item"
#define MECHA_EQUIPMENT_TRAIT "mecha-equip"
#define HIS_GRACE_TRAIT "his-grace"
#define CHAINSAW_TRAIT "chainsaw-wield"
#define PYRO_CLAWS_TRAIT "pyro-claws"
#define CONTRACTOR_BATON_TRAIT "contractor-baton"
#define MUZZLE_TRAIT "muzzle"
#define CHRONOSUIT_TRAIT "chrono-suit"
#define SUPERHERO_TRAIT "super-hero"
#define AUGMENT_TRAIT "augment"
#define ANTIDROP_TRAIT "antidrop"
#define HOLO_CIGAR_TRAIT "holo_cigar"

#define WISHGRANTER_TRAIT "wishgranter"
#define THUNDERDOME_TRAIT "thunderdome"

/// A trait given by any status effect
#define STATUS_EFFECT_TRAIT "status-effect"

#define SPECIES_TRAIT "species_trait"

#define CLOTHING_TRAIT "clothing"

#define DNA_TRAIT "dna_trait"

#define FATNESS_TRAIT "fatness"

/// Traits applied to a silicon mob by their model.
#define ROBOT_TRAIT "robot_trait"

/// A trait gained from a mob's leap action, like the leaper
#define LEAPING_TRAIT "leaping"

#define INCORPOREAL_TRAIT "incorporeal"

/// Will be removed once the transformation is complete.
#define TEMPORARY_TRANSFORMATION_TRAIT "temporary_transformation"
/// Considered "permanent" since we'll be deleting the old mob and the client will be inserted into a new one (without this trait)
#define PERMANENT_TRANSFORMATION_TRAIT "permanent_transformation"

/// Trait given by your current speed
#define SPEED_TRAIT "speed_trait"

/// Trait associated to being cuffed
#define HANDCUFFED_TRAIT "handcuffed_trait"
/// trait associated to not having fine manipulation appendages such as hands
#define LACKING_MANIPULATION_APPENDAGES_TRAIT "lacking-manipulation-appengades"
/// trait associated to not having locomotion appendages nor the ability to fly or float
#define LACKING_LOCOMOTION_APPENDAGES_TRAIT "lacking-locomotion-appengades"
/// Trait associated to wearing a suit
#define SUIT_TRAIT "suit_trait"
/// Trait associated to lying down (having a [lying_angle] of a different value than zero).
#define LYING_DOWN_TRAIT "lying-down"

#define NO_GRAVITY_TRAIT "no-gravity"
#define NEGATIVE_GRAVITY_TRAIT "negative-gravity"

/// Sources for TRAIT_IGNORING_GRAVITY
#define IGNORING_GRAVITY_NEGATION "ignoring_gravity_negation"

/// trait associated to being buckled
#define BUCKLED_TRAIT "buckled"

#define STAMINA_TRAIT "stamina"

/// trait associated to resting
#define RESTING_TRAIT "resting"
/// trait associated to a stat value or range of
#define STAT_TRAIT "stat"
/// trait associated to being held in a chokehold
#define CHOKEHOLD_TRAIT "chokehold"

#define COCOONED_TRAIT "cocooned_stat"
#define LOCKED_BORG_TRAIT "locked-borg"
#define CAT_TRAIT "kitty-kat"
#define SLIME_TRAIT "slime"

#define FULTON_TRAIT "fulton"

#define ANOMALOUS_CRYSTAL_TRAIT "anomalous_crystal"

#define FLOOR_CLUWNE_TRAIT "floor_cluwne"

#define DRAGON_SWOOP_TRAIT "dragon_swoop"

#define PANDORA_TEPELORT_TRAIT "pandora_teleport"

/// Trait given by living mob death
#define SIMPLE_MOB_DEATH_TRAIT "simple_mob_death"

#define VENTCRAWLING_TRAIT "ventcrawling"

// sources for trait TRAIT_MOVE_FLYING
#define ITEM_BROOM_TRAIT "item_broom_trait"
#define ITEM_GRAV_BOOTS_TRAIT "item_grav_boots_trait"
#define ITEM_JUMP_BOOTS_TRAIT "item_jump_boots_trait"
#define IMPLANT_JUMP_BOOTS_TRAIT "implant_jump_boots_trait"
#define SPELL_LEAP_TRAIT "spell_leap_trait"
#define SPELL_LUNGE_TRAIT "spell_lunge_trait"

// item trait sources
#define BROODMOTHER_TONGUE_TRAIT "broodmother_tongue"
#define SCRYING_ORB_TRAIT "scrying_orb"
#define EVIL_FAX_TRAIT "evil_fax"
#define CORGI_HARDSUIT_TRAIT "corgi_hardsuit"

