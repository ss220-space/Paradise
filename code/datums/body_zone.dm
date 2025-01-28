GLOBAL_LIST_INIT(body_zones, list())

/datum/body_zone
    var/name
    var/list/ru_names

/datum/body_zone/head
    name = "head"
    ru_names = list(
        NOMINATIVE = "голова",
        GENITIVE = "головы",
        DATIVE = "голове",
        ACCUSATIVE = "голову",
        INSTRUMENTAL = "головой",
        PREPOSITIONAL = "голове"
    )

/datum/body_zone/chest
    name = "chest"
    ru_names = list(
        NOMINATIVE = "грудь",
        GENITIVE = "груди",
        DATIVE = "груди",
        ACCUSATIVE = "грудь",
        INSTRUMENTAL = "грудью",
        PREPOSITIONAL = "груди"
    )

/datum/body_zone/arm
    name = "arm"
    ru_names = list(
        NOMINATIVE = "рука",
        GENITIVE = "руки",
        DATIVE = "руке",
        ACCUSATIVE = "руку",
        INSTRUMENTAL = "рукой",
        PREPOSITIONAL = "руке"
    )

/datum/body_zone/arm/left
    name = "left arm"
    ru_names = list(
        NOMINATIVE = "левая рука",
        GENITIVE = "левой руки",
        DATIVE = "левой руке",
        ACCUSATIVE = "левую руку",
        INSTRUMENTAL = "левой рукой",
        PREPOSITIONAL = "левой руке"
    )

/datum/body_zone/arm/right
    name = "right arm"
    ru_names = list(
        NOMINATIVE = "правая рука",
        GENITIVE = "правой руки",
        DATIVE = "правой руке",
        ACCUSATIVE = "правую руку",
        INSTRUMENTAL = "правой рукой",
        PREPOSITIONAL = "правой руке"
    )

/datum/body_zone/leg
    name = "leg"
    ru_names = list(
        NOMINATIVE = "нога",
        GENITIVE = "ноги",
        DATIVE = "ноге",
        ACCUSATIVE = "ногу",
        INSTRUMENTAL = "ногой",
        PREPOSITIONAL = "ноге"
    )

/datum/body_zone/leg/left
    name = "left leg"
    ru_names = list(
        NOMINATIVE = "левая нога",
        GENITIVE = "левой ноги",
        DATIVE = "левой ноге",
        ACCUSATIVE = "левую ногу",
        INSTRUMENTAL = "левой ногой",
        PREPOSITIONAL = "левой ноге"
    )

/datum/body_zone/leg/right
    name = "right leg"
    ru_names = list(
        NOMINATIVE = "правая нога",
        GENITIVE = "правой ноги",
        DATIVE = "правой ноге",
        ACCUSATIVE = "правую ногу",
        INSTRUMENTAL = "правой ногой",
        PREPOSITIONAL = "правой ноге"
    )

/datum/body_zone/tail
    name = "tail"
    ru_names = list(
        NOMINATIVE = "хвост",
        GENITIVE = "хвоста",
        DATIVE = "хвосту",
        ACCUSATIVE = "хвост",
        INSTRUMENTAL = "хвостом",
        PREPOSITIONAL = "хвосте"
    )

/datum/body_zone/wing
    name = "wing"
    ru_names = list(
        NOMINATIVE = "крылья",
        GENITIVE = "крыльев",
        DATIVE = "крыльям",
        ACCUSATIVE = "крылья",
        INSTRUMENTAL = "крыльями",
        PREPOSITIONAL = "крыльях"
    )

/datum/body_zone/eyes
    name = "eyes"
    ru_names = list(
        NOMINATIVE = "глаза",
        GENITIVE = "глаз",
        DATIVE = "глазам",
        ACCUSATIVE = "глаза",
        INSTRUMENTAL = "глазами",
        PREPOSITIONAL = "глазах"
    )

/datum/body_zone/mouth
    name = "mouth"
    ru_names = list(
        NOMINATIVE = "рот",
        GENITIVE = "рта",
        DATIVE = "рту",
        ACCUSATIVE = "рот",
        INSTRUMENTAL = "ртом",
        PREPOSITIONAL = "рте"
    )

/datum/body_zone/groin
    name = "groin"
    ru_names = list(
        NOMINATIVE = "живот",
        GENITIVE = "живота",
        DATIVE = "животу",
        ACCUSATIVE = "живот",
        INSTRUMENTAL = "животом",
        PREPOSITIONAL = "животе"
    )

/datum/body_zone/hand
    name = "hand"
    ru_names = list(
        NOMINATIVE = "кисть",
        GENITIVE = "кисти",
        DATIVE = "кисти",
        ACCUSATIVE = "кисть",
        INSTRUMENTAL = "кистью",
        PREPOSITIONAL = "кисти"
    )

/datum/body_zone/hand/left
    name = "left hand"
    ru_names = list(
        NOMINATIVE = "левая кисть",
        GENITIVE = "левой кисти",
        DATIVE = "левой кисти",
        ACCUSATIVE = "левую кисть",
        INSTRUMENTAL = "левой кистью",
        PREPOSITIONAL = "левой кисти"
    )

/datum/body_zone/hand/right
    name = "right hand"
    ru_names = list(
        NOMINATIVE = "правая кисть",
        GENITIVE = "правой кисти",
        DATIVE = "правой кисти",
        ACCUSATIVE = "правую кисть",
        INSTRUMENTAL = "правой кистью",
        PREPOSITIONAL = "правой кисти"
    )

/datum/body_zone/foot
    name = "foot"
    ru_names = list(
        NOMINATIVE = "ступня",
        GENITIVE = "ступни",
        DATIVE = "ступне",
        ACCUSATIVE = "ступню",
        INSTRUMENTAL = "ступнёй",
        PREPOSITIONAL = "ступне"
    )

/datum/body_zone/foot/left
    name = "left foot"
    ru_names = list(
        NOMINATIVE = "левая ступня",
        GENITIVE = "левой ступни",
        DATIVE = "левой ступне",
        ACCUSATIVE = "левую ступню",
        INSTRUMENTAL = "левой ступнёй",
        PREPOSITIONAL = "левой ступне"
    )

/datum/body_zone/foot/right
    name = "right foot"
    ru_names = list(
        NOMINATIVE = "правая ступня",
        GENITIVE = "правой ступни",
        DATIVE = "правой ступне",
        ACCUSATIVE = "правую ступню",
        INSTRUMENTAL = "правой ступнёй",
        PREPOSITIONAL = "правой ступне"
    )
