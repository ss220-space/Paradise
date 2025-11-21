#define MILLISECONDS *0.01

#define DECISECONDS *1 //the base unit all of these defines are scaled by, because byond uses that as a unit of measurement for some fucking reason

// So you can be all 10 SECONDS
#define SECONDS *10

#define MINUTES SECONDS*60

#define HOURS MINUTES*60

#define TICKS *world.tick_lag

#define MS2DS(T) ((T) MILLISECONDS)

#define DS2MS(T) ((T) * 100)

#define SECONDS_TO_LIFE_CYCLES /2

#define DS2TICKS(DS) ((DS)/world.tick_lag)

#define TICKS2DS(T) ((T) TICKS)

#define ROUND_TIME_TEXT(...) ( "[world.time - SSticker.round_start_time > MIDNIGHT_ROLLOVER ? "[round((world.time - SSticker.round_start_time)/MIDNIGHT_ROLLOVER)]:[worldtime2text()]" : worldtime2text()]" )

#define SHIFT_TIME_TEXT(...) ( "[SSticker.round_start_time > MIDNIGHT_ROLLOVER ? "[round(SSticker.round_start_time/MIDNIGHT_ROLLOVER)]:[shifttime2text()]" : shifttime2text()]" )

/* This proc should only be used for world/Topic.
 * If you want to display the time for which dream daemon has been running ("round time") use worldtime2text.
 * If you want to display the canonical station "time" (aka the in-character time of the station) use station_time_timestamp
 */
/proc/classic_worldtime2text(time = world.time)
	time = (SSticker.round_start_time ? (time - SSticker.round_start_time) : (time - world.time))
	return "[round(time / 36000)+12]:[(time / 600 % 60) < 10 ? add_zero(time / 600 % 60, 1) : time / 600 % 60]"

//Returns the world time in english
/proc/worldtime2text()
	return gameTimestamp("hh:mm:ss", world.time)

//Returns the world time in english
/proc/roundtime2text()
	return gameTimestamp("hh:mm:ss", world.time - SSticker.time_game_started)

/proc/shifttime2text()
	return gameTimestamp("hh:mm:ss", world.time - SSticker.round_start_time)

// This is ISO-8601
// If anything that uses this proc shouldn't be ISO-8601, change that thing, not this proc. This is important for logging.
/proc/time_stamp()
	var/date_portion = time2text(world.timeofday, "YYYY-MM-DD")
	var/time_portion = time2text(world.timeofday, "hh:mm:ss")
	return "[date_portion]T[time_portion]"

/proc/gameTimestamp(format = "hh:mm:ss", wtime=null)
	if(wtime == null)
		wtime = world.time
	return time2text(wtime - GLOB.timezoneOffset, format)

/proc/deciseconds_to_time_stamp(deciseconds)
	if(istext(deciseconds))
		deciseconds = text2num(deciseconds)
	var/hour_calc = round(deciseconds / 36000) < 10 ? add_zero(round(deciseconds / 36000), 1) : round(deciseconds / 36000)
	var/minute_calc = round((deciseconds % 36000) / 600) < 10 ? add_zero(round((deciseconds % 36000) / 600), 1) : round((deciseconds % 36000) / 600)
	var/second_calc = round(((deciseconds % 36000) % 600) / 10) < 10 ? add_zero(round(((deciseconds % 36000) % 600) / 10), 1) : round(((deciseconds % 36000) % 600) / 10)

	return "[hour_calc]:[minute_calc]:[second_calc]"

// max hh:mm:ss supported
/proc/timeStampToNum(timestamp)
	var/list/splits = text2numlist(timestamp, ":")
	. = 0
	var/split_len = length(splits)
	for(var/i = 1 to length(splits))
		switch(split_len - i)
			if(2)
				. += splits[i] HOURS
			if(1)
				. += splits[i] MINUTES
			if(0)
				. += splits[i] SECONDS

