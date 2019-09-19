defmodule FarseerTest.Handlers.Zero do
  use ExUnit.Case

  alias Farseer.Handlers.Zero

  test "the Zero.handle function" do
    assert Zero.handle(:conn, :options) == :ok
  end
end
