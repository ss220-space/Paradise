/datum/reagent/consumable/drink/cold
	name = "Прохладительный напиток"
	adj_temp_cool = 5

/datum/reagent/consumable/drink/cold/tonic
	name = "Вода с тоником" // Tonic Water
	id = "tonic"
	description = "У неё странный вкус. Но, хинин хотя бы сдерживает космическую малярию."
	color = "#664300" // rgb: 102, 67, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	drink_icon = "glass_clear"
	drink_name = "Стакан воды с тоником"
	drink_desc = "У хинина странный вкус. Но он хотя бы защищает от космической малярии."
	taste_description = "горечи"

/datum/reagent/consumable/drink/cold/sodawater
	name = "Газировка" // Soda Water
	id = "sodawater"
	description = "Банка клубной газировки. Почему бы не сделать скотч c содовой?"
	color = "#619494" // rgb: 97, 148, 148
	adj_dizzy = -5
	adj_drowsy = -3
	drink_icon = "glass_clear"
	drink_name = "Стакан газировки"
	drink_desc = "Газировка. Почему бы не сделать скотч c содовой?"
	taste_description = "газировки"

/datum/reagent/consumable/drink/cold/ice
	name = "Лёд" // Ice
	id = "ice"
	description = "Замёрзшая вода. Ваш дантист не хотел бы, чтобы вы её грызли."
	reagent_state = SOLID
	color = "#619494" // rgb: 97, 148, 148
	adj_temp_cool = 0
	drink_icon = "iceglass"
	drink_name = "Стакан льда"
	drink_desc = "Обычно, вам стоит добавить сюда что-то ещё…"
	taste_description = "холода"

/datum/reagent/consumable/drink/cold/ice/on_mob_life(mob/living/M)
	M.bodytemperature = max(M.bodytemperature - 5 * TEMPERATURE_DAMAGE_COEFFICIENT, 0)
	return ..()

/datum/reagent/consumable/drink/cold/space_cola
	name = "Кола" // Cola
	id = "cola"
	description = "Освежающий напиток."
	reagent_state = LIQUID
	color = "#100800" // rgb: 16, 8, 0
	adj_drowsy = -5
	drink_icon = "glass_brown"
	drink_name = "Стакан космической колы"
	drink_desc = "Стакан освежающей космической колы"
	taste_description = "колы"

/datum/reagent/consumable/drink/cold/nuka_cola
	name = "Нюка-Кола" // Nuka Cola
	id = "nuka_cola"
	description = "Кола… Кола никогда не меняется."
	color = "#100800" // rgb: 16, 8, 0
	adj_sleepy = -2
	drink_icon = "nuka_colaglass"
	drink_name = "Нюка-Кола"
	drink_desc = "Не плачь, не поднимай глаз. Это лишь ядерная пустошь."
	harmless = FALSE
	taste_description = "радиоактивной колы"

/datum/reagent/consumable/drink/cold/nuka_cola/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Jitter(20)
	update_flags |= M.Druggy(30, FALSE)
	M.AdjustDizzy(5)
	M.SetDrowsy(0)
	M.status_flags |= GOTTAGONOTSOFAST
	return ..() | update_flags

/datum/reagent/consumable/drink/cold/nuka_cola/on_mob_delete(mob/living/M)
	M.status_flags &= ~GOTTAGONOTSOFAST
	..()

// Отсылка на «Mountain Dew», но хз как её обыграть
/datum/reagent/consumable/drink/cold/spacemountainwind
	name = "Космический горный ветер" // Space Mountain Wind
	id = "spacemountainwind"
	description = "Дует прямо насквозь вас, как и любой космический ветер."
	color = "#102000" // rgb: 16, 32, 0
	adj_drowsy = -7
	adj_sleepy = -1
	drink_icon = "Space_mountain_wind_glass"
	drink_name = "Стакан космического горного ветра"
	drink_desc = "Космический горный ветер. Как вы знаете, в космосе нет гор. А вот ветер есть."
	taste_description = "лаймовой газировки"

