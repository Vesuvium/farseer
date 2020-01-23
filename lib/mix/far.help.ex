defmodule Mix.Tasks.Far.Help do
  def run(_args) do
    help =
      "Usage: mix far[.COMMAND]\n\nCommands:\n\nrun\t\tRun farseer\nexample\t\tGenerate an example farseer.yml file\nversion\t\tPrint farseer's version"

    IO.puts(help)
  end
end
