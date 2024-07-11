alias AdventOfCode.Y2015.HousesInVacuum

defmodule State do
  defstruct x: 0, y: 0, visited: %{[0, 0] => true}
end

defmodule AdventOfCode.Y2015.HousesInVacuum do
  @spec update_state(binary(), State) :: State
  def update_state(instruction, state) do
    state = %{
      state
      | y:
          case instruction do
            "^" -> state.y + 1
            "v" -> state.y - 1
            _ -> state.y
          end
    }

    state = %{
      state
      | x:
          case instruction do
            ">" -> state.x + 1
            "<" -> state.x - 1
            _ -> state.x
          end
    }

    %{
      state
      | visited:
          Map.put_new_lazy(
            state.visited,
            [state.x, state.y],
            fn -> true end
          )
    }
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    final_state =
      contents
      |> String.graphemes()
      |> Enum.reduce(%State{}, &update_state/2)

    final_state.visited
    |> Enum.count(fn {_, v} -> v end)
  end

  @spec part2(binary(), pos_integer()) :: non_neg_integer()
  def part2(contents, n_santas) do
    contents
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.group_by(fn {_, k} -> rem(k, n_santas) end, fn {v, _} -> v end)
    |> Map.values()
    # Instructions split for each santa
    |> Enum.map(fn x ->
      x |> Enum.reduce(%State{}, &update_state/2)
    end)
    |> Enum.reduce(%{}, fn state, visited ->
      Map.merge(visited, state.visited, fn _, v1, v2 -> v1 or v2 end)
    end)
    |> Enum.count(fn {_, v} -> v end)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> HousesInVacuum.part1()
|> IO.puts()

contents
|> HousesInVacuum.part2(2)
|> IO.puts()
