
//начальный уровень нагрева систем ИИ
#define AI_INITIAL_HEAT					0
//максимальный уровень нагрева
#define AI_MAX_HEAT						2000
//максимальный уровень резервных систем, активирующихся при красном коде
#define AI_RESERVE_MAX_HEAT				500
//количества тепла, рассеиваемого основной системой охлаждения каждый вызов Life()
#define AI_COOLDOWN_RATE				30
//количества тепла, рассеиваемого резервной системой охлаждения каждый вызов Life()
#define AI_RESERVE_COOLDOWN_RATE		1
//мультипликатор охлаждения при перегреве
#define AI_OVERHEAT_COOLDOWN_MULTIPLIER	5

//использование топиков (все действия во всех консолях)
#define AI_USE_TOPIC_HEAT				30
//большая часть неприметных действий (потрогать вентиль, нажать кнопку, посмотреть на бумажку)
#define AI_NORMAL_ACTION_HEAT			50
//все действия с компьютерами
#define AI_COMPUTER_ACTION_HEAT			100
//открытие двери
#define AI_OPEN_DOOR_HEAT				150
//изменения доступа двери на общий и обратно
#define AI_DOOR_EMERGENCYACCESS_HEAT	150
//электризация двери
#define AI_DOOR_ELECTRIFY_HEAT			250
//болтирование двери
#define AI_DOOR_BOLTS_HEAT				250
//индикатор болтирования двери
#define AI_DOOR_BOLTS_LIGHTS_HEAT		250

//движение камеры
#define AI_MOVE_HEAT					5
//текстовый анонс
#define AI_ANNOUNCEMENT_HEAT			200
//голосовой анонс
#define AI_VOICE_ANNOUNCEMENT_HEAT		400
//вызов/отзыв шаттла
#define AI_CALL_SHUTTLE_HEAT			1000

//попытка отследить человека
#define AI_TRY_TRACK_HEAT				250
//дополнительное тепло к передвижению во время отслеживания
#define AI_IN_TRACKING_HEAT				10

//сохранение локации для камеры
#define AI_LOCATION_STORAGE_HEAT		200
//прыжок к любой камере
#define AI_JUMPTO_CAMERA_HEAT			150
//смена сети камер
#define AI_CHANGE_NETWORK_HEAT			300
//прыжок к своему ядру
#define AI_JUMPTO_CORE_HEAT				50

//смена голограммы
#define AI_CHANGEHOLO_HEAT				100
//открытие списка экипажа
#define AI_SHOW_ROSTER_HEAT				100
//смена статус дисплея
#define AI_STATUSCHANGE_HEAT			100
//смена сообщения анонса прибытия члена экипажа
#define AI_CHANGE_ARRIVAL_MSG_HEAT		100
//отправка сообщения на ПДА
#define AI_SEND_PDA_MESSAGE_HEAT		100
//включение встроенного фотоаппарата
#define AI_TAKE_IMAGE_HEAT				100

//переключение режима отображения сенсоров (медхуд, секхуд и т.д.)
#define AI_TOGGLE_SENSORS_MODE_HEAT		200
//вызов бота куда-либо
#define AI_CALLBOT_HEAT					500
//взятие меха под контроль
#define AI_MECH_CONTROL_HEAT			1000
