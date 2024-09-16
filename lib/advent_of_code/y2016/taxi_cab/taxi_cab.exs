alias AdventOfCode.Y2016.TaxiCab

defmodule AdventOfCode.Y2016.TaxiCab do
  defp mutate_direction({vx, vy}, inst) do
    case inst |> String.first() do
      "R" ->
        {vy, -vx}

      "L" ->
        {-vy, vx}

      "F" ->
        {vx, vy}
    end
  end

  defp execute_inst(inst, {x0, y0, vx0, vy0}) do
    {vx, vy} = {vx0, vy0} |> mutate_direction(inst)
    n = inst |> String.slice(1..-1//1) |> String.to_integer()
    {x0 + vx * n, y0 + vy * n, vx, vy}
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    {x, y, _, _} =
      contents
      |> String.split(", ")
      |> Enum.reduce({0, 0, 0, 1}, fn inst, state ->
        execute_inst(inst, state)
      end)

    abs(x) + abs(y)
  end

  defp unroll_instruction(inst) do
    n = inst |> String.slice(1..-1//1) |> String.to_integer()

    [
      (inst |> String.first()) <> "1"
      | 2..n//1
        |> Enum.map(fn _ -> "F1" end)
    ]
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    {{x, y, _, _}, _} =
      contents
      |> String.split(", ")
      |> Enum.map(&unroll_instruction/1)
      |> List.flatten()
      |> Enum.reduce_while(
        {{0, 0, 0, 1}, %{{0, 0} => true}},
        fn inst, {state, registry} ->
          new_state = inst |> execute_inst(state)
          {x, y, _, _} = new_state

          if registry |> Map.get({x, y}, false) do
            {:halt, {new_state, registry}}
          else
            {:cont,
             {
               new_state,
               registry
               |> Map.put({x, y}, true)
             }}
          end
        end
      )

    abs(x) + abs(y)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> TaxiCab.part1()
|> IO.puts()

contents
|> TaxiCab.part2()
|> IO.puts()
