/obj/structure/decor/container
	name = "cargo container"
	desc = "Огромный промышленный грузовой контейнер.\nВам не положено это видеть."
	icon = 'icons/obj/structures/container.dmi'
	bound_height = 64
	max_integrity = 200
	opacity = TRUE
	armor = list(MELEE = 0, BULLET = 80, LASER = 80, ENERGY = 0, BOMB = -100, BIO = 0, FIRE = 90, ACID = 90)

/obj/structure/decor/container/get_ru_names()
	return alist(
	NOMINATIVE = "контейнер \"[initial(name)]\"",
	GENITIVE = "контейнера \"[initial(name)]\"",
	DATIVE = "контейнеру \"[initial(name)]\"",
	ACCUSATIVE = "контейнер \"[initial(name)]\"",
	INSTRUMENTAL = "контейнером \"[initial(name)]\"",
	PREPOSITIONAL = "контейнере \"[initial(name)]\"",
	)

/obj/structure/decor/container/watatsumi
	name = "Watatsumi"
	desc = "Огромный промышленный грузовой контейнер.\nОн принадлежит компании \"Watatsumi\", производящей разнообразную электронику и механические изделия.\nПо крайней мере, так написано на самом контейнере. Вы же до этого момента ровным счетом ничего не слышали об этой фирме."

/obj/structure/decor/container/watatsumi/left
	icon_state = "watatsumi_l"

/obj/structure/decor/container/watatsumi/leftmid
	icon_state = "watatsumi_lm"

/obj/structure/decor/container/watatsumi/mid
	icon_state = "watatsumi_m"

/obj/structure/decor/container/watatsumi/rightmid
	icon_state = "watatsumi_rm"

/obj/structure/decor/container/watatsumi/right
	icon_state = "watatsumi_r"

/obj/structure/decor/container/grant
	name = "Grant Corporation"
	desc = "Огромный промышленный грузовой контейнер.\nОн принадлежит корпорации \"Grant\" — производителю компонентов для медицинской и биотехнологической отраслей.\nВы припоминаете, что слышали об одном из их новейших препаратов и о том, насколько он был опасен, — хотя в компании утверждали, что уже близки к решению проблемы."

/obj/structure/decor/container/grant/left
	icon_state = "grant_l"

/obj/structure/decor/container/grant/leftmid
	icon_state = "grant_lm"

/obj/structure/decor/container/grant/rightmid
	icon_state = "grant_rm"

/obj/structure/decor/container/grant/right
	icon_state = "grant_r"

/obj/structure/decor/container/arious
	name = "Arious"
	desc = "Огромный промышленный грузовой контейнер.\nОн принадлежит компании \"Arious\" — производителя компьютерных комплектующих и датчиков движения.\nВы всё ещё гадаете, откуда у нас контейнер со старыми датчиками движения и работают ли они вообще."

/obj/structure/decor/container/arious/left
	icon_state = "arious_l"

/obj/structure/decor/container/arious/leftmid
	icon_state = "arious_lm"

/obj/structure/decor/container/arious/mid
	icon_state = "arious_m"

/obj/structure/decor/container/arious/rightmid
	icon_state = "arious_rm"

/obj/structure/decor/container/arious/right
	icon_state = "arious_r"

/obj/structure/decor/container/wy
	name = "Weyland-Yutani"
	desc = "Огромный промышленный грузовой контейнер.\nОн принадлежит корпорации \"Weyland-Yutani\"\ — вы наверняка о ней слышали."

/obj/structure/decor/container/wy/left
	icon_state = "wy_l"

/obj/structure/decor/container/wy/mid
	icon_state = "wy_m"

/obj/structure/decor/container/wy/right
	icon_state = "wy_r"

/obj/structure/decor/container/wy2
	name = "Weyland-Yutani"
	desc = "Огромный промышленный грузовой контейнер.\nОн принадлежит корпорации \"Weyland-Yutani\"\ — вы наверняка о ней слышали."

/obj/structure/decor/container/wy2/left
	icon_state = "wy2_l"

/obj/structure/decor/container/wy2/mid
	icon_state = "wy2_m"

/obj/structure/decor/container/wy2/right
	icon_state = "wy2_r"

