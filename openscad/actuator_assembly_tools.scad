use <./libs/microscope_parameters.scad>
use <./libs/utilities.scad>
use <./libs/lib_actuator_assembly_tools.scad>


module tools_for_printing(){
    params = default_params();

    translate_x(12){
        band_tool(params, bent=false);
    }

    band_tool_holder(params);

    translate_y(40){
        nut_tool();
    }
}

tools_for_printing();
