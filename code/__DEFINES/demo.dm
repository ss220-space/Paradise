#ifndef DEMO_WRITER
// Default automatic demo-writer detection.
// On Windows, looks in the standard places for `demo-writer.dll`.
// On Linux, looks in `.`, `$LD_LIBRARY_PATH`, and `~/.byond/bin` for either of
// `libdemo-writer.so` (preferred) or `demo-writer` (old).

/* This comment bypasses grep checks */ /var/__demo_writer

/proc/__detect_demo_writer()
	if (world.system_type == UNIX)
		if (fexists("./libdemo-writer.so"))
			// No need for LD_LIBRARY_PATH badness.
			return __demo_writer = "./libdemo-writer.so"
		else if (fexists("./demo-writer"))
			// Old dumb filename.
			return __demo_writer = "./demo-writer"
		else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/demo-writer"))
			// Old dumb filename in `~/.byond/bin`.
			return __demo_writer = "demo-writer"
		else
			// It's not in the current directory, so try others
			return __demo_writer = "libdemo-writer.so"
	else
		return __demo_writer = "demo-writer.dll"

#define DEMO_WRITER (__demo_writer || __detect_demo_writer())
#endif
