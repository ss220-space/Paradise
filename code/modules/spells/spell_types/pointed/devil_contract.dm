/datum/action/cooldown/spell/pointed/summon_contract
	name = "Призвать адский контракт"
	desc = "Зачем составлять контракт вручную, если можно сделать это с помощью магии?"

	invocation_type = INVOCATION_WHISPER
	invocation = "Iustus signum in linea punctata."

	active_msg = span_notice_alt("Вы приготавливаете подробный контракт. ЛКМ по цели, чтобы призвать контракт ей в руку.")
	deactive_msg = span_notice_alt("Вы сохраняете контракт до лучших времен.")
	aim_assist = FALSE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	cast_range = 5
	school = SCHOOL_CONJURATION
	cooldown_time = 15 SECONDS
	background_icon_state = "bg_demon"

/datum/action/cooldown/spell/pointed/summon_contract/is_valid_target(atom/cast_on)
	if(!iscarbon(cast_on))
		return FALSE
	var/mob/living/carbon/cast_mob = cast_on
	return cast_mob.mind && cast_mob.mind.hasSoul && (cast_mob.mind.soulOwner == cast_mob.mind) && !HAS_TRAIT(cast_mob.mind, TRAIT_BAD_SOUL) && ..()

/datum/action/cooldown/spell/pointed/summon_contract/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/C = cast_on
	if(!C.mind || !owner.mind)
		to_chat(owner, span_notice("[DECLENT_RU_CAP(C, NOMINATIVE)] не выглядит разумным и не сможет подписать контракт."))
		return

	if(C.stat == DEAD)
		if(!owner.drop_from_active_hand())
			return

		var/obj/item/paper/contract/infernal/contract = new(owner.loc, C.mind, owner.mind, GLOB.devil_contracts[CONTRACT_REVIVE])
		owner.put_in_hands(contract)
	else
		var/contract_type_name = tgui_input_list(owner, "Какой тип контракта?", "Тип контракта", GLOB.devil_contracts - CONTRACT_REVIVE)

		if(!contract_type_name)
			return

		var/obj/item/paper/contract/infernal/contract = new(C.loc, C.mind, owner.mind, GLOB.devil_contracts[contract_type_name])
		C.put_in_hands(contract)
