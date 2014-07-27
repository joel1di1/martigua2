# require 'delayed_job'
# require 'heroku-api'

# class JobAutoScale < Delayed::Plugin

#   def self.workers! quantity
#     if Rails.env.production?
#       heroku = Heroku::API.new(:username => ENV['HEROKU_USER'], :password => ENV['HEROKU_PWD'])
#       heroku.post_ps_scale(ENV['HEROKU_APP_NAME'], 'worker', quantity)
#     end
#   end

#   def self.scale_workers_down!
#     self.workers! 0 unless Delayed::Job.count > 1
#   end

#   callbacks do |lifecycle|
#     lifecycle.around(:invoke_job) do |worker, &block|
#       block.call(worker)
#       JobAutoScale.scale_workers_down!
#     end
#   end
# end

# module Delayed
#   class DelayProxy < Delayed::Compatibility.proxy_object_class
#     def method_missing(method, *args)
#       Job.enqueue({:payload_object => @payload_class.new(@target, method.to_sym, args)}.merge(@options))
#       ::JobAutoScale.workers! 1
#     end
#   end
  
# end


# Delayed::Worker.plugins << JobAutoScale
