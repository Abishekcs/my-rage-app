Rage.routes.draw do
  root to: ->(env) { [200, {}, ["It works!"]] }
  get "/test", to: "test#index"
end
