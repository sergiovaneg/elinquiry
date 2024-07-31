alias AdventOfCode.Y2015.AbacusFramework

defmodule AdventOfCode.Y2015.AbacusFramework do
  @type entry :: integer() | [...] | %{binary() => any()} | binary()

  @spec contains_invalid?(%{binary() => any()}, [binary(), ...]) :: boolean()
  def contains_invalid?(map, banned) do
    map
    |> Enum.map(fn {_, v} -> v in banned end)
    |> Enum.any?()
  end

  @spec get_value(entry(), [binary(), ...]) :: integer()

  def get_value(x, _) when is_integer(x) do
    x
  end

  def get_value(x, _) when is_binary(x) do
    0
  end

  def get_value(x, banned) when is_list(x) do
    x
    |> Enum.reduce(0, fn e, acc ->
      acc + get_value(e, banned)
    end)
  end

  def get_value(x, banned) when is_map(x) do
    if contains_invalid?(x, banned) do
      0
    else
      x
      |> Enum.reduce(0, fn {_, e}, acc ->
        acc + get_value(e, banned)
      end)
    end
  end
end

{:ok, contents} =
  File.cwd!()
  |> Path.join("lib/advent_of_code/y2015/abacus_framework/input.txt")
  |> File.read()

{:ok, json} = contents |> String.trim() |> Jason.decode()

json |> AbacusFramework.get_value([]) |> IO.puts()
json |> AbacusFramework.get_value(["red"]) |> IO.puts()
