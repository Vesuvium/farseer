defmodule FarseerTest.Handlers.S3 do
  use ExUnit.Case

  alias Farseer.Handlers.S3

  test "the S3.handle function" do
    assert S3.handle(:conn, :options) == :ok
  end
end
