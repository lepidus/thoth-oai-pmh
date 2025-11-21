# Thoth OAI-PMH

OAI-PMH (Open Archives Initiative Protocol for Metadata Harvesting) server for Thoth Open Metadata.

## Getting Started

### Running with Docker (Development)

```
docker compose -f docker-compose.dev.yml build
docker compose -f docker-compose.dev.yml up
```

### Running with Docker (Production)

```
docker compose build
docker compose up
```

### Running with Ruby (Development)

```
bundle install
rerun ruby app.rb
```

### Running with Ruby (Production)

```
bundle install
bundle exec puma -C config/puma.rb
```

## Testing

Run tests with Rake:

```
bundle exec rake
```
