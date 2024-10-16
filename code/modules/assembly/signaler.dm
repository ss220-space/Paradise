/obj/item/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices."
	icon_state = "signaller"
	item_state = "signaler"
	materials = list(MAT_METAL=400, MAT_GLASS=120)
	origin_tech = "magnets=1;bluespace=1"
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE

	secured = TRUE
	var/receiving = FALSE

	bomb_name = "remote-control bomb"

	var/code = 30
	var/frequency = RSD_FREQ
	var/delay = 0
	var/datum/radio_frequency/radio_connection
	var/airlock_wire = null


/obj/item/assembly/signaler/Initialize()
	. = ..()
	if(SSradio)
		set_frequency(frequency)


/obj/item/assembly/signaler/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()


/obj/item/assembly/signaler/examine(mob/user)
	. = ..()
	. += span_notice("The power light is <b>[receiving ? "on" : "off"]</b>.")
	. += span_info("<b>Alt+Click</b> to send a signal.")


/obj/item/assembly/signaler/AltClick(mob/user)
	if(!isliving(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return ..()

	SEND_SIGNAL(user, COMSIG_CLICK_ALT, src, user)
	to_chat(user, span_notice("You activate [src]."))
	activate()


/obj/item/assembly/signaler/activate()
	if(cooldown > 0)
		return FALSE
	cooldown = 2
	addtimer(CALLBACK(src, PROC_REF(process_cooldown)), 10)

	signal()
	return TRUE


/obj/item/assembly/signaler/update_icon_state()
	holder?.update_icon()


/obj/item/assembly/signaler/interact(mob/user, flag1)
	var/t1 = "-------"
	var/dat = {"<meta charset="UTF-8">
		<TT>
	"}
	if(!flag1)
		dat += {"
			<A href='byond://?src=[UID()];send=1'>Send Signal</A><BR>
			Receiver is <A href='byond://?src=[UID()];receive=1'>[receiving?"on":"off"]</A><BR>
		"}
	dat += {"
		<B>Frequency/Code</B> for signaler:<BR>
		Frequency:
		<A href='byond://?src=[UID()];freq=-10'>-</A>
		<A href='byond://?src=[UID()];freq=-2'>-</A>
		[format_frequency(frequency)]
		<A href='byond://?src=[UID()];freq=2'>+</A>
		<A href='byond://?src=[UID()];freq=10'>+</A><BR>

		Code:
		<A href='byond://?src=[UID()];code=-5'>-</A>
		<A href='byond://?src=[UID()];code=-1'>-</A>
		[code]
		<A href='byond://?src=[UID()];code=1'>+</A>
		<A href='byond://?src=[UID()];code=5'>+</A><BR>
		[t1]
		</TT>
	"}
	var/datum/browser/popup = new(user, "radio", name, 400, 400)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "radio")


/obj/item/assembly/signaler/Topic(href, href_list)
	..()

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || !in_range(loc, usr))
		usr << browse(null, "window=radio")
		onclose(usr, "radio")
		return

	if(href_list["freq"])
		var/new_frequency = (frequency + text2num(href_list["freq"]))
		if(new_frequency < RADIO_LOW_FREQ || new_frequency > RADIO_HIGH_FREQ)
			new_frequency = sanitize_frequency(new_frequency, RADIO_LOW_FREQ, RADIO_HIGH_FREQ)
		set_frequency(new_frequency)

	if(href_list["code"])
		code += text2num(href_list["code"])
		code = round(code)
		code = min(100, code)
		code = max(1, code)

	if(href_list["receive"])
		receiving = !receiving

	if(href_list["send"])
		INVOKE_ASYNC(src, PROC_REF(signal))

	if(usr)
		attack_self(usr)


/obj/item/assembly/signaler/proc/signal()
	if(!radio_connection)
		return

	var/datum/signal/signal = new
	signal.source = src
	signal.encryption = code
	signal.data["message"] = "ACTIVATE"
	signal.user = usr
	radio_connection.post_signal(src, signal)

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	if(usr)
		GLOB.lastsignalers.Add("[time] <B>:</B> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")


/obj/item/assembly/signaler/receive_signal(datum/signal/signal)
	if(!receiving || !signal)
		return FALSE

	if(signal.encryption != code)
		return FALSE

	if(!(wires & WIRE_RADIO_RECEIVE))
		return FALSE
	pulse(1, signal.user)

	for(var/mob/hearer in hearers(1, loc))
		hearer.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)
	return TRUE


/obj/item/assembly/signaler/proc/set_frequency(new_frequency)
	if(!SSradio)
		return
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_CHAT)

