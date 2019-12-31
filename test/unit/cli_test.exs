defmodule FarseerTest.Cli do
  use ExUnit.Case
  import Dummy

  alias Farseer.Cli

  test "the main method with no arguments" do
    dummy Cli, [{"help", fn -> :help end}] do
      assert Cli.main() == :help
    end
  end

  for t <- ["any", "help"] do
    test "the main method with #{t} as argument" do
      dummy Cli, [{"help", fn -> :help end}] do
        assert Cli.main([unquote(t)]) == :help
      end
    end
  end

  test "the main method with version argument" do
    dummy Cli, [{"version", fn -> :version end}] do
      assert Cli.main(["version"]) == :version
    end
  end

  test "the main method with --version argument" do
    dummy Cli, [{"version", fn -> :version end}] do
      assert Cli.main(["--version"]) == :version
    end
  end

  test "the main method with run argument" do
    dummy Farseer.Server, ["start/2"] do
      Cli.main(["run"])
      assert called(Farseer.Server.start(1, 2))
    end
  end

  test "the version method" do
    dummy IO, ["puts"] do
      Cli.version()
      version = Application.spec(:farseer, :vsn)
      assert called(IO.puts("Farseer version #{version}"))
    end
  end

  test "the help method" do
    assert Cli.help() == :ok
  end
end
