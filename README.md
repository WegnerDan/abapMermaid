# abapMermaid
Integrate [Mermaid Diagrams](https://github.com/mermaid-js/mermaid) in SAP GUI Containers

Source Code of mermaid release 9.0.0 is included as SMW0 Object (downloaded from `https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js`)

## Disclaimer
This is a work in progress, there are bugs. The background color of the HTML container is determined with cl_gui_resources, but this might not work correctly if corrections described in [SAP Note 3002961](https://launchpad.support.sap.com/#/notes/3002961) are not applied in the System. 
The font color and type are on the todo list (doesn't work yet).

## Preqrequesites
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
