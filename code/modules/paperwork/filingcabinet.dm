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
	desc = "Высокий шкаф с ящиками."
	ru_names = list(
		NOMINATIVE = "высокий шкаф с ящиками",
		GENITIVE = "высокого шкафа с ящиками",
		DATIVE = "высокому шкафу с ящиками",
		ACCUSATIVE = "высокий шкаф с ящиками",
		INSTRUMENTAL = "высоким шкафом с ящиками",
		PREPOSITIONAL = "высоком шкафе с ящиками"
	)
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "filingcabinet"
	density = TRUE
	anchored = TRUE
	var/opened = FALSE


/obj/structure/filingcabinet/chestdrawer
	name = "chest drawer"
	desc = "Шкаф с ящиками."
	ru_names = list(
		NOMINATIVE = "шкаф с ящиками",
		GENITIVE = "шкафа с ящиками",
		DATIVE = "шкафу с ящиками",
		ACCUSATIVE = "шкаф с ящиками",
		INSTRUMENTAL = "шкафом с ящиками",
		PREPOSITIONAL = "шкафе с ящиками"
	)
	icon_state = "chestdrawer"

/obj/structure/filingcabinet/chestdrawer/autopsy
	name = "autopsy reports drawer"
	desc = "Большой ящик для хранения отчетов о вскрытии."
	ru_names = list(
		NOMINATIVE = "ящик для хранения отчётов о вскрытиях",
		GENITIVE = "ящика для хранения отчётов о вскрытиях",
		DATIVE = "ящику для хранения отчётов о вскрытиях",
		ACCUSATIVE = "ящик для хранения отчётов о вскрытиях",
		INSTRUMENTAL = "ящиком для хранения отчётов о вскрытиях",
		PREPOSITIONAL = "ящике для хранения отчётов о вскрытиях"
	)

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
		balloon_alert(user, "предмет положен")
		opened = TRUE
		update_icon(UPDATE_ICON_STATE)
		sleep(0.5 SECONDS)
		opened = FALSE
		update_icon(UPDATE_ICON_STATE)
		updateUsrDialog()
		return ATTACK_CHAIN_BLOCKED_ALL

	balloon_alert(user, "невозможно положить!")
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
		balloon_alert(user, "пусто")
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
			balloon_alert(user, "вы наугад вытащили [I]")
			return
	balloon_alert(user, "вы ничего не нашли")

/obj/structure/filingcabinet/Topic(href, href_list)
	if(href_list["retrieve"])
		close_window(usr, "filingcabinet")		// Close the menu

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
			P.info = "<center><b>Запись Службы Безопасности</b></center><br>"
			P.info += "Имя: [G.fields["name"]] ID: [G.fields["id"]]<br>\nПол: [G.fields["sex"]]<br>\nВозраст: [G.fields["age"]]<br>\nХэш отпечатков пальцев: [G.fields["fingerprint"]]<br>\nФизическое состояние: [G.fields["p_stat"]]<br>\nПсихологическое состояние: [G.fields["m_stat"]]<br>"
			P.info += "<br>\n<center><b>Данные Службы Безопасности</b></center><br>\nСтатус: [S.fields["criminal"]]<br>\n<br>\nНезначительные преступления: [S.fields["mi_crim"]]<br>\nДетали: [S.fields["mi_crim_d"]]<br>\n<br>\nТяжкие преступления: [S.fields["ma_crim"]]<br>\nДетали: [S.fields["ma_crim_d"]]<br>\n<br>\nВажные примечания:<br>\n\t[S.fields["notes"]]<br>\n<br>\n<center><b>Комментарии/Log</b></center><br>"
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
			P.info = "<center><b>Медицинские Записи</b></center><br>"
			P.info += "Имя: [G.fields["name"]] ID: [G.fields["id"]]<br>\nПол: [G.fields["sex"]]<br>\nВозраст: [G.fields["age"]]<br>\nХэш отпечатков пальцев: [G.fields["fingerprint"]]<br>\nФизическое состояние: [G.fields["p_stat"]]<br>\nПсихологическое состояние: [G.fields["m_stat"]]<br>"
			P.info += "<br>\n<center><b>Медицинская Информация</b></center><br>\nГруппа крови: [M.fields["b_type"]]<br>\nДНК: [M.fields["b_dna"]]<br>\n<br>\nНезначительные отклонения: [M.fields["mi_dis"]]<br>\nДетали: [M.fields["mi_dis_d"]]<br>\n<br>\nИнвалидности: [M.fields["ma_dis"]]<br>\nДетали: [M.fields["ma_dis_d"]]<br>\n<br>\nАллергии: [M.fields["alg"]]<br>\nДетали: [M.fields["alg_d"]]<br>\n<br>\nТекущие заболевания: [M.fields["cdi"]] (информация о заболевании, размещенная в разделе комментария)<br>\nДетали: [M.fields["cdi_d"]]<br>\n<br>\nВажные примечания:<br>\n\t[M.fields["notes"]]<br>\n<br>\n<center><b>Комментарии/Записи</b></center><br>"
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
		balloon_alert(user, "заклинило, подождите!")
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
