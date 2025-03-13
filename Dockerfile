# BUILD Phase 1 - Run Composer install
FROM composer:lts AS composer-compile

COPY . /app
WORKDIR /app

RUN composer install --ignore-platform-reqs --optimize-autoloader --no-dev --no-interaction --no-progress --prefer-dist

# BUILD Phase 2 - Compile static libacl
FROM alpine AS libacl-static-builder

RUN apk add --no-cache build-base autoconf automake libtool pkgconfig wget libc-dev

RUN wget http://download.savannah.gnu.org/releases/attr/attr-2.5.2.tar.gz && \
    tar xzf attr-2.5.2.tar.gz && \
    cd attr-2.5.2 && \
    ./configure --prefix=/usr --enable-static --disable-shared && \
    make && \
    make install && \
    ls /usr/lib | grep libattr.a

RUN wget http://nongnu.askapache.com/acl/acl-2.3.2.tar.gz && \
    tar xzf acl-2.3.2.tar.gz && \
    cd acl-2.3.2 && \
    ./configure --prefix=/usr --enable-static --disable-shared && \
    make && \
    make install && \
    ls /usr/lib | grep libacl.a

# BUILD Phase 3 - Compile with FrankenPHP
FROM dunglas/frankenphp:static-builder-1.4.4 AS frankenphp-static-builder

COPY --from=composer-compile /app /go/src/app/dist/app
COPY --from=libacl-static-builder /usr/lib/libattr.a /go/src/app/dist/static-php-cli/buildroot/lib/libattr.a
COPY --from=libacl-static-builder /usr/lib/libacl.a /go/src/app/dist/static-php-cli/buildroot/lib/libacl.a

WORKDIR /go/src/app

RUN EMBED=dist/app ./build-static.sh

# COPY file dari dalam container ke luar
# docker cp $(docker create --name static-app-tmp <NAMA IMAGE, DAN TAGNYA>):/go/src/app/dist/frankenphp-linux-x86_64 my-app ; docker rm static-app-tmp
