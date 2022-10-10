namespace Censor.Tests;
using Censor;
using System.Linq;

public class FsmTests
{
    [Fact]
    public void FSMParsingTest()
    {
        string wave = "33.3";
        string[] data = {"SUNNY", "RAIN", "SUNNY"};
        string node = "..A";
        string name = "qwerty";
        Fsm fsm = new(name, wave, data, node);
        Assert.Equal(name, fsm.Name);
        Assert.Equal(3, fsm.States.Count);
        Assert.Equal(data, fsm.States.Select(s => s.Name));
        Assert.Equal(new int[] {0, 1, 3}, fsm.States.Select(s => s.StartTime));
        Assert.NotNull(fsm.States[1].Nodes);
        Assert.Single(fsm.States[1].Nodes);
    }

    [Fact]
    public void EventParsingTest()
    {
        string wave = "33.3";
        string[] data = {"SUNNY", "RAIN", "SUNNY"};
        string node = "..A";
        string name = "qwerty";
        Fsm fsm = new(name, wave, data, node);
        wave = "0.20..";
        data = new string[]{"ECLIPSE"};
        fsm.AddEvent(wave, data);
        // Assert.Single(fsm.Events);
        Assert.Equal(new string[]{"ECLIPSE"}, fsm.States[1].Events);
    }
}