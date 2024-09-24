/obj/item/terraformer_adder
	name = "terraformer adder"
	desc = "Дает вам фракцию терраформеров"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "capacitor"

/obj/item/terraformer_adder/attack_self(mob/user)
	. = ..()
	user.faction += "terraformers"
