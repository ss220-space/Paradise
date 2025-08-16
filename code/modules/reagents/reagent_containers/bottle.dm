//Not to be confused with /obj/item/reagent_containers/food/drinks/bottle


/obj/item/reagent_containers/glass/bottle
	name = "bottle"
	desc = "Небольшая стеклянная бутылочка."
	ru_names = list(
        NOMINATIVE = "бутылка",
        GENITIVE = "бутылки",
        DATIVE = "бутылке",
        ACCUSATIVE = "бутылку",
        INSTRUMENTAL = "бутылкой",
        PREPOSITIONAL = "бутылке"
	)
	gender = FEMALE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "round_bottle"
	item_state = "round_bottle"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30)
	container_type = OPENCONTAINER
	volume = 30

/obj/item/reagent_containers/glass/bottle/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)


/obj/item/reagent_containers/glass/bottle/update_overlays()
	. = ..()
	underlays.Cut()
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 24)
				filling.icon_state = "[icon_state]10"
			if(25 to 49)
				filling.icon_state = "[icon_state]25"
			if(50 to 74)
				filling.icon_state = "[icon_state]50"
			if(75 to 90)
				filling.icon_state = "[icon_state]75"
			if(91 to INFINITY)
				filling.icon_state = "[icon_state]100"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		underlays += filling

	if(!is_open_container())
		. += "lid_[icon_state]"


/obj/item/reagent_containers/glass/bottle/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!reagents.total_volume)
		C.stored_comms["glass"] += 3
		qdel(src)
		return TRUE
	return ..()

/obj/item/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится сильный токсин."
	ru_names = list(
        NOMINATIVE = "бутылка (Токсины)",
        GENITIVE = "бутылки (Токсины)",
        DATIVE = "бутылке (Токсины)",
        ACCUSATIVE = "бутылку (Токсины)",
        INSTRUMENTAL = "бутылкой (Токсины)",
        PREPOSITIONAL = "бутылке (Токсины)"
	)
	icon_state = "small_bottle"
	list_reagents = list("toxin" = 30)

/obj/item/reagent_containers/glass/bottle/atropine
	name = "atropine bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится атропин."
	ru_names = list(
        NOMINATIVE = "бутылка (Атропин)",
        GENITIVE = "бутылки (Атропин)",
        DATIVE = "бутылке (Атропин)",
        ACCUSATIVE = "бутылку (Атропин)",
        INSTRUMENTAL = "бутылкой (Атропин)",
        PREPOSITIONAL = "бутылке (Атропин)"
	)
	icon_state = "small_bottle"
	list_reagents = list("atropine" = 30)

/obj/item/reagent_containers/glass/bottle/saline
	name = "saline-glucose bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится физиологический раствор."
	ru_names = list(
        NOMINATIVE = "бутылка (Физраствор)",
        GENITIVE = "бутылки (Физраствор)",
        DATIVE = "бутылке (Физраствор)",
        ACCUSATIVE = "бутылку (Физраствор)",
        INSTRUMENTAL = "бутылкой (Физраствор)",
        PREPOSITIONAL = "бутылке (Физраствор)"
	)
	icon_state = "small_bottle"
	list_reagents = list("salglu_solution" = 30)

/obj/item/reagent_containers/glass/bottle/salicylic
	name = "salicylic acid bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится салициловая кислота."
	ru_names = list(
        NOMINATIVE = "бутылка (Салициловая кислота)",
        GENITIVE = "бутылки (Салициловая кислота)",
        DATIVE = "бутылке (Салициловая кислота)",
        ACCUSATIVE = "бутылку (Салициловая кислота)",
        INSTRUMENTAL = "бутылкой (Салициловая кислота)",
        PREPOSITIONAL = "бутылке (Салициловая кислота)"
	)
	icon_state = "small_bottle"
	list_reagents = list("sal_acid" = 30)

/obj/item/reagent_containers/glass/bottle/cyanide
	name = "cyanide bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится очень токсичный цианид."
	ru_names = list(
        NOMINATIVE = "бутылка (Цианид)",
        GENITIVE = "бутылки (Цианид)",
        DATIVE = "бутылке (Цианид)",
        ACCUSATIVE = "бутылку (Цианид)",
        INSTRUMENTAL = "бутылкой (Цианид)",
        PREPOSITIONAL = "бутылке (Цианид)"
	)
	icon_state = "small_bottle"
	list_reagents = list("cyanide" = 30)

/obj/item/reagent_containers/glass/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится нестабильный мутаген."
	ru_names = list(
        NOMINATIVE = "бутылка (Нестабильный мутаген)",
        GENITIVE = "бутылки (Нестабильный мутаген)",
        DATIVE = "бутылке (Нестабильный мутаген)",
        ACCUSATIVE = "бутылку (Нестабильный мутаген)",
        INSTRUMENTAL = "бутылкой (Нестабильный мутаген)",
        PREPOSITIONAL = "бутылке (Нестабильный мутаген)"
	)
	icon_state = "bottle"
	list_reagents = list("mutagen" = 30)

/obj/item/reagent_containers/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится аммиак."
	ru_names = list(
        NOMINATIVE = "бутылка (Аммиак)",
        GENITIVE = "бутылки (Аммиак)",
        DATIVE = "бутылке (Аммиак)",
        ACCUSATIVE = "бутылку (Аммиак)",
        INSTRUMENTAL = "бутылкой (Аммиак)",
        PREPOSITIONAL = "бутылке (Аммиак)"
	)
	icon_state = "bottle"
	list_reagents = list("ammonia" = 30)

