<h1 align="center">ENG</h1>

# What is it???

This is a small experiment that allows you to run some of the assembler code directly from Python.

## How to launch it?

Just use `make'!

You will initially need `nasm`, `ld` is usually pre-installed

```shell
sudo apt install nasm -y
```

```shell
make preset
make build
make start
```
Well, or like this:
```shell
make preset
make build 
python3 test.py
```
In addition, you need to activate `venv` in advance, but it's fast!
```shell
python3 -m venv venv
source venv/bin/activate
```

## Why did I do that?

I've been expanding my knowledge and capabilities that I can apply to real-world tasks. It's a stupid question.



<h1 align="center">RUS</h1>

# Что это???

Это небольшой эксперимент который позволяет запускать часть кода ассемблера прямо из Python

## Как его запускать?

Просто используйте `make`!

Вам изначально потребуется `nasm`, `ld` обычно предустановлен

```shell
sudo apt install nasm -y
```

```shell
make preset
make build
make start
```
Ну или вот так:
```shell
make preset
make build 
python3 test.py
```
Помимо того, вам надо заранее активировать `venv`, но это быстро!
```shell
python3 -m venv venv
source venv/bin/activate
```

## Зачем я это сделал?

Я расширял свои знания и возможности которые я могу применить на реальных задачах. Это глупый вопрос