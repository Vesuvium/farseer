defmodule Farseer.Headers do
  @moduledoc """
  Utilities to work with headers.
  """
  alias Farseer.Headers
  alias Farseer.Rules
  alias Plug.Conn

  def filter(headers) do
    Enum.reject(headers, fn header ->
      Enum.member?(["host", "accept-encoding", "dnt"], elem(header, 0))
    end)
  end

  def basic_auth(username, password) do
    "Basic " <> Base.encode64(username <> ":" <> password)
  end

  def resolve("authorization", options) do
    {"authorization",
     Headers.basic_auth(options["username"], options["password"])}
  end

  @doc """
  Resolves an header and its options to its final value.
  """
  def resolve(header, value) do
    {header, value}
  end

  def add(headers, headers_to_add) do
    if headers_to_add do
      Enum.reduce(headers_to_add, headers, fn {key, value}, acc ->
        acc ++ [Headers.resolve(key, value)]
      end)
    else
      headers
    end
  end

  @doc """
  Adds headers to a Plug.Conn object.
  """
  def add_to_conn(conn, headers) do
    Enum.reduce(headers, conn, fn {key, value}, acc ->
      Conn.put_resp_header(acc, key, value)
    end)
  end

  def add_maps_to_conn(conn, headers) do
    Enum.reduce(headers, conn, fn header, acc ->
      header = header |> Map.to_list() |> List.to_tuple() |> elem(0)
      Conn.put_resp_header(acc, elem(header, 0), elem(header, 1))
    end)
  end

  def process(conn, path_rules) do
    conn.req_headers
    |> Headers.filter()
    |> Headers.add(Rules.get(path_rules, ["request", "headers", "add"]))
  end

  @doc """
  Adds headers to a response.
  """
  def process_response(conn, response, _path_rules, method_rules) do
    conn
    |> Headers.add_to_conn(response.headers)
    |> Headers.add_maps_to_conn(
      Rules.get(method_rules, ["response", "headers", "add"])
    )
  end
end
