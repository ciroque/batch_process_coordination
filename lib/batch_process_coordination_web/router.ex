defmodule BatchProcessCoordinationWeb.Router do
  use BatchProcessCoordinationWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BatchProcessCoordinationWeb.Api do
    pipe_through :api
    scope "/v1", V1 do
      scope "/process" do
        resources "/", ProcessController, only: [:create, :delete, :index]

        scope "/batch_keys" do
          delete "/:external_id", BatchKeyController, :delete
          get "/:process_name", BatchKeyController, :index
          post "/", BatchKeyController, :create
        end
      end
    end
  end
end
