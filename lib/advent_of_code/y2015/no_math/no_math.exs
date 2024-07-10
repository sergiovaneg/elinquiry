alias AdventOfCode.Y2015.NoMath

defmodule AdventOfCode.Y2015.NoMath do
  @spec get_dimensions(binary()) :: list(non_neg_integer())
  defp get_dimensions(line) do
    line
    |> String.split("x")
    |> Enum.map(&String.to_integer/1)
  end

  @spec get_sides(list(non_neg_integer())) :: list(non_neg_integer())
  defp get_sides(dimensions) do
    x = Enum.with_index(dimensions)
    for {x1, i1} <- x, {x2, i2} <- x, i1 < i2, do: x1 * x2
  end

  @spec get_paper(list(non_neg_integer())) :: non_neg_integer()
  defp get_paper(sides) do
    sides |> Enum.sum() |> Kernel.*(2) |> Kernel.+(Enum.min(sides))
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(&get_dimensions/1)
    |> Enum.map(&get_sides/1)
    |> Enum.map(&get_paper/1)
    |> Enum.sum()
  end

  @spec get_ribbon(list(non_neg_integer())) :: non_neg_integer()
  defp get_ribbon(dimensions) do
    dimensions
    |> Enum.sort()
    |> Enum.take(2)
    |> Enum.sum()
    |> Kernel.*(2)
    |> Kernel.+(Enum.product(dimensions))
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(&get_dimensions/1)
    |> Enum.map(&get_ribbon/1)
    |> Enum.sum()
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> NoMath.part1()
|> IO.puts()

contents
|> NoMath.part2()
|> IO.puts()
