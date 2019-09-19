defmodule FarseerTest.Handlers.WebSockets do
  use ExUnit.Case

  alias Farseer.Handlers.WebSockets

  test "the WebSockets.handle function" do
    assert WebSockets.handle(:conn, :options) == :ok
  end
end
