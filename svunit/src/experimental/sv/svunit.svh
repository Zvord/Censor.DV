`include "svunit_internal.svh"


`define TEST_BEGIN(TEST_NAME) \
  `SVUNIT_INTERNAL_TEST_BEGIN(TEST_NAME, svunit::test)


`define TEST_END \
  `SVUNIT_INTERNAL_TEST_END


`define TEST_F_BEGIN(TEST_FIXTURE, TEST_NAME) \
  `SVUNIT_INTERNAL_TEST_BEGIN(TEST_NAME, TEST_FIXTURE)


`define TEST_F_END \
  `SVUNIT_INTERNAL_TEST_END
