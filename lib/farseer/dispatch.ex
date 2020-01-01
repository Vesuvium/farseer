defmodule Farseer.Dispatch do
  alias Farseer.Handlers.Http

  def init(table), do: table

  def call(conn, table) do
    case :ets.match_object(
           table,
           {conn.request_path, conn.method, :"$3", :"$4"}
         ) do
      [{_path, _method, path_rules, method_rules}] ->
        Http.handle(conn, path_rules, method_rules)

      [] ->
        Http.not_found(conn)
    end
  end
end
