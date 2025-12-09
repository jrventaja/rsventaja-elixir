# Use the same base image as production
FROM bitwalker/alpine-elixir-phoenix:1.14

# Install additional build dependencies needed for native compilation
# Also install Tesseract OCR, Portuguese language pack, and poppler-utils for PDF to image conversion
RUN apk add --no-cache \
    gcc \
    g++ \
    make \
    libc-dev \
    tesseract-ocr \
    tesseract-ocr-data-por \
    poppler-utils \
    git \
    inotify-tools \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Install Hex and Rebar globally
RUN mix do local.hex --force, local.rebar --force

# Set MIX_ENV to dev for development
ENV MIX_ENV=dev

# Keep container running for dev container usage
CMD ["sleep", "infinity"]




