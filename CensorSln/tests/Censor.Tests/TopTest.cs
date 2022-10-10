namespace Censor.Tests;
using Censor;
using System.Linq;

public class TopTest
{
    Covergroup cg;
    public TopTest()
    {
        cg = Covergroup.FromFile("real_example.json");
    }
    [Fact]
    public void TopAttributesTest() // todo rename
    {
        Covergroup cg = Covergroup.FromFile("real_example.json");
        // Top attributes
        Assert.NotNull(cg);
        Assert.Equal("weather_coverage", cg.ClassName);
        Assert.Equal("weather_cg_enum", cg.EnumName);
        Assert.Equal("weather_scenario_cg", cg.CgName);
        Assert.Equal(6, cg.Scenarios.Length);
    }
    [Fact]
    public void IntersectionTest()
    {
        // Intersections
        var scenario = cg.Scenarios.First(sc => sc.ScenarioName == "WEATHER_CROSS");
        Assert.NotNull(scenario);
        var fsm0 = scenario.FSMs.First(fsm => fsm.Name == "weather_fsm0");
        var fsm1 = scenario.FSMs.First(fsm => fsm.Name == "weather_fsm1");
        Assert.Single(fsm0.States[2].Intersections);
        Assert.Equal(fsm0.States[2].Intersections[0], fsm1.States[1]);
    }

    [Fact]
    public void FullIntersectionTest()
    {   
        // Full intersection
        var scenario = cg.Scenarios.First(sc => sc.ScenarioName == "FULL_INTERSECT");
        Assert.NotNull(scenario);
        var fsm0 = scenario.FSMs.First(fsm => fsm.Name == "weather_fsm0");
        var fsm1 = scenario.FSMs.First(fsm => fsm.Name == "weather_fsm1");
        var inter0 = new[] {fsm1.States[0], fsm1.States[1]};
        var inter1 = new[] {fsm1.States[2]};
        var inter2 = new[] {fsm1.States[2], fsm1.States[3]};
        var inters = new[] {inter0, inter1, inter2};
        foreach(var i in Enumerable.Range(0, inters.Count()))
        {
            foreach(var state in fsm1.States)
            {
                Assert.Equal(inters[i].Contains(state), fsm0.States[i].HasIntersectionWith(state));
            }
        }
        var crosses = fsm0.GetCrossAt(0)
                          .Select(pair => (pair.Item1.FsmName, pair.Item2.FsmName))
                          .ToList();
        Assert.Equal(new[] {("weather_fsm0", "weather_fsm1")}, crosses);
    }
}