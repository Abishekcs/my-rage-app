Rage.routes.draw do
  root to: ->(env) { [200, {}, ["It works!"]] }
  # Add test path to try out Backgournd job and WA
  get "/test", to: "test#index"
end