/obj/structure/decor/container/armat
	name = "Armat"
	desc = "Крупный промышленный контейнер. Этот экземпляр — от компании \"Armat\", оборонного подрядчика, разработавшего вооружение для пехоты."

/obj/structure/decor/container/armat/left
	icon_state = "armat_l"

/obj/structure/decor/container/armat/mid
	icon_state = "armat_m"

/obj/structure/decor/container/armat/right
	icon_state = "armat_r"

/obj/structure/decor/container/hd
	name = "Hyperdyne Systems"
	desc = "Огромный промышленный транспортный контейнер.\nЭтот — производства \"Hyperdyne Systems\", компании, выпускающей синтетиков, протезы и оружие."

/obj/structure/decor/container/hd/left
	icon_state = "hd_l"

/obj/structure/decor/container/hd/left/alt
	icon_state = "hd_l_alt"

/obj/structure/decor/container/hd/mid
	icon_state = "hd_m"

/obj/structure/decor/container/hd/mid/alt
	icon_state = "hd_m_alt"

/obj/structure/decor/container/hd/right
	icon_state = "hd_r"

/obj/structure/decor/container/hd/right/alt
	icon_state = "hd_r_alt"

/obj/structure/decor/container/trijent
	name = "Trijent Corporation"
	desc = "Огромный промышленный грузовой контейнер.\nЭтот — с объектов добычи корпорации \"Trijent\".\nЕсли он вскроется, лучше не вдыхать то, что находится внутри."

/obj/structure/decor/container/trijent/left
	icon_state = "trijent_l"

/obj/structure/decor/container/trijent/left/alt
	icon_state = "trijent_l_alt"

/obj/structure/decor/container/trijent/mid
	icon_state = "trijent_m"

/obj/structure/decor/container/trijent/mid/alt
	icon_state = "trijent_m_alt"

/obj/structure/decor/container/trijent/right
	icon_state = "trijent_r"

/obj/structure/decor/container/trijent/right/alt
	icon_state = "trijent_r_alt"

/obj/structure/decor/container/kelland
	name = "Kelland Mining Company"
	desc = "Небольшой промышленный грузовой контейнер. Вам мало что известно о компании \"Kelland Mining\" — разве что об инциденте на добывающем объекте LV-178."
	bound_height = 32
	layer = WALL_OBJ_LAYER

/obj/structure/decor/container/kelland/left
	icon_state = "kelland_l"

/obj/structure/decor/container/kelland/right
	icon_state = "kelland_r"

/obj/structure/decor/container/ferret
	name = "Ferret Heavy Industries"
	desc = "Огромный промышленный грузовой контейнер.\nЭтот экземпляр — от компании \"Ferret Heavy Industries\", производителя наземных гусеничных машин и силовых погрузчиков.\nК сожалению, компания обанкротилась. К счастью, теперь такие контейнеры стоят очень дешево."

/obj/structure/decor/container/ferret/left
	icon_state = "ferret_l"

/obj/structure/decor/container/ferret/mid
	icon_state = "ferret_m"

/obj/structure/decor/container/ferret/right
	icon_state = "ferret_r"

/obj/structure/decor/container/lockmart
	name = "Lockmart Corporation"
	desc = "Огромный промышленный транспортный контейнер.\nЭтот — от компании \"Lockheed Martin\", производителя космических кораблей и комплектующих для них."

/obj/structure/decor/container/lockmart/left
	icon_state = "lockmart_l"

/obj/structure/decor/container/lockmart/mid
	icon_state = "lockmart_m"

/obj/structure/decor/container/lockmart/right
	icon_state = "lockmart_r"

/obj/structure/decor/container/seegson
	name = "Seegson Corporation"
	desc = "Огромный промышленный грузовой контейнер.\nОн произведен компанией \"Seegson\" — они выпускают практически всё что угодно."

/obj/structure/decor/container/seegson/left
	icon_state = "seegson_l"

/obj/structure/decor/container/seegson/mid
	icon_state = "seegson_m"

/obj/structure/decor/container/seegson/right
	icon_state = "seegson_r"

