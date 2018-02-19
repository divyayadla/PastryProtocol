defmodule GenService do
  # use GenServer 

  # def start_link(args) do
  #   GenServer.start_link(__MODULE__, args)
  # end

  # def createNode(server, num) do
  #   GenServer.call(server, {:createNode, num})
  #   end

  # def init(args) do
  #   [base | tail] = args
  #   Node.createNode(1, false)
  # end

  # def handle_call({:createNode, num}, _from, state) do
  #   state = create_node(state, num)
  #   {:reply, Map.fetch(state, num), state}
  # end

  # def create_node(state, num) do
  #   {:ok, pid} = Node.createNode(num, state[:fpid])
  # end

end
