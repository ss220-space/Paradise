use std::{
    fs::{File, OpenOptions},
    io::{BufRead, BufReader, BufWriter, Read, Write},
};

use meowtonin::{byond_fn, ByondError, ByondResult, ByondValue, ToByond};
use std::error::Error;

#[byond_fn]
fn file_read(path: ByondValue) -> ByondResult<ByondValue> {
    let path_string = path.get_string()?;
    let read_result = read(&path_string)?;
    read_result.to_byond()
}

#[byond_fn]
fn file_exists(path: ByondValue) -> ByondResult<ByondValue> {
    let path_string = path.get_string()?;
    let exists_result = exists(&path_string);
    exists_result.to_byond()
}

#[byond_fn]
fn file_write(data: ByondValue, path: ByondValue) -> ByondResult<ByondValue> {
    let path_string = path.get_string()?;
    let data_string = data.get_string()?;
    let write_result = write(&data_string, &path_string)? as f32;
    write_result.to_byond()
}

#[byond_fn]
fn file_append(data: ByondValue, path: ByondValue) -> ByondResult<ByondValue> {
    let path_string = path.get_string()?;
    let data_string = data.get_string()?;
    let append_result = append(&data_string, &path_string)? as f32;
    append_result.to_byond()
}

#[byond_fn]
fn file_get_line_count(path: ByondValue) -> ByondResult<ByondValue> {
    let path_string = path.get_string()?;
    let line_count_result = get_line_count(&path_string)?.to_string();
    line_count_result.to_byond()
}

#[byond_fn]
fn file_seek_line(path: ByondValue, line: ByondValue) -> ByondResult<ByondValue> {
    let path_string = path.get_string()?;
    let line_string = line.get_string()?;
    let parsed_line = line_string.parse::<usize>().map_err(ByondError::boxed)?;
    match seek_line(&path_string, parsed_line) {
        Some(content) => content.to_byond(),
        None => Ok(ByondValue::NULL),
    }
}

fn read(path: &str) -> ByondResult<String> {
    let file = File::open(path).map_err(ByondError::boxed)?;
    let metadata = file.metadata().map_err(ByondError::boxed)?;
    let mut file = BufReader::new(file);

    let mut content = String::with_capacity(metadata.len() as usize);
    file.read_to_string(&mut content)
        .map_err(ByondError::boxed)?;
    let content = content.replace('\r', "");

    Ok(content)
}

fn exists(path: &str) -> String {
    let path = std::path::Path::new(path);
    path.exists().to_string()
}

fn write(data: &str, path: &str) -> ByondResult<usize> {
    let path: &std::path::Path = path.as_ref();
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent).map_err(ByondError::boxed)?;
    }

    let mut file = BufWriter::new(File::create(path).map_err(ByondError::boxed)?);
    let written = file.write(data.as_bytes()).map_err(ByondError::boxed)?;

    file.flush().map_err(ByondError::boxed)?;

    let inner_file = match file.into_inner() {
        Ok(f) => f,
        Err(e) => {
            return Err(ByondError::Boxed(Box::<dyn Error + Send + Sync>::from(
                format!("Failed to flush buffer: {}", e.error()),
            )));
        }
    };

    inner_file.sync_all().map_err(ByondError::boxed)?;
    Ok(written)
}

fn append(data: &str, path: &str) -> ByondResult<usize> {
    let path: &std::path::Path = path.as_ref();
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent).map_err(ByondError::boxed)?;
    }

    let mut file = BufWriter::new(
        OpenOptions::new()
            .append(true)
            .create(true)
            .open(path)
            .map_err(ByondError::boxed)?,
    );
    let written = file.write(data.as_bytes()).map_err(ByondError::boxed)?;

    file.flush().map_err(ByondError::boxed)?;

    let inner_file = match file.into_inner() {
        Ok(f) => f,
        Err(e) => {
            return Err(ByondError::Boxed(Box::<dyn Error + Send + Sync>::from(
                format!("Failed to flush buffer: {}", e.error()),
            )));
        }
    };

    inner_file.sync_all().map_err(ByondError::boxed)?;
    Ok(written)
}

fn get_line_count(path: &str) -> ByondResult<u32> {
    let file = BufReader::new(File::open(path).map_err(ByondError::boxed)?);
    Ok(file.lines().count() as u32)
}

fn seek_line(path: &str, line: usize) -> Option<String> {
    let file = File::open(path).ok()?;
    let reader = BufReader::new(file);
    reader.lines().nth(line).and_then(Result::ok)
}
