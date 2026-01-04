/datum/holiday
	var/name = "День багодарения"
	// Right now, only holidays that take place on a certain day or within a time period are supported.
	// It would be nice to support things like "the second monday in march" or "the first sunday after the second sunday in june"
	var/begin_day = 1
	var/begin_month = 0
	/// Default of 0 means the holiday lasts a single day
	var/end_day = 0
	var/end_month = 0
	var/eventChance = 0
	/// List of youtube URLs for lobby music to use during this holiday
	var/list/lobby_music = null

/*
 * NOTE FOR EVERYONE TRYING TO DO STUFF WHICH REQUIRES MAPPING, PLACING OBJECTS, ETC:
 * Holiday subsystem is loaded before mapping subsystem init, which means you can't place stuff before roundstart.
 * BUT:
 * /proc/handle_event() is invoked after master controller completed it's initialization,
 *  so that means you can manupulate objects and stuff in the world
 *
 * /proc/celebrate() is invoked before mapping subsystem init, so that means you can turn some flags, make
 * initializations of objects depending on which holiday we do celebrate and etc.
 * As an example, see /datum/holiday/new_year and /obj/effect/spawner/window/reinforced/Initialize
 */

/**
 * This proc gets run before the game starts when the holiday is activated.
 * Important note: it runs before mapping subsystem init, do not place/alter objects in world using this proc.
 */
/datum/holiday/proc/celebrate()
	return

/// When the round starts, this proc is ran to get a text message to display to everyone to wish them a happy holiday
/datum/holiday/proc/greet()
	return "Сегодняшний праздник — [name]!"

/// Returns special prefixes for the station name on certain days. You wind up with names like "Christmas Object Epsilon". See new_station_name()
/datum/holiday/proc/getStationPrefix()
	//get the first word of the Holiday and use that
	var/i = findtext(name," ",1,0)
	return copytext(name,1,i)

/// Return 1 if this holiday should be celebrated today
/datum/holiday/proc/shouldCelebrate(dd, mm, yy)
	if(!end_day)
		end_day = begin_day
	if(!end_month)
		end_month = begin_month

	if(end_month > begin_month) //holiday spans multiple months in one year
		if(mm == end_month) //in final month
			if(dd <= end_day)
				return TRUE

		else if(mm == begin_month)//in first month
			if(dd >= begin_day)
				return TRUE

		else if(mm in begin_month to end_month) //holiday spans 3+ months and we're in the middle, day doesn't matter at all
			return TRUE

	else if(end_month == begin_month) // starts and stops in same month, simplest case
		if(mm == begin_month && (dd in begin_day to end_day))
			return TRUE

	else // starts in one year, ends in the next
		if(mm >= begin_month && dd >= begin_day) // Holiday ends next year
			return TRUE
		if(mm <= end_month && dd <= end_day) // Holiday started last year
			return TRUE

	return FALSE

/**
 * Used for special holiday events. Called only after Master Controller has been loaded. (a.k.a initializations complete.)
 * Use this proc to manipulate objects and systems after MC load or mapload.
 */
/datum/holiday/proc/handle_event() //used for special holiday events
	return

// The actual holidays

GLOBAL_VAR_INIT(new_year_celebration, FALSE)

/datum/holiday/new_year
	name = NEW_YEAR
	begin_day = 18 // 13 days early
	begin_month = DECEMBER
	end_day = 10 //9 days extra
	end_month = JANUARY

/datum/holiday/new_year/celebrate()
	. = ..()
	GLOB.new_year_celebration = TRUE

/datum/holiday/xmas
	name = CHRISTMAS
	begin_day = 7
	begin_month = JANUARY
	eventChance = 20

/datum/holiday/xmas/greet()
	var/greeting = "Счастливого Рождества!"
	if(prob(30))
		greeting += "<br><br>В честь праздника выберите случайного члена экипажа из манифеста объекта и подарите ему подарок!"
	return greeting