/obj/structure/decor/container/canc
	name = "CANC"
	desc = "Огромный промышленный грузовой контейнер. \nЭтот экземпляр — родом из \"Кооператива китайских и азиатских наций\""

/obj/structure/decor/container/canc/left
	icon_state = "canc_g_l"

/obj/structure/decor/container/canc/mid
	icon_state = "canc_g_m"

/obj/structure/decor/container/canc/right
	icon_state = "canc_g_r"

/obj/structure/decor/container/canc/tan/left
	icon_state = "canc_t_l"

/obj/structure/decor/container/canc/tan/mid
	icon_state = "canc_t_m"

/obj/structure/decor/container/canc/tan/right
	icon_state = "canc_t_r"

/obj/structure/decor/container/upp
	name = "UPP"
	desc = "Огромный промышленный грузовой контейнер.\nЭтот — из Союза прогрессивных народов, о чём свидетельствует массивный символ на борту."

/obj/structure/decor/container/upp/left
	icon_state = "upp_l"

/obj/structure/decor/container/upp/mid
	icon_state = "upp_m"

/obj/structure/decor/container/upp/right
	icon_state = "upp_r"

/obj/structure/decor/container/upp/tan/left
	icon_state = "upp_t_l"

/obj/structure/decor/container/upp/tan/mid
	icon_state = "upp_t_m"

/obj/structure/decor/container/upp/tan/right
	icon_state = "upp_t_r"

/obj/structure/decor/container/upp/mk6
	name = "Ministry of Space Security"
	desc = "Огромный промышленный грузовой контейнер.\nЭтот принадлежит Министерству космической безопасности UPP."

/obj/structure/decor/container/upp/mk6/left
	icon_state = "mk6_l"

/obj/structure/decor/container/upp/mk6/mid
	icon_state = "mk6_m"

/obj/structure/decor/container/upp/mk6/right
	icon_state = "mk6_r"

/obj/structure/decor/container/uscm
	name = "United States Colonial Marines"
	desc = "Огромный промышленный грузовой контейнер.\nЭтот принадлежит Корпусу морской пехоты."

/obj/structure/decor/container/uscm/sanfran/left
	icon_state = "uscm1_l"

/obj/structure/decor/container/uscm/sanfran/mid
	icon_state = "uscm1_m"

/obj/structure/decor/container/uscm/borodino/left
	icon_state = "uscm2_l"

/obj/structure/decor/container/uscm/borodino/mid
	icon_state = "uscm2_m"

/obj/structure/decor/container/uscm/tartarus/left
	icon_state = "uscm3_l"

/obj/structure/decor/container/uscm/tartarus/mid
	icon_state = "uscm3_m"

/obj/structure/decor/container/uscm/chinook/left
	icon_state = "uscm4_l"

/obj/structure/decor/container/uscm/chinook/mid
	icon_state = "uscm4_m"

/obj/structure/decor/container/uscm/crestus/left
	icon_state = "uscm5_l"

/obj/structure/decor/container/uscm/crestus/mid
	icon_state = "uscm5_m"

/obj/structure/decor/container/uscm/micor/left
	icon_state = "uscm6_l"

/obj/structure/decor/container/uscm/mid
	icon_state = "uscm_m"

/obj/structure/decor/container/uscm/right
	icon_state = "uscm_r"

/obj/structure/decor/container/upp_small
	name = "UPP"
	desc = "Небольшой промышленный грузовой контейнер.\nЭтот экземпляр принадлежит Союзу прогрессивных народов, о чём свидетельствует символ красной звезды на боковой стенке"
	bound_height = 32
	layer = WALL_OBJ_LAYER

/obj/structure/decor/container/upp_small/container_1/left
	icon_state = "upp_1_l"

/obj/structure/decor/container/upp_small/container_1/right
	icon_state = "upp_1_r"

/obj/structure/decor/container/upp_small/container_2/left
	icon_state = "upp_2_l"

/obj/structure/decor/container/upp_small/container_2/right
	icon_state = "upp_2_r"

/obj/structure/decor/container/upp_small/container_3/left
	icon_state = "upp_3_l"

/obj/structure/decor/container/upp_small/container_3/right
	icon_state = "upp_3_r"

/obj/structure/decor/container/upp_small/container_4/left
	icon_state = "upp_4_l"

