use byondapi::value::ByondValue;
use rand::Rng;

pub fn pick_weight(list: &ByondValue) -> eyre::Result<ByondValue> {
    let mut total = 0;

    for item in list.get_list_values()? {
        let mut weight = list.read_list_index(item)?;

        if weight.is_null() {
            weight.set_number(1.0);
        }

        total += weight.get_number()? as i32;
    }

    let mut rng = rand::thread_rng();
    let mut rand_weight: i32 = rng.gen_range(1..=total);

    for item in list.get_list_values()? {
        let mut weight = list.read_list_index(item)?;

        if weight.is_null() {
            weight.set_number(1.0);
        }

        rand_weight -= weight.get_number()? as i32;

        if rand_weight <= 0 {
            return Ok(item);
        }
    }

    return Ok(ByondValue::null());
}
