/*
	Global associative list for caching humanoid icons.
	Index format m or f, followed by a string of 0 and 1 to represent bodyparts followed by husk hulk skeleton 1 or 0.
	TODO: Proper documentation
	icon_key is [species.race_key][g][husk][hulk][skeleton][s_tone]
*/
GLOBAL_LIST_EMPTY(human_icon_cache)

	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/*
Calling this  a system is perhaps a bit trumped up. It is essentially update_clothing dismantled into its
core parts. The key difference is that when we generate overlays we do not generate either lying or standing
versions. Instead, we generate both and store them in two fixed-length lists, both using the same list-index
(The indexes are in update_icons.dm): Each list for humans is (at the time of writing) of length 19.
This will hopefully be reduced as the system is refined.

	var/overlays_lying[19]			//For the lying down stance
	var/overlays_standing[19]		//For the standing stance

When we call update_icons, the 'lying' variable is checked and then the appropriate list is assigned to our overlays!
That in itself uses a tiny bit more memory (no more than all the ridiculous lists the game has already mind you).

On the other-hand, it should be very CPU cheap in comparison to the old system.
In the old system, we updated all our overlays every life() call, even if we were standing still inside a crate!
or dead!. 25ish overlays, all generated from scratch every second for every xeno/human/monkey and then applied.
More often than not update_clothing was being called a few times in addition to that! CPU was not the only issue,
all those icons had to be sent to every client. So really the cost was extremely cumulative. To the point where
update_clothing would frequently appear in the top 10 most CPU intensive procs during profiling.

Another feature of this new system is that our lists are indexed. This means we can update specific overlays!
So we only regenerate icons when we need them to be updated! This is the main saving for this system.

In practice this means that:
	everytime you fall over, we just switch between precompiled lists. Which is fast and cheap.
	Everytime you do something minor like take a pen out of your pocket, we only update the in-hand overlay
	etc...

There are several things that need to be remembered:

>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src) )
	You will need to call the relevant update_inv_* proc:
		update_worn_head()
		update_worn_oversuit()
		update_worn_gloves()
		update_worn_shoes()
		update_worn_undersuit()
		update_worn_glasses()
		update_held_items()
		update_worn_belt()
		update_worn_id()
		update_worn_ears()
		update_suit_storage()
		update_pockets()
		update_worn_back()
		update_worn_handcuffs()()
		update_worn_mask()

	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_worn_id() if the usr is a
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.

>	There are also these special cases:
		update_mutations()	//handles updating your appearance for certain mutations.  e.g TK head-glows
		UpdateDamageIcon()	//handles damage overlays for brute/burn damage //(will rename this when I geta round to it)
		update_body()	//Handles updating your mob's icon to reflect their gender/race/complexion etc
		update_hair()	//Handles updating your hair overlay (used to be update_face, but mouth and
																			...eyes were merged into update_body)

>	All of these procs update our overlays_lying and overlays_standing, and then call update_icons() by default.
	If you wish to update several overlays at once, you can set the argument to 0 to disable the update and call
	it manually:
		e.g.
		update_worn_head()
		update_held_items()	//<---calls update_icons()

	or equivillantly:
		update_worn_head()
		update_held_items()
		update_icons()

>	If you need to update all overlays you can use regenerate_icons(). it works exactly like update_clothing used to.

>	I reimplimented an old unused variable which was in the code called (coincidentally) var/update_icon
	It can be used as another method of triggering regenerate_icons(). It's basically a flag that when set to non-zero
	will call regenerate_icons() at the next life() call and then reset itself to 0.
	The idea behind it is icons are regenerated only once, even if multiple events requested it.

This system is confusing and is still a WIP. It's primary goal is speeding up the controls of the game whilst
reducing processing costs. So please bear with me while I iron out the kinks. It will be worth it, I promise.
If I can eventually free var/lying stuff from the life() process altogether, stuns/death/status stuff
will become less affected by lag-spikes and will be instantaneous! :3

If you have any questions/constructive-comments/bugs-to-report/or have a massivly devestated butt...
Please contact me on #coderbus IRC. ~Carn x
*/

GLOBAL_LIST_EMPTY(damage_icon_parts)

//DAMAGE OVERLAYS
//constructs damage icon for each organ from mask * damage field and saves it in our overlays_ lists
/mob/living/carbon/human/UpdateDamageIcon()
	// first check whether something actually changed about damage appearance
	var/damage_appearance = ""

	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		damage_appearance += bodypart.damage_state

	if(damage_appearance == previous_damage_appearance)
		// nothing to do here
		return

	previous_damage_appearance = damage_appearance

	remove_overlay(H_DAMAGE_LAYER)
	var/mutable_appearance/damage_overlay = mutable_appearance(dna.species.damage_overlays, "00", layer = -H_DAMAGE_LAYER)
	overlays_standing[H_DAMAGE_LAYER] = damage_overlay

	// blend the individual damage states with our icons
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		bodypart.update_state()
		if(bodypart.damage_state == "00")
			continue

		var/icon/DI
		var/cache_index = "[bodypart.damage_state]/[bodypart.icon_name]/[dna.species.blood_color]/[dna.species.name]"

		if(GLOB.damage_icon_parts[cache_index] == null)
			DI = new /icon(dna.species.damage_overlays, bodypart.damage_state)			// the damage icon for whole human
			DI.Blend(new /icon(dna.species.damage_mask, bodypart.icon_name), ICON_MULTIPLY)	// mask with this organ's pixels
			DI.Blend(dna.species.blood_color, ICON_MULTIPLY)
			GLOB.damage_icon_parts[cache_index] = DI
		else
			DI = GLOB.damage_icon_parts[cache_index]
		damage_overlay.overlays += DI

	apply_overlay(H_DAMAGE_LAYER)