/datum/holiday/groundhog
	name = "День сурка"
	begin_day = 2
	begin_month = FEBRUARY

/datum/holiday/valentines
	name = VALENTINES
	begin_day = 9 //6 days early
	begin_month = FEBRUARY
	end_day = 15 //1 day extra

/datum/holiday/random_kindness
	name = "День случайных добрых дел"
	begin_day = 17
	begin_month = FEBRUARY

/datum/holiday/random_kindness/greet()
	return "Сделайте кому-нибудь приятно!"

/datum/holiday/pi
	name = "День числа Пи"
	begin_day = 14
	begin_month = MARCH

/datum/holiday/no_this_is_patrick
	name = "День Святого Патрика"
	begin_day = 17
	begin_month = MARCH

/datum/holiday/april_fools
	name = APRIL_FOOLS
	begin_month = APRIL
	end_day = 8 //7 days extra so everyone can enjoy the festivities

/datum/holiday/fourtwenty
	name = "4/20"
	begin_day = 20
	begin_month = APRIL

/datum/holiday/earth
	name = "День Земли"
	begin_day = 22
	begin_month = APRIL

/datum/holiday/labor
	name = "День труда"
	begin_month = MAY

/datum/holiday/firefighter
	name = "День пожарного"
	begin_day = 4
	begin_month = MAY

// No holidays in June :'(

/datum/holiday/doctor
	name = "День врача"
	begin_month = JULY

/datum/holiday/UFO
	name = "День НЛО"
	begin_day = 2
	begin_month = JULY

/datum/holiday/writer
	name = "День писателя"
	begin_day = 8
	begin_month = JULY

/datum/holiday/friendship
	name = "День дружбы"
	begin_day = 30
	begin_month = JULY

/datum/holiday/friendship/greet()
	return "Пусть ваш [name] будет волшебным!"

/datum/holiday/beer
	name = "День пива"
	begin_day = 5
	begin_month = AUGUST

/datum/holiday/pirate
	name = "Международный день \"Говори как пират\""
	begin_day = 19
	begin_month = SEPTEMBER

/datum/holiday/pirate/greet()
	return "Сегодня ты, салага, будешь говорить как настоящий морской волк, а иначе пройдёшься по доске прямо за борт, якорь мне в бухту!"

/datum/holiday/questions
	name = "День глупых вопросов"
	begin_day = 28
	begin_month = SEPTEMBER

/datum/holiday/questions/greet()
	return "Вам нравится сегодняшний [name]?"

/datum/holiday/animal
	name = "День животных"
	begin_day = 4
	begin_month = OCTOBER

/datum/holiday/smile
	name = "День улыбки"
	begin_day = 7
	begin_month = OCTOBER

/datum/holiday/boss
	name = "День босса"
	begin_day = 16
	begin_month = OCTOBER

/datum/holiday/halloween
	name = HALLOWEEN
	begin_day = 24 //7 days early
	begin_month = OCTOBER
	end_day = 7 //7 days extra
	end_month = NOVEMBER

/datum/holiday/halloween/greet()
	return "Жутко весёлого Хэллоуина!"

/datum/holiday/vegan
	name = "День вегана"
	begin_month = NOVEMBER

/datum/holiday/kindness
	name = "День доброты"
	begin_day = 13
	begin_month = NOVEMBER

/datum/holiday/flowers
	name = "День цветов"
	begin_day = 19
	begin_month = NOVEMBER

/datum/holiday/hello
	name = "День \"Привет\""
	begin_day = 21
	begin_month = NOVEMBER

/datum/holiday/hello/greet()
	return "[pick(list("Алоха", "Чао", "Бонжур", "Коничива", "Привет", "Здравствуйте", "Приветствую", "Салют", "Ола", "Хауди", "Здарова", "Здравия желаю"))]! " + ..()

/datum/holiday/human_rights
	name = "День прав человека"
	begin_day = 10
	begin_month = DECEMBER

