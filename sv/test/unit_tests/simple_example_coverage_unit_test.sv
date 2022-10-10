`include "svunit_defines.svh"
`include "simple_example_coverage.sv"

module simple_example_coverage_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "simple_example_coverage_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  simple_example_coverage censor;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    censor = new(/* New arguments if needed */);
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

    `SVTEST(simple_test)
      censor.sample_state("fsm_0", "state_a");
      censor.sample_state("fsm_0", "state_b");
      censor.sample_state("fsm_1", "state_1");
      censor.sample_state("fsm_1", "state_2");
      censor.sample_event("fsm_0", "BOOM");
      censor.sample_state("fsm_0", "state_c");
      censor.sample_state("fsm_1", "state_1");
      
    `SVTEST_END


  `SVUNIT_TESTS_END

endmodule
