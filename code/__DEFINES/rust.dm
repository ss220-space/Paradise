// DM API for Rust extension modules

// Default automatic library detection.
// Look for it in the build location first, then in `.`, then in standard places.

/* This comment bypasses grep checks */ /var/__rustlib

// This works by allowing rust to compile with modern x86 instructionns, instead of compiling for a pentium 4
// This has the potential for significant speed upgrades with SIMD and similar

#ifdef PARADISE_PRODUCTION_HARDWARE
#define RUSTLIBS_SUFFIX "_prod"
#else
#define RUSTLIBS_SUFFIX ""
#endif

/proc/__detect_rustlib()
	var/version_suffix = "515"
	if(world.byond_build >= 1651)
		version_suffix = "516"

	if(world.system_type == UNIX)
#ifdef CIBUILDING
		// CI override, use librustlibs_ci.so if possible.
		if(fexists("./tools/ci/librustlibs_ci_[version_suffix].so"))
			return __rustlib = "tools/ci/librustlibs_ci_[version_suffix].so"
#endif
		// First check if it's built in the usual place.
		// Linx doesnt get the version suffix because if youre using linux you can figure out what server version youre running for
		if(fexists("./rust/target/i686-unknown-linux-gnu/release/librustlibs[RUSTLIBS_SUFFIX].so"))
			return __rustlib = "./rust/target/i686-unknown-linux-gnu/release/librustlibs[RUSTLIBS_SUFFIX].so"
		// Then check in the current directory.
		if(fexists("./librustlibs_[version_suffix][RUSTLIBS_SUFFIX].so"))
			return __rustlib = "./librustlibs_[version_suffix][RUSTLIBS_SUFFIX].so"

		if(fexists("./librustlibs[RUSTLIBS_SUFFIX].so"))
			return __rustlib = "./librustlibs[RUSTLIBS_SUFFIX].so"

		if(fexists("librustlibs[RUSTLIBS_SUFFIX].so"))

			return __rustlib = "librustlibs[RUSTLIBS_SUFFIX].so"
		// And elsewhere.
		return __rustlib = "librustlibs.so"
	else
		// First check if it's built in the usual place.
		if(fexists("./rust/target/i686-pc-windows-msvc/release/rustlibs.dll"))
			return __rustlib = "./rust/target/i686-pc-windows-msvc/release/rustlibs.dll"
		// Then check in the current directory.
		if(fexists("./rustlibs_[version_suffix].dll"))
			return __rustlib = "./rustlibs_[version_suffix].dll"

		if(fexists("./rustlibs.dll"))
			return __rustlib = "./rustlibs.dll"

		// And elsewhere.
		var/assignment_confirmed = (__rustlib = "rustlibs_[version_suffix].dll")
		// This being spanned over multiple lines is kinda scuffed, but its needed because of https://www.byond.com/forum/post/2072419
		return assignment_confirmed

#define RUSTLIB (__rustlib || __detect_rustlib())
#define RUSTLIB_CALL(func, args...) call_ext(RUSTLIB, "byond:[#func]_ffi")(args)

/// Exists by default in 516, but needs to be defined for 515 or byondapi-rs doesn't like it.
/proc/byondapi_stack_trace(err)
	CRASH(err)

#define rustlib_file_read(fname) RUSTLIB_CALL(file_read,  fname)
#define rustlib_file_exists(fname) (RUSTLIB_CALL(file_exists,  fname) == "true")
#define rustlib_file_write(text, fname) RUSTLIB_CALL(file_write, text,  fname)
#define rustlib_file_append(text, fname) RUSTLIB_CALL(file_append, text,  fname)
#define rustlib_file_get_line_count(fname) text2num(RUSTLIB_CALL(file_get_line_count,  fname))
#define rustlib_file_seek_line(fname, line) RUSTLIB_CALL(file_seek_line,  fname, "[line]")

/**
 * Get the dmi metadata of the file located at `fname`.
 * Returns a list in the metadata format listed above, or an error message.
 */
#define rustlib_dmi_read_metadata(fname) json_decode(RUSTLIB_CALL(dmi_read_metadata,  fname))
/**
 * Inject dmi metadata into a png file located at `path`.
 * `metadata` must be a json_encode'd list in the metadata format listed above.
 */
