// The severity of explosions. Why are these inverted? I have no idea, but git blame doesn't go back far enough for me to find out.
/// The (current) highest possible explosion severity.
#define EXPLODE_DEVASTATE 3
/// The (current) middling explosion severity.
#define EXPLODE_HEAVY 2
/// The (current) lowest possible explosion severity.
#define EXPLODE_LIGHT 1
/// The default explosion severity used to mark that an object is beyond the impact range of the explosion.
#define EXPLODE_NONE 0

// Gibtonite state defines
/// Gibtonite has not been mined
#define GIBTONITE_UNSTRUCK 0
/// Gibtonite has been mined and will explode soon
#define GIBTONITE_ACTIVE 1
/// Gibtonite has been stablized preventing an explosion
#define GIBTONITE_STABLE 2
/// Gibtonite will now explode
#define GIBTONITE_DETONATE 3
