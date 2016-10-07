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
iex> {test_var, expected_value} = System.get_env |> Enum.take(1) |> List.first
...> Application.put_env(:myapp, :test_var, {:system, test_var})
...> ^expected_value = EnvConfig.get(:myapp, :test_var)
...> :ok
:ok

iex> Application.put_env(:myapp, :test_var2, 1)
...> 1 = EnvConfig.get(:myapp, :test_var2)
1

iex> :default = EnvConfig.get(:myapp, :missing_var, :default)
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

