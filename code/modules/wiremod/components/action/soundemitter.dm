/**
 * # Sound Emitter Component
 *
 * A component that emits a sound when it receives an input.
 */
/obj/item/circuit_component/soundemitter
	display_name = "Динамик"
	desc = "Компонент, издающий звук при получении входного сигнала. \
			Частота — множитель, определяющий скорость воспроизведения звука."
	category = "Action"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// Sound to play
	var/datum/port/input/option/sound_file

	/// Volume of the sound when played
	var/datum/port/input/volume

	/// Whether to play the sound backwards
	var/datum/port/input/backwards

	/// Frequency of the sound when played
	var/datum/port/input/frequency

	/// The cooldown for this component of how often it can play sounds.
	var/sound_emitter_cooldown = 2 SECONDS

	/// The maximum pitch this component can play sounds at.
	var/max_pitch = 50
	/// The minimum pitch this component can play sounds at.
	var/min_pitch = -50
	/// The maximum volume this component can play sounds at.
	var/max_volume = 30

	var/list/options_map

/obj/item/circuit_component/soundemitter/Destroy()
	options_map = null
	sound_file = null
	volume = null
	backwards = null
	frequency = null
	. = ..()

/obj/item/circuit_component/soundemitter/get_ui_notices()
	. = ..()
	. += create_ui_notice("Перезарядка звука: [DisplayTimeText(sound_emitter_cooldown)]", "orange", "stopwatch")

/obj/item/circuit_component/soundemitter/populate_ports()
	volume = add_input_port("Громкость", PORT_TYPE_NUMBER, default = 35)
	frequency = add_input_port("Частота", PORT_TYPE_NUMBER, default = 0)
	backwards = add_input_port("Наоборот", PORT_TYPE_NUMBER, default = 0)

/obj/item/circuit_component/soundemitter/populate_options()
	var/static/component_options = list(
		"Жужжание" = 'sound/machines/buzz-sigh.ogg',
		"Двойное жужжание" = 'sound/machines/buzz-two.ogg',
		"Звон" = 'sound/machines/chime.ogg',
		"Гудок" = 'sound/items/bikehorn.ogg',
		"Звон №2" = 'sound/machines/ping.ogg',
		"Грустный тромбон" = 'sound/misc/sadtrombone.ogg',
		"Предупреждение" = 'sound/machines/warning-buzzer.ogg',
		"Жужжание моли" = 'sound/voice/scream_moth.ogg',
		"Писк игрушки" = 'sound/items/toysqueak1.ogg',
		"Разрыв" = 'sound/items/poster_ripped.ogg',
		"Подброс монеты" = 'sound/items/coinflip.ogg',
		"Шипение" = 'sound/voice/hiss1.ogg',
		"Светошумовая граната" = 'sound/weapons/flashbang.ogg',
		"Флешер" = 'sound/weapons/flash.ogg',
		"Хлыст" = 'sound/weapons/whip.ogg',
		"Смех толпы" = 'sound/items/sitcomLaugh1.ogg',
		"Судейский молоток" = 'sound/items/gavel.ogg',
		"Пердёж" = SFX_FART,
	)
	sound_file = add_option_port("Звук", component_options)
	options_map = component_options

/obj/item/circuit_component/soundemitter/pre_input_received(datum/port/input/port)
	volume.set_value(clamp(volume.value, 0, 100))
	frequency.set_value(clamp(frequency.value, min_pitch, max_pitch))
	backwards.set_value(clamp(backwards.value, 0, 1))

/obj/item/circuit_component/soundemitter/input_received(datum/port/input/port)
	if(!parent.shell)
		return

	if(TIMER_COOLDOWN_RUNNING(parent.shell, COOLDOWN_CIRCUIT_SOUNDEMITTER))
		return

	var/sound_to_play = options_map[sound_file.value]
	if(!sound_to_play)
		return

	var/actual_frequency = 1 + (frequency.value / 100)
	var/actual_volume = max_volume * (volume.value / 100)

	if(backwards.value)
		actual_frequency = -actual_frequency

	playsound(src, sound_to_play, actual_volume, TRUE, frequency = actual_frequency)

	TIMER_COOLDOWN_START(parent.shell, COOLDOWN_CIRCUIT_SOUNDEMITTER, sound_emitter_cooldown)
