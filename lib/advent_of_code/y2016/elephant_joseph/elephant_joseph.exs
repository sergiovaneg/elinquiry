alias AdventOfCode.Y2016.ElephantJoseph

defmodule AdventOfCode.Y2016.ElephantJoseph do
  @n_elves 3_014_387

  def steal_next_heuristic(n_elves \\ @n_elves) do
    1 + 2 * (n_elves - round(:math.pow(2, floor(:math.log2(n_elves)))))
  end

  def steal_next(first_idx \\ 0, gap \\ 2, remaining_elves \\ @n_elves)

  def steal_next(first_idx, gap, _) when first_idx + gap >= @n_elves,
    do: first_idx + 1

  def steal_next(first_idx, gap, remaining_elves)
      when rem(remaining_elves, 2) == 1,
      do: steal_next(first_idx + gap, gap * 2, div(remaining_elves, 2))

  def steal_next(first_idx, gap, remaining_elves),
    do: steal_next(first_idx, gap * 2, div(remaining_elves, 2))

  def steal_front_heuristic(n_elves \\ @n_elves)

  def steal_front_heuristic(1), do: 1

  def steal_front_heuristic(n_elves) do
    ub_exp = ceil(:math.log(n_elves) / :math.log(3))
    # ub = round(:math.pow(3, ub_exp))
    separator = round(:math.pow(3, ub_exp - 1))

    if n_elves <= 2 * separator do
      n_elves - separator
    else
      2 * n_elves - 3 * separator
    end

    # Enum.concat(1..(separator - 1)//1, separator..ub//2)
    # |> Enum.at(n_elves - separator - 1)
  end

  def steal_front(
        remaining \\ 1..@n_elves |> Enum.to_list(),
        current_idx \\ 0
      )

  def steal_front([last], _),
    do: last

  def steal_front(remaining, current_idx) do
    n = length(remaining)

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
        rem(current_idx, n - 1)
      else
        rem(current_idx + 1, n - 1)
      end
    )
  end
end

ElephantJoseph.steal_next_heuristic()
|> IO.puts()

ElephantJoseph.steal_front_heuristic()
|> IO.puts()
