defmodule SoundGen.Note do
  defstruct note: "A", octave: 4, sharp: false, duration: 0.5

  @a4 440.0

  @shift_map %{
    {"C", false} => -9,
    {"C", true} => -8,
    {"D", false} => -7,
    {"D", true} => -6,
    {"E", false} => -5,
    {"F", false} => -4,
    {"F", true} => -3,
    {"G", false} => -2,
    {"G", true} => -1,
    {"A", false} => 0,
    {"A", true} => 1,
    {"B", false} => 2
  }

  @doc """
  Note can be encoded as string using format "<note_letter><octave>[#]|<diration>", where "#"
  denotes sharp note.
  """
  def new(notation) when is_binary(notation) do
    notation = String.upcase(notation)
    {note_params, duration} = split_note_params_duration(notation)
    sharp = sharp?(note_params)
    {note, octave} = split_note_octave(note_params)

    opts = [
      note: note,
      octave: octave,
      sharp: sharp,
      duration: duration
    ]

    encode(opts)
  end

  defp encode(args) when is_list(args) do
    note = Keyword.get(args, :note, "A")
    octave = Keyword.get(args, :octave, 4)
    sharp = Keyword.get(args, :sharp, false)
    duration = Keyword.get(args, :duration, 0.25)

    cond do
      octave not in 0..8 -> {:error, "octave must be from 0 to 8 inclusive"}
      note not in ~w[C D E F G A B] -> {:error, "note must be from 'A' to 'D' inclusive"}
      true -> %__MODULE__{octave: octave, note: note, duration: duration, sharp: sharp}
    end
  end

  def frequency_and_duration(%__MODULE__{
        note: note,
        octave: octave,
        sharp: sharp,
        duration: duration
      }) do
    with shift when is_integer(shift) <- shift(note, sharp) do
      base_frequency = @a4 * 2 ** (shift / 12)
      frequency = base_frequency * 2 ** (4 - octave)
      {frequency, duration}
    else
      error -> error
    end
  end

  defp split_note_params_duration(notation) do
    notation
    |> String.split("|")
    |> then(fn
      [note_params, duration] -> {note_params, String.to_float(duration)}
      [note_params] -> {note_params, 0.25}
    end)
  end

  defp split_note_octave(note_params) do
    note_params
    |> String.trim_trailing("#")
    |> String.graphemes()
    |> then(fn
      [note, octave] -> {note, String.to_integer(octave)}
      [note] -> {note, 4}
    end)
  end

  defp sharp?(note_params), do: String.ends_with?(note_params, "#")

  defp shift(note, sharp) do
    Map.get(@shift_map, {note, sharp}, {:error, :wrong_note})
  end
end
