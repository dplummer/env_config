# Copied from https://gist.githubusercontent.com/bitwalker/a4f73b33aea43951fe19b242d06da7b9/raw/eca0f6fa7b840a4ef3c9719423d72e3ae370dd9d/config.ex
defmodule EnvConfig do
  @moduledoc """
  This module handles fetching values from the config with some additional niceties
  """

  @doc """
  Fetches a value from the config, or from the environment if {:system, "VAR"}
  is provided.

  An optional default value can be provided if desired.

  ## Example

      iex> {test_var, expected_value} = System.get_env |> Enum.take(1) |> List.first
      ...> Application.put_env(:myapp, :test_var, {:system, test_var})
      ...> ^expected_value = #{__MODULE__}.get(:myapp, :test_var)
      ...> :ok
      :ok

      iex> Application.put_env(:myapp, :test_var2, 1)
      ...> 1 = #{__MODULE__}.get(:myapp, :test_var2)
      1

      iex> :default = #{__MODULE__}.get(:myapp, :missing_var, :default)
      :default
  """
  @spec get(atom, atom, term | nil) :: term
  def get(app, key, default \\ nil) when is_atom(app) and is_atom(key) do
    expand(Application.get_env(app, key), default)
  end

  @doc """
  Same as get/3, but raises an error if the key is not found.
  """
  def get!(app, key), do: get(app, key, :error) |> ok!(key)

  @doc """
  Same as get/3, but returns the result as an integer.
  If the value cannot be converted to an integer, the
  default is returned instead.
  """
  @spec get_integer(atom(), atom(), integer() | nil | :error) :: integer
  def get_integer(app, key, default \\ nil) do
    case get(app, key, nil) do
      nil -> default
      n when is_integer(n) -> n
      n ->
        case Integer.parse(n) do
          {i, _} -> i
          :error -> default
        end
    end
  end

  @doc """
  Same as get_integer/3, but raises an error if the key is not found
  """
  def get_integer!(app, key), do: get_integer(app, key, :error) |> ok!(key)

  @doc """
  Same as get/3, but expect config entry is a map
  and expand keys if {:system, "VAR"} is provided.

  ## Example

      iex> {test_var, expected_value} = System.get_env |> Enum.take(1) |> List.first
      ...> Application.put_env(:myapp, :test_var, %{ key: {:system, test_var}})
      ...> %{ key: ^expected_value } = #{__MODULE__}.get_map(:myapp, :test_var)
      ...> :ok
      :ok

      iex> config = %{ key: {:system, "NOT_FOUND_ENV", "default_value" }}
      ...> Application.put_env(:myapp, :test_var2, config)
      ...> #{__MODULE__}.get_map(:myapp, :test_var2)
      %{key: "default_value"}
      
      iex> #{__MODULE__}.get_map(:myapp, :test_var3, %{ key: "default_value" })
      %{key: "default_value"}
  """
  @spec get_map(atom(), atom(), map()) :: map
  def get_map(app, key, default \\ %{}) do
    case get(app, key, %{}) do
      m when is_map(m) ->
        m
          |> Map.merge(default)
          |> Enum.map(fn {k, v} -> {k, expand(v, default[k])} end)
          |> Map.new
      m ->
        m
    end
  end

  defp ok!(:error, key), do: raise "Required key :#{key} not found"
  defp ok!(v, _), do: v
  
  defp expand({:system, env_var}, default) do
    case System.get_env(env_var) do
      nil -> default
      val -> val
    end
  end
  defp expand({:system, env_var, preconfigured_default}, _) do
    case System.get_env(env_var) do
      nil -> preconfigured_default
      val -> val
    end
  end
  defp expand(nil, default), do: default
  defp expand(val, _), do: val
end
