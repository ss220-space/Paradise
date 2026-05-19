#define GHOST_CAN_REENTER 1
#define GHOST_IS_OBSERVER 2

/// Aghosting AND APPERANTLY STEALTHMINNING sets your ckey/key == "@[old_key]" because it hates me. this detects that
#define IS_FAKE_KEY(key) (key && key[1] == "@")
