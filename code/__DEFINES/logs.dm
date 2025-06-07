// Used for create_log() Log Viewer
#define ATTACK_LOG		"Attack"
#define DEFENSE_LOG		"Defense"
#define CONVERSION_LOG	"Conversion"
#define SAY_LOG			"Say"
#define EMOTE_LOG		"Emote"
#define GAME_LOG		"Game"
#define MISC_LOG		"Misc"
#define DEADCHAT_LOG	"Deadchat"
#define OOC_LOG			"OOC"
#define LOOC_LOG		"LOOC"

#define ALL_LOGS list(ATTACK_LOG, DEFENSE_LOG, CONVERSION_LOG, SAY_LOG, EMOTE_LOG, GAME_LOG, DEADCHAT_LOG, OOC_LOG, LOOC_LOG, MISC_LOG)

// Logging types for log_message()
#define LOG_ATTACK (1 << 0)
#define LOG_SAY (1 << 1)
#define LOG_WHISPER (1 << 2)
#define LOG_EMOTE (1 << 3)
#define LOG_DSAY (1 << 4)
#define LOG_PDA (1 << 5)
#define LOG_CHAT (1 << 6)
#define LOG_COMMENT (1 << 7)
#define LOG_TELECOMMS (1 << 8)
#define LOG_OOC (1 << 9)
#define LOG_ADMIN (1 << 10)
#define LOG_OWNERSHIP (1 << 11)
#define LOG_GAME (1 << 12)
#define LOG_ADMIN_PRIVATE (1 << 13)
#define LOG_ASAY (1 << 14)
#define LOG_MECHA (1 << 15)
#define LOG_VIRUS (1 << 16)
#define LOG_SHUTTLE (1 << 17)
#define LOG_ECON (1 << 18)
#define LOG_VICTIM (1 << 19)
#define LOG_RADIO_EMOTE (1 << 20)
#define LOG_SPEECH_INDICATORS (1 << 21)
#define LOG_TRANSPORT (1 << 22)

//Investigate logging defines
#define INVESTIGATE_ACCESSCHANGES "id_card_changes"
#define INVESTIGATE_ATMOS "atmos"
#define INVESTIGATE_BOMB "bombs"
#define INVESTIGATE_BOTANY "botany"
#define INVESTIGATE_CARGO "cargo"
#define INVESTIGATE_CRAFTING "crafting"
#define INVESTIGATE_DEATHS "deaths"
#define INVESTIGATE_ENGINE "engine"
#define INVESTIGATE_EXPERIMENTOR "experimentor"
#define INVESTIGATE_GRAVITY "gravity"
#define INVESTIGATE_HALLUCINATIONS "hallucinations"
#define INVESTIGATE_TELEPORTATION "teleportation"
#define INVESTIGATE_RECORDS "records"
#define INVESTIGATE_RENAME "renames"
#define INVESTIGATE_RESEARCH "research"
#define INVESTIGATE_SYNDIE_CARGO "syndicate_cargo"
#define INVESTIGATE_WIRES "wires"

//This is an external call, "true" and "false" are how rust parses out booleans
#define WRITE_LOG(log, text) rustg_log_write(log, text, "true")
#define WRITE_LOG_NO_FORMAT(log, text) rustg_log_write(log, text, "false")
