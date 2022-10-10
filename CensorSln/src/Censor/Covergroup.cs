namespace Censor
{
    using System.Text.Json.Serialization;
    using System.Text.Json;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    

    public partial class Covergroup
    {
        [JsonPropertyName("$schema")]
        public string? Schema { get; set; }

        [JsonPropertyName("class_name")]
        public string? ClassName { get; set; } = null!;

        [JsonPropertyName("enum_name")]
        public string? EnumName { get; set; } = null!;

        [JsonPropertyName("covergroup_name")]
        public string? CgName { get; set; } = null!;

        [JsonPropertyName("fsm_descriptions")]
        public FsmDescription[] FsmDescriptions { get; set; } = null!;

        [JsonPropertyName("scenarios")]
        public Scenario[] Scenarios { get; set; } = null!;

        static public Covergroup FromFile(string filepath)
        {
            var contents = File.ReadAllText(filepath);
            Covergroup? cg = JsonSerializer.Deserialize<Covergroup>(contents);
            if (cg == null)
                throw new Exception("Can't read the input JSON");

            if (cg.ClassName is null)
                throw new Exception("class_name is absent");
            if (cg.EnumName is null)
                throw new Exception("enum_name is absent");
            if (cg.CgName is null)
                throw new Exception("cg_name is absent");
            if (cg.FsmDescriptions is null)
                throw new Exception("fsm_descriptions is absent");
            if (cg.Scenarios is null)
                throw new Exception("scenarios is absent");

            IEnumerable<string> validFsmNames = cg.FsmDescriptions.Select(fsm => fsm.Name);
            foreach(var scenario in cg.Scenarios)
            {
                if (scenario.Signal is null)
                    throw new Exception("Scenario without any signals");
                scenario.ParseScenario(validFsmNames);
            }
            return cg;
        }

        public string Print()
        {
            MyStringBuilder sb = new();
            sb.AppendLine("import uvm_pkg::*;");
            sb.AppendLine("`include \"uvm_macros.svh\"");
            sb.AppendLine("import censor_pkg::*;");
            sb.AppendLine("");
            sb.AppendLine($"class {ClassName} extends censor_base;");
            sb.IncreaseIndentLevel();
            sb.AppendLine($"`uvm_component_utils({ClassName})");
            sb.AppendLine("");
            sb.AppendLine("typedef enum {");
            sb.IncreaseIndentLevel();
            foreach(var scenario in Scenarios)
            {
                if (scenario == Scenarios.Last())
                    sb.AppendLine($"{scenario.ScenarioName}");
                else
                    sb.AppendLine($"{scenario.ScenarioName},");
            }
            sb.DecreaseIndentLevel();
            sb.AppendLine($"}} {EnumName};");
            sb.AppendLine("");
            sb.AppendLine($"bit raw_coverage[{EnumName}];");
            sb.AppendLine("");
            sb.AppendLine($"covergroup {CgName} with function sample ({EnumName} name);");
            sb.IncreaseIndentLevel();
            sb.AppendLine("coverpoint name;");
            sb.DecreaseIndentLevel();
            sb.AppendLine("endgroup");
            sb.AppendLine("");
            sb.AppendLine($"function new(string name = \"{ClassName}\", uvm_component parent = null);");
            sb.IncreaseIndentLevel();
            sb.AppendLine("super.new(name, parent);");
            sb.AppendLine($"{CgName} = new();");
            sb.AppendLine("fill_scenarios();");
            sb.AppendLine("configure_fsms();");
            sb.AppendLine("finalize();");
            sb.DecreaseIndentLevel();
            sb.AppendLine("endfunction");
            sb.AppendLine("");
            sb.AppendLine("function void sample(int id);");
            sb.IncreaseIndentLevel();
            sb.AppendLine($"{EnumName} e;");
            sb.AppendLine("if (!$cast(e, id)) begin");
            sb.IncreaseIndentLevel();
            sb.AppendLine("`uvm_fatal(get_name(), $sformatf(\"Method sample got an id %0d that does not correspond to any enum values of enum_type_to_cover\", id))");
            sb.DecreaseIndentLevel();
            sb.AppendLine("end");
            sb.AppendLine($"{CgName}.sample(e);");
            sb.AppendLine("raw_coverage[e] = 1;");
            sb.DecreaseIndentLevel();
            sb.AppendLine("endfunction");
            sb.AppendLine("");
            sb.AppendLine("function void fill_scenarios();");
            sb.IncreaseIndentLevel();
            foreach(var scenario in Scenarios)
            {
                sb.AppendLine("begin");
                sb.IncreaseIndentLevel();
                sb.AppendLine($"{EnumName} e = {scenario.ScenarioName};");
                sb.AppendLine("censor_scenario s = new(e.name(), int'(e));");
                List<State> thisTimeStates = new();
                foreach(int t in scenario.GetAllTimes())
                {
                    foreach(var state in scenario.GetStateAt(t))
                    {
                        sb.AppendLine($"void'(s.add_state_to_pattern(\"{state.FsmName}\", \"{state.Name}\"));");
                        thisTimeStates.Add(state);
                    }
                    foreach(var pair in scenario.GetEventsAt(t))
                        foreach(var evnt in pair.Events)
                            sb.AppendLine($"void'(s.add_event_to_pattern(\"{pair.Fsm}\", \"{evnt}\"));");
                    foreach(var crosses in scenario.GetCrossesAt(t))
                        foreach(var pair in crosses)
                            sb.AppendLine($"s.add_intersection(\"{pair.Item1.FsmName}\", \"{pair.Item2.FsmName}\");");
                }
                foreach(var fsm in scenario.FSMs)
                    foreach(var alias in fsm.Aliases)
                        foreach(var original in alias.OriginalStateNames)
                            sb.AppendLine($"s.add_state_synonym(\"{fsm.Name}\", \"{original}\", \"{alias.JsonStateName}\");");
                sb.AppendLine("add_scenario(s);");
                sb.DecreaseIndentLevel();
                sb.AppendLine("end");
            }
            sb.DecreaseIndentLevel();
            sb.AppendLine("endfunction");
            sb.DecreaseIndentLevel();
            sb.AppendLine();
            sb.AppendLine("function void configure_fsms();");
            sb.IncreaseIndentLevel();
            foreach(var fsm in FsmDescriptions)
                foreach(var state in fsm.ValidStates)
                    sb.AppendLine($"add_valid_state(\"{fsm.Name}\", \"{state}\");");
            sb.DecreaseIndentLevel();
            sb.AppendLine("endfunction");
            sb.AppendLine("endclass");
            return sb.ToString();
        }

        
    }

    public partial class FsmDescription
    {
        [JsonPropertyName("source_name")]
        public string Name { get; set; } = null!;

        [JsonPropertyName("valid_states")]
        public string[] ValidStates { get; set; } = null!;
    }

    public partial class Config
    {
        [JsonPropertyName("hscale")]
        public long Hscale { get; set; }
    }

    

    public partial class Alias
    {
        [JsonPropertyName("original_state_names")]
        public string[] OriginalStateNames { get; set; } = null!;

        [JsonPropertyName("json_state_name")]
        public string JsonStateName { get; set; } = null!;
    }
}