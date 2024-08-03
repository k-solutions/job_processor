defmodule JobProcessor.TaskSorter do
  alias JobProcessor.{Task, CircularDependencyError}

  @doc """
  Sorts tasks based on their dependencies.
  Raises CircularDependencyError if a circular dependency is detected.
  
  ## Examples

      iex> tasks = [
      ...>   %JobProcessor.Task{name: "task-1", command: "touch /tmp/file1"},
      ...>   %JobProcessor.Task{name: "task-2", command: "cat /tmp/file1", requires: ["task-3"]},
      ...>   %JobProcessor.Task{name: "task-3", command: "echo Hello > /tmp/file1", requires: ["task-1"]},
      ...>   %JobProcessor.Task{name: "task-4", command: "rm /tmp/file1", requires: ["task-2", "task-3"]}
      ...> ]
      iex> tasks |> JobProcessor.TaskSorter.sort_tasks()
      [
        %JobProcessor.Task{name: "task-1", command: "touch /tmp/file1", requires: []},
        %JobProcessor.Task{name: "task-3", command: "echo Hello > /tmp/file1", requires: ["task-1"]},
        %JobProcessor.Task{name: "task-2", command: "cat /tmp/file1", requires: ["task-3"]},
        %JobProcessor.Task{name: "task-4", command: "rm /tmp/file1", requires: ["task-2", "task-3"]}
      ]

  """  
  @spec sort_tasks([Task.t()]) :: [Task.t()]
  def sort_tasks(tasks) do
    task_map = Map.new(tasks, fn task -> {task.name, task} end)
    max_counter = length(tasks) # WE asssume that this maximum count of opperation sghould be less than max_counter ^ 2
    task_map  
    |> Map.keys()
    |> topological_sort(task_map, [], max_counter * max_counter)
    |> Enum.map(fn name -> task_map[name] end)
  end
  
  @spec topological_sort([String.t()], map(), [String.t()], integer) :: [String.t()]
  defp topological_sort([], _task_map, visited, _sorted), do: visited 
  defp topological_sort(_, _, visited, counter) when counter <= 0, do: raise(CircularDependencyError, Enum.join(visited, " -> ")) 
  defp topological_sort(task_list, task_map, visited, counter) do
    task_list 
    |> List.foldr(visited, 
      fn it, acc ->
          new_acc = if Enum.member?(acc, it), do: [it | remove_existing(acc, it)], else: [it | acc] 
          case task_map[it].requires do 
            []  -> new_acc # |> add_as_top(it)
            reqs -> topological_sort(reqs, task_map, new_acc, counter - 1)
          end    
      end)
  end

  defp remove_existing(acc, it) do
    ix = Enum.find_index(acc, fn i -> i == it end)
    acc |> List.delete_at(ix) 
  end  
end
