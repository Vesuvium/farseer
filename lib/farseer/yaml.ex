defmodule Farseer.Yaml do
  @moduledoc """
  Wrapper for YamlElixir, responsible for getting the yaml and validating it.
  """
  alias Farseer.Yaml

  @doc """
  Reads the farseer.yml file, or tells the user it wasn't found.
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

  @doc """
  Checks whether the yaml has endpoints defined.
  """
  def has_endpoints(yaml) do
    unless Map.has_key?(yaml, "endpoints") do
      IO.puts("No endpoints found in the configuration")
      System.halt(1)
    end
  end

  @doc """
  Checks the declared farseer version.
  """
  def has_farseer(yaml) do
    unless Map.has_key?(yaml, "farseer") do
      IO.puts("No farseer version specified in the configuration")
      System.halt(1)
    end
  end

  def load(path) do
    # should be
    # path |> read |> has_farseer |> has_endpoints
    yaml = Yaml.read(path)
    Yaml.has_farseer(yaml)
    Yaml.has_endpoints(yaml)
    yaml
  end
end
