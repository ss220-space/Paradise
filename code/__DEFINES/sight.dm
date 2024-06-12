///Default see in dark. See in dark sucks.
#define DEFAULT_SEE_IN_DARK 1e6

#define SEE_IN_DARK_THRESHOLD 4

#define SEE_INVISIBLE_MINIMUM 5

#define SEE_INVISIBLE_OBSERVER_NOLIGHTING 15

#define INVISIBILITY_LIGHTING 20

#define SEE_INVISIBLE_LIVING 25

// Hidden cult runes
#define INVISIBILITY_HIDDEN_RUNES  30
#define SEE_INVISIBLE_HIDDEN_RUNES 30

#define SEE_INVISIBLE_LEVEL_ONE 35	//Used by some stuff in code. It's really poorly organized.

#define SEE_INVISIBLE_LEVEL_TWO 45	//Used by some other stuff in code. It's really poorly organized.
#define INVISIBILITY_LEVEL_TWO 45	//Used by some other stuff in code. It's really poorly organized.

#define INVISIBILITY_SPIRIT 50
#define SEE_SPIRITS 50

#define INVISIBILITY_ANOMALY 40	// Can be seen by observers or using a t-ray scanner

#define SEE_INVISIBLE_OBSERVER_NOOBSERVERS 59
#define INVISIBILITY_OBSERVER 60
#define SEE_INVISIBLE_OBSERVER 60
#define INVISIBILITY_AI_EYE 61
#define SEE_INVISIBLE_OBSERVER_AI_EYE 61


#define INVISIBILITY_MAXIMUM 100
#define INVISIBILITY_ABSTRACT 101

//Some mob defines below
#define AI_CAMERA_LUMINOSITY 6

#define SILICONMESON 1
#define SILICONTHERM 2
#define SILICONXRAY  4
#define SILICONNIGHTVISION 8

#define SECHUD 1
#define MEDHUD 2
#define ANTAGHUD 3

//for clothing visor toggles, these determine which vars to toggle
#define VISOR_FLASHPROTECT		(1<<0)
#define VISOR_TINT				(1<<1)
#define VISOR_VISIONFLAGS		(1<<2) //all following flags only matter for glasses
#define VISOR_DARKNESSVIEW		(1<<3)
#define VISOR_INVISVIEW			(1<<4)
#define VISOR_HUDTYPE			(1<<5)
#define VISOR_EXAM_EXTENTIONS	(1<<6)


#define VISOR_FULL_HUD (VISOR_HUDTYPE|VISOR_EXAM_EXTENTIONS)

// BYOND internal values for the sight flags
// See [https://www.byond.com/docs/ref/#/mob/var/sight]
/// can't see anything
//#define BLIND (1<<0)
/// can see all mobs, no matter what
//#define SEE_MOBS (1<<2)
/// can see all objs, no matter what
//#define SEE_OBJS (1<<3)
// can see all turfs (and areas), no matter what
//#define SEE_TURFS (1<<4)
/// can see self, no matter what
//#define SEE_SELF (1<<5)
/// can see infra-red objects (different sort of luminosity, essentially a copy of it, one we do not use)
//#define SEE_INFRA (1<<6)
/// if an object is located on an unlit area, but some of its pixels are
/// in a lit area (via pixel_x,y or smooth movement), can see those pixels
//#define SEE_PIXELS (1<<8)
/// can see through opaque objects
//#define SEE_THRU (1<<9)
/// render dark tiles as blackness (Note, this basically means we draw dark tiles to plane 0)
/// we can then hijack that plane with a plane master, and start drawing it anywhere we want
/// NOTE: this does not function with the SIDE_MAP map format. So we can't. :(
//#define SEE_BLACKNESS (1<<10)

/// Bitfield of sight flags that show things "inside" the blackness plane
/// We've gotta alpha it down if we get this, cause otherwise the sight flag won't work
#define BLACKNESS_CUTTING (SEE_MOBS|SEE_OBJS|SEE_TURFS|SEE_TURFS|SEE_TURFS)
