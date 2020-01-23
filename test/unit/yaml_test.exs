defmodule FarseerTest.Yaml do
  use ExUnit.Case
  import Dummy

  alias Farseer.Yaml
  alias YamlElixir.{FileNotFoundError, ParsingError}

  test "read/1" do
    dummy YamlElixir, [{"read_from_file", {:ok, "data"}}] do
      yaml = Yaml.read("path")
      assert called(YamlElixir.read_from_file("path"))
      assert yaml == "data"
    end
  end

  test "read/1 with YamlElixir.FileNotFoundError" do
    error = %FileNotFoundError{message: "message"}

    dummy YamlElixir, [{"read_from_file", {:error, error}}] do
      dummy System, ["halt"] do
        dummy IO, ["puts"] do
          Yaml.read("path")
          assert called(IO.puts("File \"path\" was not found"))
          assert called(System.halt(1))
        end
      end
    end
  end

  test "read/1 with YamlElixir.ParsingError" do
    error = %ParsingError{message: "message"}

    dummy YamlElixir, [{"read_from_file", {:error, error}}] do
      dummy System, ["halt"] do
        dummy IO, ["puts"] do
          Yaml.read("path")
          assert called(IO.puts("Failed to read \"path\" because: message"))
          assert called(System.halt(1))
        end
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
    yaml = %{"endpoints" => true}
    assert Yaml.has_endpoints(yaml) == yaml
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
    yaml = %{"farseer" => 1}
    assert Yaml.has_farseer(yaml) == yaml
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

  test "check_version/1" do
    yaml = %{"farseer" => "0.4"}
    assert Yaml.check_version(yaml) == yaml
  end

  test "check_version/1 with ansupported version" do
    yaml = %{"farseer" => "0"}
    version = Application.spec(:farseer, :vsn)
    message = "Farseer #{version} does not support configuration version 0"

    dummy System, ["halt"] do
      dummy IO, ["puts"] do
        Yaml.check_version(yaml)
        assert called(IO.puts(message))
        assert called(System.halt(1))
      end
    end
  end

  test "Yaml.load/1" do
    dummy Yaml, ["read", "has_farseer", "check_version", "has_endpoints"] do
      assert Yaml.load("path") == "path"
      assert called(Yaml.read("path"))
      assert called(Yaml.has_farseer("path"))
      assert called(Yaml.check_version("path"))
      assert called(Yaml.has_endpoints("path"))
    end
  end
end
