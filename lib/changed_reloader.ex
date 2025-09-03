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
    import Supervisor.Spec, warn: false

    children = [
      worker(ChangedReloader.Worker, [])
    ]

    opts = [strategy: :one_for_one, name: ChangedReloader.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defmodule Worker do
    use GenServer

    defmodule State, do: defstruct last_mtime: nil

    def start_link do
      Process.send_after(__MODULE__, :poll_and_reload, 10000)
      GenServer.start_link(__MODULE__, %State{}, name: ChangedReloader.Worker)
    end

    def init(state) do
      {:ok, state}
    end

    def handle_info(:poll_and_reload, state) do
      current_mtimes = get_current_mtime()
      if current_mtimes && current_mtimes != [] do
        {latest_mtime, _} = List.first(current_mtimes)

        case state.last_mtime do
          nil -> :ok
          _ ->
            Enum.filter(current_mtimes, fn  {mtime, _} -> mtime > state.last_mtime end)
            |> Enum.each(fn {_, file} ->
              try do
                if String.split(file, ".") |> List.last == "ex" do
                  IEx.Helpers.c(file)
                end
              rescue
                _err ->
                  :ok
                # IO.puts "error: #{inspect err, pretty: true}\n stacktrace: #{inspect System.stacktrace(), pretty: true}"
              end
            end)
        end

        Process.send_after(__MODULE__, :poll_and_reload, 1000)
        {:noreply, %State{last_mtime: latest_mtime}}
      else
        Process.send_after(__MODULE__, :poll_and_reload, 1000)
        {:noreply, state}
      end
    end

    def get_current_mtime, do: get_current_mtime("apps")

    def get_current_mtime(dir) do
      case File.ls(dir) do
        {:ok, files} -> get_current_mtime(files, [], dir)
        _ -> []
      end
    end

    def get_current_mtime([], mtimes, _cwd) do
      mtimes
      |> List.flatten
      |> Enum.sort
      |> Enum.reverse
    end

    def get_current_mtime([h | tail], mtimes, cwd) do
      path = "#{cwd}/#{h}"
      mtime = case File.dir?(path) do
        true  -> get_current_mtime(path) || []
        false ->
          try do
            {File.stat!(path).mtime, path}
          rescue
            _ -> nil
          end
      end
      get_current_mtime(tail, [mtime | mtimes], cwd)
    end
  end
end
