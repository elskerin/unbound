# unofficial unbound multiarch docker image

[![Gitlab pipeline status](https://img.shields.io/gitlab/pipeline/klutchell/unbound?style=flat-square)](https://gitlab.com/klutchell/unbound/pipelines)
[![Docker Pulls](https://img.shields.io/docker/pulls/klutchell/unbound.svg?style=flat-square)](https://hub.docker.com/r/klutchell/unbound/)
[![Docker Stars](https://img.shields.io/docker/stars/klutchell/unbound.svg?style=flat-square)](https://hub.docker.com/r/klutchell/unbound/)

[Unbound](https://unbound.net/) is a validating, recursive, and caching DNS resolver.

## Architectures

The architectures supported by this image are:

- `linux/amd64`
- `linux/arm64`
- `linux/ppc64le`
- `linux/s390x`
- `linux/arm/v7`
- `linux/arm/v6`

Simply pulling `klutchell/unbound` should retrieve the correct image for your arch.

## Build

```bash
# build a local image
docker build . -t klutchell/unbound

# cross-build for another platform (eg. arm32v6)
export DOCKER_CLI_EXPERIMENTAL=enabled
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --use --driver docker-container
docker buildx build . --platform linux/arm/v6 --load -t klutchell/unbound
```

## Test

```bash
# run selftest on local image
docker run --rm -d --name unbound klutchell/unbound
docker exec unbound unbound-anchor -v
docker exec unbound drill -p 5053 nlnetlabs.nl @127.0.0.1
docker stop unbound
```

## Usage

NLnet Labs documentation: <https://nlnetlabs.nl/documentation/unbound/>

```bash
# print general usage
docker run --rm klutchell/unbound -h

# run a recursive dns server on host port 53
docker run -p 53:5053/tcp -p 53:5053/udp klutchell/unbound

# run unbound server with configuration mounted from a host directory
docker run --name unbound -p 53:5053/udp -v /path/to/config:/opt/unbound/etc/unbound klutchell/unbound

# generate a root trust anchor for DNSSEC validation
# assumes your existing container is named 'unbound' as in the example above
docker exec unbound unbound-anchor -v
```

Please note the following if you are using a custom configuration file:

- `chroot` and `username` are not supported as the service is already running as `nobody:nogroup`
- `auto-trust-anchor-file` should be omitted or set to `root.key`
- any additional paths should be relative to `/var/run/unbound`

## Author

Kyle Harding: <https://klutchell.dev>

## Contributing

Please open an issue or submit a pull request with any features, fixes, or changes.

<https://gitlab.com/klutchell/unbound/issues>

## Acknowledgments

Original software is by NLnet Labs: <https://github.com/NLnetLabs/unbound>

## Licenses

- klutchell/unbound: [MIT License](https://gitlab.com/klutchell/unbound/blob/master/LICENSE)
- unbound: [BSD 3-Clause "New" or "Revised" License](https://github.com/NLnetLabs/unbound/blob/master/LICENSE)
