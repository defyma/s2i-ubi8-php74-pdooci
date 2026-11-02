PHP 7.4 UBI8 s2i image + OCI8/PDO_OCI
=====================================

Base: [`registry.access.redhat.com/ubi8/php-74`](https://catalog.redhat.com/software/containers/ubi8/php-74/5f521244e05bbcd88f128b63) (RHEL 8.10, s2i)
plus Oracle Instant Client 21, `oci8` 2.2.0, and `pdo_oci` (from php-src 7.4.33).

Replaces [`defyma/s2i-fedora34-php74-pdooci`](https://github.com/defyma/s2i-fedora34-php74-pdooci). That image is based on Fedora 34, which is EOL.
LibreOffice is intentionally not installed.

Docker Hub: `defyma/s2i-ubi8-php74-pdooci` (linux/amd64)

| Tag          | UBI8 php-74 base | Instant Client |
|--------------|------------------|----------------|
| `1792860909` | `1792860909`     | 21.24          |
| `latest`     | latest build     |                |

s2i container: please refer to https://github.com/sclorg/s2i-php-container

Build & Push
------------
```
./build.sh                 # default UBI tag 1792860909
./build.sh <ubi8-tag>      # rebuild on a newer ubi8/php-74 tag (CVE patch)
```
`build.sh` builds the image, checks that `oci8` and `PDO_OCI` load, and then pushes `:<ubi8-tag>` and `:latest`.

Run
---
```
docker run --mount type=bind,src=/your/path/www/,dst=/opt/app-root/src -p 8080:8080 -it defyma/s2i-ubi8-php74-pdooci /usr/libexec/s2i/run
```

Enter Bash
----------
```
docker run --mount type=bind,src=/your/path/www/,dst=/opt/app-root/src -p 8080:8080 -it defyma/s2i-ubi8-php74-pdooci bash
```

Notes
-----
- At build time, `dnf update` pulls the latest httpd/openssl/php packages. Running it resets the s2i permissions (e.g. `/run/httpd` becomes `0710`),
  so the Dockerfile restores them; otherwise httpd fails to start as UID 1001 or an arbitrary OpenShift UID.
- The `pdo_oci` source comes from `git archive php-7.4.33 ext/pdo_oci`.
