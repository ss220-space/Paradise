//AkA guardian components

/datum/component/phantom_component
	var/datum/linked_item = null //Signal hear
	var/deep = FALSE

/datum/component/phantom_component/Initialize(link_item = null, so_deep = FALSE)
	. = ..()
	linked_item = link_item
	deep = so_deep
	if(!isatom(parent) || isnull(linked_item))
		return COMPONENT_INCOMPATIBLE
	if(!deep)
		return
	var/atom/prom = parent
	phantomification(prom.contents)

/datum/component/phantom_component/RegisterWithParent()
	RegisterSignal(linked_item, COMSIG_PHANTOM_DELETE, PROC_REF(smart_self_delete))

/datum/component/phantom_component/UnregisterFromParent()
	UnregisterSignal(linked_item, COMSIG_PHANTOM_DELETE)

/datum/component/phantom_component/proc/phantomification(list/atoms)
	for(var/atom/A in atoms)
		A.AddComponent(/datum/component/phantom_component, linked_item, FALSE)

/datum/component/phantom_component/proc/smart_self_delete()
	SIGNAL_HANDLER
	if(!parent || QDELETED(parent))
		qdel(src)
		return
	var/atom/prom_parent = parent
	if(iscarbon(prom_parent.loc))
		var/mob/living/carbon/human/H = prom_parent.loc
		H.temporarily_remove_item_from_inventory(parent, TRUE, FALSE, TRUE)
	if(isstorage(parent))
		var/obj/item/storage/prom_s = parent
		prom_s.force_drop_inventory()

	qdel(parent)
