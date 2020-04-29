defmodule FarseerTest.Rules.Parser do
  use ExUnit.Case
  import Dummy

  alias Farseer.Log
  alias Farseer.Rules.{Parser, Validator}
  alias YamlElixir.ParsingError

  test "read/1" do
    dummy File, [{"read", {:ok, "string"}}] do
      yaml = Parser.read("path")
      assert called(File.read("path"))
      assert yaml == "string"
    end
  end

  test "read/1 with :enoent" do
    dummy File, [{"read", {:error, :enoent}}] do
      dummy System, ["halt"] do
        dummy IO, ["puts"] do
          Parser.read("path")
          assert called(IO.puts("File \"path\" was not found"))
          assert called(System.halt(1))
        end
      end
    end
  end

  test "read/1 with :enoaccess" do
    dummy File, [{"read", {:error, :enoaccess}}] do
      dummy System, ["halt"] do
        dummy IO, ["puts"] do
          Parser.read("path")
          assert called(IO.puts("File \"path\" could not be read"))
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

  test "yaml/1" do
    dummy YamlElixir, [{"read_from_string", {:ok, "data"}}] do
      yaml = Parser.yaml("string")
      assert called(YamlElixir.read_from_string("string"))
      assert yaml == "data"
    end
  end

  test "yaml/1 with ParsingError" do
    error = %ParsingError{message: "message"}
    error_message = "Failed to parse configuration because: message"

    dummy YamlElixir, [{"read_from_string", {:error, error}}] do
      dummy System, ["halt"] do
        dummy IO, ["puts"] do
          Parser.yaml("string")
          assert called(IO.puts(error_message))
          assert called(System.halt(1))
        end
      end
    end
  end

  test "parse/1" do
    dummy Parser, [{"read", :read}, {"replace", :replace}, {"yaml", :yaml}] do
      dummy Validator, [{"validate", :validate}] do
        assert Parser.parse("path") == :validate
        assert called(Parser.read("path"))
        assert called(Parser.replace(:read))
        assert called(Parser.yaml(:replace))
        assert called(Validator.validate(:yaml))
      end
    end
  end
end
