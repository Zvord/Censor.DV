class censor_state;
    typedef int int_q[$];

    string name;
    int unsigned start;
    int unsigned stop = -1; // meaninfull only for observed states
    int unsigned number; // order number in scenario

    int_q intersection_per_fsm[string];

    extern function new (string state_name_);
    extern function bit does_intersect(censor_state other);
    extern function bit compare(censor_state other);
    extern function void add_intersection(string name, int n);


endclass

function censor_state::new (string state_name_);
    name = state_name_;
endfunction


function bit censor_state::compare(censor_state other);
    return name == other.name;
endfunction


function bit censor_state::does_intersect(censor_state other);
    if (other.start == start || other.stop == stop)
        return 1;
    else if (other.start > start)
        return other.start < stop;
    else
        return other.stop > start;
endfunction


function void censor_state::add_intersection(string name, int n);
    intersection_per_fsm[name].push_back(n);
endfunction