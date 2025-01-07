#!/usr/bin/env bash
#
# Ensure SSL certificates are installed; should be run as root.
#
set -euo pipefail

# Required environment variables
: "${FQDN:?Environment variable FQDN is required but not set.}"
: "${ADMIN_EMAIL:?Environment variable ADMIN_EMAIL is required but not set.}"
: "${PRODUCTION:?Environment variable PRODUCTION is required but not set.}"

# Constants
CERT_DIR="/etc/letsencrypt/live/${FQDN}"
SSL_DIR="/etc/nginx/ssl"

# Functions
check_certificates() {
    if [[ -d "${CERT_DIR}" && -f "${CERT_DIR}/fullchain.pem" && -f "${CERT_DIR}/privkey.pem" ]]; then
        echo "Valid certificates already exist for ${FQDN}."
        exit 0
    fi
}

setup_user_and_group() {
    echo "Ensuring letsencrypt group and permissions..."
    groupadd -f letsencrypt || true
    usermod -aG letsencrypt www-data || true
}

install_certbot() {
    if command -v certbot &>/dev/null; then
        echo "Certbot is already installed, skipping installation."
        return
    fi
    echo "Installing Certbot and dependencies..."
    snap install core && snap refresh core
    snap install --classic certbot
}

get_certificates() {
    echo "Attempting to obtain certificates for ${FQDN}..."
    local certbot_mode=$([ "${PRODUCTION}" = "true" ] && echo "" || echo "--staging")
    certbot certonly \
        --standalone \
        -d "${FQDN}" \
        ${certbot_mode} \
        --non-interactive \
        --agree-tos \
        --email "${ADMIN_EMAIL}"
}

link_certificates() {
    echo "Linking certificates for Nginx..."
    mkdir -p "${SSL_DIR}"
    ln -sf "${CERT_DIR}/fullchain.pem" "${SSL_DIR}/hpk-fullchain.pem"
    ln -sf "${CERT_DIR}/privkey.pem" "${SSL_DIR}/hpk-privkey.pem"
    chown -R letsencrypt:www-data "${SSL_DIR}"
}

# Main Execution
check_certificates
setup_user_and_group
install_certbot
get_certificates
link_certificates

echo "SSL certificate setup completed successfully!"
