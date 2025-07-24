# Multi-stage build for production optimization
FROM ruby:3.4.4-alpine AS base

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    git \
    tzdata \
    wget \
    && rm -rf /var/cache/apk/*

# Create app user for security
RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

WORKDIR /app

# Development stage
FROM base AS development
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
RUN chown -R appuser:appgroup /app
USER appuser
EXPOSE 4567
CMD ["rerun", "ruby", "app.rb", "--background", "--", "-o", "0.0.0.0"]

# Production stage
FROM base AS production

# Copy and install production gems only
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment true && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3 && \
    bundle clean --force && \
    rm -rf /usr/local/bundle/cache/*.gem && \
    find /usr/local/bundle -name "*.c" -delete && \
    find /usr/local/bundle -name "*.o" -delete

# Copy application code
COPY . .

# Remove unnecessary files for production
RUN rm -rf tests/ \
    Rakefile \
    DOCKER.md \
    README.md \
    docker-compose.yml \
    .git* \
    *.md

# Change ownership to app user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Set production environment
ENV RACK_ENV=production
ENV RAILS_ENV=production

EXPOSE 4567

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:4567/oai?verb=Identify || exit 1

# Use Puma for production
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]