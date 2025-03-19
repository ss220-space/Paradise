/* Filing cabinets!
 * Contains:
 *		Filing Cabinets
 *		Security Record Cabinets
 *		Medical Record Cabinets
 */


/*
 * Filing Cabinets
 */
/obj/structure/filingcabinet
	name = "filing cabinet"
	desc = "A large cabinet with drawers."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "filingcabinet"
	density = TRUE
	anchored = TRUE
	var/opened = FALSE


/obj/structure/filingcabinet/chestdrawer
	name = "chest drawer"
	icon_state = "chestdrawer"

/obj/structure/filingcabinet/chestdrawer/autopsy
	name = "autopsy reports drawer"
	desc = "A large drawer for holding autopsy reports."

/obj/structure/filingcabinet/filingcabinet	//not changing the path to avoid unecessary map issues, but please don't name stuff like this in the future -Pete
	icon_state = "tallcabinet"


/obj/structure/filingcabinet/Initialize(mapload)
	. = ..()
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/paper) || istype(I, /obj/item/folder) || istype(I, /obj/item/photo))
			I.loc = src


/obj/structure/filingcabinet/update_icon_state()
	icon_state = "[initial(icon_state)][opened ? "-open" : ""]"


/obj/structure/filingcabinet/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	add_fingerprint(user)
	var/static/list/allowed_to_store = typecacheof(list(
		/obj/item/paper,
		/obj/item/folder,
		/obj/item/photo,
		/obj/item/paper_bundle,
		/obj/item/documents,
	))
	if(is_type_in_typecache(I, allowed_to_store))
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You put [I] into [src]."))
		opened = TRUE
		update_icon(UPDATE_ICON_STATE)
		sleep(0.5 SECONDS)
		opened = FALSE
		update_icon(UPDATE_ICON_STATE)
		updateUsrDialog()
		return ATTACK_CHAIN_BLOCKED_ALL

	to_chat(user, span_warning("You cannot put [I] into [src]!"))
	return ATTACK_CHAIN_PROCEED


/obj/structure/filingcabinet/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/structure/filingcabinet/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 2)
		for(var/obj/item/I in src)
			I.forceMove(loc)
	qdel(src)

/obj/structure/filingcabinet/attack_hand(mob/user)
	if(!length(contents))
		to_chat(user, "<span class='notice'>[src] is empty.</span>")
		return

	add_fingerprint(user)
	user.set_machine(src)
	var/dat = {"<meta charset="UTF-8"><center><table>"}
	for(var/obj/item/P in src)
		dat += "<tr><td><a href='byond://?src=[UID()];retrieve=\ref[P]'>[P.name]</a></td></tr>"
	dat += "</table></center>"
	var/datum/browser/popup = new(user, "filingcabinet", name, 350, 300)
	popup.set_content(dat)
	popup.open(FALSE)

	return

/obj/structure/filingcabinet/attack_tk(mob/user)
	if(anchored)
		attack_self_tk(user)
	else
		..()

/obj/structure/filingcabinet/attack_self_tk(mob/user)
	if(length(contents))
		if(prob(40 + (length(contents) * 5)))
			var/obj/item/I = pick(contents)
			I.loc = loc
			if(prob(25))
				step_rand(I)
			to_chat(user, "<span class='notice'>You pull \a [I] out of [src] at random.</span>")
			return
	to_chat(user, "<span class='notice'>You find nothing in [src].</span>")

/obj/structure/filingcabinet/Topic(href, href_list)
	if(href_list["retrieve"])
		usr << browse(null, "window=filingcabinet") // Close the menu

		//var/retrieveindex = text2num(href_list["retrieve"])
		var/obj/item/P = locate(href_list["retrieve"])//contents[retrieveindex]
		if(istype(P) && (P.loc == src) && src.Adjacent(usr))
			P.forceMove_turf()
			usr.put_in_hands(P, ignore_anim = FALSE)
			updateUsrDialog()
			opened = TRUE
			update_icon(UPDATE_ICON_STATE)
			sleep(5)
			opened = FALSE
			update_icon(UPDATE_ICON_STATE)


/*
 * Security Record Cabinets
 */
/obj/structure/filingcabinet/security
	var/populated = FALSE


