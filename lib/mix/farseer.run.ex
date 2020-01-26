defmodule Mix.Tasks.Farseer.Run do
  use Mix.Task

  @shortdoc "Runs farseer"

  def run(_args) do
    Application.ensure_all_started(:farseer, :permanent)
    System.no_halt(true)
  end
end
