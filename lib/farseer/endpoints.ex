defmodule Farseer.Endpoints do
  @moduledoc """
  Responsible for loading the yml file and making the needed transformations
  so that the endpoints map works with Plug.match
  """
  alias Farseer.Endpoints
  alias Farseer.Yaml

  @options_list ["to", "request_headers"]

  @doc """
  Get the endpoints from the yaml file.
  """
  def endpoints() do
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

  @doc """
  Finds the method name to store in the ets table.
  """
  def method_name(method) do
    if is_binary(method) do
      method |> String.upcase()
    else
      method |> Map.keys() |> List.first() |> String.upcase()
    end
  end

  def method_rules(method, method_name) do
    if is_map(method) do
      method[String.downcase(method_name)]
    end
  end

  def register_methods(table, path, path_rules, methods) do
    Enum.each(methods, fn method ->
      method_name = Endpoints.method_name(method)
      method_rules = Endpoints.method_rules(method, method_name)
      :ets.insert(table, {path, method_name, path_rules, method_rules})
    end)
  end

  @doc """
  Registers paths with the corresponding rules.
  """
  def register(table, path, rules) do
    path_rules = Endpoints.options(rules)

    if Map.has_key?(rules, "methods") do
      Endpoints.register_methods(table, path, path_rules, rules["methods"])
    else
      :ets.insert(table, {path, "GET", path_rules, nil})
    end
  end

  @doc """
  Inits the ets table and registers and all paths.
  """
  def init() do
    table = Confex.get_env(:farseer, :table)
    :ets.new(table, [:set, :protected, :named_table])

    Enum.each(Endpoints.endpoints(), fn {path, rules} ->
      Endpoints.register(table, path, rules)
    end)
  end
end
