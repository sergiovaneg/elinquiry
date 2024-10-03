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

  def count_safe(contents, n_rows) do
    1..n_rows
    |> Enum.reduce({contents |> parse_row(), 0}, fn _, {last_row, acc} ->
      {last_row |> get_next(), acc + (last_row |> Enum.count(& &1))}
    end)
    |> then(fn {_, n_safe} -> n_safe end)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> LikeRogue.count_safe(40)
|> IO.puts()

contents
|> LikeRogue.count_safe(400_000)
|> IO.puts()
