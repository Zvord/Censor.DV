namespace Censor
{
    using System.Text.Json.Serialization;
    public partial class Signal
        {
            [JsonPropertyName("name")]
            public string? Name { get; set; }

            [JsonPropertyName("wave")]
            public string? Wave { get; set; }

            [JsonPropertyName("data")]
            public string[]? Data { get; set; }

            [JsonPropertyName("event_name")]
            public string? EventName { get; set; }

            [JsonPropertyName("source_name")]
            public string? SourceName { get; set; }

            [JsonPropertyName("state_synonyms")]
            public Alias[]? Aliases { get; set; }

            [JsonPropertyName("node")]
            public string? Node { get; set; }

            [JsonPropertyName("need_exact_sequence")]
            public long? NeedExactSequence { get; set; }
        }
}