//BASE MOB SPRITE
/mob/living/carbon/human/update_body(rebuild_base = FALSE)
	SEND_SIGNAL(src, COMSIG_UPDATE_STRENGTH)
	remove_overlay(LIMBS_LAYER) // So we don't get the old species' sprite splatted on top of the new one's
	remove_overlay(UNDERWEAR_LAYER)

	var/husk_color_mod = rgb(96, 88, 80)
	var/hulk_color_mod = rgb(48, 224, 40)

	var/husk = HAS_TRAIT(src, TRAIT_HUSK)
	var/hulk = HAS_TRAIT(src, TRAIT_HULK)
	var/skeleton = HAS_TRAIT(src, TRAIT_SKELETON)

	if(dna.species && dna.species.bodyflags & HAS_ICON_SKIN_TONE)
		dna.species.updatespeciescolor(src)

	//CACHING: Generate an index key from visible bodyparts.
	//0 = destroyed, 1 = normal, 2 = robotic, 3 = necrotic.
	//Create a new, blank icon for our mob to use.
	if(stand_icon)
		qdel(stand_icon)

	update_misc_effects()
	stand_icon = new (dna.species.icon_template ? dna.species.icon_template : 'icons/mob/human.dmi', "blank")
	var/list/standing = list()
	var/icon_key = generate_icon_render_key()

	var/mutable_appearance/base
	if(GLOB.human_icon_cache[icon_key] && !rebuild_base)
		base = GLOB.human_icon_cache[icon_key]
		standing += base
	else
		var/icon/base_icon
		//BEGIN CACHED ICON GENERATION.
		var/obj/item/organ/external/chest = get_organ(BODY_ZONE_CHEST)
		if(chest) //I hate it.
			base_icon = chest.get_icon(skeleton)

		for(var/obj/item/organ/external/part as anything in bodyparts)
			if(part.limb_zone == BODY_ZONE_TAIL || part.limb_zone == BODY_ZONE_WING)
				continue
			var/icon/temp = part.get_icon(skeleton)
			//That part makes left and right legs drawn topmost and lowermost when human looks WEST or EAST
			//And no change in rendering for other parts (they icon_position is 0, so goes to 'else' part)
			if(part.icon_position & (LEFT | RIGHT))
				var/icon/temp2 = new('icons/mob/human.dmi',"blank")
				temp2.Insert(new/icon(temp,dir=NORTH),dir=NORTH)
				temp2.Insert(new/icon(temp,dir=SOUTH),dir=SOUTH)
				if(!(part.icon_position & LEFT))
					temp2.Insert(new/icon(temp,dir=EAST),dir=EAST)
				if(!(part.icon_position & RIGHT))
					temp2.Insert(new/icon(temp,dir=WEST),dir=WEST)
				base_icon.Blend(temp2, ICON_OVERLAY)
				if(part.icon_position & LEFT)
					temp2.Insert(new/icon(temp,dir=EAST),dir=EAST)
				if(part.icon_position & RIGHT)
					temp2.Insert(new/icon(temp,dir=WEST),dir=WEST)
				base_icon.Blend(temp2, ICON_UNDERLAY)
			else
				base_icon.Blend(temp, ICON_OVERLAY)

		if(!skeleton)
			if(isgolem(src))
				var/datum/species/golem/G = src.dna.species
				if(G.golem_colour)
					base_icon.ColorTone(G.golem_colour)
			if(husk)
				base_icon.ColorTone(husk_color_mod)
			else if(hulk)
				var/list/tone = rgb2num(hulk_color_mod)
				base_icon.MapColors(rgb(tone[1],0,0),rgb(0,tone[2],0),rgb(0,0,tone[3]))

		//Handle husk overlay.
		if(husk && icon_exists(chest.icobase, "overlay_husk"))
			var/icon/mask = new(base_icon)
			var/icon/husk_over = new(chest.icobase,"overlay_husk")
			mask.MapColors(0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,0)
			husk_over.Blend(mask, ICON_ADD)
			base_icon.Blend(husk_over, ICON_OVERLAY)

		var/mutable_appearance/new_base = mutable_appearance(base_icon, layer = -LIMBS_LAYER)
		GLOB.human_icon_cache[icon_key] = new_base
		standing += new_base

		//END CACHED ICON GENERATION.

	overlays_standing[LIMBS_LAYER] = standing
	apply_overlay(LIMBS_LAYER)

	//Underwear
	var/icon/underwear_standing = new /icon('icons/mob/clothing/underwear.dmi', "nude")
	if(underwear && dna.species.clothing_flags & HAS_UNDERWEAR)
		var/datum/sprite_accessory/underwear/U = GLOB.underwear_list[underwear]
		if(U)
			var/u_icon = U.sprite_sheets && (dna.species.name in U.sprite_sheets) ? U.sprite_sheets[dna.species.name] : U.icon //Species-fit the undergarment.
			var/icon/underwear_icon = new (u_icon, "uw_[U.icon_state]_s")
			if(U.allow_change_color)
				underwear_icon.Blend(color_underwear, ICON_MULTIPLY)
			underwear_standing.Blend(underwear_icon, ICON_OVERLAY)

	if(undershirt && dna.species.clothing_flags & HAS_UNDERSHIRT)
		var/datum/sprite_accessory/undershirt/U2 = GLOB.undershirt_list[undershirt]
		if(U2)
			var/u2_icon = U2.sprite_sheets && (dna.species.name in U2.sprite_sheets) ? U2.sprite_sheets[dna.species.name] : U2.icon
			var/icon/undershirt_icon = new(u2_icon, "us_[U2.icon_state]_s")
			if(U2.allow_change_color)
				undershirt_icon.Blend(color_undershirt, ICON_MULTIPLY)
			underwear_standing.Blend(undershirt_icon, ICON_OVERLAY)

	if(socks && dna.species.clothing_flags & HAS_SOCKS)
		var/datum/sprite_accessory/socks/U3 = GLOB.socks_list[socks]
		if(U3)
			var/u3_icon = U3.sprite_sheets && (dna.species.name in U3.sprite_sheets) ? U3.sprite_sheets[dna.species.name] : U3.icon
			underwear_standing.Blend(new /icon(u3_icon, "sk_[U3.icon_state]_s"), ICON_OVERLAY)

	if(underwear_standing)
		overlays_standing[UNDERWEAR_LAYER] = mutable_appearance(underwear_standing, layer = -UNDERWEAR_LAYER)
	apply_overlay(UNDERWEAR_LAYER)

	//wings
	update_wing_layer()
	//tail
	update_tail_layer()
	update_int_organs()
	//head accessory
	update_head_accessory()
	//markings
	update_markings()
	//hair
	update_hair()
	update_fhair()

//MARKINGS OVERLAY
/mob/living/carbon/human/proc/update_markings()
	//Reset our markings.
	remove_overlay(MARKINGS_LAYER)

	//Base icon.
	var/icon/markings_standing = icon("icon" = 'icons/mob/clothing/body_accessory.dmi', "icon_state" = "accessory_none_s")

	//Body markings.
	var/obj/item/organ/external/chest/chest_organ = get_organ(BODY_ZONE_CHEST)
	if(chest_organ && m_styles["body"])
		var/body_marking = m_styles["body"]
		var/datum/sprite_accessory/body_marking_style = GLOB.marking_styles_list[body_marking]
		if(body_marking_style?.species_allowed && (dna.species.name in body_marking_style.species_allowed))
			var/icon/b_marking_s = icon("icon" = body_marking_style.icon, "icon_state" = "[body_marking_style.icon_state]_s")
			if(body_marking_style.do_colouration)
				b_marking_s.Blend(m_colours["body"], ICON_ADD)
			markings_standing.Blend(b_marking_s, ICON_OVERLAY)
	//Head markings.
	var/obj/item/organ/external/head/head_organ = get_organ(BODY_ZONE_HEAD)
	if(head_organ && m_styles["head"]) //If the head is destroyed, forget the head markings. This prevents floating optical markings on decapitated IPCs, for example.
		var/head_marking = m_styles["head"]
		var/datum/sprite_accessory/head_marking_style = GLOB.marking_styles_list[head_marking]
		if(head_marking_style?.species_allowed && (head_organ.dna.species.name in head_marking_style.species_allowed))
			var/icon/h_marking_s = icon("icon" = head_marking_style.icon, "icon_state" = "[head_marking_style.icon_state]_s")
			if(head_marking_style.do_colouration)
				h_marking_s.Blend(m_colours["head"], ICON_ADD)
			markings_standing.Blend(h_marking_s, ICON_OVERLAY)

	overlays_standing[MARKINGS_LAYER] = mutable_appearance(markings_standing, layer = -MARKINGS_LAYER)
	apply_overlay(MARKINGS_LAYER)
	var/body_marking = m_styles["body"]
	var/datum/sprite_accessory/body_marking_style = GLOB.marking_styles_list[body_marking]
	if(body_marking_style.visible_over_uniform && istype(w_uniform, /obj/item/clothing/under))
		update_worn_undersuit()

//HEAD ACCESSORY OVERLAY
/mob/living/carbon/human/proc/update_head_accessory()
	//Reset our head accessory
	remove_overlay(HEAD_ACCESSORY_LAYER)
	remove_overlay(HEAD_ACC_OVER_LAYER)

	var/obj/item/organ/external/head/head_organ = get_organ(BODY_ZONE_HEAD)
	if(!head_organ || !head_organ.dna || !head_organ.ha_style)
		return

	//masks and helmets can obscure our head accessory
	if((head && (head.flags_inv & HIDEHAIR)) || (wear_mask && (wear_mask.flags_inv & HIDEHAIR)))
		return

	var/datum/sprite_accessory/head_accessory/head_accessory = GLOB.head_accessory_styles_list[head_organ.ha_style]
	if(!head_accessory || !(head_accessory.species_allowed && (head_organ.dna.species.name in head_accessory.species_allowed)))
		return

	//base icons
	var/icon/head_accessory_standing = icon('icons/mob/clothing/body_accessory.dmi', "accessory_none_s")
	var/icon/head_accessory_s = icon(head_accessory.icon, "[head_accessory.icon_state]_s")
	if(head_accessory.do_colouration)
		head_accessory_s.Blend(head_organ.headacc_colour, ICON_ADD)
	//head_accessory_standing.Blend(head_accessory_s, ICON_OVERLAY)
	//Having it this way preserves animations. Useful for animated antennae.
	head_accessory_standing = head_accessory_s

	if(head_accessory.over_hair) //Select which layer to use based on the properties of the head accessory style.
		overlays_standing[HEAD_ACC_OVER_LAYER] = mutable_appearance(head_accessory_standing, layer = -HEAD_ACC_OVER_LAYER)
		apply_overlay(HEAD_ACC_OVER_LAYER)
	else
		overlays_standing[HEAD_ACCESSORY_LAYER] = mutable_appearance(head_accessory_standing, layer = -HEAD_ACCESSORY_LAYER)
		apply_overlay(HEAD_ACCESSORY_LAYER)

