use byondapi::value::ByondValue;
use dmi::{
    error::DmiError,
    icon::{Icon, Looping},
};
use image::Rgba;
use png::{text_metadata::ZTXtChunk, Decoder, Encoder, OutputInfo, Reader};
use qrcode::{render::svg, QrCode};
use serde::{Deserialize, Serialize};
use serde_repr::{Deserialize_repr, Serialize_repr};
use std::{
    fmt::Write,
    fs::{create_dir_all, File},
    io::BufReader,
    num::NonZeroU32,
    path::Path,
};

#[byondapi::bind]
fn dmi_strip_metadata(path: ByondValue) -> eyre::Result<ByondValue> {
    strip_metadata(&path.get_string()?)?;
    Ok(ByondValue::null())
}

#[byondapi::bind]
fn dmi_create_png(
    path: ByondValue,
    width: ByondValue,
    height: ByondValue,
    data: ByondValue,
) -> eyre::Result<ByondValue> {
    create_png(
        &path.get_string()?,
        &width.get_string()?,
        &height.get_string()?,
        &data.get_string()?,
    )?;
    Ok(ByondValue::null())
}

#[byondapi::bind]
fn dmi_resize_png(
    path: ByondValue,
    width: ByondValue,
    height: ByondValue,
    resizetype: ByondValue,
) -> eyre::Result<ByondValue> {
    let resizetype = match resizetype.get_string()?.as_str() {
        "catmull" => image::imageops::CatmullRom,
        "gaussian" => image::imageops::Gaussian,
        "lanczos3" => image::imageops::Lanczos3,
        "nearest" => image::imageops::Nearest,
        "triangle" => image::imageops::Triangle,
        _ => image::imageops::Nearest,
    };
    resize_png(
        path.get_string()?,
        &width.get_string()?,
        &height.get_string()?,
        resizetype,
    )?;
    Ok(ByondValue::null())
}

#[byondapi::bind]
fn dmi_read_metadata(path: ByondValue) -> eyre::Result<ByondValue> {
    let metadata = read_metadata(&path.get_string()?)?;
    Ok(metadata.try_into()?)
}

#[byondapi::bind]
fn dmi_icon_states(path: ByondValue) -> eyre::Result<ByondValue> {
    let states = read_states(&path.get_string()?)?;
    Ok(states)
}

#[byondapi::bind]
fn dmi_inject_metadata(path: ByondValue, metadata: ByondValue) -> eyre::Result<ByondValue> {
    inject_metadata(&path.get_string()?, &metadata.get_string()?)?;
    Ok(ByondValue::null())
}

fn strip_metadata(path: &str) -> eyre::Result<()> {
    let (reader, frame_info, image) = read_png(path)?;
    write_png(path, &reader, &frame_info, &image, true)
}

fn read_png(path: &str) -> eyre::Result<(Reader<BufReader<File>>, OutputInfo, Vec<u8>)> {
    let mut reader = Decoder::new(BufReader::new(File::open(path)?)).read_info()?;
    let buffer_size = reader
        .output_buffer_size()
        .ok_or_else(|| eyre::eyre!("Failed to determine output buffer size"))?;
    let mut buf = vec![0; buffer_size];
    let frame_info = reader.next_frame(&mut buf)?;

    Ok((reader, frame_info, buf))
}

fn write_png(
    path: &str,
    reader: &Reader<BufReader<File>>,
    info: &OutputInfo,
    image: &[u8],
    strip: bool,
) -> eyre::Result<()> {
    let mut encoder = Encoder::new(File::create(path)?, info.width, info.height);
    encoder.set_color(info.color_type);
    encoder.set_depth(info.bit_depth);

    let reader_info = reader.info();
    if let Some(palette) = reader_info.palette.clone() {
        encoder.set_palette(palette);
    }

    if let Some(trns_chunk) = reader_info.trns.clone() {
        encoder.set_trns(trns_chunk);
    }

    let mut writer = encoder.write_header()?;
    // Handles zTxt chunk copying from the original image if we /don't/ want to strip it
    if !strip {
        for chunk in &reader_info.compressed_latin1_text {
            writer.write_text_chunk(chunk)?;
        }
    }
    Ok(writer.write_image_data(image)?)
}

