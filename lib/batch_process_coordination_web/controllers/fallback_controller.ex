defmodule BatchProcessCoordinationWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use BatchProcessCoordinationWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(BatchProcessCoordinationWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(BatchProcessCoordinationWeb.ErrorView, :"404")
  end

  def call(conn, {:error, message}) when is_binary(message) do
    conn
    |> put_status(:unprocessable_entity)
    |> assign(:message, message)
    |> render(BatchProcessCoordinationWeb.ErrorView, :"422") # => json {"error" : "message"}
  end
end