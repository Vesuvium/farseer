defmodule FarseerTest.Handlers.Json do
  use ExUnit.Case
  import Dummy

  alias Farseer.Handlers.Http
  alias Farseer.Handlers.Json

  test "handle/3" do
    path_rules = %{"response" => "json"}

    dummy Jason, [{"encode!", :body}] do
      dummy Http, [{"respond", fn _a, _b, _c, _d -> :response end}] do
        assert Json.handle(:conn, path_rules, :method_rules) == :response
        assert called(Jason.encode!("json"))
        assert called(Http.respond(:conn, 200, :body, "application/json"))
      end
    end
  end
end
