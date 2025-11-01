// CAMERA NET
// The datum containing all the chunks.

GLOBAL_DATUM_INIT(cameranet, /datum/cameranet, new())

/datum/cameranet
	var/name = "Camera Net" // Name to show for VV and stat()

	// The cameras on the map, no matter if they work or not. Updated in obj/machinery/camera.dm by New() and Destroy().
	var/list/cameras = list()
	// The chunks of the map, mapping the areas that the cameras can see.
	var/list/chunks = list()
	var/ready = 0

	/// List of images cloned by all chunk static images put onto turfs cameras cant see
	/// Indexed by the plane offset to use
	var/list/image/obscured_images

/datum/cameranet/New()
	obscured_images = list()
	update_offsets(SSmapping.max_plane_offset)
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(on_offset_growth))

/datum/cameranet/proc/update_offsets(new_offset)
	for(var/i in length(obscured_images) to new_offset)
		var/image/obscured = new('icons/effects/cameravis.dmi')
		SET_PLANE_W_SCALAR(obscured, CAMERA_STATIC_PLANE, i)
		obscured.appearance_flags = RESET_TRANSFORM | RESET_ALPHA | RESET_COLOR | KEEP_APART
		obscured.override = TRUE
		obscured_images += obscured

/datum/cameranet/proc/on_offset_growth(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	update_offsets(new_offset)

// Checks if a chunk has been Generated in x, y, z.
/datum/cameranet/proc/chunkGenerated(x, y, z)
	x = GET_CHUNK_COORD(x)
	y = GET_CHUNK_COORD(y)
	if(GET_LOWEST_STACK_OFFSET(z) != 0)
		var/turf/lowest = get_lowest_turf(locate(x, y, z))
		return chunks["[x],[y],[lowest.z]"]

	return chunks["[x],[y],[z]"]

// Returns the chunk in the x, y, z.
// If there is no chunk, it creates a new chunk and returns that.
/datum/cameranet/proc/getCameraChunk(x, y, z)
	x = GET_CHUNK_COORD(x)
	y = GET_CHUNK_COORD(y)
	var/turf/lowest = get_lowest_turf(locate(x, y, z))
	var/key = "[x],[y],[lowest.z]"
	. = chunks[key]
	if(!.)
		chunks[key] = . = new /datum/camerachunk(x, y, lowest.z)

// Updates what the aiEye can see. It is recommended you use this when the aiEye moves or it's location is set.

/datum/cameranet/proc/visibility(list/moved_eyes, client/C, list/other_eyes)
	if(!islist(moved_eyes))
		moved_eyes = moved_eyes ? list(moved_eyes) : list()
	if(islist(other_eyes))
		other_eyes = (other_eyes - moved_eyes)
	else
		other_eyes = list()


	for(var/mob/camera/aiEye/eye as anything in moved_eyes)
		var/list/visibleChunks = list()
		// 0xf = 15
		var/turf/eye_turf = get_turf(eye)
		if(eye.loc)
			var/static_range = eye.static_visibility_range
			var/x1 = max(1, eye_turf.x - static_range)
			var/y1 = max(1, eye_turf.y - static_range)
			var/x2 = min(world.maxx, eye_turf.x + static_range)
			var/y2 = min(world.maxy, eye_turf.y + static_range)


			for(var/x = x1; x <= x2; x += CHUNK_SIZE)
				for(var/y = y1; y <= y2; y += CHUNK_SIZE)
					visibleChunks |= getCameraChunk(x, y, eye_turf.z)

		var/list/remove = eye.visibleCameraChunks - visibleChunks
		var/list/add = visibleChunks - eye.visibleCameraChunks

		for(var/datum/camerachunk/chunk as anything in remove)
			chunk.remove(eye, FALSE)

		for(var/datum/camerachunk/chunk as anything in add)
			chunk.add(eye)

// Updates the chunks that the turf is located in. Use this when obstacles are destroyed or	when doors open.

/datum/cameranet/proc/updateVisibility(atom/A, opacity_check = TRUE)
	if(!SSticker || (opacity_check && !A.opacity))
		return
	majorChunkChange(A, 2)

/datum/cameranet/proc/updateChunk(x, y, z)
	var/datum/camerachunk/chunk = chunkGenerated(x, y, z)
	if(!chunk)
		return
	chunk.hasChanged()

// Removes a camera from a chunk.

/datum/cameranet/proc/removeCamera(obj/machinery/camera/c)
	majorChunkChange(c, 0)

// Add a camera to a chunk.

/datum/cameranet/proc/addCamera(obj/machinery/camera/c)
	if(c.can_use())
		majorChunkChange(c, 1)

// Used for Cyborg cameras. Since portable cameras can be in ANY chunk.

/datum/cameranet/proc/updatePortableCamera(obj/machinery/camera/c)
	if(c.can_use())
		majorChunkChange(c, 1)
		c.update_computers_watched_by()
	//else
	//	majorChunkChange(c, 0)

// Never access this proc directly!!!!
// This will update the chunk and all the surrounding chunks.
// It will also add the atom to the cameras list if you set the choice to 1.
// Setting the choice to 0 will remove the camera from the chunks.
// If you want to update the chunks around an object, without adding/removing a camera, use choice 2.

/datum/cameranet/proc/majorChunkChange(atom/c, choice)
	if(QDELETED(c) && choice == 1)
		CRASH("Tried to add a qdeleting camera to the net")

	var/turf/T = get_turf(c)
	if(T)
		var/x1 = max(1, T.x - (CHUNK_SIZE / 2))
		var/y1 = max(1, T.y - (CHUNK_SIZE / 2))
		var/x2 = min(world.maxx, T.x + (CHUNK_SIZE / 2))
		var/y2 = min(world.maxy, T.y + (CHUNK_SIZE / 2))

//		to_chat(world, "X1: [x1] - Y1: [y1] - X2: [x2] - Y2: [y2]")

		for(var/x = x1; x <= x2; x += CHUNK_SIZE)
			for(var/y = y1; y <= y2; y += CHUNK_SIZE)
				var/datum/camerachunk/chunk = chunkGenerated(x, y, T.z)
				if(chunk)
					if(choice == 0)
						// Remove the camera.
						chunk.cameras["[T.z]"] -= c
					else if(choice == 1)
						// You can't have the same camera in the list twice.
						chunk.cameras["[T.z]"] |= c
					chunk.hasChanged()

/// A faster, turf only version of [/datum/cameranet/proc/majorChunkChange]
/// For use in sensitive code, be careful with it
/datum/cameranet/proc/bareMajorChunkChange(turf/changed)
	var/x1 = max(1, changed.x - (CHUNK_SIZE / 2))
	var/y1 = max(1, changed.y - (CHUNK_SIZE / 2))
	var/x2 = min(world.maxx, changed.x + (CHUNK_SIZE / 2))
	var/y2 = min(world.maxy, changed.y + (CHUNK_SIZE / 2))
	for(var/x = x1; x <= x2; x += CHUNK_SIZE)
		for(var/y = y1; y <= y2; y += CHUNK_SIZE)
			var/datum/camerachunk/chunk = chunkGenerated(x, y, changed.z)
			chunk?.hasChanged()

// Will check if a mob is on a viewable turf. Returns 1 if it is, otherwise returns 0.

/datum/cameranet/proc/checkCameraVis(mob/living/target as mob)

	// 0xf = 15
	var/turf/position = get_turf(target)
	return checkTurfVis(position)

/datum/cameranet/proc/checkTurfVis(turf/position)
	var/datum/camerachunk/chunk = getCameraChunk(position.x, position.y, position.z)
	if(chunk)
		if(chunk.changed)
			chunk.hasChanged(1) // Update now, no matter if it's visible or not.
		if(chunk.visibleTurfs[position])
			return TRUE
	return FALSE


/// Returns list of available cameras, ready to use for UIs displaying list of them
/// The format is: list("name" = "camera.c_tag", x = camera.x, y = camera.y, z = camera.z, ref = camera.UID(), status = camera.status)
/datum/cameranet/proc/get_available_cameras_data(list/networks_available, list/z_levels_available)
	var/list/available_cameras_data = list()
	for(var/obj/machinery/camera/camera as anything in get_filtered_and_sorted_cameras(networks_available, z_levels_available))
		available_cameras_data += list(list(
			name = camera.c_tag,
			x = camera.x,
			y = camera.y,
			z = camera.z,
			ref = camera.UID(),
			status = camera.status
		))

	return available_cameras_data

/**
 * get_available_camera_by_tag_list
 *
 * Builds a list of all available cameras that can be seen to networks_available and in z_levels_available.
 * Entries are stored in `c_tag[camera.can_use() ? null : " (Deactivated)"]` => `camera` format
 * Args:
 *  networks_available - List of networks that we use to see which cameras are visible to it.
 *  z_levels_available - List of z levels to filter camera by. If empty, all z levels are considered valid.
 *  sort_by_ctag - If the resulting list should be sorted by `c_tag`.
 */
/datum/cameranet/proc/get_available_camera_by_tag_list(list/networks_available, list/z_levels_available)
	var/list/available_cameras_by_tag = list()
	for(var/obj/machinery/camera/camera as anything in get_filtered_and_sorted_cameras(networks_available, z_levels_available))
		available_cameras_by_tag["[camera.c_tag][camera.can_use() ? null : " (Deactivated)"]"] = camera

	return available_cameras_by_tag

/// Returns list of all cameras that passed `is_camera_available` filter and sorted by `cmp_camera_ctag_asc`
/datum/cameranet/proc/get_filtered_and_sorted_cameras(list/networks_available, list/z_levels_available)
	PRIVATE_PROC(TRUE)

	var/list/filtered_cameras = list()
	for(var/obj/machinery/camera/camera as anything in cameras)
		if(!is_camera_available(camera, networks_available, z_levels_available))
			continue

		filtered_cameras += camera

	return sortTim(filtered_cameras, GLOBAL_PROC_REF(cmp_camera_ctag_asc))

/// Checks if the `camera_to_check` meets the requirements of availability.
/datum/cameranet/proc/is_camera_available(obj/machinery/camera/camera_to_check, list/networks_available, list/z_levels_available)
	PRIVATE_PROC(TRUE)

	if(!camera_to_check.c_tag)
		return FALSE

	if(length(z_levels_available) && !(camera_to_check.z in z_levels_available))
		return FALSE

	return length(camera_to_check.network & networks_available) > 0
