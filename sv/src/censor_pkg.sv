`ifndef CENSOR_PKG__SV
`define CENSOR_PKG__SV

package censor_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "censor_state.sv"
    `include "censor_fsm.sv"
    `include "censor_scenario.sv"
    `include "censor_base.sv"

    class censor_pool;
        static protected censor_base pool[string];

        static function censor_base get(string scope);
            return pool[scope];
        endfunction

        static function void set(string scope, censor_base censor);
            if (pool[scope] == null)
                pool[scope] = censor;
            else
                `uvm_warning("CENSOR", $sformatf("The scope %s already has a set scenario.", scope))
        endfunction
    endclass

endpackage : censor_pkg

`endif