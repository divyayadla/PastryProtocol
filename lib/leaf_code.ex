  # def update_leaf_nodes_from_routing_table(state) do
  #   leafset = state[:leafset]
  #   route = state[:route]

  #   Enum.each route, fn {key, val} ->
  #     {pid, hash} = val
      
  #   end


  # end


    # def exists_in_leaf_set_range(state, hash) do
  #   leaves = state[:leafset]
  #   if leaves == [] do
  #     nil
  #   else 
  #     [first_node, tail] = leaves
  #     last_node = get_tail(tail)
  #     if last_node == [] do 
  #       nil
  #     else
  #       if first_node <= hash and hash <= last_node do
  #         get_closest_hash(leaves, hash)
  #       else
  #         nil
  #       end
  #     end
  #   end
  # end

  # yet to complete this method
  # def get_closest_hash(list, key) do
  #   [head1 | tail] = list
  #   [head2 | tail2] = tail
  #   if head1 <= key and head2 >= key do

  #     {n1, next1, rem1} = prefix_tuple(key,head1,0,32)
  #     {n2, next2, rem2} = prefix_tuple(key,head2,0,32)

  #     <<p1, _>> = next1 <> <<0>>
  #     <<p2, _>> = next2 <> <<0>>

  #     cond do
  #       n1 > n2 -> 
  #         <<p, _>> = String.slice(key, n1, 1) <> <<0>>          
  #         {n1, p-p1, rem1, head1}
  #       n1 < n2 ->           
  #         <<p, _>> = String.slice(key, n2, 1) <> <<0>>          
  #         <<p2, _>> = String.slice(head2, n2, 1) <> <<0>>
  #         {n2, p1-p2, rem2, head2}
  #       _ -> 
  #         <<p, _>> = String.slice(key, n1, 1) <> <<0>>          
          
          
  #     end

  #   else 
  #     get_closest_hash(tail, key)
  #   end
  # end

  # def get_tail(snake) do
  #   if snake == [] do
  #     []
  #   else
  #     [head | tail] = snake
  #     if tail == [] do
  #       head
  #     else
  #       get_tail(tail)
  #     end
  #   end
  # end