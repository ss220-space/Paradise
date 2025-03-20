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

/datum/component/phantom_component/proc/phantomification(list/atoms)
	for(var/atom/A in atoms)
		A.AddComponent(/datum/component/phantom_component, linked_item, FALSE)

/datum/component/phantom_component/proc/smart_self_delete()
	
