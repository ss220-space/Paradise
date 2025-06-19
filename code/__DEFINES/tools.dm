// Tool tools
#define TOOL_CROWBAR 		"crowbar"
#define TOOL_MULTITOOL		"multitool"
#define TOOL_SCREWDRIVER 	"screwdriver"
#define TOOL_WIRECUTTER 	"wirecutter"
#define TOOL_WRENCH 		"wrench"
#define TOOL_WELDER 		"welder"
#define TOOL_ANALYZER		"analyzer"

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

//Crowbar messages
#define CROWBAR_ATTEMPT_PRY_CIRCUIT_MESSAGE	user.visible_message(span_notice("[user] начина[pluralize_ru(user.gender,"ет","ют")] извлекать плату из [src.declent_ru(GENITIVE)]..."), span_notice("Вы начинаете извлекать плату из [src.declent_ru(GENITIVE)]..."),  span_warning("Слышны звуки откручивания."))

#define CROWBAR_PRY_CIRCUIT_SUCCESS_MESSAGE	user.visible_message(span_notice("[user] извлека[pluralize_ru(user.gender,"ет","ют")] плату из [src.declent_ru(GENITIVE)]!"), span_notice("Вы извлекаете плату из [src.declent_ru(GENITIVE)]!"), span_warning("Слышны звуки откручивания."))


//Screwdriver messages
#define SCREWDRIVER_SCREW_MESSAGE			user.visible_message(span_notice("[user] затягива[pluralize_ru(user.gender,"ет","ют")] винты на [src.declent_ru(PREPOSITIONAL)]!"), span_notice("Вы затягиваете винты на [src.declent_ru(PREPOSITIONAL)]!"), span_warning("Слышен звук отвёртки."))
#define SCREWDRIVER_UNSCREW_MESSAGE			user.visible_message(span_notice("[user] ослабля[pluralize_ru(user.gender,"ет","ют")] винты на [src.declent_ru(PREPOSITIONAL)]!"), span_notice("Вы ослабляете винты на [src.declent_ru(PREPOSITIONAL)]!"), span_warning("Слышен звук отвёртки."))
#define SCREWDRIVER_OPEN_PANEL_MESSAGE		user.visible_message(span_notice("[user] открыва[pluralize_ru(user.gender,"ет","ют")] панель [src.declent_ru(GENITIVE)]!"), span_notice("Вы открываете панель [src.declent_ru(GENITIVE)]!"), span_warning("Слышен звук отвёртки."))
#define SCREWDRIVER_CLOSE_PANEL_MESSAGE		user.visible_message(span_notice("[user] закрыва[pluralize_ru(user.gender,"ет","ют")] панель [src.declent_ru(GENITIVE)]!"), span_notice("Вы закрываете панель [src.declent_ru(GENITIVE)]!"), span_warning("Слышен звук отвёртки."))

//Wirecutter messages
#define WIRECUTTER_SNIP_MESSAGE					user.visible_message(span_notice("[user] перереза[pluralize_ru(user.gender,"ет","ют")] провода в [src.declent_ru(PREPOSITIONAL)]!"), span_notice("Вы перерезаете провода в [src.declent_ru(GENITIVE)]!"), span_warning("Слышны звуки резки."))
#define WIRECUTTER_ATTEMPT_DISMANTLE_MESSAGE	user.visible_message(span_notice("[user] начина[pluralize_ru(user.gender,"ет","ют")] разбирать [src.declent_ru(NOMINATIVE)]..."), span_notice("Вы начинаете разбирать [src.declent_ru(ACCUSATIVE)]..."), span_warning("Слышны звуки резки."))
#define WIRECUTTER_DISMANTLE_SUCCESS_MESSAGE	user.visible_message(span_notice("[user] разбира[pluralize_ru(user.gender,"ет","ют")] [src.declent_ru(ACCUSATIVE)] на части!"), span_notice("Вы разбираете [src.declent_ru(ACCUSATIVE)] на части!"), span_warning("Слышны звуки резки."))

