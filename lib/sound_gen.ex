defmodule SoundGen do
  @doc """
  This package requires 'sox' to be install on your system.

  NOTE:

  jingle_bells = "E E E|0.5 E E E|0.5 E G C D|0.125 E|1.0 F F F F|0.125 F E E E|0.125 E D D E D|0.5 G|0.5"
  """
  def play_sequence(notation, type) do
    notation
    |> String.split()
    |> Enum.map(&SoundGen.Note.new/1)
    |> Enum.map(&SoundGen.Note.frequency_and_duration/1)
    |> Enum.each(fn {frequency, duration} ->
      case type do
        :square -> square_wave(frequency, duration)
        :sine -> sine_wave(frequency, duration)
      end
    end)
  end

  def sine_wave(frequency, duration) do
    args = args("sin", duration, frequency)
    play(args)
  end

  def square_wave(frequency, duration) do
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
      # "-q -r 48000 -n -c 2 synth #{duration} #{type} #{frequency} vol -10dB",
      "-q -r 48000 -n -c 2 synth #{duration} #{type} #{frequency}",
      ~r/\s/
    )
  end
end