/obj/structure/filingcabinet/security/proc/populate()
	if(!populated)
		for(var/datum/data/record/G in GLOB.data_core.general)
			var/datum/data/record/S
			for(var/datum/data/record/R in GLOB.data_core.security)
				if(R.fields["name"] == G.fields["name"] || R.fields["id"] == G.fields["id"])
					S = R
					break
			var/obj/item/paper/P = new /obj/item/paper(src)
			P.info = "<center><b>Security Record</b></center><br>"
			P.info += "Name: [G.fields["name"]] ID: [G.fields["id"]]<br>\nSex: [G.fields["sex"]]<br>\nAge: [G.fields["age"]]<br>\nFingerprint: [G.fields["fingerprint"]]<br>\nPhysical Status: [G.fields["p_stat"]]<br>\nMental Status: [G.fields["m_stat"]]<br>"
			P.info += "<br>\n<center><b>Security Data</b></center><br>\nCriminal Status: [S.fields["criminal"]]<br>\n<br>\nMinor Crimes: [S.fields["mi_crim"]]<br>\nDetails: [S.fields["mi_crim_d"]]<br>\n<br>\nMajor Crimes: [S.fields["ma_crim"]]<br>\nDetails: [S.fields["ma_crim_d"]]<br>\n<br>\nImportant Notes:<br>\n\t[S.fields["notes"]]<br>\n<br>\n<center><b>Comments/Log</b></center><br>"
			for(var/c in S.fields["comments"])
				P.info += "[c]<br>"
			P.name = "paper - '[G.fields["name"]]'"
			populated = TRUE	//tabbing here is correct- it's possible for people to try and use it
						//before the records have been generated, so we do this inside the loop.

/obj/structure/filingcabinet/security/attack_hand()
	populate()
	..()

/obj/structure/filingcabinet/security/attack_tk()
	populate()
	..()

/*
 * Medical Record Cabinets
 */
/obj/structure/filingcabinet/medical
	var/populated = FALSE

/obj/structure/filingcabinet/medical/proc/populate()
	if(!populated)
		for(var/datum/data/record/G in GLOB.data_core.general)
			var/datum/data/record/M
			for(var/datum/data/record/R in GLOB.data_core.medical)
				if(R.fields["name"] == G.fields["name"] || R.fields["id"] == G.fields["id"])
					M = R
					break
			var/obj/item/paper/P = new /obj/item/paper(src)
			P.info = "<center><b>Medical Record</b></center><br>"
			P.info += "Name: [G.fields["name"]] ID: [G.fields["id"]]<br>\nSex: [G.fields["sex"]]<br>\nAge: [G.fields["age"]]<br>\nFingerprint: [G.fields["fingerprint"]]<br>\nPhysical Status: [G.fields["p_stat"]]<br>\nMental Status: [G.fields["m_stat"]]<br>"
			P.info += "<br>\n<center><b>Medical Data</b></center><br>\nBlood Type: [M.fields["b_type"]]<br>\nDNA: [M.fields["b_dna"]]<br>\n<br>\nMinor Disabilities: [M.fields["mi_dis"]]<br>\nDetails: [M.fields["mi_dis_d"]]<br>\n<br>\nMajor Disabilities: [M.fields["ma_dis"]]<br>\nDetails: [M.fields["ma_dis_d"]]<br>\n<br>\nAllergies: [M.fields["alg"]]<br>\nDetails: [M.fields["alg_d"]]<br>\n<br>\nCurrent Diseases: [M.fields["cdi"]] (per disease info placed in log/comment section)<br>\nDetails: [M.fields["cdi_d"]]<br>\n<br>\nImportant Notes:<br>\n\t[M.fields["notes"]]<br>\n<br>\n<center><b>Comments/Log</b></center><br>"
			for(var/c in M.fields["comments"])
				P.info += "[c]<br>"
			P.name = "paper - '[G.fields["name"]]'"
			populated = TRUE	//tabbing here is correct- it's possible for people to try and use it
						//before the records have been generated, so we do this inside the loop.

/obj/structure/filingcabinet/medical/attack_hand()
	populate()
	..()

/obj/structure/filingcabinet/medical/attack_tk()
	populate()
	..()

/*
 * Employment contract Cabinets
 */

GLOBAL_LIST_EMPTY(employmentCabinets)

/obj/structure/filingcabinet/employment
	var/cooldown = FALSE // Only used for devils
	icon_state = "employmentcabinet"
	var/populated = FALSE

/obj/structure/filingcabinet/employment/Initialize(mapload)
	. = ..()
	GLOB.employmentCabinets += src

/obj/structure/filingcabinet/employment/Destroy()
	GLOB.employmentCabinets -= src
	return ..()

/obj/structure/filingcabinet/employment/proc/fillCurrent()
	//This proc fills the cabinet with the current crew.
	for(var/record in GLOB.data_core.locked)
		var/datum/data/record/G = record
		if(!G)
			continue
		if(G.fields["reference"])
			addFile(G.fields["reference"])


/obj/structure/filingcabinet/employment/proc/addFile(mob/living/carbon/human/employee)
	new /obj/item/paper/contract/employment(src, employee)

/obj/structure/filingcabinet/employment/attack_hand(mob/user)
	if(cooldown)
		to_chat(user, "<span class='warning'>[src] is jammed, give it a few seconds.</span>")
	else
		if(!populated)
			add_fingerprint(user)
			fillCurrent()
			populated = TRUE
		if(user.mind.special_role != "devil")
			return ..()

		else
			cooldown = TRUE
			..()
			sleep(10 SECONDS) // prevents the devil from just instantly emptying the cabinet, ensuring an easy win.
			cooldown = FALSE
