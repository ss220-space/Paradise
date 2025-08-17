use byondapi::value::ByondValue;
use eyre::OptionExt;
use rand::rngs::SmallRng;
use rand::Rng;
use rand::SeedableRng;
use std::cell::RefCell;

thread_local! {
    static RNG: RefCell<SmallRng> = RefCell::new(SmallRng::from_rng(&mut rand::rng()));
}

#[byondapi::bind]
fn random_replace(
    text: ByondValue,
    chance: ByondValue,
    replacement: ByondValue,
) -> eyre::Result<ByondValue> {
    let input = text.get_string()?;
    let chance_val = chance.get_number()?.clamp(0.0, 100.0) / 100.0;
    let replacement_char = replacement
        .get_string()?
        .chars()
        .next()
        .ok_or_eyre("missed replacement pattern")?;

    let mut output = String::with_capacity(input.len());

    for ch in input.chars() {
        if ch == ' ' {
            output.push(ch);
            continue;
        }

        let do_replace = RNG.with(|rng| rng.borrow_mut().random_bool(chance_val.into()));

        if do_replace {
            output.push(replacement_char);
        } else {
            output.push(ch);
        }
    }

    Ok(ByondValue::try_from(output)?)
}
