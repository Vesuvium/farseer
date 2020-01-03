defmodule FarseerTest.Body do
  use ExUnit.Case
  import Dummy

  alias Farseer.Body
  alias Plug.Conn
  alias Plug.Conn.Query

  test "add/2" do
    result = Body.add({:conn, %{"fields" => :f}}, [%{"extra" => :e}])
    assert result == %{"fields" => :f, "extra" => :e}
  end

  test "read/2 with json" do
    content_type = ["application/json"]

    dummy Jason, ["decode!"] do
      assert Body.read({:ok, :body, :conn}, content_type) == {:conn, :body}
      assert called(Jason.decode!(:body))
    end
  end

  test "read/2 with urlencoded" do
    content_type = ["application/x-www-form-urlencoded"]

    dummy Query, ["decode"] do
      assert Body.read({:ok, :body, :conn}, content_type) == {:conn, :body}
      assert called(Query.decode(:body))
    end
  end

  test "encode/2 with json" do
    content_type = ["application/json"]

    dummy Jason, [{"encode!", :encode}] do
      assert Body.encode("string", content_type) == :encode
      assert called(Jason.encode!("string"))
    end
  end

  test "encode/2 with urlencoded" do
    content_type = ["application/x-www-form-urlencoded"]

    dummy Query, [{"encode", :encode}] do
      assert Body.encode("string", content_type) == :encode
      assert called(Query.encode("string"))
    end
  end

  test "process/2 with conn, nil" do
    dummy Conn, [{"read_body", {:ok, :body}}] do
      assert Body.process(:conn, nil) == :body
      assert called(Conn.read_body(:conn))
    end
  end

  test "process/2" do
    dummy Conn, [
      {"read_body", {:ok, "body", "conn"}},
      {"get_req_header", fn _a, _b -> ["header"] end}
    ] do
      dummy Body, [
        {"read", fn {:ok, _a, _b}, _c -> {:conn, :body} end},
        {"add", fn {_a, _b}, _c -> :add end},
        {"encode", fn _a, [_b] -> :encode end}
      ] do
        assert Body.process(:conn, %{"request_body" => "rb"}) == :encode
        assert called(Conn.read_body(:conn))
        assert called(Conn.get_req_header(:conn, "content-type"))
        assert called(Body.read({:ok, "body", "conn"}, ["header"]))
        assert called(Body.add({:conn, :body}, "rb"))
        assert called(Body.encode(:add, ["header"]))
      end
    end
  end
end
