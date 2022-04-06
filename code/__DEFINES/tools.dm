#define TOOL_CROWBAR 		"crowbar"
#define TOOL_MULTITOOL		"multitool"
#define TOOL_SCREWDRIVER 	"screwdriver"
#define TOOL_WIRECUTTER 	"wirecutter"
#define TOOL_WRENCH 		"wrench"
#define TOOL_WELDER 		"welder"

#define MIN_TOOL_SOUND_DELAY 20

//Crowbar messages
#define CROWBAR_ATTEMPT_PRY_CIRCUIT_MESSAGE	user.visible_message("<span class='notice'>[user] начина[pluralize_ru(user.gender,"ет","ют")] выламывать печатную плату из [src]…</span>", "<span class='notice'>Вы начинаете вынимать печатную плату из [src]…</span>", "<span class='warning'>Вы слышите звуки выламывания.</span>")
#define CROWBAR_PRY_CIRCUIT_SUCCESS_MESSAGE	user.visible_message("<span class='notice'>[user] выламыва[pluralize_ru(user.gender,"ет","ют")] печатную плату из [src]!</span>", "<span class='notice'>Вы выламываете печатную плату из [src]!</span>", "<span class='warning'>Вы слышите звуки выламывания.</span>")

//Screwdriver messages
#define SCREWDRIVER_SCREW_MESSAGE			user.visible_message("<span class='notice'>[user] затягива[pluralize_ru(user.gender,"ет","ют")] винты на [src]!</span>", "<span class='notice'>Вы затягиваете винты на [src]!</span>", "<span class='warning'>Вы слышите звуки отвёртки.</span>")
#define SCREWDRIVER_UNSCREW_MESSAGE			user.visible_message("<span class='notice'>[user] ослабля[pluralize_ru(user.gender,"ет","ют")] винты на [src]!</span>", "<span class='notice'>Вы ослабляете винты на [src]!</span>", "<span class='warning'>Вы слышите звуки отвёртки.</span>")
#define SCREWDRIVER_OPEN_PANEL_MESSAGE		user.visible_message("<span class='notice'>[user] отвинчива[pluralize_ru(user.gender,"ет","ют")] панель на [src]!</span>", "<span class='notice'>Вы отвинчиваете панель на [src]!</span>", "<span class='warning'>Вы слышите звуки отвёртки.</span>")
#define SCREWDRIVER_CLOSE_PANEL_MESSAGE		user.visible_message("<span class='notice'>[user] завинчива[pluralize_ru(user.gender,"ет","ют")] панель на [src]!</span>", "<span class='notice'>Вы завинчиваете панель на [src]!</span>", "<span class='warning'>Вы слышите звуки отвёртки.</span>")

//Wirecutter messages
#define WIRECUTTER_SNIP_MESSAGE					user.visible_message("<span class='notice'>[user] среза[pluralize_ru(user.gender,"ет","ют")] провода с [src]!</span>", "<span class='notice'>Вы срезаете провода с [src]!</span>", "<span class='warning'>Вы слышите щелчки кусачек.</span>")
#define WIRECUTTER_ATTEMPT_DISMANTLE_MESSAGE	user.visible_message("<span class='notice'>[user] начина[pluralize_ru(user.gender,"ет","ют")] отрезать [src]… </span>", "<span class='notice'>Вы начинаете отрезать [src]…</span>", "<span class='warning'>Вы слышите щелчки кусачек.</span>")
#define WIRECUTTER_DISMANTLE_SUCCESS_MESSAGE	user.visible_message("<span class='notice'>[user] отреза[pluralize_ru(user.gender,"ет","ют")] [src]!</span>", "<span class='notice'>Вы отрезаете [src]!</span>", "<span class='warning'>Вы слышите щелчки кусачек.</span>")

