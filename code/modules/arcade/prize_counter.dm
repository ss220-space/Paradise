
/obj/machinery/prize_counter
	name = "Prize Counter"
	desc = "A machine which exchanges tickets for a variety of fabulous prizes!"
	icon = 'icons/obj/machines/arcade.dmi'
	icon_state = "prize_counter-on"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	var/tickets = 0

/obj/machinery/prize_counter/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/prize_counter(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()


/obj/machinery/prize_counter/update_icon_state()
	if(stat & BROKEN)
		icon_state = "prize_counter-broken"
	else if(panel_open)
		icon_state = "prize_counter-open"
	else if(stat & NOPOWER)
		icon_state = "prize_counter-off"
	else
		icon_state = "prize_counter-on"


/obj/machinery/prize_counter/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/tickets))
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		add_fingerprint(user)
		var/obj/item/stack/tickets/new_tickets = I
		tickets += new_tickets.amount
		qdel(new_tickets)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/prize_counter/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!panel_open)
		to_chat(user, span_warning("Open the service panel first."))
		return .
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume) || !panel_open)
		return .
	if(tickets)		//save the tickets!
		print_tickets()
	to_chat(user, span_notice("You disassemble [src]."))
	deconstruct(TRUE)


/obj/machinery/prize_counter/screwdriver_act(mob/living/user, obj/item/I)
	if(!anchored)
		return FALSE
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	update_icon(UPDATE_ICON_STATE)
	return TRUE


/obj/machinery/snow_machine/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!panel_open)
		return .
	default_unfasten_wrench(user, I)


/obj/machinery/prize_counter/attack_hand(mob/user)
	if(..())
		return
	add_fingerprint(user)
	interact(user)

/obj/machinery/prize_counter/interact(mob/user)
	user.set_machine(src)

	if(stat & (BROKEN|NOPOWER))
		return

	var/dat = {"
	<p style="float:right"><b>Tickets: [tickets]</b> | <a href='byond://?src=[UID()];eject=1'>Eject Tickets</a></p>
	<h1>Arcade Ticket Exchange</h1>
	<p>
		<b>Exchange that pile of tickets for a pile of cool prizes!</b>
	</p>
	<br>
	<table cellspacing="0" cellpadding="0">
		<caption><b>Available Prizes:</b></caption>
		<thead>
			<th>#</th>
			<th>Name/Description</th>
			<th>Tickets</th>
		</thead>
		<tbody>
	"}

	for(var/datum/prize_item/item in GLOB.global_prizes.prizes)
		var/cost_class="affordable"
		if(item.cost>tickets)
			cost_class="toomuch"
		var/itemID = GLOB.global_prizes.prizes.Find(item)
		var/row_color="light"
		if(itemID%2 == 0)
			row_color="dark"
		dat += {"
			<tr class="[row_color]">
				<th>
					[itemID]
				</th>
				<td>
					<p><b>[item.name]</b></p>
					<p>[item.desc]</p>
				</td>
		"}
		dat += {"
				<th class="cost [cost_class]">
					<a href="byond://?src=[UID()];buy=[itemID]" class="button">[item.cost]</a>
				</th>
			</tr>
		"}

	dat += {"
		</tbody>
	</table>"}
	var/datum/browser/popup = new(user, "prize_counter", "Arcade Ticket Exchange", 440, 600)
	popup.set_content(dat)
	popup.set_window_options("can_resize=0;")
	popup.add_stylesheet("prize_counter", 'html/css/prize_counter.css')
	popup.open(FALSE)
	onclose(user, "prize_counter")
	return

/obj/machinery/prize_counter/Topic(href, href_list)
	if(..())
		return 1

	add_fingerprint(usr)

	if(href_list["eject"])
		print_tickets()

	if(href_list["buy"])
		var/itemID = text2num(href_list["buy"])
		var/datum/prize_item/item = GLOB.global_prizes.prizes[itemID]
		var/sure = tgui_alert(usr,"Are you sure you wish to purchase [item.name] for [item.cost] tickets?", "You sure?", list("Yes","No"))
		if(sure != "Yes")
			updateUsrDialog()
			return
		if(!GLOB.global_prizes.PlaceOrder(src, itemID))
			to_chat(usr, "<span class='warning'>Unable to complete the exchange.</span>")
		else
			to_chat(usr, "<span class='notice'>You've successfully purchased the item.</span>")

	interact(usr)
	return

/obj/machinery/prize_counter/proc/print_tickets()
	if(!tickets)
		return
	if(tickets >= 9999)
		new /obj/item/stack/tickets(get_turf(src), 9999)	//max stack size
		tickets -= 9999
		print_tickets()
	else
		new /obj/item/stack/tickets(get_turf(src), tickets)
		tickets = 0
