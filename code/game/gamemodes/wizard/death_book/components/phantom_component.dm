//AkA guardian components

/datum/component/phantom_component
	var/atom/linked_item = null //Signal hear
	var/deep = FALSE
/datum/component/phantom_component/Initialize(link_item = null, so_deep = FALSE)
	. = ..()
	linked_item = link_item
	deep = so_deep
	if(!isitem(parent) || isnull(linked_item))
		return COMPONENT_INCOMPATIBLE
	if(deep && isstorage(parent))
		var/obj/item/storage/prom = parent
		phantomification(prom.return_inv())

/datum/component/phantom_component/RegisterWithParent()
	RegisterSignal(linked_item, PHANTOM_DELETE, PROC_REF(smart_self_delete))

/datum/component/phantom_component/UnregisterFromParent()
	UnregisterSignal(linked_item, PHANTOM_DELETE)

/datum/component/phantom_component/proc/phantomification(list/atoms)
	for(var/atom/A in atoms)
		A.AddComponent(/datum/component/phantom_component, linked_item, FALSE)

/datum/component/phantom_component/proc/smart_self_delete()
	SIGNAL_HANDLER
	/*
	if(isstorage(parent.loc))
		var/obj/item/storage/prom = parent.loc
	if(ismmob(parent.loc))
		var/mob/prom = parent.loc
		prom.drop
	*/
	if(isnull(parent))
		qdel(src)
	var/atom/prom_parent = parent
	if(iscarbon(prom_parent.loc))
		var/mob/living/carbon/human/H = prom_parent.loc
		H.temporarily_remove_item_from_inventory(parent, TRUE, FALSE, TRUE)
	if(isstorage(parent))
		var/obj/item/storage/prom_s = parent
		prom_s.force_drop_inventory()

	qdel(parent)
