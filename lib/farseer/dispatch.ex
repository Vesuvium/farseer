defmodule Farseer.Dispatch do
  alias Farseer.Handlers.Http

  def init(table), do: table

  def call(conn, table) do
    case :ets.match_object(table, {conn.request_path, conn.method, :"$3"}) do
      [{_path, _method, options}] -> Http.handle(conn, options)
      [] -> Http.not_found(conn)
    end
  end
end
