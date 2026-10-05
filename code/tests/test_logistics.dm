#define LOGISTICS_TEST_LINE_LENGTH 4

/datum/unit_test/room_test/logistics
	var/turf/expel_turf
	var/expel_turf_type

/datum/unit_test/room_test/logistics/Destroy()
	expel_turf?.ChangeTurf(expel_turf_type)
	expel_turf = null
	return ..()

/datum/unit_test/room_test/logistics/Run()
	var/turf/anchor = run_loc_floor_bottom_left
	var/list/obj/structure/logistics_pipe/line = list()
	for(var/offset in 0 to LOGISTICS_TEST_LINE_LENGTH)
		var/turf/tile = locate(anchor.x + offset, anchor.y, anchor.z)
		var/pipe_type = (offset == 0 || offset == LOGISTICS_TEST_LINE_LENGTH) ? /obj/structure/logistics_pipe/trunk : /obj/structure/logistics_pipe/segment
		var/obj/structure/logistics_construct/construct = new(tile, pipe_type, EAST)
		line += allocate(pipe_type, tile, construct)
		qdel(construct)

	var/turf/source_turf = get_turf(line[1])
	var/turf/dest_turf = get_turf(line[length(line)])
	var/obj/machinery/smartfridge/smart_container/source_fridge = allocate(/obj/machinery/smartfridge/smart_container, source_turf)
	var/obj/machinery/smartfridge/smart_container/dest_fridge = allocate(/obj/machinery/smartfridge/smart_container, dest_turf)
	var/datum/component/logistics_interface/source = source_fridge.install_logistics_interface(LOGISTICS_MODE_SEND)
	var/datum/component/logistics_interface/dest = dest_fridge.install_logistics_interface(LOGISTICS_MODE_RECEIVE)
	TEST_ASSERT_EQUAL(source.linked_pipe, line[1], "the source did not link to its trunk")
	TEST_ASSERT_NOTNULL(source.net, "the source has no network")
	TEST_ASSERT_EQUAL(source.net, dest.net, "both ends of one pipe line ended up in different networks")
	var/datum/logistics_net/net = source.net

	source_fridge.load(allocate(/obj/item/pen, source_turf))
	source_fridge.load(allocate(/obj/item/pen/blue, source_turf))
	source_fridge.load(allocate(/obj/item/stack/sheet/metal, source_turf, 30))
	for(var/i in 1 to 3)
		source_fridge.load(allocate(/obj/item/stack/medical/bruise_pack, source_turf, 1, FALSE))

	var/list/wanted = list()
	for(var/obj/item/item in source_fridge.contents)
		wanted[logistics_stock_id_for_item(item)] += logistics_item_units(item)

	var/datum/logistics_request/request = net.create_request(null, dest, wanted)
	net.execute_request(request)
	var/deadline = world.time + 30 SECONDS
	while(!QDELETED(request) && world.time < deadline)
		sleep(1 SECONDS)
	TEST_ASSERT(QDELETED(request), "the request was not finished in time")
	TEST_ASSERT_EQUAL(net.archived_orders[1]["result"], "выполнен", "the request did not complete")
	TEST_ASSERT_EQUAL(length(source_fridge.contents), 0, "the source still holds items")

	var/gauze_amount = 0
	var/list/received = list()
	for(var/obj/item/item in dest_fridge.contents)
		if(istype(item, /obj/item/stack/medical/bruise_pack))
			var/obj/item/stack/gauze = item
			gauze_amount += gauze.get_amount()
			continue
		received[logistics_stock_id_for_item(item)] += logistics_item_units(item)
	TEST_ASSERT_EQUAL(gauze_amount, 3, "merged gauze was miscounted on delivery")
	TEST_ASSERT_EQUAL(received["[/obj/item/pen]"], 1, "the plain pen was not delivered exactly once")
	TEST_ASSERT_EQUAL(received["[/obj/item/pen/blue]"], 1, "the blue pen was not delivered exactly once")
	TEST_ASSERT_EQUAL(received["[/obj/item/stack/sheet/metal]"], 30, "metal was lost or duplicated")
	for(var/obj/structure/logistics_pipe/pipe as anything in line)
		TEST_ASSERT_NULL(locate(/obj/item) in get_turf(pipe), "a delivery spilled items onto the floor")

	var/turf/away_turf = locate(anchor.x, anchor.y + 1, anchor.z)
	source_fridge.forceMove(away_turf)
	TEST_ASSERT_NULL(source.linked_pipe, "a moved machine kept its old pipe")
	TEST_ASSERT_NULL(source.net, "a moved machine stayed in the network")
	source_fridge.forceMove(source_turf)
	TEST_ASSERT_EQUAL(source.linked_pipe, line[1], "a machine moved back onto its trunk did not relink")
	TEST_ASSERT_EQUAL(source.net, net, "a relinked machine did not rejoin its network")

	for(var/i in 1 to 4)
		source_fridge.load(allocate(/obj/item/pen, source_turf))
	dest_fridge.max_n_of_items = length(dest_fridge.contents) + 2
	var/datum/logistics_request/capped = net.create_request(source, dest, list("[/obj/item/pen]" = 4))
	TEST_ASSERT(net.dispatch_shipment_batch(capped, source, dest, list()), "the first batch was not sent")
	TEST_ASSERT_NOT(net.dispatch_shipment_batch(capped, source, dest, list()), "a second batch ignored the shipment already in flight")
	net.cancel_request(capped)

	var/obj/structure/logistics_pipe/middle = line[3]
	expel_turf = get_turf(middle)
	expel_turf_type = expel_turf.type
	var/obj/structure/logistics_holder/holder = allocate(/obj/structure/logistics_holder, middle)
	var/obj/item/pen/thrown = allocate(/obj/item/pen, source_turf)
	thrown.forceMove(holder)
	middle.expel(holder, expel_turf, NORTH)
	TEST_ASSERT_NOTNULL(thrown.throwing, "expelled contents were not thrown")
	TEST_ASSERT(get_dist(thrown, expel_turf) <= 1, "expelled contents were teleported instead of thrown")

#undef LOGISTICS_TEST_LINE_LENGTH
