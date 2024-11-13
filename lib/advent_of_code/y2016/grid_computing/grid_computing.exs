alias AdventOfCode.Y2016.GridComputing

defmodule AdventOfCode.Y2016.GridComputing do
  @typep grid_node :: %{
           x: non_neg_integer(),
           y: non_neg_integer(),
           used: non_neg_integer(),
           avail: non_neg_integer()
         }

  @spec parse_node(binary()) :: grid_node()
  defp parse_node(line) do
    [x, y, _size, used, avail, _usep] =
      ~r/[0-9]+/
      |> Regex.scan(line, capture: :first)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)

    %{
      x: x,
      y: y,
      used: used,
      avail: avail
    }
  end

  def part1(contents) do
    nodes =
      contents
      |> String.split("\n")
      |> Enum.filter(&String.starts_with?(&1, "/dev/grid/"))
      |> Enum.map(&parse_node/1)

    nodes
    |> Enum.filter(&(&1.used > 0))
    |> Enum.reduce(0, fn a_node, acc ->
      acc +
        (nodes
         |> Enum.filter(&(&1.x != a_node.x || &1.y != a_node.y))
         |> Enum.filter(&(&1.avail >= a_node.used))
         |> Enum.count())
    end)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> GridComputing.part1()
|> IO.inspect()
