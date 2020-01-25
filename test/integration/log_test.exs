defmodule FarseerTest.Log do
  use ExUnit.Case

  alias Farseer.Log

  test "server_start/1" do
    assert Log.server_start("4000") == :ok
  end

  test "endpoint/2" do
    assert Log.endpoint("get", "endpoint") == :ok
  end

  test "request_received/0" do
    assert Log.request_received() == :ok
  end

  test "response_sending/0" do
    assert Log.response_sending() == :ok
  end
end
