// MARK: TODO: REF
/proc/DuplicateObject(atom/original, perfectcopy = FALSE , sameloc = FALSE, atom/newloc = null)
	RETURN_TYPE(original.type)
	if(!original)
		return null

	var/atom/atom = null

	if(sameloc)
		atom = new original.type(original.loc)
	else
		atom = new original.type(newloc)

	if(perfectcopy)
		if(atom)
			var/static/list/forbidden_vars = list("type","loc","locs","vars", "parent","parent_type", "verbs","ckey","key","power_supply","contents","reagents","stat","x","y","z","group", "_listen_lookup", "_datum_components")

			for(var/V in original.vars - forbidden_vars)
				if(islist(original.vars[V]))
					var/list/L = original.vars[V]
					atom.vars[V] = L.Copy()
				else if(isdatum(original.vars[V]))
					continue // this would reference the original's object, that will break when it is used or deleted.
				else
					atom.vars[V] = original.vars[V]
	if(istype(atom))
		atom.update_icon()
	return atom
