#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: GeoServer
# This script configures and starts the GeoServer instance based on add-on options.
# ==============================================================================

# Define the persistent data directory path within the container.
# Home Assistant add-ons typically use /data for persistent storage.
PERSISTENT_DATA_PATH="/data/geoserver_data"

# --- Data Directory Persistence ---
# Check if the persistent GeoServer data directory exists. If not, create it.
if [ ! -d "${PERSISTENT_DATA_PATH}" ]; then
    bashio::log.info "Creating persistent GeoServer data directory: ${PERSISTENT_DATA_PATH}"
    mkdir -p "${PERSISTENT_DATA_PATH}"
fi

# Set the GEOSERVER_DATA_DIR environment variable.
# The kartoza/geoserver image uses this variable to determine where to store
# all GeoServer configurations, workspaces, layers, and uploaded data.
# If this directory is empty on the first run, the base image will copy
# its default data into it, ensuring a working initial setup.
export GEOSERVER_DATA_DIR="${PERSISTENT_DATA_PATH}"
bashio::log.info "GeoServer data directory set to: ${GEOSERVER_DATA_DIR}"

# --- Configure GeoServer Environment Variables from Add-on Options ---

# Retrieve GeoServer admin password from add-on options.
ADMIN_PASSWORD=$(bashio::config 'GEOSERVER_ADMIN_PASSWORD')
if [ -n "${ADMIN_PASSWORD}" ]; then
    export GEOSERVER_ADMIN_PASSWORD="${ADMIN_PASSWORD}"
    bashio::log.info "GeoServer admin password set from add-on options."
else
    bashio::log.warning "No GeoServer admin password provided in add-on options. Using default 'geoserver'."
fi

# Retrieve JVM memory limit from add-on options.
MEMORY_LIMIT_MB=$(bashio::config 'GEOSERVER_MEMORY_LIMIT_MB')
if [ -n "${MEMORY_LIMIT_MB}" ]; then
    # The kartoza/geoserver image typically uses JAVA_OPTS or EXTRA_JAVA_OPTS for JVM settings.
    # -Xms: initial heap size, -Xmx: maximum heap size.
    export JAVA_OPTS="-Xms256m -Xmx${MEMORY_LIMIT_MB}m"
    bashio::log.info "GeoServer JVM memory limit set to ${MEMORY_LIMIT_MB}MB."
fi

# Handle GeoServer extensions based on add-on options.
INSTALL_EXTENSIONS=$(bashio::config 'INSTALL_EXTENSIONS')
STABLE_EXTENSIONS=$(bashio::config 'STABLE_EXTENSIONS')

if bashio::config.true 'INSTALL_EXTENSIONS'; then
    export INSTALL_EXTENSIONS="true"
    if [ -n "${STABLE_EXTENSIONS}" ]; then
        export STABLE_EXTENSIONS="${STABLE_EXTENSIONS}"
        bashio::log.info "Installing stable GeoServer extensions: ${STABLE_EXTENSIONS}"
    else
        bashio::log.warning "INSTALL_EXTENSIONS is true but no STABLE_EXTENSIONS specified. No stable extensions will be installed."
    fi
else
    export INSTALL_EXTENSIONS="false"
    bashio::log.info "GeoServer extensions will not be installed."
fi

# --- Start GeoServer ---
bashio::log.info "Starting GeoServer..."
# The kartoza/geoserver image's original ENTRYPOINT is typically a script that
# processes these environment variables and then executes the Tomcat startup command.
# Since our `Dockerfile` sets `run.sh` as the `ENTRYPOINT`, we need to explicitly
# execute the command that starts GeoServer. For Tomcat-based GeoServer, this is
# usually `catalina.sh run`.
exec /usr/local/tomcat/bin/catalina.sh run
