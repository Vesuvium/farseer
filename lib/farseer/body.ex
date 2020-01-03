defmodule Farseer.Body do
  alias Farseer.Body
  alias Plug.Conn
  alias Plug.Conn.Query

  def add({_conn, fields}, extra_fields) do
    Enum.reduce(extra_fields, fields, fn field, acc ->
      Map.merge(acc, field)
    end)
  end

  def read({:ok, body, conn}, ["application/json"]) do
    {conn, Jason.decode!(body)}
  end

  def read({:ok, body, conn}, ["application/x-www-form-urlencoded"]) do
    {conn, Query.decode(body)}
  end

  def encode(string, ["application/json"]) do
    Jason.encode!(string)
  end

  def encode(string, ["application/x-www-form-urlencoded"]) do
    Query.encode(string)
  end

  def process(conn, nil) do
    Conn.read_body(conn) |> elem(1)
  end

  def process(conn, _method_rules) do
    conn
    |> Conn.read_body()
    |> Body.read(Conn.get_req_header(conn, "content-type"))
  end
end
