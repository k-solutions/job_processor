defmodule JobProcessor.Processor do
  alias JobProcessor.{Task, TaskSorter}

  @doc """
  Processes the job tasks by sorting them based on their dependencies.

  ## Examples

      iex> task_params = [
      ...>   %{"name" => "task-1", "command" => "touch /tmp/file1"},
      ...>   %{"name" => "task-2", "command" => "cat /tmp/file1", "requires" => ["task-3"]},
      ...>   %{"name" => "task-3", "command" => "echo Hello > /tmp/file1", "requires" => ["task-1"]},
      ...>   %{"name" => "task-4", "command" => "rm /tmp/file1", "requires" => ["task-2", "task-3"]}
      ...> ]
      iex> JobProcessor.Processor.process_jobs(task_params)
      [
        %JobProcessor.Task{name: "task-1", command: "touch /tmp/file1", requires: []},
        %JobProcessor.Task{name: "task-3", command: "echo Hello > /tmp/file1", requires: ["task-1"]},
        %JobProcessor.Task{name: "task-2", command: "cat /tmp/file1", requires: ["task-3"]},
        %JobProcessor.Task{name: "task-4", command: "rm /tmp/file1", requires: ["task-2", "task-3"]}
      ]

  """
  @spec process_jobs([map()]) :: [Task.t()]
  def process_jobs(task_params) do
    task_params
    |> Enum.map(&Task.new/1)
    |> TaskSorter.sort_tasks()
  end
  
  @doc """
  Generates a bash script from the sorted job tasks.

  ## Examples

      iex> task_params = [
      ...>   %{"name" => "task-1", "command" => "touch /tmp/file1"},
      ...>   %{"name" => "task-2", "command" => "cat /tmp/file1", "requires" => ["task-3"]},
      ...>   %{"name" => "task-3", "command" => "echo Hello > /tmp/file1", "requires" => ["task-1"]},
      ...>   %{"name" => "task-4", "command" => "rm /tmp/file1", "requires" => ["task-2", "task-3"]}
      ...> ]
      iex> JobProcessor.Processor.generate_bash_script(task_params)
      "#!/usr/bin/env bash\\ntouch /tmp/file1\\necho Hello > /tmp/file1\\ncat /tmp/file1\\nrm /tmp/file1"

  """
  @spec generate_bash_script([map()]) :: String.t()
  def generate_bash_script(task_params) do
    tasks = process_jobs(task_params)
    tasks
    |> Enum.map(& &1.command)
    |> Enum.join("\n")
    |> (&("#!/usr/bin/env bash\n" <> &1)).()
  end
end
