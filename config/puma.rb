# frozen_string_literal: true

workers ENV.fetch('WEB_CONCURRENCY', 2)

threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
threads threads_count, threads_count

preload_app!

bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 4567)}"

environment ENV.fetch('RACK_ENV', 'production')

restart_command '/usr/local/bundle/bin/puma'

stdout_redirect '/dev/stdout', '/dev/stderr', true

worker_timeout 60

worker_boot_timeout 30

worker_shutdown_timeout 30

plugin :tmp_restart
