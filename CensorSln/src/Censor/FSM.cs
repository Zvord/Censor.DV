namespace Censor
{

    public class State
    {
        public readonly string Name;
        public readonly string FsmName;
        public int StartTime;
        public List<string> Events;
        public List<char> Nodes;
        public List<State> Intersections;
        public int StopTime;
        public int Duration => StopTime - StartTime;
        protected List<(int, string)> CrossAtTime;

        public State(string name, string fsmName, int start)
        {
            Name = name;
            StartTime = start;
            FsmName = fsmName;
            Events = new();
            Nodes = new();
            Intersections = new();
            CrossAtTime = new();
        }

        public bool HasIntersectionWith(State rhs)
        {
            return Intersections.Contains(rhs) || rhs.Intersections.Contains(this);
        }

        public void AddIntersection(State inter)
        {
            Intersections.Add(inter);
            int time = inter.StartTime > this.StartTime ? inter.StartTime : this.StartTime;
            CrossAtTime.Add((time, inter.FsmName));
        }

        public void AddIntersections(IEnumerable<State> input)
        {
            foreach(var state in input)
                AddIntersection(state);
        }
    }
    public class Fsm
    {
        public readonly string Name;
        public List<State> States = null!;
        public Alias[] Aliases = {};
        readonly char[] goodStateValues = {'2', '3', '4', '5', '6', '7', '8', '9'};

        public void ParseWave(string wave, string[] data, string? node = null)
        {
            var times = Enumerable.Range(0, wave.Length)
                                  .Where(i => goodStateValues.Contains(wave[i]));
            States = times.Zip(data, (time, dat) => new State(dat, Name, time)).ToList();
            if (node != null)
            {
                var nodeTimes = Enumerable.Range(0, node.Length)
                                          .Where(i => node[i] != '.').ToList();
                var nodeVals = node.Where(c => c != '.').ToArray();
                foreach(var i in Enumerable.Range(0, nodeTimes.Count))
                {
                    var state = States.Where(s => s.StartTime <= nodeTimes[i]).MaxBy(s => s.StartTime);
                    state!.Nodes.Add(nodeVals[i]);
                }
            }
            SetStopTimes(wave);
        }

        private void SetStopTimes(string wave)
        {
            foreach(var i in Enumerable.Range(0, States.Count - 1))
            {
                States[i].StopTime = States[i + 1].StartTime;
            }
            States[States.Count - 1].StopTime = wave.Length;
        }

        public void AddEvent(string wave, string[] data)
        {
            var times = Enumerable.Range(0, wave.Length)
                                  .Where(i => goodStateValues.Contains(wave[i]))
                                  .ToArray();
            var EventPerTime = times.Zip(data, (time, dat) => new {time, dat})
                                    .ToDictionary(x => x.time, x => x.dat);
            foreach (var i in Enumerable.Range(0, times.Length))
            {
                var state = States.Where(s => s.StartTime <= times[i]).MaxBy(s => s.StartTime);
                state!.Events.Add(data[i]);
            }
        }

        public State? StateAtTime(int t) => States.FirstOrDefault(s => s.StartTime == t);

        public List<string>? EventsAtTime(int t)
        {
            var state = StateAtTime(t);
            var events = state == null ? null : state.Events;
            return events;
        }

        public Fsm(string name, string wave, string[] data, string? node = null)
        {
            Name = name;
            ParseWave(wave, data, node);
        }

        public List<(State, State)> GetCrossAt(int t)
        {
            List<(State, State)> list = new();
            var stateCoversTime = (State s) => (s.StartTime <= t) && (t < s.StopTime);
            var states = States.Where(s => stateCoversTime(s));
            foreach(var state in states)
            {
                var goodCrosses = state.StartTime == t ? state.Intersections.Where(i => stateCoversTime(i))
                                                       : state.Intersections.Where(i => i.StartTime == t);
                var pairs = goodCrosses.Select(cross => (state, cross)).ToList();
                list.AddRange(pairs);
            }
            return list;
        }

    }
}