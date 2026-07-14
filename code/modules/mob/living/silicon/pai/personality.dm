/*
		name
		key
		description
		role
		comments
		ready = 0
*/

/datum/paiCandidate/proc/savefile_path(mob/user)
	return "data/player_saves/[copytext(user.ckey, 1, 2)]/[user.ckey]/pai.sav"

/datum/paiCandidate/proc/savefile_save(mob/user)
	if(is_guest_key(user.key))
		return FALSE

	if(!src.name)	//Preventing false savings
		return FALSE

	var/savefile/savefile = new /savefile(src.savefile_path(user))

	savefile["name"] << src.name
	savefile["description"] << src.description
	savefile["role"] << src.role
	savefile["comments"] << src.comments

	savefile["version"] << 1

	return TRUE

// loads the savefile corresponding to the mob's ckey
// if silent=true, report incompatible savefiles
// returns 1 if loaded (or file was incompatible)
// returns 0 if savefile did not exist

/datum/paiCandidate/proc/savefile_load(mob/user, silent = 1)
	if(is_guest_key(user.key))
		return 0

	var/path = savefile_path(user)

	if(!fexists(path))
		return 0

	var/savefile/savefile = new /savefile(path)

	if(!savefile) return //Not everyone has a pai savefile.

	var/version = null
	savefile["version"] >> version

	if(isnull(version) || version != 1)
		fdel(path)
		if(!silent)
			alert(user, "Your savefile was incompatible with this version and was deleted.")
		return 0

	savefile["name"] >> src.name
	savefile["description"] >> src.description
	savefile["role"] >> src.role
	savefile["comments"] >> src.comments
	return 1
