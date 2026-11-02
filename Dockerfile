# s2i-ubi8-php74-pdooci
# Base: Red Hat UBI8 PHP 7.4 (s2i) + Oracle Instant Client 21 + oci8 + pdo_oci.
# Pengganti defyma/s2i-fedora34-php74-pdooci(-libreoffice) yang base-nya Fedora 34 (EOL).
# LibreOffice sengaja tidak dipasang.

ARG UBI_TAG=1792860909
FROM registry.access.redhat.com/ubi8/php-74:${UBI_TAG}

ARG IC_VER=21.24.0.0.0-1
ARG IC_DIR=2124000
ARG IC_URL=https://download.oracle.com/otn_software/linux/instantclient/${IC_DIR}

LABEL maintainer="defyma85@gmail.com" \
      io.k8s.display-name="Apache 2.4 with PHP 7.4 + OCI8/PDO_OCI (UBI8)" \
      io.openshift.tags="builder,php,php74,oci8,pdo_oci"

USER 0

# Ambil patch terbaru untuk paket sensitif saat build (re-build = ikut patch CVE terbaru).
RUN dnf -y update httpd httpd-filesystem httpd-tools mod_ssl openssl openssl-libs 'php' 'php-*' \
 && dnf -y install --setopt=tsflags=nodocs php-devel php-pear gcc make libaio \
      ${IC_URL}/oracle-instantclient-basic-${IC_VER}.el8.x86_64.rpm \
      ${IC_URL}/oracle-instantclient-devel-${IC_VER}.el8.x86_64.rpm

COPY bahan/ /tmp/bahan/

RUN IC=/usr/lib/oracle/21/client64/lib \
 && cd /tmp/bahan/oci8-2.2.0 \
 && phpize && ./configure --with-oci8=instantclient,$IC && make -j"$(nproc)" && make install \
 && cd /tmp/bahan/pdo_oci-7.4.33 \
 && phpize && ./configure --with-pdo-oci=instantclient,$IC,21 && make -j"$(nproc)" && make install \
 && echo "extension=oci8"    > /etc/php.d/30-oci8.ini \
 && echo "extension=pdo_oci" > /etc/php.d/30-pdo_oci.ini \
 && dnf -y remove php-devel gcc make cpp \
 && dnf clean all \
 && cd / && rm -rf /tmp/bahan /var/cache/dnf \
 && php -m | grep -qx oci8 && php -m | grep -qx PDO_OCI

# dnf update httpd/php me-reset permission yang sebelumnya disiapkan s2i (mis. /run/httpd jadi 0710),
# akibatnya httpd gagal start sebagai UID 1001 / arbitrary UID OpenShift. Kembalikan seperti
# /usr/libexec/container-setup (script itu sendiri tidak idempotent, jadi tidak dipanggil ulang).
RUN chmod -R a+rwx ${HTTPD_MAIN_CONF_PATH} ${HTTPD_MAIN_CONF_D_PATH} ${HTTPD_VAR_RUN} ${APP_ROOT}/etc /tmp/sessions \
 && chmod a+rwx ${PHP_SYSCONF_PATH}/php.ini \
 && chmod -R a+rwx ${PHP_SYSCONF_PATH}/php.d \
 && chmod -R ug+r /etc/pki/tls/certs/localhost.crt /etc/pki/tls/private/localhost.key \
 && chown -R 1001:0 /etc/pki/tls/certs/localhost.crt /etc/pki/tls/private/localhost.key ${APP_ROOT} /tmp/sessions ${HTTPD_DATA_PATH} \
 && rpm-file-permissions

USER 1001
