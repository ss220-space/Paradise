use byondapi::value::ByondValue;
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
    // Try to open the file
    let sound_src = match File::open(sound_path) {
        Ok(r) => r,
        Err(e) => return Err(eyre::eyre!(format!("Couldn't open file, {e}"))),
    };

    // Audio probe things
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

    match sound_length_simple(&probed) {
        Ok(r) => return Ok(r as f32),
        Err(_e) => (),
    };

    match sound_length_decode(probed) {
        Ok(r) => Ok(r as f32),
        Err(e) => Err(e),
    }
}

fn sound_length_simple(probed: &ProbeResult) -> eyre::Result<f64> {
    let format = &probed.format;

    let track = match format.default_track() {
        Some(r) => r,
        None => return Err(eyre::eyre!("Could not get default track".to_string())),
    };

    let time_base = match track.codec_params.time_base {
        Some(r) => r,
        None => {
            return Err(eyre::eyre!(
                "Codec does not provide a time base.".to_string()
            ))
        }
    };

    let n_frames = match track.codec_params.n_frames {
        Some(r) => r,
        None => return Err(eyre::eyre!("Codec does not provide frame count".to_string())),
    };

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
    Ok(get_sound_length_list(list.get_list_values()?)?)
}

fn get_sound_length_list(list: Vec<ByondValue>) -> eyre::Result<ByondValue> {
    let mut successes = ByondValue::new_list()?;
    let mut errors = ByondValue::new_list()?;

    for path_value in &list {
        let path_string = path_value.get_string()?;
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
    out.write_list_index("successes", successes)?;
    out.write_list_index("errors", errors)?;

    Ok(out)
}
