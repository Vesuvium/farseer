defmodule FarseerTest.Config do
  use ExUnit.Case

  test "the yaml_file configuration option" do
    result = Application.get_env(:farseer, :yaml_file)
    assert result == "test/_test.yml"
  end

  test "the port configuration option" do
    result = Application.get_env(:farseer, :port)
    assert result == {:system, :integer, "FARSEER_PORT", 8000}
  end

  test "the compress configuration option" do
    result = Application.get_env(:farseer, :compress)
    assert result == {:system, :boolean, "FARSEER_COMPRESS", true}
  end
end
