defmodule MN do

  def main(args) do
    Process.flag(:trap_exit, true)
    {n, _} = Enum.at(args, 0) |> Integer.parse
    {req, _} = Enum.at(args, 1) |> Integer.parse
    IO.puts to_string(n)
    IO.puts to_string(req)
    # n = 100000
    # req = 10
    b = 4
    params = [b]
    # {:ok, pid} = GenService.init(params)

    # IO.puts "mpid " <> inspect(self())

    {:ok, pid} = HP.create(1, self(), false)
    
    :timer.sleep(500)
    list = [pid]
    
    loop(list, 2, n, pid, req, 0, 0)
  end

  def loop(l, i, n, fpid, r, c, sum) do
    receive do
      {:ready} ->  
                # IO.puts "here3 "
                if i <= n do
                  {:ok, pid} = HP.create(i, self(), fpid)
                  l = [pid | l]
                  i = i+1
                else 
                # Enum.each(l, fn x -> send x, {:print} end)

                  send self(), {:request}
                end
                                # IO.puts "here4 "
                loop(l,i, n, fpid, r,c, sum )
      {:request} -> 
                Enum.each(l, fn x -> req(x,0, r) end)
                loop(l,i,n,fpid,r,c,sum)
      {:hops, i} ->
                if rem(c, 1000) == 0 do
                  IO.puts "count: " <> inspect(c) <> " needed " <> inspect(r*n)
                end
                c = c+1
                sum = sum + i
                if c == r*n do
                  res = sum/c
                  IO.puts "result is " <> inspect(res)
                  System.halt(0)
                end
                loop(l,i,n,fpid,r,c,sum)
    end
  end

  def req(pid, i, r) do
    if i < r do
      send pid, {:route, Hash.abc, 1}
      req(pid, i+1, r)
    end
  end

end
