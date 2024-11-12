alias AdventOfCode.Y2016.ScrambledHash

defmodule AdventOfCode.Y2016.ScrambledHash do
  @clean_passwd "abcdefgh"
  @scrambled_passwd "fbgdceah"

  @spec execute(binary(), binary()) :: binary()
  defp execute(inst, passwd) do
    split_passwd =
      passwd
      |> String.graphemes()

    case inst |> String.split(" ") do
      ["swap", criterion, x, _w, _, y] ->
        [i1, i2] =
          if criterion == "position" do
            [x, y]
            |> Enum.map(&String.to_integer/1)
          else
            [x, y]
            |> Enum.map(fn target ->
              split_passwd
              |> Enum.find_index(&(target == &1))
            end)
          end

        e1 = split_passwd |> Enum.at(i1)
        e2 = split_passwd |> Enum.at(i2)

        split_passwd
        |> List.replace_at(i1, e2)
        |> List.replace_at(i2, e1)

      ["rotate", dir, n, _] ->
        mult = if(dir == "left", do: 1, else: -1)

        split_passwd
        |> Enum.split(mult * rem(String.to_integer(n), length(split_passwd)))
        |> then(fn {l, r} -> [r, l] |> List.flatten() end)

      ["rotate" | tail] ->
        idx =
          split_passwd
          |> Enum.find_index(&(tail |> List.last() == &1))
          |> then(fn idx ->
            if idx >= 4 do
              idx + 2
            else
              idx + 1
            end
          end)
          |> rem(length(split_passwd))

        split_passwd
        |> Enum.split(-idx)
        |> then(fn {l, r} -> [r, l] |> List.flatten() end)

      ["reverse", _pos, x, _to, y] ->
        [i1, i2] = [x, y] |> Enum.map(&String.to_integer/1)

        {b, t} = split_passwd |> Enum.split(i2 + 1)
        {b, m} = b |> Enum.split(i1)

        [b | [m |> Enum.reverse() | t]]

      ["move", _pos, x, _to, _, y] ->
        [i1, i2] = [x, y] |> Enum.map(&String.to_integer/1)

        {b, [m | t]} = split_passwd |> Enum.split(i1)

        (b ++ t)
        |> List.insert_at(i2, m)
    end
    |> Enum.join()
  end

  @spec reverse(binary(), binary()) :: binary()
  defp reverse(inst, passwd) do
    split_passwd =
      passwd
      |> String.graphemes()

    case inst |> String.split(" ") do
      ["swap", criterion, x, _w, _, y] ->
        [i1, i2] =
          if criterion == "position" do
            [x, y]
            |> Enum.map(&String.to_integer/1)
          else
            [x, y]
            |> Enum.map(fn target ->
              split_passwd
              |> Enum.find_index(&(target == &1))
            end)
          end

        e1 = split_passwd |> Enum.at(i1)
        e2 = split_passwd |> Enum.at(i2)

        split_passwd
        |> List.replace_at(i1, e2)
        |> List.replace_at(i2, e1)

      ["rotate", dir, n, _] ->
        mult = if(dir == "left", do: -1, else: 1)

        split_passwd
        |> Enum.split(mult * rem(String.to_integer(n), length(split_passwd)))
        |> then(fn {l, r} -> [r, l] |> List.flatten() end)

      ["rotate" | _tail] ->
        0..length(split_passwd)
        |> Enum.reduce_while(split_passwd, fn _, src ->
          if(execute(inst, src |> Enum.join()) == passwd) do
            {:halt, src}
          else
            [h | t] = src

            {
              :cont,
              t ++ [h]
            }
          end
        end)

      ["reverse", _pos, x, _to, y] ->
        [i1, i2] = [x, y] |> Enum.map(&String.to_integer/1)

        {b, t} = split_passwd |> Enum.split(i2 + 1)
        {b, m} = b |> Enum.split(i1)

        [b | [m |> Enum.reverse() | t]]

      ["move", _pos, x, _to, _, y] ->
        [i1, i2] = [x, y] |> Enum.map(&String.to_integer/1)

        {b, [m | t]} = split_passwd |> Enum.split(i2)

        (b ++ t)
        |> List.insert_at(i1, m)
    end
    |> Enum.join()
  end

  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.reduce(@clean_passwd, &execute/2)
  end

  def part2(contents) do
    contents
    |> String.split("\n")
    |> Enum.reverse()
    |> Enum.reduce(@scrambled_passwd, &reverse/2)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> ScrambledHash.part1()
|> IO.puts()

contents
|> ScrambledHash.part2()
|> IO.puts()
