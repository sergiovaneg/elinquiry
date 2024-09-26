alias AdventOfCode.Y2016.OneTimePad

defmodule AdventOfCode.Y2016.OneTimePad do
  @salt "yjdafjpo"
  @buffer_size 1000
  @hash_target 64
  @num_sequential_hashes 2016

  @typep hasher :: (non_neg_integer() -> binary())

  defp get_hash(idx) do
    :crypto.hash(:md5, @salt <> to_string(idx))
    |> Base.encode16(case: :lower)
  end

  @spec iterate(
          {binary(), non_neg_integer()},
          [binary()],
          non_neg_integer(),
          hasher()
        ) :: non_neg_integer()
  defp iterate({_, current_idx}, _, @hash_target, _), do: current_idx - 1

  defp iterate(
         {current_hash, current_idx},
         hash_buffer,
         found_hashes,
         hasher
       ) do
    found_hashes =
      if (case ~r/(.)\1\1/ |> Regex.run(current_hash, capture: :first) do
            [triplet] ->
              hash_buffer
              |> Enum.any?(
                &String.contains?(
                  &1,
                  triplet
                  |> String.first()
                  |> String.duplicate(5)
                )
              )

            nil ->
              false
          end),
         do: found_hashes + 1,
         else: found_hashes

    [new_hash | new_buffer] =
      hash_buffer
      |> List.insert_at(
        -1,
        hasher.(current_idx + @buffer_size + 1)
      )

    iterate(
      {new_hash, current_idx + 1},
      new_buffer,
      found_hashes,
      hasher
    )
  end

  @spec part1() :: non_neg_integer()
  def part1() do
    iterate(
      {get_hash(0), 0},
      1..@buffer_size//1 |> Enum.map(&get_hash/1),
      0,
      &get_hash/1
    )
  end

  @spec sequential_hasher(non_neg_integer()) :: binary()
  defp sequential_hasher(idx) do
    1..@num_sequential_hashes//1
    |> Enum.reduce(
      get_hash(idx),
      fn _, hash ->
        :crypto.hash(:md5, hash)
        |> Base.encode16(case: :lower)
      end
    )
  end

  @spec part2() :: non_neg_integer()
  def part2() do
    iterate(
      {sequential_hasher(0), 0},
      1..@buffer_size//1 |> Enum.map(&sequential_hasher/1),
      0,
      &sequential_hasher/1
    )
  end
end

OneTimePad.part1()
|> IO.puts()

OneTimePad.part2()
|> IO.puts()
