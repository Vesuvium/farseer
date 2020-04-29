defmodule FarseerTest.Rules.Parser do
  use ExUnit.Case
  import Dummy

  alias Farseer.Log
  alias Farseer.Rules.Parser
  alias Farseer.Rules.Validator
  alias YamlElixir.{FileNotFoundError, ParsingError}

  test "read/1" do
    dummy YamlElixir, [{"read_from_file", {:ok, "data"}}] do
      yaml = Parser.read("path")
      assert called(YamlElixir.read_from_file("path"))
      assert yaml == "data"
    end
  end

  test "read/1 with FileNotFoundError" do
    error = %FileNotFoundError{message: "message"}

    dummy YamlElixir, [{"read_from_file", {:error, error}}] do
      dummy System, ["halt"] do
        dummy IO, ["puts"] do
          Parser.read("path")
          assert called(IO.puts("File \"path\" was not found"))
          assert called(System.halt(1))
        end
      end
    end
  end

  test "read/1 with ParsingError" do
    error = %ParsingError{message: "message"}

    dummy YamlElixir, [{"read_from_file", {:error, error}}] do
      dummy System, ["halt"] do
        dummy IO, ["puts"] do
          Parser.read("path")
          assert called(IO.puts("Failed to read \"path\" because: message"))
          assert called(System.halt(1))
        end
      end
    end
  end

  test "replace/1" do
    string = "text $key"

    dummy System, [{"get_env/0", %{"key" => "value"}}] do
      dummy Log, ["variable_replacing/3"] do
        assert Parser.replace(string) == "text value"
        assert called(System.get_env())
        assert called(Log.variable_replacing(string, "$key", "value"))
      end
    end
  end

  test "parse/1" do
    dummy Parser, ["read"] do
      dummy Validator, ["validate"] do
        assert Parser.parse("path") == "path"
        assert called(Validator.validate("path"))
      end
    end
  end
end