//HAIR OVERLAY
/mob/living/carbon/human/update_hair()
	//Reset our hair
	remove_overlay(HAIR_LAYER)

	var/obj/item/organ/external/head/head_organ = get_organ(BODY_ZONE_HEAD)
	if(!head_organ || !head_organ.dna || !head_organ.h_style)
		return

	if(HAS_TRAIT(src, TRAIT_BALD))
		head_organ.f_style = "Shaved"
		head_organ.h_style = "Bald"

	//masks and helmets can obscure our hair, unless we're a synthetic
	if((head && (head.flags_inv & (HIDEHAIR|HIDEHEADHAIR))) || (wear_mask && (wear_mask.flags_inv & (HIDEHAIR|HIDEHEADHAIR))))
		return

	var/datum/sprite_accessory/hair/hair = GLOB.hair_styles_full_list[head_organ.h_style]
	if(!hair || !((hair.species_allowed && (head_organ.dna.species.name in hair.species_allowed)) || (head_organ.dna.species.bodyflags & ALL_RPARTS)))
		return

	//base icons
	var/mutable_appearance/MA = new()
	MA.appearance_flags = KEEP_TOGETHER
	MA.layer = -HAIR_LAYER

	// Base hair
	var/mutable_appearance/img_hair = mutable_appearance(hair.icon, "[hair.icon_state]_s")
	if(head_organ.dna.species.name == SPECIES_SLIMEPERSON)
		img_hair.color = COLOR_MATRIX_OVERLAY("[skin_colour]A0")
	else if(hair.do_colouration)
		img_hair.color = COLOR_MATRIX_ADD(head_organ.hair_colour)
	MA.overlays += img_hair

	// Gradient
	var/datum/sprite_accessory/hair_gradient/gradient = GLOB.hair_gradients_list[head_organ.h_grad_style]
	if(gradient)
		var/icon/icn_alpha_mask = icon(gradient.icon, gradient.icon_state)
		var/icon/icn_gradient = icon(gradient.icon, "full")
		var/list/icn_color = rgb2num(head_organ.h_grad_colour)
		icn_gradient.MapColors(rgb(icn_color[1], 0, 0), rgb(0, icn_color[2], 0), rgb(0, 0, icn_color[3]))
		icn_gradient.ChangeOpacity(head_organ.h_grad_alpha / 200)
		icn_gradient.AddAlphaMask(icn_alpha_mask)
		icn_gradient.Shift(EAST, head_organ.h_grad_offset_x)
		icn_gradient.Shift(NORTH, head_organ.h_grad_offset_y)
		icn_gradient.AddAlphaMask(icon(hair.icon, "[hair.icon_state]_s"))
		MA.overlays += icn_gradient

	// Secondary style
	if(hair.secondary_theme)
		var/mutable_appearance/img_secondary = mutable_appearance(hair.icon, "[hair.icon_state]_[hair.secondary_theme]_s")
		if(!hair.no_sec_colour)
			img_secondary.color = COLOR_MATRIX_ADD(head_organ.sec_hair_colour)
		MA.overlays += img_secondary

	update_mutant_ears()
	overlays_standing[HAIR_LAYER] = MA
	apply_overlay(HAIR_LAYER)

//FACIAL HAIR OVERLAY
/mob/living/carbon/human/proc/update_fhair()
	//Reset our facial hair
	remove_overlay(FHAIR_LAYER)
	remove_overlay(FHAIR_OVER_LAYER)

	var/obj/item/organ/external/head/head_organ = get_organ(BODY_ZONE_HEAD)
	if(!head_organ || !head_organ.dna || !head_organ.f_style)
		return

	if(HAS_TRAIT(src, TRAIT_BALD))
		head_organ.f_style = "Shaved"
		head_organ.h_style = "Bald"

	//masks and helmets can obscure our facial hair, unless we're a synthetic
	if((head && (head.flags_inv & (HIDEHAIR|HIDEFACIALHAIR))) || (wear_mask && (wear_mask.flags_inv & (HIDEHAIR|HIDEFACIALHAIR))))
		return

	var/datum/sprite_accessory/facial_hair/facial_hair = GLOB.facial_hair_styles_list[head_organ.f_style]
	//If the head's species is in the list of allowed species for the hairstyle, or the head's species is one flagged to have bodies comprised wholly of cybernetics...
	if(!facial_hair || !((facial_hair.species_allowed && (head_organ.dna.species.name in facial_hair.species_allowed)) || (head_organ.dna.species.bodyflags & ALL_RPARTS)))
		return

	//base icons
	var/icon/face_standing = icon('icons/mob/human_face.dmi', "bald_s")

	var/icon/facial_s = icon(facial_hair.icon, "[facial_hair.icon_state]_s")
	if(head_organ.dna.species.name == SPECIES_SLIMEPERSON) // I am el worstos
		facial_s.Blend("[skin_colour]A0", ICON_AND)
	else if(facial_hair.do_colouration)
		facial_s.Blend(head_organ.facial_colour, ICON_ADD)

	if(facial_hair.secondary_theme)
		var/icon/facial_secondary_s = icon(facial_hair.icon, "[facial_hair.icon_state]_[facial_hair.secondary_theme]_s")
		if(!facial_hair.no_sec_colour)
			facial_secondary_s.Blend(head_organ.sec_facial_colour, ICON_ADD)
		facial_s.Blend(facial_secondary_s, ICON_OVERLAY)

	face_standing.Blend(facial_s, ICON_OVERLAY)

	if(facial_hair.over_hair) //Select which layer to use based on the properties of the facial hair style.
		overlays_standing[FHAIR_OVER_LAYER] = mutable_appearance(face_standing, layer = -FHAIR_OVER_LAYER)
		apply_overlay(FHAIR_OVER_LAYER)
	else
		overlays_standing[FHAIR_LAYER] = mutable_appearance(face_standing, layer = -FHAIR_LAYER)
		apply_overlay(FHAIR_LAYER)

/mob/living/carbon/human/update_mutations()
	remove_overlay(MUTATIONS_LAYER)
	var/mutable_appearance/standing = mutable_appearance(is_monkeybasic(src) ? 'icons/mob/monkey.dmi' : 'icons/effects/genetics.dmi', layer = -MUTATIONS_LAYER)
	var/add_image = FALSE
	var/g = "m"
	if(gender == FEMALE)
		g = "f"
	// DNA2 - Drawing underlays.
	for(var/datum/dna/gene/gene as anything in GLOB.dna_genes)
		if(gene.is_active(src))
			var/underlay = gene.OnDrawUnderlays(src, g)
			if(underlay)
				standing.underlays += underlay
				add_image = TRUE

	if(HAS_TRAIT_FROM(src, TRAIT_RESIST_COLD, DNA_TRAIT) && HAS_TRAIT_FROM(src, TRAIT_RESIST_HEAT, DNA_TRAIT))
		standing.underlays -= "cold_s"
		standing.underlays -= "fire_s"
		standing.underlays += "coldfire_s"

	if(HAS_TRAIT(src, TRAIT_LASEREYES))
		standing.overlays += "lasereyes_s"
		add_image = TRUE

	if(add_image)
		overlays_standing[MUTATIONS_LAYER] = standing
	apply_overlay(MUTATIONS_LAYER)

/mob/living/carbon/human/proc/update_mutant_ears()
	remove_overlay(MUTANT_EARS_LAYER)
	var/datum/dna/gene/disability/catears/ears_gene = locate(/datum/dna/gene/disability/catears) in GLOB.dna_genes
	if(!ears_gene.is_active(src))
		return

	var/mutable_appearance/felinide_ears = mutable_appearance('icons/effects/genetics.dmi', layer = -MUTANT_EARS_LAYER)
	var/painted_ears = ears_gene.paint_felinide_ears(src)
	felinide_ears.underlays += painted_ears
	overlays_standing[MUTANT_EARS_LAYER] = felinide_ears
	apply_overlay(MUTANT_EARS_LAYER)

/mob/living/carbon/human/update_fire()
	remove_overlay(FIRE_LAYER)
	if(on_fire || HAS_TRAIT(src, TRAIT_FAKE_FIRE))
		var/fire_icon_state = "[is_monkeybasic(src) ? "monkey" : "human"]_fire"
		if(!overlays_standing[FIRE_LAYER])
			overlays_standing[FIRE_LAYER] = mutable_appearance('icons/mob/OnFire.dmi', icon_state = fire_icon_state, layer = -FIRE_LAYER)
	apply_overlay(FIRE_LAYER)

