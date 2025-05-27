# Use the kartoza/geoserver image as the base.
# The {ARCH} placeholder will be replaced by Home Assistant based on the system's architecture.
FROM kartoza/geoserver:{ARCH}-latest

# Set maintainer information for the add-on (optional but good practice).
LABEL maintainer="Your Name <your.email@example.com>"

# Copy the run.sh script into the container's /usr/bin directory.
# This script will be the entrypoint for our add-on.
COPY run.sh /usr/bin/run.sh

# Make the run.sh script executable.
RUN chmod a+x /usr/bin/run.sh

# Set the entrypoint for the Docker container to our run.sh script.
# This means when the container starts, it will execute run.sh.
ENTRYPOINT ["/usr/bin/run.sh"]

# Expose GeoServer's default port.
# This is largely for documentation as ports are defined in config.json.
EXPOSE 8080
