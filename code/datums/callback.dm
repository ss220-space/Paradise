/**
 * # Callback Datums
 * A datum that holds a proc to be called on another object, used to track proccalls to other objects
 *
 * ## USAGE
 *
 * ```
 * var/datum/callback/C = new(object|null, PROC_REF(procname), arg1, arg2, ... argn)
 * var/timerid = addtimer(C, time, timertype)
 * you can also use the compiler define shorthand
 * var/timerid = addtimer(CALLBACK(object|null, PROC_REF(procname), arg1, arg2, ... argn), time, timertype)
 * ```
 *
 * Note: proc strings can only be given for datum proc calls, global procs must be proc paths
 *
 * Also proc strings are strongly advised against because they don't compile error if the proc stops existing
 *
 * In some cases you can provide a shortform of the procname, see the proc typepath shortcuts documentation below
 *
 * ## INVOKING THE CALLBACK
 * `var/result = C.Invoke(args, to, add)` additional args are added after the ones given when the callback was created
 *
 * `var/result = C.InvokeAsync(args, to, add)` Asyncronous - returns . on the first sleep then continues on in the background
 * after the sleep/block ends, otherwise operates normally.
 *
 * ## PROC TYPEPATH SHORTCUTS
 * (these operate on paths, not types, so to these shortcuts, datum is NOT a parent of atom, etc...)
 *
 * ### proc defined on current(src) object OR overridden at src or any of its parents:
 * PROC_REF(procname)
 *
 * `CALLBACK(src, PROC_REF(some_proc_here))`
 *
 * ### global proc
 * GLOBAL_PROC_REF(procname)
 *
 * `CALLBACK(src, GLOBAL_PROC_REF(some_proc_here))`
 *
 *
 * ### proc defined on some type
 * TYPE_PROC_REF(/some/type/, some_proc_here)
 */
/datum/callback
	///The object we will be calling the proc on
	var/datum/object = GLOBAL_PROC
	///The proc we will be calling on the object
	var/delegate
	///A list of arguments to pass into the proc
	var/list/arguments
	///A weak reference to the user who triggered this callback
	var/datum/weakref/user

/**
 * Create a new callback datum
 *
 * Arguments
 * * thingtocall the object to call the proc on
 * * proctocall the proc to call on the target object
 * * ... an optional list of extra arguments to pass to the proc
 */
/datum/callback/New(thingtocall, proctocall, ...)
	if(thingtocall)
		object = thingtocall
	delegate = proctocall
	if(length(args) > 2)
		arguments = args.Copy(3)
	if(usr)
		user = WEAKREF(usr)

/**
 * Invoke this callback
 *
 * Calls the registered proc on the registered object, if the user ref
 * can be resolved it also inclues that as an arg
 */
/datum/callback/proc/Invoke(...)
	if(!usr && user)
		var/mob/M = user.resolve()
		if(M)
			if(length(args))
				return world.invoke_callback_with_usr(arglist(list(M, src) + args))
			return world.invoke_callback_with_usr(M, src)
	if(!object)
		return
	var/list/calling_arguments = arguments
	if(length(args))
		if(length(arguments))
			calling_arguments = calling_arguments + args //not += so that it creates a new list so the arguments list stays clean
		else
			calling_arguments = args
	if(object == GLOBAL_PROC)
		return call(delegate)(arglist(calling_arguments))
	return call(object, delegate)(arglist(calling_arguments))

/**
 * Invoke this callback async (waitfor=false)
 *
 * Calls the registered proc on the registered object, if the user ref
 * can be resolved it also inclues that as an arg
 */
/datum/callback/proc/InvokeAsync(...)
	set waitfor = FALSE

	if(!usr && user)
		var/mob/M = user.resolve()
		if(M)
			if(length(args))
				return world.invoke_callback_with_usr(arglist(list(M, src) + args))
			return world.invoke_callback_with_usr(M, src)

	if(!object)
		return
	var/list/calling_arguments = arguments
	if(length(args))
		if(length(arguments))
			calling_arguments = calling_arguments + args //not += so that it creates a new list so the arguments list stays clean
		else
			calling_arguments = args
	if(object == GLOBAL_PROC)
		return call(delegate)(arglist(calling_arguments))
	return call(object, delegate)(arglist(calling_arguments))
