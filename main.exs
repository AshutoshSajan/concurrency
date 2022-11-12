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

Benchmark.measure(fn -> Concurrency.non_concurrent() end)
Benchmark.measure(fn -> Concurrency.concurrent() end)
