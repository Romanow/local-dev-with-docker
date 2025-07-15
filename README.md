[![CI](https://github.com/Romanow/local-dev-with-docker/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/Romanow/local-dev-with-docker/actions/workflows/build.yml)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC%20BY--NC--ND%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

# Использование Docker Compose для разработки и тестирования

## Аннотация

Мы часто слышим, что Docker упрощает жизнь разработчиков и QA, но давайте разберемся, как им пользоваться в мире
микросервисов? Поговорим, как с помощью Docker Compose собирать, тестировать и даже отлаживать весь ваш микросервисный
зоопарк.

## План

1. Какую проблему мы хотим решить? (дать тестировщикам возможность локально запускать часть сервисов)
2. Новые возможности Docker Compose:
    * Health Check.
    * Порядок запуска сервисов.
    * Отслеживание локальных изменений с через `docker compose watch`.
3. Пример:
    * Использование Git Submodules для работы с конкретными ветками.
    * Secrets, Config и профили в Spring Boot.
    * Удаленная отладка (через `-agentlib`).
4. Выводы: что получилось и какие есть ограничения в этом решении.

## Доклад

### Использование Git Submodules

```shell
# первичное добавление сервисов
for module in person-service person-frontend; do
  git submodule add -b master --name modules/$module https://github.com/Romanow/$module.git modules/$module
done
```

```shell
# затягиваем изменения
$ git submodule update --init --remote

# собираем проект
$ ./build.sh

# собираем в docker
$ docker compose build

# запускаем в docker, открыть страницу http://localhost:8880
$ docker compose up -d --wait

# запускаем коллекцию для проверки
$ newman run --delay-request 100 -e tests/local.json tests/collection.json

# остановка сервисов
$ docker compose down -v
```
