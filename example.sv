//=============================================================================
// Copyright (c) 2020 SK hynix memory solutions Eastern Europe, LLC. All rights reserved.
//
// This file is the Confidential and Proprietary product of
// SK hynix. Any unauthorized use, reproduction
// or transfer of this file is strictly prohibited
//------------------------------------------------------------------------------
// Version and Release Control Information:
//
// $File: $
//
// Description    : Auto-generated scenario coverage
// Author         : Ilya Barkov (ilya.barkov@sk.com)
// Created        : 
//
// $Revision: $
// $Author: $
// $Date: $
//
//==============================================================================


import uvm_pkg::*;
`include "uvm_macros.svh"
import censor_pkg::*;

class generated_class_name extends censor_base;
    `uvm_component_utils(generated_class_name)
     
    typedef enum {
        MY_ONLY_BIN
    } enum_type_to_cover;
     
    covergroup your_cvoergroup_name with function sample (enum_type_to_cover name);
        coverpoint name;
    endgroup
     
    function  new(string name = "generated_class_name", uvm_component parent = null);
        super.new(name, parent);
        your_cvoergroup_name = new();
    endfunction
     
    function void sample(int id);
        enum_type_to_cover e;
        if (!$cast(e, id)) begin
            `uvm_fatal(get_name(), $sformatf("Method sample got an id %0d that does not correspond to any enum values of enum_type_to_cover", id))
        end
        your_cvoergroup_name.sample(e);
    endfunction
     
    function void fill_scenarios();
        begin
            enum_type_to_cover e = MY_ONLY_BIN;
            censor_scenario s = new(e.name(), int'(e));
            void'(s.sample_state("fsm_1_tb_name", "State_A"));
            void'(s.sample_state("fsm_2_tb_name", "State_1"));
            void'(s.add_action("fsm_2_tb_name", "RST"));
            void'(s.sample_state("fsm_1_tb_name", "State_B"));
            void'(s.add_action("fsm_1_tb_name", "RST"));
            void'(s.sample_state("fsm_2_tb_name", "State_2"));
            s.add_intersection("fsm_1_tb_name", "fsm_2_tb_name");
            void'(s.sample_state("fsm_1_tb_name", "State_C"));
            void'(s.sample_state("fsm_2_tb_name", "State_1"));
            s. sample_event("fsm_1_tb_name", "RST");
            s. sample_event("fsm_2_tb_name", "RST");
            add_scenario(s);
        end
        add_accepted_state("fsm_1_tb_name", "State_A");
        add_accepted_state("fsm_1_tb_name", "State_B");
        add_accepted_state("fsm_1_tb_name", "State_C");
        add_accepted_state("fsm_2_tb_name", "State_1");
        add_accepted_state("fsm_2_tb_name", "State_2");
    endfunction
endclass