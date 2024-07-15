alias AdventOfCode.Y2015.FireHazard

defmodule AdventOfCode.Y2015.FireHazard do
  @grid_size 1000

  defp init_grid(default_value) do
    List.duplicate(default_value, @grid_size)
    |> Enum.zip(0..(@grid_size - 1))
    |> List.duplicate(@grid_size)
    |> Enum.zip(0..(@grid_size - 1))
  end

  defp parse_bounds(line) do
    Regex.scan(~r/([0-9]+)/, line, capture: :first)
    |> List.flatten()
    |> Enum.map(fn x -> x |> String.to_integer() end)
    |> List.to_tuple()
  end

  defp parse_instruction_A(line) do
    {i_lb, j_lb, i_ub, j_ub} = line |> parse_bounds()

    action =
      cond do
        line |> String.starts_with?("toggle") ->
          fn {state, i} -> {!state, i} end

        line |> String.starts_with?("turn on") ->
          fn {_state, i} -> {true, i} end

        line |> String.starts_with?("turn off") ->
          fn {_state, i} -> {false, i} end

        true ->
          fn x -> x end
      end

    fn {state_i, j} ->
      if j >= j_lb and j <= j_ub do
        {state_i
         |> Enum.map(fn {state, i} ->
           if i >= i_lb and i <= i_ub do
             {state, i} |> action.()
           else
             {state, i}
           end
         end), j}
      else
        {state_i, j}
      end
    end
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(&parse_instruction_A/1)
    |> Enum.reduce(init_grid(false), fn inst, grid ->
      grid |> Enum.map(inst)
    end)
    |> Enum.map(fn {state_i, _} ->
      state_i
      |> Enum.count(fn {state, _} -> state end)
    end)
    |> Enum.sum()
  end

  defp parse_instruction_B(line) do
    {i_lb, j_lb, i_ub, j_ub} = line |> parse_bounds()

    action =
      cond do
        line |> String.starts_with?("toggle") ->
          fn {state, i} -> {state + 2, i} end

        line |> String.starts_with?("turn on") ->
          fn {state, i} -> {state + 1, i} end

        line |> String.starts_with?("turn off") ->
          fn {state, i} -> {max(0, state - 1), i} end

        true ->
          fn x -> x end
      end

    fn {state_i, j} ->
      if j >= j_lb and j <= j_ub do
        {state_i
         |> Enum.map(fn {state, i} ->
           if i >= i_lb and i <= i_ub do
             {state, i} |> action.()
           else
             {state, i}
           end
         end), j}
      else
        {state_i, j}
      end
    end
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(&parse_instruction_B/1)
    |> Enum.reduce(init_grid(0), fn inst, grid ->
      grid |> Enum.map(inst)
    end)
    |> Enum.map(fn {state_i, _} ->
      state_i
      |> Enum.reduce(0, fn {state, _}, acc -> acc + state end)
    end)
    |> Enum.sum()
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> FireHazard.part1()
|> IO.puts()

contents
|> FireHazard.part2()
|> IO.puts()
