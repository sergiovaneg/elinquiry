alias AdventOfCode.Y2016.ThreeSides

defmodule AdventOfCode.Y2016.ThreeSides do
  defp parse_triangle(line) do
    ~r/[0-9]+/
    |> Regex.scan(line)
    |> Enum.map(fn [num] -> num |> String.to_integer() end)
  end

  @spec is_valid_triangle?({
          pos_integer(),
          pos_integer(),
          pos_integer()
        }) :: boolean()
  defp is_valid_triangle?({a, b, c}) do
    a + b > c and a + c > b and b + c > a
  end

  @spec is_valid_triangle?([pos_integer(), ...]) :: boolean()
  defp is_valid_triangle?([a, b, c]) do
    {a, b, c} |> is_valid_triangle?()
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(&parse_triangle/1)
    |> Enum.count(&is_valid_triangle?/1)
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(&parse_triangle/1)
    |> Enum.chunk_every(3)
    |> Enum.map(&Enum.zip/1)
    |> List.flatten()
    |> Enum.count(&is_valid_triangle?/1)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> ThreeSides.part1()
|> IO.puts()

contents
|> ThreeSides.part2()
|> IO.puts()
