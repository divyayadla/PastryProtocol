defmodule UP do

  def get_and_update_state(state, table, m1, m2, chash, cpid) do
    state 
      |> get_leaves(m1, m2)
      |> get_each_route(table)
      |> update(chash, cpid)
  end

  def get_leaves(state, m1, m2) do
    state |> get_each_leaf(m1) |> get_each_leaf(m2)
  end

  def get_each_leaf(state, m1) do
    if m1 == [] do
      state
    else
      [q | m1] = m1
      {a,b} = q
      state = update(state, a, b)
      get_each_leaf(state, m1)
    end
  end

  def get_each_route(state, table) do
    state = iter_map(state, 0,0, 32, 16, table)
  end

  def iter_map(state, i, j, m, n, table) do
    # IO.puts "i: " <> to_string(i) <> ",j: " <> to_string(j)
    if i < m do
      if table[i] do
        if j < n do
          if table[i][j] do
            {a,b} = table[i][j]
            state = update(state, a, b)
          end
          j = j+1
        else 
          j = 0
          i = i+1
        end
      else 
        i = i+1
      end
      iter_map(state, i, j, m,n,table)
    else 
      state
    end
  end

  def update(state, caller_hash, caller_pid) do
    nodeid = state[:nodeid]
    if nodeid != caller_hash do
      m1 = state[:min_set]
      m2 = state[:max_set]
      re = nil
      if caller_hash < nodeid do
        if length(m1) < 1 do
          m1 = [{caller_hash, caller_pid} | m1]
        else
          {re, m1} = UT.find_min(m1, {caller_hash, caller_pid}, [])
        end
      else
        if length(m2) < 1 do
          m2 = [{caller_hash, caller_pid} | m2]
        else
          {re, m2} = UT.find_max(m2, {caller_hash, caller_pid}, [])
        end
      end
      state = Map.put(state, :min_set, m1)
      state = Map.put(state, :max_set, m2)
      if re do
        {n, next, _} = UT.prefix_tuple(nodeid,caller_hash,0,32)
        next = UT.get_int_val_from_hex(next, nodeid, caller_hash)
        state = UT.up_route_table(state, n, next, caller_hash, caller_pid)
      end
      state
    else 
      state
    end
  end

end