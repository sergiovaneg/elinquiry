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
       |> Enum.map(fn idx ->
         {pairs, singles} =
           floors
           |> Enum.at(idx)
           |> Enum.group_by(&String.first/1)
           |> Enum.split_with(fn {_k, v} -> length(v) == 2 end)

         {gens, micros} =
           singles
           |> Enum.split_with(fn {_k, [v]} ->
             v |> String.graphemes() |> List.last() == "G"
           end)

         to_string(idx) <>
           String.duplicate("P", length(pairs)) <>
           String.duplicate("G", length(gens)) <>
           String.duplicate("M", length(micros))
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
    if f |> Enum.all?(&String.contains?(&1, "M")) do
      # Only Microchips in this floor
      true
    else
      # Only Generators alone in this floor
      f
      |> Enum.group_by(&String.first/1)
      |> Map.values()
      |> Enum.filter(fn v -> length(v) == 1 end)
      |> List.flatten()
      |> Enum.all?(&String.contains?(&1, "G"))
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

  @spec get_next_generation(state(), record()) :: [state(), ...]
  defp get_next_generation({idx, floors}, rec) do
    current = floors |> Enum.at(idx)

    to_remove =
      (comb(1, current) ++ comb(2, current))
      |> Enum.filter(fn subset -> is_valid_floor?(current -- subset) end)

    top =
      (idx + 1)
      |> controlled_insert(to_remove, floors)
      |> then(fn new_floors ->
        max_length =
          new_floors
          |> Enum.map(&length/1)
          |> Enum.max(fn -> 0 end)

        new_floors |> Enum.filter(&(length(&1) == max_length))
      end)
      |> Enum.map(fn new_floor ->
        {idx + 1,
         floors
         |> List.replace_at(idx + 1, new_floor)
         |> List.update_at(idx, &(&1 -- new_floor))}
      end)

    bot =
      (idx - 1)
      |> controlled_insert(to_remove, floors)
      |> then(fn new_floors ->
        min_length =
          new_floors
          |> Enum.map(&length/1)
          |> Enum.min(fn -> 0 end)

        new_floors |> Enum.filter(&(length(&1) == min_length))
      end)
      |> Enum.map(fn new_floor ->
        {idx - 1,
         floors
         |> List.replace_at(idx - 1, new_floor)
         |> List.update_at(idx, &(&1 -- new_floor))}
      end)

    (top ++ bot)
    |> Enum.filter(&(not is_map_key(rec, &1 |> hash_state())))
  end

  defp iterate(states, steps, rec) do
    next_gen =
      states
      |> Enum.flat_map(fn state ->
        get_next_generation(state, rec)
      end)
      |> Enum.uniq_by(&hash_state/1)

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
