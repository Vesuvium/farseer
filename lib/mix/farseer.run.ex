defmodule Mix.Tasks.Farseer.Run do
  use Mix.Task

  @shortdoc "Runs farseer"

  def run(args) do
    Mix.Tasks.Run.run(run_args() ++ args)
  end

  defp run_args do
    if iex_running?(), do: [], else: ["--no-halt"]
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) and IEx.started?()
  end
end
