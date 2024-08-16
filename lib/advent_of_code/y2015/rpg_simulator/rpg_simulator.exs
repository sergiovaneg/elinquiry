alias AdventOfCode.Y2015.RPGSimulator

defmodule Item do
  defstruct cost: 0, dmg: 0, arm: 0
end

defmodule AdventOfCode.Y2015.RPGSimulator do
  @boss_hp 104
  @boss_dmg 8
  @boss_arm 1

  @type shop :: [[%Item{}, ...], ...]

  @spec parse_item(binary()) :: %Item{
          cost: non_neg_integer(),
          dmg: non_neg_integer(),
          arm: non_neg_integer()
        }
  defp parse_item(line) do
    [cost, dmg, arm] =
      ~r/([0-9]+)/
      |> Regex.scan(line, capture: :first)
      |> Enum.take(-3)
      |> Enum.map(fn [x] -> x |> String.to_integer() end)

    %Item{
      cost: cost,
      dmg: dmg,
      arm: arm
    }
  end

  @spec parse_shop(binary()) :: shop()
  defp parse_shop(contents) do
    contents
    |> String.split("\n\n")
    |> Enum.map(fn block ->
      block
      |> String.split("\n")
      |> Enum.filter(&String.match?(&1, ~r/([0-9]+)/))
      |> Enum.map(&parse_item/1)
    end)
  end

  @spec get_item_sets(shop()) :: [%Item{}, ...]
  defp get_item_sets([weapons, armours, rings]) do
    # Heuristic combination filter
    ring_combinations =
      for(rl <- [%Item{} | rings], rr <- [%Item{} | rings], do: [rl, rr])
      |> Enum.uniq_by(fn [rl, rr] ->
        %Item{
          cost: rl.cost + rr.cost,
          dmg: rl.dmg + rr.dmg,
          arm: rl.arm + rr.arm
        }
      end)

    for w <- weapons,
        a <- [%Item{} | armours],
        [rl, rr] <- ring_combinations do
      # Virtual item aggregating all attributes
      %Item{
        cost: w.cost + a.cost + rl.cost + rr.cost,
        dmg: w.dmg + a.dmg + rl.dmg + rr.dmg,
        arm: w.arm + a.arm + rl.arm + rr.arm
      }
    end
  end

  @spec is_winning_set?(%Item{}) :: boolean()
  defp is_winning_set?(item_set) do
    ceil(@boss_hp / max(1, item_set.dmg - @boss_arm)) <=
      ceil(100 / max(1, @boss_dmg - item_set.arm))
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> parse_shop()
    |> get_item_sets()
    |> Enum.filter(&is_winning_set?/1)
    |> Enum.map(fn item_set -> item_set.cost end)
    |> Enum.min()
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    contents
    |> parse_shop()
    |> get_item_sets()
    |> Enum.filter(fn item_set -> !is_winning_set?(item_set) end)
    |> Enum.map(fn item_set -> item_set.cost end)
    |> Enum.max()
  end
end

contents = File.read!("./shop.txt") |> String.trim()

contents
|> RPGSimulator.part1()
|> IO.puts()

contents
|> RPGSimulator.part2()
|> IO.puts()
