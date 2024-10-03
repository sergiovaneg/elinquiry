alias AdventOfCode.Y2016.LikeRogue

defmodule AdventOfCode.Y2016.LikeRogue do
  defp parse_row(line) do
    line
    |> String.graphemes()
    |> Enum.map(&Kernel.==(&1, "."))
  end

  defp get_next(row) do
    [true | row]
    |> Enum.chunk_every(3, 1, [true])
    |> Enum.map(fn [l, _, r] -> l == r end)
  end

  defp count_safe(contents, n_rows) do
    1..n_rows
    |> Enum.reduce({contents |> parse_row(), 0}, fn _, {last_row, acc} ->
      {last_row |> get_next(), acc + (last_row |> Enum.count(& &1))}
    end)
    |> then(fn {_, n_safe} -> n_safe end)
  end

  def part1(contents) do
    contents
    |> count_safe(40)
  end

  def part2(contents) do
    contents
    |> count_safe(400_000)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> LikeRogue.part1()
|> IO.puts()

contents
|> LikeRogue.part2()
|> IO.puts()
