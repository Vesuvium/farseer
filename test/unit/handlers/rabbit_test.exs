defmodule FarseerTest.Handlers.Rabbit do
  use ExUnit.Case

  alias Farseer.Handlers.Rabbit

  test "the Rabbit.handle function" do
    assert Rabbit.handle(:conn, :options) == :ok
  end
end
