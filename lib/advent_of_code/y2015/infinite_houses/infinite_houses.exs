alias AdventOfCode.Y2015.InfiniteHouses

defmodule AdventOfCode.Y2015.InfiniteHouses do
  @spec get_factors(pos_integer(), pos_integer() | nil) :: [pos_integer(), ...]
  defp get_factors(n, limit) do
    1..trunc(:math.sqrt(n))
    |> Enum.map(fn x -> [x, div(n, x)] end)
    |> Enum.filter(fn [x, y] -> x * y == n end)
    |> then(fn factors ->
      if limit != nil do
        factors
        |> Enum.map(fn [x, y] ->
          cond do
            x <= limit && y <= limit -> [x, y]
            x <= limit -> [y]
            y <= limit -> [x]
            true -> []
          end
        end)
      else
        factors
      end
    end)
    |> List.flatten()
    |> Enum.uniq()
  end

  defp recursive_call(x, target, limit \\ nil) do
    if x |> get_factors(limit) |> Enum.sum() >= target do
      x
    else
      recursive_call(x + 1, target, limit)
    end
  end

  def part1(target) do
    1 |> recursive_call(target / 10)
  end

  def part2(target) do
    1 |> recursive_call(target / 11, 50)
  end
end

36_000_000
|> InfiniteHouses.part1()
|> IO.puts()

36_000_000
|> InfiniteHouses.part2()
|> IO.puts()
