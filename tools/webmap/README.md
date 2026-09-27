# WebMap

Статическая вебкарта станций на Leaflet — наш аналог SS13WebMap. Тайлы режутся из
полноразмерных рендеров `.dmm`, страницы отдаёт nginx, обновление ночным workflow.

## Из чего состоит

| Файл | Что делает |
|---|---|
| `maps.json` | Реестр карт: ключ, имена, путь к `.dmm`, список z-уровней |
| `render.sh` | Рендер всех карт в полном разрешении (32 px на турф) |
| `build.py` | Нарезка пирамиды тайлов + генерация страниц |
| `template/` | Шаблоны страниц и стили |

Рендерит апстримный `dmm-tools` из SpacemanDMM. Ставится как `dreamchecker` и
`dmdoc` — скриптом `tools/ci/install_dmm_tools.sh`, версия берётся из
`SPACEMANDMM_TAG` в `_build_dependencies.sh`.

Форк `tools/github-actions/nanomap-renderer` здесь НЕ подходит: он рисует только
турфы, без мебели, машин и прочих объектов. Для внутриигровых наномап это и нужно,
для вебкарты — нет.

Под Windows можно проверять локально: в релизе лежит `dmm-tools.exe`. Рендер
отдельного участка:

```bash
dmm-tools.exe minimap --min 200,75,1 --max 220,95,1 -o out _maps/map_files/Delta/delta.dmm
```

Имена выходных файлов у двух рендереров разные (`delta-1.png` против
`delta_nanomap_z1.png`), `build.py` понимает оба.

## Локальная сборка

```bash
python tools/webmap/build.py --renders icons/_nanomaps --out dist/webmap --skip-missing
python -m http.server 8777 --directory dist/webmap
```

Наномапы из `icons/_nanomaps` ужаты до 2040 px, поэтому счётчик координат в углу
покажет неверные значения — для проверки вёрстки это неважно, в CI рендер полный.

## Добавить карту

1. Дописать запись в `maps.json` (ключ = имя каталога в URL).
2. Прописать `webmap_url = "https://webmap.wiki-ss13.space/<ключ>/"` в датуме карты.

Имя PNG рендерер составляет из имени `.dmm`, а не из ключа — `build.py` это учитывает.

## Сервер

```
/var/www/webmap/          — корень сайта, сюда rsync-ит workflow
/etc/nginx/sites-available/webmap.wiki-ss13.space
```

Конфиг nginx:

```nginx
server {
    listen 80;
    server_name webmap.wiki-ss13.space;

    root /var/www/webmap;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location /leaflet/ {
        expires 30d;
        add_header Cache-Control "public";
    }

    location ~* /tiles/.*\.png$ {
        expires 7d;
        add_header Cache-Control "public";
        access_log off;
    }
}
```

TLS выпускается после появления DNS-записи:

```bash
certbot --nginx -d webmap.wiki-ss13.space
```

## Деплой из CI

`.github/workflows/render_webmap.yml` собирает карту каждую ночь и, если заданы
секреты, заливает её по rsync. Без секретов шаг деплоя пропускается, а сборка
остаётся artifact'ом — её можно скачать и залить руками.

Нужные секреты репозитория:

| Секрет | Значение |
|---|---|
| `WEBMAP_HOST` | IP VDS |
| `WEBMAP_PORT` | порт SSH |
| `WEBMAP_USER` | `webmap` |
| `WEBMAP_DEPLOY_KEY` | приватный ключ пользователя `webmap` |

Пользователь `webmap` не root: пишет только в `/var/www/webmap`.