/obj/item/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится диэтиламин."
	ru_names = list(
        NOMINATIVE = "бутылка (Диэтиламин)",
        GENITIVE = "бутылки (Диэтиламин)",
        DATIVE = "бутылке (Диэтиламин)",
        ACCUSATIVE = "бутылку (Диэтиламин)",
        INSTRUMENTAL = "бутылкой (Диэтиламин)",
        PREPOSITIONAL = "бутылке (Диэтиламин)"
	)
	icon_state = "round_bottle"
	list_reagents = list("diethylamine" = 30)

/obj/item/reagent_containers/glass/bottle/facid
	name = "Fluorosulfuric Acid Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится фторсерная кислота."
	ru_names = list(
        NOMINATIVE = "бутылка (Фторсерная кислота)",
        GENITIVE = "бутылки (Фторсерная кислота)",
        DATIVE = "бутылке (Фторсерная кислота)",
        ACCUSATIVE = "бутылку (Фторсерная кислота)",
        INSTRUMENTAL = "бутылкой (Фторсерная кислота)",
        PREPOSITIONAL = "бутылке (Фторсерная кислота)"
	)
	icon_state = "round_bottle"
	list_reagents = list("facid" = 30)

/obj/item/reagent_containers/glass/bottle/adminordrazine
	name = "Adminordrazine Bottle"
	desc = "Небольшая стеклянная бутылочка, содержащая в себе божественную эссенцию."
	ru_names = list(
        NOMINATIVE = "бутылка (Админордразин)",
        GENITIVE = "бутылки (Админордразин)",
        DATIVE = "бутылке (Админордразин)",
        ACCUSATIVE = "бутылку (Админордразин)",
        INSTRUMENTAL = "бутылкой (Админордразин)",
        PREPOSITIONAL = "бутылке (Админордразин)"
	)
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	list_reagents = list("adminordrazine" = 30)

/obj/item/reagent_containers/glass/bottle/capsaicin
	name = "Capsaicin Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится капсаицин, получаемый из перца чили."
	ru_names = list(
        NOMINATIVE = "бутылка (Капсаицин)",
        GENITIVE = "бутылки (Капсаицин)",
        DATIVE = "бутылке (Капсаицин)",
        ACCUSATIVE = "бутылку (Капсаицин)",
        INSTRUMENTAL = "бутылкой (Капсаицин)",
        PREPOSITIONAL = "бутылке (Капсаицин)"
	)
	icon_state = "round_bottle"
	list_reagents = list("capsaicin" = 30)

/obj/item/reagent_containers/glass/bottle/frostoil
	name = "Frost Oil Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится ледяное масло, получаемое из ледяного перца чили."
	ru_names = list(
        NOMINATIVE = "бутылка (Ледяное масло)",
        GENITIVE = "бутылки (Ледяное масло)",
        DATIVE = "бутылке (Ледяное масло)",
        ACCUSATIVE = "бутылку (Ледяное масло)",
        INSTRUMENTAL = "бутылкой (Ледяное масло)",
        PREPOSITIONAL = "бутылке (Ледяное масло)"
	)
	icon_state = "round_bottle"
	list_reagents = list("frostoil" = 30)

/obj/item/reagent_containers/glass/bottle/morphine
	name = "Morphine Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится морфин."
	ru_names = list(
        NOMINATIVE = "бутылка (Морфин)",
        GENITIVE = "бутылки (Морфин)",
        DATIVE = "бутылке (Морфин)",
        ACCUSATIVE = "бутылку (Морфин)",
        INSTRUMENTAL = "бутылкой (Морфин)",
        PREPOSITIONAL = "бутылке (Морфин)"
	)
	icon_state = "bottle"
	list_reagents = list("morphine" = 30)

/obj/item/reagent_containers/glass/bottle/ether
	name = "Ether Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится эфир."
	ru_names = list(
        NOMINATIVE = "бутылка (Эфир)",
        GENITIVE = "бутылки (Эфир)",
        DATIVE = "бутылке (Эфир)",
        ACCUSATIVE = "бутылку (Эфир)",
        INSTRUMENTAL = "бутылкой (Эфир)",
        PREPOSITIONAL = "бутылке (Эфир)"
	)
	icon_state = "round_bottle"
	list_reagents = list("ether" = 30)

/obj/item/reagent_containers/glass/bottle/charcoal
	name = "Charcoal Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится активированный уголь."
	ru_names = list(
        NOMINATIVE = "бутылка (Активированный уголь)",
        GENITIVE = "бутылки (Активированный уголь)",
        DATIVE = "бутылке (Активированный уголь)",
        ACCUSATIVE = "бутылку (Активированный уголь)",
        INSTRUMENTAL = "бутылкой (Активированный уголь)",
        PREPOSITIONAL = "бутылке (Активированный уголь)"
	)
	icon_state = "wide_bottle"
	list_reagents = list("charcoal" = 30)

/obj/item/reagent_containers/glass/bottle/epinephrine
	name = "Epinephrine Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится эпинефрин."
	ru_names = list(
        NOMINATIVE = "бутылка (Эпинефрин)",
        GENITIVE = "бутылки (Эпинефрин)",
        DATIVE = "бутылке (Эпинефрин)",
        ACCUSATIVE = "бутылку (Эпинефрин)",
        INSTRUMENTAL = "бутылкой (Эпинефрин)",
        PREPOSITIONAL = "бутылке (Эпинефрин)"
	)
	icon_state = "round_bottle"
	list_reagents = list("epinephrine" = 30)

