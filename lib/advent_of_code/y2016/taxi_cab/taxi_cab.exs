alias AdventOfCode.Y2016.TaxiCab

defmodule AdventOfCode.Y2016.TaxiCab do
  defp mutate_direction({vx, vy}, inst) do
    if inst |> String.starts_with?("R") do
      {vy, -vx}
    else
      {-vy, vx}
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
      |> Enum.reduce({0, 0, 0, 1}, fn inst, state -> execute_inst(inst, state) end)

    abs(x) + abs(y)
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    {{x, y, _, _}, _} =
      contents
      |> String.split(", ")
      |> Enum.reduce_while(
        {{0, 0, 0, 1}, %{{0, 0} => 1}},
        fn inst, {{x0, y0, vx0, vy0}, registry} ->
          {vx, vy} = {vx0, vy0} |> mutate_direction(inst)

          {{x, y}, registry} =
            1..(inst |> String.slice(1..-1//1) |> String.to_integer())
            |> Enum.reduce_while(
              {{x0, y0}, registry},
              fn _, {{x0, y0}, registry} ->
                pos = {x0 + vx, y0 + vy}

                registry =
                  registry
                  |> Map.update(
                    pos,
                    1,
                    &Kernel.+(&1, 1)
                  )

                if registry[pos] == 1 do
                  {:cont, {pos, registry}}
                else
                  {:halt, {pos, registry}}
                end
              end
            )

          ret = {{x, y, vx, vy}, registry}

          if registry[{x, y}] == 1 do
            {:cont, ret}
          else
            {:halt, ret}
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