//Welder messages and other stuff
#define HEALPERWELD 15
#define WELDER_ATTEMPT_WELD_MESSAGE			user.visible_message("<span class='notice'>[user] начина[pluralize_ru(user.gender,"ет","ют")] сварку [src]…</span>", "<span class='notice'>Вы начинаете сварку [src]…</span>", "<span class='warning'>Вы слышите звуки сварки.</span>")
#define WELDER_WELD_SUCCESS_MESSAGE			to_chat(user, "<span class='notice'>Вы завершаете сварку [src]!</span>")
#define WELDER_ATTEMPT_REPAIR_MESSAGE		user.visible_message("<span class='notice'>[user] начина[pluralize_ru(user.gender,"ет","ют")] заваривать повреждения на [src]…</span>", "<span class='notice'>Вы начинаете заваривать повреждения на [src]…</span>", "<span class='warning'>Вы слышите звуки сварки.</span>")
#define WELDER_REPAIR_SUCCESS_MESSAGE		to_chat(user, "<span class='notice'>Вы завариваете повреждения на [src]!</span>")
#define WELDER_ATTEMPT_SLICING_MESSAGE		user.visible_message("<span class='notice'>[user] начина[pluralize_ru(user.gender,"ет","ют")] разрезать [src]…</span>", "<span class='notice'>Вы начинаете разрезать [src]…</span>", "<span class='warning'>Вы слышите звуки сварки.</span>")
#define WELDER_SLICING_SUCCESS_MESSAGE		to_chat(user, "<span class='notice'>Вы разрезаете [src]!</span>")
#define WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE	user.visible_message("<span class='notice'>[user] начина[pluralize_ru(user.gender,"ет","ют")] отваривать [src] от [get_turf(src)]…</span>", "<span class='notice'>Вы начинаете отваривать [src] от [get_turf(src)]…</span>", "<span class='warning'>Вы слышите звуки сварки.</span>")
#define WELDER_FLOOR_SLICE_SUCCESS_MESSAGE	to_chat(user, "<span class='notice'>Вы очищаете [src] от [get_turf(src)]!</span>")
#define WELDER_ATTEMPT_FLOOR_WELD_MESSAGE	user.visible_message("<span class='notice'>[user] начина[pluralize_ru(user.gender,"ет","ют")] приваривать [src] к [get_turf(src)]…</span>", "<span class='notice'>Вы начинаете приваривать [src] к [get_turf(src)]…</span>", "<span class='warning'>Вы слышите звуки сварки.</span>")
#define WELDER_FLOOR_WELD_SUCCESS_MESSAGE	to_chat(user, "<span class='notice'>Вы привариваете [src] к [get_turf(src)]!</span>")

//Wrench messages
#define WRENCH_ANCHOR_MESSAGE				user.visible_message("<span class='notice'>[user] затягива[pluralize_ru(user.gender,"ет","ют")] болты на [src]!</span>", "<span class='notice'>Вы затягиваете болты на [src]!</span>", "<span class='warning'>Вы слышите звук трещотки.</span>")
#define WRENCH_UNANCHOR_MESSAGE				user.visible_message("<span class='notice'>[user] ослабля[pluralize_ru(user.gender,"ет","ют")] болты на [src]!</span>", "<span class='notice'>Вы ослабляете болты на [src]!</span>", "<span class='warning'>Вы слышите звук трещотки.</span>")
#define WRENCH_UNANCHOR_WALL_MESSAGE		user.visible_message("<span class='notice'>[user] откручива[pluralize_ru(user.gender,"ет","ют")] [src] от стены!</span>", "<span class='notice'>Вы откручиваете [src] от стены!</span>", "<span class='warning'>Вы слышите звук трещотки.</span>")
#define WRENCH_ANCHOR_TO_WALL_MESSAGE		user.visible_message("<span class='notice'>[user] прикручива[pluralize_ru(user.gender,"ет","ют")] [src] на стену!</span>", "<span class='notice'>Вы прикручиваете [src] на стену!</span>", "<span class='warning'>Вы слышите звук трещотки.</span>")

//Generic tool messages that don't correspond to any particular tool
#define TOOL_ATTEMPT_DISMANTLE_MESSAGE	    user.visible_message("<span class='notice'>Используя [I], [user], начина[pluralize_ru(user.gender,"ет","ют")] разбирать [src]…</span>", "<span class='notice'>Используя [I], вы начинаете разбирать [src]…</span>", "<span class='warning'>Вы слышите как кто-то использует какой-то инструмент.</span>")
#define TOOL_DISMANTLE_SUCCESS_MESSAGE  	user.visible_message("<span class='notice'>[user] разбира[pluralize_ru(user.gender,"ет","ют")] [src]!</span>", "<span class='notice'>Вы разбираете [src]!</span>", "<span class='warning'>Вы слышите как кто-то использует какой-то инструмент.</span>")