/* This is used for displaying the "station time" equivelent of a world.time value
* Calling it with no args will give you the current time, but you can specify a world.time-based value as an argument
* - You can use this, for example, to do "This will expire at [station_time_at(world.time + 500)]" to display a "station time" expiration date
*   which is much more useful for a player)*/
/proc/station_time(time=world.time, display_only=FALSE)
	return ((((time - SSticker.round_start_time)) + GLOB.gametime_offset) % 864000) - (display_only ? GLOB.timezoneOffset : 0)

/proc/station_time_timestamp(format = "hh:mm:ss", time=world.time)
	return time2text(station_time(time, TRUE), format)

/* Returns 1 if it is the selected month and day */
/proc/isDay(month, day)
	if(isnum(month) && isnum(day))
		var/MM = text2num(time2text(world.timeofday, "MM")) // get the current month
		var/DD = text2num(time2text(world.timeofday, "DD")) // get the current day
		if(month == MM && day == DD)
			return 1

		// Uncomment this out when debugging!
		//else
			//return 1

//returns timestamp in a sql and ISO 8601 friendly format
/proc/SQLtime()
	return time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")

/**
 * Returns "watch handle" (really just a timestamp :V)
 */
/proc/start_watch()
	return REALTIMEOFDAY

/**
 * Returns number of seconds elapsed.
 * @param wh number The "Watch Handle" from start_watch(). (timestamp)
 */
/proc/stop_watch(wh)
	return round(0.1 * (REALTIMEOFDAY - wh), 0.1)

/proc/numberToMonthName(number)
	return GLOB.month_names.Find(number)

//Take a value in seconds and returns a string of minutes and seconds in the format X minute(s) and X seconds.
/proc/seconds_to_time(seconds as num)
	var/numSeconds = seconds % 60
	var/numMinutes = (seconds - numSeconds) / 60
	return "[numMinutes] [numMinutes > 1 ? "minutes" : "minute"] and [numSeconds] seconds"

//Take a value in seconds and makes it display like a clock
/proc/seconds_to_clock(seconds as num)
	return "[add_zero(num2text((seconds / 60) % 60), 2)]:[add_zero(num2text(seconds % 60), 2)]"

///Takes a value of time in deciseconds.
///Returns a text value of that number in hours, minutes, or seconds.
/proc/DisplayTimeText(time_value, round_seconds_to = 0.1)
	var/second = FLOOR(time_value * 0.1, round_seconds_to)
	if(!second)
		return "right now"
	if(second < 60)
		return "[second] second[(second != 1)? "s":""]"
	var/minute = FLOOR(second / 60, 1)
	second = FLOOR(MODULUS(second, 60), round_seconds_to)
	var/secondT
	if(second)
		secondT = " and [second] second[(second != 1)? "s":""]"
	if(minute < 60)
		return "[minute] minute[(minute != 1)? "s":""][secondT]"
	var/hour = FLOOR(minute / 60, 1)
	minute = MODULUS(minute, 60)
	var/minuteT
	if(minute)
		minuteT = " and [minute] minute[(minute != 1)? "s":""]"
	if(hour < 24)
		return "[hour] hour[(hour != 1)? "s":""][minuteT][secondT]"
	var/day = FLOOR(hour / 24, 1)
	hour = MODULUS(hour, 24)
	var/hourT
	if(hour)
		hourT = " and [hour] hour[(hour != 1)? "s":""]"
	return "[day] day[(day != 1)? "s":""][hourT][minuteT][secondT]"

GLOBAL_VAR_INIT(midnight_rollovers, 0)
GLOBAL_VAR_INIT(rollovercheck_last_timeofday, 0)
/proc/update_midnight_rollover()
	if(world.timeofday < GLOB.rollovercheck_last_timeofday) //TIME IS GOING BACKWARDS!
		GLOB.midnight_rollovers++
	GLOB.rollovercheck_last_timeofday = world.timeofday
	return GLOB.midnight_rollovers
