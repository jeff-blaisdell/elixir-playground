defmodule UUIDGenerator do
  def main(args) do
    IO.puts "#{UUID.uuid4()}"
  end
end
