#define TTS_TRAIT_PITCH_WHISPER (1<<1)
#define TTS_TRAIT_RATE_FASTER (1<<2)
#define TTS_TRAIT_RATE_MEDIUM (1<<3)

/// How long SStts waits for the TTS effects service before falling back to the shell ffmpeg call.
#define TTS_EFFECTS_REQUEST_TIMEOUT (20 SECONDS)
