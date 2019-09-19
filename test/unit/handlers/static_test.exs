defmodule FarseerTest.Handlers.Static do
  use ExUnit.Case

  alias Farseer.Handlers.Static

  test "the Static.handle function" do
    assert Static.handle(:conn, :options) == :ok
  end
end
