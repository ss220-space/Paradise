/proc/EquipCustomItems(mob/living/carbon/human/M)
	if(!SSdbcore.IsConnected())
		return

	// Grab the info we want.
	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT cuiPath, cuiPropAdjust, cuiJobMask, cuiDescription, cuiItemName FROM [format_table_name("customuseritems")]
		WHERE cuiCKey=:ckey AND (cuiRealName=:realname OR cuiRealName='*')"}, list(
			"ckey" = M.ckey,
			"realname" = M.real_name
		))
	if(!query.warn_execute(async = FALSE)) // Dont make this async. Youll make roundstart slow. Trust me.
		qdel(query)
		return

	while(query.NextRow())
		var/path = text2path(query.item[1])
		var/propadjust = query.item[2]
		var/jobmask = query.item[3]
		var/ok = 0
		if(!path || !ispath(path))
			log_debug("Incorrect database entry found in table 'customuseritems' path value = [path], cuiPath is null. cuiCKey='[M.ckey]' AND (cuiRealName='[M.real_name]' OR cuiRealName='*'")
			continue
		if(jobmask != "*")
			var/list/allowed_jobs = splittext(jobmask,",")
			for(var/i = 1, i <= length(allowed_jobs), i++)
				if(istext(allowed_jobs[i]))
					allowed_jobs[i] = trim(allowed_jobs[i])
			var/alt_blocked = 0
			if(M.mind.role_alt_title)
				if(!(M.mind.role_alt_title in allowed_jobs))
					alt_blocked = 1
			if(!(M.mind.assigned_role in allowed_jobs) || alt_blocked)
				continue

		var/obj/item/Item = new path()
		var/description = query.item[4]
		var/newname = query.item[5]
		if(is_id_card(Item))
			var/obj/item/card/id/id = Item
			for(var/obj/item/card/id/mob_id in M)
				//default settings
				id.name = "[M.real_name]’s ID Card ([M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role])"
				id.registered_name = M.real_name
				id.access = mob_id.access
				id.assignment = mob_id.assignment
				id.blood_type = mob_id.blood_type
				id.dna_hash = mob_id.dna_hash
				id.fingerprint_hash = mob_id.fingerprint_hash
				qdel(mob_id)
				ok = M.equip_or_collect(id, ITEM_SLOT_ID)
				break
		else if(isstorage(M.back)) // Try to place it in something on the mob's back
			var/obj/item/storage/storage = M.back
			if(length(storage.contents) < storage.storage_slots)
				Item.loc = M.back
				ok = 1
				to_chat(M, span_notice("Your [Item.name] has been added to your [M.back.name]."))
		if(ok == 0)
			for(var/obj/item/storage/storage in M.contents) // Try to place it in any item that can store stuff, on the mob.
				if(length(storage.contents) < storage.storage_slots)
					Item.loc = storage
					ok = 1
					to_chat(M, span_notice("Your [Item.name] has been added to your [storage.name]."))
					break
		if(description)
			Item.desc = description
		if(newname)
			Item.name = newname

		if(ok == 0) // Finally, since everything else failed, place it on the ground
			Item.loc = get_turf(M.loc)

		HackProperties(Item,propadjust)
		M.regenerate_icons()
	qdel(query)

// This is hacky, but since it's difficult as fuck to make a proper parser in BYOND without killing the server, here it is. - N3X
/proc/HackProperties(mob/living/carbon/human/M, obj/item/I, script)
	var/list/statements = splittext(script,";")
	if(length(statements) == 0)
		return
	for(var/statement in statements)
		var/list/assignmentChunks = splittext(statement,"=")
		var/varname = assignmentChunks[1]
		var/list/typeChunks=splittext(script,":")
		var/desiredType=typeChunks[1]
		switch(desiredType)
			if("string")
				var/output = typeChunks[2]
				output = replacetext(output,"{REALNAME}", M.real_name)
				output = replacetext(output,"{ROLE}",     M.mind.assigned_role)
				output = replacetext(output,"{ROLE_ALT}", "[M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role]")
				I.vars[varname]=output
			if("number")
				I.vars[varname]=text2num(typeChunks[2])
			if("icon")
				if(typeChunks.len==2)
					I.vars[varname]=new /icon(typeChunks[2])
				if(typeChunks.len==3)
					I.vars[varname]=new /icon(typeChunks[2],typeChunks[3])
