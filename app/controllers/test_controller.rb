class TestController < RageController::API
  def index
    SayHello.enqueue(name: "John", delay: 10)
    render json: { status: "enqueued" }
  end
end
