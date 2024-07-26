alias AdventOfCode.Y2015.SingleNight

defmodule AdventOfCode.Y2015.SingleNight do
  @spec perm([]) :: [[]]
  def perm([]), do: [[]]

  @spec perm([...]) :: [[...], ...]
  def perm(list) do
    for(x <- list, rest <- perm(list -- [x]), do: [x | rest])
  end

  defp parse_edge(line) do
    line
    |> String.split([" to ", " = "])
    |> List.to_tuple()
  end

  @spec get_length([binary()], %{{binary(), binary()} => non_neg_integer()}) ::
          non_neg_integer()
  defp get_length(path, net) do
    [_ | destinations] = path

    [path, destinations]
    |> List.zip()
    |> Enum.map(fn x -> net[x] end)
    |> Enum.sum()
  end

  @spec get_perm_distances(binary()) :: [non_neg_integer()]
  def get_perm_distances(contents) do
    net =
      contents
      |> String.split("\n")
      |> Enum.map(&parse_edge/1)
      |> Enum.map(fn {a, b, c} ->
        d = c |> String.to_integer()
        [{{a, b}, d}, {{b, a}, d}]
      end)
      |> List.flatten()
      |> Map.new()

    net
    |> Map.keys()
    |> Enum.map(fn {a, _} -> a end)
    |> Enum.uniq()
    |> perm()
    |> Enum.map(fn x -> x |> get_length(net) end)
  end
end

contents = File.read!("./input.txt") |> String.trim()

perm_distances =
  contents
  |> SingleNight.get_perm_distances()

perm_distances
|> Enum.min()
|> IO.puts()

perm_distances
|> Enum.max()
|> IO.puts()