fn create_png(path: &str, width: &str, height: &str, data: &str) -> eyre::Result<()> {
    let width = width.parse::<u32>()?;
    let height = height.parse::<u32>()?;

    let bytes = data.as_bytes();

    let mut result: Vec<u8> = Vec::new();
    for pixel in bytes.split(|&b| b == b'#').skip(1) {
        if pixel.len() != 6 && pixel.len() != 8 {
            return Err(eyre::eyre!("Invalid PNG data"));
        }
        for channel in pixel.chunks_exact(2) {
            result.push(u8::from_str_radix(std::str::from_utf8(channel)?, 16)?);
        }
        // If only RGB is provided for any pixel we also add alpha
        if pixel.len() == 6 {
            result.push(255);
        }
    }

    if let Some(fdir) = Path::new(path).parent() {
        if !fdir.is_dir() {
            create_dir_all(fdir)?;
        }
    }

    let mut encoder = Encoder::new(File::create(path)?, width, height);
    encoder.set_color(png::ColorType::Rgba);
    encoder.set_depth(png::BitDepth::Eight);
    let mut writer = encoder.write_header()?;
    Ok(writer.write_image_data(&result)?)
}

fn resize_png<P: AsRef<Path>>(
    path: P,
    width: &str,
    height: &str,
    resizetype: image::imageops::FilterType,
) -> eyre::Result<()> {
    let width = width.parse::<u32>()?;
    let height = height.parse::<u32>()?;

    let img = image::open(path.as_ref())?;

    let newimg = img.resize(width, height, resizetype);

    Ok(newimg.save_with_format(path.as_ref(), image::ImageFormat::Png)?)
}

/// Output is a JSON string for reading within BYOND
///
/// Erroring at any point will produce an empty string
fn read_states(path: &str) -> eyre::Result<ByondValue> {
    let file = File::open(path).map(BufReader::new)?;
    let decoder = png::Decoder::new(file);
    let reader = decoder
        .read_info()
        .map_err(|_| eyre::eyre!("Invalid PNG data"))?;
    let info = reader.info();
    let mut list = ByondValue::new_list()?;

    for ztxt in &info.compressed_latin1_text {
        let text = ztxt.get_text()?;
        for line in text.lines().take_while(|line| !line.contains("# END DMI")) {
            if let Some(state) = line
                .trim()
                .strip_prefix("state = \"")
                .and_then(|line| line.strip_suffix('"'))
            {
                list.push_list(state.try_into()?)?;
            }
        }
    }

    Ok(list)
}

#[derive(Serialize_repr, Deserialize_repr, Clone, Copy)]
#[repr(u8)]
enum DmiStateDirCount {
    One = 1,
    Four = 4,
    Eight = 8,
}

impl TryFrom<u8> for DmiStateDirCount {
    type Error = u8;
    fn try_from(value: u8) -> eyre::Result<Self, Self::Error> {
        match value {
            1 => Ok(Self::One),
            4 => Ok(Self::Four),
            8 => Ok(Self::Eight),
            n => Err(n),
        }
    }
}

#[derive(Serialize, Deserialize)]
struct DmiState {
    name: String,
    dirs: DmiStateDirCount,
    #[serde(default)]
    delay: Option<Vec<f32>>,
    #[serde(default)]
    rewind: Option<u8>,
    #[serde(default)]
    movement: Option<u8>,
    #[serde(default)]
    loop_count: Option<NonZeroU32>,
    #[serde(default)]
    hotspot: Option<(u32, u32, u32)>,
}

#[derive(Serialize, Deserialize)]
struct DmiMetadata {
    width: u32,
    height: u32,
    states: Vec<DmiState>,
}

