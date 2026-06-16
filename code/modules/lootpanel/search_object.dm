/**
 * ## Search Object
 * An object for content lists. Compacted item data.
 */
/datum/search_object
	/// Item we're indexing
	var/atom/item
	/// Url to the image of the object
	var/icon
	/// Icon state, for inexpensive icons
	var/icon_state
	/// Name of the original object
	var/name
	/// Typepath of the original object for ui grouping
	var/path

	/// How [/datum/search_object/proc/generate_icon] should render this item's preview.
	/// Copied from the source atom's [/atom/var/looting_icon_mode]; if unset, New() picks a mode
	/// heuristically (see the icon generation conditions below). One of the LOOT_ICON_* defines.
	var/looting_icon_mode

	/// Shared cache of rendered icon HTML for [LOOT_ICON_FLAT_ICON_TYPE_CACHABLE] items, keyed by a
	/// md5 of the item's typepath. Static so every search object across every lootpanel reuses the
	/// same flat-icon HTML instead of re-rendering it per item. Only safe for items whose appearance
	/// is fully determined by their type (no per-instance overlays/state).
	var/static/alist/icon_cache = alist()

/datum/search_object/New(client/owner, atom/item)
	. = ..()

	src.item = item
	name = item.declent_ru(NOMINATIVE)
	looting_icon_mode = item.looting_icon_mode
	if(isobj(item))
		path = item.type

	if(isturf(item))
		RegisterSignal(item, COMSIG_TURF_CHANGE, PROC_REF(on_turf_change))
	else
		// Lest we find ourselves here again, this is intentionally stupid.
		// It tracks items going out and user actions, otherwise they can refresh the lootpanel.
		// If this is to be made to track everything, we'll need to make a new signal to specifically create/delete a search object
		RegisterSignals(item, list(
			COMSIG_ITEM_PICKUP,
			COMSIG_MOVABLE_MOVED,
			COMSIG_QDELETING,
			), PROC_REF(on_item_moved))

	if(looting_icon_mode)
		return

	// Icon generation conditions //////////////
	// Condition 1: Icon is complex
	if(length(item.overlays) > 1)
		looting_icon_mode = LOOT_ICON_FLAT_ICON_TYPE_CACHABLE
		return

	// Condition 2: Can't get icon path
	if(!isfile(item.icon) || !length("[item.icon]"))
		return

	// Condition 3: Using opendream
#if defined(OPENDREAM) || defined(UNIT_TESTS)
	return
#endif

	icon = "[item.icon]"
	icon_state = item.icon_state

/datum/search_object/Destroy(force)
	item = null
	icon = null

	return ..()

/// Generates the icon for the search object. This is the expensive part.
/datum/search_object/proc/generate_icon(client/owner)
	switch(looting_icon_mode)
		if(LOOT_ICON_ICON_TO_HTML)
			icon = icon2html(item, owner, sourceonly = TRUE)

		if(LOOT_ICON_FLAT_ICON_TYPE_CACHABLE)
			var/hash = md5("[item.type]")
			if(!(hash in icon_cache))
				icon_cache[hash] = flat_icon2html(item, owner, sourceonly = TRUE, name = hash)
			icon = icon_cache[hash]

		if(LOOT_ICON_FLAT_ICON)
			icon = flat_icon2html(item, owner, sourceonly = TRUE)

/// Parent item has been altered, search object no longer valid
/datum/search_object/proc/on_item_moved(atom/source)
	SIGNAL_HANDLER

	if(QDELETED(src))
		return

	qdel(src)

/// Parent tile has been altered, entire search needs reset
/datum/search_object/proc/on_turf_change(turf/source, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER

	post_change_callbacks += CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src)
