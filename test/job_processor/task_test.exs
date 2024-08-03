defmodule JobProcessor.TaskTest do
  use ExUnit.Case
  doctest JobProcessor.Task
  alias JobProcessor.Task

  test "encoding Task to JSON" do
    task = %Task{name: "task-1", command: "echo Hello", requires: []}
    json = Jason.encode!(task)
    assert json == ~s({"command":"echo Hello","name":"task-1","requires":[]})
  end

  test "decoding JSON to Task" do
    json = ~s({"name":"task-1","command":"echo Hello","requires":[]})
    task = Jason.decode!(json, as: %{"name" => "", "command" => "", "requires" => []}) |> Task.from_map()
    assert task == %Task{name: "task-1", command: "echo Hello", requires: []}
  end
end
