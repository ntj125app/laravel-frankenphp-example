# BUILD Phase 1 - Run Composer install
FROM composer:lts AS composer-compile

COPY . /app
WORKDIR /app

RUN composer install --ignore-platform-reqs --optimize-autoloader --no-dev --no-interaction --no-progress --prefer-dist

# BUILD Phase 2 - Compile with FrankenPHP
FROM dunglas/frankenphp:static-builder-1.4.4 AS frankenphp-static-builder

COPY --from=composer-compile /app /go/src/app/dist/app

# Add missing dependencies
RUN apk add --no-cache acl-static attr-static && \
    cp /usr/lib/libacl.a /go/src/app/dist/static-php-cli/buildroot/lib/libacl.a && \
    cp /usr/lib/libattr.a /go/src/app/dist/static-php-cli/buildroot/lib/libattr.a

WORKDIR /go/src/app

RUN EMBED=dist/app ./build-static.sh

# COPY file dari dalam container ke luar
# docker cp $(docker create --name static-app-tmp <NAMA IMAGE, DAN TAGNYA>):/go/src/app/dist/frankenphp-linux-x86_64 my-app ; docker rm static-app-tmp
