defmodule Farseer.Ets do
  @moduledoc """
  Responsible for normalizing interactions with ets.
  """
  alias Farseer.Ets

  def table, do: Confex.get_env(:farseer, :table)

  def create_table do
    :ets.new(Ets.table(), [:set, :protected, :named_table])
  end

  @doc """
  The id of an entry is [method, path fragments]. For example,
  GET "/hello/world" will be ["GET", "", "hello", "world"]
  """
  def id(method, id) when is_tuple(id) do
    id
  end

  def id(method, path) do
    [method | String.split(path, "/")] |> List.to_tuple()
  end

  def insert(method, path, path_rules, method_rules) do
    :ets.insert(Ets.table(), {Ets.id(method, path), path_rules, method_rules})
  end

  @doc """
  Gets all ets entries. Used for debug purposes.
  """
  def all() do
    :ets.match(Ets.table(), {:"$1", :"$2", :"$3"})
  end

  @doc """
  Matches a given method and path.
  """
  def match(method, path) do
    :ets.lookup(Ets.table(), Ets.id(method, path))
  end
end
