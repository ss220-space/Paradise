use super::{gags, image_cache, spritesheet};
use crate::{error::catch_panic, jobs};
use meowtonin::{byond_fn, ByondResult, ByondValue, ToByond};
use tracy_full::frame;

#[byond_fn]
fn iconforge_generate(
    file_path: ByondValue,
    spritesheet_name: ByondValue,
    sprites: ByondValue,
    hash_icons: ByondValue,
    generate_dmi: ByondValue,
    flatten: ByondValue,
) -> ByondResult<ByondValue> {
    let file_path = file_path.get_string()?;
    let spritesheet_name = spritesheet_name.get_string()?;
    let sprites = sprites.get_string()?;
    let hash_icons = hash_icons.is_true();
    let generate_dmi = generate_dmi.is_true();
    let flatten = flatten.is_true();
    let result = match catch_panic(|| {
        spritesheet::generate_spritesheet(
            &file_path,
            &spritesheet_name,
            &sprites,
            hash_icons,
            generate_dmi,
            flatten,
        )
    }) {
        Ok(o) => o.to_string(),
        Err(e) => e.to_string(),
    };
    frame!();
    result.to_byond()
}

#[byond_fn]
fn iconforge_generate_async(
    file_path: ByondValue,
    spritesheet_name: ByondValue,
    sprites: ByondValue,
    hash_icons: ByondValue,
    generate_dmi: ByondValue,
    flatten: ByondValue,
) -> ByondResult<ByondValue> {
    let file_path = file_path.get_string()?;
    let spritesheet_name = spritesheet_name.get_string()?;
    let sprites = sprites.get_string()?;
    let hash_icons = hash_icons.is_true();
    let generate_dmi = generate_dmi.is_true();
    let flatten = flatten.is_true();
    (jobs::start(move || {
        let result = match catch_panic(|| {
            spritesheet::generate_spritesheet(
                &file_path,
                &spritesheet_name,
                &sprites,
                hash_icons,
                generate_dmi,
                flatten,
            )
        }) {
            Ok(o) => o.to_string(),
            Err(e) => e.to_string(),
        };
        frame!();
        result
    }) as f32)
        .to_byond()
}

#[byond_fn]
fn iconforge_check(id: ByondValue) -> ByondResult<ByondValue> {
    let job_id = id.get_number()? as usize;
    match jobs::check(&job_id) {
        Some(Ok(result)) => result.to_byond(),
        Some(Err(flume::TryRecvError::Empty)) => jobs::NO_RESULTS_YET.to_byond(),
        Some(Err(flume::TryRecvError::Disconnected)) => jobs::JOB_PANICKED.to_byond(),
        None => jobs::NO_SUCH_JOB.to_byond(),
    }
}

#[byond_fn]
fn iconforge_cleanup() -> ByondResult<ByondValue> {
    // Only perform cleanup if no jobs are currently using the icon cache
    if image_cache::CACHE_ACTIVE.load(std::sync::atomic::Ordering::SeqCst) > 0 {
        return Ok(ByondValue::new_string("Skipped, cache in use"));
    }
    image_cache::icon_cache_clear();
    image_cache::image_cache_clear();
    Ok(ByondValue::new_string("Ok"))
}

#[byond_fn]
fn iconforge_cache_valid(
    input_hash: ByondValue,
    dmi_hashes: ByondValue,
    sprites: ByondValue,
) -> ByondResult<ByondValue> {
    let input_hash = input_hash.get_string()?;
    let dmi_hashes = dmi_hashes.get_string()?;
    let sprites = sprites.get_string()?;
    let result = match catch_panic(|| spritesheet::cache_valid(&input_hash, &dmi_hashes, &sprites))
    {
        Ok(o) => o.to_string(),
        Err(e) => e.to_string(),
    };
    frame!();
    result.to_byond()
}

#[byond_fn]
fn iconforge_cache_valid_async(
    input_hash: ByondValue,
    dmi_hashes: ByondValue,
    sprites: ByondValue,
) -> ByondResult<ByondValue> {
    let input_hash = input_hash.get_string()?;
    let dmi_hashes = dmi_hashes.get_string()?;
    let sprites = sprites.get_string()?;
    (jobs::start(move || {
        let result =
            match catch_panic(|| spritesheet::cache_valid(&input_hash, &dmi_hashes, &sprites)) {
                Ok(o) => o.to_string(),
                Err(e) => e.to_string(),
            };
        frame!();
        result
    }) as f32)
        .to_byond()
}

#[byond_fn]
fn iconforge_load_gags_config(
    config_path: ByondValue,
    config_json: ByondValue,
    config_icon_path: ByondValue,
) -> ByondResult<ByondValue> {
    let config_path = config_path.get_string()?;
    let config_json = config_json.get_string()?;
    let config_icon_path = config_icon_path.get_string()?;
    let result =
        match catch_panic(|| gags::load_gags_config(&config_path, &config_json, &config_icon_path))
        {
            Ok(o) => o.to_string(),
            Err(e) => e.to_string(),
        };
    frame!();
    result.to_byond()
}

#[byond_fn]
fn iconforge_load_gags_config_async(
    config_path: ByondValue,
    config_json: ByondValue,
    config_icon_path: ByondValue,
) -> ByondResult<ByondValue> {
    let config_path = config_path.get_string()?;
    let config_json = config_json.get_string()?;
    let config_icon_path = config_icon_path.get_string()?;
    (jobs::start(move || {
        let result = match catch_panic(|| {
            gags::load_gags_config(&config_path, &config_json, &config_icon_path)
        }) {
            Ok(o) => o.to_string(),
            Err(e) => e.to_string(),
        };
        frame!();
        result
    }) as f32)
        .to_byond()
}

#[byond_fn]
fn iconforge_gags(
    config_path: ByondValue,
    colors: ByondValue,
    output_dmi_path: ByondValue,
) -> ByondResult<ByondValue> {
    let config_path = config_path.get_string()?;
    let colors = colors.get_string()?;
    let output_dmi_path = output_dmi_path.get_string()?;
    let result = match catch_panic(|| gags::gags(&config_path, &colors, &output_dmi_path)) {
        Ok(o) => o.to_string(),
        Err(e) => e.to_string(),
    };
    frame!();
    result.to_byond()
}

#[byond_fn]
fn iconforge_gags_async(
    config_path: ByondValue,
    colors: ByondValue,
    output_dmi_path: ByondValue,
) -> ByondResult<ByondValue> {
    let config_path = config_path.get_string()?;
    let colors = colors.get_string()?;
    let output_dmi_path = output_dmi_path.get_string()?;
    (jobs::start(move || {
        let result = match catch_panic(|| gags::gags(&config_path, &colors, &output_dmi_path)) {
            Ok(o) => o.to_string(),
            Err(e) => e.to_string(),
        };
        frame!();
        result
    }) as f32)
        .to_byond()
}

#[byond_fn]
fn iconforge_cleanup_all() -> ByondResult<ByondValue> {
    spritesheet::sprites_to_json_clear();
    image_cache::icon_cache_clear();
    image_cache::image_cache_clear();

    Ok(ByondValue::new_string("OK"))
}
