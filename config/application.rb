require "bundler/setup"
require "rage"
require "active_support/core_ext/integer/time"
require "./app/tasks/say_hello"
Bundler.require(*Rage.groups)

require "rage/all"

# config/application.rb or config/environments/<environment>.rb

# Rage.configure do
#   config.deferred.schedule do
#     every 1.hour, task: CleanupExpiredInvites
#     every 1.minute, task: ResetCache
#   end
# end

Rage.configure do
  config.deferred.schedule do
    every 1.minute, task: SayHello
    every 1.minute, task: 'SayHello101'
  end
  # use this to add settings that are constant across all environments
end

require "rage/setup"
