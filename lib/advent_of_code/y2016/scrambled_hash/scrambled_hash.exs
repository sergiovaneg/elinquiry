alias AdventOfCode.Y2016.ScrambledHash

defmodule AdventOfCode.Y2016.ScrambledHash do
  @clean_passwd "abcdefgh"
  @scrambled_passwd "fbgdceah"

  @spec execute(binary(), [binary()], :fwd | :bwd) :: [binary()]
  defp execute(inst, passwd, mode \\ :fwd) do
    case inst |> String.split(" ") do
      ["swap", criterion, x, _w, _, y] ->
        [i1, i2] =
          if criterion == "position" do
            [x, y]
            |> Enum.map(&String.to_integer/1)
          else
            [x, y]
            |> Enum.map(fn target ->
              passwd
              |> Enum.find_index(&(target == &1))
            end)
          end

        [e1, e2] = [i1, i2] |> Enum.map(&Enum.at(passwd, &1))

        passwd
        |> List.replace_at(i1, e2)
        |> List.replace_at(i2, e1)

      ["rotate", dir, n, _] ->
        mult =
          case {dir, mode} do
            conf when conf in [{"right", :bwd}, {"left", :fwd}] ->
              1

            conf when conf in [{"right", :fwd}, {"left", :bwd}] ->
              -1
          end

        passwd
        |> Enum.split(mult * rem(String.to_integer(n), length(passwd)))
        |> then(fn {l, r} -> [r, l] |> List.flatten() end)

      ["rotate" | tail] ->
        case mode do
          :fwd ->
            shift =
              passwd
              |> Enum.find_index(&(tail |> List.last() == &1))
              |> then(fn shift ->
                if shift >= 4 do
                  shift + 2
                else
                  shift + 1
                end
              end)
              |> rem(length(passwd))

            passwd
            |> Enum.split(-shift)
            |> then(fn {l, r} -> [r, l] |> List.flatten() end)

          :bwd ->
            0..length(passwd)
            |> Enum.reduce_while(passwd, fn _, src ->
              if(execute(inst, src) == passwd) do
                {:halt, src}
              else
                [h | t] = src
                {:cont, t ++ [h]}
              end
            end)
        end

      ["reverse", _pos, x, _to, y] ->
        [i1, i2] = [x, y] |> Enum.map(&String.to_integer/1)

        {h, t} = passwd |> Enum.split(i2 + 1)
        {h, m} = h |> Enum.split(i1)

        h ++ (m |> Enum.reverse()) ++ t

      ["move", _pos, x, _to, _, y] ->
        [i1, i2] =
          if mode == :fwd do
            [x, y]
          else
            [y, x]
          end
          |> Enum.map(&String.to_integer/1)

        passwd
        |> Enum.split(i1)
        |> then(fn {h, [m | t]} ->
          (h ++ t)
          |> List.insert_at(i2, m)
        end)
    end
  end

  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.reduce(
      @clean_passwd |> String.graphemes(),
      &execute(&1, &2, :fwd)
    )
    |> Enum.join()
  end

  def part2(contents) do
    contents
    |> String.split("\n")
    |> Enum.reverse()
    |> Enum.reduce(
      @scrambled_passwd |> String.graphemes(),
      &execute(&1, &2, :bwd)
    )
    |> Enum.join()
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> ScrambledHash.part1()
|> IO.puts()

contents
|> ScrambledHash.part2()
|> IO.puts()
