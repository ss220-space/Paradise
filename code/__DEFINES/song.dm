#define MUSICIAN_HEARCHECK_MINDELAY 4
#define MUSIC_MAXLINES 1000
#define MUSIC_MAXLINECHARS 300

#define BPM_TO_TEMPO_SETTING(value) (600 / round(value, 1))

//Return values of song/should_stop_playing()

///When the song should stop being played
#define STOP_PLAYING 1
///Will ignore the instrument checks and play the song anyway.
#define IGNORE_INSTRUMENT_CHECKS 2