/obj/structure/decor/container/upp_small/container_4/right
	icon_state = "upp_4_r"

/obj/structure/decor/container/upp_small/container_5/left
	icon_state = "upp_5_l"

/obj/structure/decor/container/upp_small/container_5/right
	icon_state = "upp_5_r"

/obj/structure/decor/container/upp_small/container_6/left
	icon_state = "upp_6_l"

/obj/structure/decor/container/upp_small/container_6/right
	icon_state = "upp_6_r"

/obj/structure/decor/container/upp_small/container_7/left
	icon_state = "upp_7_l"

/obj/structure/decor/container/upp_small/container_7/right
	icon_state = "upp_7_r"

/obj/structure/decor/container/upp_small/container_8/left
	icon_state = "upp_8_l"

/obj/structure/decor/container/upp_small/container_8/right
	icon_state = "upp_8_r"

/obj/structure/decor/container/upp_small/container_9/left
	icon_state = "upp_9_l"

/obj/structure/decor/container/upp_small/container_9/right
	icon_state = "upp_9_r"

/obj/structure/decor/container/upp_small/container_10/left
	icon_state = "upp_10_l"

/obj/structure/decor/container/upp_small/container_10/right
	icon_state = "upp_10_r"

/obj/structure/decor/container/upp_small/container_11/left
	icon_state = "upp_11_l"

/obj/structure/decor/container/upp_small/container_11/right
	icon_state = "upp_11_r"

/obj/structure/decor/container/upp_small/container_12/left
	icon_state = "upp_12_l"

/obj/structure/decor/container/upp_small/container_12/right
	icon_state = "upp_12_r"

/obj/structure/decor/container/upp_small/container_13/left
	icon_state = "upp_13_l"

/obj/structure/decor/container/upp_small/container_13/right
	icon_state = "upp_13_r"

/obj/structure/decor/container/upp_small/container_14/left
	icon_state = "upp_14_l"

/obj/structure/decor/container/upp_small/container_14/right
	icon_state = "upp_14_r"

/obj/structure/decor/container/upp_small/container_15/left
	icon_state = "upp_15_l"

/obj/structure/decor/container/upp_small/container_15/right
	icon_state = "upp_15_r"

/obj/structure/decor/container/upp_small/container_16/left
	icon_state = "upp_16_l"

/obj/structure/decor/container/upp_small/container_16/right
	icon_state = "upp_16_r"

/obj/structure/decor/container/upp_small/container_17/left
	icon_state = "upp_17_l"

/obj/structure/decor/container/upp_small/container_17/right
	icon_state = "upp_17_r"

/obj/structure/decor/container/upp_small/container_18/left
	icon_state = "upp_18_l"

/obj/structure/decor/container/upp_small/container_18/right
	icon_state = "upp_18_r"

/obj/structure/decor/container/upp_small/container_19/left
	icon_state = "upp_19_l"

/obj/structure/decor/container/upp_small/container_19/right
	icon_state = "upp_19_r"

/obj/structure/decor/container/upp_small/container_20/left
	icon_state = "upp_20_l"

/obj/structure/decor/container/upp_small/container_20/right
	icon_state = "upp_20_r"

/// MARK: Horizontal
/obj/structure/decor/container/horizontal
	desc = "A huge industrial shipping container."
	icon = 'icons/obj/structures/containHorizont.dmi'
	bound_width = 64

/obj/structure/decor/container/horizontal/blue
	name = "Generic"
	desc = "Огромный промышленный грузовой контейнер.\nНесмотря на то, что логотип отчетливо виден на боковой стороне, разглядеть его невозможно, так как он не обращен на юг."
	bound_height = 32
	bound_width = 32

/obj/structure/decor/container/horizontal/blue/top
	icon_state = "blue_t"

/obj/structure/decor/container/horizontal/blue/middle
	icon_state = "blue_m"

/obj/structure/decor/container/horizontal/blue/bottom
	icon_state = "blue_b"

/// MARK: Extended
/obj/structure/decor/container/cargo_container/containersextended
	desc = "A cargo container."
	icon = 'icons/obj/structures/containersextended.dmi'
	icon_state = "blackwyleft"
	layer = ABOVE_MOB_LAYER

