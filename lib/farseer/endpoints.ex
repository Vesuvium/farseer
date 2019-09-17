defmodule Farseer.Endpoints do
  @moduledoc """
  Responsible for loading the yml file and making the needed transformations
  so that the endpoints map works with Plug.match
  """
  alias Farseer.Yaml

  @options_list ["to", "request_headers"]

  def endpoints do
    Confex.get_env(:farseer, :yaml_file)
    |> Yaml.load()
    |> Map.get("endpoints")
  end

  def options(endpoint) do
    Enum.reduce(endpoint, %{}, fn {key, value}, acc ->
      if Enum.member?(@options_list, key) do
        Map.put(acc, key, value)
      else
        acc
      end
    end)
  end

  def register(table, endpoint) do
    options = Farseer.Endpoints.options(endpoint)

    if Map.has_key?(endpoint, "methods") do
      Enum.each(endpoint["methods"], fn method ->
        :ets.insert(
          table,
          {endpoint["path"], String.upcase(method), options}
        )
      end)
    else
      :ets.insert(table, {endpoint["path"], "GET", options})
    end
  end

  def init do
    table = Confex.get_env(:farseer, :table)
    :ets.new(table, [:set, :protected, :named_table])

    Enum.each(Farseer.Endpoints.endpoints(), fn {_name, endpoint} ->
      Farseer.Endpoints.register(table, endpoint)
    end)
  end
end
