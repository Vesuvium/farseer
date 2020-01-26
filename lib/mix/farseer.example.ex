defmodule Mix.Tasks.Farseer.Example do
  use Mix.Task

  @shortdoc "Creates an example farseer.yml file."

  def run(_args) do
    Farseer.Cli.example()
  end
end
