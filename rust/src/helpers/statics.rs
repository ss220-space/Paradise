use byondapi::sys::ByondValueData;
use byondapi::sys::CByondValue;
use byondapi::value::ByondValue;

pub static WORLD: ByondValue = ByondValue(CByondValue {
    type_: 0x0E,
    junk1: 0,
    junk2: 0,
    junk3: 0,
    data: ByondValueData { ref_: 0 },
});

pub static GLOBALS: ByondValue = ByondValue(CByondValue {
    type_: 0x0E,
    junk1: 0,
    junk2: 0,
    junk3: 0,
    data: ByondValueData { ref_: 1 },
});
