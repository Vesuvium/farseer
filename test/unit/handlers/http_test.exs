defmodule FarseerTest.Handlers.Http do
  use ExUnit.Case
  import Dummy

  alias Farseer.Handlers.Http
  alias Farseer.Headers
  alias Plug.Conn

  test "the accepts?/2 function with a specific type" do
    dummy Conn, [{"get_req_header", fn _a, _b -> ["text/plain"] end}] do
      assert Http.accepts?(:conn, "text/plain") == true
    end
  end

  test "the accepts?/2 function with any type" do
    dummy Conn, [{"get_req_header", fn _a, _b -> ["*/*"] end}] do
      assert Http.accepts?(:conn, "text/plain") == true
    end
  end

  test "the accepts?/2 function with any subtype" do
    dummy Conn, [{"get_req_header", fn _a, _b -> ["text/*"] end}] do
      assert Http.accepts?(:conn, "text/plain") == true
    end
  end

  test "the respond function" do
    dummy Conn, [
      {"put_resp_content_type", fn conn, _b -> conn end},
      "send_resp/3"
    ] do
      Http.respond(:conn, :status, :body)
      assert called(Conn.put_resp_content_type(:conn, "text/plain"))
      assert called(Conn.send_resp(:conn, :status, :body))
    end
  end

  test "the respond function with a content type" do
    dummy Conn, ["put_resp_content_type/2", "send_resp/3"] do
      Http.respond(:conn, :status, :body, "application/json")
      assert called(Conn.put_resp_content_type(:conn, "application/json"))
    end
  end

  test "method/1" do
    assert Http.method(%{method: "GET"}) == :get!
  end

  test "sending a request" do
    dummy Tesla, ["get!/2"] do
      dummy Headers, [{"filter", :headers}, {"add", fn _a, _b -> :add end}] do
        options = %{"to" => :to, "request_headers" => "request_headers"}
        Http.send(%{:req_headers => :req_headers}, options)
        assert called(Headers.filter(:req_headers))
        assert called(Headers.add(:headers, "request_headers"))
        assert called(Tesla.get!(:to, headers: :add))
      end
    end
  end

  test "handle/3" do
    dummy Conn, ["send_resp/3"] do
      dummy Http, [
        {"send",
         fn _a, _b, _c ->
           %{:headers => :headers, :status => 200, :body => :body}
         end}
      ] do
        dummy Headers, [{"add_to_conn", fn conn, _b -> conn end}] do
          conn = %{:req_headers => :req_headers}
          Http.handle(conn, :path_rules, :method_rules)
          assert called(Http.send(conn, :path_rules, :method_rules))
          assert called(Headers.add_to_conn(conn, :headers))
          assert called(Conn.send_resp(conn, 200, :body))
        end
      end
    end
  end

  test "the not_found function" do
    dummy Http, [{"accepts?", fn _a, _b -> false end}, "respond/3"] do
      Http.not_found(:conn)
      assert called(Http.respond(:conn, 404, Http.not_found_text()))
    end
  end

  test "the not found function when json is accepted" do
    dummy Jason, [{"encode!", :json}] do
      dummy Http, [{"accepts?", fn _a, _b -> true end}, "respond/4"] do
        Http.not_found(:conn)
        assert called(Http.accepts?(:conn, "application/json"))
        assert called(Jason.encode!(Http.not_found_json()))
        assert called(Http.respond(:conn, 404, :json, "application/json"))
      end
    end
  end

  test "the not found function when html is accepted" do
    dummy Http, [
      {"accepts?", fn _a, mime -> if mime == "text/html", do: true end},
      "respond/4"
    ] do
      Http.not_found(:conn)
      assert called(Http.accepts?(:conn, "text/html"))
      html = Http.not_found_html()
      assert called(Http.respond(:conn, 404, html, "text/html"))
    end
  end
end
