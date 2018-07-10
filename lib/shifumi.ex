defmodule Shifumi do
  @moduledoc false

  #############
  # Constants #
  #############

  def online_topic, do: "presence"

  def beat, do: Application.get_env(:shifumi, :beat)

  def splash_duration, do: Application.get_env(:shifumi, :splash_duration)

  def inactive_limit, do: Application.get_env(:shifumi, :inactive_limit)

  def upload_at, do: Application.get_env(:shifumi, :upload_at)

  def max_rounds, do: 100

  def max_empty_rounds, do: 10

  def max_wells, do: 12

  def well_bonus, do: 1
end