/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return
	cut_overlays()
	force_update_limbs(update_body = FALSE)
	update_eyes(update_body = FALSE)
	update_body(rebuild_base = TRUE) //Update the body and force limb icon regeneration.
	update_mutations()
	update_worn_undersuit()
	update_worn_id()
	update_worn_glasses()
	update_worn_gloves()
	update_worn_ears()
	update_worn_shoes()
	update_suit_storage()
	update_worn_mask()
	update_worn_head()
	update_worn_belt()
	update_worn_back()
	update_worn_oversuit()
	update_held_items()
	update_pockets()
	update_worn_handcuffs()
	update_worn_legcuffs()
	update_worn_neck()
	update_worn_pda()
	update_transform()
	UpdateDamageIcon()
	if(blocks_emissive)
		add_overlay(get_emissive_block())
	SEND_SIGNAL(src, COMSIG_MOB_HALO_GAINED)
	update_fire()
	update_ssd_overlay()
	update_unconscious_overlay()
	SEND_SIGNAL(src, COMSIG_HUMAN_REGENERATE_ICONS)

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_worn_undersuit()
	remove_overlay(UNIFORM_LAYER)
	remove_overlay(OVER_SHOES_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_CLOTH_INNER) + 1]
		inv?.update_icon()

	if(!istype(w_uniform, /obj/item/clothing/under))
		return

	if(check_obscured_slots(check_transparent = TRUE) & ITEM_SLOT_CLOTH_INNER)
		return

	update_item_on_hud(w_uniform, ui_iclothing, togleable_inventory = TRUE)
	var/state_type = w_uniform.rolled_down ? "[w_uniform.icon_state]_d" : w_uniform.icon_state
	var/mutable_appearance/uniform_overlay
	var/uniform_layer = w_uniform.over_shoes ? OVER_SHOES_LAYER : UNIFORM_LAYER

	uniform_overlay = w_uniform.build_worn_icon(
		default_layer = uniform_layer,
		default_icon_file = w_uniform.onmob_sheets[ITEM_SLOT_CLOTH_INNER_STRING],
		isinhands = FALSE,
		override_state = "[state_type]_s"
	)

	for(var/obj/item/clothing/accessory/accessory as anything in w_uniform.accessories)
		var/acc_state_type = accessory.item_state ? accessory.item_state : accessory.icon_state
		var/mutable_appearance/acc_olay = mutable_appearance(accessory.onmob_sheets[ITEM_SLOT_ACCESSORY_STRING], acc_state_type, alpha = accessory.alpha, color = accessory.color)
		if(accessory.sprite_sheets?[dna.species.name])
			acc_olay.icon = accessory.sprite_sheets[dna.species.name]
		uniform_overlay.overlays += acc_olay

	// over_uniform body marks
	var/body_marking = m_styles["body"]
	var/datum/sprite_accessory/body_marking_style = GLOB.marking_styles_list[body_marking]
	if(body_marking_style.visible_over_uniform || body_marking_style.name != /datum/sprite_accessory/body_markings/none::name)
		var/obj/item/organ/external/chest/chest_organ = get_organ(BODY_ZONE_CHEST)
		if(chest_organ && m_styles["body"])
			if(body_marking_style?.species_allowed && (dna.species.name in body_marking_style.species_allowed))
				var/icon/b_marking_s = icon("icon" = body_marking_style.icon, "icon_state" = "[body_marking_style.icon_state]-withclothes")
				if(body_marking_style.do_colouration)
					b_marking_s.Blend(m_colours["body"], ICON_ADD)
				uniform_overlay.overlays += b_marking_s

	overlays_standing[uniform_layer] = uniform_overlay
	apply_overlay(uniform_layer)

/mob/living/carbon/human/update_worn_id()
	remove_overlay(ID_LAYER)
	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_ID) + 1]
		inv.update_icon()
	var/mutable_appearance/id_overlay = overlays_standing[ID_LAYER]
	if(!wear_id)
		return

	update_item_on_hud(wear_id, ui_id)
	if(!w_uniform?.displays_id)
		return

	id_overlay = wear_id.build_worn_icon(default_layer = ID_LAYER, default_icon_file = wear_id.onmob_sheets[ITEM_SLOT_ID_STRING], override_state = "id")
	if(!id_overlay)
		return

	overlays_standing[ID_LAYER] = id_overlay
	apply_overlay(ID_LAYER)

/mob/living/carbon/human/update_worn_gloves()
	remove_overlay(GLOVES_LAYER)

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_GLOVES) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_GLOVES) + 1]
		inv.update_icon()

	if(check_obscured_slots(check_transparent = TRUE) & ITEM_SLOT_GLOVES)
		return

	if(isnull(gloves))
		if(!num_hands)
			return

		var/clock_hands = HAS_TRAIT(src, TRAIT_CLOCK_HANDS)
		if(!blood_DNA && !clock_hands)
			return

		// When byond gives us filters that respect dirs we can just use an alpha mask for this but until then, two icons weeeee
		var/mutable_appearance/hands_combined = mutable_appearance(layer = -GLOVES_LAYER, appearance_flags = KEEP_TOGETHER)
		if(clock_hands)
			if(has_left_hand())
				var/mutable_appearance/clock_hands_overlay = mutable_appearance('icons/effects/clockwork_effects.dmi', "clockedhands_l", color = COLOR_LIGHT_ORANGE)
				hands_combined.overlays += clock_hands_overlay

			if(has_right_hand())
				var/mutable_appearance/clock_hands_overlay = mutable_appearance('icons/effects/clockwork_effects.dmi', "clockedhands_r", color = COLOR_LIGHT_ORANGE)
				hands_combined.overlays += clock_hands_overlay

		else if(blood_DNA)
			var/blood_mask = 'icons/mob/human_races/masks/blood_human.dmi'
			if(dna && ("bloodyhands_left" in dna.species.get_blood_overlays()))
				blood_mask = dna.species.blood_mask
			if(has_left_hand())
				var/mutable_appearance/blood_hands_overlay = mutable_appearance(blood_mask, "bloodyhands_left", color = hand_blood_color)
				hands_combined.overlays += blood_hands_overlay

			if(has_right_hand())
				var/mutable_appearance/blood_hands_overlay = mutable_appearance(blood_mask, "bloodyhands_right", color = hand_blood_color)
				hands_combined.overlays += blood_hands_overlay

		overlays_standing[GLOVES_LAYER] = hands_combined
		apply_overlay(GLOVES_LAYER)
		return

	update_item_on_hud(gloves, ui_gloves, togleable_inventory = TRUE)
	var/mutable_appearance/gloves_overlay = gloves.build_worn_icon(default_layer = GLOVES_LAYER, default_icon_file = gloves.onmob_sheets[ITEM_SLOT_GLOVES_STRING], use_item_state = TRUE)

	overlays_standing[GLOVES_LAYER] = gloves_overlay
	apply_overlay(GLOVES_LAYER)

/mob/living/carbon/human/update_worn_glasses()
	remove_overlay(GLASSES_LAYER)
	remove_overlay(GLASSES_OVER_LAYER)
	remove_overlay(OVER_MASK_LAYER)
	remove_overlay(OVER_HEAD_LAYER)

	var/obj/item/organ/external/head/head_organ = get_organ(BODY_ZONE_HEAD)
	if(!head_organ)
		return

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_EYES) + 1]
		inv.update_icon()

	if(check_obscured_slots(check_transparent = TRUE) & ITEM_SLOT_EYES)
		return

	if(!glasses)
		return

	update_item_on_hud(glasses, ui_glasses, togleable_inventory = TRUE)
	var/glasses_layer = GLASSES_LAYER
	var/datum/sprite_accessory/hair/hair_style = GLOB.hair_styles_full_list[head_organ.h_style]
	var/obj/item/clothing/glasses/real_glasses = glasses
	var/is_real_glasses = istype(real_glasses)

	if(is_real_glasses && real_glasses.over_hat)
		glasses_layer = OVER_HEAD_LAYER
	else if(is_real_glasses && real_glasses.over_mask)
		glasses_layer = OVER_MASK_LAYER
	else if(hair_style?.glasses_over)
		glasses_layer = GLASSES_OVER_LAYER

	var/mutable_appearance/glasses_overlay = glasses.build_worn_icon(default_layer = glasses_layer, default_icon_file = glasses.onmob_sheets[ITEM_SLOT_EYES_STRING])
	overlays_standing[glasses_layer] = glasses_overlay
	apply_overlay(glasses_layer)

