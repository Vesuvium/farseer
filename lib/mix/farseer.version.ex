defmodule Mix.Tasks.Farseer.Version do
  use Mix.Task

  @shortdoc "Prints farseer's version."

  def run(_args) do
    IO.puts("Farseer version 0.4.0")
  end
end
