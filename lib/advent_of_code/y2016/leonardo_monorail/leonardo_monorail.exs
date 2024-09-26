alias AdventOfCode.Y2016.LeonardoMonorail

defmodule AdventOfCode.Y2016.LeonardoMonorail do
  @typep memory :: %{
           a: integer(),
           b: integer(),
           c: integer(),
           d: integer()
         }

  @spec parse_instruction(memory(), [binary()]) :: memory()
  defp parse_instruction(mem, operands) do
    case operands do
      ["cpy", x, y] ->
        if(x |> String.match?(~r/[a-d]/)) do
          mem
          |> Map.put(
            y |> String.to_existing_atom(),
            mem[x |> String.to_existing_atom()]
          )
        else
          mem
          |> Map.put(
            y |> String.to_existing_atom(),
            x |> String.to_integer()
          )
        end

      ["inc", x] ->
        mem
        |> Map.update!(
          x |> String.to_existing_atom(),
          &Kernel.+(&1, 1)
        )

      ["dec", x] ->
        mem
        |> Map.update!(
          x |> String.to_existing_atom(),
          &Kernel.-(&1, 1)
        )
    end
  end

  @spec run([binary()], memory(), non_neg_integer()) :: memory()
  defp run(instruction_set, mem \\ %{a: 0, b: 0, c: 0, d: 0}, start_idx \\ 0) do
    start_idx..(length(instruction_set) - 1)//1
    |> Enum.reduce_while(mem, fn idx, mem ->
      case instruction_set |> Enum.at(idx) |> String.split(" ") do
        ["jnz", x, offset] ->
          val =
            if(x |> String.match?(~r/[a-d]/)) do
              mem[x |> String.to_existing_atom()]
            else
              x |> String.to_integer()
            end

          if val != 0 do
            {
              :halt,
              run(
                instruction_set,
                mem,
                idx + (offset |> String.to_integer())
              )
            }
          else
            {:cont, mem}
          end

        operands ->
          {:cont, mem |> parse_instruction(operands)}
      end
    end)
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> String.split("\n")
    |> run()
    |> Map.fetch!(:a)
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    contents
    |> String.split("\n")
    |> run(%{a: 0, b: 0, c: 1, d: 0})
    |> Map.fetch!(:a)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> LeonardoMonorail.part1()
|> IO.puts()

contents
|> LeonardoMonorail.part2()
|> IO.puts()
