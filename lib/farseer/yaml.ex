defmodule Farseer.Yaml do
  @moduledoc """
  Wrapper for YamlElixir, responsible for getting the yaml and validating it.
  """

  def read(path) do
    case YamlElixir.read_from_file(path) do
      {:ok, yaml} ->
        yaml

      {:error, _error} ->
        IO.puts("File #{path} was not found")
        System.halt(1)
    end
  end

  def read do
    read("farseer.yml")
  end

  @doc "Check the yaml has an endpoints key"
  def has_endpoints(yaml) do
    unless Map.has_key?(yaml, "endpoints") do
      IO.puts("No endpoints found in the configuration")
      System.halt(1)
    end
  end

  def has_farseer(yaml) do
    unless Map.has_key?(yaml, "farseer") do
      IO.puts("No farseer version specified in the configuration")
      System.halt(1)
    end
  end

  def load(path) do
    # should be
    # path |> read |> has_farseer |> has_endpoints
    yaml = Farseer.Yaml.read(path)
    Farseer.Yaml.has_farseer(yaml)
    Farseer.Yaml.has_endpoints(yaml)
    yaml
  end
end
