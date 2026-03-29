#define TLV_VALUE_IGNORE -1

/datum/tlv
	var/min2	// hazard_min
	var/min1	// warning_min
	var/max1	// warning_max
	var/max2	// hazard_max

/datum/tlv/New(_min2, _min1, _max1, _max2)
	if(_min2)
		min2 = _min2
	if(_min1)
		min1 = _min1
	if(_max1)
		min1 = _max1
	if(_max2)
		max2 = _max2

/datum/tlv/proc/get_danger_level(curval)
	if(max2 >= 0 && curval > max2)
		return ATMOS_ALARM_DANGER
	if(min2 >= 0 && curval < min2)
		return ATMOS_ALARM_DANGER
	if(max1 >= 0 && curval > max1)
		return ATMOS_ALARM_WARNING
	if(min1 >= 0 && curval < min1)
		return ATMOS_ALARM_WARNING
	return ATMOS_ALARM_NONE

/datum/tlv/proc/CopyFrom(datum/tlv/other)
	min2 = other.min2
	min1 = other.min1
	max1 = other.max1
	max2 = other.max2

/datum/tlv/ignore
	min2 = TLV_VALUE_IGNORE
	min1 = TLV_VALUE_IGNORE
	max1 = TLV_VALUE_IGNORE
	max2 = TLV_VALUE_IGNORE

/datum/tlv/dangerous
	min2 = TLV_VALUE_IGNORE
	min1 = TLV_VALUE_IGNORE
	max1 = 0.2
	max2 = 0.5

/datum/tlv/oxygen
	min2 = 16		// hazard_min
	min1 = 19		// warning_min
	max1 = TLV_VALUE_IGNORE
	max2 = TLV_VALUE_IGNORE

/datum/tlv/nitrogen
	min2 = TLV_VALUE_IGNORE
	min1 = TLV_VALUE_IGNORE
	max1 = TLV_VALUE_IGNORE
	max2 = TLV_VALUE_IGNORE

/datum/tlv/carbon_dioxide
	min2 = TLV_VALUE_IGNORE
	min1 = TLV_VALUE_IGNORE
	max1 = 5
	max2 = 10

/datum/tlv/plasma
	min2 = TLV_VALUE_IGNORE
	min1 = TLV_VALUE_IGNORE
	max1 = 0.2
	max2 = 0.5

/datum/tlv/nitrous_oxide
	min2 = TLV_VALUE_IGNORE
	min1 = TLV_VALUE_IGNORE
	max1 = 0.2
	max2 = 0.5

/datum/tlv/hydrogen
	min2 = TLV_VALUE_IGNORE
	min1 = TLV_VALUE_IGNORE
	max1 = 0.2
	max2 = 0.5

/datum/tlv/water_vapor
	min2 = TLV_VALUE_IGNORE
	min1 = TLV_VALUE_IGNORE
	max1 = 0.5
	max2 = 1.0

/datum/tlv/other_gas
	min2 = TLV_VALUE_IGNORE
	min1 = TLV_VALUE_IGNORE
	max1 = 0.5
	max2 = 1.0

/datum/tlv/pressure
	min2 = HAZARD_LOW_PRESSURE
	min1 = WARNING_LOW_PRESSURE
	max1 = WARNING_HIGH_PRESSURE
	max2 = HAZARD_HIGH_PRESSURE

/datum/tlv/temperature
	min2 = COLD_WARNING_1
	min1 = COLD_WARNING_1 + 10
	max1 = HEAT_WARNING_1 - 27
	max2 = HEAT_WARNING_1

/datum/tlv/vox_oxygen
	min2 = TLV_VALUE_IGNORE
	min1 = TLV_VALUE_IGNORE
	max1 = 1
	max2 = 2

/datum/tlv/vox_temperature
	min2 = T0C
	min1 = T0C + 10
	max1 = T0C + 40
	max2 = T0C + 66

/datum/tlv/cold_room_pressure
	min2 = ONE_ATMOSPHERE * 0.8
	min1 = ONE_ATMOSPHERE * 0.9
	max1 = ONE_ATMOSPHERE * 1.1
	max2 = ONE_ATMOSPHERE * 1.2

/datum/tlv/cold_room_temperature
	min2 = T0C - 50
	min1 = T0C - 20
	max1 = T0C
	max2 = T20C

/datum/tlv/server_temperature
	min2 = 0
	min1 = 0
	max1 = T20C + 5
	max2 = T20C + 15

#undef TLV_VALUE_IGNORE
