defmodule SoundGen do
  def sine_wave(duration, frequency) do
    args = args("sin", duration, frequency)
    play(args)
  end

  def square_wave(duration, frequency) do
    args = args("square", duration, frequency)
    play(args)
  end

  defp play(args) do
    case System.cmd("play", args) do
      {_output, 0} -> :ok
      {_output, code} -> {:error, code}
    end
  end

  defp args(type, duration, frequency) do
    String.split(
      "-q -r 48000 -n -c 2 synth #{duration} #{type} #{frequency} vol -10dB",
      ~r/\s/
    )
  end
end
