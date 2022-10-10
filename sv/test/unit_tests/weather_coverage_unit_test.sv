`include "svunit_defines.svh"
`include "weather_coverage.sv"

module weather_coverage_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "weather_coverage_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  weather_coverage wc;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    wc = new(/* New arguments if needed */);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */

  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */

  endtask


  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SVTEST(_NAME_)
  // `SVTEST_END
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END
  //===================================
  `SVUNIT_TESTS_BEGIN

  `SVTEST(basic)
    wc.sample_state("weather_fsm0", "HAIL");
    wc.sample_state("weather_fsm0", "SUNNY");
    wc.sample_state("weather_fsm0", "RAIN");
    wc.sample_state("weather_fsm0", "SUNNY");
    `FAIL_UNLESS(wc.raw_coverage[weather_coverage::SUN_RAIN_SUN] == 1)
  `SVTEST_END

  `SVTEST(cross_no)
    wc.sample_state("weather_fsm1", "HAIL");
    wc.sample_state("weather_fsm1", "SUNNY");
    wc.sample_state("weather_fsm1", "HAIL");
    wc.sample_state("weather_fsm0", "RAIN");
    wc.sample_state("weather_fsm0", "CLOUDY");
    wc.sample_state("weather_fsm0", "SUNNY");
    `FAIL_UNLESS(wc.raw_coverage[weather_coverage::WEATHER_CROSS] != 1)
  `SVTEST_END

  `SVTEST(cross_yes)
    wc.sample_state("weather_fsm0", "RAIN");
    wc.sample_state("weather_fsm1", "HAIL");
    wc.sample_state("weather_fsm0", "CLOUDY");
    wc.sample_state("weather_fsm0", "SUNNY");
    wc.sample_state("weather_fsm1", "SUNNY");
    wc.sample_state("weather_fsm1", "HAIL");
    `FAIL_UNLESS(wc.raw_coverage[weather_coverage::WEATHER_CROSS] == 1)
  `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