fn read_metadata(path: &str) -> eyre::Result<String> {
    let dmi = Icon::load_meta(File::open(path).map(BufReader::new)?)?;
    let metadata = DmiMetadata {
        width: dmi.width,
        height: dmi.height,
        states: dmi
            .states
            .iter()
            .map(|state| {
                Ok(DmiState {
                    name: state.name.clone(),
                    dirs: DmiStateDirCount::try_from(state.dirs).map_err(|n| {
                        DmiError::IconState(format!(
                            "State \"{}\" has invalid dir count (expected 1, 4, or 8, got {})",
                            state.name, n
                        ))
                    })?,
                    delay: state.delay.clone(),
                    movement: state.movement.then_some(1),
                    rewind: state.rewind.then_some(1),
                    loop_count: match state.loop_flag {
                        Looping::Indefinitely => None,
                        Looping::NTimes(n) => Some(n),
                    },
                    hotspot: state.hotspot.map(|hotspot| (hotspot.x, hotspot.y, 1)),
                })
            })
            .collect::<Result<Vec<DmiState>, DmiError>>()?,
    };
    Ok(serde_json::to_string(&metadata)?)
}

fn inject_metadata(path: &str, metadata: &str) -> eyre::Result<()> {
    let read_file = File::open(path).map(BufReader::new)?;
    let decoder = png::Decoder::new(read_file);
    let mut reader = decoder
        .read_info()
        .map_err(|_| eyre::eyre!("Invalid PNG data"))?;
    let new_dmi_metadata: DmiMetadata = serde_json::from_str(metadata)?;
    let mut new_metadata_string = String::new();
    writeln!(new_metadata_string, "# BEGIN DMI")?;
    writeln!(new_metadata_string, "version = 4.0")?;
    writeln!(new_metadata_string, "\twidth = {}", new_dmi_metadata.width)?;
    writeln!(
        new_metadata_string,
        "\theight = {}",
        new_dmi_metadata.height
    )?;
    for state in new_dmi_metadata.states {
        writeln!(new_metadata_string, "state = \"{}\"", state.name)?;
        writeln!(new_metadata_string, "\tdirs = {}", state.dirs as u8)?;
        writeln!(
            new_metadata_string,
            "\tframes = {}",
            state.delay.as_ref().map_or(1, Vec::len)
        )?;
        if let Some(delay) = state.delay {
            writeln!(
                new_metadata_string,
                "\tdelay = {}",
                delay
                    .iter()
                    .map(f32::to_string)
                    .collect::<Vec<_>>()
                    .join(",")
            )?;
        }
        if state.rewind.is_some_and(|r| r != 0) {
            writeln!(new_metadata_string, "\trewind = 1")?;
        }
        if state.movement.is_some_and(|m| m != 0) {
            writeln!(new_metadata_string, "\tmovement = 1")?;
        }
        if let Some(loop_count) = state.loop_count {
            writeln!(new_metadata_string, "\tloop = {loop_count}")?;
        }
        if let Some((hotspot_x, hotspot_y, hotspot_frame)) = state.hotspot {
            writeln!(
                new_metadata_string,
                "\totspot = {hotspot_x},{hotspot_y},{hotspot_frame}"
            )?;
        }
    }
    writeln!(new_metadata_string, "# END DMI")?;
    let mut info = reader.info().clone();
    info.compressed_latin1_text
        .push(ZTXtChunk::new("Description", new_metadata_string));
    let mut raw_image_data: Vec<u8> = vec![];
    while let Some(row) = reader.next_row()? {
        raw_image_data.append(&mut row.data().to_vec());
    }
    let encoder = png::Encoder::with_info(File::create(path)?, info)?;
    encoder.write_header()?.write_image_data(&raw_image_data)?;
    Ok(())
}

#[byondapi::bind]
fn create_qr_code_png(path: ByondValue, data: ByondValue) -> eyre::Result<ByondValue> {
    let path_str = path.get_string()?;
    let data_str = data.get_string()?;

    let code = QrCode::new(data_str.as_bytes())?;
    let image = code.render::<Rgba<u8>>().build();

    image.save(&path_str)?;
    Ok(path)
}

#[byondapi::bind]
fn create_qr_code_svg(data: ByondValue) -> eyre::Result<ByondValue> {
    let data_str = data.get_string()?;

    let code = QrCode::new(data_str.as_bytes())?;
    let svg_xml = code.render::<svg::Color>().build();

    Ok(svg_xml.try_into()?)
}
