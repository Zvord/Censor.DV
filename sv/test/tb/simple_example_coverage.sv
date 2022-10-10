import uvm_pkg::*;
`include "uvm_macros.svh"
import censor_pkg::*;

class simple_example_coverage extends censor_base;
    `uvm_component_utils(simple_example_coverage)
    
    typedef enum {
        some_name
    } enum_type_that_will_be_covered;
    
    bit raw_coverage[enum_type_that_will_be_covered];
    
    covergroup just_a_covergroup with function sample (enum_type_that_will_be_covered name);
        coverpoint name;
    endgroup
    
    function new(string name = "simple_example_coverage", uvm_component parent = null);
        super.new(name, parent);
        just_a_covergroup = new();
        fill_scenarios();
        configure_fsms();
        finalize();
    endfunction
    
    function void sample(int id);
        enum_type_that_will_be_covered e;
        if (!$cast(e, id)) begin
            `uvm_fatal(get_name(), $sformatf("Method sample got an id %0d that does not correspond to any enum values of enum_type_to_cover", id))
        end
        just_a_covergroup.sample(e);
        raw_coverage[e] = 1;
    endfunction
    
    function void fill_scenarios();
        begin
            enum_type_that_will_be_covered e = some_name;
            censor_scenario s = new(e.name(), int'(e));
            void'(s.add_state_to_pattern("fsm_0", "state_a"));
            void'(s.add_state_to_pattern("fsm_1", "state_1"));
            void'(s.add_state_to_pattern("fsm_0", "state_b"));
            void'(s.add_event_to_pattern("fsm_0", "BOOM"));
            void'(s.add_state_to_pattern("fsm_1", "state_2"));
            s.add_intersection("fsm_0", "fsm_1");
            void'(s.add_state_to_pattern("fsm_0", "state_c"));
            void'(s.add_state_to_pattern("fsm_1", "state_1"));
            add_scenario(s);
        end
    endfunction
    
    function void configure_fsms();
        add_valid_state("fsm_0", "state_a");
        add_valid_state("fsm_0", "state_b");
        add_valid_state("fsm_0", "state_c");
        add_valid_state("fsm_1", "state_1");
        add_valid_state("fsm_1", "state_2");
    endfunction
    endclass