#define rustlib_dmi_inject_metadata(path, metadata) RUSTLIB_CALL(dmi_inject_metadata, path, metadata)
#define rustlib_dmi_strip_metadata(fname) RUSTLIB_CALL(dmi_strip_metadata, fname)
#define rustlib_dmi_create_png(path, width, height, data) RUSTLIB_CALL(dmi_create_png, path, width, height, data)
#define rustlib_dmi_resize_png(path, width, height, resizetype) RUSTLIB_CALL(dmi_resize_png, path, width, height, resizetype)
/**
 * input: must be a path, not an /icon; you have to do your own handling if it is one, as icon objects can't be directly passed to rustg.
 *
 * output: icon_states list.
 */
#define rustlib_dmi_icon_states(fname) RUSTLIB_CALL(dmi_icon_states, fname)

#define rustlib_hash_string(algorithm, text) RUSTLIB_CALL(hash_string, algorithm, text)
#define rustlib_hash_file(algorithm, fname) RUSTLIB_CALL(hash_file, algorithm, fname)
#define rustlib_hash_generate_totp(seed)RUSTLIB_CALL(generate_totp, seed)
#define rustlib_hash_generate_totp_tolerance(seed, tolerance) RUSTLIB_CALL(generate_totp_tolerance, seed, tolerance)

#define RUSTLIB_HASH_MD5 "md5"
#define RUSTLIB_HASH_SHA1 "sha1"
#define RUSTLIB_HASH_SHA256 "sha256"
#define RUSTLIB_HASH_SHA512 "sha512"
#define RUSTLIB_HASH_XXH64 "xxh64"
#define RUSTLIB_HASH_BASE64 "base64"

/// Encode a given string into base64
#define rustlib_encode_base64(str) rustlib_hash_string(RUSTLIB_HASH_BASE64, str)
/// Decode a given base64 string
#define rustlib_decode_base64(str) RUSTLIB_CALL(decode_base64, str)

#ifdef RUSTLIB_OVERRIDE_BUILTINS
	#define md5(thing) (isfile(thing) ? rustlib_hash_file(RUSTLIB_HASH_MD5, "[thing]") : rustlib_hash_string(RUSTLIB_HASH_MD5, thing))
#endif


