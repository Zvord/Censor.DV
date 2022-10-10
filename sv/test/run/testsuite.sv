module testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "testsuite";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  weather_coverage_unit_test weather_coverage_ut();
  simple_example_coverage_unit_test simple_example_coverage_ut();


  //===================================
  // Build
  //===================================
  function void build();
    weather_coverage_ut.build();
    simple_example_coverage_ut.build();
    svunit_ts = new(name);
    svunit_ts.add_testcase(weather_coverage_ut.svunit_ut);
    svunit_ts.add_testcase(simple_example_coverage_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    weather_coverage_ut.run();
    simple_example_coverage_ut.run();
    svunit_ts.report();
  endtask

endmodule
