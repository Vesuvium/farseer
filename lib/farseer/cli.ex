defmodule Farseer.Cli do
  def main(args \\ []) do
    command = Enum.at(args, 0)

    cond do
      command == "run" -> Farseer.Server.start(1, 2)
      command == "version" -> Farseer.Cli.version()
      command == "help" -> Farseer.Cli.help()
      command == nil -> Farseer.Cli.help()
      true -> Farseer.Cli.help()
    end
  end

  def version() do
    IO.puts("Farseer version #{Application.spec(:farseer, :vsn)}")
  end

  def help do
  end
end
