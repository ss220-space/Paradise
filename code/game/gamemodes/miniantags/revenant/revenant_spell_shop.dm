/datum/action/cooldown/spell/revenant_spells
	name = "Призрачный Гримуар"
	desc = "Усильте свои навыки пугания смертных."
	button_icon_state = "revenantlist"
	background_icon_state = "bg_revenant"
	spell_requirements = NONE
	var/list/revenant_spell_list = list()
	var/mob/living/simple_animal/revenant/rev_owner

/datum/action/cooldown/spell/revenant_spells/Grant(mob/grant_to)
	. = ..()
	rev_owner = owner

/datum/action/cooldown/spell/revenant_spells/ui_status(mob/user, datum/ui_state/state)
	if(istype(user, /mob/living/simple_animal/revenant))
		return UI_INTERACTIVE
	return ..()

/datum/action/cooldown/spell/revenant_spells/cast(atom/cast_on)
	. = ..()
	ui_interact(owner)

/datum/action/cooldown/spell/revenant_spells/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Revenant", name)
		ui.open()

/datum/action/cooldown/spell/revenant_spells/ui_data(mob/user)
	var/list/data = list()
	var/list/all_spells = list()
	for(var/i in 1 to length(revenant_spell_list))
		var/datum/revenant_spell/spell = revenant_spell_list[i]
		var/list/spell_data = list()
		spell_data["name"] = spell.name
		spell_data["cost"] = spell.cost
		spell_data["cast_cost"] = spell.cast_cost
		spell_data["index"] = i
		spell_data["can_buy"] = spell.CanBuy(user)
		spell_data["desc"] = spell.desc
		spell_data["cooldown"] = spell.cooldown_time / 10
		spell_data["stun"] = spell.stun
		spell_data["reveal"] = spell.reveal
		spell_data["buy_word"] = spell.buyword(user)
		spell_data["radius"] = spell.aoe_radius
		spell_data["u_radius"] = spell.owned ? spell.upgraded_radius : 0
		spell_data["u_cast"] = spell.owned ? spell.upgraded_cast : 0
		spell_data["u_stun"] = spell.owned ? spell.upgraded_stun : 0
		spell_data["u_reveal"] = spell.owned ? spell.upgraded_reveal : 0
		spell_data["u_cooldown"] = spell.owned ? spell.u_cooldown_time : 0
		all_spells += list(spell_data)
	data["spells"] = all_spells
	return data

/datum/action/cooldown/spell/revenant_spells/New(Target, original)
	. = ..()
	var/list/types_to_create = subtypesof(/datum/revenant_spell/aoe) + subtypesof(/datum/revenant_spell/pointed)
	for(var/type in types_to_create)
		revenant_spell_list += new type

/datum/action/cooldown/spell/revenant_spells/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(action != "buy")
		return FALSE
	var/idx = params["index"]
	if(!idx || idx > length(revenant_spell_list))
		return
	var/datum/revenant_spell/spell = revenant_spell_list[idx]
	spell.buy(owner)
	return TRUE

/datum/revenant_spell
	var/name = "Жуткое заклинание"
	var/desc = "Оно делает что-то жуткое"
	var/spell_type = /datum/action/cooldown/spell/aoe/revenant
	var/datum/action/cooldown/spell/aoe/revenant/spell
	var/cost = 100
	var/cast_cost = 50
	var/cooldown_time = 0
	var/reveal = 0
	var/stun = 0
	var/aoe_radius = 0
	var/upgraded_radius = 0
	var/upgraded_cast = 0
	var/upgraded_stun = 0
	var/upgraded_reveal = 0
	var/owned = FALSE
	var/u_cooldown_time
	var/need_lamp = FALSE

/datum/revenant_spell/New()
	. = ..()
	spell = new spell_type()
	update_stats()

/datum/revenant_spell/proc/CanBuy(mob/living/simple_animal/revenant/buyer)
	if(!istype(buyer) || buyer.essence < cost || spell.spell_level == spell.spell_max_level || need_lamp && !buyer.have_lamp)
		return FALSE
	return TRUE

/datum/revenant_spell/proc/buyword(mob/living/simple_animal/revenant/buyer)
	if(need_lamp && !buyer.have_lamp)
		return "Отсутствует фонарь"
	if(!(spell in buyer.mob_spell_list))
		return "Получить Способность"
	if(spell.spell_level < spell.spell_max_level)
		return "Усилить Способность"
	return "Максимальный Уровень"

/datum/revenant_spell/proc/buy(mob/living/simple_animal/revenant/user)
	user.change_essence_amount(-cost, TRUE)
	if(owned)
		spell.level_spell()
		update_stats()
		return
	owned = TRUE
	user.AddSpell(spell)

