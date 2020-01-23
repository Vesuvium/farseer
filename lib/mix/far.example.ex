defmodule Mix.Tasks.Far.Example do
  @doc """
  Creates an exampel farseer.yml file.
  """
  def run(_args) do
    File.cp("priv/example.yml", "farseer-example.yml")
  end
end
