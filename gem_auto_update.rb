#!/usr/bin/env ruby

bundle_outdated_result = `bundle outdated`
gem_names = bundle_outdated_result.split("\n").map{|s| /^\s*\*\s([^\s]*)/.match(s)&.send(:[], 1) }.compact

gem_names.each do |gem_name|
  puts "-- reset Gemfile.lock"
  system "git checkout Gemfile.lock"
  puts "-- bundle update #{gem_name}"
  if system "bundle update #{gem_name}"
    if system 'git diff-index --quiet HEAD'
      puts "no modification, do not update #{gem_name}"
    else
      puts '-- try bundle exec rspec'
      if system "bundle exec rspec"
        puts 'commit gem update'
        system 'git add Gemfile.lock'
        system "git commit -m 'auto update #{gem_name} gem'"
      else
        puts "error, do not update #{gem_name}"
      end
    end
  end
end
