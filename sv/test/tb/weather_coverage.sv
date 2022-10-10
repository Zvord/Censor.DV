import uvm_pkg::*;
`include "uvm_macros.svh"
import censor_pkg::*;

class weather_coverage extends censor_base;
    `uvm_component_utils(weather_coverage)
    
    typedef enum {
        SUN_RAIN_SUN,
        ECLIPSE_EVENT,
        PRECIPATION_ON_OFF,
        WEATHER_CROSS,
        EXACT_EVENT,
        FULL_INTERSECT
    } weather_cg_enum;
    
    bit raw_coverage[weather_cg_enum];
    
    covergroup weather_scenario_cg with function sample (weather_cg_enum name);
        coverpoint name;
    endgroup
    
    function new(string name = "weather_coverage", uvm_component parent = null);
        super.new(name, parent);
        weather_scenario_cg = new();
        fill_scenarios();
        configure_fsms();
        finalize();
    endfunction
    
    function void sample(int id);
        weather_cg_enum e;
        if (!$cast(e, id)) begin
            `uvm_fatal(get_name(), $sformatf("Method sample got an id %0d that does not correspond to any enum values of enum_type_to_cover", id))
        end
        weather_scenario_cg.sample(e);
        raw_coverage[e] = 1;
    endfunction
    
    function void fill_scenarios();
        begin
            weather_cg_enum e = SUN_RAIN_SUN;
            censor_scenario s = new(e.name(), int'(e));
            void'(s.add_state_to_pattern("weather_fsm0", "SUNNY"));
            void'(s.add_state_to_pattern("weather_fsm0", "RAIN"));
            void'(s.add_state_to_pattern("weather_fsm0", "SUNNY"));
            add_scenario(s);
        end
        begin
            weather_cg_enum e = ECLIPSE_EVENT;
            censor_scenario s = new(e.name(), int'(e));
            void'(s.add_state_to_pattern("weather_fsm0", "RAIN"));
            void'(s.add_state_to_pattern("weather_fsm0", "SUNNY"));
            void'(s.add_event_to_pattern("weather_fsm0", "ECLIPSE"));
            void'(s.add_state_to_pattern("weather_fsm0", "RAIN"));
            add_scenario(s);
        end
        begin
            weather_cg_enum e = PRECIPATION_ON_OFF;
            censor_scenario s = new(e.name(), int'(e));
            void'(s.add_state_to_pattern("weather_fsm0", "PRECIP_ON"));
            void'(s.add_state_to_pattern("weather_fsm0", "PRECIP_OFF"));
            void'(s.add_state_to_pattern("weather_fsm0", "PRECIP_ON"));
            void'(s.add_state_to_pattern("weather_fsm0", "PRECIP_OFF"));
            s.add_state_synonym("weather_fsm0", "HAIL", "PRECIP_ON");
            s.add_state_synonym("weather_fsm0", "RAIN", "PRECIP_ON");
            s.add_state_synonym("weather_fsm0", "SNOW", "PRECIP_ON");
            s.add_state_synonym("weather_fsm0", "SUNNY", "PRECIP_OFF");
            s.add_state_synonym("weather_fsm0", "CLOUDY", "PRECIP_OFF");
            add_scenario(s);
        end
        begin
            weather_cg_enum e = WEATHER_CROSS;
            censor_scenario s = new(e.name(), int'(e));
            void'(s.add_state_to_pattern("weather_fsm0", "RAIN"));
            void'(s.add_state_to_pattern("weather_fsm1", "HAIL"));
            void'(s.add_state_to_pattern("weather_fsm0", "CLOUDY"));
            void'(s.add_state_to_pattern("weather_fsm1", "SUNNY"));
            void'(s.add_state_to_pattern("weather_fsm0", "SUNNY"));
            s.add_intersection("weather_fsm0", "weather_fsm1");
            void'(s.add_state_to_pattern("weather_fsm1", "HAIL"));
            add_scenario(s);
        end
        begin
            weather_cg_enum e = EXACT_EVENT;
            censor_scenario s = new(e.name(), int'(e));
            void'(s.add_state_to_pattern("weather_fsm0", "CLOUDY"));
            void'(s.add_state_to_pattern("weather_fsm0", "HAIL"));
            void'(s.add_event_to_pattern("weather_fsm0", "Run for beer"));
            void'(s.add_state_to_pattern("weather_fsm0", "RAIN"));
            add_scenario(s);
        end
        begin
            weather_cg_enum e = FULL_INTERSECT;
            censor_scenario s = new(e.name(), int'(e));
            void'(s.add_state_to_pattern("weather_fsm0", "SUNNY"));
            void'(s.add_state_to_pattern("weather_fsm1", "RAIN"));
            s.add_intersection("weather_fsm0", "weather_fsm1");
            void'(s.add_state_to_pattern("weather_fsm1", "SUNNY"));
            s.add_intersection("weather_fsm0", "weather_fsm1");
            void'(s.add_state_to_pattern("weather_fsm0", "RAIN"));
            void'(s.add_state_to_pattern("weather_fsm1", "RAIN"));
            s.add_intersection("weather_fsm0", "weather_fsm1");
            void'(s.add_state_to_pattern("weather_fsm0", "SUNNY"));
            s.add_intersection("weather_fsm0", "weather_fsm1");
            void'(s.add_state_to_pattern("weather_fsm1", "SUNNY"));
            s.add_intersection("weather_fsm0", "weather_fsm1");
            add_scenario(s);
        end
    endfunction
    
    function void configure_fsms();
        add_valid_state("weather_fsm0", "SUNNY");
        add_valid_state("weather_fsm0", "CLOUDY");
        add_valid_state("weather_fsm0", "RAIN");
        add_valid_state("weather_fsm0", "SNOW");
        add_valid_state("weather_fsm0", "HAIL");
        add_valid_state("weather_fsm1", "SUNNY");
        add_valid_state("weather_fsm1", "CLOUDY");
        add_valid_state("weather_fsm1", "RAIN");
        add_valid_state("weather_fsm1", "SNOW");
        add_valid_state("weather_fsm1", "HAIL");
        add_valid_state("leisure_fsm", "WALK");
        add_valid_state("leisure_fsm", "SLEEP");
        add_valid_state("leisure_fsm", "MOVIE");
        add_valid_state("leisure_fsm", "CAFE");
        add_valid_state("leisure_fsm", "BIKE");
    endfunction
    endclass
