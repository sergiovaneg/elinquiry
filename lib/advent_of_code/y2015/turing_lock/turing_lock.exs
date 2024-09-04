alias AdventOfCode.Y2015.TuringLock

defmodule AdventOfCode.Y2015.TuringLock do
  @type state :: {integer(), integer(), integer()}
  @type instruction :: (state() -> state())

  @spec parse_instruction(binary()) :: instruction()
  defp parse_instruction(line) do
    case(line |> String.split([" ", ", "])) do
      [cmd, x] ->
        case cmd do
          "hlf" ->
            if x == "a" do
              fn {a, b, i} -> {a |> Bitwise.bsr(1), b, i + 1} end
            else
              fn {a, b, i} -> {a, b |> Bitwise.bsr(1), i + 1} end
            end

          "tpl" ->
            if x == "a" do
              fn {a, b, i} -> {a * 3, b, i + 1} end
            else
              fn {a, b, i} -> {a, b * 3, i + 1} end
            end

          "inc" ->
            if x == "a" do
              fn {a, b, i} -> {a + 1, b, i + 1} end
            else
              fn {a, b, i} -> {a, b + 1, i + 1} end
            end

          "jmp" ->
            fn {a, b, i} -> {a, b, i + String.to_integer(x)} end
        end

      [cmd, x, y] ->
        case cmd do
          "jie" ->
            if x == "a" do
              fn {a, b, i} ->
                if a |> Bitwise.band(0x01) == 0 do
                  {a, b, i + String.to_integer(y)}
                else
                  {a, b, i + 1}
                end
              end
            else
              fn {a, b, i} ->
                if b |> Bitwise.band(0x01) == 0 do
                  {a, b, i + String.to_integer(y)}
                else
                  {a, b, i + 1}
                end
              end
            end

          "jio" ->
            if x == "a" do
              fn {a, b, i} ->
                if a == 1 do
                  {a, b, i + String.to_integer(y)}
                else
                  {a, b, i + 1}
                end
              end
            else
              fn {a, b, i} ->
                if b == 1 do
                  {a, b, i + String.to_integer(y)}
                else
                  {a, b, i + 1}
                end
              end
            end
        end
    end
  end

  @spec run_program([instruction(), ...], state()) :: state()
  defp run_program(instruction_set, {a, b, i}) do
    if i < length(instruction_set) do
      instruction = instruction_set |> Enum.at(i)
      run_program(instruction_set, instruction.({a, b, i}))
    else
      {a, b, i}
    end
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    {_, b, _} =
      contents
      |> String.split("\n")
      |> Enum.map(&parse_instruction/1)
      |> run_program({0, 0, 0})

    b
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    {_, b, _} =
      contents
      |> String.split("\n")
      |> Enum.map(&parse_instruction/1)
      |> run_program({1, 0, 0})

    b
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> TuringLock.part1()
|> IO.puts()

contents
|> TuringLock.part2()
|> IO.puts()