/obj/item/reagent_containers/glass/bottle/pancuronium
	name = "Pancuronium Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится панкуроний."
	ru_names = list(
        NOMINATIVE = "бутылка (Панкуроний)",
        GENITIVE = "бутылки (Панкуроний)",
        DATIVE = "бутылке (Панкуроний)",
        ACCUSATIVE = "бутылку (Панкуроний)",
        INSTRUMENTAL = "бутылкой (Панкуроний)",
        PREPOSITIONAL = "бутылке (Панкуроний)"
	)
	icon_state = "round_bottle"
	list_reagents = list("pancuronium" = 30)

/obj/item/reagent_containers/glass/bottle/sulfonal
	name = "Sulfonal Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится сульфонал."
	ru_names = list(
        NOMINATIVE = "бутылка (Сульфонал)",
        GENITIVE = "бутылки (Сульфонал)",
        DATIVE = "бутылке (Сульфонал)",
        ACCUSATIVE = "бутылку (Сульфонал)",
        INSTRUMENTAL = "бутылкой (Сульфонал)",
        PREPOSITIONAL = "бутылке (Сульфонал)"
	)
	icon_state = "round_bottle"
	list_reagents = list("sulfonal" = 30)

//Reagent bottles

/obj/item/reagent_containers/glass/bottle/reagent
	name = "Reagent Bottle"
	desc = "Небольшая стеклянная бутылочка."
	icon_state = "reagent_bottle"
	volume = 50

/obj/item/reagent_containers/glass/bottle/reagent/oil
	name = "Oil Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится масло."
	ru_names = list(
        NOMINATIVE = "бутылка (Масло)",
        GENITIVE = "бутылки (Масло)",
        DATIVE = "бутылке (Масло)",
        ACCUSATIVE = "бутылку (Масло)",
        INSTRUMENTAL = "бутылкой (Масло)",
        PREPOSITIONAL = "бутылке (Масло)"
	)
	list_reagents = list("oil" = 50)
	pixel_x = -4
	pixel_y = 6

/obj/item/reagent_containers/glass/bottle/reagent/phenol
	name = "Phenol Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится фенол."
	ru_names = list(
        NOMINATIVE = "бутылка (Фенол)",
        GENITIVE = "бутылки (Фенол)",
        DATIVE = "бутылке (Фенол)",
        ACCUSATIVE = "бутылку (Фенол)",
        INSTRUMENTAL = "бутылкой (Фенол)",
        PREPOSITIONAL = "бутылке (Фенол)"
	)
	list_reagents = list("phenol" = 50)
	pixel_x = 6
	pixel_y = 6

/obj/item/reagent_containers/glass/bottle/reagent/acetone
	name = "Acetone Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится ацетон."
	ru_names = list(
        NOMINATIVE = "бутылка (Ацетон)",
        GENITIVE = "бутылки (Ацетон)",
        DATIVE = "бутылке (Ацетон)",
        ACCUSATIVE = "бутылку (Ацетон)",
        INSTRUMENTAL = "бутылкой (Ацетон)",
        PREPOSITIONAL = "бутылке (Ацетон)"
	)
	list_reagents = list("acetone" = 50)
	pixel_x = -4

/obj/item/reagent_containers/glass/bottle/reagent/ammonia
	name = "Ammonia Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится аммиак."
	ru_names = list(
        NOMINATIVE = "бутылка (Аммиак)",
        GENITIVE = "бутылки (Аммиак)",
        DATIVE = "бутылке (Аммиак)",
        ACCUSATIVE = "бутылку (Аммиак)",
        INSTRUMENTAL = "бутылкой (Аммиак)",
        PREPOSITIONAL = "бутылке (Аммиак)"
	)
	list_reagents = list("ammonia" = 50)
	pixel_x = 6

/obj/item/reagent_containers/glass/bottle/reagent/diethylamine
	name = "Diethylamine Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится диэтиламин."
	ru_names = list(
        NOMINATIVE = "бутылка (Диэтиламин)",
        GENITIVE = "бутылки (Диэтиламин)",
        DATIVE = "бутылке (Диэтиламин)",
        ACCUSATIVE = "бутылку (Диэтиламин)",
        INSTRUMENTAL = "бутылкой (Диэтиламин)",
        PREPOSITIONAL = "бутылке (Диэтиламин)"
	)
	list_reagents = list("diethylamine" = 50)
	pixel_x = -4
	pixel_y = -6

/obj/item/reagent_containers/glass/bottle/reagent/acid
	name = "Acid Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится серная кислота."
	ru_names = list(
        NOMINATIVE = "бутылка (Серная кислота)",
        GENITIVE = "бутылки (Серная кислота)",
        DATIVE = "бутылке (Серная кислота)",
        ACCUSATIVE = "бутылку (Серная кислота)",
        INSTRUMENTAL = "бутылкой (Серная кислота)",
        PREPOSITIONAL = "бутылке (Серная кислота)"
	)
	list_reagents = list("sacid" = 50)
	pixel_x = 6
	pixel_y = -6

