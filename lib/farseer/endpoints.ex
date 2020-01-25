defmodule Farseer.Endpoints do
  @moduledoc """
  Responsible for loading the yml file and making the needed transformations
  so that the endpoints map works with Plug.match
  """
  alias Farseer.Endpoints
  alias Farseer.Ets
  alias Farseer.Rules

  @options_list ["to", "request_headers"]

  @doc """
  Get the endpoints from the yaml file.
  """
  def endpoints() do
    Confex.get_env(:farseer, :yaml_file)
    |> Rules.parse()
    |> Rules.endpoints()
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
  def method_name(method) when is_map(method) do
    method |> Map.keys() |> List.first() |> String.upcase()
  end

  def method_name(method) do
    String.upcase(method)
  end

  def method_rules(method, method_name) do
    if is_map(method) do
      method[String.downcase(method_name)]
    end
  end

  def register_methods(path, path_rules, methods) do
    Enum.each(methods, fn method ->
      method_name = Endpoints.method_name(method)
      method_rules = Endpoints.method_rules(method, method_name)
      Ets.insert(method_name, path, path_rules, method_rules)
    end)
  end

  @doc """
  Registers paths with the corresponding rules.
  """
  def register(path, rules) do
    path_rules = Endpoints.options(rules)

    if Map.has_key?(rules, "methods") do
      Endpoints.register_methods(path, path_rules, rules["methods"])
    else
      Ets.insert("GET", path, path_rules, nil)
    end
  end

  @doc """
  Inits the ets table and registers and all paths.
  """
  def init() do
    Ets.create_table()

    Enum.each(Endpoints.endpoints(), fn {path, rules} ->
      Endpoints.register(path, rules)
    end)
  end
end
