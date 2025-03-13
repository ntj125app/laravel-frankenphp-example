# BUILD Phase 1 - Run Composer install
FROM composer:lts AS composer-compile

COPY . /app
WORKDIR /app

RUN composer install --ignore-platform-reqs --optimize-autoloader --no-dev --no-interaction --no-progress --prefer-dist

# BUILD Phase 2 - Compile with FrankenPHP
FROM dunglas/frankenphp:static-builder AS frankenphp-static-builder

COPY --from=composer-compile /app /go/src/app/dist/app

WORKDIR /go/src/app
RUN EMBED=dist/app \
    PHP_EXTENSIONS=apcu,bcmath,calendar,ctype,curl,dom,exif,fileinfo,filter,gd,iconv,intl,mbregex,mbstring,mysqlnd,opcache,openssl,pcntl,pdo,pdo_mysql,phar,posix,readline,redis,session,sockets,sodium,sqlite3,ssh2,tokenizer,uuid,xml,xsl,yaml,zip,zlib,zstd \
    PHP_EXTENSION_LIBS=bzip2,freetype,libavif,libjpeg,liblz4,libwebp,libzip,curl,icu,libiconv,libpng,libsodium,libxml2,openssl,postgresql,readline,zlib,zstd,onig,libxslt,libssh2,nghttp2 \
    ./build-static.sh

# COPY file dari dalam container ke luar
# docker cp $(docker create --name static-app-tmp <NAMA IMAGE, DAN TAGNYA>):/go/src/app/dist/frankenphp-linux-x86_64 my-app ; docker rm static-app-tmp
