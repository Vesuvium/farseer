defmodule Farseer.Cli do
  alias Farseer.Cli

  def main(args \\ []) do
    command = Enum.at(args, 0)

    cond do
      command == "run" -> Cli.run()
      command == "example" -> Cli.example()
      command == "version" -> Cli.version()
      command == "--version" -> Cli.version()
      command == "help" -> Cli.help()
      command == nil -> Cli.help()
      true -> Cli.help()
    end
  end

  def run() do
    Application.ensure_all_started(:farseer)
    :timer.sleep(:infinity)
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
