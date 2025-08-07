#!/usr/bin/env bash

# Exit on error
set -eo pipefail

# Echo output colors
GREEN='\033[0;32m'
COLOR_OFF='\033[0m'

# Method to displaying messages
_log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $@${COLOR_OFF}"
}

# Helper function to call mongoimport.
# First argument is the filename of the compressed json. The other arguments are the mongoimport arguments.
_mongoimport() {
    local filename=${1}
    local arguments=("${@:2}")
    gunzip --stdout "${filename}" | mongoimport --uri "mongodb://${MONGO_HOST}:${MONGO_PORT}/${DATABASE_NAME}" --username "${MONGO_USER}" --password "${MONGO_PASS}" --authenticationDatabase admin "${arguments[@]}"
}

# Helper function to call mongosh
_mongosh() {
    mongosh "${MONGO_HOST}:${MONGO_PORT}/${DATABASE_NAME}" --username "${MONGO_USER}" --password "${MONGO_PASS}" --authenticationDatabase admin "$@"
}

_mongoimport_add_json_to_collection() {
    local collection="${1}"
    local filename="${DATA_FOLDER}/${2}.gz"

    # Check if the JSON filename exists
    if [[ -f "${filename}" ]]; then
        # Add JSON data to the collection. Use mongoimport to create the collection and add data
        _mongoimport "${filename}" --collection ${collection} --jsonArray --upsert --upsertFields "_id"

        _log "'${filename}' is added to '${collection}'"
    else
        _log "Error: JSON file '$filename' not found."
        exit 1
    fi
}
