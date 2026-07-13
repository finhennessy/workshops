#!/bin/bash
set -euo pipefail

NUM_USERS=30
SCRIPT_DIR="$(pwd)"
HTPASSWD_FILE="${SCRIPT_DIR}/htpasswd_file"
CREDENTIALS_FILE="${SCRIPT_DIR}/user-credentials.txt"

# trap "rm -f ${HTPASSWD_FILE}" EXIT

> "${CREDENTIALS_FILE}"

generate_password() {
  head -c 128 < /dev/urandom | LC_ALL=C tr -dc 'A-Za-z0-9' | head -c 16
}

# ensure htpasswd is installed
dnf install -y httpd-tools

echo "Creating htpasswd file with ${NUM_USERS} users..."
for i in $(seq 1 ${NUM_USERS}); do
  USERNAME="user${i}"
  PASSWORD=$(generate_password)
  echo "${USERNAME}:${PASSWORD}" >> "${CREDENTIALS_FILE}"
  if [ "$i" -eq 1 ]; then
    htpasswd -cbB "${HTPASSWD_FILE}" "${USERNAME}" "${PASSWORD}"
  else
    htpasswd -bB "${HTPASSWD_FILE}" "${USERNAME}" "${PASSWORD}"
  fi
done

echo "Created $(wc -l < "${HTPASSWD_FILE}") users in htpasswd file"
echo "Credentials saved to ${CREDENTIALS_FILE}"

echo ""
echo "Done. Users user1 through user${NUM_USERS} created."
echo "Credentials: ${CREDENTIALS_FILE}"
