defmodule FarseerTest.Rules do
  use ExUnit.Case
  import Dummy

  alias Farseer.Rules
  alias Farseer.Rules.Parser

  test "parse/1" do
    dummy Parser, [{"parse", :parse}] do
      assert Rules.parse(:path) == :parse
      assert called(Parser.parse(:path))
    end
  end

  test "endpoints/1" do
    assert Rules.endpoints(%{"endpoints" => :endpoints}) == :endpoints
  end
end
