#define MILLISECONDS *0.01

#define DECISECONDS *1 //the base unit all of these defines are scaled by, because byond uses that as a unit of measurement for some fucking reason

#define SECONDS *10

#define MINUTES SECONDS*60

#define HOURS MINUTES*60

#define DAYS HOURS*24
#define YEARS DAYS*365 //fuck leap days, they were removed in 2069

#define TICKS *world.tick_lag

#define DS2TICKS(DS) ((DS)/world.tick_lag)

#define TICKS2DS(T) ((T) TICKS)

#define MS2DS(T) ((T) MILLISECONDS)

#define DS2MS(T) ((T) * 100)

#define ROUND_TIME_TEXT(...) ( "[world.time - SSticker.round_start_time > MIDNIGHT_ROLLOVER ? "[round((world.time - SSticker.round_start_time)/MIDNIGHT_ROLLOVER)]:[worldtime2text()]" : worldtime2text()]" )

#define SHIFT_TIME_TEXT(...) ( "[SSticker.round_start_time > MIDNIGHT_ROLLOVER ? "[round(SSticker.round_start_time/MIDNIGHT_ROLLOVER)]:[shifttime2text()]" : shifttime2text()]" )
