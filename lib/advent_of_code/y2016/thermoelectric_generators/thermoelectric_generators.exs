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

  @spec controlled_insert(integer(), [[binary()]], [floor()]) :: [floor()]
  defp controlled_insert(n, _, _) when n in [-1, @n_floors], do: []

  defp controlled_insert(n, subsets, floors) do
    target_floor = floors |> Enum.at(n)

    for subset <- subsets,
        candidate = subset ++ target_floor,
        is_valid_floor?(candidate) do
      candidate
    end
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
      |> controlled_insert(to_remove, floors)
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
      |> Enum.map(fn new_floor ->
        {target_idx,
         floors
         |> List.replace_at(target_idx, new_floor)
         |> List.update_at(current_idx, &(&1 -- new_floor))}
      end)
    end)
  end

  @spec iterate(state(), non_neg_integer(), record()) :: non_neg_integer()
  defp iterate(states, steps, rec) do
    next_gen =
      states
      |> Enum.flat_map(&get_next_generation/1)
      |> Enum.uniq_by(&hash_state/1)
      |> Enum.filter(&(not is_map_key(rec, &1 |> hash_state())))

    if next_gen |> Enum.find(&is_final?/1) != nil do
      steps + 1
    else
      next_gen
      |> Enum.reduce(rec, fn state, record ->
        record |> Map.put(state |> hash_state(), true)
      end)
      |> then(&iterate(next_gen, steps + 1, &1))
    end
  end

  @spec iterate([floor()]) :: non_neg_integer()
  defp iterate(floors) do
    initial_state = {0, floors}
    iterate([initial_state], 0, %{hash_state(initial_state) => true})
  end

  @spec parse_floor(binary()) :: floor()
  defp parse_floor(line) do
    generators =
      ~r/([a-z]+) generator/
      |> Regex.scan(line, capture: :all_but_first)
      |> Enum.map(fn [element] ->
        (element |> String.capitalize() |> String.first()) <> "G"
      end)

    microchips =
      ~r/([a-z]+)-compatible microchip/
      |> Regex.scan(line, capture: :all_but_first)
      |> Enum.map(fn [element] ->
        (element |> String.capitalize() |> String.first()) <> "M"
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
