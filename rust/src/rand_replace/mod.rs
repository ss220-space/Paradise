use meowtonin::{byond_fn, ByondError, ByondResult, ByondValue, ToByond};
use rand::{rngs::SmallRng, RngExt, SeedableRng};
use std::cell::RefCell;
use std::error::Error;

thread_local! {
    static RNG: RefCell<SmallRng> = RefCell::new(SmallRng::from_rng(&mut rand::rng()));
}

#[byond_fn]
fn random_replace(
    text: ByondValue,
    chance: ByondValue,
    replacement: ByondValue,
) -> ByondResult<ByondValue> {
    let input = text.get_string()?;
    let chance_val = chance.get_number()?.clamp(0.0, 100.0) / 100.0;
    let replacement_char = replacement
        .get_string()?
        .chars()
        .next()
        .ok_or(ByondError::Boxed(Box::<dyn Error + Send + Sync>::from(
            "missed replacement pattern",
        )))?;

    let mut output = String::with_capacity(input.len());

    RNG.with(|rng| {
        let mut rng = rng.borrow_mut();

        for ch in input.chars() {
            if ch == ' ' {
                output.push(ch);
                continue;
            }

            if rng.random::<f32>() < chance_val {
                output.push(replacement_char);
                continue;
            }

            output.push(ch);
        }
    });

    output.to_byond()
}
