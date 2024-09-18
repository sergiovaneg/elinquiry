alias AdventOfCode.Y2016.NiceChess

defmodule AdventOfCode.Y2016.NiceChess do
  @door_id "ffykfhsq"
  @typep state :: {any(), integer()}
  @typep val_fn :: (state() -> boolean())
  @typep upd_fn :: (state() -> state())

  @spec hasher(binary()) :: binary()
  defp hasher(msg) do
    msg
    |> then(fn x -> :crypto.hash(:md5, x) end)
    |> Base.encode16()
  end

  @spec search(state(), val_fn(), upd_fn()) :: state()
  defp search(s, v, u) do
    if v.(s) do
      s
    else
      s |> u.() |> search(v, u)
    end
  end

  defp is_valid_1?({pwd, _}) do
    pwd |> String.length() == 8
  end

  defp update_1({pwd, i}) do
    case (@door_id <> to_string(i)) |> hasher() do
      "00000" <> suffix ->
        {pwd <> (suffix |> String.first()), i + 1}

      _ ->
        {pwd, i + 1}
    end
  end

  @spec part1() :: binary()
  def part1() do
    {pwd, _} = search({"", 0}, &is_valid_1?/1, &update_1/1)
    pwd
  end

  defp is_valid_2?({pwd, _}) do
    pwd |> Map.keys() |> length() == 8
  end

  defp update_2({pwd, i}) do
    case (@door_id <> to_string(i)) |> hasher() do
      "00000" <> suffix ->
        [idx, c | _] = suffix |> String.graphemes()

        if(idx |> String.match?(~r/[0-7]{1}/)) do
          {pwd |> Map.put(idx, c), i + 1}
        else
          {pwd, i + 1}
        end

      _ ->
        {pwd, i + 1}
    end
  end

  @spec part2() :: binary()
  def part2() do
    {pwd, _} = search({%{}, 0}, &is_valid_2?/1, &update_2/1)

    pwd
    |> Map.to_list()
    |> Enum.sort_by(fn {k, _} -> k end)
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.join()
  end
end

NiceChess.part1() |> IO.puts()
NiceChess.part2() |> IO.puts()