/datum/holiday/monkey
	name = "День обезьяны"
	begin_day = 14
	begin_month = DECEMBER

/datum/holiday/friday_thirteenth
	name = "Пятница, 13-е"

/datum/holiday/friday_thirteenth/shouldCelebrate(dd, mm, yy)
	if(dd == 13)
		if(time2text(world.timeofday, "DDD") == "Fri")
			return 1
	return 0

/datum/holiday/friday_thirteenth/getStationPrefix()
	return pick("Майк", "Пятница", "Злая", "Майерс", "Убийственная", "Смертельная")

/datum/holiday/easter
	name = EASTER
	var/const/days_early = 1 //to make editing the holiday easier
	var/const/days_extra = 6

/datum/holiday/easter/shouldCelebrate(dd, mm, yy)
// Easter's celebration day is as snowflakey as Uhangi's code

	if(!begin_month)

		var/yy_string = "[yy]"
// year = days after March 22that Easter falls on that year.
// For 2015 Easter is on April 5th, so 2015 = 14 since the 5th is 14 days past the 22nd
// If it's 2040 and this is still in use, invent a time machine and teach me a better way to do this. Also tell us about HL3.
		var/list/easters = list(
		"15" = 14,\
		"16" = 6,\
		"17" = 25,\
		"18" = 10,\
		"19" = 30,\
		"20" = 22,\
		"21" = 13,\
		"22" = 26,\
		"23" = 18,\
		"24" = 9,\
		"25" = 29,\
		"26" = 14,\
		"27" = 6,\
		"28" = 25,\
		"29" = 10,\
		"30" = 30,\
		"31" = 23,\
		"32" = 6,\
		"33" = 26,\
		"34" = 18,\
		"35" = 3,\
		"36" = 22,\
		"37" = 14,\
		"38" = 34,\
		"39" = 19,\
		"40" = 9,\
		)

		begin_day = easters[yy_string]
		if(begin_day <= 9)
			begin_day += 22
			begin_month = MARCH
		else
			begin_day -= 9
			begin_month = APRIL

		end_day = begin_day + days_extra
		end_month = begin_month
		if(end_day >= 32 && end_month == MARCH) //begins in march, ends in april
			end_day -= 31
			end_month++
		if(end_day >= 31 && end_month == APRIL) //begins in april, ends in june
			end_day -= 30
			end_month++

		begin_day -= days_early
		if(begin_day <= 0)
			if(begin_month == APRIL)
				begin_day += 31
				begin_month-- //begins in march, ends in april

//	to_chat(world, "Easter calculates to be on [begin_day] of [begin_month] ([days_early] early) to [end_day] of [end_month] ([days_extra] extra) for 20[yy]")
	return ..()

ADMIN_VERB(set_holiday, R_SERVER, "Задать праздник", "Принудительно задать переменную \"Праздник\", чтобы игра считала, что сегодня определённый день.", ADMIN_CATEGORY_EVENTS, T as text|null)
	var/list/choice = list()
	for(var/H in subtypesof(/datum/holiday))
		choice += "[H]"

	choice += "ОТМЕНА"
	var/selected = tgui_input_list(user, "Какой праздник вы хотите зафорсить?", "Форс праздника", choice, "ОТМЕНА")

	if(selected == "ОТМЕНА")
		return

	var/selected2path = text2path(selected)
	if(!ispath(selected2path) || !selected2path)
		return

	var/datum/holiday/H = new selected2path
	if(!istype(H))
		return

	H.celebrate()
	if(!SSholiday.holidays)
		SSholiday.holidays = list()
	SSholiday.holidays[H.name] = H

	//update our hub status
	world.update_status()

	message_admins(span_notice("ADMIN: Event: [key_name_admin(user)] force-set Holiday to \"[H]\""))
	log_admin("[key_name(user)] force-set Holiday to \"[H]\"")
