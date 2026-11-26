# Schoolbox Etherpad Lite with Redis

## Quickstart

Make a copy of `.env.example` and name it as `.env` and set the values

To run on your local machine just execute `docker-compose up -d` and visit http://localhost:9001 to see the Etherpad instance.

If you set a value for `ADMIN_PASSWORD` the admin dashboard will be enabled and it will be accessible via http://localhost:9001/admin

If you just want to run the container independently without `docker-compose` based from the image in docker hub repo you may use this command:

```
docker container run -it --rm --env API_KEY=<API_KEY> \
--env SESSION_KEY=<SESSION_KEY> \
--env NODE_ENV=<NODE_ENV> \
--env ADMIN_PASSWORD=<ADMIN_PASSWORD> \
--env TITLE=<TITLE> \
--env DB_TYPE=redis \
--env DB_HOST=<REDIS_HOST> \
--env DB_PORT=<REDIS_PORT> \
--env DB_NAME=<REDIS_DBNAME> \
-p 9001:9001 schoolbox/epl
```

Otherwise, you may also just build this image on your local first before executing the `docker container run` command like so:

```
 docker build -t <your-build-name> .
```

```
docker container run -it --rm --env API_KEY=<API_KEY> \
--env SESSION_KEY=<SESSION_KEY> \
--env NODE_ENV=<NODE_ENV> \
--env ADMIN_PASSWORD=<ADMIN_PASSWORD> \
--env TITLE=<TITLE> \
--env DB_TYPE=redis \
--env DB_HOST=<REDIS_HOST> \
--env DB_PORT=<REDIS_PORT> \
--env DB_NAME=<REDIS_DBNAME> \
-p 9001:9001 <your-build-name>
```

Once successful, you should be able to access http://localhost:9001

## Installed plugins

- ep_disable_chat
- ep_disable_change_author_name
- ep_headings2

Etherpad 3 ships the Redis driver, so it is no longer installed as a plugin.

## Environment Variables

- `TITLE` : Set the title of the etherpad lite instance. Defaults to `Etherpad`
- `ADMIN_PASSWORD` : If set, etherpad admin dashboard will be enabled
- `DEFAULT_PAD_TEXT` : Default text when creating a new pad
- `API_KEY` : The key that will be used in `APIKEY.txt`
- `SESSION_KEY` : The key that will be used in `SESSIONKEY.txt`
- `NODE_ENV` : Sets the instance environment. Defaults to `development`
- `EDIT_ONLY` : If true, pad creation can only be done via the API. Defaults to `true`
- `REQUIRE_SESSION` : If true, user must have a session to access pads. Defaults to `true`
