// using Censor;

// Console.WriteLine("Convert!");
// var filepath = "/Users/zvord/Library/CloudStorage/OneDrive-Personal/workspace/supa grupa/jsons/real_example.json";
// Covergroup cg = Covergroup.FromFile(filepath);
// var outfile = "/Users/zvord/Desktop/output.sv";
// File.WriteAllText(outfile, cg.Print());


namespace Censor
{
    using System;
    using CommandLine;
    class Program
    {
        public class Options
        {
            [Option('v', "verbose", Required = false, HelpText = "Set output to verbose messages.")]
            public bool Verbose { get; set; }
            [Option('i', "input", Required = true, HelpText = "Input JSON file.")]
            public string InputFile { get; set; } = null!;
            [Option('o', "output", Required = true, HelpText = "Output SV file.")]
            public string OutputFile { get; set; } = null!;
        }

        static void Main(string[] args)
        {
            Parser.Default.ParseArguments<Options>(args)
                .WithParsed<Options>(o =>
                {
                    Covergroup cg = Covergroup.FromFile(o.InputFile);
                    File.WriteAllText(o.OutputFile, cg.Print());
                });
        }
    }
}