## Запуск локального сервера через докер

#### 1)Добавьте конфиги из `config/example` в `tools/docker/station/config`

#### 2)Выполните `./recreate.sh`

#### P.S
- Если сервер падает с ошибкой вида `library/std/src/sys/unix/time.rs Operation not permitted`, то необходимо переустановить докер, проблема в пакетах на хосте, либо запустить в `privileged` режиме
