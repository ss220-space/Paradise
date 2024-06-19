GLOBAL_LIST_INIT(bitfields, generate_bitfields())

/// Specifies a bitfield for smarter debugging
/datum/bitfield
	/// The variable name that contains the bitfield
	var/variable

	/// An associative list of the readable flag and its true value
	var/list/flags

/// Turns /datum/bitfield subtypes into a list for use in debugging
/proc/generate_bitfields()
	var/list/bitfields = list()
	for (var/_bitfield in subtypesof(/datum/bitfield))
		var/datum/bitfield/bitfield = new _bitfield
		bitfields[bitfield.variable] = bitfield.flags
	return bitfields

DEFINE_BITFIELD(datum_flags, list(
	"DF_ISPROCESSING" = DF_ISPROCESSING,
	"DF_VAR_EDITED" = DF_VAR_EDITED,
	"DF_USE_TAG" = DF_USE_TAG,
))

DEFINE_BITFIELD(turf_flags, list(
	"NOJAUNT" = NOJAUNT,
	"UNUSED_RESERVATION_TURF" = UNUSED_RESERVATION_TURF,
	"RESERVATION_TURF" = RESERVATION_TURF,
	"NO_LAVA_GEN" = NO_LAVA_GEN,
	"NO_RUINS" = NO_RUINS,
))
