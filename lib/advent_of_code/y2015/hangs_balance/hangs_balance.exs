alias AdventOfCode.Y2015.HangsBalance

defmodule AdventOfCode.Y2015.HangsBalance do
  defp combine(_, 0), do: [[]]
  defp combine([], _), do: []

  defp combine([h | t], k) do
    (t |> combine(k)) ++
      for(
        e <- t |> combine(k - 1),
        do: [h | e]
      )
  end

  defp test_n(weights, 1, target), do: weights |> Enum.sum() == target

  defp test_n(weights, n, target) do
    1..length(weights)
    |> Enum.reduce_while(false, fn k, _ ->
      candidates =
        weights
        |> combine(k)
        |> Enum.filter(fn g -> g |> Enum.sum() == target end)
        |> Enum.filter(fn g -> (weights -- g) |> test_n(n - 1, target) end)

      if length(candidates) == 0 do
        {:cont, false}
      else
        {:halt, true}
      end
    end)
  end

  defp solve_n(weights, n) do
    target = weights |> Enum.sum() |> Kernel./(n) |> round()

    1..length(weights)
    |> Enum.reduce_while([[]], fn k, _ ->
      candidates =
        weights
        |> combine(k)
        |> Enum.filter(fn g -> g |> Enum.sum() == target end)
        |> Enum.filter(fn g -> (weights -- g) |> test_n(n - 1, target) end)

      if length(candidates) == 0 do
        {:cont, [[]]}
      else
        {:halt, candidates |> Enum.map(&Enum.product/1) |> Enum.min()}
      end
    end)
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    weights =
      contents
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)
      |> Enum.sort()

    weights |> solve_n(3)
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    weights =
      contents
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)
      |> Enum.sort()

    weights |> solve_n(4)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> HangsBalance.part1()
|> IO.puts()

contents
|> HangsBalance.part2()
|> IO.puts()
