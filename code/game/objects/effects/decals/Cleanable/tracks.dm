// 5 seconds
#define TRACKS_CRUSTIFY_TIME   50

// color-dir-dry
GLOBAL_LIST_EMPTY(fluidtrack_cache)

// Footprints, tire trails...
/obj/effect/decal/cleanable/blood/tracks
	icon = 'icons/effects/fluidtracks.dmi'
	name = "wet tracks"
	dryname = "dried tracks"
	desc = "Whoops..."
	drydesc = "Whoops..."
	icon_state = "wheels1"
	gender = PLURAL
	random_icon_states = null
	amount = 0

//BLOODY FOOTPRINTS
/obj/effect/decal/cleanable/blood/footprints
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = "nothingwhatsoever"
	desc = "You REALLY shouldn't follow these.."
	gender = PLURAL
	random_icon_states = null
	basecolor = "#A10808"
	var/entered_dirs = 0
	var/exited_dirs = 0
	blood_state = BLOOD_STATE_HUMAN //the icon state to load images from


/obj/effect/decal/cleanable/blood/footprints/blood_decal_crossed(mob/living/carbon/human/arrived)
	. = ..()
	var/obj/item/clothing/shoes/shoes = arrived.shoes
	if(istype(shoes) && shoes.bloody_shoes[blood_state] && shoes.blood_color == basecolor)
		shoes.bloody_shoes[blood_state] = max(shoes.bloody_shoes[blood_state] - BLOOD_LOSS_PER_STEP, 0)
		if(!shoes.blood_DNA)
			shoes.blood_DNA = list()
		shoes.blood_DNA |= blood_DNA.Copy()
		if(!(entered_dirs & arrived.dir))
			entered_dirs |= arrived.dir
			update_icon()

	else if(!arrived.shoes && arrived.num_legs > 0 && arrived.bloody_feet[blood_state] && arrived.feet_blood_color == basecolor)
		arrived.bloody_feet[blood_state] = max(arrived.bloody_feet[blood_state] - BLOOD_LOSS_PER_STEP, 0)
		if(!arrived.feet_blood_DNA)
			arrived.feet_blood_DNA = list()
		arrived.feet_blood_DNA |= blood_DNA.Copy()
		if(!(entered_dirs & arrived.dir))
			entered_dirs |= arrived.dir
			update_icon()


/obj/effect/decal/cleanable/blood/footprints/blood_decal_uncrossed(mob/living/carbon/human/departed)
	. = ..()
	var/obj/item/clothing/shoes/shoes = departed.shoes
	if(istype(shoes) && shoes.bloody_shoes[blood_state] && shoes.blood_color == basecolor)
		shoes.bloody_shoes[blood_state] = max(shoes.bloody_shoes[blood_state] - BLOOD_LOSS_PER_STEP, 0)
		if(!shoes.blood_DNA)
			shoes.blood_DNA = list()
		shoes.blood_DNA |= blood_DNA.Copy()
		if(!(exited_dirs & departed.dir))
			exited_dirs |= departed.dir
			update_icon()

	else if(!departed.shoes && departed.num_legs > 0 && departed.bloody_feet[blood_state] && departed.feet_blood_color == basecolor)
		departed.bloody_feet[blood_state] = max(departed.bloody_feet[blood_state] - BLOOD_LOSS_PER_STEP, 0)
		if(!departed.feet_blood_DNA)
			departed.feet_blood_DNA = list()
		departed.feet_blood_DNA |= blood_DNA.Copy()
		if(!(exited_dirs & departed.dir))
			exited_dirs |= departed.dir
			update_icon()


/obj/effect/decal/cleanable/blood/footprints/update_overlays()
	. = ..()

	for(var/Ddir in GLOB.cardinal)
		if(entered_dirs & Ddir)
			var/image/I
			if(GLOB.fluidtrack_cache["entered-[blood_state]-[Ddir]"])
				I = GLOB.fluidtrack_cache["entered-[blood_state]-[Ddir]"]
			else
				I = image(icon,"[blood_state]1",dir = Ddir)
				GLOB.fluidtrack_cache["entered-[blood_state]-[Ddir]"] = I
			if(I)
				I.color = basecolor
				. += I
		if(exited_dirs & Ddir)
			var/image/I
			if(GLOB.fluidtrack_cache["exited-[blood_state]-[Ddir]"])
				I = GLOB.fluidtrack_cache["exited-[blood_state]-[Ddir]"]
			else
				I = image(icon,"[blood_state]2",dir = Ddir)
				GLOB.fluidtrack_cache["exited-[blood_state]-[Ddir]"] = I
			if(I)
				I.color = basecolor
				. += I

	alpha = BLOODY_FOOTPRINT_BASE_ALPHA + bloodiness


/proc/createFootprintsFrom(atom/movable/A, dir, turf/T)
	var/obj/effect/decal/cleanable/blood/footprints/FP = new /obj/effect/decal/cleanable/blood/footprints(T)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		FP.blood_state = H.blood_state
		FP.bloodiness = H.bloody_feet[H.blood_state] - BLOOD_LOSS_IN_SPREAD
		FP.basecolor = H.feet_blood_color
		if(H.blood_DNA)
			FP.blood_DNA = H.blood_DNA.Copy()
	else if(istype(A, /obj/item/clothing/shoes))
		var/obj/item/clothing/shoes/S = A
		FP.blood_state = S.blood_state
		FP.bloodiness = S.bloody_shoes[S.blood_state] - BLOOD_LOSS_IN_SPREAD
		FP.basecolor = S.blood_color
		if(S.blood_DNA)
			FP.blood_DNA = S.blood_DNA.Copy()
	FP.entered_dirs |= dir
	FP.update_icon()

	return FP

/obj/effect/decal/cleanable/blood/footprints/replace_decal(obj/effect/decal/cleanable/blood/footprints/C)
	if(blood_state != C.blood_state) //We only replace footprints of the same type as us
		return
	..()

/obj/effect/decal/cleanable/blood/footprints/can_bloodcrawl_in()
	if(basecolor == COLOR_BLOOD_MACHINE)
		return FALSE
	return TRUE
