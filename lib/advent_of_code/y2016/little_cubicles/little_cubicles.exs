alias AdventOfCode.Y2016.LittleCubicles

defmodule AdventOfCode.Y2016.LittleCubicles do
  @favourite_number 1362
  @target {31, 39}
  @n_steps 50

  @typep coordinates :: {non_neg_integer(), non_neg_integer()}
  @typep record :: %{coordinates() => boolean()}

  @spec is_wall?(coordinates()) :: boolean()
  defp is_wall?({x, y}) do
    (x * (x + Bitwise.<<<(y, 1) + 3) + y * (y + 1) + @favourite_number)
    |> Integer.to_string(2)
    |> String.graphemes()
    |> Enum.reduce(false, &((&1 == "1" and not &2) or (&1 == "0" and &2)))
  end

  @spec get_next_gen(coordinates(), record()) :: {[coordinates()], record()}
  defp get_next_gen({x0, y0}, rec) do
    [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]
    |> Enum.map(fn {dx, dy} -> {max(0, x0 + dx), max(0, y0 + dy)} end)
    |> Enum.filter(&(not Map.has_key?(rec, &1)))
    |> then(fn explorers ->
      {
        explorers
        |> Enum.filter(&(!is_wall?(&1))),
        explorers
        |> Enum.reduce(rec, &Map.put(&2, &1, true))
      }
    end)
  end

  @spec navigate([coordinates()], record(), non_neg_integer()) ::
          non_neg_integer()
  defp navigate(explorers, rec, steps) do
    if @target in explorers do
      steps
    else
      explorers
      |> Enum.flat_map_reduce(rec, &get_next_gen/2)
      |> then(fn {next_gen, new_rec} ->
        navigate(next_gen, new_rec, steps + 1)
      end)
    end
  end

  @spec navigate(coordinates()) :: non_neg_integer()
  defp navigate(ic) do
    navigate([ic], %{ic => true}, 0)
  end

  @spec part1() :: non_neg_integer()
  def part1() do
    {1, 1}
    |> navigate()
  end

  @spec chart(coordinates(), non_neg_integer()) :: [coordinates()]
  defp chart(ic, step_limit \\ @n_steps) do
    1..step_limit//1
    |> Enum.reduce(
      {[ic], %{ic => true}},
      fn _, {explorers, rec} ->
        explorers
        |> Enum.flat_map_reduce(rec, &get_next_gen/2)
      end
    )
    |> then(fn {_, final_record} ->
      final_record
      |> Map.keys()
    end)
    |> Enum.filter(&(not is_wall?(&1)))
  end

  @spec part1() :: non_neg_integer()
  def part2() do
    {1, 1}
    |> chart()
    |> length()
  end
end

LittleCubicles.part1()
|> IO.puts()

LittleCubicles.part2()
|> IO.puts()
