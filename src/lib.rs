use pyo3::prelude::*;
use pyo3::wrap_pyfunction;

mod wrappers;  // <-- наш файл с Rust-обёртками над C-функциями

// Импортируем функции из wrappers
use wrappers::{
    return_42_wrapper,
    create_file_wrapper,
    write_file_wrapper,
    read_file_wrapper,
};

// 1. Описываем Python-функции
#[pyfunction]
fn py_return_42() -> PyResult<i32> {
    Ok(return_42_wrapper())
}

#[pyfunction]
fn py_create_file(filename: String) -> PyResult<()> {
    Ok(create_file_wrapper(&filename))
}

#[pyfunction]
fn py_write_file(filename: String, data: String) -> PyResult<()> {
    Ok(write_file_wrapper(&filename, &data))
}

#[pyfunction]
fn py_read_file(filename: String) -> PyResult<String> {
    Ok(read_file_wrapper(&filename))
}

// 2. Собираем их в модуль
#[pymodule]
fn mylib_wrapper(_py: Python, m: &PyModule) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(py_return_42, m)?)?;
    m.add_function(wrap_pyfunction!(py_create_file, m)?)?;
    m.add_function(wrap_pyfunction!(py_write_file, m)?)?;
    m.add_function(wrap_pyfunction!(py_read_file, m)?)?;
    Ok(())
}

