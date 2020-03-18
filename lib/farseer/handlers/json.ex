defmodule Farseer.Handlers.Json do
  @moduledoc """
  An handler for static JSON responses
  """
  alias Farseer.Handlers.Http

  def handle(conn, path_rules, _method_rules) do
    body = Jason.encode!(path_rules["response"])
    Http.respond(conn, 200, body, "application/json")
  end
end
