defmodule Farseer.Endpoints do
  @moduledoc """
  Responsible for loading the yml file and making the needed transformations
  so that the endpoints map works with Plug.match
  """
  alias Farseer.Endpoints
  alias Farseer.Ets
  alias Farseer.Log
  alias Farseer.Rules

  @options_list ["to", "request_headers", "response"]

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

  def handler(%{"handler" => handler}), do: handler
  def handler(_rules), do: "Http"

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

  def register_method(path, handler, path_rules, method) do
    method_name = Endpoints.method_name(method)
    method_rules = Endpoints.method_rules(method, method_name)
    Log.endpoint(method_name, path)
    Ets.insert(method_name, path, handler, path_rules, method_rules)
  end

  def register_methods(path, handler, path_rules, %{"methods" => methods}) do
    Enum.each(methods, fn method ->
      Endpoints.register_method(path, handler, path_rules, method)
    end)
  end

  def register_methods(path, handler, path_rules, _rules) do
    Ets.insert("GET", path, handler, path_rules, nil)
  end

  @doc """
  Registers paths with the corresponding rules.
  """
  def register(path, rules) do
    handler = Endpoints.handler(rules)
    path_rules = Endpoints.options(rules)
    Endpoints.register_methods(path, handler, path_rules, rules)
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
