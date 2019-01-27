#!/usr/bin/env ruby

# Usage:
# > ruby gem_auto_update.rb

# try to update everything

def log(msg)
  puts "=== #{msg}\n"
end

def exec_system(cmd, desc: nil)
  _exec(cmd, desc: nil, mode: :system)
end

def exec_thick(cmd, desc: nil)
  _exec(cmd, desc: nil, mode: :thick)
end

def _exec(cmd, desc: nil, mode:)
  log("execute `#{cmd}` (using #{mode} mode) -- #{desc}")
  mode == :thick ? `#{cmd}` : system(cmd)
end

def update_test_and_commit(gem_name: nil)
  if exec_system "bundle update #{gem_name}"
    if exec_system 'git diff-index --quiet HEAD', desc: 'check if any modification'
      log("no modification, do not update #{gem_name || 'all'}")
      true
    else
      if exec_system "bundle exec rspec", desc: 'run tests'
        exec_system 'git add Gemfile.lock'
        exec_system "git commit -m 'auto update #{gem_name || 'all'}'"
        true
      else
        log("error, do not update #{gem_name || 'all'}")
        exec_system 'git checkout Gemfile.lock', desc: 'Revert Gemfile.lock'
        false
      end
    end
  end
end

exec_system 'git checkout Gemfile.lock'
exec_system 'bundle update'

if update_test_and_commit
  log 'Bundle update successful, stop here'
end

bundle_outdated_result = exec_thick 'bundle outdated'
gem_names = bundle_outdated_result.split("\n").map { |s| /^\s*\*\s([^\s]*)/.match(s)&.send(:[], 1) }.compact

gem_names.each do |gem_name|
  exec_system 'git checkout Gemfile.lock'
  update_test_and_commit(gem_name: gem_name)
end
