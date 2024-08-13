alias AdventOfCode.Y2015.TooMuch

defmodule AdventOfCode.Y2015.TooMuch do
  @capacity 150
  defp filtered_combine([], _), do: []

  defp filtered_combine(elems, capacity) do
    for x <- elems, x == capacity do
      [x]
    end ++
      for idx <- -length(elems)..-1,
          x = elems |> Enum.at(idx),
          x < capacity,
          rest <- filtered_combine(elems |> Enum.take(idx + 1), capacity - x) do
        [x | rest]
      end
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
    |> filtered_combine(@capacity)
    |> length()
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    valid_combinations =
      contents
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)
      |> filtered_combine(@capacity)

    min_group_size = valid_combinations |> Enum.map(&length/1) |> Enum.min()

    valid_combinations
    |> Enum.filter(fn x -> length(x) == min_group_size end)
    |> length()
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> TooMuch.part1()
|> IO.inspect()

contents
|> TooMuch.part2()
|> IO.inspect()