/obj/item/reagent_containers/glass/bottle/reagent/formaldehyde
	name = "Formaldehyde Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится формальдегид."
	ru_names = list(
        NOMINATIVE = "бутылка (Формальдегид)",
        GENITIVE = "бутылки (Формальдегид)",
        DATIVE = "бутылке (Формальдегид)",
        ACCUSATIVE = "бутылку (Формальдегид)",
        INSTRUMENTAL = "бутылкой (Формальдегид)",
        PREPOSITIONAL = "бутылке (Формальдегид)"
	)
	list_reagents = list("formaldehyde" = 50)

/obj/item/reagent_containers/glass/bottle/reagent/synaptizine
	name = "Synaptizine Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится синаптизин."
	ru_names = list(
        NOMINATIVE = "бутылка (Синаптизин)",
        GENITIVE = "бутылки (Синаптизин)",
        DATIVE = "бутылке (Синаптизин)",
        ACCUSATIVE = "бутылку (Синаптизин)",
        INSTRUMENTAL = "бутылкой (Синаптизин)",
        PREPOSITIONAL = "бутылке (Синаптизин)"
	)
	list_reagents = list("synaptizine" = 50)

/obj/item/reagent_containers/glass/bottle/reagent/morphine
	name = "Morphine Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится морфин."
	ru_names = list(
        NOMINATIVE = "бутылка (Морфин)",
        GENITIVE = "бутылки (Морфин)",
        DATIVE = "бутылке (Морфин)",
        ACCUSATIVE = "бутылку (Морфин)",
        INSTRUMENTAL = "бутылкой (Морфин)",
        PREPOSITIONAL = "бутылке (Морфин)"
	)
	list_reagents = list("morphine" = 50)

/obj/item/reagent_containers/glass/bottle/reagent/insulin
	name = "Insulin Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится инсулин."
	ru_names = list(
        NOMINATIVE = "бутылка (Инсулин)",
        GENITIVE = "бутылки (Инсулин)",
        DATIVE = "бутылке (Инсулин)",
        ACCUSATIVE = "бутылку (Инсулин)",
        INSTRUMENTAL = "бутылкой (Инсулин)",
        PREPOSITIONAL = "бутылке (Инсулин)"
	)
	list_reagents = list("insulin" = 50)

/obj/item/reagent_containers/glass/bottle/reagent/hairgrownium
	name = "Hair Grow Gel"
	desc = "Небольшая стеклянная бутылочка, внутри находится власорост."
	ru_names = list(
        NOMINATIVE = "бутылка (Власорост)",
        GENITIVE = "бутылки (Власорост)",
        DATIVE = "бутылке (Власорост)",
        ACCUSATIVE = "бутылку (Власорост)",
        INSTRUMENTAL = "бутылкой (Власорост)",
        PREPOSITIONAL = "бутылке (Власорост)"
	)
	list_reagents = list("hairgrownium" = 50)

/obj/item/reagent_containers/glass/bottle/reagent/hair_dye
	name = "Quantum Hair Dye Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится квантовая краска для волос."
	ru_names = list(
        NOMINATIVE = "бутылка (Квантовая краска для волос)",
        GENITIVE = "бутылки (Квантовая краска для волос)",
        DATIVE = "бутылке (Квантовая краска для волос)",
        ACCUSATIVE = "бутылку (Квантовая краска для волос)",
        INSTRUMENTAL = "бутылкой (Квантовая краска для волос)",
        PREPOSITIONAL = "бутылке (Квантовая краска для волос)"
	)
	list_reagents = list("hair_dye" = 50)

/obj/item/reagent_containers/glass/bottle/reagent/omnizine
	name = "Omnizine Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится омнизин."
	ru_names = list(
        NOMINATIVE = "бутылка (Омнизин)",
        GENITIVE = "бутылки (Омнизин)",
        DATIVE = "бутылке (Омнизин)",
        ACCUSATIVE = "бутылку (Омнизин)",
        INSTRUMENTAL = "бутылкой (Омнизин)",
        PREPOSITIONAL = "бутылке (Омнизин)"
	)
	list_reagents = list("omnizine" = 50)

/obj/item/reagent_containers/glass/bottle/reagent/strange_reagent
	name = "Strange Reagent Bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится странный реагент."
	ru_names = list(
        NOMINATIVE = "бутылка (Странный реагент)",
        GENITIVE = "бутылки (Странный реагент)",
        DATIVE = "бутылке (Странный реагент)",
        ACCUSATIVE = "бутылку (Странный реагент)",
        INSTRUMENTAL = "бутылкой (Странный реагент)",
        PREPOSITIONAL = "бутылке (Странный реагент)"
	)
	list_reagents = list("strange_reagent" = 30)

////////////////////Traitor Poison Bottle//////////////////////////////

/obj/item/reagent_containers/glass/bottle/traitor
	desc = "На ней изображён маленький череп и скрещённые кости. О-о-о!"
	possible_transfer_amounts = list(5,10,15,25,30,40)
	volume = 40

/obj/item/reagent_containers/glass/bottle/traitor/Initialize(mapload)
	reagents.add_reagent(pick_list("chemistry_tools.json", "traitor_poison_bottle"), 40)
	. = ..()

/obj/item/reagent_containers/glass/bottle/plasma
	name = "plasma dust bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится плазменная пыль."
	ru_names = list(
        NOMINATIVE = "бутылка (Плазменная пыль)",
        GENITIVE = "бутылки (Плазменная пыль)",
        DATIVE = "бутылке (Плазменная пыль)",
        ACCUSATIVE = "бутылку (Плазменная пыль)",
        INSTRUMENTAL = "бутылкой (Плазменная пыль)",
        PREPOSITIONAL = "бутылке (Плазменная пыль)"
	)
	icon_state = "wide_bottle"
	list_reagents = list("plasma_dust" = 30)

