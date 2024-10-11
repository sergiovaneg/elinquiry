alias AdventOfCode.Y2016.ElephantJoseph

defmodule AdventOfCode.Y2016.ElephantJoseph do
  @n_elves 3_014_387

  def steal_next(first_idx \\ 0, gap \\ 2, remaining_elves \\ @n_elves)

  def steal_next(first_idx, gap, _) when first_idx + gap >= @n_elves,
    do: first_idx + 1

  def steal_next(first_idx, gap, remaining_elves)
      when rem(remaining_elves, 2) == 1,
      do: steal_next(first_idx + gap, gap * 2, div(remaining_elves, 2))

  def steal_next(first_idx, gap, remaining_elves),
    do: steal_next(first_idx, gap * 2, div(remaining_elves, 2))

  def steal_front(
        remaining \\ 1..@n_elves |> Enum.to_list(),
        current_idx \\ 0
      )

  def steal_front([last], _),
    do: last

  def steal_front(remaining, current_idx) do
    n = length(remaining)

    (100 * (@n_elves - n) / @n_elves) |> IO.puts()

    remove_idx =
      rem(
        current_idx + div(n, 2),
        n
      )

    (remaining --
       [
         remaining
         |> Enum.at(remove_idx)
       ])
    |> steal_front(
      if remove_idx < current_idx do
        current_idx
      else
        rem(current_idx + 1, n - 1)
      end
    )
  end
end

ElephantJoseph.steal_next()
|> IO.puts()

ElephantJoseph.steal_front()
|> IO.puts()
