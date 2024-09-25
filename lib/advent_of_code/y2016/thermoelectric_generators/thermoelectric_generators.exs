alias AdventOfCode.Y2016.ThermoelectricGenerators

defmodule AdventOfCode.Y2016.ThermoelectricGenerators do
  @typep floor :: [binary(), ...]
  @typep state :: {integer(), [floor, ...]}
  @typep record :: %{binary() => boolean()}
  @n_floors 4

  @spec hash_state(state()) :: binary()
  defp hash_state({elevator_idx, floors}) do
    (elevator_idx |> to_string()) <>
      (0..(@n_floors - 1)
       |> Enum.map(fn current_idx ->
         {pairs, singles} =
           floors
           |> Enum.at(current_idx)
           |> Enum.group_by(&String.first/1)
           |> Enum.split_with(fn {_k, v} -> length(v) == 2 end)

         to_string(current_idx) <>
           String.duplicate("P", length(pairs)) <>
           (singles
            |> Enum.map(fn {_k, [v]} ->
              v |> String.last()
            end)
            |> Enum.sort()
            |> Enum.join())
       end)
       |> Enum.join())
  end

  defp comb(0, _), do: [[]]
  defp comb(_, []), do: []

  defp comb(n, [h | t]) do
    comb(n, t) ++ for l <- comb(n - 1, t), do: [h | l]
  end

  @spec is_valid_floor?(floor()) :: boolean()
  defp is_valid_floor?(f) do
    if f |> Enum.all?(&String.ends_with?(&1, "M")) do
      # Only Microchips in this floor
      true
    else
      # Only Generators alone in this floor
      f
      |> Enum.group_by(&String.first/1)
      |> Map.values()
      |> Enum.filter(&(length(&1) == 1))
      |> List.flatten()
      |> Enum.all?(&String.ends_with?(&1, "G"))
    end
  end

  defp is_final?({_idx, floors}) do
    floors
    |> Enum.take(@n_floors - 1)
    |> Enum.all?(&Enum.empty?/1)
  end

  @spec elevator_filter(integer(), [[binary()]], [floor()]) :: [floor()]
  defp elevator_filter(n, _, _) when n in [-1, @n_floors], do: []

  defp elevator_filter(n, subsets, floors) do
    target_floor = floors |> Enum.at(n)

    subsets
    |> Enum.filter(&is_valid_floor?(&1 ++ target_floor))
  end

  @spec get_next_generation(state()) :: [state(), ...]
  defp get_next_generation({current_idx, floors}) do
    current = floors |> Enum.at(current_idx)

    to_remove =
      (comb(1, current) ++ comb(2, current))
      |> Enum.filter(fn subset -> is_valid_floor?(current -- subset) end)

    [{current_idx + 1, &Enum.max/1}, {current_idx - 1, &Enum.min/1}]
    |> Enum.flat_map(fn {target_idx, target_fn} ->
      target_idx
      |> elevator_filter(to_remove, floors)
      # Optimal occupancy filter
      |> then(fn candidates ->
        if Enum.empty?(candidates) do
          []
        else
          target_len =
            candidates
            |> Enum.map(&length/1)
            |> target_fn.()

          candidates
          |> Enum.filter(&(length(&1) == target_len))
        end
      end)
      |> Enum.map(fn candidate ->
        {target_idx,
         floors
         |> List.update_at(target_idx, &(&1 ++ candidate))
         |> List.update_at(current_idx, &(&1 -- candidate))}
      end)
    end)
  end

  @spec iterate(record(), state(), non_neg_integer()) :: non_neg_integer()
  defp iterate(rec, states, steps) do
    next_gen =
      states
      |> Enum.flat_map(&get_next_generation/1)
      |> Enum.uniq_by(&hash_state/1)
      |> Enum.filter(&(not is_map_key(rec, hash_state(&1))))

    if next_gen |> Enum.any?(&is_final?/1) do
      steps + 1
    else
      next_gen
      |> Enum.reduce(rec, fn state, record ->
        record |> Map.put(hash_state(state), true)
      end)
      |> iterate(next_gen, steps + 1)
    end
  end

  @spec iterate([floor()]) :: non_neg_integer()
  defp iterate(floors) do
    initial_state = {0, floors}
    iterate(%{hash_state(initial_state) => true}, [initial_state], 0)
  end

  @spec parse_floor(binary()) :: floor()
  defp parse_floor(line) do
    generators =
      ~r/([a-z]+) generator/
      |> Regex.scan(line, capture: :all_but_first)
      |> Enum.map(fn [element] ->
        (element |> String.first() |> String.capitalize()) <> "G"
      end)

    microchips =
      ~r/([a-z]+)-compatible microchip/
      |> Regex.scan(line, capture: :all_but_first)
      |> Enum.map(fn [element] ->
        (element |> String.first() |> String.capitalize()) <> "M"
      end)

    generators ++ microchips
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(&parse_floor/1)
    |> iterate()
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    contents
    |> String.split("\n")
    |> List.update_at(0, fn first_floor ->
      first_floor <>
        " Also, an elerium generator, an elerium-compatible microchip, a dilithium generator, and a dilithium-compatible microchip."
    end)
    |> Enum.map(&parse_floor/1)
    |> iterate()
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> ThermoelectricGenerators.part1()
|> IO.puts()

contents
|> ThermoelectricGenerators.part2()
|> IO.puts()
