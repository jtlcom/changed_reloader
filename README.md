# ChangedReloader

`ChangedReloader` is a development tool for Elixir that automatically recompiles your code when a file is changed. It supports both regular Mix projects and Umbrella projects out of the box.

## Installation

Add `changed_reloader` to your list of dependencies in `mix.exs`. 推荐使用 tag 方式引用稳定版本：

```elixir
defp deps do
  [
    {:changed_reloader, git: "https://github.com/jtlcom/changed_reloader", tag: "1.0.0", only: :dev}
  ]
end
```

Next, add `:changed_reloader` to your list of applications. This ensures the reloader is started automatically when you run your server.

A common way to do this is:

```elixir
def application do
  [
    extra_applications: [:logger] ++ extra_applications(Mix.env())
  ]
end

defp extra_applications(:dev), do: [:changed_reloader]
defp extra_applications(_), do: []
```

## Usage

No configuration is needed. Once installed, `ChangedReloader` will automatically:

- Monitor `lib/**/*.ex` files in a regular project.
- Monitor `apps/*/lib/**/*.ex` files in an umbrella project.

When a file is saved, it will be recompiled.

## Credits

This project is based on the original idea of [Remix](https://github.com/AgilionApps/remix).
