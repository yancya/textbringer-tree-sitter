# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/test_*.rb"]
end

namespace :parsers do
  desc "Download prebuilt parsers for CI (ruby, hcl, markdown)"
  task :download do
    sh "bash scripts/download_parsers.sh ruby hcl markdown"
  end

  desc "Build parsers from source (HCL, Ruby)"
  task :build do
    sh "bash scripts/build_parsers.sh"
  end

  desc "Setup parsers for testing (downloads if available, falls back to build)"
  task :setup do
    sh "bash scripts/download_parsers.sh ruby hcl markdown || bash scripts/build_parsers.sh"
  end
end

task default: :test
