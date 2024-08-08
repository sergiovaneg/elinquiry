alias AdventOfCode.Y2015.DinnerTable

defmodule AdventOfCode.Y2015.DinnerTable do
  @spec permutations([]) :: [[]]
  defp permutations([]), do: [[]]

  @spec permutations([...]) :: [[...], ...]
  defp permutations(list),
    do:
      for(
        elem <- list,
        rest <- permutations(list -- [elem]),
        do: [elem | rest]
      )

  @spec calculate_happiness(
          [binary(), ...],
          %{{binary(), binary()} => integer()}
        ) :: integer()
  defp calculate_happiness(seating, rel_happiness) do
    seating
    |> Enum.chunk_every(2, 1, seating)
    |> Enum.reduce(0, fn [a, b], acc ->
      acc
      |> Kernel.+(rel_happiness |> Map.get({a, b}, 0))
      |> Kernel.+(rel_happiness |> Map.get({b, a}, 0))
    end)
  end

  defp parse_happiness(line) do
    [num] = ~r/([0-9]+)/ |> Regex.run(line, capture: :first)

    val =
      if line |> String.contains?("lose") do
        ("-" <> num) |> String.to_integer()
      else
        num |> String.to_integer()
      end

    elems = line |> String.trim(".") |> String.split()
    {{elems |> List.first(), elems |> List.last()}, val}
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    rel_happiness =
      contents
      |> String.split("\n")
      |> Enum.map(&parse_happiness/1)
      |> Map.new()

    rel_happiness
    |> Map.keys()
    |> Enum.map(fn {a, _} -> a end)
    |> Enum.uniq()
    |> permutations()
    |> Enum.map(&calculate_happiness(&1, rel_happiness))
    |> Enum.max()
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    rel_happiness =
      contents
      |> String.split("\n")
      |> Enum.map(&parse_happiness/1)
      |> Map.new()

    [
      "Me"
      | rel_happiness
        |> Map.keys()
        |> Enum.map(fn {a, _} -> a end)
        |> Enum.uniq()
    ]
    |> permutations()
    |> Enum.map(&calculate_happiness(&1, rel_happiness))
    |> Enum.max()
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> DinnerTable.part1()
|> IO.puts()

contents
|> DinnerTable.part2()
|> IO.puts()