/mob/living/carbon/human/update_worn_ears()
	remove_overlay(EARS_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_EAR_LEFT) + 1]
		inv.update_icon()
		inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_EAR_RIGHT) + 1]
		inv.update_icon()

	var/obj/item/organ/external/head/head_organ = get_organ(BODY_ZONE_HEAD)
	if(!head_organ)
		return

	if(check_obscured_slots(check_transparent = TRUE) & ITEM_SLOT_EARS)
		return

	if(!l_ear && !r_ear)
		return

	var/mutable_appearance/standing = mutable_appearance(layer = -EARS_LAYER, appearance_flags = KEEP_TOGETHER)
	if(l_ear)
		update_item_on_hud(l_ear, ui_l_ear, togleable_inventory = TRUE)
		var/mutable_appearance/l_ear_olay = l_ear.build_worn_icon(default_layer = EARS_LAYER, default_icon_file = l_ear.onmob_sheets[ITEM_SLOT_EAR_LEFT_STRING], use_item_state = TRUE)
		standing.overlays += l_ear_olay

	if(r_ear)
		update_item_on_hud(r_ear, ui_r_ear, togleable_inventory = TRUE)
		var/mutable_appearance/r_ear_olay = r_ear.build_worn_icon(default_layer = EARS_LAYER, default_icon_file = r_ear.onmob_sheets[ITEM_SLOT_EAR_LEFT_STRING], use_item_state = TRUE)
		standing.overlays += r_ear_olay

	overlays_standing[EARS_LAYER] = standing
	apply_overlay(EARS_LAYER)

/mob/living/carbon/human/update_worn_shoes()
	remove_overlay(SHOES_LAYER)

	if(num_legs < 2 || check_obscured_slots(check_transparent = TRUE) & ITEM_SLOT_FEET)
		return

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_FEET) + 1]
		inv.update_icon()

	if(!shoes)
		if(!feet_blood_DNA)
			return
		overlays_standing[SHOES_LAYER] = mutable_appearance(dna.species.blood_mask, "shoeblood", layer = -SHOES_LAYER, color = feet_blood_color)
		apply_overlay(SHOES_LAYER)
		return

	update_item_on_hud(shoes, ui_shoes, togleable_inventory = TRUE)
	var/mutable_appearance/standing = shoes.build_worn_icon(default_layer = SHOES_LAYER, default_icon_file = shoes.onmob_sheets[ITEM_SLOT_FEET_STRING])

	overlays_standing[SHOES_LAYER] = standing
	apply_overlay(SHOES_LAYER)

/mob/living/carbon/human/update_suit_storage()
	remove_overlay(SUIT_STORE_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_SUITSTORE) + 1]
		inv.update_icon()

	if(!s_store)
		return

	update_item_on_hud(s_store, ui_sstore1)
	if(wear_suit?.flags_inv & HIDESUITSTORAGE)
		return

	overlays_standing[SUIT_STORE_LAYER] = s_store.build_worn_icon(default_layer = SUIT_STORE_LAYER, default_icon_file = s_store.onmob_sheets[ITEM_SLOT_SUITSTORE_STRING], use_item_state = TRUE)
	apply_overlay(SUIT_STORE_LAYER)

/mob/living/carbon/human/update_worn_head()
	remove_overlay(HEAD_LAYER)
	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_HEAD) + 1]
		inv.update_appearance()

	var/obj/item/organ/external/head/head_organ = get_organ(BODY_ZONE_HEAD)
	if(!head_organ)
		return

	if(!head)
		return

	update_item_on_hud(head, ui_head, togleable_inventory = TRUE)

	var/mutable_appearance/standing = head.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = head.onmob_sheets[ITEM_SLOT_HEAD_STRING])

	overlays_standing[HEAD_LAYER] = standing
	apply_overlay(HEAD_LAYER)

/mob/living/carbon/human/update_worn_belt()
	remove_overlay(BELT_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BELT) + 1]
		inv.update_icon()

	if(!belt)
		return

	update_item_on_hud(belt, ui_belt)
	overlays_standing[BELT_LAYER] = belt.build_worn_icon(default_layer = BELT_LAYER, default_icon_file = belt.onmob_sheets[ITEM_SLOT_BELT_STRING], use_item_state = TRUE)
	apply_overlay(BELT_LAYER)

/mob/living/carbon/human/update_worn_oversuit()
	remove_overlay(SUIT_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_CLOTH_OUTER) + 1]
		inv.update_icon()

	if(wear_suit)
		update_item_on_hud(wear_suit, ui_oclothing, togleable_inventory = TRUE)
		var/mutable_appearance/standing = wear_suit.build_worn_icon(default_layer = SUIT_LAYER, default_icon_file = wear_suit.onmob_sheets[ITEM_SLOT_CLOTH_OUTER_STRING])
		overlays_standing[SUIT_LAYER] = standing

	apply_overlay(SUIT_LAYER)
	update_tail_layer()
	update_wing_layer()
	update_collar()

/mob/living/carbon/human/update_pockets()
	if(!client || !hud_used)
		return

	var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_POCKET_LEFT) + 1]
	inv.update_icon()
	inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_POCKET_RIGHT) + 1]
	inv.update_icon()

	if(l_store)
		update_item_on_hud(l_store, ui_storage1)

	if(r_store)
		update_item_on_hud(r_store, ui_storage2)

/mob/living/carbon/human/update_worn_pda()
	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_PDA) + 1]
		inv?.update_icon()

	if(wear_pda)
		update_item_on_hud(wear_pda, ui_pda)

/mob/living/carbon/human/update_worn_mask()
	remove_overlay(FACEMASK_LAYER)

	var/obj/item/organ/external/head/head_organ = get_organ(BODY_ZONE_HEAD)
	if(!head_organ)
		return

	if(check_obscured_slots(check_transparent = TRUE) & ITEM_SLOT_MASK)
		return

	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1]
		inv.update_appearance()

	if(!wear_mask)
		return

	update_item_on_hud(wear_mask, ui_mask, togleable_inventory = TRUE)

	var/datum/sprite_accessory/alt_heads/alternate_head
	if(head_organ.alt_head && head_organ.alt_head != "None")
		alternate_head = GLOB.alt_heads_list[head_organ.alt_head]

	var/override_icon_state
	if(alternate_head)
		var/icon/icon_file = wear_mask.sprite_sheets?[dna.species.name] || wear_mask.onmob_sheets[ITEM_SLOT_MASK_STRING]
		var/alt_icon_state = "[wear_mask.icon_state]_[alternate_head.suffix]"
		override_icon_state = icon_exists(icon_file, alt_icon_state) ? alt_icon_state : null

	var/mutable_appearance/standing = wear_mask.build_worn_icon(default_layer = FACEMASK_LAYER, default_icon_file = wear_mask.onmob_sheets[ITEM_SLOT_MASK_STRING], override_state = override_icon_state)

	overlays_standing[FACEMASK_LAYER] = standing

	apply_overlay(FACEMASK_LAYER)

/mob/living/carbon/human/update_worn_neck()
	remove_overlay(NECK_LAYER)

	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1]
		inv.update_appearance()

	if(!neck)
		return

	update_item_on_hud(neck, ui_neck, togleable_inventory = TRUE)
	if(neck.flags_inv & HIDENECK)
		return

	overlays_standing[NECK_LAYER] = neck.build_worn_icon(default_layer = NECK_LAYER, default_icon_file = neck.onmob_sheets[ITEM_SLOT_NECK_STRING])

	apply_overlay(NECK_LAYER)

/mob/living/carbon/update_worn_back()
	remove_overlay(BACK_LAYER)

	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1]
		inv.update_appearance()

	if(!back)
		return

	overlays_standing[BACK_LAYER] = back.build_worn_icon(default_layer = BACK_LAYER, default_icon_file = back.onmob_sheets[ITEM_SLOT_BACK_STRING])
	update_item_on_hud(back, ui_back)

	apply_overlay(BACK_LAYER)

