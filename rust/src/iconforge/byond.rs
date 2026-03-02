use super::{gags, image_cache, spritesheet};
use crate::{error::catch_panic, jobs};
use byondapi::value::ByondValue;
use tracy_full::frame;

#[byondapi::bind]
fn iconforge_generate(
    file_path: ByondValue,
    spritesheet_name: ByondValue,
    sprites: ByondValue,
    hash_icons: ByondValue,
    generate_dmi: ByondValue,
    flatten: ByondValue,
) -> eyre::Result<ByondValue> {
    let file_path = file_path.get_string()?;
    let spritesheet_name = spritesheet_name.get_string()?;
    let sprites = sprites.get_string()?;
    let hash_icons = hash_icons.get_bool()?;
    let generate_dmi = generate_dmi.get_bool()?;
    let flatten = flatten.get_bool()?;
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
    Ok(result.try_into()?)
}

#[byondapi::bind]
fn iconforge_generate_async(
    file_path: ByondValue,
    spritesheet_name: ByondValue,
    sprites: ByondValue,
    hash_icons: ByondValue,
    generate_dmi: ByondValue,
    flatten: ByondValue,
) -> eyre::Result<ByondValue> {
    let file_path = file_path.get_string()?;
    let spritesheet_name = spritesheet_name.get_string()?;
    let sprites = sprites.get_string()?;
    let hash_icons = hash_icons.get_bool()?;
    let generate_dmi = generate_dmi.get_bool()?;
    let flatten = flatten.get_bool()?;
    Ok((jobs::start(move || {
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
        .into())
}

#[byondapi::bind]
fn iconforge_check(id: ByondValue) -> eyre::Result<ByondValue> {
    let job_id = id.get_number()? as usize;
    match jobs::check(&job_id) {
        Some(Ok(result)) => Ok(result.try_into()?),
        Some(Err(flume::TryRecvError::Empty)) => Ok(jobs::NO_RESULTS_YET.try_into()?),
        Some(Err(flume::TryRecvError::Disconnected)) => Ok(jobs::JOB_PANICKED.try_into()?),
        None => Ok(jobs::NO_SUCH_JOB.try_into()?),
    }
}

#[byondapi::bind]
fn iconforge_cleanup() -> eyre::Result<ByondValue> {
    image_cache::icon_cache_clear();
    image_cache::image_cache_clear();
    Ok(ByondValue::new_str("Ok")?)
}

#[byondapi::bind]
fn iconforge_cache_valid(
    input_hash: ByondValue,
    dmi_hashes: ByondValue,
    sprites: ByondValue,
) -> eyre::Result<ByondValue> {
    let input_hash = input_hash.get_string()?;
    let dmi_hashes = dmi_hashes.get_string()?;
    let sprites = sprites.get_string()?;
    let result = match catch_panic(|| spritesheet::cache_valid(&input_hash, &dmi_hashes, &sprites))
    {
        Ok(o) => o.to_string(),
        Err(e) => e.to_string(),
    };
    frame!();
    Ok(result.try_into()?)
}

#[byondapi::bind]
fn iconforge_cache_valid_async(
    input_hash: ByondValue,
    dmi_hashes: ByondValue,
    sprites: ByondValue,
) -> eyre::Result<ByondValue> {
    let input_hash = input_hash.get_string()?;
    let dmi_hashes = dmi_hashes.get_string()?;
    let sprites = sprites.get_string()?;
    Ok((jobs::start(move || {
        let result =
            match catch_panic(|| spritesheet::cache_valid(&input_hash, &dmi_hashes, &sprites)) {
                Ok(o) => o.to_string(),
                Err(e) => e.to_string(),
            };
        frame!();
        result
    }) as f32)
        .into())
}

#[byondapi::bind]
fn iconforge_load_gags_config(
    config_path: ByondValue,
    config_json: ByondValue,
    config_icon_path: ByondValue,
) -> eyre::Result<ByondValue> {
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
    Ok(result.try_into()?)
}

#[byondapi::bind]
fn iconforge_load_gags_config_async(
    config_path: ByondValue,
    config_json: ByondValue,
    config_icon_path: ByondValue,
) -> eyre::Result<ByondValue> {
    let config_path = config_path.get_string()?;
    let config_json = config_json.get_string()?;
    let config_icon_path = config_icon_path.get_string()?;
    Ok((jobs::start(move || {
        let result = match catch_panic(|| {
            gags::load_gags_config(&config_path, &config_json, &config_icon_path)
        }) {
            Ok(o) => o.to_string(),
            Err(e) => e.to_string(),
        };
        frame!();
        result
    }) as f32)
        .into())
}

#[byondapi::bind]
fn iconforge_gags(
    config_path: ByondValue,
    colors: ByondValue,
    output_dmi_path: ByondValue,
) -> eyre::Result<ByondValue> {
    let config_path = config_path.get_string()?;
    let colors = colors.get_string()?;
    let output_dmi_path = output_dmi_path.get_string()?;
    let result = match catch_panic(|| gags::gags(&config_path, &colors, &output_dmi_path)) {
        Ok(o) => o.to_string(),
        Err(e) => e.to_string(),
    };
    frame!();
    Ok(result.try_into()?)
}

#[byondapi::bind]
fn iconforge_gags_async(
    config_path: ByondValue,
    colors: ByondValue,
    output_dmi_path: ByondValue,
) -> eyre::Result<ByondValue> {
    let config_path = config_path.get_string()?;
    let colors = colors.get_string()?;
    let output_dmi_path = output_dmi_path.get_string()?;
    Ok((jobs::start(move || {
        let result = match catch_panic(|| gags::gags(&config_path, &colors, &output_dmi_path)) {
            Ok(o) => o.to_string(),
            Err(e) => e.to_string(),
        };
        frame!();
        result
    }) as f32)
        .into())
}

#[byondapi::bind]
fn iconforge_cleanup_all() -> eyre::Result<ByondValue> {
    spritesheet::sprites_to_json_clear();
    image_cache::icon_cache_clear();
    image_cache::image_cache_clear();

    Ok(ByondValue::new_str("OK")?)
}
