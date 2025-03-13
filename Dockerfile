# BUILD Phase 1 - Run Composer install
FROM composer:lts AS composer-compile

COPY . /app
WORKDIR /app

RUN composer install --ignore-platform-reqs --optimize-autoloader --no-dev --no-interaction --no-progress --prefer-dist

# BUILD Phase 2 - Compile with FrankenPHP
FROM dunglas/frankenphp:static-builder AS frankenphp-static-builder

WORKDIR /go/src/app/dist/app

COPY --from=composer-compile /app /go/src/app/dist/app

WORKDIR /go/src/app
RUN EMBED=dist/app \
    PHP_EXTENSIONS=ctype,iconv,pdo_sqlite \
    ./build-static.sh

# COPY file dari dalam container ke luar
# docker cp $(docker create --name static-app-tmp <NAMA IMAGE, DAN TAGNYA>):/go/src/app/dist/frankenphp-linux-x86_64 my-app ; docker rm static-app-tmp