/obj/item/reagent_containers/glass/bottle/diphenhydramine
	name = "diphenhydramine bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится дифенгидрамин."
	ru_names = list(
        NOMINATIVE = "бутылка (Дифенгидрамин)",
        GENITIVE = "бутылки (Дифенгидрамин)",
        DATIVE = "бутылке (Дифенгидрамин)",
        ACCUSATIVE = "бутылку (Дифенгидрамин)",
        INSTRUMENTAL = "бутылкой (Дифенгидрамин)",
        PREPOSITIONAL = "бутылке (Дифенгидрамин)"
	)
	icon_state = "round_bottle"
	list_reagents = list("diphenhydramine" = 30)

/obj/item/reagent_containers/glass/bottle/oculine
	name = "oculine bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится окулин."
	ru_names = list(
        NOMINATIVE = "бутылка (Окулин)",
        GENITIVE = "бутылки (Окулин)",
        DATIVE = "бутылке (Окулин)",
        ACCUSATIVE = "бутылку (Окулин)",
        INSTRUMENTAL = "бутылкой (Окулин)",
        PREPOSITIONAL = "бутылке (Окулин)"
	)
	icon_state = "round_bottle"
	list_reagents = list("oculine" = 30)

/obj/item/reagent_containers/glass/bottle/potassium_iodide
	name = "potassium iodide bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится иодид калия."
	ru_names = list(
        NOMINATIVE = "бутылка (Иодид калия)",
        GENITIVE = "бутылки (Иодид калия)",
        DATIVE = "бутылке (Иодид калия)",
        ACCUSATIVE = "бутылку (Иодид калия)",
        INSTRUMENTAL = "бутылкой (Иодид калия)",
        PREPOSITIONAL = "бутылке (Иодид калия)"
	)
	icon_state = "wide_bottle"
	list_reagents = list("potass_iodide" = 30)

/obj/item/reagent_containers/glass/bottle/cold
	name = "Rhinovirus culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Простуда\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Простуда)",
		GENITIVE = "вирусной культуры (Простуда)",
		DATIVE = "вирусной культуре (Простуда)",
		ACCUSATIVE = "вирусную культуру (Простуда)",
		INSTRUMENTAL = "вирусной культурой (Простуда)",
		PREPOSITIONAL = "вирусной культуре (Простуда)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/cold

/obj/item/reagent_containers/glass/bottle/flu
	name = "Flu virion culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Грипп\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Грипп)",
		GENITIVE = "вирусной культуры (Грипп)",
		DATIVE = "вирусной культуре (Грипп)",
		ACCUSATIVE = "вирусную культуру (Грипп)",
		INSTRUMENTAL = "вирусной культурой (Грипп)",
		PREPOSITIONAL = "вирусной культуре (Грипп)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/flu

/obj/item/reagent_containers/glass/bottle/sneezing
	name = "Sneezing symptom bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Чихание\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Чихание)",
		GENITIVE = "вирусной культуры (Чихание)",
		DATIVE = "вирусной культуре (Чихание)",
		ACCUSATIVE = "вирусную культуру (Чихание)",
		INSTRUMENTAL = "вирусной культурой (Чихание)",
		PREPOSITIONAL = "вирусной культуре (Чихание)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/sneezing

/obj/item/reagent_containers/glass/bottle/cough
	name = "Cough symptom bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Кашель\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Кашель)",
		GENITIVE = "вирусной культуры (Кашель)",
		DATIVE = "вирусной культуре (Кашель)",
		ACCUSATIVE = "вирусную культуру (Кашель)",
		INSTRUMENTAL = "вирусной культурой (Кашель)",
		PREPOSITIONAL = "вирусной культуре (Кашель)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/cough

/obj/item/reagent_containers/glass/bottle/epiglottis_virion
	name = "Epiglottis virion culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Надгортанник\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Надгортанник)",
		GENITIVE = "вирусной культуры (Надгортанник)",
		DATIVE = "вирусной культуре (Надгортанник)",
		ACCUSATIVE = "вирусную культуру (Надгортанник)",
		INSTRUMENTAL = "вирусной культурой (Надгортанник)",
		PREPOSITIONAL = "вирусной культуре (Надгортанник)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/voice_change

/obj/item/reagent_containers/glass/bottle/liver_enhance_virion
	name = "Liver enhancement virion culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Укрепление печени\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Укрепление печени)",
		GENITIVE = "вирусной культуры (Укрепление печени)",
		DATIVE = "вирусной культуре (Укрепление печени)",
		ACCUSATIVE = "вирусную культуру (Укрепление печени)",
		INSTRUMENTAL = "вирусной культурой (Укрепление печени)",
		PREPOSITIONAL = "вирусной культуре (Укрепление печени)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/heal

/obj/item/reagent_containers/glass/bottle/hullucigen_virion
	name = "Hullucigen virion culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Галлюцинации\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Галлюцинации)",
		GENITIVE = "вирусной культуры (Галлюцинации)",
		DATIVE = "вирусной культуре (Галлюцинации)",
		ACCUSATIVE = "вирусную культуру (Галлюцинации)",
		INSTRUMENTAL = "вирусной культурой (Галлюцинации)",
		PREPOSITIONAL = "вирусной культуре (Галлюцинации)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/hullucigen

