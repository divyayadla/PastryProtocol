defmodule UT do

  def get_node_from_leaves(state, hash_val) do
    nodeid = state[:nodeid]
    m1 = state[:min_set]
    m2 = state[:max_set]

    min =     
      if m1 != [] do
        [a | b] = m1
        {m11, res} = find_min(b, a, [])
        m11
      else
        nodeid
      end

    max = 
      if m2 != [] do
        [a | b] = m2
        {m12, res} = find_max(b,a,[])
        m12
      else
        nodeid
      end
  
    if min <= hash_val &&  hash_val <= max do
      true
    else
      false
    end
  end


  def get_node_from_route_table(state, hash) do
    nodeid = state[:nodeid]

    # IO.puts "n1: " <> nodeid <> " n2," <> hash
    {n, next, rem} = UT.prefix_tuple(nodeid, hash, 0, 32)

    j = UT.get_int_val_from_hex(next, nodeid, hash)
    route = state[:route]
    if route && route[n] && route[n][j] do
      route[n][j]
    else 
      nil
    end
  end

  def up_route_table(state, n, next,caller_hash, caller_pid) do
    route = state[:route]
    sub = route[n]
    if !sub do
      sub = %{}
    end
    if !sub[next] do
      sub = Map.put(sub, next, {caller_hash, caller_pid})
    end
    route = Map.put(route, n, sub)
    
    state = Map.put(state, :route, route)
    state
  end

  def get_int_val_from_hex(ch, s1, s2) do
    # IO.puts "getval from char " <> s1 <> " " <> s2 <> " " <>ch
    case ch do
      "a" -> 10
      "b" -> 11
      "c" -> 12
      "d" -> 13
      "e" -> 14
      "f" -> 15
      _ -> {n, _} = ch |> Integer.parse
          n
    end
  end

  # s1 is nodeid and s2 is key
  def prefix_tuple(s1, s2, n, rem) do
    if rem == 0 do
      {n,"",""}
    else
      s11 = String.slice(s1, 0,1)
      s12 = String.slice(s2, 0,1)
      if s11 == s12 do
        prefix_tuple(String.slice(s1, 1..-1), String.slice(s2, 1..-1), n+1, rem-1)
      else
        next = String.slice(s2, 0,1)
        {n,next, String.slice(s2, 1..-1)}
      end
    end
  end

  def find_min(list, min, res) do
    if list == [] do
      {min, res}
    else 
      [a | b] = list
      {a1 , b1} = min
      {c1 , d1} = a
      if a1 > c1 do
        res = [min | res]
        min = a
      else 
        res = [a | res]
      end
      find_min(b, min, res)
    end
  end

  def find_max(list, max, res) do
    if list == [] do
      {max, res}
    else 
      [a | b] = list
      {a1 , b1} = max
      {c1 , d1} = a
      if a1 < c1 do
        res = [max | res]
        max = a
      else 
        res = [a | res]
      end
      find_max(b, max, res)
    end
  end
end