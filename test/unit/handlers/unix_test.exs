defmodule FarseerTest.Handlers.Unix do
  use ExUnit.Case

  alias Farseer.Handlers.Unix

  test "the Unix.handle function" do
    assert Unix.handle(:conn, :options) == :ok
  end
end