//Welder messages and other stuff
#define HEALPERWELD 15
#define WELDER_ATTEMPT_WELD_MESSAGE			user.visible_message(span_notice("[user] начина[pluralize_ru(user.gender,"ет","ют")] варить [src.declent_ru(ACCUSATIVE)]..."), span_notice("Вы начинаете сварку [src.declent_ru(GENITIVE)]..."), span_warning("Слышна сварка."))
#define WELDER_WELD_SUCCESS_MESSAGE			to_chat(user, span_notice("Вы завершили сварку [src.declent_ru(GENITIVE)]!"))
#define WELDER_ATTEMPT_REPAIR_MESSAGE		user.visible_message(span_notice("[user] начина[pluralize_ru(user.gender,"ет","ют")] ремонтировать [src.declent_ru(ACCUSATIVE)]..."), span_notice("Вы начинаете ремонт [src.declent_ru(GENITIVE)]..."), span_warning("Слышна сварка."))
#define WELDER_REPAIR_SUCCESS_MESSAGE		to_chat(user, span_notice("Вы отремонтировали [src.declent_ru(ACCUSATIVE)]!"))
#define WELDER_ATTEMPT_SLICING_MESSAGE		user.visible_message(span_notice("[user] начина[pluralize_ru(user.gender,"ет","ют")] разрезать [src.declent_ru(ACCUSATIVE)]..."), span_notice("Вы начинаете резку [src.declent_ru(GENITIVE)]..."), span_warning("Слышна сварка."))
#define WELDER_SLICING_SUCCESS_MESSAGE		to_chat(user, span_notice("Вы аккуратно разрезали [src.declent_ru(ACCUSATIVE)]!"))
#define WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE	user.visible_message(span_notice("[user] начина[pluralize_ru(user.gender,"ет","ют")] отрезать [src.declent_ru(ACCUSATIVE)] от [get_turf(src.declent_ru(GENITIVE))]..."), span_notice("Вы начинаете отрезать [src.declent_ru(ACCUSATIVE)] от [get_turf(src.declent_ru(GENITIVE))]..."), span_warning("Слышна сварка."))
#define WELDER_FLOOR_SLICE_SUCCESS_MESSAGE	to_chat(user, span_notice("Вы отделили [src.declent_ru(ACCUSATIVE)] от [get_turf(src.declent_ru(GENITIVE))]!"))
#define WELDER_ATTEMPT_FLOOR_WELD_MESSAGE	user.visible_message(span_notice("[user] начина[pluralize_ru(user.gender,"ет","ют")] приваривать [src.declent_ru(ACCUSATIVE)] к [get_turf(src.declent_ru(GENITIVE))]..."), span_notice("Вы начинаете приваривать [src.declent_ru(ACCUSATIVE)] к [get_turf(src.declent_ru(GENITIVE))]..."), span_warning("Слышна сварка."))
#define WELDER_FLOOR_WELD_SUCCESS_MESSAGE	to_chat(user, span_notice("Вы приварили [src.declent_ru(ACCUSATIVE)] к [get_turf(src.declent_ru(GENITIVE))]!"))

//Wrench messages
#define WRENCH_ANCHOR_MESSAGE				user.visible_message(span_notice("[user] затягива[pluralize_ru(user.gender,"ет","ют")] болты на [src.declent_ru(PREPOSITIONAL)]!"), span_notice("Вы затягиваете болты на [src.declent_ru(PREPOSITIONAL)]!"), span_warning("Слышен трещоточный звук."))
#define WRENCH_UNANCHOR_MESSAGE				user.visible_message(span_notice("[user] ослабля[pluralize_ru(user.gender,"ет","ют")] болты на [src.declent_ru(PREPOSITIONAL)]!"), span_notice("Вы ослабляете болты на [src.declent_ru(PREPOSITIONAL)]!"), span_warning("Слышен трещоточный звук."))
#define WRENCH_UNANCHOR_WALL_MESSAGE		user.visible_message(span_notice("[user] откручива[pluralize_ru(user.gender,"ет","ют")] [src.declent_ru(ACCUSATIVE)] от стены!"), span_notice("Вы откручиваете [src.declent_ru(ACCUSATIVE)] от стены!"), span_warning("Слышен трещоточный звук."))
#define WRENCH_ANCHOR_TO_WALL_MESSAGE		user.visible_message(span_notice("[user] закрепля[pluralize_ru(user.gender,"ет","ют")] [src.declent_ru(ACCUSATIVE)] на стене!"), span_notice("Вы закрепляете [src.declent_ru(ACCUSATIVE)] на стене!"), span_warning("Слышен трещоточный звук."))

//Generic tool messages that don't correspond to any particular tool
#define TOOL_ATTEMPT_DISMANTLE_MESSAGE	    user.visible_message(span_notice("[user] начина[pluralize_ru(user.gender,"ет","ют")] разбирать [src.declent_ru(ACCUSATIVE)] при помощи [I]..."), span_notice("Вы начинаете разборку [src] при помощи [I]..."), span_warning("Слышны звуки работы с инструментом."))
#define TOOL_DISMANTLE_SUCCESS_MESSAGE  	user.visible_message(span_notice("[user] демонтиру[pluralize_ru(user.gender,"ет","ют")] [src.declent_ru(ACCUSATIVE)]!"), span_notice("Вы демонтировали [src.declent_ru(ACCUSATIVE)]!"), span_warning("Слышны звуки работы с инструментом."))
