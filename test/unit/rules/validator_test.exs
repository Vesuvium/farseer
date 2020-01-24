defmodule FarseerTest.Rules.Validator do
  use ExUnit.Case
  import Dummy

  alias Farseer.Rules.Validator

  test "farseer/1" do
    assert Validator.farseer(%{"farseer" => 1}) == %{"farseer" => 1}
  end

  test "farseer/1 without farseer" do
    message = "No farseer version specified in the configuration"

    dummy System, ["halt"] do
      dummy IO, ["puts"] do
        Validator.farseer(%{})
        assert called(IO.puts(message))
        assert called(System.halt(1))
      end
    end
  end

  test "version/1" do
    assert Validator.version(%{"farseer" => "0.4"}) == %{"farseer" => "0.4"}
  end

  test "version/1 with an supported version" do
    rules = %{"farseer" => "0"}
    version = Application.spec(:farseer, :vsn)
    message = "Farseer #{version} does not support configuration version 0"

    dummy System, ["halt"] do
      dummy IO, ["puts"] do
        Validator.version(rules)
        assert called(IO.puts(message))
        assert called(System.halt(1))
      end
    end
  end

  test "endpoints/1" do
    assert Validator.endpoints(%{"endpoints" => true}) == %{"endpoints" => true}
  end

  test "endpoints/1 without endpoints" do
    message = "No endpoints found in the configuration"

    dummy System, ["halt"] do
      dummy IO, ["puts"] do
        Validator.endpoints(%{})
        assert called(IO.puts(message))
        assert called(System.halt(1))
      end
    end
  end

  test "validate/1" do
    dummy Validator, [
      {"farseer", :farseer},
      {"version", :version},
      {"endpoints", :endpoints}
    ] do
      assert Validator.validate(:rules) == :endpoints
      assert called(Validator.farseer(:rules))
      assert called(Validator.version(:farseer))
      assert called(Validator.endpoints(:version))
    end
  end
end
