namespace Censor
{
    using System.Text.Json.Serialization;
    using System.Collections.Generic;
    using System.Linq;
    
    public partial class Scenario
    {
        [JsonPropertyName("description")]
        public string? Description { get; set; }

        [JsonPropertyName("scenario_name")]
        public string? ScenarioName { get; set; }

        [JsonPropertyName("signal")]
        public Signal[] Signal { get; set; } = null!;

        [JsonPropertyName("config")]
        public Config? Config { get; set; }

        [JsonPropertyName("edge")]
        public string[]? Edge { get; set; }

        [JsonPropertyName("full_intersection")]
        public string[][]? FullIntersection { get; set; }

        public List<Fsm> FSMs;

        public Scenario()
        {
            FSMs = new();
        }

        public void ParseScenario(IEnumerable<string> validFsmNames)
        {
            // Find FSMs
            foreach (var signal in Signal)
            {
                if (string.IsNullOrEmpty(signal.Name))
                    continue;
                var renamed = !string.IsNullOrEmpty(signal.SourceName);
                string fsmName = renamed ? signal.SourceName! : signal.Name;
                var known = validFsmNames.Contains(fsmName);
                if (renamed && !known)
                    throw new Exception($"Can't find {fsmName} in fsm_desctiptions");
                if (!renamed && !known)
                    continue;
                if (signal.Data is null)
                    throw new Exception("FSM must have the data field");
                if (signal.Wave is null)
                    throw new Exception("FSM must have the wave field");
                Fsm fsm = new(fsmName, signal.Wave, signal.Data, signal.Node);
                if (signal.Aliases is not null)
                    fsm.Aliases = signal.Aliases;
                FSMs.Add(fsm);

                if (string.IsNullOrEmpty(signal.EventName))
                    continue;
                
                var evntSignal = Signal.First(s => s.Name == signal.EventName);
                if (evntSignal is null)
                    throw new Exception($"Can't find provided event name {signal.EventName} for scenario {ScenarioName}");
                if (evntSignal.Data is null)
                    throw new Exception($"Event {evntSignal.Name} must have the data field");
                if (evntSignal.Wave is null)
                    throw new Exception($"Event {evntSignal.Name} must have the wave field");
                fsm.AddEvent(evntSignal.Wave, evntSignal.Data);
            }
            SetIntersections();
        }

        /// <summary>
        /// Once the scenario JSON has been parsed, we compute states intersections,
        /// using Edges and Full Intersection.
        /// </summary>
        public void SetIntersections()
        {
            // First, we go through Edges
            var nodePairs = GetNodePairs();
            var allStates = FSMs.SelectMany(fsm => fsm.States).ToList();
            foreach(var pair in nodePairs)
            {
                var fromState = allStates.FirstOrDefault(s => s.Nodes.Contains(pair.Item1));
                var toState = allStates.FirstOrDefault(s => s.Nodes.Contains(pair.Item2));
                if (fromState == null)
                    throw new ArgumentException($"Can't find a state with node {pair.Item1}. Is FSM description correct?");
                if (toState == null)
                    throw new ArgumentException($"Can't find a state with node {pair.Item2}. Is FSM description correct?");
                fromState.Intersections.Add(toState);
            }

            // Now, by FullIntersections
            if (FullIntersection is not null)
            {
                foreach(var pair in FullIntersection)
                {
                    if (pair.Length != 2)
                        throw new Exception("\"full_intersection\" must be a collection of pairs");
                    var fromFsm = FSMs.First(fsm => fsm.Name == pair[0]);
                    var toFsm = FSMs.First(fsm => fsm.Name == pair[1]);
                    SetFullIntersection(fromFsm, toFsm);
                }

            }
        }

        public void SetFullIntersection(Fsm fromFsm, Fsm toFsm)
        {
            foreach(var state in fromFsm.States)
            {
                var between = toFsm.States
                                   .Where(s => ((s.StartTime >= state.StartTime) && (s.StartTime < state.StopTime))
                                                                                 ||
                                                (state.StartTime >= s.StartTime) && (state.StartTime < s.StopTime));
                state.AddIntersections(between);
            }
        }

        public IEnumerable<int> GetAllTimes() =>
            FSMs.SelectMany(fsm => fsm.States).Select(s => s.StartTime).Distinct().OrderBy(i => i);

        public IEnumerable<State> GetStateAt(int t)
        {
            foreach (var fsm in FSMs)
            {
                var s = fsm.StateAtTime(t);
                if (s is not null)
                    yield return s;
            }
        }

        public IEnumerable<(string Fsm, List<string> Events)> GetEventsAt(int t)
        {
            foreach (var fsm in FSMs)
            {
                var e = fsm.EventsAtTime(t);
                if (e is not null)
                    yield return (fsm.Name, e);
            }
        }

        public IEnumerable<List<(State, State)>> GetCrossesAt(int t)
        {
            foreach (var fsm in FSMs)
            {
                var crosses = fsm.GetCrossAt(t);
                if (crosses is not null)
                    yield return crosses;
            }

        }

        public List<(char, char)> GetNodePairs()
        {
            List<(char, char)> list = new();
            if (Edge is null)
                return list;
            foreach(var edge in Edge)
            {
                // edge example: A~-B desctiption
                // We leave only A~-B
                var textPair = edge.Split(' ')[0];
                var pair = (textPair[0], textPair[textPair.Length-1]);
                list.Add(pair);
            }
            return list;
        }
    }
}