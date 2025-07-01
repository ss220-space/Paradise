// DM API for Rust extension modules


// Default automatic library detection.
// Look for it in the build location first, then in `.`, then in standard places.

/* This comment bypasses grep checks */ /var/__rustlib

/proc/__detect_rustlib()
	if(world.system_type == UNIX)
		// First check if it's built in the usual place.
		if(fexists("./rust/target/i686-unknown-linux-gnu/release/librustlibs.so"))
			return __rustlib = "./rust/target/i686-unknown-linux-gnu/release/librustlibs.so"
		// Then check in the current directory.
		if(fexists("./librustlibs.so"))
			return __rustlib = "./librustlibs.so"
		// And elsewhere.
		return __rustlib = "librustlibs.so"
	// First check if it's built in the usual place.
	if(fexists("./rust/target/i686-pc-windows-gnu/release/rustlibs.dll"))
		return __rustlib = "./rust/target/i686-pc-windows-gnu/release/rustlibs.dll"
	// Then check in the current directory.
	if(fexists("./rustlibs.dll"))
		return __rustlib = "./rustlibs.dll"
		// And elsewhere.
	return __rustlib = "rustlibs.dll"

#define RUSTLIB (__rustlib || __detect_rustlib())
#define RUSTLIB_CALL(func, args...) call_ext(RUSTLIB, "byond:[#func]_ffi")(args)

/// Exists by default in 516, but needs to be defined for 515 or byondapi-rs doesn't like it.
/proc/byondapi_stack_trace(err)
	CRASH(err)
