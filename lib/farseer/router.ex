defmodule Farseer.Router do
  use Plug.Router

  alias Farseer.Dispatch

  plug(:match)
  plug(:dispatch)

  get "/_version" do
    send_resp(conn, 200, Application.spec(:farseer, :vsn))
  end

  forward("/", to: Dispatch, init_opts: Confex.get_env(:farseer, :table))
end