/// Generates a spritesheet at: [file_path][spritesheet_name]_[size_id].[png or dmi]
/// The resulting spritesheet arranges icons in a random order, with the position being denoted in the "sprites" return value.
/// All icons have the same y coordinate, and their x coordinate is equal to `icon_width * position`.
///
/// hash_icons is a boolean (0 or 1), and determines if the generator will spend time creating hashes for the output field dmi_hashes.
/// These hashes can be helpful for 'smart' caching (see rustg_iconforge_cache_valid), but require extra computation.
///
/// generate_dmi is a boolean (0 or 1), and determines if the generator will save the sheet as a DMI or stripped PNG file.
/// DMI files can be used to replace bulk Insert() operations, PNGs are more useful for asset transport or UIs. DMI generation is slower due to more metadata.
/// flatten is a boolean (0 or 1), and determines if the DMI output will be flattened to a single frame/dir if unscoped (null/0 dir or frame values).
/// PNGs are always flattened, regardless of argument.
///
/// Spritesheet will contain all sprites listed within "sprites".
/// "sprites" format:
/// list(
///		"sprite_name" = list( // <--- this list is a [SPRITE_OBJECT]
///			icon_file = 'icons/path_to/an_icon.dmi',
///			icon_state = "some_icon_state",
///			dir = SOUTH,
///			frame = 1,
///			transform = list([TRANSFORM_OBJECT], ...)
///		),
///		...,
/// )
/// TRANSFORM_OBJECT format:
/// list("type" = RUSTLIB_ICONFORGE_BLEND_COLOR, "color" = "#ff0000", "blend_mode" = ICON_MULTIPLY)
/// list("type" = RUSTLIB_ICONFORGE_BLEND_ICON, "icon" = [SPRITE_OBJECT], "blend_mode" = ICON_OVERLAY, "x" = 1, "y" = 1) // offsets optional
/// list("type" = RUSTLIB_ICONFORGE_SCALE, "width" = 32, "height" = 32)
/// list("type" = RUSTLIB_ICONFORGE_CROP, "x1" = 1, "y1" = 1, "x2" = 32, "y2" = 32) // (BYOND icons index from 1,1 to the upper bound, inclusive)
/// list("type" = RUSTLIB_ICONFORGE_MAP_COLORS, "rr" = 0.5, "rg" = 0.5, "rb" = 0.5, "ra" = 1, "gr" = 1, "gg" = 1, "gb" = 1, "ga" = 1, ...) // alpha arguments and rgba0 optional
/// list("type" = RUSTLIB_ICONFORGE_FLIP, "dir" = SOUTH)
/// list("type" = RUSTLIB_ICONFORGE_TURN, "angle" = 90.0)
/// list("type" = RUSTLIB_ICONFORGE_SHIFT, "dir" = EAST, "offset" = 10, "wrap" = FALSE)
/// list("type" = RUSTLIB_ICONFORGE_SWAP_COLOR, "src_color" = "#ff0000", "dst_color" = "#00ff00") // alpha bits supported
/// list("type" = RUSTLIB_ICONFORGE_DRAW_BOX, "color" = "#ff0000", "x1" = 1, "y1" = 1, "x2" = 32, "y2" = 32) // alpha bits supported. color can be null/omitted for transparency. x2 and y2 will default to x1 and y1 if omitted
///
/// Returns a SpritesheetResult as JSON, containing fields:
///	list(
///		"sizes" = list("32x32", "64x64", ...),
///		"sprites" = list("sprite_name" = list("size_id" = "32x32", "position" = 0), ...),
///		"dmi_hashes" = list("icons/path_to/an_icon.dmi" = "d6325c5b4304fb03", ...),
///		"sprites_hash" = "a2015e5ff403fb5c", // This is the xxh64 hash of the INPUT field "sprites".
///		"error" = "[A string, empty if there were no errors.]",
///	)
/// In the case of an unrecoverable panic from within Rust, this function ONLY returns a string containing the error.
#define rustlib_iconforge_generate(file_path, spritesheet_name, sprites, hash_icons, generate_dmi, flatten) RUSTLIB_CALL(iconforge_generate, file_path, spritesheet_name, sprites, hash_icons, generate_dmi, flatten)
/// Returns a job_id for use with rustlib_iconforge_check()
#define rustlib_iconforge_generate_async(file_path, spritesheet_name, sprites, hash_icons, generate_dmi, flatten) RUSTLIB_CALL(iconforge_generate_async, file_path, spritesheet_name, sprites, hash_icons, generate_dmi, flatten)
/// Returns the status of an async job_id, or its result if it is completed. See RUSTG_JOB DEFINEs.
#define rustlib_iconforge_check(job_id) RUSTLIB_CALL(iconforge_check, job_id)
/// Clears all cached DMIs and images, freeing up memory.
/// This should be used after spritesheets are done being generated.
#define rustlib_iconforge_cleanup(...) RUSTLIB_CALL(iconforge_cleanup)
/// Takes in a set of hashes, generate inputs, and DMI filepaths, and compares them to determine cache validity.
/// input_hash: xxh64 hash of "sprites" from the cache.
/// dmi_hashes: xxh64 hashes of the DMIs in a spritesheet, given by `rustlib_iconforge_generate` with `hash_icons` enabled. From the cache.
/// sprites: The new input that will be passed to rustlib_iconforge_generate().
/// Returns a CacheResult with the following structure: list(
///		"result": "1" (if cache is valid) or "0" (if cache is invalid)
///		"fail_reason": "" (emtpy string if valid, otherwise a string containing the invalidation reason or an error with ERROR: prefixed.)
/// )
/// In the case of an unrecoverable panic from within Rust, this function ONLY returns a string containing the error.
#define rustlib_iconforge_cache_valid(input_hash, dmi_hashes, sprites) RUSTLIB_CALL(iconforge_cache_valid, input_hash, dmi_hashes, sprites)
/// Returns a job_id for use with rustlib_iconforge_check()
#define rustlib_iconforge_cache_valid_async(input_hash, dmi_hashes, sprites) RUSTLIB_CALL(iconforge_cache_valid_async, input_hash, dmi_hashes, sprites)
/// Provided a /datum/greyscale_config typepath, JSON string containing the greyscale config, and path to a DMI file containing the base icons,
/// Loads that config into memory for later use by rustlib_iconforge_gags(). The config_path is the unique identifier used later.
/// JSON Config schema: https://hackmd.io/@tgstation/GAGS-Layer-Types
/// Adding dirs or frames (via blending larger icons) to icons with more than 1 dir or 1 frame is not supported.
/// Returns "OK" if successful, otherwise, returns a string containing the error.
#define rustlib_iconforge_load_gags_config(config_path, config_json, config_icon_path) RUSTLIB_CALL(iconforge_load_gags_config, "[config_path]", config_json, config_icon_path)
/// Given a config_path (previously loaded by rustlib_iconforge_load_gags_config), and a string of hex colors formatted as "#ff00ff#ffaa00"
/// Outputs a DMI containing all of the states within the config JSON to output_dmi_path, creating any directories leading up to it if necessary.
/// Returns "OK" if successful, otherwise, returns a string containing the error.
#define rustlib_iconforge_gags(config_path, colors, output_dmi_path) RUSTLIB_CALL(iconforge_gags, "[config_path]", colors, output_dmi_path)
/// Returns a job_id for use with rustlib_iconforge_check()
#define rustlib_iconforge_load_gags_config_async(config_path, config_json, config_icon_path) RUSTLIB_CALL(iconforge_load_gags_config_async, "[config_path]", config_json, config_icon_path)
/// Returns a job_id for use with rustlib_iconforge_check()
#define rustlib_iconforge_gags_async(config_path, colors, output_dmi_path) RUSTLIB_CALL(iconforge_gags_async, "[config_path]", colors, output_dmi_path)

