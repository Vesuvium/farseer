defmodule Farseer.Handlers.Http do
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

  def send(conn, options) do
    headers =
      conn.req_headers
      |> Headers.filter()
      |> Headers.add(options["request_headers"])

    options["to"]
    |> Tesla.get!(headers: headers)
  end

  def handle(conn, to) do
    response = Http.send(conn, to)

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
