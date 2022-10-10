class censor_scenario;

    protected censor_fsm pattern_fsms[string];
    protected censor_fsm observed_fsms[string];

    int id;
    string name;
    int step_number;

    extern function new(string name_, int id_);
    extern function void add_state_synonym(string fsm_name, string original, string alias_name);
    extern function void add_intersection(string from, string to);
    extern function void add_valid_state(string fsm_name, string fsm_state);
    extern function void add_expected_event(string fsm_name, string action_name);
    extern function void add_state_to_pattern(string fsm_name, string state_name);
    extern function bit sample_state(string fsm_name, string state_name);
    extern function void add_event_to_pattern(string fsm_name, string event_name);
    extern function bit sample_event(string fsm_name, string event_name);
    extern function bit compare();
    extern function bit check_state_intersections(string fsm_name, censor_state pattern_state);
    extern function void finalize();

endclass


function censor_scenario::new(string name_, int id_);
    name = name_;
    id = id_;
endfunction


function void censor_scenario::add_state_synonym(string fsm_name, string original, string alias_name);
    pattern_fsms[fsm_name].state_synonyms[original] = alias_name;
    add_valid_state(fsm_name, alias_name);
endfunction


function void censor_scenario::add_intersection(string from, string to);
    pattern_fsms[from].states[$].add_intersection(to, pattern_fsms[to].states.size()-1);
endfunction


function void censor_scenario::add_valid_state(string fsm_name, string fsm_state);
    if (!pattern_fsms.exists(fsm_name)) begin
        // todo valid states should be per scenario. Modify censor_base.
        pattern_fsms[fsm_name] = new(fsm_name);
    end
    pattern_fsms[fsm_name].add_valid_state(fsm_state);
endfunction


function void censor_scenario::add_expected_event(string fsm_name, string action_name);
    `uvm_fatal("Undefined", "The method add_expected_event is not implemented yet")
endfunction


function void censor_scenario::add_state_to_pattern(string fsm_name, string state_name);
    if (!pattern_fsms.exists(fsm_name))
        pattern_fsms[fsm_name] = new(fsm_name);
    pattern_fsms[fsm_name].add_state_to_pattern(state_name);
endfunction


function bit censor_scenario::sample_state(string fsm_name, string state_name);
    if (observed_fsms[fsm_name].sample_state(state_name, step_number)) begin
        step_number++;
        return 1;
    end
    return 0;
endfunction


function void censor_scenario::add_event_to_pattern(string fsm_name, string event_name);
    pattern_fsms[fsm_name].sample_event(event_name);
endfunction


function bit censor_scenario::sample_event(string fsm_name, string event_name);
    observed_fsms[fsm_name].sample_event(event_name);
endfunction

/**********************************/
/**** todo add printing methods****/
/**********************************/

function bit censor_scenario::compare();
    foreach(observed_fsms[name]) begin
        censor_fsm exp = pattern_fsms[name];
        censor_fsm act = observed_fsms[name];
        if (exp.states.size() != act.states.size())
            return 0;
        foreach(act.states[i]) begin
            if (!act.states[i].compare(exp.states[i]))
                return 0;
        end
    end
    foreach (pattern_fsms[name]) begin
        foreach (pattern_fsms[name].states[i]) begin
            if (!check_state_intersections(name, pattern_fsms[name].states[i]))
                return 0;
        end
    end
    foreach(pattern_fsms[name]) begin
        if (!(pattern_fsms[name].events_per_state == observed_fsms[name].events_per_state))
            return 0;
    end
    return 1;
endfunction


function bit censor_scenario::check_state_intersections(string fsm_name, censor_state pattern_state);
    censor_state observed_state = observed_fsms[fsm_name].states[pattern_state.number];
    foreach (pattern_state.intersection_per_fsm[fsm_name]) begin
        int cross_indices[$] = pattern_state.intersection_per_fsm[fsm_name];
        foreach (cross_indices[i]) begin
            censor_state to_cross = observed_fsms[fsm_name].states[cross_indices[i]];
            if (!observed_state.does_intersect(to_cross))
                return 0;
        end
    end
    return 1;
endfunction


function void censor_scenario::finalize();
    foreach(pattern_fsms[name])
        observed_fsms[name] = pattern_fsms[name].get_observation_copy();
endfunction