/mob/living/carbon/human/proc/update_wing_layer()
	remove_overlay(WING_UNDERLIMBS_LAYER)
	remove_overlay(WING_LAYER)

	var/obj/item/organ/external/wing/bodypart_wing = get_organ(BODY_ZONE_WING)
	if(!bodypart_wing)
		return

	if(!istype(bodypart_wing.body_accessory, /datum/body_accessory/wing))
		if(dna.species.optional_body_accessory)
			return
		bodypart_wing.body_accessory = GLOB.body_accessory_by_name[dna.species.default_bodyacc]

	var/mutable_appearance/wings = mutable_appearance(bodypart_wing.body_accessory.icon, bodypart_wing.body_accessory.icon_state, layer = -WING_LAYER)
	wings.pixel_w = bodypart_wing.body_accessory.pixel_x_offset
	wings.pixel_z = bodypart_wing.body_accessory.pixel_y_offset
	overlays_standing[WING_LAYER] = wings

	if(bodypart_wing.body_accessory.has_behind)
		var/mutable_appearance/under_wing = mutable_appearance(bodypart_wing.body_accessory.icon, "[bodypart_wing.body_accessory.icon_state]_BEHIND", layer = -WING_UNDERLIMBS_LAYER)
		under_wing.pixel_w = bodypart_wing.body_accessory.pixel_x_offset
		under_wing.pixel_z = bodypart_wing.body_accessory.pixel_y_offset
		overlays_standing[WING_UNDERLIMBS_LAYER] = under_wing

		var/icon/accessory_s = icon(bodypart_wing.body_accessory.icon, bodypart_wing.body_accessory.icon_state)
		var/icon/tempicon = icon(accessory_s, dir = NORTH)
		tempicon.Flip(SOUTH)
		accessory_s.Insert(tempicon, dir = SOUTH)
		bodypart_wing.force_icon = accessory_s
		bodypart_wing.icon_name = null

	bodypart_wing.get_icon()
	apply_overlay(WING_UNDERLIMBS_LAYER)
	apply_overlay(WING_LAYER)

/mob/living/carbon/human/proc/update_tail_layer()
	remove_overlay(TAIL_UNDERLIMBS_LAYER) // SEW direction icons, overlayed by LIMBS_LAYER.
	remove_overlay(TAIL_LAYER) /* This will be one of two things:
							If the species' tail is overlapped by limbs, this will be only the N direction icon so tails
							can still appear on the outside of uniforms and such.
							Otherwise, since the user's tail isn't overlapped by limbs, it will be a full icon with all directions. */

	var/obj/item/organ/external/tail/bodypart_tail = get_organ(BODY_ZONE_TAIL)
	if(!bodypart_tail) // No tail - no overlay!
		return

	var/icon/tail_marking_icon
	var/datum/sprite_accessory/body_markings/tail/tail_marking_style
	if(bodypart_tail.m_styles["tail"] != "None" && (bodypart_tail.dna.species.bodyflags & HAS_TAIL_MARKINGS))
		var/tail_marking = bodypart_tail.m_styles["tail"]
		tail_marking_style = GLOB.marking_styles_list[tail_marking]
		tail_marking_icon = new/icon("icon" = tail_marking_style.icon, "icon_state" = "[tail_marking_style.icon_state]_s")
		tail_marking_icon.Blend(bodypart_tail.m_colours["tail"], ICON_ADD)

	if(bodypart_tail.body_accessory)
		if(bodypart_tail.body_accessory.try_restrictions(src))
			var/icon/accessory_s = new/icon("icon" = bodypart_tail.body_accessory.icon, "icon_state" = bodypart_tail.body_accessory.icon_state)
			if(bodypart_tail.dna.species.bodyflags & HAS_SKIN_COLOR)
				if(!(bodypart_tail.dna.species.bodyflags & HAS_ICON_SKIN_TONE))
					accessory_s.Blend(bodypart_tail.s_col, bodypart_tail.body_accessory.blend_mode)
			if(tail_marking_icon && (bodypart_tail.body_accessory.name in tail_marking_style.tails_allowed))
				accessory_s.Blend(tail_marking_icon, ICON_OVERLAY)
			if(istype(bodypart_tail.body_accessory, /datum/body_accessory/tail) && bodypart_tail.dna.species.bodyflags & TAIL_OVERLAPPED) // If the player has a species whose tail is overlapped by limbs... (having a non-tail body accessory like the snake body will override this)
				// Gives the underlimbs layer SEW direction icons since it's overlayed by limbs and just about everything else anyway.
				var/icon/under = new/icon("icon" = 'icons/mob/clothing/body_accessory.dmi', "icon_state" = "accessory_none_s")
				under.Insert(new/icon(accessory_s, dir=SOUTH), dir=SOUTH)
				under.Insert(new/icon(accessory_s, dir=EAST), dir=EAST)
				under.Insert(new/icon(accessory_s, dir=WEST), dir=WEST)

				var/mutable_appearance/underlimbs = mutable_appearance(under, layer = -TAIL_UNDERLIMBS_LAYER)
				underlimbs.pixel_w = bodypart_tail.body_accessory.pixel_x_offset
				underlimbs.pixel_z = bodypart_tail.body_accessory.pixel_y_offset
				overlays_standing[TAIL_UNDERLIMBS_LAYER] = underlimbs

				// Creates a blank icon, and copies accessory_s' north direction sprite into it
				// before passing that to the tail layer that overlays uniforms and such.
				var/icon/over = new/icon("icon" = 'icons/mob/clothing/body_accessory.dmi', "icon_state" = "accessory_none_s")
				over.Insert(new/icon(accessory_s, dir=NORTH), dir=NORTH)

				var/mutable_appearance/tail = mutable_appearance(over, layer = -TAIL_LAYER)
				tail.pixel_w = bodypart_tail.body_accessory.pixel_x_offset
				tail.pixel_z = bodypart_tail.body_accessory.pixel_y_offset
				overlays_standing[TAIL_LAYER] = tail
			else // Otherwise, since the user's tail isn't overlapped by limbs, go ahead and use default icon generation.
				var/mutable_appearance/tail = mutable_appearance(accessory_s, layer = -TAIL_LAYER)
				tail.pixel_w = bodypart_tail.body_accessory.pixel_x_offset
				tail.pixel_z = bodypart_tail.body_accessory.pixel_y_offset
				overlays_standing[TAIL_LAYER] = tail

			var/icon/tempicon = new/icon(accessory_s,dir=NORTH)
			tempicon.Flip(SOUTH)
			accessory_s.Insert(tempicon,dir=SOUTH)
			bodypart_tail.force_icon = accessory_s
			bodypart_tail.icon_name = null

	else
		if(!wear_suit || !(wear_suit.flags_inv & HIDETAIL))
			var/icon/tail_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.tail]_s")
			switch(tail)
				if("voxtail_azu") //Azure Vox.
					tail_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.tail]_azu_s")
				if("voxtail_emrl") //Emerald Vox.
					tail_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.tail]_emrl_s")
				if("voxtail_gry") //Grey Vox.
					tail_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.tail]_gry_s")
				if("voxtail_brn") //Brown Vox.
					tail_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.tail]_brn_s")
				if("voxtail_dgrn") //Dark Green Vox.
					tail_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.tail]_dgrn_s")
				else  //Default behaviour
					tail_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.tail]_s")
			if(bodypart_tail.dna.species.bodyflags & HAS_SKIN_COLOR)
				if(!(bodypart_tail.dna.species.bodyflags & HAS_ICON_SKIN_TONE))
					tail_s.Blend(bodypart_tail.s_col, ICON_ADD)
			if(tail_marking_icon && !tail_marking_style.tails_allowed)
				tail_s.Blend(tail_marking_icon, ICON_OVERLAY)
			if(istype(bodypart_tail.body_accessory, /datum/body_accessory/tail) && bodypart_tail.dna.species.bodyflags & TAIL_OVERLAPPED) // If the player has a species whose tail is overlapped by limbs... (having a non-tail body accessory like the snake body will override this)
				// Gives the underlimbs layer SEW direction icons since it's overlayed by limbs and just about everything else anyway.
				var/icon/under = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "blank")
				under.Insert(new/icon(tail_s, dir=SOUTH), dir=SOUTH)
				under.Insert(new/icon(tail_s, dir=EAST), dir=EAST)
				under.Insert(new/icon(tail_s, dir=WEST), dir=WEST)

				overlays_standing[TAIL_UNDERLIMBS_LAYER] = mutable_appearance(under, layer = -TAIL_UNDERLIMBS_LAYER)

				// Creates a blank icon, and copies accessory_s' north direction sprite into it before passing that to the tail layer that overlays uniforms and such.
				var/icon/over = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "blank")
				over.Insert(new/icon(tail_s, dir=NORTH), dir=NORTH)

				overlays_standing[TAIL_LAYER] = mutable_appearance(over, layer = -TAIL_LAYER)
			else // Otherwise, since the user's tail isn't overlapped by limbs, go ahead and use default icon generation.
				overlays_standing[TAIL_LAYER] = mutable_appearance(tail_s, layer = -TAIL_LAYER)

			var/icon/tempicon = new/icon(tail_s,dir=NORTH)
			tempicon.Flip(SOUTH)
			tail_s.Insert(tempicon,dir=SOUTH)
			bodypart_tail.force_icon = tail_s
			bodypart_tail.icon_name = null
	bodypart_tail.get_icon()
	apply_overlay(TAIL_LAYER)
	apply_overlay(TAIL_UNDERLIMBS_LAYER)

