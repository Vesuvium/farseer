defmodule Farseer.Dispatch do
  alias Farseer.Ets
  alias Farseer.Handlers.Http

  def init(table), do: table

  def call(conn, table) do
    case Ets.match(conn.method, conn.request_path) do
      [{_path, path_rules, method_rules}] ->
        Http.handle(conn, path_rules, method_rules)

      [] ->
        Http.not_found(conn)
    end
  end
end
