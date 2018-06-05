defmodule ExDoc.Highlighter.HtmlDecoderTest do
  use ExUnit.Case, async: true

  alias ExDoc.Highlighter.HtmlDecoder

  def encoded_snippets_from_file(path) do
    path
    |> File.read!()
    |> String.split("\n<!-- example -->\n")
  end

  def decoded_snippets_from_file(path) do
    path
    |> File.read!()
    |> String.split("\n# example\n")
  end

  # The correctness of a decoder is easy to test using property testing,
  # but ExDoc can't import a property testing library, and we don't want
  # to add a dependency on StreamData, which is only available in recent
  # Elixir version.
  # Instead of using property testing, we generate a corpus of valid outputs
  # and inputs and use such corpus to detect regressions
  test "decode the code snippets in plug's docs" do
    encoded_snippets = encoded_snippets_from_file("test/fixtures/html_decoder/inputs.html")
    decoded_snippets = decoded_snippets_from_file("test/fixtures/html_decoder/outputs.exs")

    for {encoded_snippet, decoded_snippet} <- List.zip([encoded_snippets, decoded_snippets]) do
      assert HtmlDecoder.unescape_html_entities(encoded_snippet) == decoded_snippet
    end
  end

  # Test os all entities are decoded correctly
  test "all entities" do
    assert HtmlDecoder.unescape_html_entities("&amp;") == "&"
    assert HtmlDecoder.unescape_html_entities("&lt;") == "<"
    assert HtmlDecoder.unescape_html_entities("&gt;") == ">"
    assert HtmlDecoder.unescape_html_entities("&quot;") == "\""
    assert HtmlDecoder.unescape_html_entities("&#39;") == "'"
  end

  # Some simple examples, which include all quoted entities
  # (entities in context)
  test "more examples" do
    assert HtmlDecoder.unescape_html_entities("a &amp; b") == "a & b"
    assert HtmlDecoder.unescape_html_entities("a &gt; b") == "a > b"
    assert HtmlDecoder.unescape_html_entities("a &lt; b") == "a < b"
    assert HtmlDecoder.unescape_html_entities("&quot;string&quot;") == "\"string\""
    assert HtmlDecoder.unescape_html_entities("&#39;string&#39;") == "'string'"
  end
end