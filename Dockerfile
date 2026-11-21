FROM nikhilbadyal/docker-py-revanced-base

# Copy and install Python dependencies
COPY requirements.txt .
# CloakBrowser ships its own Chromium, but Playwright still needs OS libraries in slim Docker images.
# Do not run CloakBrowser's Chromium installer during multi-arch builds because arm64 builds execute under QEMU and can segfault while probing the downloaded browser.
# Playwright's bundled node needs libatomic, which the base image lacks; without it `install-deps` fails to even start.
RUN apt-get update && \
    apt-get install -y --no-install-recommends libatomic1 && \
    rm -rf /var/lib/apt/lists/* && \
    python -m pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    python -m playwright install-deps chromium


# Copy entrypoint script
COPY ./entrypoint /entrypoint
RUN sed -i 's/\r$//g' /entrypoint && chmod +x /entrypoint

# Copy application code
COPY . ${APP_HOME}

# Set the default command to run the entrypoint script
CMD ["bash","/entrypoint"]
