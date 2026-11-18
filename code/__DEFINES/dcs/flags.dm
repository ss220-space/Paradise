/// Return this from `/datum/component/Initialize` or `datum/component/OnTransfer` to have the component be deleted if it's applied to an incorrect type.
/// `parent` must not be modified if this is to be returned.
/// This will be noted in the runtime logs
#define COMPONENT_INCOMPATIBLE 1
/// Returned in PostTransfer to prevent transfer, similar to `COMPONENT_INCOMPATIBLE`
#define COMPONENT_NOTRANSFER 2

/// Return value to cancel attaching
#define ELEMENT_INCOMPATIBLE 1

// /datum/element flags
/// Causes the detach proc to be called when the host object is being deleted
#define ELEMENT_DETACH_ON_HOST_DESTROY (1 << 0)
/**
 * Only elements created with the same arguments given after `argument_hash_start_idx` share an element instance
 * The arguments are the same when the text and number values are the same and all other values have the same ref
 */
#define ELEMENT_BESPOKE (1 << 1)

// How multiple components of the exact same type are handled in the same datum
/// old component is deleted (default)
#define COMPONENT_DUPE_HIGHLANDER 0
/// duplicates allowed
#define COMPONENT_DUPE_ALLOWED 1
/// new component is deleted
#define COMPONENT_DUPE_UNIQUE 2
/**
 * Component uses source tracking to manage adding and removal logic.
 * Add a source/spawn to/the component by using AddComponentFrom(source, component_type, args...)
 * Removing the last source will automatically remove the component from the parent.
 * Arguments will be passed to on_source_add(source, args...); ensure that Initialize and on_source_add have the same signature.
 */
#define COMPONENT_DUPE_SOURCES 3
/// old component is given the initialization args of the new
#define COMPONENT_DUPE_UNIQUE_PASSARGS 4
/// each component of the same type is consulted as to whether the duplicate should be allowed
#define COMPONENT_DUPE_SELECTIVE 5

//Redirection component init flags
#define REDIRECT_TRANSFER_WITH_TURF 1

//Arch
#define ARCH_PROB "probability" //Probability for each item
#define ARCH_MAXDROP "max_drop_amount" //each item's max drop amount

//Ouch my toes!
#define CALTROP_BYPASS_SHOES (1<<0)
#define CALTROP_BYPASS_WALKERS (1<<1)
#define CALTROP_BYPASS_ROBOTIC_FOOTS (1<<2)
#define CALTROP_BYPASS_CRAWLING (1<<3)

// Udder component features.
/// Generate milk on Life ticks.
#define UDDER_PASSIVE_GENERATION (1<<0)
/// Show the current milk volume when examined.
#define UDDER_EXAMINE (1<<1)
/// Generate milk after consuming configured food types.
#define UDDER_GENERATE_ON_CONSUME (1<<2)
/// Boost milk production after successful feeding.
#define UDDER_BOOST_ON_FEED (1<<3)
/// Empty the udder after the parent gives birth.
#define UDDER_CLEAR_ON_BIRTH (1<<4)
