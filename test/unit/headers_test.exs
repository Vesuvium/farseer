defmodule FarseerTest.Headers do
  use ExUnit.Case
  import Dummy

  alias Farseer.Headers
  alias Farseer.Rules
  alias Plug.Conn

  test "filtering request headers" do
    headers = [{"host", "value"}, {"something", "value"}]
    assert Headers.filter(headers) == [{"something", "value"}]
  end

  test "making a basic auth header" do
    dummy Base, [{"encode64", "encoded"}] do
      assert Headers.basic_auth("user", "password") == "Basic encoded"
      assert called(Base.encode64("user:password"))
    end
  end

  test "resolve/2" do
    assert Headers.resolve(:header, :value) == {:header, :value}
  end

  test "resolve/2 with authorization" do
    dummy Headers, ["basic_auth/2"] do
      options = %{"username" => "user", "password" => "password"}
      result = Headers.resolve("authorization", options)
      assert called(Headers.basic_auth("user", "password"))
      assert result == {"authorization", ["user", "password"]}
    end
  end

  test "add headers to a list" do
    dummy Headers, [{"resolve", fn _a, _b -> :resolved end}] do
      assert Headers.add([], %{:key => :value}) == [:resolved]
      assert called(Headers.resolve(:key, :value))
    end
  end

  test "add headers to a list with no headers to add" do
    assert Headers.add([:headers], nil) == [:headers]
  end

  test "adding headers to conn" do
    dummy Conn, [{"put_resp_header", fn conn, _h, _v -> conn end}] do
      result = Headers.add_to_conn(:conn, [{"header", "value"}])
      assert called(Conn.put_resp_header(:conn, "header", "value"))
      assert result == :conn
    end
  end

  test "process/2" do
    dummy Rules, [{"get", fn _a, _b -> :get end}] do
      dummy Headers, [{"filter", :filter}, {"add", fn _a, _b -> :add end}] do
        assert Headers.process(%{:req_headers => :headers}, :rules) == :add
        assert called(Headers.filter(:headers))
        assert called(Rules.get(:rules, ["request", "headers", "add"]))
        assert called(Headers.add(:filter, :get))
      end
    end
  end

  test "process_response/2" do
    dummy Rules, [{"get", fn _a, _b -> :get end}] do
      dummy Headers, [{"add_to_conn", fn _a, _b -> :conn end}] do
        Headers.process_response(
          :conn,
          %{headers: "headers"},
          :path_rules,
          :method_rules
        )

        assert called(Rules.get(:method_rules, ["response", "headers", "add"]))
        assert called(Headers.add_to_conn(:conn, :get))
      end
    end
  end
end
