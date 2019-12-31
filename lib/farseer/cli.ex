defmodule Farseer.Cli do
  def main(args \\ []) do
    command = Enum.at(args, 0)

    cond do
      command == "run" -> Farseer.Server.start(1, 2)
      command == "version" -> Farseer.Cli.version()
      command == "--version" -> Farseer.Cli.version()
      command == "help" -> Farseer.Cli.help()
      command == nil -> Farseer.Cli.help()
      true -> Farseer.Cli.help()
    end
  end

  def version() do
    IO.puts("Farseer version #{Application.spec(:farseer, :vsn)}")
  end

  def example do
    File.cp("priv/example.yml", "farseer.yml")
  end

  def help do
    help =
      "Usage: farseer [command]\n\nCommands:\n\nrun\t\tRun farseer\nexample\t\tGenerate an example farseer.yml file\nversion\t\tPrint farseer's version"

    IO.puts(help)
  end
end
