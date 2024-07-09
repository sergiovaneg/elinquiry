defmodule AdventOfCode.Y2015.NotQuiteLisp do
  def part1(contents) do
    contents
    |> String.graphemes()
    |> Enum.map(&char_to_int/1)
    |> Enum.sum()
  end

  def part2(contents) do
    contents
    |> String.graphemes()
    |> Enum.map(&char_to_int/1)
    |> Enum.scan(&(&1 + &2))
    |> Enum.find_index(fn x -> x == -1 end)
    |> Kernel.+(1)
  end

  defp char_to_int(x) do
    case x do
      "(" -> 1
      ")" -> -1
      _ -> 0
    end
  end
end

contents = File.read!("./input.txt")

IO.puts(AdventOfCode.Y2015.NotQuiteLisp.part1(contents))
IO.puts(AdventOfCode.Y2015.NotQuiteLisp.part2(contents))
