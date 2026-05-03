use byondapi::value::ByondValue;
use core::f32;
use std::{fs::File, time::Duration};
use symphonia::{
    self,
    core::{
        codecs::DecoderOptions,
        formats::FormatOptions,
        io::MediaSourceStream,
        meta::MetadataOptions,
        probe::{Hint, ProbeResult},
    },
    default::{get_codecs, get_probe},
};

#[byondapi::bind]
fn sound_len(sound_path: ByondValue) -> eyre::Result<ByondValue> {
    let path = sound_path.get_string()?;
    let length = get_sound_length_safe(&path)?;
    Ok(length.try_into()?)
}

fn get_sound_length_safe(path: &str) -> eyre::Result<f32> {
    let prev_hook = std::panic::take_hook();
    std::panic::set_hook(Box::new(|_| {}));
    let result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| get_sound_length(path)));
    std::panic::set_hook(prev_hook);
    match result {
        Ok(r) => r,
        Err(_) => {
            diagnose_file(path);
            Err(eyre::eyre!(format!(
                "symphonia panicked while parsing {path}"
            )))
        }
    }
}

fn diagnose_file(path: &str) {
    use std::io::Read;
    let bytes = path.as_bytes();
    let path_hex: String = bytes.iter().map(|b| format!("{:02x}", b)).collect();
    let cwd = std::env::current_dir()
        .map(|p| p.display().to_string())
        .unwrap_or_else(|_| "<err>".into());
    let abs = std::path::Path::new(path)
        .canonicalize()
        .map(|p| p.display().to_string())
        .unwrap_or_else(|e| format!("<canon err: {e}>"));
    let mut head = [0u8; 16];
    let (size, magic) = match std::fs::File::open(path) {
        Ok(mut f) => {
            let size = f.metadata().map(|m| m.len()).unwrap_or(0);
            let n = f.read(&mut head).unwrap_or(0);
            let h: String = head[..n].iter().map(|b| format!("{:02x}", b)).collect();
            (size, h)
        }
        Err(e) => (0, format!("<open err: {e}>")),
    };
    eprintln!(
        "[rustlibs sound_len] PANIC: path={path:?} bytes={path_hex} cwd={cwd} abs={abs} size={size} head={magic}"
    );
}

fn get_sound_length(sound_path: &str) -> eyre::Result<f32> {
    let sound_src = match File::open(sound_path) {
        Ok(r) => r,
        Err(e) => return Err(eyre::eyre!(format!("Couldn't open file, {e}"))),
    };

    let mss = MediaSourceStream::new(Box::new(sound_src), Default::default());

    let mut hint = Hint::new();
    hint.with_extension("ogg");
    hint.with_extension("mp3");

    let meta_opts: MetadataOptions = Default::default();
    let fmt_opts: FormatOptions = symphonia::core::formats::FormatOptions {
        enable_gapless: true,
        ..Default::default()
    };

    let probed = match get_probe().format(&hint, mss, &fmt_opts, &meta_opts) {
        Ok(r) => r,
        Err(e) => return Err(eyre::eyre!(format!("Probe error: {e}"))),
    };

    if let Ok(r) = sound_length_simple(&probed) {
        return Ok(r as f32);
    }

    sound_length_decode(probed).map(|r| r as f32)
}

fn sound_length_simple(probed: &ProbeResult) -> eyre::Result<f64> {
    let format = &probed.format;

    let track = match format.default_track() {
        Some(r) => r,
        None => return Err(eyre::eyre!("Could not get default track")),
    };

    let time_base = track
        .codec_params
        .time_base
        .ok_or_else(|| eyre::eyre!("Codec does not provide a time base"))?;

    let n_frames = track
        .codec_params
        .n_frames
        .ok_or_else(|| eyre::eyre!("Codec does not provide frame count"))?;

    let time = time_base.calc_time(n_frames);
    let duration = Duration::from_secs(time.seconds) + Duration::from_secs_f64(time.frac);

    Ok(duration.as_secs_f64() * 10.0)
}

fn sound_length_decode(probed: ProbeResult) -> eyre::Result<f64> {
    let mut format = probed.format;

    let track = match format.default_track() {
        Some(r) => r,
        None => return Err(eyre::eyre!("Could not get default track".to_string())),
    };

    // Grab the number of frames of the track
    let samples_capacity = if let Some(n_frames) = track.codec_params.n_frames {
        n_frames as f64
    } else {
        0.0
    };

    // Create a decoder using the provided codec parameters in the track.
    let decoder_opts: DecoderOptions = Default::default();
    let mut decoder = match get_codecs().make(&track.codec_params, &decoder_opts) {
        Ok(r) => r,
        Err(e) => return Err(eyre::eyre!(format!("Decoder creation error: {e}"))),
    };

    // Try to grab a data packet from the container
    let encoded_packet = match format.next_packet() {
        Ok(r) => r,
        Err(e) => return Err(eyre::eyre!(format!("Next_packet error: {e}"))),
    };

    // Try to decode the data packet
    let decoded_packet = match decoder.decode(&encoded_packet) {
        Ok(r) => r,
        Err(e) => return Err(eyre::eyre!(format!("Decode error: {e}"))),
    };

    // Grab the sample rate from the spec of the buffer.
    let sample_rate = decoded_packet.spec().rate as f64;
    // Math!
    let duration_in_desciseconds = samples_capacity / sample_rate * 10.0;
    Ok(duration_in_desciseconds)
}

#[byondapi::bind]
fn sound_len_list(list: ByondValue) -> eyre::Result<ByondValue> {
    let list_values = list.get_list_values()?;
    let result = get_sound_length_list(&list_values)?;
    Ok(result)
}

fn get_sound_length_list(list: &[ByondValue]) -> eyre::Result<ByondValue> {
    let mut successes = ByondValue::new_list()?;
    let mut errors = ByondValue::new_list()?;

    for path_value in list.iter() {
        let path_string = match path_value.get_string() {
            Ok(s) => s,
            Err(e) => {
                errors.write_list_index(*path_value, format!("Invalid path: {e}"))?;
                continue;
            }
        };

        match get_sound_length_safe(&path_string) {
            Ok(duration) => {
                successes.write_list_index(*path_value, duration)?;
            }
            Err(e) => {
                errors.write_list_index(*path_value, e.to_string())?;
            }
        };
    }

    let mut out = ByondValue::new_list()?;
    out.write_list_index(ByondValue::new_str("successes")?, successes)?;
    out.write_list_index(ByondValue::new_str("errors")?, errors)?;

    Ok(out)
}
