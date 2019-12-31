defmodule FarseerTest.Cli do
  use ExUnit.Case
  import Dummy

  alias Farseer.Cli

  test "farseer" do
    dummy Cli, [{"help", fn -> :help end}] do
      assert Cli.main() == :help
    end
  end

  for t <- ["any", "help"] do
    test "farseer #{t}" do
      dummy Cli, [{"help", fn -> :help end}] do
        assert Cli.main([unquote(t)]) == :help
      end
    end
  end

  test "farseer version" do
    dummy Cli, [{"version", fn -> :version end}] do
      assert Cli.main(["version"]) == :version
    end
  end

  test "farseer --version" do
    dummy Cli, [{"version", fn -> :version end}] do
      assert Cli.main(["--version"]) == :version
    end
  end

  test "farseer run" do
    dummy Farseer.Server, ["start/2"] do
      Cli.main(["run"])
      assert called(Farseer.Server.start(1, 2))
    end
  end

  test "version/0" do
    dummy IO, ["puts"] do
      Cli.version()
      version = Application.spec(:farseer, :vsn)
      assert called(IO.puts("Farseer version #{version}"))
    end
  end

  test "example/0" do
    dummy File, [{"cp", fn _a, _b -> :cp end}] do
      assert Cli.example() == :cp
      assert called(File.cp("priv/example.yml", "farseer.yml"))
    end
  end

  test "help/0" do
    assert Cli.help() == :ok
  end
end