#define RUSTLIB_ICONFORGE_BLEND_COLOR "BlendColor"
#define RUSTLIB_ICONFORGE_BLEND_ICON "BlendIcon"
#define RUSTLIB_ICONFORGE_CROP "Crop"
#define RUSTLIB_ICONFORGE_SCALE "Scale"
#define RUSTLIB_ICONFORGE_MAP_COLORS "MapColors"
#define RUSTLIB_ICONFORGE_FLIP "Flip"
#define RUSTLIB_ICONFORGE_TURN "Turn"
#define RUSTLIB_ICONFORGE_SHIFT "Shift"
#define RUSTLIB_ICONFORGE_SWAP_COLOR "SwapColor"
#define RUSTLIB_ICONFORGE_DRAW_BOX "DrawBox"

// MARK: Jobs
#define RUSTLIBS_JOB_NO_RESULTS_YET "NO RESULTS YET"
#define RUSTLIBS_JOB_NO_SUCH_JOB "NO SUCH JOB"
#define RUSTLIBS_JOB_ERROR "JOB PANICKED"

/// Provided a static RSC file path or a raw text file path, returns the duration of the file in deciseconds as a float.
/proc/rustlib_sound_length(file_path)
	var/static/list/sound_cache
	if(isnull(sound_cache))
		sound_cache = list()

	. = 0

	if(!istext(file_path))
		if(!isfile(file_path))
			CRASH("rustg_sound_length error: Passed non-text object")

		if(length("[file_path]")) // Runtime generated RSC references stringify into 0-length strings.
			file_path = "[file_path]"
		else
			CRASH("rustg_sound_length does not support non-static file refs.")

	var/cached_length = sound_cache[file_path]
	if(!isnull(cached_length))
		return cached_length

	var/ret = RUSTLIB_CALL(sound_len, file_path)
	if(isnull(ret))
		. = 0
		CRASH("rustg_sound_length error: [ret]")

	sound_cache[file_path] = ret
	return ret


#define RUSTG_SOUNDLEN_SUCCESSES "successes"
#define RUSTG_SOUNDLEN_ERRORS "errors"
/**
 * Returns a nested key-value list containing "successes" and "errors"
 * The format is as follows:
 * list(
 *  RUSTG_SOUNDLEN_SUCCESES = list("sounds/test.ogg" = 25.34),
 *  RUSTG_SOUNDLEN_ERRORS = list("sound/bad.png" = "SoundLen: Unable to decode file."),
 *)
*/
#define rustlib_sound_length_list(file_paths) RUSTLIB_CALL(sound_len_list, file_paths)

/proc/get_rustlib_version()
	return __rustlib
