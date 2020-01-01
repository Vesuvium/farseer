defmodule FarseerTest.Yaml do
  use ExUnit.Case
  import Dummy

  alias Farseer.Yaml

  test "read/1" do
    dummy YamlElixir, [{"read_from_file", {:ok, "data"}}] do
      yaml = Yaml.read("path")
      assert called(YamlElixir.read_from_file("path"))
      assert yaml == "data"
    end
  end

  test "read/1 when the file is not found" do
    dummy System, ["halt"] do
      dummy IO, ["puts"] do
        Yaml.read("path")
        assert called(IO.puts("File path was not found"))
        assert called(System.halt(1))
      end
    end
  end

  test "read/0" do
    dummy YamlElixir, [{"read_from_file", {:ok, "data"}}] do
      Yaml.read()
      assert called(YamlElixir.read_from_file("farseer.yml"))
    end
  end

  test "has_endpoints/1" do
    assert Yaml.has_endpoints(%{"endpoints" => true}) == nil
  end

  test "has_endpoints/1 without endpoints" do
    message = "No endpoints found in the configuration"

    dummy System, ["halt"] do
      dummy IO, ["puts"] do
        Yaml.has_endpoints(%{})
        assert called(IO.puts(message))
        assert called(System.halt(1))
      end
    end
  end

  test "has_farseer/1" do
    assert Yaml.has_farseer(%{"farseer" => 1}) == nil
  end

  test "has_farseer/1 without farseer" do
    message = "No farseer version specified in the configuration"

    dummy System, ["halt"] do
      dummy IO, ["puts"] do
        Yaml.has_farseer(%{})
        assert called(IO.puts(message))
        assert called(System.halt(1))
      end
    end
  end

  test "Yaml.load/1" do
    dummy Yaml, ["read", "has_farseer", "has_endpoints"] do
      assert Yaml.load("path") == "path"
      assert called(Yaml.read("path"))
      assert called(Yaml.has_farseer("path"))
      assert called(Yaml.has_endpoints("path"))
    end
  end
end
