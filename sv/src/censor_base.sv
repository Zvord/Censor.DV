virtual class censor_base extends uvm_component;

    protected censor_scenario scenarios[$];

    pure virtual function void fill_scenarios();
    pure virtual function void sample(int id);
    extern function new(string name = "censor_base", uvm_component parent = null);
    extern function void sample_state(string fsm_name, string fsm_state);
    extern function void sample_event(string fsm_name, string fsm_state);
    extern function void add_scenario(censor_scenario s);
    extern function void add_valid_state(string fsm_name, string state);
    extern function void finalize();

endclass


function censor_base::new(string name = "censor_base", uvm_component parent = null);
    super.new(name, parent);
endfunction


function void censor_base::sample_state(string fsm_name, string fsm_state);
    foreach(scenarios[i]) begin
        if (scenarios[i].sample_state(fsm_name, fsm_state)) begin 
            if (scenarios[i].compare()) begin
                sample(scenarios[i].id);
            end
        end
    end
endfunction


function void censor_base::sample_event(string fsm_name, string fsm_state);
    foreach(scenarios[i]) begin
        // todo add event validity checking
        if (scenarios[i].compare()) begin
            sample(scenarios[i].id);
        end
    end
endfunction


function void censor_base::add_scenario(censor_scenario s);
    scenarios.push_back(s);
endfunction


function void censor_base::add_valid_state(string fsm_name, string state);
    foreach(scenarios[i])
        scenarios[i].add_valid_state(fsm_name, state);
endfunction


function void censor_base::finalize();
    foreach(scenarios[i])
        scenarios[i].finalize();
endfunction
