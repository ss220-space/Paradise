
/datum/chemical_reaction/hot_coco
	name = "Горячий шоколад"
	id = "hot_coco"
	result = "hot_coco"
	required_reagents = list("water" = 5, "cocoa" = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/chocolate_milk
	name = "Шоколадное молоко"
	id = "chocolate_milk"
	result = "chocolate_milk"
	required_reagents = list("chocolate" = 1, "milk" = 1)
	result_amount = 2
	mix_message = "Смесь приобретает приятный коричневый цвет."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/coffee
	name = "Кофе"
	id = "coffee"
	result = "coffee"
	required_reagents = list("coffeepowder" = 1, "water" = 5)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/tea
	name = "Чай"
	id = "tea"
	result = "tea"
	required_reagents = list("teapowder" = 1, "water" = 5)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/goldschlager
	name = "Гольдшлагер"
	id = "goldschlager"
	result = "goldschlager"
	required_reagents = list("vodka" = 10, "gold" = 1)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/patron
	name = "Патрон"
	id = "patron"
	result = "patron"
	required_reagents = list("tequila" = 10, "silver" = 1)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/bilk
	name = "Пивлоко"
	id = "bilk"
	result = "bilk"
	required_reagents = list("milk" = 1, "beer" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/icetea
	name = "Чай со льдом"
	id = "icetea"
	result = "icetea"
	required_reagents = list("ice" = 1, "tea" = 3)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/icecoffee
	name = "Кофе со льдом"
	id = "icecoffee"
	result = "icecoffee"
	required_reagents = list("ice" = 1, "coffee" = 3)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/nuka_cola
	name = "Нюка-Кола"
	id = "nuka_cola"
	result = "nuka_cola"
	required_reagents = list("uranium" = 1, "cola" = 6)
	result_amount = 6
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/moonshine
	name = "Сивуха"
	id = "moonshine"
	result = "moonshine"
	required_reagents = list("nutriment" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/wine
	name = "Вино"
	id = "wine"
	result = "wine"
	required_reagents = list("grapejuice" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/spacebeer
	name = "Космическое пиво" // Space Beer
	id = "spacebeer"
	result = "beer"
	required_reagents = list("cornoil" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/vodka
	name = "Водка" // Vodka
	id = "vodka"
	result = "vodka"
	required_reagents = list("potato" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/sake
	name = "Саке" // Sake
	id = "sake"
	result = "sake"
	required_reagents = list("rice" = 10,"water" = 5)
	required_catalysts = list("enzyme" = 5)
	result_amount = 15
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/kahlua
	name = "Калуа"
	id = "kahlua"
	result = "kahlua"
	required_reagents = list("coffee" = 5, "sugar" = 5, "rum" = 5)
	required_catalysts = list("enzyme" = 5)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/kahluaVodka
	name = "Калуа с водкой" // KahluaVodka
	id = "kahlauVodka"
	result = "kahlua"
	required_reagents = list("coffee" = 5, "sugar" = 5, "vodka" = 5)
	required_catalysts = list("enzyme" = 5)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/gin_tonic
	name = "Джин-тоник"
	id = "gintonic"
	result = "gintonic"
	required_reagents = list("gin" = 2, "tonic" = 1)
	result_amount = 3
	mix_message = "Тоник и джин прекрасно сочетаются друг с другом.."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/cuba_libre
	name = "Свободная Куба"
	id = "cubalibre"
	result = "cubalibre"
	required_reagents = list("rum" = 2, "cola" = 2, "limejuice" = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/mojito
	name = "Мохито"
	id = "mojito"
	result = "mojito"
	required_reagents = list("rum" = 1, "sugar" = 1, "limejuice" = 1, "sodawater" = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/martini
	name = "Классический мартини"
	id = "martini"
	result = "martini"
	required_reagents = list("gin" = 2, "vermouth" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/vodkamartini
	name = "Мартини с водкой"
	id = "vodkamartini"
	result = "vodkamartini"
	required_reagents = list("vodka" = 2, "vermouth" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/white_russian
	name = "Белый русский"
	id = "whiterussian"
	result = "whiterussian"
	required_reagents = list("blackrussian" = 3, "cream" = 2)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/whiskey_cola
	name = "Виски с колой"
	id = "whiskeycola"
	result = "whiskeycola"
	required_reagents = list("whiskey" = 2, "cola" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/screwdriver
	name = "Отвёртка"
	id = "screwdrivercocktail"
	result = "screwdrivercocktail"
	required_reagents = list("vodka" = 2, "orangejuice" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/bloody_mary
	name = "Кровавая Мэри"
	id = "bloodymary"
	result = "bloodymary"
	required_reagents = list("vodka" = 1, "tomatojuice" = 2, "limejuice" = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/gargle_blaster
	name = "Пангалактический грызлодёр"
	id = "gargleblaster"
	result = "gargleblaster"
	required_reagents = list("vodka" = 1, "gin" = 1, "whiskey" = 1, "cognac" = 1, "limejuice" = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/flaming_homer
	name = "Горючий Мо"
	id = "flamingmoe"
	result = "flamingmoe"
	required_reagents = list("vodka" = 1, "gin" = 1, "cognac" = 1, "tequila" = 1, "salglu_solution" = 1) //Close enough
	min_temp = T0C + 100 //Fire makes it good!
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'
	mix_message = "Смесь взрывается пламенем!"

/datum/chemical_reaction/brave_bull
	name = "Храбрый бык"
	id = "bravebull"
	result = "bravebull"
	required_reagents = list("tequila" = 2, "kahlua" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/tequila_sunrise
	name = "Текилла «Восход»"
	id = "tequilasunrise"
	result = "tequilasunrise"
	required_reagents = list("tequila" = 2, "orangejuice" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/toxins_special
	name = "Особые токсины"
	id = "toxinsspecial"
	result = "toxinsspecial"
	required_reagents = list("rum" = 2, "vermouth" = 1, "plasma" = 2)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/beepsky_smash
	name = "Удар Бипски" // Beepksy Smash
	id = "beepksysmash"
	result = "beepskysmash"
	required_reagents = list("limejuice" = 2, "whiskey" = 2, "iron" = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/doctor_delight
	name = "Восторг врача" // The Doctor's Delight
	id = "doctordelight"
	result = "doctorsdelight"
	required_reagents = list("limejuice" = 1, "tomatojuice" = 1, "orangejuice" = 1, "cream" = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/irish_cream
	name = "Ирландские сливки" // Irish Cream
	id = "irishcream"
	result = "irishcream"
	required_reagents = list("whiskey" = 2, "cream" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/manly_dorf
	name = "Бравый карлик"
	id = "manlydorf"
	result = "manlydorf"
	required_reagents = list ("beer" = 1, "ale" = 2)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/suicider
	name = "Суицидник"
	id = "suicider"
	result = "suicider"
	required_reagents = list ("vodka" = 1, "cider" = 1, "fuel" = 1, "epinephrine" = 1)
	result_amount = 4
	mix_message = "Напитки и химикаты перемешиваются, издавая сильный запах."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/irish_coffee
	name = "Ирландский кофе"
	id = "irishcoffee"
	result = "irishcoffee"
	required_reagents = list("irishcream" = 1, "coffee" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/b52
	name = "Б-52" // B-52
	id = "b52"
	result = "b52"
	required_reagents = list("irishcream" = 1, "kahlua" = 1, "cognac" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/atomicbomb
	name = "Атомная бомба"
	id = "atomicbomb"
	result = "atomicbomb"
	required_reagents = list("b52" = 10, "uranium" = 1)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/margarita
	name = "Маргарита"
	id = "margarita"
	result = "margarita"
	required_reagents = list("tequila" = 2, "limejuice" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/longislandicedtea
	name = "Лонг Айленд Айс Ти"
	id = "longislandicedtea"
	result = "longislandicedtea"
	required_reagents = list("vodka" = 1, "gin" = 1, "tequila" = 1, "cubalibre" = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/threemileisland
	name = "Three Mile Island Iced Tea" // Three Mile Island Iced Tea
	id = "threemileisland"
	result = "threemileisland"
	required_reagents = list("longislandicedtea" = 10, "uranium" = 1)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/whiskeysoda
	name = "Виски с содовой" // Whiskey Soda
	id = "whiskeysoda"
	result = "whiskeysoda"
	required_reagents = list("whiskey" = 2, "sodawater" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/black_russian
	name = "Чёрный русский" // Black Russian
	id = "blackrussian"
	result = "blackrussian"
	required_reagents = list("vodka" = 3, "kahlua" = 2)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/manhattan
	name = "Манхэттен" // Manhattan
	id = "manhattan"
	result = "manhattan"
	required_reagents = list("whiskey" = 2, "vermouth" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/manhattan_proj
	name = "Манхэттенский проект" // Manhattan Project
	id = "manhattan_proj"
	result = "manhattan_proj"
	required_reagents = list("manhattan" = 10, "uranium" = 1)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/vodka_tonic
	name = "Водка с тоником" // Vodka and Tonic
	id = "vodkatonic"
	result = "vodkatonic"
	required_reagents = list("vodka" = 2, "tonic" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/gin_fizz
	name = "Джин Физз" // Gin Fizz
	id = "ginfizz"
	result = "ginfizz"
	required_reagents = list("gin" = 2, "sodawater" = 1, "limejuice" = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/bahama_mama
	name = "Багама мама" // Bahama mama
	id = "bahama_mama"
	result = "bahama_mama"
	required_reagents = list("rum" = 2, "orangejuice" = 2, "limejuice" = 1, "ice" = 1)
	result_amount = 6
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/singulo
	name = "Сингуло" // Singulo
	id = "singulo"
	result = "singulo"
	required_reagents = list("vodka" = 5, "radium" = 1, "wine" = 5)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/alliescocktail
	name = "Коктейль «Союзнический»" // Allies Сocktail
	id = "alliescocktail"
	result = "alliescocktail"
	required_reagents = list("martini" = 1, "vodka" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/demonsblood
	name = "Кровь демона" // Demons Blood
	id = "demonsblood"
	result = "demonsblood"
	required_reagents = list("rum" = 1, "spacemountainwind" = 1, "blood" = 1, "dr_gibb" = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/booger
	name = "Козявка" // Booger
	id = "booger"
	result = "booger"
	required_reagents = list("cream" = 1, "banana" = 1, "rum" = 1, "watermelonjuice" = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/antifreeze
	name = "Антифриз" // Anti-freeze
	id = "antifreeze"
	result = "antifreeze"
	required_reagents = list("vodka" = 2, "cream" = 1, "ice" = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/barefoot
	name = "Босоногий" // Barefoot
	id = "barefoot"
	result = "barefoot"
	required_reagents = list("berryjuice" = 1, "cream" = 1, "vermouth" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'


////DRINKS THAT REQUIRED IMPROVED SPRITES BELOW:: -Agouri/////

/datum/chemical_reaction/sbiten
	name = "Сбитень" // Sbiten
	id = "sbiten"
	result = "sbiten"
	required_reagents = list("vodka" = 10, "capsaicin" = 1)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/red_mead
	name = "Красный мёд" // Red Mead
	id = "red_mead"
	result = "red_mead"
	required_reagents = list("blood" = 1, "mead" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/mead
	name = "Мёд" // Mead
	id = "mead"
	result = "mead"
	required_reagents = list("sugar" = 1, "water" = 1)
	required_catalysts = list("enzyme" = 5)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/iced_beer
	name = "Ледяное пиво" // Iced Beer
	id = "iced_beer"
	result = "iced_beer"
	required_reagents = list("beer" = 10, "frostoil" = 1)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/iced_beer2
	name = "Ледяное пиво" // Iced Beer
	id = "iced_beer"
	result = "iced_beer"
	required_reagents = list("beer" = 5, "ice" = 1)
	result_amount = 6
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/grog
	name = "Грог" // Grog
	id = "grog"
	result = "grog"
	required_reagents = list("rum" = 1, "water" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/soy_latte
	name = "Соевый латте" // Soy Latte
	id = "soy_latte"
	result = "soy_latte"
	required_reagents = list("coffee" = 1, "soymilk" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/cafe_latte
	name = "Кофе латте" // Cafe Latte
	id = "cafe_latte"
	result = "cafe_latte"
	required_reagents = list("coffee" = 1, "milk" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/cafe_mocha
	name = "Моккачино" // Cafe Mocha
	id = "cafe_mocha"
	result = "cafe_mocha"
	required_reagents = list("cafe_latte" = 1, "chocolate" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/acidspit
	name = "Кислотный плевок" // Acid Spit
	id = "acidspit"
	result = "acidspit"
	required_reagents = list("sacid" = 1, "wine" = 5)
	result_amount = 6
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/amasec
	name = "Амасек" // Amasec
	id = "amasec"
	result = "amasec"
	required_reagents = list("iron" = 1, "wine" = 5, "vodka" = 5)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/changelingsting
	name = "Жало генокрада" // Changeling Sting
	id = "changelingsting"
	result = "changelingsting"
	required_reagents = list("screwdrivercocktail" = 1, "limejuice" = 1, "lemonjuice" = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/aloe
	name = "Алоэ" // Aloe
	id = "aloe"
	result = "aloe"
	required_reagents = list("cream" = 1, "whiskey" = 1, "watermelonjuice" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/andalusia
	name = "Андалусия" // Andalusia
	id = "andalusia"
	result = "andalusia"
	required_reagents = list("rum" = 1, "whiskey" = 1, "lemonjuice" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/neurotoxin
	name = "Нейротоксин" // Neurotoxin
	id = "neurotoxin"
	result = "neurotoxin"
	required_reagents = list("gargleblaster" = 1, "ether" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/snowwhite
	name = "Белоснежка"
	id = "snowwhite"
	result = "snowwhite"
	required_reagents = list("beer" = 1, "lemon_lime" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/irishcarbomb
	name = "Ирландская автомобильная бомба" // Irish Car Bomb
	id = "irishcarbomb"
	result = "irishcarbomb"
	required_reagents = list("ale" = 1, "irishcream" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/syndicatebomb
	name = "Бомба Синдиката" // Syndicate Bomb
	id = "syndicatebomb"
	result = "syndicatebomb"
	required_reagents = list("beer" = 1, "whiskeycola" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/erikasurprise
	name = "Сюрприз Эрики" // Erika Surprise
	id = "erikasurprise"
	result = "erikasurprise"
	required_reagents = list("ale" = 1, "limejuice" = 1, "whiskey" = 1, "banana" = 1, "ice" = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/devilskiss
	name = "Поцелуй дьявола" // Devils Kiss
	id = "devilskiss"
	result = "devilskiss"
	required_reagents = list("blood" = 1, "kahlua" = 1, "rum" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/hippiesdelight
	name = "Радость хиппи" // Hippies Delight
	id = "hippiesdelight"
	result = "hippiesdelight"
	required_reagents = list("psilocybin" = 1, "gargleblaster" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/bananahonk
	name = "Банановый хонк" // Banana Honk
	id = "bananahonk"
	result = "bananahonk"
	required_reagents = list("banana" = 1, "cream" = 1, "sugar" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/silencer
	name = "Глушитель" // Silencer
	id = "silencer"
	result = "silencer"
	required_reagents = list("nothing" = 1, "cream" = 1, "sugar" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/driestmartini
	name = "Сухой мартини" // Driest Martini
	id = "driestmartini"
	result = "driestmartini"
	required_reagents = list("nothing" = 1, "gin" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/lemonade
	name = "Лимонад" // Lemonade
	id = "lemonade"
	result = "lemonade"
	required_reagents = list("lemonjuice" = 1, "sugar" = 1, "water" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/kiraspecial
	name = "Особый коктейль Киры" // Kira Special
	id = "kiraspecial"
	result = "kiraspecial"
	required_reagents = list("orangejuice" = 1, "limejuice" = 1, "sodawater" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/brownstar
	name = "Бурая звезда" // Brown Star
	id = "brownstar"
	result = "brownstar"
	required_reagents = list("orangejuice" = 2, "cola" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/milkshake
	name = "Молочный коктейль" // Milkshake
	id = "milkshake"
	result = "milkshake"
	required_reagents = list("cream" = 1, "ice" = 2, "milk" = 2)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/rewriter
	name = "Рерайтер" // Rewriter
	id = "rewriter"
	result = "rewriter"
	required_reagents = list("spacemountainwind" = 1, "coffee" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/ginsonic
	name = "Джин-соник" // ginsonic
	id = "ginsonic"
	result = "ginsonic"
	required_reagents = list("gintonic" = 1, "methamphetamine" = 1)
	result_amount = 2
	mix_message = "Напиток становится электрически-синим и начинает сильно дрожать."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/applejack
	name = "Яблочная водка" // applejack
	id = "applejack"
	result = "applejack"
	required_reagents = list("cider" = 2)
	max_temp = T0C
	result_amount = 1
	mix_message = "Напиток темнеет по мере замерзания воды, оставляя после себя концентрированный сидр."
	mix_sound = null

/datum/chemical_reaction/jackrose
	name = "Джек Роуз" // jackrose
	id = "jackrose"
	result = "jackrose"
	required_reagents = list("applejack" = 4, "lemonjuice" = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/synthanol
	name = "Синтанол" // Synthanol
	id = "synthanol"
	result = "synthanol"
	required_reagents = list("lube" = 1, "plasma" = 1, "fuel" = 1)
	result_amount = 3
	mix_message = "Химикаты смешиваются, создавая блестящую синюю субстанцию."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/synthanol/robottears
	name = "Слёзы робота" // Robot Tears
	id = "robottears"
	result = "robottears"
	required_reagents = list("synthanol" = 1, "oil" = 1, "sodawater" = 1)
	result_amount = 3
	mix_message = "Ингредиенты соединяются в густую тёмную жижу."

/datum/chemical_reaction/synthanol/trinary
	name = "Троичность" // Trinary
	id = "trinary"
	result = "trinary"
	required_reagents = list("synthanol" = 1, "limejuice" = 1, "orangejuice" = 1)
	result_amount = 3
	mix_message = "Ингредиенты смешиваются в красочную субстанцию."

/datum/chemical_reaction/synthanol/servo
	name = "Серво" // Servo
	id = "servo"
	result = "servo"
	required_reagents = list("synthanol" = 2, "cream" = 1, "hot_coco" = 1)
	result_amount = 4
	mix_message = "Ингредиенты смешиваются в тёмно-коричневую субстанцию."

/datum/chemical_reaction/synthanol/uplink
	name = "Аплинк" // Uplink
	id = "uplink"
	result = "uplink"
	required_reagents = list("rum" = 1, "vodka" = 1, "tequila" = 1, "whiskey" = 1, "synthanol" = 1)
	result_amount = 5
	mix_message = "Химикаты смешиваются, образуя блестящую оранжевую субстанцию."

/datum/chemical_reaction/synthanol/synthnsoda
	name = "Синт с содовой" // Synth 'n Soda
	id = "synthnsoda"
	result = "synthnsoda"
	required_reagents = list("synthanol" = 1, "cola" = 1)
	result_amount = 2
	mix_message = "Химикаты смешиваются, образуя однородную шипучую субстанцию."

/datum/chemical_reaction/synthanol/synthignon
	name = "Синтиньон" // Synthignon
	id = "synthignon"
	result = "synthignon"
	required_reagents = list("synthanol" = 1, "wine" = 1)
	result_amount = 2
	mix_message = "Химикаты смешиваются, образуя блестящую красную субстанцию."

/datum/chemical_reaction/triple_citrus
	name = "Тройной цитрус" // triple_citrus
	id = "triple_citrus"
	result = "triple_citrus"
	required_reagents = list("lemonjuice" = 1, "limejuice" = 1, "orangejuice" = 1)
	result_amount = 3
	mix_message = "Соки цитрусовых начинают перемешиваться."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/chocolatepudding
	name = "Шоколадный пудинг" // Chocolate Pudding
	id = "chocolatepudding"
	result = "chocolatepudding"
	required_reagents = list("cocoa" = 5, "milk" = 5, "egg" = 5)
	result_amount = 20
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/vanillapudding
	name = "Ванильный пудинг" // Vanilla Pudding
	id = "vanillapudding"
	result = "vanillapudding"
	required_reagents = list("vanilla" = 5, "milk" = 5, "egg" = 5)
	result_amount = 20
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/cherryshake
	name = "Вишнёвый коктейль" // Cherry Shake
	id = "cherryshake"
	result = "cherryshake"
	required_reagents = list("cherryjelly" = 1, "ice" = 1, "cream" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/bluecherryshake
	name = "Коктейль «Синяя вишня»" // Blue Cherry Shake
	id = "bluecherryshake"
	result = "bluecherryshake"
	required_reagents = list("bluecherryjelly" = 1, "ice" = 1, "cream" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/drunkenblumpkin
	name = "Пьяный синяк" // Drunken Blumpkin
	id = "drunkenblumpkin"
	result = "drunkenblumpkin"
	required_reagents = list("blumpkinjuice" = 1, "irishcream" = 2, "ice" = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/pumpkin_latte
	name = "Тыквенный космический латте" // Pumpkin space latte
	id = "pumpkin_latte"
	result = "pumpkin_latte"
	required_reagents = list("pumpkinjuice" = 5, "coffee" = 5, "cream" = 5)
	result_amount = 15
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/gibbfloats
	name = "Д-р Гибб с поплавком" // Gibb Floats
	id = "gibbfloats"
	result = "gibbfloats"
	required_reagents = list("dr_gibb" = 5, "ice" = 5, "cream" = 5)
	result_amount = 15
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/grape_soda
	name = "Виноградный сок с содовой" // grape soda
	id = "grapesoda"
	result = "grapesoda"
	required_reagents = list("grapejuice" = 1, "sodawater" = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/eggnog
	name = "Гоголь-моголь" // eggnog
	id = "eggnog"
	result = "eggnog"
	required_reagents = list("rum" = 5, "cream" = 5, "egg" = 5)
	result_amount = 15
	mix_message = "Яйца немного гоглят, образуя моголь. Как будто это настоящие слова."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/hooch
	name = "Самогон" // Hooch
	id = "hooch"
	result = "hooch"
	required_reagents = list("ethanol" = 2, "fuel" = 1)
	result_amount = 3
	required_catalysts = list("enzyme" = 1)

/datum/chemical_reaction/bacchus_blessing
	name = "Благословение Бахуса" // Bacchus' Blessing
	id = "bacchus_blessing"
	result = "bacchus_blessing"
	required_reagents = list("hooch" = 1, "absinthe" = 1, "manlydorf" = 1, "syndicatebomb" = 1)
	result_amount = 4
	mix_message = "<span class='warning'>Смесь превращается в отвратительную пену.</span>"

/datum/chemical_reaction/icecoco
	name = "Какао со льдом" // sickening
	id = "icecoco"
	result = "icecoco"
	required_reagents = list("ice" = 1, "hot_coco" = 3)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/fernet_cola
	name = "Фернет-кола" // Fernet Cola
	id = "fernet_cola"
	result = "fernet_cola"
	required_reagents = list("fernet" = 1, "cola" = 2)
	result_amount = 3
	mix_message = "Ингредиенты смешиваются в боежественную тёмно-коричневую субстанцию."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'