/obj/item/reagent_containers/glass/bottle/pierrot_throat
	name = "Pierrot's Throat culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Горло Пьеро\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Горло Пьеро)",
		GENITIVE = "вирусной культуры (Горло Пьеро)",
		DATIVE = "вирусной культуре (Горло Пьеро)",
		ACCUSATIVE = "вирусную культуру (Горло Пьеро)",
		INSTRUMENTAL = "вирусной культурой (Горло Пьеро)",
		PREPOSITIONAL = "вирусной культуре (Горло Пьеро)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/pierrot_throat

/obj/item/reagent_containers/glass/bottle/mind_restoration
	name = "Reality Purifier culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Восстановление сознания\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Восстановление сознания)",
		GENITIVE = "вирусной культуры (Восстановление сознания)",
		DATIVE = "вирусной культуре (Восстановление сознания)",
		ACCUSATIVE = "вирусную культуру (Восстановление сознания)",
		INSTRUMENTAL = "вирусной культурой (Восстановление сознания)",
		PREPOSITIONAL = "вирусной культуре (Восстановление сознания)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/mind_restoration

/obj/item/reagent_containers/glass/bottle/advanced_regeneration
	name = "Advanced Neogenesis culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Улучшенная регенерация\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Улучшенная регенерация)",
		GENITIVE = "вирусной культуры (Улучшенная регенерация)",
		DATIVE = "вирусной культуре (Улучшенная регенерация)",
		ACCUSATIVE = "вирусную культуру (Улучшенная регенерация)",
		INSTRUMENTAL = "вирусной культурой (Улучшенная регенерация)",
		PREPOSITIONAL = "вирусной культуре (Улучшенная регенерация)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/advanced_regeneration

/obj/item/reagent_containers/glass/bottle/stealth_necrosis
	name = "Necroeyrosis culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Некроз\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Некроз)",
		GENITIVE = "вирусной культуры (Некроз)",
		DATIVE = "вирусной культуре (Некроз)",
		ACCUSATIVE = "вирусную культуру (Некроз)",
		INSTRUMENTAL = "вирусной культурой (Некроз)",
		PREPOSITIONAL = "вирусной культуре (Некроз)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/stealth_necrosis

/obj/item/reagent_containers/glass/bottle/pre_kingstons
	name = "Neverlasting Stranger culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Синдром Кингстона\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Синдром Кингстона)",
		GENITIVE = "вирусной культуры (Синдром Кингстона)",
		DATIVE = "вирусной культуре (Синдром Кингстона)",
		ACCUSATIVE = "вирусную культуру (Синдром Кингстона)",
		INSTRUMENTAL = "вирусной культурой (Синдром Кингстона)",
		PREPOSITIONAL = "вирусной культуре (Синдром Кингстона)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/pre_kingstons

/obj/item/reagent_containers/glass/bottle/love
	name = "love"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Любовь\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Любовь)",
		GENITIVE = "вирусной культуры (Любовь)",
		DATIVE = "вирусной культуре (Любовь)",
		ACCUSATIVE = "вирусную культуру (Любовь)",
		INSTRUMENTAL = "вирусной культурой (Любовь)",
		PREPOSITIONAL = "вирусной культуре (Любовь)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/love

/obj/item/reagent_containers/glass/bottle/aggression
	name = "aggression"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Агрессия\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Агрессия)",
		GENITIVE = "вирусной культуры (Агрессия)",
		DATIVE = "вирусной культуре (Агрессия)",
		ACCUSATIVE = "вирусную культуру (Агрессия)",
		INSTRUMENTAL = "вирусной культурой (Агрессия)",
		PREPOSITIONAL = "вирусной культуре (Агрессия)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/aggression

/obj/item/reagent_containers/glass/bottle/obsession
	name = "obsession"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Одержимость\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Одержимость)",
		GENITIVE = "вирусной культуры (Одержимость)",
		DATIVE = "вирусной культуре (Одержимость)",
		ACCUSATIVE = "вирусную культуру (Одержимость)",
		INSTRUMENTAL = "вирусной культурой (Одержимость)",
		PREPOSITIONAL = "вирусной культуре (Одержимость)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/obsession

/obj/item/reagent_containers/glass/bottle/confusion
	name = "confusion"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Замешательство\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Замешательство)",
		GENITIVE = "вирусной культуры (Замешательство)",
		DATIVE = "вирусной культуре (Замешательство)",
		ACCUSATIVE = "вирусную культуру (Замешательство)",
		INSTRUMENTAL = "вирусной культурой (Замешательство)",
		PREPOSITIONAL = "вирусной культуре (Замешательство)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/confusion

/obj/item/reagent_containers/glass/bottle/bones
	name = "bones"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Кости\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Кости)",
		GENITIVE = "вирусной культуры (Кости)",
		DATIVE = "вирусной культуре (Кости)",
		ACCUSATIVE = "вирусную культуру (Кости)",
		INSTRUMENTAL = "вирусной культурой (Кости)",
		PREPOSITIONAL = "вирусной культуре (Кости)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/bones

