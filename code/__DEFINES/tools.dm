// Tool types
#define TOOL_CROWBAR "crowbar"
#define TOOL_MULTITOOL "multitool"
#define TOOL_SCREWDRIVER "screwdriver"
#define TOOL_WIRECUTTER "wirecutter"
#define TOOL_WRENCH "wrench"
#define TOOL_WELDER "welder"
#define TOOL_ANALYZER "analyzer"

// Surgery tools
#define TOOL_RETRACTOR "retractor"
#define TOOL_HEMOSTAT "hemostat"
#define TOOL_CAUTERY "cautery"
#define TOOL_DRILL "drill"
#define TOOL_SCALPEL "scalpel"
#define TOOL_SAW "saw"
#define TOOL_BONESET "bonesetter"
#define TOOL_BONEGEL "bonegel"
#define TOOL_FIXOVEIN "fixovein"

GLOBAL_LIST_INIT(surgery_tool_behaviors, list(
	TOOL_RETRACTOR,
	TOOL_HEMOSTAT,
	TOOL_CAUTERY,
	TOOL_DRILL,
	TOOL_SCALPEL,
	TOOL_SAW,
	TOOL_BONESET,
	TOOL_BONEGEL,
	TOOL_FIXOVEIN,
	TOOL_SCREWDRIVER
))

#define MIN_TOOL_SOUND_DELAY 20

// Crowbar messages
#define CROWBAR_ATTEMPT_PRY_CIRCUIT_MESSAGE \
	balloon_alert_to_viewers("начина[PLUR_ET_YUT(user)] извлекать плату...", "извлечение платы...");\
	user.visible_message(blind_message = span_hear("Слышны звуки поддевания."));
#define CROWBAR_PRY_CIRCUIT_SUCCESS_MESSAGE balloon_alert_to_viewers("извлека[PLUR_ET_YUT(user)] плату", "плата извлечена")

// Screwdriver messages
#define SCREWDRIVER_SCREW_MESSAGE \
	balloon_alert_to_viewers("затягива[PLUR_ET_YUT(user)] винты", "винты затянуты");\
	user.visible_message(blind_message = span_hear("Слышны звуки закручивания."));
#define SCREWDRIVER_UNSCREW_MESSAGE \
	balloon_alert_to_viewers("ослабля[PLUR_ET_YUT(user)] винты", "винты ослаблены");\
	user.visible_message(blind_message = span_hear("Слышны звуки откручивания."));

#define SCREWDRIVER_OPEN_PANEL_MESSAGE \
	balloon_alert_to_viewers("открыва[PLUR_ET_YUT(user)] панель", "панель открыта");\
	user.visible_message(blind_message = span_hear("Слышны звуки откручивания."));
#define SCREWDRIVER_CLOSE_PANEL_MESSAGE \
	balloon_alert_to_viewers("закрыва[PLUR_ET_YUT(user)] панель", "панель закрыта");\
	user.visible_message(blind_message = span_hear("Слышны звуки закручивания."));

// Wirecutter messages
#define WIRECUTTER_SNIP_MESSAGE \
	balloon_alert_to_viewers("перекусыва[PLUR_ET_YUT(user)] провода", "провода перекусаны");\
	user.visible_message(blind_message = span_hear("Слышны звуки резки."));

#define WIRECUTTER_ATTEMPT_DISMANTLE_MESSAGE \
	balloon_alert_to_viewers("начина[PLUR_ET_YUT(user)] разбирать...", "разборка...");\
	user.visible_message(blind_message = span_hear("Слышны звуки резки."));
#define WIRECUTTER_DISMANTLE_SUCCESS_MESSAGE balloon_alert_to_viewers("заверша[PLUR_ET_YUT(user)] разборку", "разобрано")

// Welder messages and other stuff
#define HEALPERWELD 15

#define WELDER_ATTEMPT_WELD_MESSAGE \
	balloon_alert_to_viewers("начина[PLUR_ET_YUT(user)] сваривать...", "сварка...");\
	user.visible_message(blind_message = span_hear("Слышны звуки сваривания."));
#define WELDER_WELD_SUCCESS_MESSAGE balloon_alert_to_viewers("заверша[PLUR_ET_YUT(user)] сварку", "сварено")

