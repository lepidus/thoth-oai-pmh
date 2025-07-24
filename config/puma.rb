# frozen_string_literal: true

# Puma configuration for production

# Number of workers (auto-detect based on CPU cores if not set)
workers ENV.fetch('WEB_CONCURRENCY', 2)

# Min and Max threads per worker
threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
threads threads_count, threads_count

# Preload the application before forking worker processes
preload_app!

# Bind to all interfaces in production
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 4567)}"

# Environment
environment ENV.fetch('RACK_ENV', 'production')

# Restart command
restart_command '/usr/local/bundle/bin/puma'

# Logging - send to stdout/stderr for container logging
stdout_redirect '/dev/stdout', '/dev/stderr', true

# Worker timeout for slow requests
worker_timeout 60

# Worker boot timeout
worker_boot_timeout 30

# Worker shutdown timeout
worker_shutdown_timeout 30

# Allow puma to be restarted by restart command
plugin :tmp_restart

# Graceful shutdown
on_worker_boot do
  # Worker specific setup
end

before_fork do
  # Server specific setup before forking workers
end