/datum/reagent/consumable/drink/cold/dr_gibb
	name = "Д-р Гибб" // Dr. Gibb
	id = "dr_gibb"
	description = "Восхитительная смесь 42 различных вкусов."
	color = "#102000" // rgb: 16, 32, 0
	adj_drowsy = -6
	drink_icon = "dr_gibb_glass"
	drink_name = "Стакан д-ра Гибба"
	drink_desc = "Д-р Гибб. Не так опасен, как может показаться из названия."
	taste_description = "вишнёвой газировки"

/datum/reagent/consumable/drink/cold/space_up
	name = "Космирование" // Space-Up
	id = "space_up"
	description = "С лёгким вкусом разгермы."
	color = "#202800" // rgb: 32, 40, 0
	adj_temp_cool = 8
	drink_icon = "space-up_glass"
	drink_name = "Стакан космирования"
	drink_desc = "Космирование. Помогает сохранять хладнокровие."
	taste_description = "лимонной газировки"

/datum/reagent/consumable/drink/cold/lemon_lime
	name = "Лимон-лайм" // Lemon Lime
	description = "Едкая субстанция, состоящая из 0,5% натуральных цитрусовых!"
	id = "lemon_lime"
	color = "#878F00" // rgb: 135, 40, 0
	adj_temp_cool = 8
	taste_description = "цитрусовой газировки"

/datum/reagent/consumable/drink/cold/lemonade
	name = "Лимонад" // Lemonade
	description = "О, ностальгия…"
	id = "lemonade"
	color = "#FFFF00" // rgb: 255, 255, 0
	drink_icon = "lemonade"
	drink_name = "Лимонад"
	drink_desc = "О, ностальгия…"
	taste_description = "лимонада"

/datum/reagent/consumable/drink/cold/kiraspecial
	name = "Особый коктейль Киры" // Kira Special
	description = "Долгих лет тому парню, которого все путали с девушкой. Бака!"
	id = "kiraspecial"
	color = "#CCCC99" // rgb: 204, 204, 153
	drink_icon = "kiraspecial"
	drink_name = "Особый коктейль Киры"
	drink_desc = "Долгих лет тому парню, которого все путали с девушкой. Бака!"
	taste_description = "цитрусовой газировки"

/datum/reagent/consumable/drink/cold/brownstar
	name = "Бурая звезда" // Brown Star
	description = "Это совсем не то, как это звучит…"
	id = "brownstar"
	color = "#9F3400" // rgb: 159, 052, 000
	adj_temp_cool = 2
	drink_icon = "brownstar"
	drink_name = "Бурая звезда"
	drink_desc = "Это совсем не то, как это звучит…"
	taste_description = "апельсиновой газировки"

/datum/reagent/consumable/drink/cold/milkshake
	name = "Молочный коктейль" // Milkshake
	description = "Великолепная смесь, леденящая мозги."
	id = "milkshake"
	color = "#AEE5E4" // rgb" 174, 229, 228
	adj_temp_cool = 9
	drink_icon = "milkshake"
	drink_name = "Молочный коктейль"
	drink_desc = "Великолепная смесь, леденящая мозги."
	taste_description = "молочного коктейль"

/datum/reagent/consumable/drink/cold/rewriter
	name = "Рерайтер" // Rewriter
	description = "Тайна святилища Библиотекаря…"
	id = "rewriter"
	color = "#485000" // rgb:72, 080, 0
	drink_icon = "rewriter"
	drink_name = "Рерайтер"
	drink_desc = "Тайна святилища Библиотекаря…"
	taste_description = "кофе… с газировкой?"

/datum/reagent/consumable/drink/cold/rewriter/on_mob_life(mob/living/M)
	M.Jitter(5)
	return ..()
