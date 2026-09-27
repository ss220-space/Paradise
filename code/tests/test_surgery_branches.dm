/datum/unit_test/surgery_branch_tools/Run()
	for(var/proxy_type in subtypesof(/datum/surgery_step/proxy))
		var/datum/surgery_step/proxy/proxy_step = new proxy_type
		var/list/claimed_tools = list()
		var/hand_branches = 0
		var/any_item_branches = 0

		for(var/datum/surgery/branch as anything in proxy_step.branches_init)
			var/datum/surgery_step/first_step = branch.get_surgery_step()
			hand_branches += first_step.accept_hand
			any_item_branches += first_step.accept_any_item

			for(var/tool in first_step.allowed_tools)
				if((tool in claimed_tools) && !(tool in proxy_step.overriding_tools))
					TEST_FAIL("[proxy_type] has two branches starting with [tool], which crashes the surgery when that tool is used.")
				claimed_tools += tool

			qdel(first_step)

		if(hand_branches > 1)
			TEST_FAIL("[proxy_type] has [hand_branches] branches accepting an empty hand, which crashes the surgery.")
		if(any_item_branches > 1)
			TEST_FAIL("[proxy_type] has [any_item_branches] branches accepting any item, which crashes the surgery.")

		qdel(proxy_step)
