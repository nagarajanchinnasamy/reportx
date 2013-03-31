reportx
=======

Tcl Framework To Generate Tabular Reports. Simplifies the usage of tcllib's report package in generating formatted tabular reports.

The reportx framework itself contains only one method/proc named ::reportx::format. The format method takes 3 arguments (onely one mandatory and 2 optional):

1. Tabular Format Template:
    - Defines the structure of the report starting outer most table to rows inside the table and the columns in each row.
    - Is a nested/recursive structure. Hence, you can define a cell to create sub-tables.
    - Can have Tcl variable names (e.g. $company_name) that will be substituted with values later.
    - Can also mention the name of the style definition to be applied to the outer most table, rows and columns.
2. Data Values:
    - Optional list of name-value pairs that will be used to substitute the variables in the template.
3. Style Definitions:
    - Optional list of style definitions of the style names used in the template

The signature of this method is:

    proc ::reportx::format {template {subst_data ""} {styles_def ""}}

::reportx::format method returns a string that contains the entire formatted report that can be sent to a printing framework.

For more details please visit: http://nagarajanchinnasamy.blogspot.in/2013/03/reportx-tcl-framework-to-generate.html
