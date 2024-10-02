alias AdventOfCode.Y2016.StepsForward

defmodule AdventOfCode.Y2016.StepsForward do
  @passcode "ioramepc"

  @typep position :: {
           non_neg_integer(),
           non_neg_integer()
         }
  @typep state :: {
           binary(),
           position()
         }

  @spec is_final_state?(state()) :: boolean()
  defp is_final_state?({_, pos}), do: pos == {3, 3}

  @spec get_next_gen(state()) :: [state()]
  defp get_next_gen({path, {i0, j0}}) do
    :crypto.hash(:md5, @passcode <> path)
    |> Base.encode16(case: :lower)
    |> String.graphemes()
    |> Enum.zip([
      {"U", {-1, 0}},
      {"D", {1, 0}},
      {"L", {0, -1}},
      {"R", {0, 1}}
    ])
    |> Enum.filter(fn {<<h>>, _} -> h > ?a end)
    |> Enum.map(fn {_, {dir, {di, dj}}} ->
      {path <> dir, {i0 + di, j0 + dj}}
    end)
    |> Enum.filter(fn {_, {i, j}} -> i in 0..3 and j in 0..3 end)
  end

  @spec part1([state()]) :: binary()
  def part1(current_states \\ [{"", {0, 0}}]) do
    {path, _} =
      current_states
      |> Enum.find(
        {nil, {-1, -1}},
        &is_final_state?/1
      )

    if path != nil do
      path
    else
      current_states
      |> Enum.flat_map(&get_next_gen/1)
      |> part1()
    end
  end

  @spec find_longest([state()], non_neg_integer()) :: non_neg_integer()
  defp find_longest(current_states, n \\ 0)

  defp find_longest([], n), do: n

  defp find_longest(current_states, n) do
    {final_states, current_states} =
      current_states
      |> Enum.split_with(&is_final_state?/1)

    n =
      if(length(final_states) > 0) do
        final_states
        |> List.first()
        |> then(fn {path, _} -> String.length(path) end)
      else
        n
      end

    current_states
    |> Enum.flat_map(&get_next_gen/1)
    |> find_longest(n)
  end

  @spec part2() :: non_neg_integer()
  def part2() do
    [{"", {0, 0}}]
    |> find_longest()
  end
end

StepsForward.part1()
|> IO.puts()

StepsForward.part2()
|> IO.puts()
