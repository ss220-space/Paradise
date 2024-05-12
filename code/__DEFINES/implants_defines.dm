/// If used, an implant will trigger when an emote is intentionally used.
#define BIOCHIP_EMOTE_TRIGGER_INTENTIONAL (1<<0)
/// If used, an implant will trigger when an emote is forced/unintentionally used.
#define BIOCHIP_EMOTE_TRIGGER_UNINTENTIONAL (1<<1)
/// If used, an implant will always trigger when the user makes an emote.
#define BIOCHIP_EMOTE_TRIGGER_ALWAYS (BIOCHIP_EMOTE_TRIGGER_UNINTENTIONAL|BIOCHIP_EMOTE_TRIGGER_INTENTIONAL)
/// If used, an implant will trigger on the user's first death.
#define BIOCHIP_TRIGGER_DEATH_ONCE (1<<2)
/// If used, an implant will trigger any time a user dies.
#define BIOCHIP_TRIGGER_DEATH_ANY (1<<3)
/// If used, an implant will NOT trigger on death when a user is gibbed.
#define BIOCHIP_TRIGGER_NOT_WHEN_GIBBED (1<<4)

// Defines related to the way that the implant is activated. This is the value for implant.activated
/// The implant is passively active (like a mindshield)
#define BIOCHIP_ACTIVATED_PASSIVE 0
/// The implant is activated manually by a trigger
#define BIOCHIP_ACTIVATED_ACTIVE 1

// Defines related to biochip current status
/// The implant is currently inside the body
#define BIOCHIP_IMPLANTED 1
/// The implant was once implanted into someone
#define BIOCHIP_USED 0
/// The implant is new and intact
#define BIOCHIP_NEW null

// Defines implanting results of proc [/obj/item/implant/proc/implant()]
/// Implant is successfully installed
#define BIOCHIP_IMPLANT_SUCCESS 1
/// Implant fails to inject
#define BIOCHIP_IMPLANT_FAIL -1
/// Return this if there's no room for the implant
#define BIOCHIP_IMPLANT_NOROOM 0

