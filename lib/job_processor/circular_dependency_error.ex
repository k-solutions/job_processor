defmodule JobProcessor.CircularDependencyError do
  defexception message: "Circular dependency detected"

  def exception(value) do
    %JobProcessor.CircularDependencyError{message: "Circular dependency detected in: #{value}"}
  end
end
