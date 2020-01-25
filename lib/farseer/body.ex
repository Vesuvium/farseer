defmodule Farseer.Body do
  alias Farseer.Body
  alias Farseer.Rules
  alias Plug.Conn
  alias Plug.Conn.Query

  def add({_conn, fields}, extra_fields) when is_map(fields) do
    Enum.reduce(extra_fields, fields, fn field, acc ->
      Map.merge(acc, field)
    end)
  end

  def add({_conn, fields}, _extra_fields) do
    fields
  end

  def read({:ok, body, conn}, ["application/json"]) do
    {conn, Jason.decode!(body)}
  end

  def read({:ok, body, conn}, ["application/x-www-form-urlencoded"]) do
    {conn, Query.decode(body)}
  end

  def read({:ok, body, conn}, []) do
    {conn, body}
  end

  def encode(string, ["application/json"]) do
    Jason.encode!(string)
  end

  def encode(string, ["application/x-www-form-urlencoded"]) do
    Query.encode(string)
  end

  def encode(string, []) do
    string
  end

  def process(conn, nil) do
    Conn.read_body(conn) |> elem(1)
  end

  @doc """
  Processes the body of a request.
  """
  def process(conn, method_rules) do
    content_type = Conn.get_req_header(conn, "content-type")

    conn
    |> Conn.read_body()
    |> Body.read(content_type)
    |> Body.add(Rules.get(method_rules, ["request", "body", "add"]))
    |> Body.encode(content_type)
  end

  @doc """
  Filters body keys.
  """
  def collect(body, collect) do
    Enum.filter(body, fn {k, _v} -> Enum.member?(collect, k) end) |> Map.new()
  end
  end
end
