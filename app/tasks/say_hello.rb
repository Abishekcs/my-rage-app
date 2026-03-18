class SayHello
  include Rage::Deferred::Task

  def perform(name:)
    sleep 5
    Rage.logger.info "Hello, #{name}"
  end
end