/obj/item/reagent_containers/glass/bottle/limb_throw
	name = "limb_throw"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Отстреливание конечностей\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Отстреливание конечностей)",
		GENITIVE = "вирусной культуры (Отстреливание конечностей)",
		DATIVE = "вирусной культуре (Отстреливание конечностей)",
		ACCUSATIVE = "вирусную культуру (Отстреливание конечностей)",
		INSTRUMENTAL = "вирусной культурой (Отстреливание конечностей)",
		PREPOSITIONAL = "вирусной культуре (Отстреливание конечностей)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/limb_throw

/obj/item/reagent_containers/glass/bottle/laugh
	name = "laugh"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Смех\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Смех)",
		GENITIVE = "вирусной культуры (Смех)",
		DATIVE = "вирусной культуре (Смех)",
		ACCUSATIVE = "вирусную культуру (Смех)",
		INSTRUMENTAL = "вирусной культурой (Смех)",
		PREPOSITIONAL = "вирусной культуре (Смех)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/laugh

/obj/item/reagent_containers/glass/bottle/moan
	name = "moan"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Стоны\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Стоны)",
		GENITIVE = "вирусной культуры (Стоны)",
		DATIVE = "вирусной культуре (Стоны)",
		ACCUSATIVE = "вирусную культуру (Стоны)",
		INSTRUMENTAL = "вирусной культурой (Стоны)",
		PREPOSITIONAL = "вирусной культуре (Стоны)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/moan

/obj/item/reagent_containers/glass/bottle/infection
	name = "infection"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Инфекция\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Инфекция)",
		GENITIVE = "вирусной культуры (Инфекция)",
		DATIVE = "вирусной культуре (Инфекция)",
		ACCUSATIVE = "вирусную культуру (Инфекция)",
		INSTRUMENTAL = "вирусной культурой (Инфекция)",
		PREPOSITIONAL = "вирусной культуре (Инфекция)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/infection

/obj/item/reagent_containers/glass/bottle/loyalty
	name = "loyalty"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Преданность\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Преданность)",
		GENITIVE = "вирусной культуры (Преданность)",
		DATIVE = "вирусной культуре (Преданность)",
		ACCUSATIVE = "вирусную культуру (Преданность)",
		INSTRUMENTAL = "вирусной культурой (Преданность)",
		PREPOSITIONAL = "вирусной культуре (Преданность)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/loyalty

/obj/item/reagent_containers/glass/bottle/pre_loyalty
	name = "pre_loyalty"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Пре-преданность\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Пре-преданность)",
		GENITIVE = "вирусной культуры (Пре-преданность)",
		DATIVE = "вирусной культуре (Пре-преданность)",
		ACCUSATIVE = "вирусную культуру (Пре-преданность)",
		INSTRUMENTAL = "вирусной культурой (Пре-преданность)",
		PREPOSITIONAL = "вирусной культуре (Пре-преданность)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/pre_loyalty

/obj/item/reagent_containers/glass/bottle/retrovirus
	name = "Retrovirus culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Ретровирус\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Ретровирус)",
		GENITIVE = "вирусной культуры (Ретровирус)",
		DATIVE = "вирусной культуре (Ретровирус)",
		ACCUSATIVE = "вирусную культуру (Ретровирус)",
		INSTRUMENTAL = "вирусной культурой (Ретровирус)",
		PREPOSITIONAL = "вирусной культуре (Ретровирус)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/dna_retrovirus

/obj/item/reagent_containers/glass/bottle/gbs
	name = "GBS culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"ГБС+\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (ГБС+)",
		GENITIVE = "вирусной культуры (ГБС+)",
		DATIVE = "вирусной культуре (ГБС+)",
		ACCUSATIVE = "вирусную культуру (ГБС+)",
		INSTRUMENTAL = "вирусной культурой (ГБС+)",
		PREPOSITIONAL = "вирусной культуре (ГБС+)"
	)
	icon_state = "round_bottle"
	amount_per_transfer_from_this = 5
	spawned_disease = /datum/disease/virus/gbs

/obj/item/reagent_containers/glass/bottle/fake_gbs
	name = "GBS culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"ГБС-\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (ГБС-)",
		GENITIVE = "вирусной культуры (ГБС-)",
		DATIVE = "вирусной культуре (ГБС-)",
		ACCUSATIVE = "вирусную культуру (ГБС-)",
		INSTRUMENTAL = "вирусной культурой (ГБС-)",
		PREPOSITIONAL = "вирусной культуре (ГБС-)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/fake_gbs

/obj/item/reagent_containers/glass/bottle/brainrot
	name = "Brainrot culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Мозговая гниль\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Мозговая гниль)",
		GENITIVE = "вирусной культуры (Мозговая гниль)",
		DATIVE = "вирусной культуре (Мозговая гниль)",
		ACCUSATIVE = "вирусную культуру (Мозговая гниль)",
		INSTRUMENTAL = "вирусной культурой (Мозговая гниль)",
		PREPOSITIONAL = "вирусной культуре (Мозговая гниль)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/brainrot

/obj/item/reagent_containers/glass/bottle/magnitis
	name = "Magnitis culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Магнитис\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Магнитис)",
		GENITIVE = "вирусной культуры (Магнитис)",
		DATIVE = "вирусной культуре (Магнитис)",
		ACCUSATIVE = "вирусную культуру (Магнитис)",
		INSTRUMENTAL = "вирусной культурой (Магнитис)",
		PREPOSITIONAL = "вирусной культуре (Магнитис)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/magnitis

