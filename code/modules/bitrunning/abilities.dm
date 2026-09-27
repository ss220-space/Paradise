/datum/action/avatar_domain_info
	name = "Информация о домене"
	desc = "Открыть инструктаж по текущему виртуальному домену."
	button_icon_state = "hotkey_help"
	show_to_observers = FALSE
	var/help_text

/datum/action/avatar_domain_info/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return

	ui_interact(owner)

/datum/action/avatar_domain_info/ui_state(mob/user)
	return GLOB.always_state

/datum/action/avatar_domain_info/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AvatarHelp", "Информация о домене")
		ui.open()

/datum/action/avatar_domain_info/ui_static_data(mob/user)
	return list("help_text" = help_text)

/datum/action/cooldown/spell/conjure/bitrunner_cheese
	name = "Summon Cheese"
	desc = "Создаёт девять головок сыра вокруг заклинателя."
	cooldown_time = 1 MINUTES
	spell_requirements = NONE
	invocation = "PL'YR DOT PL'CTM' OOO'B'ABEE G!"
	invocation_type = INVOCATION_SHOUT
	summon_radius = 1
	summon_amount = 9
	summon_type = list(/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel)
	sound = 'sound/magic/summonitems_generic.ogg'

/datum/action/cooldown/spell/bitrunner_heal
	name = "Lesser Heal"
	desc = "Исцеляет по 10 единиц физических повреждений и ожогов заклинателя."
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "Victus sano!"
	invocation_type = INVOCATION_WHISPER
	sound = 'sound/magic/staff_healing.ogg'
	var/brute_to_heal = 10
	var/burn_to_heal = 10

/datum/action/cooldown/spell/bitrunner_heal/cast(atom/cast_on)
	. = ..()
	var/mob/living/healed = owner
	healed.adjustBruteLoss(-brute_to_heal, updating_health = FALSE)
	healed.adjustFireLoss(-burn_to_heal, updating_health = FALSE)
	healed.updatehealth()
	owner.visible_message(span_notice("[owner] окутывается мягким светом."), span_notice("Вы окутываете себя целительным светом."))
	return TRUE

/datum/action/cooldown/spell/shapeshift/bitrunner_polar_bear
	name = "Polar Bear Form"
	desc = "Превращает вас в белого медведя."
	invocation = "*roar"
	spell_requirements = NONE
	shapeshift_type = /mob/living/simple_animal/hostile/bear/polar/bitrunner
	possible_shapes = list(/mob/living/simple_animal/hostile/bear/polar/bitrunner)

/mob/living/simple_animal/hostile/bear/polar/bitrunner
	name = "magic polar bear"
	desc = "Белый медведь с необычайно осмысленным взглядом."
	health = 300
	maxHealth = 300
	obj_damage = 40
	melee_damage_lower = 25
	melee_damage_upper = 25
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	faction = list("neutral")

/mob/living/simple_animal/hostile/bear/polar/bitrunner/get_ru_names()
	return alist(
		NOMINATIVE = "волшебный белый медведь",
		GENITIVE = "волшебного белого медведя",
		DATIVE = "волшебному белому медведю",
		ACCUSATIVE = "волшебного белого медведя",
		INSTRUMENTAL = "волшебным белым медведем",
		PREPOSITIONAL = "волшебном белом медведе",
	)

/datum/action/cooldown/spell/pointed/projectile/fireball/bitrunner_lightning
	name = "Lightning Bolt"
	desc = "Выпускает молнию, перескакивающую между целями без оглушения."
	cooldown_time = 10 SECONDS
	invocation = "P'WAH, UNLIM'TED P'WAH!"
	projectile_type = /obj/projectile/magic/bitrunner_lightning
	button_icon_state = "lightning"
	sound = 'sound/magic/lightningbolt.ogg'
	active_msg = span_notice_alt("Ваши руки наливаются древним электричеством! <b>Кликните по цели левой кнопкой!</b>")
	deactive_msg = span_notice_alt("Вы позволяете энергии утечь обратно...")

/obj/projectile/magic/bitrunner_lightning
	name = "lightning bolt"
	icon_state = "spark"
	damage = 15
	damage_type = BURN
	nodamage = FALSE
	speed = 0.2
	var/datum/beam/lightning_chain

/obj/projectile/magic/bitrunner_lightning/get_ru_names()
	return alist(
		NOMINATIVE = "молния",
		GENITIVE = "молнии",
		DATIVE = "молнии",
		ACCUSATIVE = "молнию",
		INSTRUMENTAL = "молнией",
		PREPOSITIONAL = "молнии",
	)

/obj/projectile/magic/bitrunner_lightning/fire(setAngle)
	if(firer)
		lightning_chain = firer.Beam(src, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi')
	return ..()

/obj/projectile/magic/bitrunner_lightning/on_hit(atom/target, blocked = 0)
	. = ..()
	var/list/shocked_targets = list()
	if(firer)
		shocked_targets[firer] = TRUE
	tesla_zap(src, zap_range = 15, power = 20000, cutoff = 1000, zap_flags = ZAP_MOB_DAMAGE, shocked_targets = shocked_targets)

/obj/projectile/magic/bitrunner_lightning/Destroy()
	QDEL_NULL(lightning_chain)
	return ..()
