alias AdventOfCode.Y2015.HungryPeople

defmodule AdventOfCode.Y2015.HungryPeople do
  @typep ingredient :: %{binary() => integer()}
  @typep recipe :: %{ingredient() => non_neg_integer()}

  @spec parse_ingredient(binary()) :: ingredient
  defp parse_ingredient(line) do
    ~r/(?<name>[a-z]+) (?<val>-*[0-9]+)/
    |> Regex.scan(line, capture: :all_names)
    |> Map.new(fn [name, num] -> {name, num |> String.to_integer()} end)
  end

  @spec cal_constraint(recipe()) :: boolean()
  defp cal_constraint(rec) do
    rec
    |> Enum.map(fn {ing, qty} -> qty * ing["calories"] end)
    |> Enum.sum()
    |> Kernel.==(500)
  end

  @spec score_recipe(recipe()) :: integer()
  defp score_recipe(rec) do
    rec
    |> Enum.map(fn {ing, qty} ->
      ing
      |> Enum.map(fn {name, val} -> {name, val * qty} end)
    end)
    |> List.flatten()
    |> Enum.group_by(fn {k, _} -> k end, fn {_, v} -> v end)
    |> Map.drop(["calories"])
    |> Enum.reduce(1, fn {_, vals}, acc ->
      vals |> Enum.sum() |> Kernel.max(0) |> Kernel.*(acc)
    end)
  end

  defp gen_valid_recipes([last_ing], capacity), do: [[{last_ing, capacity}]]

  defp gen_valid_recipes(ingredients, capacity) do
    [ing | rest] = ingredients

    for(
      qty <- 0..capacity,
      perm <- gen_valid_recipes(rest, capacity - qty),
      do: [{ing, qty} | perm]
    )
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(&parse_ingredient/1)
    |> gen_valid_recipes(100)
    |> Enum.map(&(&1 |> Map.new() |> score_recipe()))
    |> Enum.max()
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(&parse_ingredient/1)
    |> gen_valid_recipes(100)
    |> Enum.map(&Map.new/1)
    |> Enum.filter(&cal_constraint/1)
    |> Enum.map(&score_recipe/1)
    |> Enum.max()
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> HungryPeople.part1()
|> IO.puts()

contents
|> HungryPeople.part2()
|> IO.puts()
