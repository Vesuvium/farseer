defmodule Farseer.Headers do
  @moduledoc """
  Utilities to work with headers.
  """
  alias Farseer.Headers
  alias Plug.Conn

  def filter(headers) do
    Enum.reject(headers, fn header ->
      Enum.member?(["host", "accept-encoding", "dnt"], elem(header, 0))
    end)
  end

  def basic_auth(username, password) do
    "Basic " <> Base.encode64(username <> ":" <> password)
  end

  @doc """
  Resolves an header and its options to its final value.
  """
  def resolve(header, options) do
    cond do
      header == "authorization" ->
        {header, Headers.basic_auth(options["username"], options["password"])}
    end
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

  def add_to_conn(conn, headers) do
    Enum.reduce(headers, conn, fn {key, value}, acc ->
      Conn.put_resp_header(acc, key, value)
    end)
  end
end
