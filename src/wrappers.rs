#![allow(dead_code)]
#![allow(improper_ctypes)]
#![allow(unused_unsafe)]

use std::ffi::{CStr, CString};
use std::os::raw::c_char;

// Объявляем C-функции, которые лежат в нашей libmylib.so
#[link(name = "mylib")]
extern "C" {
    fn return_42() -> i32;
    fn create_file(filename: *const c_char);
    fn write_file(filename: *const c_char, data: *const c_char, length: usize);
    fn read_file(filename: *const c_char) -> *const c_char;
}

/// Возвращает 42
pub fn return_42_wrapper() -> i32 {
    unsafe { return_42() }
}

/// Создаёт (или обнуляет) файл
pub fn create_file_wrapper(filename: &str) {
    let c_filename = CString::new(filename).expect("CString::new failed");
    unsafe {
        create_file(c_filename.as_ptr());
    }
}

/// Записывает в файл `filename` строку `data`
pub fn write_file_wrapper(filename: &str, data: &str) {
    let c_filename = CString::new(filename).expect("CString::new failed");
    let c_data = data.as_bytes(); // &[u8]
    unsafe {
        write_file(
            c_filename.as_ptr(),
            c_data.as_ptr() as *const c_char,
            c_data.len(),
        );
    }
}

/// Читает файл `filename` в строку (макс. 4096 байт)
pub fn read_file_wrapper(filename: &str) -> String {
    let c_filename = CString::new(filename).expect("CString::new failed");
    let ptr = unsafe { read_file(c_filename.as_ptr()) };
    if ptr.is_null() {
        // Если не удалось открыть/прочесть файл — вернём пустую строку
        return String::new();
    }
    unsafe {
        // Преобразуем C-строку в String
        CStr::from_ptr(ptr).to_string_lossy().into_owned()
    }
}

