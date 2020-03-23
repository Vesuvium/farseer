defmodule Farseer.Dispatch do
  alias Farseer.Ets
  alias Farseer.Handlers.{Http, Json}

  def init(table), do: table

  def call(conn, _table) do
    case Ets.match(conn.method, conn.request_path) do
      [{_path, handler, path_rules, method_rules}] ->
        cond do
          handler == "Http" ->
            Http.handle(conn, path_rules, method_rules)

          handler == "Json" ->
            Json.handle(conn, path_rules, method_rules)

          true ->
            Http.handle(conn, path_rules, method_rules)
        end

      [] ->
        Http.not_found(conn)
    end
  end
end
