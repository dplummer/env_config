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

      iex> System.put_env("MY_ENV_NUMBER", "10")
      ...> Application.put_env(:myapp, :test_var, %{ key: {:system, :integer, "MY_ENV_NUMBER"}})
      ...> #{__MODULE__}.get_map(:myapp, :test_var)
      %{ key: 10 }

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
  
  # Expand and/or convert
  defp expand({:system, env_var, default}) when is_bitstring(env_var) do
    case System.get_env(env_var) do
      nil -> default
      val -> val
    end
  end
  
  defp expand({:system, type, env_var, default}) do
    try do
      case {type, expand({:system, env_var, default}, nil)} do
        {_, ^default} -> default
        {:charlist, value} -> to_charlist(value)
        {:integer, value} ->
          case Integer.parse(value) do
            {i, _} -> i
            :error -> default
          end
        {:boolean, value} when value == "no" or value == "not" or value == "off" or value == "false" or value == "0" ->
          false
        {:boolean, value} when value == "yes" or value == "on" or value == "true" or value == "1" ->
          true
        v -> v
      end
    rescue
      _ -> default
    end
  end
  
  defp expand(val), do: val
  
  # Put default in value
  defp expand(nil, default), do: default
  defp expand({:system, type, env_var}, default) when is_atom(type) do
    expand({:system, type, env_var, default})
  end
  defp expand({:system, env_var}, default) do
    expand({:system, env_var, default})
  end
  defp expand(value, _), do: expand(value)
end