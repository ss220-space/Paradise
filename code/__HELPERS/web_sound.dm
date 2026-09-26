/**
 * Metadata about a web sound resolved through yt-dlp.
 *
 * Produced by [/proc/get_web_sound_info]. Resolving metadata never downloads
 * the audio file - that happens later, as a step of building the music asset.
 */
/datum/web_sound_info
	/// Whether yt-dlp ran and its JSON output was parsed successfully.
	var/success = FALSE
	/// Human readable failure reason (yt-dlp stderr or a JSON parse error).
	var/error_message
	/// Site specific media id, used to build the cached file name.
	var/id
	/// Direct stream url of the selected audio format.
	var/url
	/// Display title of the track.
	var/title
	/// Url of the page the track was taken from.
	var/webpage_url
	/// Track length in seconds.
	var/duration
	/// Track artist, if reported.
	var/artist
	/// Upload date, if reported.
	var/upload_date
	/// Album name, if reported.
	var/album

/**
 * Result of downloading a web sound through yt-dlp.
 *
 * Produced by [/proc/download_web_sound] when a music asset is created.
 */
/datum/web_sound_download
	/// Whether the audio file was downloaded successfully.
	var/success = FALSE
	/// Human readable failure reason (yt-dlp stderr).
	var/error_message
	/// Path to the downloaded mp3 on disk.
	var/file_path

/// Shared yt-dlp flags for both metadata lookup and downloading.
#define YTDL_COMMON_ARGS "-x --audio-format mp3 --audio-quality 0 --geo-bypass --no-playlist"

/**
 * Resolves metadata for a web sound without downloading it.
 *
 * Runs yt-dlp in simulate mode and returns a [/datum/web_sound_info] describing
 * the track. No audio file is written to disk.
 *
 * Arguments:
 * * ytdl - the configured yt-dlp invocation string.
 * * url - the page url to resolve.
 */
/proc/get_web_sound_info(ytdl, url)
	var/datum/web_sound_info/info = new
	var/scrubbed_url = shell_url_scrub(url)
	var/list/output = world.shelleo("[ytdl] [YTDL_COMMON_ARGS] --dump-single-json --simulate \"[scrubbed_url]\"")
	if(output[SHELLEO_ERRORLEVEL])
		info.error_message = output[SHELLEO_STDERR]
		return info

	var/list/data
	try
		data = json_decode(output[SHELLEO_STDOUT])
	catch(var/exception/parse_exception)
		info.error_message = "[parse_exception]: [output[SHELLEO_STDOUT]]"
		return info

	info.success = TRUE
	info.id = data["id"]
	info.url = data["url"]
	info.title = data["title"]
	info.webpage_url = data["webpage_url"]
	info.duration = data["duration"]
	info.artist = data["artist"]
	info.upload_date = data["upload_date"]
	info.album = data["album"]
	return info

/**
 * Downloads a web sound into the songs cache.
 *
 * Runs yt-dlp without simulate, extracting the audio to
 * cache/songs/[sound_id].mp3, and returns a [/datum/web_sound_download].
 *
 * Arguments:
 * * ytdl - the configured yt-dlp invocation string.
 * * url - the page url to download from.
 * * sound_id - the media id from [/datum/web_sound_info], used to locate the result.
 */
/proc/download_web_sound(ytdl, url, sound_id)
	var/datum/web_sound_download/download = new
	var/scrubbed_url = shell_url_scrub(url)
	var/list/output = world.shelleo("[ytdl] [YTDL_COMMON_ARGS] -o \"cache/songs/%(id)s.%(ext)s\" \"[scrubbed_url]\"")
	if(output[SHELLEO_ERRORLEVEL])
		download.error_message = output[SHELLEO_STDERR]
		return download

	download.success = TRUE
	download.file_path = "cache/songs/[sound_id].mp3"
	return download

#undef YTDL_COMMON_ARGS
