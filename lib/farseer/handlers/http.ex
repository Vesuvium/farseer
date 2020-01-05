defmodule Farseer.Handlers.Http do
  @moduledoc """
  Generic HTTP handler. This is also the default handler.
  """
  alias Farseer.Body
  alias Farseer.Handlers.Http
  alias Farseer.Headers
  alias Plug.Conn

  @not_found_text "The requested resource was not found"
  @not_found_html "<!doctype html><html><head></head><body>#{@not_found_text}</body></html>"
  @not_found_json %{:message => @not_found_text}

  def not_found_text, do: @not_found_text
  def not_found_html, do: @not_found_html
  def not_found_json, do: @not_found_json

  @doc """
  Finds out whether a request accepts a given mime type. Succeeds if the
  request accepts */* or <mime_type>/*.
  """
  def accepts?(conn, mime_full_type) do
    mime_type =
      mime_full_type
      |> String.split("/")
      |> List.first()

    conn
    |> Conn.get_req_header("accept")
    |> List.first()
    |> String.contains?(["*/*", "#{mime_type}/*", mime_full_type])
  end

  @doc """
  Shorthand to send responses.
  """
  def respond(conn, status, body, content_type \\ "text/plain") do
    conn
    |> Conn.put_resp_content_type(content_type)
    |> Conn.send_resp(status, body)
  end

  @doc """
  Converts the request method to a Tesla method atom, e.g "GET" => :get!
  """
  def method(conn) do
    (String.downcase(conn.method) <> "!") |> String.to_atom()
  end

  def to(conn, to) do
    fragment = String.split(conn.request_path, "/") |> List.last()
    String.replace(to, "{id}", fragment)
  end

  def send(%{method: "GET"} = conn, path_rules, _method_rules) do
    headers = Headers.process(conn, path_rules)
    Tesla.get!(path_rules["to"], headers: headers)
  end

  def send(%{method: "DELETE"} = conn, path_rules, _method_rules) do
    headers = Headers.process(conn, path_rules)
    Tesla.delete!(path_rules["to"], headers: headers)
  end

  @doc """
  Sends the request to the configured target.
  """
  def send(conn, path_rules, method_rules) do
    headers = Headers.process(conn, path_rules)
    body = Body.process(conn, method_rules)

    apply(Tesla, Http.method(conn), [path_rules["to"], body, [headers: headers]])
  end

  def handle(conn, path_rules, method_rules) do
    response = Http.send(conn, path_rules, method_rules)

    conn
    |> Headers.add_to_conn(response.headers)
    |> Conn.send_resp(response.status, response.body)
  end

  @doc """
  If a route is not found, we want to respond with the a media type the client
  can understand, or with plain text as last resort.
  """
  def not_found(conn) do
    cond do
      Http.accepts?(conn, "application/json") ->
        Http.respond(
          conn,
          404,
          Jason.encode!(@not_found_json),
          "application/json"
        )

      Http.accepts?(conn, "text/html") ->
        Http.respond(conn, 404, @not_found_html, "text/html")

      true ->
        Http.respond(conn, 404, @not_found_text)
    end
  end
end
