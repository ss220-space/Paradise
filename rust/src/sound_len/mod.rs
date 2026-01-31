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
    let length = get_sound_length(&sound_path.get_string()?)?;
    Ok(length.try_into()?)
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

fn sound_length_decode(mut probed: ProbeResult) -> eyre::Result<f64> {
    let track = match probed.format.default_track() {
        Some(r) => r,
        None => return Err(eyre::eyre!("Could not get default track".to_string())),
    };

    let samples_capacity = track.codec_params.n_frames.unwrap_or(0) as f64;
    let sample_rate = track.codec_params.sample_rate.unwrap_or(44100) as f64;

    let decoder_opts: DecoderOptions = Default::default();
    let mut decoder = match get_codecs().make(&track.codec_params, &decoder_opts) {
        Ok(r) => r,
        Err(e) => return Err(eyre::eyre!(format!("Decoder creation error: {e}"))),
    };

    if samples_capacity > 0.0 {
        let duration_in_desciseconds = samples_capacity / sample_rate * 10.0;
        return Ok(duration_in_desciseconds);
    }

    let mut total_samples = 0u64;

    loop {
        let packet = match probed.format.next_packet() {
            Ok(packet) => packet,
            Err(symphonia::core::errors::Error::ResetRequired) => {
                decoder.reset();
                continue;
            }
            Err(symphonia::core::errors::Error::IoError(ref e))
                if e.kind() == std::io::ErrorKind::UnexpectedEof =>
            {
                break;
            }
            Err(e) => {
                return Err(eyre::eyre!(format!("Packet error: {e}")));
            }
        };

        match decoder.decode(&packet) {
            Ok(decoded) => {
                total_samples += decoded.capacity() as u64;
            }
            Err(symphonia::core::errors::Error::DecodeError(_)) => {
                continue;
            }
            Err(e) => {
                return Err(eyre::eyre!(format!("Decode error: {e}")));
            }
        }
    }

    let duration_in_desciseconds = total_samples as f64 / sample_rate * 10.0;

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

        match get_sound_length(&path_string) {
            Ok(duration) => {
                successes.write_list_index(*path_value, duration)?;
            }
            Err(e) => {
                errors.write_list_index(*path_value, e.to_string())?;
            }
        };
    }

    let mut out = ByondValue::new_list()?;
    out.write_list_index(ByondValue::try_from("successes")?, successes)?;
    out.write_list_index(ByondValue::try_from("errors")?, errors)?;

    Ok(out)
}
