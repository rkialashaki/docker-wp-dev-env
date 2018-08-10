# docker-wp-dev-env

Simple docker-compose setup to enable rapid wordpress development.  
Makes backing up and porting your developed sites super easy by exposing the 
docker database `db_data` and wordpress `wp_data` volumes as a directory paths 
in the repo making them easy to move around and backup.

## Getting started

### 1. Build docker image
First clone the repo and build the docker image `wp-dev-env` using the
`build.sh` script.

```
git clone http://github.com/rkialashaki/docker-wp-dev-env.git
cd docker-wp-dev-env
./build.sh
```

This will build the base docker image with the package dependencies installed.
This image is meant to be used interactively at an ubuntu bash prompt, so the
docker image is built with this in mind.  

### 2. Run docker-compose
Our docker image includes nginx, php7.2, and redis, but we need a database for
wordpress to work with.  The default `docker-compose.yml` provides us an
environment with our `wp-dev-env` image and a standard mysql database.  

```
docker-compose up -d
```

Ensure the database is provisioned before moving on to the next steps.

```
docker-compose logs 
...
db_1         | 2018-08-10T21:51:57.849979Z 0 [Note] Beginning of list of non-natively partitioned tables
db_1         | 2018-08-10T21:51:58.131065Z 0 [Note] End of list of non-natively partitioned tables
```

### 3. Setup dev environment
Now our stack is running, we can attach to the bash session running in our
`wp-dev-env` container to complete our setup.

```
docker attach docker-wp-dev-env_wordpress_1
```

There is a helper script `resources/setup.sh` to get a default wordpress setup installed.  For the
first time, this script may take a few minutes to run as it installs wp-cli and
its dependencies from source.  Please read through this script.  You can make
changes to the environment variables defined for you wordpress environment.  If
you make changes to the `$URL` variable, you may also need to change the nginx
config `resources/nginx/wordpress-nginx.conf` to match your `server_name`.  

```
./resources/setup.sh
```

This will install wp-cli from source and use it to bootstrap an installation of
wordpress using the default database in the compose stack.  It sets up nginx,
php-fpm, and redis for you, but you can modify it to fit your needs.

### 4. Start developing
You can find your wordpress install in the container at
`/home/wp/wordpress/public`.

You can navigate to your site in your browser http://127.0.0.1:8000

## Backing up and restoring
To backup your site, simply tar up your `db_data` and `wp_data`
directories.  

To restore a backup, simply untar your backups to the `db_data` and `wp_data`
directories.

To start from scratch, simply remove the `db_data` and `wp_data` direcotry
contents

```
rm -rf {wp,db}_data/*
```
