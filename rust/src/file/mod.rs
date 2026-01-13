use std::{
    fs::{File, OpenOptions},
    io::{BufRead, BufReader, BufWriter, Read, Write},
};

use byondapi::value::ByondValue;

#[byondapi::bind]
fn file_read(path: ByondValue) -> eyre::Result<ByondValue> {
    let path_string = path.get_string()?;
    let read_result = read(&path_string)?;
    Ok(read_result.try_into()?)
}

#[byondapi::bind]
fn file_exists(path: ByondValue) -> eyre::Result<ByondValue> {
    let path_string = path.get_string()?;
    let exists_result = exists(&path_string);
    Ok(exists_result.try_into()?)
}

#[byondapi::bind]
fn file_write(data: ByondValue, path: ByondValue) -> eyre::Result<ByondValue> {
    let path_string = path.get_string()?;
    let data_string = data.get_string()?;
    let write_result = write(&data_string, &path_string)? as f32;
    Ok(write_result.try_into()?)
}

#[byondapi::bind]
fn file_append(data: ByondValue, path: ByondValue) -> eyre::Result<ByondValue> {
    let path_string = path.get_string()?;
    let data_string = data.get_string()?;
    let append_result = append(&data_string, &path_string)? as f32;
    Ok(append_result.try_into()?)
}

#[byondapi::bind]
fn file_get_line_count(path: ByondValue) -> eyre::Result<ByondValue> {
    let path_string = path.get_string()?;
    let line_count_result = get_line_count(&path_string)?.to_string();
    Ok(line_count_result.try_into()?)
}

#[byondapi::bind]
fn file_seek_line(path: ByondValue, line: ByondValue) -> eyre::Result<ByondValue> {
    let path_string = path.get_string()?;
    let line_string = line.get_string()?;
    let parsed_line = line_string.parse::<usize>()?;
    match seek_line(&path_string, parsed_line) {
        Some(content) => Ok(content.try_into()?),
        None => Ok(ByondValue::null()),
    }
}

fn read(path: &str) -> eyre::Result<String> {
    let file = File::open(path)?;
    let metadata = file.metadata()?;
    let mut file = BufReader::new(file);

    let mut content = String::with_capacity(metadata.len() as usize);
    file.read_to_string(&mut content)?;
    let content = content.replace('\r', "");

    Ok(content)
}

fn exists(path: &str) -> String {
    let path = std::path::Path::new(path);
    path.exists().to_string()
}

fn write(data: &str, path: &str) -> eyre::Result<usize> {
    let path: &std::path::Path = path.as_ref();
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent)?;
    }

    let mut file = BufWriter::new(File::create(path)?);
    let written = file.write(data.as_bytes())?;

    file.flush()?;
    file.into_inner()
        .map_err(|e| std::io::Error::new(e.error().kind(), e.error().to_string()))? // This is god-awful, but the compiler REFUSES to let me get an owned copy of `e`
        .sync_all()?;

    Ok(written)
}

fn append(data: &str, path: &str) -> eyre::Result<usize> {
    let path: &std::path::Path = path.as_ref();
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent)?;
    }

    let mut file = BufWriter::new(OpenOptions::new().append(true).create(true).open(path)?);
    let written = file.write(data.as_bytes())?;

    file.flush()?;
    file.into_inner()
        .map_err(|e| std::io::Error::new(e.error().kind(), e.error().to_string()))?
        .sync_all()?;

    Ok(written)
}

fn get_line_count(path: &str) -> eyre::Result<u32> {
    let file = BufReader::new(File::open(path)?);
    Ok(file.lines().count() as u32)
}

fn seek_line(path: &str, line: usize) -> Option<String> {
    let file = BufReader::new(File::open(path).ok()?);
    file.lines().nth(line).and_then(std::result::Result::ok)
}
