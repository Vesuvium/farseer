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
  GET "/hello/world" will be {"GET", "", "hello", "world"}
  """
  def id(method, path) do
    [method | String.split(path, "/")] |> List.to_tuple()
  end

  @doc """
  Transforms an id into a templated id, e.g. {"GET", "", "hello", "1"} to
  {"GET", "", "hello", :"$1"}, so that it can match
  {"GET", "", "hello", "{{id}}"}
  """
  def templated_id(id) do
    id
    |> Tuple.to_list()
    |> List.replace_at(tuple_size(id) - 1, :"$1")
    |> List.to_tuple()
  end

  def insert(method, path, handler, path_rules, method_rules) do
    :ets.insert(
      Ets.table(),
      {Ets.id(method, path), handler, path_rules, method_rules}
    )
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
    id = Ets.id(method, path)
    table = Ets.table()
    result = :ets.lookup(table, id)

    if result == [] do
      :ets.match_object(table, {Ets.templated_id(id), :"$2", :"$3", :"$4"})
    else
      result
    end
  end
end
