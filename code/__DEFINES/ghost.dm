#define GHOST_CAN_REENTER 1
#define GHOST_IS_OBSERVER 2

/// Aghosting AND APPERANTLY STEALTHMINNING sets your ckey/key == "@[old_key]" because it hates me. this detects that
#define IS_FAKE_KEY(key) (key && key[1] == "@")

/// A ghosts min view range that we won't allow them to go under by.
#define GHOST_MIN_VIEW_RANGE 7
/// A ghosts max view range if they are a BYOND guest or regular account
#define GHOST_MAX_VIEW_RANGE_DEFAULT 10
/// A ghosts max view range if they are a BYOND paid member account (P2W feature)
#define GHOST_MAX_VIEW_RANGE_MEMBER 14
