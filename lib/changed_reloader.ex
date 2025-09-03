defmodule ChangedReloader do
  use Application

  @moduledoc  ~S"""
  Add `changed_reloader` to deps:
  ```elixir
  defp deps do
    [{:changed_reloader, "~> 0.0.1", only: :dev}]
  end
  ```
  Add  `:changed_reloader` as a development only OTP app.
  ```elixir
  def application do
    [applications: applications(Mix.env)]
  end

  defp applications(:dev), do: applications(:all) ++ [:changed_reloader]
  defp applications(_all), do: [:logger]
  ```
  =====

  """

  def start(_type, _args) do
    if Mix.env() == :dev do
      children = [
        {ChangedReloader.Worker, []}
      ]

      opts = [strategy: :one_for_one, name: ChangedReloader.Supervisor]
      Supervisor.start_link(children, opts)
    else
      # In non-dev environments, do nothing.
      :ignore
    end
  end

  defmodule Worker do
    use GenServer

    def start_link(_opts) do
      GenServer.start_link(__MODULE__, %{last_mtime: nil}, name: __MODULE__)
    end

    @impl true
    def init(state) do
      # Poll for changes every second
      :timer.send_interval(1000, self(), :poll_and_reload)
      {:ok, state}
    end

    @impl true
    def handle_info(:poll_and_reload, state) do
      watched_files = get_watched_files()

      current_mtimes =
        watched_files
        |> Enum.map(&get_mtime/1)
        |> Enum.reject(&is_nil/1)
        |> Enum.sort_by(&elem(&1, 0), &>=/2)

      if current_mtimes != [] do
        {latest_mtime, _} = List.first(current_mtimes)

        case state.last_mtime do
          nil ->
            :ok

          _ ->
            current_mtimes
            |> Enum.filter(fn {mtime, _} -> mtime > state.last_mtime end)
            |> Enum.each(fn {_, file} ->
              IO.puts("Recompiling #{file}...")
              Code.compile_file(file)
            end)
        end

        {:noreply, %{state | last_mtime: latest_mtime}}
      else
        {:noreply, state}
      end
    end

    defp get_watched_files do
      if Mix.Project.umbrella?() do
        Path.wildcard("apps/*/lib/**/*.ex")
      else
        Path.wildcard("lib/**/*.ex")
      end
    end

    defp get_mtime(file) do
      case File.stat(file) do
        {:ok, %{mtime: mtime}} -> {mtime, file}
        {:error, _} -> nil
      end
    end
  end
end
