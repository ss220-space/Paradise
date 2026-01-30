#define HMAC_BLOCK_SIZE 64
#define HMAC_IPAD 54 // ASCII "6"
#define HMAC_OPAD 92 // ASCII "\"

/*
 * Основная функция HMAC-MD5
 * hex_key - ключ в hex-формате
 * data - данные для подписи
 */
/proc/hmac_md5_hex(hex_key, data)
	var/key_bin = hex_to_bin(hex_key)

	if(!key_bin)
		CRASH("hmac_md5_hex: Invalid hex key for HMAC")

	if(length(key_bin) > HMAC_BLOCK_SIZE)
		key_bin = hex_to_bin(md5(key_bin))

	if(length(key_bin) < HMAC_BLOCK_SIZE)
		key_bin += repeat_string(HMAC_BLOCK_SIZE - length(key_bin), "0")

	var/ipad = repeat_string(HMAC_BLOCK_SIZE, ascii2text(HMAC_IPAD))
	var/opad = repeat_string(HMAC_BLOCK_SIZE, ascii2text(HMAC_OPAD))

	var/i_key = xor_strings(key_bin, ipad)
	var/o_key = xor_strings(key_bin, opad)

	var/inner_hash = md5(i_key + data)

	var/inner_hash_bin = hex_to_bin(inner_hash)
	var/hmac_hex = md5(o_key + inner_hash_bin)

	return hmac_hex

/proc/hmac_md5_base64(hex_key, data)
	var/hmac_hex = hmac_md5_hex(hex_key, data)
	var/hmac_bin = hex_to_bin(hmac_hex)
	return rustg_encode_base64(hmac_bin)

/proc/xor_strings(a, b)
	if(length(a) != length(b))
		CRASH("XOR: strings of different lengths ([length(a)] vs [length(b)])")

	var/result = ""
	for(var/i = 1; i <= length(a); i++)
		var/byte_a = text2ascii(copytext(a, i, i+1))
		var/byte_b = text2ascii(copytext(b, i, i+1))
		result += ascii2text(byte_a ^ byte_b)

	return result

/proc/hex_to_bin(hex_string)
	if(!istext(hex_string))
		return null

	hex_string = replacetext(hex_string, " ", "")
	hex_string = replacetext(hex_string, "\n", "")
	hex_string = replacetext(hex_string, "\t", "")

	if(length(hex_string) % 2 != 0)
		hex_string = "0" + hex_string

	var/bin = ""
	for(var/i = 1; i <= length(hex_string); i += 2)
		var/hex_pair = copytext(hex_string, i, i+2)
		var/num = hex2num(hex_pair)

		if(isnull(num))
			return null

		bin += ascii2text(num)

	return bin

/proc/bin_to_hex(bin_string)
	if(!istext(bin_string))
		return ""

	var/hex = ""
	for(var/i = 1; i <= length(bin_string); i++)
		var/byte = text2ascii(copytext(bin_string, i, i+1))
		hex += num2hex(byte, 2)

	return lowertext(hex)

/proc/validate_hmac_key(hex_key)
	if(!istext(hex_key))
		return FALSE

	var/len = length(hex_key)
	if(len != 40 && len != HMAC_BLOCK_SIZE)
		return FALSE

	var/valid_chars = "0123456789abcdefABCDEF"
	for(var/i = 1; i <= len; i++)
		var/char = copytext(hex_key, i, i+1)
		if(!findtext(valid_chars, char))
			return FALSE

	return TRUE

#undef HMAC_BLOCK_SIZE
#undef HMAC_IPAD
#undef HMAC_OPAD
