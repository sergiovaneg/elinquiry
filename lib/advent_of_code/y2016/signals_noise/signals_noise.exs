alias AdventOfCode.Y2016.SignalsNoise

defmodule AdventOfCode.Y2016.SignalsNoise do
  @spec part1(binary()) :: binary()
  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip_reduce("", fn col, acc ->
      frequencies = col |> Enum.frequencies()

      acc <>
        (frequencies
         |> Map.keys()
         |> Enum.max_by(&frequencies[&1]))
    end)
  end

  @spec part2(binary()) :: binary()
  def part2(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip_reduce("", fn col, acc ->
      frequencies = col |> Enum.frequencies()

      acc <>
        (frequencies
         |> Map.keys()
         |> Enum.min_by(&frequencies[&1]))
    end)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> SignalsNoise.part1()
|> IO.puts()

contents
|> SignalsNoise.part2()
|> IO.puts()
