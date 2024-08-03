defmodule JobProcessor.Task do
  defstruct name: "", command: "", requires: []

  @type t :: %__MODULE__{
          name: String.t(),
          command: String.t(),
          requires: [String.t()]
        }

  defimpl Jason.Encoder, for: JobProcessor.Task do
    def encode(%JobProcessor.Task{name: name, command: command, requires: requires}, opts) do
      map = %{
        "name" => name,
        "command" => command,
        "requires" => requires
      }

      Jason.Encode.map(map, opts)
    end
  end

  @doc """
  Creates a new Task.

  ## Examples

      iex> JobProcessor.Task.new(%{"name" => "task-1", "command" => "echo Hello"})
      %JobProcessor.Task{name: "task-1", command: "echo Hello", requires: []}

      iex> JobProcessor.Task.new(%{"name" => "task-2", "command" => "cat /tmp/file1", "requires" => ["task-1"]})
      %JobProcessor.Task{name: "task-2", command: "cat /tmp/file1", requires: ["task-1"]}

  """
  @spec new(map()) :: t()
  def new(%{"name" => name, "command" => command, "requires" => requires}) do
    %__MODULE__{name: name, command: command, requires: requires}
  end

  def new(%{"name" => name, "command" => command}) do
    %__MODULE__{name: name, command: command, requires: []}
  end

  @doc """
  Converts a map to a Task struct.

  ## Examples

      iex> JobProcessor.Task.from_map(%{"name" => "task-1", "command" => "echo Hello"})
      %JobProcessor.Task{name: "task-1", command: "echo Hello", requires: []}

      iex> JobProcessor.Task.from_map(%{"name" => "task-2", "command" => "cat /tmp/file1", "requires" => ["task-1"]})
      %JobProcessor.Task{name: "task-2", command: "cat /tmp/file1", requires: ["task-1"]}

  """
  @spec from_map(map()) :: t()
  def from_map(%{"name" => name, "command" => command, "requires" => requires}) do
    %__MODULE__{name: name, command: command, requires: requires}
  end

  def from_map(%{"name" => name, "command" => command}) do
    %__MODULE__{name: name, command: command, requires: []}
  end
end
