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

  test "get/2" do
    assert Rules.get(%{key: :value}, [:key]) == :value
  end

  test "get/2 with no results" do
    assert Rules.get(%{}, [:key]) == nil
  end
end
