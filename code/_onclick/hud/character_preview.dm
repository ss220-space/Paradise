/// A preview of a character. The view owns the dummy: the map control auto-fits the
/// bounding box of its registered screen objects to the ByondUi element, so a
/// single 1x1 tile screen object with the dummy's appearance copied onto it
/// fills the whole element - no frame, zoom or transform needed.
/atom/movable/screen/map_view/character_preview
	name = "character_preview"
	/// The dummy human shown; its appearance is copied onto the screen object.
	var/mob/living/carbon/human/dummy
	/// Direction the dummy faces.
	var/preview_direction = SOUTH

/atom/movable/screen/map_view/character_preview/Destroy()
	QDEL_NULL(dummy)
	return ..()

/// Rebuilds the dummy from scratch with the current appearance and outfit of the owner's target.
/atom/movable/screen/map_view/character_preview/proc/rebuild_dummy(datum/custom_outfit/owner)
	QDEL_NULL(dummy)
	if(QDELETED(owner) || QDELETED(owner.target_mob) || !ishuman(owner.target_mob))
		return
	var/mob/living/carbon/human/human_target = owner.target_mob
	if(!human_target.dna || !human_target.dna.species)
		return
	dummy = new human_target.type
	dummy.setDir(preview_direction)
	owner.copy_appearance(human_target, dummy)
	var/datum/outfit/final_outfit = owner.make_final_outfit(preserve_implants = TRUE)
	if(length(owner.internal_augmentations))
		owner.apply_internal_augmentations(dummy)
	if(length(owner.external_augmentations))
		owner.apply_external_augmentations(dummy)
	dummy.equipOutfit(final_outfit)
	dummy.move_to_null_space()
	update_body()

/// Copies the dummy's appearance onto the screen object.
/atom/movable/screen/map_view/character_preview/proc/update_body()
	if(QDELETED(dummy))
		return
	dummy.setDir(preview_direction)
	appearance = dummy.appearance
	set_position(1, 1)
