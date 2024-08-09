alias AdventOfCode.Y2015.ReindeerOlympics

defmodule AdventOfCode.Y2015.ReindeerOlympics do
  @t_limit 2503

  @spec get_reindeer_trajectory({integer(), integer(), integer()}) ::
          [pos_integer(), ...]
  defp get_reindeer_trajectory({speed, t1, t2}) do
    0..(@t_limit - 1)
    |> Enum.scan(0, fn t, x ->
      if t |> rem(t1 + t2) < t1 do
        x + speed
      else
        x
      end
    end)
  end

  @spec parse_reindeer(binary()) :: {integer(), integer(), integer()}
  defp parse_reindeer(line) do
    ~r/([0-9]+)/
    |> Regex.scan(line, capture: :first)
    |> Enum.take(3)
    |> Enum.map(fn [num] -> num |> String.to_integer() end)
    |> List.to_tuple()
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> parse_reindeer()
      |> get_reindeer_trajectory()
      |> List.last()
    end)
    |> Enum.max()
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    trajectories =
      contents
      |> String.split("\n")
      |> Enum.map(fn line ->
        line
        |> parse_reindeer()
        |> get_reindeer_trajectory()
      end)

    leads =
      trajectories
      |> Enum.zip_with(&Enum.max/1)

    trajectories
    |> Enum.map(fn trajectory ->
      trajectory
      |> Enum.zip_reduce(leads, 0, fn x, y, acc ->
        if x >= y do
          acc + 1
        else
          acc
        end
      end)
    end)
    |> Enum.max()
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> ReindeerOlympics.part1()
|> IO.puts()

contents
|> ReindeerOlympics.part2()
|> IO.puts()
