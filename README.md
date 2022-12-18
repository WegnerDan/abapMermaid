# abapMermaid
Integrate [Mermaid Diagrams](https://github.com/mermaid-js/mermaid) in SAP GUI Containers

Source Code of mermaid release 9.3.0 is included as SMW0 Object (downloaded from `https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js`)

## Disclaimer
This is a work in progress, there are bugs. The background color of the HTML container is determined with cl_gui_resources, but this might not work correctly if corrections described in [SAP Note 3002961](https://launchpad.support.sap.com/#/notes/3002961) are not applied in the System. 
The font color and type are on the todo list (doesn't work yet).

## Prerequisites
Mermaid does not work in the Internet Explorer Browser Control, so the Edge Chromium Control has to be used. More info in [SAP Note 2913405](https://launchpad.support.sap.com/#/notes/2913405)

![image](https://user-images.githubusercontent.com/6908247/162700774-2aedd4ac-526c-4b82-9dff-cb331ddf3cf4.png)


# Preview
```abap
DATA(diagram) = NEW zcl_wd_gui_mermaid_js_diagram( parent = some_instance_of_cl_gui_container ).
diagram->set_source_code_string(    |graph TD\n|
                                 && |A[Client] --> B[Load Balancer]\n|
                                 && |B --> C[Server01]\n|
                                 && |B --> D[Server02]\n| ).
diagram->display( ).
```
![image](https://user-images.githubusercontent.com/6908247/162644750-43fa7f39-2610-4da9-963f-3beec23d9143.png) ![image](https://user-images.githubusercontent.com/6908247/162644775-c2aba0bc-6144-4471-b69e-6e2e8add5187.png)

# Sample Programs
## Program `ZWD_MERMAID_SAMPLE_1`
Simplest possible example, basically the code that is mentioned in the preview section.

## Program `ZWD_MERMAID_SAMPLE_2`
Example in a classic screen, with a couple of different diagrams. 
![image](https://user-images.githubusercontent.com/6908247/162852204-b6f09007-6518-451c-a3eb-ca47917f6717.png)

## Program `ZWD_MERMAID_TEST`
Use this to test how a diagram looks in SAP GUI after designing with [Mermaid Live Editor](https://mermaid.live).
Includes basic error handling (parse errors are displayed in the bottom left corner) and configuration editable as JSON.

![image](https://user-images.githubusercontent.com/6908247/162852877-9c5b6dae-5d97-4164-b03e-1e31092d06a7.png)

## abapMermaidDocflow
[See Details](https://github.com/thedoginthewok/abapMermaidDocflow)
