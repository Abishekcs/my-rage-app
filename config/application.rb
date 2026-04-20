require "bundler/setup"
require "rage"
require "active_support/core_ext/integer/time"
require "./app/tasks/say_hello"
Bundler.require(*Rage.groups)

require "rage/all"

Rage.configure do
  config.deferred.schedule do
    every 1.minute, task: SayHello
  end
  # use this to add settings that are constant across all environments
end

require "rage/setup"