#define WELDER_ATTEMPT_REPAIR_MESSAGE \
	balloon_alert_to_viewers("начина[PLUR_ET_YUT(user)] ремонтировать...", "ремонт...");\
	user.visible_message(blind_message = span_hear("Слышны звуки сваривания."));
#define WELDER_REPAIR_SUCCESS_MESSAGE balloon_alert_to_viewers("заверша[PLUR_ET_YUT(user)] ремонт", "отремонтировано")

#define WELDER_ATTEMPT_SLICING_MESSAGE \
	balloon_alert_to_viewers("начина[PLUR_ET_YUT(user)] разваривать...", "разваривание...");\
	user.visible_message(blind_message = span_hear("Слышны звуки разрезания."));
#define WELDER_SLICING_SUCCESS_MESSAGE balloon_alert_to_viewers("заверша[PLUR_ET_YUT(user)] разваривание", "разварено")

#define WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE \
	balloon_alert_to_viewers("начина[PLUR_ET_YUT(user)] отделять от пола...", "отделение от пола...");\
	user.visible_message(blind_message = span_hear("Слышны звуки сваривания."));
#define WELDER_FLOOR_SLICE_SUCCESS_MESSAGE balloon_alert_to_viewers("отделя[PLUR_ET_YUT(user)] от пола", "отделено от пола")

#define WELDER_ATTEMPT_FLOOR_WELD_MESSAGE \
	balloon_alert_to_viewers("начина[PLUR_ET_YUT(user)] приваривать к полу...", "приваривание к полу...");\
	user.visible_message(blind_message = span_hear("Слышны звуки сваривания."));
#define WELDER_FLOOR_WELD_SUCCESS_MESSAGE balloon_alert_to_viewers("приварива[PLUR_ET_YUT(user)] к полу", "приварено к полу")

// Wrench messages
#define WRENCH_ANCHOR_MESSAGE \
	balloon_alert_to_viewers("затягива[PLUR_ET_YUT(user)] болты", "болты затянуты");\
	user.visible_message(blind_message = span_hear("Слышен трещоточный звук."));
#define WRENCH_UNANCHOR_MESSAGE \
	balloon_alert_to_viewers("ослабля[PLUR_ET_YUT(user)] болты", "болты ослаблены");\
	user.visible_message(blind_message = span_hear("Слышен трещоточный звук."));

#define WRENCH_UNANCHOR_WALL_MESSAGE \
	balloon_alert_to_viewers("открепля[PLUR_ET_YUT(user)] от стены", "откреплено от стены");\
	user.visible_message(blind_message = span_hear("Слышен трещоточный звук."));
#define WRENCH_ANCHOR_TO_WALL_MESSAGE \
	balloon_alert_to_viewers("закрепля[PLUR_ET_YUT(user)] на стене", "закреплено на стене");\
	user.visible_message(blind_message = span_hear("Слышен трещоточный звук."));

// Generic tool messages that don't correspond to any particular tool
#define TOOL_ATTEMPT_DISMANTLE_MESSAGE \
	balloon_alert_to_viewers("начина[PLUR_ET_YUT(user)] разбирать...", "разборка...");\
	user.visible_message(blind_message = span_hear("Слышны звуки работы с инструментом."));
#define TOOL_DISMANTLE_SUCCESS_MESSAGE balloon_alert_to_viewers("заверша[PLUR_ET_YUT(user)] разборку", "разобрано")

/// Return when an item interaction is successful.
/// This cancels the rest of the chain entirely and indicates success.
#define ITEM_INTERACT_SUCCESS (1<<0) // Same as TRUE, as most tool (legacy) tool acts return TRUE on success
/// Return to prevent the rest of the attack chain from being executed / preventing the item user from thwacking the target.
/// Similar to [ITEM_INTERACT_SUCCESS], but does not necessarily indicate success.
#define ITEM_INTERACT_BLOCKING (1<<1)
	/// Only for people who get confused by the naming scheme
	#define ITEM_INTERACT_FAILURE ITEM_INTERACT_BLOCKING
/// Return to skip the rest of the interaction chain, going straight to attack.
#define ITEM_INTERACT_SKIP_TO_ATTACK (1<<2)

/// Combination flag for any item interaction that blocks the rest of the attack chain
#define ITEM_INTERACT_ANY_BLOCKER (ITEM_INTERACT_SUCCESS | ITEM_INTERACT_BLOCKING)