/mob/living/carbon/human/proc/start_tail_wagging()
	remove_overlay(TAIL_UNDERLIMBS_LAYER) // SEW direction icons, overlayed by LIMBS_LAYER.
	remove_overlay(TAIL_LAYER) /* This will be one of two things:
							If the species' tail is overlapped by limbs, this will be only the N direction icon so tails
							can still appear on the outside of uniforms and such.
							Otherwise, since the user's tail isn't overlapped by limbs, it will be a full icon with all directions. */

	var/obj/item/organ/external/tail/bodypart_tail = get_organ(BODY_ZONE_TAIL)
	if(!bodypart_tail) // No tail - no overlay!
		return

	var/icon/tail_marking_icon
	var/datum/sprite_accessory/body_markings/tail/tail_marking_style
	if(bodypart_tail.m_styles["tail"] != "None" && (bodypart_tail.dna.species.bodyflags & HAS_TAIL_MARKINGS))
		var/tail_marking = bodypart_tail.m_styles["tail"]
		tail_marking_style = GLOB.marking_styles_list[tail_marking]
		tail_marking_icon = new/icon("icon" = tail_marking_style.icon, "icon_state" = "[tail_marking_style.icon_state]w_s")
		tail_marking_icon.Blend(bodypart_tail.m_colours["tail"], ICON_ADD)

	if(bodypart_tail.body_accessory)
		var/icon/accessory_s = new/icon("icon" = bodypart_tail.body_accessory.get_animated_icon(), "icon_state" = bodypart_tail.body_accessory.get_animated_icon_state())
		if(bodypart_tail.dna.species.bodyflags & HAS_SKIN_COLOR)
			if(!(bodypart_tail.dna.species.bodyflags & HAS_ICON_SKIN_TONE))
				accessory_s.Blend(bodypart_tail.s_col, bodypart_tail.body_accessory.blend_mode)
		if(tail_marking_icon && (bodypart_tail.body_accessory.name in tail_marking_style.tails_allowed))
			accessory_s.Blend(tail_marking_icon, ICON_OVERLAY)
		if(istype(bodypart_tail.body_accessory, /datum/body_accessory/tail) && bodypart_tail.dna.species.bodyflags & TAIL_OVERLAPPED) // If the player has a species whose tail is overlapped by limbs... (having a non-tail body accessory like the snake body will override this)
			// Gives the underlimbs layer SEW direction icons since it's overlayed by limbs and just about everything else anyway.
			var/icon/under = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.name]_tail_delay")
			under.Insert(new/icon(accessory_s, dir=SOUTH), dir=SOUTH)
			under.Insert(new/icon(accessory_s, dir=EAST), dir=EAST)
			under.Insert(new/icon(accessory_s, dir=WEST), dir=WEST)

			var/mutable_appearance/underlimbs = mutable_appearance(under, layer = -TAIL_UNDERLIMBS_LAYER)
			underlimbs.pixel_w = bodypart_tail.body_accessory.pixel_x_offset
			underlimbs.pixel_z = bodypart_tail.body_accessory.pixel_y_offset
			overlays_standing[TAIL_UNDERLIMBS_LAYER] = underlimbs

			// Creates a blank icon, and copies accessory_s' north direction sprite into it before passing that to the tail layer that overlays uniforms and such.
			var/icon/over = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.name]_tail_delay")
			over.Insert(new/icon(accessory_s, dir=NORTH), dir=NORTH)

			var/mutable_appearance/tail = mutable_appearance(over, layer = -TAIL_LAYER)
			tail.pixel_w = bodypart_tail.body_accessory.pixel_x_offset
			tail.pixel_z = bodypart_tail.body_accessory.pixel_y_offset
			overlays_standing[TAIL_LAYER] = tail
		else // Otherwise, since the user's tail isn't overlapped by limbs, go ahead and use default icon generation.
			var/mutable_appearance/tail = mutable_appearance(accessory_s, layer = -TAIL_LAYER)
			tail.pixel_w = bodypart_tail.body_accessory.pixel_x_offset
			tail.pixel_z = bodypart_tail.body_accessory.pixel_y_offset
			overlays_standing[TAIL_LAYER] = tail

	else
		var/icon/tailw_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.tail]w_s")
		switch(tail)
			if("voxtail_azu") //Azure Vox.
				tailw_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.tail]_azuw_s")
			if("voxtail_emrl") //Emerald Vox.
				tailw_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.tail]_emrlw_s")
			if("voxtail_gry") //Grey Vox.
				tailw_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.tail]_gryw_s")
			if("voxtail_brn") //Brown Vox.
				tailw_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.tail]_brnw_s")
			if("voxtail_dgrn") //Dark Green Vox.
				tailw_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.tail]_dgrnw_s")
			else  //Default behaviour
				tailw_s = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.tail]w_s")
		if(bodypart_tail.dna.species.bodyflags & HAS_SKIN_COLOR)
			if(!(bodypart_tail.dna.species.bodyflags & HAS_ICON_SKIN_TONE))
				tailw_s.Blend(bodypart_tail.s_col, ICON_ADD)
		if(tail_marking_icon && !tail_marking_style.tails_allowed)
			tailw_s.Blend(tail_marking_icon, ICON_OVERLAY)
		if(istype(bodypart_tail.body_accessory, /datum/body_accessory/tail) && bodypart_tail.dna.species.bodyflags & TAIL_OVERLAPPED) // If the player has a species whose tail is overlapped by limbs... (having a non-tail body accessory like the snake body will override this)
			// Gives the underlimbs layer SEW direction icons since it's overlayed by limbs and just about everything else anyway.
			var/icon/under = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.name]_tail_delay")
			under.Insert(new/icon(tailw_s, dir=SOUTH), dir=SOUTH)
			under.Insert(new/icon(tailw_s, dir=EAST), dir=EAST)
			under.Insert(new/icon(tailw_s, dir=WEST), dir=WEST)

			overlays_standing[TAIL_UNDERLIMBS_LAYER] = mutable_appearance(under, layer = -TAIL_UNDERLIMBS_LAYER)

			// Creates a blank icon, and copies accessory_s' north direction sprite into it before passing that to the tail layer that overlays uniforms and such.
			var/icon/over = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[bodypart_tail.dna.species.name]_tail_delay")
			over.Insert(new/icon(tailw_s, dir=NORTH), dir=NORTH)

			overlays_standing[TAIL_LAYER] = mutable_appearance(over, layer = -TAIL_LAYER)
		else // Otherwise, since the user's tail isn't overlapped by limbs, go ahead and use default icon generation.
			overlays_standing[TAIL_LAYER] = mutable_appearance(tailw_s, layer = -TAIL_LAYER)
	apply_overlay(TAIL_LAYER)
	apply_overlay(TAIL_UNDERLIMBS_LAYER)

/mob/living/carbon/human/proc/stop_tail_wagging()
	remove_overlay(TAIL_UNDERLIMBS_LAYER)
	remove_overlay(TAIL_LAYER)
	update_tail_layer() //just trigger a full update for normal stationary sprites

/mob/living/carbon/human/proc/update_int_organs()
	remove_overlay(INTORGAN_LAYER)

	var/list/standing = list()
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		var/render = organ.render()
		if(render)
			standing += render

	overlays_standing[INTORGAN_LAYER] = standing
	apply_overlay(INTORGAN_LAYER)

/mob/living/carbon/human/handle_transform_change()
	..()
	update_tail_layer()
	update_wing_layer()

//Adds a collar overlay above the helmet layer if the suit has one
//	Suit needs an identically named sprite in icons/mob/clothing/collar.dmi
//  For suits with sprite_sheets, an identically named sprite needs to exist in a file like this icons/mob/clothing/species/[species_name_here]/collar.dmi.
/mob/living/carbon/human/proc/update_collar()
	remove_overlay(COLLAR_LAYER)
	var/icon/C = null
	var/mutable_appearance/standing = null

	if(wear_suit)
		C = new(wear_suit.onmob_sheets[ITEM_SLOT_COLLAR_STRING])
		if(wear_suit.sprite_sheets && wear_suit.sprite_sheets[dna.species.name])
			var/icon_path = "[wear_suit.sprite_sheets[dna.species.name]]"
			icon_path = "[copytext(icon_path, 1, findtext(icon_path, "/suit.dmi"))]/collar.dmi" //If this file doesn't exist, the end result is that COLLAR_LAYER will be unchanged (empty).
			if(fexists(icon_path)) //Just ensuring the nonexistance of a file with the above path won't cause a runtime.
				var/icon/icon_file = new(icon_path)
				if(wear_suit.icon_state in icon_file.IconStates())
					standing = mutable_appearance(icon_file, "[wear_suit.icon_state]", layer = -COLLAR_LAYER)
		else
			if(wear_suit.icon_state in C.IconStates())
				standing = mutable_appearance(C, "[wear_suit.icon_state]", layer = -COLLAR_LAYER)

		overlays_standing[COLLAR_LAYER]	= standing
	apply_overlay(COLLAR_LAYER)

