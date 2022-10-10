//###########################################################################
//
//  Copyright 2021 The SVUnit Authors.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//###########################################################################


/**
 * Models a JUnit test suite.
 *
 * @see TestCase
 */
class TestSuite;

  local const string name;
  local TestCase test_cases[$];


  function new(string name);
    this.name = name;
  endfunction


  function string get_name();
    return name;
  endfunction


  function void add_test_case(TestCase test_case);
    test_cases.push_back(test_case);
  endfunction


  function XmlElement as_xml_element();
    XmlElement result = new("testsuite");
    result.set_attribute("name", name);
    foreach (test_cases[i])
      result.add_child(test_cases[i].as_xml_element());
    return result;
  endfunction

endclass
