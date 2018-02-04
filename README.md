# EnvConfig

Handles fetching values from config with support for runtime ENV loading.

All credit goes to [bitwalker](https://github.com/bitwalker), this module is
[copied from this gist](https://gist.github.com/bitwalker/a4f73b33aea43951fe19b242d06da7b9).

## Usage

Fetches a value from the config, or from the environment if {:system, "VAR"}
is provided.

An optional default value can be provided if desired.

In your `config/config.exs`:

```
# maybe you start your app with FOO_KEY=abcd
config :foo_app, :some_setting, {:system, "FOO_KEY"}
```

In your application:

```
EnvConfig.get(:foo_app, :some_setting) # => "abcd"
```

## Example

```elixir
iex> Application.put_env(:myapp, :test_var, {:system, "MY_ENVVAR"})
iex> System.put_env("MY_ENVVAR", "my_value")
...> #{__MODULE__}.get(:myapp, :test_var)
"my_value"

iex> Application.put_env(:myapp, :test_var, {:system, :charlist, "MY_CHARLIST"})
...> #{__MODULE__}.get(:myapp, :test_var)
nil
iex> System.put_env("MY_CHARLIST", "charlist_value")
...> #{__MODULE__}.get(:myapp, :test_var)
'charlist_value'

iex> Application.put_env(:myapp, :test_var, {:system, :boolean, "MY_BOOLEAN"})
...> System.put_env("MY_BOOLEAN", "off")
...> #{__MODULE__}.get(:myapp, :test_var)
false
iex> System.put_env("MY_BOOLEAN", "true")
...> #{__MODULE__}.get(:myapp, :test_var)
true

iex> Application.put_env(:myapp, :test_var2, 1)
...> 1 = #{__MODULE__}.get(:myapp, :test_var2)
1

iex> :default = #{__MODULE__}.get(:myapp, :missing_var, :default)
:default
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `env_config` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:env_config, "~> 0.1.0"}]
end
```

  2. Ensure `env_config` is started before your application:

```elixir
def application do
  [applications: [:env_config]]
end
```