/obj/item/reagent_containers/glass/bottle/wizarditis
	name = "Wizarditis culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Визардис\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Визардис)",
		GENITIVE = "вирусной культуры (Визардис)",
		DATIVE = "вирусной культуре (Визардис)",
		ACCUSATIVE = "вирусную культуру (Визардис)",
		INSTRUMENTAL = "вирусной культурой (Визардис)",
		PREPOSITIONAL = "вирусной культуре (Визардис)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/wizarditis

/obj/item/reagent_containers/glass/bottle/anxiety
	name = "Severe Anxiety culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Сильное беспокойство\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Сильное беспокойство)",
		GENITIVE = "вирусной культуры (Сильное беспокойство)",
		DATIVE = "вирусной культуре (Сильное беспокойство)",
		ACCUSATIVE = "вирусную культуру (Сильное беспокойство)",
		INSTRUMENTAL = "вирусной культурой (Сильное беспокойство)",
		PREPOSITIONAL = "вирусной культуре (Сильное беспокойство)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/anxiety

/obj/item/reagent_containers/glass/bottle/beesease
	name = "Beesease culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Пчелораза\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Пчелораза)",
		GENITIVE = "вирусной культуры (Пчелораза)",
		DATIVE = "вирусной культуре (Пчелораза)",
		ACCUSATIVE = "вирусную культуру (Пчелораза)",
		INSTRUMENTAL = "вирусной культурой (Пчелораза)",
		PREPOSITIONAL = "вирусной культуре (Пчелораза)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/beesease

/obj/item/reagent_containers/glass/bottle/fluspanish
	name = "Spanish flu culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Испанский Грипп\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Испанский Грипп)",
		GENITIVE = "вирусной культуры (Испанский Грипп)",
		DATIVE = "вирусной культуре (Испанский Грипп)",
		ACCUSATIVE = "вирусную культуру (Испанский Грипп)",
		INSTRUMENTAL = "вирусной культурой (Испанский Грипп)",
		PREPOSITIONAL = "вирусной культуре (Испанский Грипп)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/fluspanish

/obj/item/reagent_containers/glass/bottle/tuberculosis
	name = "Fungal Tuberculosis culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Грибковый туберкулёз\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Грибковый туберкулёз)",
		GENITIVE = "вирусной культуры (Грибковый туберкулёз)",
		DATIVE = "вирусной культуре (Грибковый туберкулёз)",
		ACCUSATIVE = "вирусную культуру (Грибковый туберкулёз)",
		INSTRUMENTAL = "вирусной культурой (Грибковый туберкулёз)",
		PREPOSITIONAL = "вирусной культуре (Грибковый туберкулёз)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/tuberculosis

/obj/item/reagent_containers/glass/bottle/regeneration
	name = "Regeneration culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Восстановление\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Восстановление)",
		GENITIVE = "вирусной культуры (Восстановление)",
		DATIVE = "вирусной культуре (Восстановление)",
		ACCUSATIVE = "вирусную культуру (Восстановление)",
		INSTRUMENTAL = "вирусной культурой (Восстановление)",
		PREPOSITIONAL = "вирусной культуре (Восстановление)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/heal

/obj/item/reagent_containers/glass/bottle/sensory_restoration
	name = "Sensory Restoration culture bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится вирусная культура \"Сенсорное восстановление\"."
	ru_names = list(
		NOMINATIVE = "вирусная культура (Сенсорное восстановление)",
		GENITIVE = "вирусной культуры (Сенсорное восстановление)",
		DATIVE = "вирусной культуре (Сенсорное восстановление)",
		ACCUSATIVE = "вирусную культуру (Сенсорное восстановление)",
		INSTRUMENTAL = "вирусной культурой (Сенсорное восстановление)",
		PREPOSITIONAL = "вирусной культуре (Сенсорное восстановление)"
	)
	icon_state = "round_bottle"
	spawned_disease = /datum/disease/virus/advance/preset/sensory_restoration

/obj/item/reagent_containers/glass/bottle/tuberculosiscure
	name = "BVAK bottle"
	desc = "Небольшая стеклянная бутылочка, внутри находится смесь лекарственных веществ для лечения био-вирусов."
	ru_names = list(
        NOMINATIVE = "бутылка (Био-вирусный антидот)",
        GENITIVE = "бутылки (Био-вирусный антидот)",
        DATIVE = "бутылке (Био-вирусный антидот)",
        ACCUSATIVE = "бутылку (Био-вирусный антидот)",
        INSTRUMENTAL = "бутылкой (Био-вирусный антидот)",
        PREPOSITIONAL = "бутылке (Био-вирусный антидот)"
	)
	icon_state = "wide_bottle"
	list_reagents = list("atropine" = 5, "epinephrine" = 5, "salbutamol" = 10, "spaceacillin" = 10)

/obj/item/reagent_containers/glass/bottle/monkeylangue
	name = "bottle of monkey language potion"
	desc = "Небольшая стеклянная бутылочка, внутри находится вещество, заставляющее выпившего выучить обезьяний язык. Удивительно."
	ru_names = list(
        NOMINATIVE = "бутылка (Обезьяний язык)",
        GENITIVE = "бутылки (Обезьяний язык)",
        DATIVE = "бутылке (Обезьяний язык)",
        ACCUSATIVE = "бутылку (Обезьяний язык)",
        INSTRUMENTAL = "бутылкой (Обезьяний язык)",
        PREPOSITIONAL = "бутылке (Обезьяний язык)"
	)
	icon_state = "round_bottle"
	list_reagents = list("monkeylanguage" = 30)
