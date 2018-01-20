defmodule BatchProcessCoordinationWeb.Router do
  use BatchProcessCoordinationWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BatchProcessCoordinationWeb.Api do
    pipe_through :api
    scope "/v1", V1 do
      scope "/process" do
        resources "/", ProcessMaintenanceController, only: [:create, :delete, :index]

        scope "/batch_keys" do
          post "/", BatchKeyMaintenanceController, :create
          get "/:process_name", BatchKeyMaintenanceController, :index
        end
      end
    end
  end
end
