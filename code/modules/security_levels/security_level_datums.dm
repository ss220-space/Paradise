/**
 * Security levels
 *
 * These are used by the security level subsystem. Each one of these represents a security level that a player can set.
 *
 * Base type is abstract
 */
/datum/security_level
	/// The name of this security level.
	var/name = "Not set."
	/// The numerical level of this security level, see defines for more information.
	var/number_level = -1
	/// The delay, after which the security level will be set
	var/set_delay = 0
	/// The sound that we will play when elevated to this security level
	var/elevating_to_sound
	/// The sound that we will play when lowered to this security level
	var/lowering_to_sound
	/// The AI announcement sound about code change, that will be played after main sound
	var/ai_announcement_sound
	/// Color of security level
	var/color
	/// The status display that will be posted to all status displays on security level set
	var/status_display_mode = STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME
	/// The status display data that will be posted to all status displays on security level set
	var/status_display_data = ""
	/// Our announcement title when lowering to this level
	var/lowering_to_announcement_title = "Not set."
	/// Our announcement when lowering to this level
	var/lowering_to_announcement_text = "Not set."
	/// Our announcement title when elevating to this level
	var/elevating_to_announcement_title = "Not set."
	/// Our announcement when elevating to this level
	var/elevating_to_announcement_text = "Not set."

/**
 * Should contain actions that must be completed before actual security level set
 */
/datum/security_level/proc/pre_change()
	return

/**
 * MARK: GREEN
 *
 * No threats
 */
/datum/security_level/green
	name = SECURITY_CODE_GREEN
	number_level = SEC_LEVEL_GREEN
	ai_announcement_sound = 'sound/AI/green.ogg'
	color = "limegreen"
	lowering_to_announcement_title = "Внимание! Уровень угрозы понижен до Зелёного."
	lowering_to_announcement_text = "Все угрозы для станции устранены. Все оружие должно быть в кобуре, и законы о конфиденциальности вновь полностью соблюдаются."

/**
 * MARK: BLUE
 *
 * Caution advised
 */
/datum/security_level/blue
	name = SECURITY_CODE_BLUE
	number_level = SEC_LEVEL_BLUE
	elevating_to_sound = 'sound/misc/notice1.ogg'
	ai_announcement_sound = 'sound/AI/blue.ogg'
	color = "dodgerblue"
	lowering_to_announcement_title = "Внимание! Уровень угрозы понижен до Синего."
	lowering_to_announcement_text = "Непосредственная угроза миновала. Служба безопасности может больше не держать оружие в полной боевой готовности, но может по-прежнему держать его на виду. Выборочные обыски запрещены."
	elevating_to_announcement_title = "Внимание! Уровень угрозы повышен до Синего."
	elevating_to_announcement_text = "На станции обнаружено присутствие враждебных элементов, представляющих незначительную угрозу экипажу и активам корпорации. Служба безопасности может держать оружие на виду и использовать летальную силу в соответствии с рабочими процедурами отдела защиты активов."

/**
 * MARK: RED
 *
 * Hostile threats
 */
/datum/security_level/red
	name = SECURITY_CODE_RED
	number_level = SEC_LEVEL_RED
	elevating_to_sound = 'sound/misc/notice1.ogg'
	ai_announcement_sound = 'sound/AI/red.ogg'
	color = "red"
	status_display_mode = STATUS_DISPLAY_ALERT
	status_display_data = "redalert"
	lowering_to_announcement_title = "Внимание! Код Красный!"
	lowering_to_announcement_text = "Угроза уничтожения станции миновала, но враждебная активность остается на высоком уровне. Службе безопасности рекомендуется иметь оружие в полной боевой готовности. Выборочные обыски разрешены."
	elevating_to_announcement_title = "Внимание! Код Красный!"
	elevating_to_announcement_text = "На борту станции подтверждена серьезная угроза для экипажа и активов корпорации. Службе безопасности рекомендуется иметь оружие в полной боевой готовности. Выборочные обыски разрешены и рекомендуются."

/**
 * MARK: GAMMA
 *
 * Station major hostile threats
 */
/datum/security_level/gamma
	name = SECURITY_CODE_GAMMA
	number_level = SEC_LEVEL_GAMMA
	lowering_to_sound = 'sound/effects/new_siren.ogg'
	elevating_to_sound = 'sound/effects/new_siren.ogg'
	ai_announcement_sound = 'sound/AI/gamma.ogg'
	color = "gold"
	status_display_mode = STATUS_DISPLAY_ALERT
	status_display_data = "gammaalert"
	lowering_to_announcement_title = "Внимание! Активирован код Гамма!"
	lowering_to_announcement_text = "Центральным командованием был установлен Код Гамма. Станция находится под угрозой полного уничтожения. Службе безопасности следует получить полное вооружение и приготовиться к ведению боевых действий с враждебными элементами на борту станции. Гражданский персонал обязан немедленно обратиться к Главам отделов для получения дальнейших указаний."
	elevating_to_announcement_text = "Центральным командованием был установлен Код Гамма. Станция находится под угрозой полного уничтожения. Службе безопасности следует получить полное вооружение и приготовиться к ведению боевых действий с враждебными элементами на борту станции. Гражданский персонал обязан немедленно обратиться к Главам отделов для получения дальнейших указаний."
	elevating_to_announcement_title = "Внимание! Активирован код Гамма!"

/**
 * MARK: EPSILON
 *
 * Station is not longer under the Central Command and to be destroyed by Death Squad (Or maybe not)
 */
/datum/security_level/epsilon
	name = SECURITY_CODE_EPSILON
	number_level = SEC_LEVEL_EPSILON
	set_delay = 15 SECONDS
	lowering_to_sound = 'sound/effects/purge_siren.ogg'
	elevating_to_sound = 'sound/effects/purge_siren.ogg'
	ai_announcement_sound = 'sound/AI/epsilon.ogg'
	color = "blueviolet"
	status_display_mode = STATUS_DISPLAY_ALERT
	status_display_data = "epsilonalert"
	lowering_to_announcement_title = "Внимание! Активирован код Эпсилон!"
	lowering_to_announcement_text = "Центральным командованием был установлен код Эпсилон. Все контракты считаются расторгнутыми."
	elevating_to_announcement_title = "Внимание! Активирован код Эпсилон!"
	elevating_to_announcement_text = "Центральным командованием был установлен код Эпсилон. Все контракты считаются расторгнутыми."

/datum/security_level/epsilon/pre_change()
	sound_to_playing_players_on_station_level(sound = sound('sound/effects/powerloss.ogg'))

/**
 * MARK: DELTA
 *
 * Station self-destruiction mechanism has been engaged
 */
/datum/security_level/delta
	name = SECURITY_CODE_DELTA
	number_level = SEC_LEVEL_DELTA
	elevating_to_sound = 'sound/effects/delta_klaxon.ogg'
	ai_announcement_sound = 'sound/AI/delta.ogg'
	color = "orangered"
	status_display_mode = STATUS_DISPLAY_ALERT
	status_display_data = "deltaalert"
	elevating_to_announcement_title = "Внимание! Активирован код Дельта!"
	elevating_to_announcement_text = "Механизм самоуничтожения станции задействован. Все члены экипажа обязаны подчиняться всем указаниям, данными Главами отделов. Любые нарушения этих приказов наказуемы уничтожением на месте. Это не учебная тревога."
