# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'tests'
  t.test_files = FileList['tests/**/test_*.rb']
  t.verbose = true
  t.ruby_opts = ['-W0']
end

task default: :test
