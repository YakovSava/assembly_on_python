import mylib_wrapper

# 1. Тестируем return_42
val = mylib_wrapper.py_return_42()
print("return_42 =", val)

# 2. Создадим файл
mylib_wrapper.py_create_file("test_file.txt")
print("Файл test_file.txt создан (или обнулён).")

# 3. Запишем что-то в файл
mylib_wrapper.py_write_file("test_file.txt", "Hello from Python + Rust + NASM!\n")
print("Данные записаны в test_file.txt.")

# 4. Прочитаем обратно
contents = mylib_wrapper.py_read_file("test_file.txt")
print("Содержимое файла:\n", contents)

