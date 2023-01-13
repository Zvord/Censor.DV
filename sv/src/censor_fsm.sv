class censor_fsm;

    typedef string string_q[$];

    string name;
    string_q events_per_state[$];
    string state_synonyms[string];
    bit valid_states[string];
    int depth;
    censor_state states[$];

    extern function new(string name_);
    extern function void add_valid_state(string state);
    extern function void add_state_to_pattern(string state_name);
    extern function bit sample_state(string state_name, int step_number);
    extern function void sample_event(string event_name);
    extern function bit is_valid_state(string state_name);
    extern function censor_fsm get_observation_copy();

endclass

function censor_fsm::new(string name_);
    name = name_;
endfunction

function void censor_fsm::add_valid_state(string state);
    valid_states[state] = 1;
endfunction


function bit censor_fsm::sample_state(string state_name, int step_number);
    censor_state state;
    censor_state last_state = states.size() > 0 ? states[$] : null;
    if (state_synonyms.exists(state_name))
        state_name = state_synonyms[state_name];
    if (!is_valid_state(state_name))
        `uvm_fatal(name, $sformatf("Attempting to sample state %s of FSM %s. This state is not expected", state_name, name))
    if ((last_state != null) && (states[$].name == state_name)) // todo add an option to be state repeting valid
        return 0;
    state = new(state_name);
    state.start = step_number;
    if (last_state != null)
        last_state.stop = step_number;
    states.push_back(state);
    events_per_state.push_back('{});
    if (states.size() > depth) begin
        void'(states.pop_front());
        void'(events_per_state.pop_front);
    end
    return 1;
endfunction

function void censor_fsm::sample_event(string event_name);
    events_per_state[$].push_back(name);
endfunction

function void censor_fsm::add_state_to_pattern(string state_name);
    censor_state state;
    if (1 == state_synonyms.exists(state_name))
        state_name = state_synonyms[state_name];
    state = new(state_name);
    begin
        if (states.size() == 0)
            state.start = 0;
        else
            state.start = states[$].stop;
    end
    states.push_back(state);
    events_per_state.push_back('{});
    state.number = depth;
    depth++;
endfunction

function bit censor_fsm::is_valid_state(string state_name);
    return valid_states[state_name];
endfunction

function censor_fsm censor_fsm::get_observation_copy();
    censor_fsm c = new(name);
    c.valid_states      = this.valid_states;
    c.state_synonyms    = this.state_synonyms;
    c.depth             = this.depth;
    return c;
endfunction

    /**********************************/
    /**** todo add printing methods****/
    /**********************************/