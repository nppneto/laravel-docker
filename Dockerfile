FROM php:7.4-fpm

# utilizando os argumentos criados no docker-compose.yml
ARG user
ARG uid

# Instalando dependências
RUN apt-get update && apt-get install && apt-get install apt-utils -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Instalando extensões do PHP
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets

# Pegando última versão do Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Criando usuário para rodar comandos do Composer e Artisan
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Instalando Nodejs e NPM
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install nodejs -y

# Limpando cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalando Redis (Opcional)
RUN pecl install -o -f redis && \
    rm -rf /tmp/pear && \
    docker-php-ext-enable redis

# Setando working dir
WORKDIR /var/www

USER $user