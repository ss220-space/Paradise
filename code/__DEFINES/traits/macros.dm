// This file contains all of the "dynamic" traits and trait sources that can be used
// in a number of versatile and everchanging ways.
// If it uses psuedo-variables like the examples below, it's a macro-trait.

/// The item is magically cursed
#define CURSED_ITEM_TRAIT(item_type) "cursed_item_[item_type]"
/// Gives a unique trait source for any given datum
#define UNIQUE_TRAIT_SOURCE(target) "unique_source_[UID_of(target)]"
/// Trait applied by element
#define ELEMENT_TRAIT(source) "element_trait_[source]"
/// A trait given by a specific status effect (not sure why we need both but whatever!)
#define TRAIT_STATUS_EFFECT(effect_id) "[effect_id]-trait"
