defmodule Mix.Tasks.Farseer.Help do
  use Mix.Task

  @shortdoc "Prints farseers' help message"

  def run(_args) do
    help =
      "Usage: mix farseer[.COMMAND]\n\nCommands:\n\nrun\t\tRun farseer\nexample\t\tGenerate an example farseer.yml file\nversion\t\tPrint farseer's version"

    IO.puts(help)
  end
end
