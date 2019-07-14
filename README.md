# docker plex
This is a Dockerfile to set up ([https://plex.tv/](https://plex.tv/) "Plex Media Server") - ([https://plex.tv/](https://plex.tv/))

All scripts and code is closely based on timhaak's containers.
[https://github.com/timhaak/docker-plexpass](https://github.com/timhaak/docker-plexpass)
[https://github.com/timhaak/docker-plex](https://github.com/timhaak/docker-plex)

## Instructions
### Getting the docker image
Build from docker file

```
git clone git@github.com:neclimdul/docker-plex.git
cd docker-plex
docker build -t neclimdul/docker-plex:plex Plex
```

You can also obtain it via:

```
docker pull neclimdul/docker-plex:plex
```
or

```
docker pull neclimdul/docker-plex:plex-pass
```

### Running the docker image
Instructions to run:

```
docker rm -f plex
docker run --restart=always -d --name plex -h *your_host_name* -v /*your_config_location*:/config -v /*your_videos_location*:/data -p 32400:32400 neclimdul/docker-plex
```

When the container starts, it will initialize the config directory and the configuration is populated through [environment variables](#environment-variables) that can be set using the command line or an envfile.

Browse to `http://*ipaddress*:32400/web` to run through the setup wizard.

By default, unauthenticated web access will only be available from the host machine and so to configure authentication for external access you will need a web browser on your host machine. If this is unavailable or you would like to have unauthenticated access from your LAN, then you can set the `PLEX_ALLOWED_NETWORKS` [environment variable](#environment-variables) to the subnet of your LAN either temporarily for configuration or permenantly for unauthenticated LAN access.

#### Avahi Auto Detection
For auto detection to work add --net="host". Though be aware this more insecure and not best practice with docker images. The only reason for doing it is to allow Avahi to work (as it uses broadcasts that will not cross network boundries).

See the [Docker Networking Article](https://docs.docker.com/articles/networking/#how-docker-networks-a-container) for details on how docker networks a container.

```
docker rm -f plex
docker run --restart=always -d --name plex --net="host" -h *your_host_name* -v /*your_config_location*:/config -v /*your_videos_location*:/data neclimdul/docker-plex
```

## Configuration
### Environment Varaibles

Variable Name         | Values               | Behaviour
--------------------  | -------------------- | -----------------------------------------------------------------------------------
    SKIP_CHOWN_CONFIG | `TRUE` or `FALSE`    | Startup will be faster and there won't be a permissions check for the configuration
        PLEX_USERNAME | String               | Will add this Plex Media Server to that account
        PLEX_PASSWORD | String               | (Mandatory if username is set) The account password
           PLEX_TOKEN | [Plex token][1]      | Plex token if you don't want to write your password
    PLEX_EXTERNALPORT | Integer              | The port if you're not using the default one (32400), ie. when using `-p 80:34200`
PLEX_DISABLE_SECURITY | `0` or `1`           | If set to 1, the remote security will be disabled
          RUN_AS_ROOT | `TRUE` or `FALSE`    | *Dangerous* If true, will start Plex as root
PLEX_ALLOWED_NETWORKS | Comma-separated list | List of networks to allow access to. Defaults to the docker network (public Plex)

To use an option, set it as a Docker environment variable through the command line:

```
docker run -e RUN_AS_ROOT=TRUE ... neclimdul/docker-plex:plex
```

or add it to an envfile that can be included through the command line:

```
docker run --envfile=*filename* ... neclimdul/docker-plex:plex
```

[1]: https://support.plex.tv/hc/en-us/articles/204059436-Finding-your-account-token-X-Plex-Token
