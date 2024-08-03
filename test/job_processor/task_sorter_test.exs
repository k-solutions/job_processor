defmodule JobProcessor.TaskSorterTest do
  use ExUnit.Case
  doctest JobProcessor.TaskSorter
  alias JobProcessor.{Task, TaskSorter, CircularDependencyError}

  describe "sort_tasks/1" do
    test "sorts tasks with straightforward dependencies" do
      tasks = [
        %Task{name: "task-1", command: "echo 'Task 1'"},
        %Task{name: "task-2", command: "echo 'Task 2'", requires: ["task-3"]},
        %Task{name: "task-3", command: "echo 'Task 3'", requires: ["task-1"]}
      ]

      sorted_tasks = TaskSorter.sort_tasks(tasks)

      assert Enum.map(sorted_tasks, & &1.name) == ["task-1", "task-3", "task-2"]
    end

    @tag :focus
    test "sorts tasks with complex dependencies" do
      tasks = [
        %Task{name: "task-1", command: "echo 'Task 1'"},
        %Task{name: "task-2", command: "echo 'Task 2'", requires: ["task-3", "task-5"]},
        %Task{name: "task-3", command: "echo 'Task 3'", requires: ["task-1"]},
        %Task{name: "task-4", command: "echo 'Task 4'", requires: ["task-2"]},
        %Task{name: "task-5", command: "echo 'Task 5'", requires: ["task-3"]}
      ]

      sorted_tasks = TaskSorter.sort_tasks(tasks)

      assert Enum.map(sorted_tasks, & &1.name) == ["task-1", "task-3", "task-5", "task-2", "task-4"]
    end
  end

  describe "circular dependecies" do 
    test "raises an error" do
      tasks = [
        %Task{name: "task-1", command: "echo 'Task 1'", requires: ["task-2"]},
        %Task{name: "task-2", command: "echo 'Task 2'", requires: ["task-3"]},
        %Task{name: "task-3", command: "echo 'Task 3'", requires: ["task-1"]}
      ]

      assert_raise CircularDependencyError, fn ->
        TaskSorter.sort_tasks(tasks)
      end
    end
  end  
end
