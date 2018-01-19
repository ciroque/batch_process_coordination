defmodule BatchProcessCoordinationWeb.Router do
  use BatchProcessCoordinationWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BatchProcessCoordinationWeb do
    pipe_through :api
  end
end
