# ChangedReloader

base on Remix (https://github.com/AgilionApps/remix)
(in remix, when a file changed, it invoke 'recompile' in iex shell, all application recompiled)

recompile modified elixir file in any lib file
(in changed_reloader, when a file changed, just then changed file recompiled)


Intended for development use only.

## Installation

Add :changed_reloader to deps:

```elixir
defp deps do
  [{:changed_reloader, "~> 0.0.1", only: :dev}]
end
```

Add add `:changed_reloader` as a development only OTP app.

```elixir

def application do
  [applications: applications(Mix.env)]
end

defp applications(:dev), do: applications(:all) ++ [:changed_reloader]
defp applications(_all), do: [:logger]

```

## Usage

Save or create a new file in the lib directory. Thats it!

## About

Co-authored by the Agilion team during a Brown Bag Beers learning session as an exploration into Elixir, OTP, and recursion.

## License

ChangedReloader source code is released under the Apache 2 License. Check LICENSE file for more information.
