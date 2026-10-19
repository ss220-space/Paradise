/datum/element/empprotection
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY // Detach for turfs
	argument_hash_start_idx = 2
	var/flags = NONE

/datum/element/empprotection/Attach(datum/target, _flags)
	. = ..()
	if(. == ELEMENT_INCOMPATIBLE || !isatom(target))
		return ELEMENT_INCOMPATIBLE
	flags = _flags
	RegisterSignal(target, COMSIG_ATOM_PRE_EMP_ACT, PROC_REF(getEmpFlags))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE_TAGS, PROC_REF(get_examine_tags))

/datum/element/empprotection/Detach(atom/target)
	UnregisterSignal(target, list(COMSIG_ATOM_PRE_EMP_ACT, COMSIG_ATOM_EXAMINE_TAGS))
	return ..()

/datum/element/empprotection/proc/getEmpFlags(datum/source, severity)
	SIGNAL_HANDLER

	return (flags & EMP_PROTECT_ALL)

/datum/element/empprotection/proc/get_examine_tags(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(flags & EMP_NO_EXAMINE)
		return

	if((flags & EMP_PROTECT_ALL) == EMP_PROTECT_ALL)
		examine_list["полностью защищенный от ЭМИ"] = "Электромагнитные импульсы не воздействуют на объект, его содержимое и проводку."
		return

	if(flags & EMP_PROTECT_SELF)
		examine_list["устойчивый к ЭМИ"] = "Электромагнитные импульсы не воздействуют на сам объект."

	if((flags & (EMP_PROTECT_CONTENTS|EMP_PROTECT_WIRES)) == (EMP_PROTECT_CONTENTS|EMP_PROTECT_WIRES))
		examine_list["частично защищенный от ЭМИ"] = "Содержимое и проводка объекта защищены от электромагнитных импульсов."

	else if(flags & EMP_PROTECT_CONTENTS)
		examine_list["с защитой содержимого от ЭМИ"] = "Содержимое объекта защищено от электромагнитных импульсов."

	else if(flags & EMP_PROTECT_WIRES)
		examine_list["с защитой проводки от ЭМИ"] = "Проводка объекта защищена от электромагнитных импульсов."
