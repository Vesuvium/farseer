defmodule Mix.Tasks.Farseer.Help do
  use Mix.Task

  @shortdoc "Prints farseers' help message"

  def run(_args) do
    Farseer.Cli.help()
  end
end