/obj/structure/decor/container/cargo_container/containersextended/blueleft
	icon_state = "blueleft"

/obj/structure/decor/container/cargo_container/containersextended/blueright
	icon_state = "blueright"

/obj/structure/decor/container/cargo_container/containersextended/greenleft
	icon_state = "greenleft"

/obj/structure/decor/container/cargo_container/containersextended/greenright
	icon_state = "greenright"

/obj/structure/decor/container/cargo_container/containersextended/tanleft
	icon_state = "tanleft"

/obj/structure/decor/container/cargo_container/containersextended/tanright
	icon_state = "tanright"

/obj/structure/decor/container/cargo_container/containersextended/redleft
	icon_state = "redleft"

/obj/structure/decor/container/cargo_container/containersextended/redright
	icon_state = "redright"

/obj/structure/decor/container/cargo_container/containersextended/greywyleft
	name = "Weyland-Yutani"
	icon_state = "greywyleft"

/obj/structure/decor/container/cargo_container/containersextended/greywyright
	name = "Weyland-Yutani"
	icon_state = "greywyright"

/obj/structure/decor/container/cargo_container/containersextended/lightgreywyleft
	name = "Weyland-Yutani"
	icon_state = "lightgreywyleft"

/obj/structure/decor/container/cargo_container/containersextended/lightgreywyright
	name = "Weyland-Yutani"
	icon_state = "lightgreywyright"

/obj/structure/decor/container/cargo_container/containersextended/blackwyleft
	name = "Weyland-Yutani"

/obj/structure/decor/container/cargo_container/containersextended/blackwyright
	name = "Weyland-Yutani"
	icon_state = "blackwyright"

/obj/structure/decor/container/cargo_container/containersextended/whitewyleft
	name = "Weyland-Yutani"
	icon_state = "whitewyleft"

/obj/structure/decor/container/cargo_container/containersextended/whitewyright
	name = "Weyland-Yutani"
	icon_state = "whitewyright"

/obj/structure/decor/container/cargo_container/containersextended/tanwywingsleft
	icon_state = "tanwywingsleft"

/obj/structure/decor/container/cargo_container/containersextended/tanwywingsright
	icon_state = "tanwywingsright"

/obj/structure/decor/container/cargo_container/containersextended/greenwywingsleft
	icon_state = "greenwywingsleft"

/obj/structure/decor/container/cargo_container/containersextended/greenwywingsright
	icon_state = "greenwywingsright"

/obj/structure/decor/container/cargo_container/containersextended/bluewywingsleft
	icon_state = "bluewywingsleft"

/obj/structure/decor/container/cargo_container/containersextended/bluewywingsright
	icon_state = "bluewywingsright"

/obj/structure/decor/container/cargo_container/containersextended/redwywingsleft
	icon_state = "redwywingsleft"

/obj/structure/decor/container/cargo_container/containersextended/redwywingsright
	icon_state = "redwywingsright"

/obj/structure/decor/container/cargo_container/containersextended/medicalleft
	name = "medical"
	icon_state = "medicalleft"

/obj/structure/decor/container/cargo_container/containersextended/medicalright
	name = "medical"
	icon_state = "medicalright"

/obj/structure/decor/container/cargo_container/containersextended/emptymedicalleft
	name = "medical"
	icon_state = "emptymedicalleft"

/obj/structure/decor/container/cargo_container/containersextended/emptymedicalright
	name = "medical"
	icon_state = "emptymedicalright"

/obj/structure/decor/container/cargo_container/containersextended/kelland_left
	name = "Kelland Mining Company"
	desc = "Небольшой промышленный грузовой контейнер. Вам мало что известно о компании \"Kelland Mining\" — разве что об инциденте на добывающем объекте LV-178."
	icon_state = "kelland_alt_l"

/obj/structure/decor/container/cargo_container/containersextended/kelland_right
	name = "Kelland Mining Company"
	desc = "Небольшой промышленный грузовой контейнер. Вам мало что известно о компании \"Kelland Mining\" — разве что об инциденте на добывающем объекте LV-178."
	icon_state = "kelland_alt_r"
