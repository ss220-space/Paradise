## Описание
Это self-hosted версия TTS сервера на основе моделей Silero. Совместима с билдом на момент 14.08.2023

Модели Silero предоставлены https://github.com/snakers4/silero-models/tree/master

## Требования

Python 3.11.+ (версии ниже не проверял, просьба отписаться об этом.)

- ffmpeg
- torch
- soundfile
- pydub
- flask

Подробнее в `requirements.txt`
## Установка

Воспользуйтесь в командной строке `pip install -r requirements.txt`

## Как пользоваться

Включите в конфигурации билда в `config.txt` (раскоменнтируйте следующее):
`TTS_TOKEN_SILERO mytoken` (токен не важен, он не используется)
`TTS_ENABLED`
`TTS_CACHE` 

Запустите `tts_server.py` через bat файл `launch_server.bat` или воспользуйтесь командной строкой и введите `python tts_server.py`.
Будет выведен адрес сервеа и номер порта для подключения к API, заполните файл `sensitive.dm` в строчке 
`GLOBAL_REAL_VAR(tts_url_silero) = ...` и введите заместо `...` полученные данные, например
`GLOBAL_REAL_VAR(tts_url_silero) = "http://127.0.0.1:5000/tts/"`