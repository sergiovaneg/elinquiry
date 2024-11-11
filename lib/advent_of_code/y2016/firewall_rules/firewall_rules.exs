alias AdventOfCode.Y2016.FirewallRules

defmodule AdventOfCode.Y2016.FirewallRules do
  defp parse_range(line) do
    [[a], [b]] =
      ~r/[0-9]+/
      |> Regex.scan(line, capture: :first)

    {
      a |> String.to_integer(),
      b |> String.to_integer()
    }
  end

  defp get_sorted_ranges(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(&parse_range/1)
    |> Enum.sort_by(fn {a, _b} -> a end)
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    case contents |> get_sorted_ranges() do
      [{0, first_b} | tail] ->
        tail
        |> Enum.reduce_while(first_b, fn {a, b}, top ->
          if top < a - 1 do
            {:halt, top + 1}
          else
            {:cont, max(top, b)}
          end
        end)

      _ ->
        0
    end
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    contents
    |> get_sorted_ranges()
    |> then(fn [init | tail] ->
      tail
      |> Enum.reduce([init], fn {c, d}, [{a, b} | acc] ->
        if b >= c - 1 do
          [{a, max(b, d)} | acc]
        else
          [{c, d} | [{a, b} | acc]]
        end
      end)
    end)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(0, fn [{c, _d}, {_a, b}], avail ->
      avail + c - b - 1
    end)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> FirewallRules.part1()
|> IO.inspect()

contents
|> FirewallRules.part2()
|> IO.inspect()
