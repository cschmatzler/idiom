defmodule Idiom.IdiomTest do
  use ExUnit.Case, async: true

  import Idiom

  alias Idiom.Cache

  setup_all do
    "test/data.json"
    |> File.read!()
    |> Jason.decode!()
    |> Cache.init()
  end

  doctest Idiom
end
