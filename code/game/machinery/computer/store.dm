/obj/machinery/computer/merch
	name = "merch computer"
	icon = 'icons/obj/machines/computer.dmi'
	icon_screen = "comm_logs"
	circuit = /obj/item/circuitboard/merch

	light_color = LIGHT_COLOR_GREEN

/obj/item/circuitboard/merch
	board_name = "Merchandise Computer"
	build_path = /obj/machinery/computer/merch

/obj/machinery/computer/merch/New()
	..()

/obj/machinery/computer/merch/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/merch/attack_hand(mob/user as mob)
	user.set_machine(src)

	if(stat & (BROKEN|NOPOWER))
		return

	if(..())
		return TRUE

	var/balance=0
	if(user.mind)
		if(user.mind.initial_account)
			add_fingerprint(user)
			balance = user.mind.initial_account.money
	var/dat = {"
	<p style="float:right"><a href='byond://?src=[UID()];refresh=1'>Refresh</a> | <b>Balance: $[balance]</b></p>
	<h1>[command_name()] Merchandise</h1>
	<p>
		<b>Doing your job and not getting any recognition at work?</b>  Well, welcome to the
		merch shop!  Here, you can buy cool things in exchange for money you earn when you've
		completed your Job Objectives.
	</p>
	<p>Work hard. Get cash. Acquire bragging rights.</p>
	<br>
	<table cellspacing="0" cellpadding="0">
		<caption><b>In Stock:</b></caption>
		<thead>
			<th>#</th>
			<th>Name/Description</th>
			<th>Price</th>
		</thead>
		<tbody>
	"}
	for(var/datum/storeitem/item in GLOB.centcomm_store.items)
		var/cost_class="affordable"
		if(item.cost>balance)
			cost_class="toomuch"
		var/itemID=GLOB.centcomm_store.items.Find(item)
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
				<th class="cost [cost_class]">
					<a href="byond://?src=[UID()];buy=[itemID]" class="button">$[item.cost]</a>
				</th>
			</tr>
		"}
	dat += {"
		</tbody>
	</table>"}
	var/datum/browser/popup = new(user, "merch", "[command_name()] Merchandise", 440, 600)
	popup.set_content(dat)
	popup.set_window_options("can_resize=0;")
	popup.add_stylesheet("merch_computer", 'html/css/merch_computer.css')
	popup.open(TRUE)
	onclose(user, "merch")
	return

/obj/machinery/computer/merch/Topic(href, href_list)
	if(..())
		return 1

	//testing(href)

	src.add_fingerprint(usr)

	if(href_list["buy"])
		var/itemID = text2num(href_list["buy"])
		var/datum/storeitem/item = GLOB.centcomm_store.items[itemID]
		var/sure = alert(usr,"Are you sure you wish to purchase [item.name] for $[item.cost]?","You sure?","Yes","No") in list("Yes","No")
		if(!Adjacent(usr))
			to_chat(usr, span_warning("You are not close enough to do that."))
			return
		if(sure=="No")
			updateUsrDialog()
			return
		if(!GLOB.centcomm_store.PlaceOrder(usr,itemID))
			to_chat(usr, span_warning("Unable to charge your account."))
		else
			to_chat(usr, span_notice("You've successfully purchased the item. It should be in your hands or on the floor."))
	src.updateUsrDialog()
	return
