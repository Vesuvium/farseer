defmodule FarseerTest.Body do
  use ExUnit.Case
  import Dummy

  alias Farseer.Body
  alias Plug.Conn
  alias Plug.Conn.Query

  test "read/2 with json" do
    dummy Jason, ["decode!"] do
      assert Body.read({:ok, :body, :conn}, ["application/json"]) == :body
      assert called(Jason.decode!(:body))
    end
  end

  test "read/2 with urlencoded" do
    content_type = ["application/x-www-form-urlencoded"]

    dummy Query, ["decode"] do
      assert Body.read({:ok, :body, :conn}, content_type) == :body
      assert called(Query.decode(:body))
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
      {"read_body", :body},
      {"get_req_header", fn _a, _b -> :header end}
    ] do
      dummy Body, [{"read", fn _a, _b -> :read end}] do
        assert Body.process(:conn, :rules) == :read
        assert called(Conn.read_body(:conn))
        assert called(Conn.get_req_header(:conn, "content-type"))
        assert called(Body.read(:body, :header))
      end
    end
  end
end