/mob/living/carbon/human/update_misc_effects()
	remove_overlay(MISC_LAYER)

	//Begin appending miscellaneous effects.
	if(eyes_shine())
		overlays_standing[MISC_LAYER] = get_eye_shine() //Image layer is specified in get_eye_shine() proc as LIGHTING_LAYER + 1.

	apply_overlay(MISC_LAYER)

/mob/living/carbon/human/admin_Freeze(client/admin, skip_overlays = TRUE, mech = null)
	if(..())
		overlays_standing[FROZEN_LAYER] = mutable_appearance(frozen, layer = -FROZEN_LAYER)
		apply_overlay(FROZEN_LAYER)
	else
		remove_overlay(FROZEN_LAYER)

/mob/living/carbon/human/proc/force_update_limbs(update_body = TRUE)
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		bodypart.sync_colour_to_human(src)
	if(update_body)
		update_body()

/mob/living/carbon/human/proc/get_overlays_copy(list/unwantedLayers)
	var/list/out = new
	for(var/i=1;i<=TOTAL_LAYERS;i++)
		if(overlays_standing[i])
			if(i in unwantedLayers)
				continue
			out += overlays_standing[i]
	return out

/mob/living/carbon/human/proc/generate_icon_render_key()
	var/husk = HAS_TRAIT(src, TRAIT_HUSK)
	var/hulk = HAS_TRAIT(src, TRAIT_HULK)
	var/skeleton = HAS_TRAIT(src, TRAIT_SKELETON)
	var/g = dna.GetUITriState(DNA_UI_GENDER)
	if(g == DNA_GENDER_PLURAL)
		g = DNA_GENDER_FEMALE

	. = ""

	var/obj/item/organ/internal/eyes/eyes = get_int_organ(/obj/item/organ/internal/eyes)
	if(eyes)
		. += "[eyes.eye_colour]"
	else
		. += "#000000"

	if(lip_color && HAS_TRAIT(src, TRAIT_HAS_LIPS))
		. += "[lip_color]"
	else
		. += "#000000"

	for(var/limb_zone in dna.species.has_limbs)
		var/obj/item/organ/external/part = bodyparts_by_name[limb_zone]
		if(isnull(part))
			. += "0"
		else if(part.is_robotic())
			. += "2[part.model ? "-[part.model]" : ""]"
		else if(part.is_dead())
			. += "3"
		else
			. += "1"

		if(part)
			var/datum/species/S = GLOB.all_species[part.dna.species.name]
			. += "[S.race_key]"
			. += "[part.dna.GetUIValue(DNA_UI_SKIN_TONE)]"
			. += "[g]"
			if(part.s_col)
				. += "[part.s_col]"
			if(part.s_tone)
				. += "[part.s_tone]"

	var/list/bonus_info = list()
	SEND_SIGNAL(src, COMSIG_GET_ICON_RENDER_KEY_INFO, bonus_info)
	for(var/info in bonus_info)
		. += "[info]"

	. = "[.][!!husk][!!hulk][!!skeleton]"

/mob/living/carbon/human/update_ssd_overlay()
	if(!isnull(player_logged))
		overlays_standing[SSD_LAYER] = mutable_appearance('icons/effects/effects.dmi', "SSD", -SSD_LAYER, appearance_flags = KEEP_APART|RESET_TRANSFORM|RESET_COLOR)
		apply_overlay(SSD_LAYER)
	else
		remove_overlay(SSD_LAYER)

/mob/living/carbon/human/update_unconscious_overlay()
	if(stat == UNCONSCIOUS && !HAS_TRAIT(src, TRAIT_FAKEDEATH))
		var/mutable_appearance/sleep_effect = mutable_appearance('icons/effects/effects.dmi', "sleep", -SLEEP_LAYER, appearance_flags = KEEP_APART|RESET_TRANSFORM|RESET_COLOR)
		sleep_effect.pixel_z = 8
		overlays_standing[SLEEP_LAYER] = sleep_effect
		apply_overlay(SLEEP_LAYER)
	else
		remove_overlay(SLEEP_LAYER)

/// Overlays for the worn overlay so you can overlay while you overlay
/// eg: ammo counters, primed grenade flashing, etc.
/// "icon_file" is used automatically for inhands etc. to make sure it gets the right inhand file
/obj/item/proc/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	. = list()
	if(blocks_emissive != EMISSIVE_BLOCK_NONE)
		. += emissive_blocker(standing.icon, standing.icon_state, src)
	SEND_SIGNAL(src, COMSIG_ITEM_GET_WORN_OVERLAYS, ., standing, isinhands, icon_file)

/// worn_overlays to use when you'd want to use KEEP_APART. Don't use KEEP_APART neither there nor here, as it would break floating overlays
/obj/item/proc/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands = FALSE, icon_file)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)
	. = list()
	SEND_SIGNAL(src, COMSIG_ITEM_GET_SEPARATE_WORN_OVERLAYS, ., standing, draw_target, isinhands, icon_file)

/*
Does everything in relation to building the /mutable_appearance used in the mob's overlays list
covers:
Inhands and any other form of worn item
Rentering large appearances
Layering appearances on custom layers
Building appearances from custom icon files

By Remie Richards (yes I'm taking credit because this just removed 90% of the copypaste in update_icons())

state: A string to use as the state, this is FAR too complex to solve in this proc thanks to shitty old code
so it's specified as an argument instead.

default_layer: The layer to draw this on if no other layer is specified

default_icon_file: The icon file to draw states from if no other icon file is specified

isinhands: If true then alternate_worn_icon is skipped so that default_icon_file is used,
in this situation default_icon_file is expected to match either the lefthand_ or righthand_ file var

use_item_state: SS1984 legacy var, used to fix fact, that item_state randomly used in different parts. If you sorted out all onmob files you can delete it.

*/
/obj/item/proc/build_worn_icon(
	default_layer = 0,
	default_icon_file = null,
	isinhands = FALSE,
	override_state = null,
	override_file = null,
	use_item_state = FALSE
)

	var/mob/living/carbon/wearer = loc
	var/species
	if(istype(wearer))
		species = wearer?.dna?.species.name

	//Find a valid icon_state from variables+arguments
	var/t_state = override_state || (isinhands || use_item_state) && item_state || icon_state
	//Find a valid icon file from variables+arguments
	var/file2use = override_file || (species ? (isinhands ? sprite_sheets_inhand?[species] : sprite_sheets?[species]) : null)  || default_icon_file
	//Find a valid layer from variables+arguments
	var/layer2use = default_layer

	var/mutable_appearance/draw_target // MA of the item itself, not the final result

	draw_target = mutable_appearance(file2use, t_state, layer = -layer2use)

	//Get the overlays for this item when it's being worn
	//eg: ammo counters, primed grenade flashes, etc.
	var/list/worn_overlays = worn_overlays(draw_target, isinhands, file2use)
	if(length(worn_overlays))
		draw_target.overlays += worn_overlays
	//draw_target = color_atom_overlay(draw_target)

	// Okay so this has to be done because some overlays, like blood, want to be KEEP_APART
	// but KEEP_APART breaks float layering, so what we need to do is make fake KEEP_APART for us to use
	var/mutable_appearance/standing = mutable_appearance(layer = -layer2use, appearance_flags = KEEP_TOGETHER)
	standing.overlays += draw_target
	var/list/separate_overlays = separate_worn_overlays(standing, draw_target, isinhands, file2use)
	if(length(separate_overlays))
		standing.overlays += separate_overlays
	else // Don't nest overlays if there's nothing to nest against
		standing.overlays -= draw_target
		standing = draw_target

	standing = center_image(standing, isinhands ? inhand_x_dimension : worn_x_dimension, isinhands ? inhand_y_dimension : worn_y_dimension)

	standing.alpha = alpha
	standing.color = color

	return standing

