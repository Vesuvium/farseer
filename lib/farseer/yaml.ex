defmodule Farseer.Yaml do
  @moduledoc """
  Wrapper for YamlElixir, responsible for getting the yaml and validating it.
  """

  def read(path) do
    case YamlElixir.read_from_file(path) do
      {:ok, yaml} ->
        yaml

      {:error, _error} ->
        nil
    end
  end

  def read do
    read("farseer.yml")
  end

  @doc "Check the yaml has an endpoints key"
  def has_endpoints(yaml) do
    unless Map.has_key?(yaml, "endpoints") do
      raise "No endpoints found in the configuration"
    end
  end

  def has_farseer(yaml) do
    unless Map.has_key?(yaml, "farseer") do
      raise "No farseer version specified in the configuration"
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
