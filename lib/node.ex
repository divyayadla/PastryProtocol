defmodule HP do
  # require IEx
  def create(i, mpid, first_pid) do
    args = [first_pid]
    args = [mpid | args]
    args = [i | args]
    # {:ok, pid} = 
    Task.start_link(__MODULE__, :run, args)
  end

  def run(i, mpid, first_pid) do
    hash_val = Hash.getHash(to_string(i))
    i = to_string(i)
    state = %{
                 :nodeid => hash_val,
                 :nodenum => i,
                 :min_set => [],
                 :max_set => [],
                 :route => %{},
                 :pids => [],
                 :sum => -1,
                 :curr => %{i=>self()},
                 :mpid => mpid
                #  :hashes => %{i=>self()}
                }
    if first_pid do
      # IO.puts "here 6 " <> inspect(self()) <> " " <> inspect(first_pid)
      send first_pid, { :join, self(), hash_val}
    else
      # IO.puts "here " <> inspect(mpid)
      send mpid, {:ready}
    end
    run(state)
  end

  def run(state) do
    receive do
      # this is the mesg that the new node sends to first_node in the network
      {:join, new_node_pid, hash_val} -> 
          state = join_helper(new_node_pid, hash_val, state, 1)
          run(state)

      # this is the mesg that nodes sends while there is a incoming new node 
      {:join_route, new_node_pid, hash_val, num} -> 
          # IO.puts "jr " <> inspect(hash_val)
          state = join_helper(new_node_pid, hash_val, state, num)
          # IO.puts "jr end" <> inspect(hash_val)
          run(state)

      # this is the mesg that the nodes in the path send to new node for sharing their routing table
      {:join_route_table, caller_pid, caller_hash, num, table, m1, m2} -> 
          # IO.puts "jrt " <> inspect(caller_hash)
          state = UP.get_and_update_state(state, table, m1, m2, caller_hash, caller_pid)
          # IO.puts "jrt end" <> inspect(caller_hash)
          # IO.inspect(state)
          pids = state[:pids]
          pids = [caller_pid | pids]
          state = Map.put(state, :pids, pids)
          if length(pids) == state[:sum] do
            send_route_to_pids(pids, state[:nodeid], state)
            send_route_to_pids(state[:m1], state[:nodeid], state)
            send_route_to_pids(state[:m2], state[:nodeid], state)
            send state[:mpid], {:ready}
          end
          run(state)

      # this is the mesg that new node sends to the nodes in the path once it updates all its routing info
      {:route_table, caller_pid, caller_hash, table, m1, m2} -> 
          # IO.puts "rt " <> inspect(caller_hash)
          state = UP.get_and_update_state(state, table, m1, m2, caller_hash, caller_pid)
          # IO.puts "rt end" <> inspect(caller_hash)
          # IO.inspect(state)
          run(state)

      # this is the info that the last nodes in the path send to new node
      {:leaf_nodes, caller_hash, caller_pid, num, min_set, max_set} -> 
          state = put_in state[:sum], num
          # IO.puts "here state is num" <> inspect(state) <> inspect(num)
          pids = state[:pids]
          m1 = []
          m2 = []
          # leaves(caller_hash, caller_pid, min_set, max_set, state)
          m1 = collect_pids(min_set, m1)
          m2 = collect_pids(max_set, m2)
          state = Map.put(state, :m1, m1)
          state = Map.put(state, :m2, m2)
          if length(pids) == state[:sum] do
            send_route_to_pids(pids, state[:nodeid], state)
            send_route_to_pids(state[:m1], state[:nodeid], state)
            send_route_to_pids(state[:m2], state[:nodeid], state)
            send state[:mpid], {:ready}
          end
          run(state)

      # this mesg is used while routing the information
      {:route, key, num} -> 
          val = route(state, key, num)
          if val do
            send state[:mpid], {:hops, num}
          end
          run(state)

      {:print} -> nodeid = 
          state[:nodeid]
          IO.puts "node => " <> state[:nodenum] <> " " <> nodeid <> " " <> inspect(state)
          run(state)
    end
  end

  def collect_pids(l, pids) do
    if l == [] do
      pids
    else
      [a | l] = l
      {b, c} = a
      pids = [ c | pids ]
      collect_pids(l, pids)
    end
  end
  
  def join_helper(new_pid, hash_val, state, num) do
    nodeid = state[:nodeid]
    send new_pid, {:join_route_table, self(), nodeid, num, state[:route], state[:min_set], state[:max_set]}

    if UT.get_node_from_leaves(state, hash_val) do
      send new_pid, {:leaf_nodes, nodeid, self(), num, state[:min_set], state[:max_set]}
    else 
      route_node = UT.get_node_from_route_table(state, hash_val)
      if route_node do
        {hash, route_node_pid} = route_node
        send route_node_pid, {:join_route, new_pid, hash_val, num+1}
      else 
        send new_pid, {:leaf_nodes, nodeid, self(), num, state[:min_set], state[:max_set]}
      end
    end
    state
  end

  def send_route_to_pids(pids, nodeid, state) do
    if pids != [] do
      [pid | pids] = pids
      send pid, {:route_table, self(), nodeid, state[:route], state[:min_set], state[:max_set]}
      send_route_to_pids(pids, nodeid, state)
    end
  end

  def route(state, key, num) do
    if state[:nodeid] != key do
      if UT.get_node_from_leaves(state, key) do
        num
      else 
        route = state[:route]
        route_node = UT.get_node_from_route_table(state, key)
        if route_node do
          {hash, route_node_pid} = route_node
          send route_node_pid, {:route, key, num+1}
          nil
        else 
          num+1
          # IO.puts "this node is not present should handle node not persent in routable as well " <> to_string(num)
          # true
        end    
      end
    else
      num
    end
  end

end