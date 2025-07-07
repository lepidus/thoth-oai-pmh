# Thoth OAI-PMH

OAI-PMH (Open Archives Initiative Protocol for Metadata Harvesting) server for Thoth Open Metadata.

## Installation

Install the dependencies:

```bash
bundle install
```

And run with:

```bash
ruby app.rb
```

View at: <http://localhost:4567>

## Development

Run with rerun code reloader:

```bash
rerun ruby app.rb
```

Or build and run docker image:

```bash
docker build -t thoth_oai_pmh .
docker run --name thoth_oai_pmh -p 4567:4567 thoth_oai_pmh
```

## Testing

Run tests with Rake:

```bash
bundle exec rake
```
