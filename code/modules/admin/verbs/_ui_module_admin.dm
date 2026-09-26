GLOBAL_LIST_EMPTY(admin_ui_modules)

/proc/get_admin_ui_module(type)
	if(GLOB.admin_ui_modules[type])
		return GLOB.admin_ui_modules[type]
	if(!ispath(type, /datum/ui_module/admin))
		CRASH("Some user tried to create a [type] using the admin UI module helper!")
	return new type()

/// UI Admin Module is used by UIs who are shared between admins. For personal UI, don't use this.
/datum/ui_module/admin

/datum/ui_module/admin/New(datum/_host)
	. = ..()
	if(GLOB.admin_ui_modules[type])
		stack_trace("Somebody has overridden an admin UI module!")
		qdel(GLOB.admin_ui_modules[type])
	GLOB.admin_ui_modules[type] = src

/datum/ui_module/admin/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)
