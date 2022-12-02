defmodule Concurrency do
  :inets.start()
  :ssl.start()

  def get_coin(id) do
    # https://stackoverflow.com/questions/20108421/using-the-httpc-erlang-module-from-elixir
    :httpc.request("https://xkcd.com/#{id}/info.0.json")
  end

  def non_concurrent() do
    ids = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    Enum.map(ids, fn id -> get_coin(id) end)
  end

  def concurrent() do
    ids = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    Enum.map(ids, fn id -> Task.async(fn -> get_coin(id) end) end)
    |> Enum.map(&Task.await/1)
  end
end

# https://stackoverflow.com/questions/29668635/how-can-we-easily-time-function-calls-in-elixir
defmodule Benchmark do
  def measure(function) do
    function
    |> :timer.tc()
    |> elem(0)
    |> Kernel./(1_000_000)
  end
end

# Benchmark.measure(fn -> Concurrency.non_concurrent() end)
# Benchmark.measure(fn -> Concurrency.concurrent() end)

t1 = :os.system_time(:millisecond)
Concurrency.non_concurrent()
t2 = :os.system_time(:millisecond)

time_diff = t2 - t1

IO.inspect("#{time_diff} ms", label: "non_concurrent_time_diff")

t1 = :os.system_time(:millisecond)
Concurrency.concurrent()
t2 = :os.system_time(:millisecond)

time_diff = t2 - t1

IO.inspect("#{time_diff} ms", label: "concurrent_time_diff")

# defmodule TimeDiff do
#   def get_time_diff(function, label) do
#     t1 = :os.system_time(:millisecond)
#     function()
#     t2 = :os.system_time(:millisecond)
#     time_diff = t2 - t1
#     IO.inspect("#{time_diff} ms", label: "#{label}_time_diff")
#   end
# end

# [label1, label2] = ["concurrent", "non_concurrent"]

# TimeDiff.get_time_diff(fn -> Concurrency[label1], "non_concurrent_time_diff" end)
# TimeDiff.get_time_diff(Concurrency[label2], "concurrent_time_diff")
