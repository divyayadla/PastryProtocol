defmodule Hash do
  def getHash(str) do
    :crypto.hash(:md5, str) |> Base.encode16 |> String.downcase
  end

  def abc do
    r = :rand.uniform(1000)
    getHash(to_string(r))
  end
end
