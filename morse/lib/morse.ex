defmodule Morse do

  alias Synthex.Context
  alias Synthex.Output.WavWriter
  alias Synthex.File.WavHeader
  alias Synthex.Generator.Oscillator
  alias Synthex.Sequencer
  alias Synthex.Sequencer.Morse
  alias Synthex.ADSR
  alias Synthex.Input.WavReader
  alias Synthex.Output.SoxPlayer

  use Synthex.Math

  def main(args) do
    args |> parse_args |> process
  end

  def process([]) do
    IO.puts "No arguments given"
  end

  def process(options) do
    options[:text] |>
    to_morse |>
    play
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [text: :string]
    )
    options
  end


  def to_morse(text) do
    IO.puts "Converting to \"#{text}\" to morse..."
    header = %WavHeader{channels: 1, format: :float, sample_size: 32}
    output_file = System.user_home() <> "/morse.wav"
    {:ok, writer} = WavWriter.open(output_file, header)

    sequencer = Morse.from_text(text, Morse.wpm_to_dot_duration(15))
    duration = Sequencer.sequence_duration(sequencer)

    context =
      %Context{output: writer, rate: header.rate}
      |> Context.put_element(:main, :osc1, %Oscillator{algorithm: :sine})
      |> Context.put_element(:main, :adsr, ADSR.adsr(header.rate, 1.0, 0.01, 0.000001, 0.01, 10, 10))
      |> Context.put_element(:main, :sequencer, sequencer)

    Synthex.synthesize(context, duration, fn (ctx) ->
      {ctx, {freq, amp}} = Context.get_sample(ctx, :main, :sequencer)
      {ctx, osc1} = Context.get_sample(ctx, :main, :osc1, %{frequency: freq})
      {ctx, adsr} = Context.get_sample(ctx, :main, :adsr, %{gate: ADSR.amplification_to_gate(amp)})
      {ctx, osc1 * adsr}
    end)

    WavWriter.close(writer)
    :timer.sleep(100)

    output_file
  end


  def play(path) do
    IO.puts "Playing wav file \"#{path}\"..."
    reader = WavReader.open(path, false)
    {:ok, writer} = SoxPlayer.open(rate: reader.header.rate, channels: reader.header.channels)
    context =
      %Context{output: writer, rate: reader.header.rate}
      |> Context.put_element(:main, :wav, reader)

    Synthex.synthesize(context, WavReader.get_duration(reader), fn (ctx) ->
      Context.get_sample(ctx, :main, :wav)
    end)

    SoxPlayer.close(writer)
  end
end
