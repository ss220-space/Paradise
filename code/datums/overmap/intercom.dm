/datum/overmap_sector_message
	var/id
	var/plaintext = ""
	var/scrambled = ""
	var/encryption_key
	var/sender_name = "Неизвестный"
	var/sector_id
	var/sent_at = 0

/datum/overmap_sector_message/New(body, key, origin_name, from_sector_id)
	id = "omsg_[UID()]"
	plaintext = body
	encryption_key = key
	sender_name = origin_name
	sector_id = from_sector_id
	sent_at = world.time
	if(encryption_key)
		scrambled = overmap_comms_scramble(plaintext)
	else
		scrambled = plaintext

/datum/overmap_comms_cipher
	var/key = ""
	var/label = ""
	var/autodecrypt = FALSE
	var/announce = FALSE

/datum/overmap_comms_cipher/New(cipher_key, cipher_label)
	key = cipher_key
	label = cipher_label || "Канал"
