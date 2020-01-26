defmodule Mix.Tasks.Farseer.Run do
  use Mix.Task

  @shortdoc "Runs farseer"

  def run(_args) do
    Farseer.Cli.run()
  end
end
