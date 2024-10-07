/datum/antagonist/blob_overmind
	name = "Blob"
	roundend_category = "blobs"
	job_rank = ROLE_BLOB
	special_role = SPECIAL_ROLE_BLOB_OVERMIND
	wiki_page_name = "Blob"
	russian_wiki_name = "Блоб"
	show_in_roundend = FALSE
	show_in_orbit = FALSE
	/// Variable responsible for the need to add a mind to blob_infected list in game mode
	var/add_to_mode = TRUE
	/// Is a blob a offspring of another blob.
	var/is_offspring = FALSE
	/// Was the blob with this datum bursted blob_infected.
	var/is_tranformed = FALSE
	/// Link to the datum of the selected blob reagent.
	var/datum/reagent/blob/reagent

/datum/antagonist/blob_overmind/on_gain()
	if(!reagent)
		var/reagent_type = pick(subtypesof(/datum/reagent/blob))
		reagent = new reagent_type
	return ..()

/datum/antagonist/blob_overmind/add_owner_to_gamemode()
	var/datum/game_mode/mode = SSticker.mode
	if(add_to_mode && mode && !(owner in mode.blobs["infected"]))
		if(!is_tranformed)
			mode.blob_win_count += BLOB_TARGET_POINT_PER_CORE
		if(is_offspring)
			mode.blobs["offsprings"] |= owner
		else mode.blobs["infected"] |= owner
		mode.update_blob_objective()


/datum/antagonist/blob_overmind/remove_owner_from_gamemode()
	var/datum/game_mode/mode = SSticker.mode
	if(add_to_mode && mode && (owner in mode.blobs["infected"]))
		mode.blob_win_count -= BLOB_TARGET_POINT_PER_CORE
		if(is_offspring)
			mode.blobs["offsprings"]  -= owner
		else mode.blobs["infected"] -= owner
		mode.update_blob_objective()


/datum/antagonist/blob_overmind/give_objectives()
	if(SSticker)
		add_objective(SSticker.mode.get_blob_objective())


/datum/antagonist/blob_overmind/roundend_report_header()
	return

/datum/antagonist/blob_overmind/greet()
	var/list/messages = list()
	messages.Add("<span class='danger'>Вы Блоб!</span>")
	for(var/message in get_blob_help_messages(reagent))
		messages.Add(message)
	SEND_SOUND(owner.current, 'sound/magic/mutate.ogg')
	return messages

/proc/get_blob_help_messages(datum/reagent/blob/blob_reagent_datum)
	var/list/messages = list()
	messages += "<b>Как надразум, вы можете управлять блобом!</b>"
	messages += "Ваш реагент: <b><font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</b></font> - [blob_reagent_datum.description]"
	messages += "<b>Вы можете расширяться, атакуя людей, повреждая объекты или размещая простую плитку, если клетка свободна.</b>"
	messages += "<i>Обычная плитка</i> будет расширять ваше влияние и может быть улучшена до специальной плитки, выполняющей определённую функцию."
	messages += "<b>Вы можете улучшить обычные плитки до следующих типов:</b>"
	messages += "<i>Крепкая плитка</i> это сильная и дорогая плитка, которая выдерживает больше повреждений. Кроме того, она огнеупорна и может блокировать газы. Используйте их для защиты от пожаров на станции. Повторное улучшение превратит их в <i>Отражающие плитки</i>, способные отражать лазерные снаряды, но теряющие дополнительное здоровье крепкой плитки."
	messages += "<i>Ресурсная плитка</i> это плитка, которая производит больше ресурсов для вас, стройте как можно больше таких, чтобы поглотить станцию. Этот тип плиток должен быть размещен рядом с <b>узлами</b> или <b>ядром</b>, чтобы работать."
	messages += "<i>Фабрика</i> это плитка, которая порождает споры, атакующие ближайших врагов. Этот тип плиток должен быть размещен рядом с <b>узлами</b> или <b>ядром</b>, чтобы работать."
	messages += "<i>Блоббернаут</i> могут быть созданы из фабрик за определенную цену. Они сложны для уничтожения, мощные, но в конечном итоге не очень умные. Фабрика, использованная для их создания, будет уничтожена в процессе."
	messages += "<i>Хранилище</i> это плитка, которая будет накапливать дополнительные ресурсы для вас. Каждая плитка увеличивает ваш максимальный предел ресурсов на 50."
	messages += "<i>Узел</i> представляет собой плитку, которая разрастается, как и ядро. Как и ядро, он может активировать ресурсные плитки и фабрики."
	messages += "<b>Помимо кнопок на вашем HUD, есть несколько сочетаний клавиш и кнопок мыши для ускорения расширения и защиты.</b>"
	messages += "<b>Сочетания клавиш:</b> ЛКМ = установить простую плитку <b>|</b> CTRL + ЛКМ = Улучшить плитку <b>|</b> СКМ = Указать цель спорам <b>|</b> Alt + ЛКМ = Удалить плитку"
	messages += "Попытайтесь отправить телепатическое сообщение всем остальным <b>надразумами</b>, что позволит вам координировать свои действия с ними."
	return messages

/**
 * Takes any datum `source` and checks it for blob_overmind datum.
 */
/proc/isblobovermind(datum/source)
	if(!source)
		return FALSE

	if(istype(source, /datum/mind))
		var/datum/mind/our_mind = source
		return our_mind.has_antag_datum(/datum/antagonist/blob_overmind) && isovermind(our_mind.current)

	if(!ismob(source))
		return FALSE

	var/mob/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/blob_overmind) && isovermind(mind_holder)
