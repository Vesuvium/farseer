defmodule Farseer.Dispatch do
  alias Farseer.Handler
  alias Plug.Conn

  def init(table), do: table

  def call(conn, table) do
    case :ets.match_object(table, {conn.request_path, conn.method, :"$3"}) do
      [{_path, _method, options}] -> Handler.handle(conn, options)
      [] -> Handler.not_found(conn)
    end
  end
end