/datum/revenant_spell/proc/update_stats()
	cast_cost = spell.cast_amount
	stun = spell.stun
	reveal = spell.reveal
	cooldown_time = spell.cooldown_time
	if(spell.spell_level < 3)
		upgraded_cast = min(cast_cost + spell.cast_increase_per_level, spell.max_cast_amount) == cast_cost ? 0 : min(cast_cost + spell.cast_increase_per_level, spell.max_cast_amount)
		upgraded_stun = min(stun + spell.stun_increase_per_level, spell.max_stun) == stun ? 0 : min(stun + spell.stun_increase_per_level, spell.max_stun)
		upgraded_reveal = min(reveal + spell.reveal_increase_per_level, spell.max_reveal) == reveal ? 0 : min(reveal + spell.reveal_increase_per_level, spell.max_reveal)
		u_cooldown_time = min(cooldown_time + spell.cooldown_increase_per_level, spell.max_cooldown) == cooldown_time ? 0 : min(cooldown_time + spell.cooldown_increase_per_level, spell.max_cooldown)
		return
	upgraded_radius = 0
	upgraded_cast = 0
	upgraded_stun = 0
	upgraded_reveal = 0
	u_cooldown_time = 0

/datum/revenant_spell/aoe/update_stats()
	. = ..()
	aoe_radius = spell.aoe_radius
	if(spell.spell_level < 3)
		upgraded_radius = min(aoe_radius + spell.radius_increase_per_level, spell.max_radius) == aoe_radius ? 0 : min(aoe_radius + spell.radius_increase_per_level, spell.max_radius)
		return
	upgraded_radius = 0

/datum/revenant_spell/pointed
	var/datum/action/cooldown/spell/pointed/revenant/spell_pointed

/datum/revenant_spell/pointed/New()
	spell_pointed = new spell_type
	. = ..()

/datum/revenant_spell/pointed/update_stats()
	. = ..()
	aoe_radius = spell_pointed.cast_range
	if(spell.spell_level < 3)
		upgraded_radius = min(aoe_radius + spell.radius_increase_per_level, spell.max_radius) == aoe_radius ? 0 : min(aoe_radius + spell.radius_increase_per_level, spell.max_radius)
		return
	upgraded_radius = 0

/datum/revenant_spell/aoe/hallucinations
	name = "Аура галлюцинации"
	desc = "Играйте с живыми, показывая им видения того, что могло бы быть или было."
	spell_type = /datum/action/cooldown/spell/aoe/revenant/hallucinations
	cost = 25

/datum/revenant_spell/aoe/overload
	name = "Перегрузить сеть"
	desc = "Направляет большое количество эссенции в ближайшие источники света, заставляя их бить током окружающих."
	spell_type = /datum/action/cooldown/spell/aoe/revenant/overload
	cost = 75

/datum/revenant_spell/aoe/defile
	name = "Осквернить"
	desc = "Искажает и оскверняет ближайшую территорию, а также рассеивает святую ауру на полу."
	spell_type = /datum/action/cooldown/spell/aoe/revenant/defile
	cost = 35

/datum/revenant_spell/aoe/malfunction
	name = "Вызвать сбой"
	desc = "Повреждает и искажает ближайшие механизмы и технические объекты."
	spell_type = /datum/action/cooldown/spell/aoe/revenant/malfunction
	cost = 75

/datum/revenant_spell/aoe/blight
	name = "Мор"
	desc = "Заражает ближайших людей болезнью, которая постепенно ослабляет их."
	spell_type = /datum/action/cooldown/spell/aoe/revenant/blight
	cost = 150

/datum/revenant_spell/aoe/haunt_object
	name = "Призрачные предметы"
	desc = "Наполняет ближайшие предметы призрачной энергией, заставляя их атаковать живых. Предметы ближе к вам имеют больше шансов быть одержимыми."
	spell_type = /datum/action/cooldown/spell/aoe/revenant/haunt_object
	cost = 50

/datum/revenant_spell/aoe/mirage
	name = "Призрачный мираж"
	desc = "Создайте свою призрачную копию чтобы обмануть смертных."
	spell_type = /datum/action/cooldown/spell/aoe/revenant/mirage
	cost = 15

/datum/revenant_spell/aoe/lamp
	name = "Призвать маяк душ."
	desc = "Создайте маяк душ, который будет высасывать жизненную эссенцию из ближайших смертных и позволит использовать более мощные заклинания."
	spell_type = /datum/action/cooldown/spell/aoe/revenant/soul_lamp
	cost = 100

/datum/revenant_spell/aoe/soul_fire
	name = "Призрачное пламя"
	desc = "Выпустите волну призрачного пламени из вашего фонаря."
	spell_type = /datum/action/cooldown/spell/aoe/revenant/soul_fire
	cost = 50
	need_lamp = TRUE

/datum/revenant_spell/pointed/gaze
	name = "Пугающий взор"
	desc = "Направьте пламя вашей лампы в смертного, ослепляя и оглушая его."
	spell_type = /datum/action/cooldown/spell/pointed/revenant/gaze
	cost =  35
	need_lamp = TRUE

/datum/revenant_spell/pointed/tear
	name = "Слеза пламени"
	desc = "Выпустите в цель призрачную слезу из своего фонаря. При попадании слеза подожжет цель призрачным пламенем и нанесет урон ожогами."
	spell_type = /datum/action/cooldown/spell/pointed/revenant/tear
	cost = 50
	need_lamp = TRUE

/datum/revenant_spell/pointed/reflect
	name = "Отражение мук"
	desc = "Позволяет перенаправлять часть полученных повреждений в выбранного смертного."
	spell_type = /datum/action/cooldown/spell/pointed/revenant/reflect
	cost = 35
