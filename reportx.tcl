# reportx.tcl --
#
#	Implementation of matrix report formatting wrapper around report package.
#
# Copyright (c) 2013 by Nagarajan Chinnasamy <nagarajanchinnasamy@gmail.com>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 

package require Tcl 8.5
package require struct::matrix 2.0.1
package require report 0.3.1

package provide reportx 0.2.3

namespace eval ::reportx {
	namespace export format

	proc format {template args} {}

	proc _format_table {table_def} {}
	proc _format_report {template formattedtable} {}
	proc _subst_table {table_def subst_data} {}
	proc _print_matrix {mx {stylename {}} args} {}
}

# ::reportx::format	 --
#
#
#	Format a report according to the structure defined by
#	template. When supplied, applies variable substitution
#	and style definitions.
#
# Arguments:
#	template	template that defines the report structure
#	subst_data	Optional name-value list to be subst-ed on the template
#	styles_def	Optional list of style definitions
#
# Results:
#	formattedtable	Formatted report as a string
#

proc ::reportx::format {template args} {

	set subst_data [list]
	set styles_def [list]

	foreach {opt val} $args {
		switch -- $opt {
			-subst {
				set subst_data $val
			}
			-styles {
				set styles_def $val
			}
			default {
				return -code error "Unknown option: $opt"
			}
		}
	}

	set table_def [list -table [dict get $template -table]]
	set table_def [_subst_table $table_def $subst_data]

	foreach {stylename styleargs stylescript} $styles_def {
		::report::defstyle $stylename $styleargs $stylescript
	}
	
	return [_format_report $template [_format_table $table_def]]
}

# ::reportx::_subst_table	 --
#
#
#	Substitute variables in table definition as per name value list
#
# Arguments:
#	table_def	table definition
#	subst_data	name-value list to be subst-ed on the table_def
#
# Results:
#	substed_def	a variable-substituted table definition
#
proc ::reportx::_subst_table {table_def subst_data} {
	dict with subst_data {}
	return [subst -nobackslashes -nocommands $table_def]
}

# ::reportx::_format_table	 --
#
#
#	Prepare formatted table according to the structure defined by
#	table_def. Calls itself recursively if a cell contains nested
#	-table definition.
#
# Arguments:
#	table_def	a variable-substituted table definition
#
# Results:
#	formattedtable	Formatted report of a -table definition
#

proc ::reportx::_format_table {table_def} {

	set tablemx [struct::matrix]
	set tablestyle ""
	if {[dict exists $table_def -table -style]} {
		set tablestyle [dict get $table_def -table -style]
		dict unset table_def -table -style
	}

	set rowsstyle ""
	if {[dict exists $table_def -table -rows -style]} {
		set rowsstyle [dict get $table_def -table -rows -style]
		dict unset table_def -table -rows -style
	}
	
	set rownums [lsort -integer [dict keys [dict get $table_def -table -rows]]]

	$tablemx add rows [llength $rownums]
	$tablemx add columns 1

	set formattedrows ""
	foreach rownum $rownums {
		set row_def [dict create {*}[dict get $table_def -table -rows $rownum]]
		set rowmx [struct::matrix]

		set rowstyle $rowsstyle
		if {[dict exists $row_def -style]} {
			set rowstyle [dict get $row_def -style]
			dict unset row_def -style
		}

		set columnsstyle ""
		if {[dict exists $row_def -columns -style]} {
			set columnsstyle [dict get $row_def -columns -style]
			dict unset row_def -columns -style
		}
		set colnums [lsort -integer [dict keys [dict get $row_def -columns]]]

		$rowmx add rows 1
		$rowmx add columns [llength $colnums]

		set formattedcols ""
		foreach colnum $colnums  {
			set colmx [struct::matrix]
			$colmx add rows 1
			$colmx add columns 1
			set col_def [dict create {*}[dict get $row_def -columns $colnum]]

			set columnstyle $columnsstyle
			if {[dict exists $col_def -style]} {
				set columnstyle [dict get $col_def -style]
				dict unset col_def -style
			}

			set datamx [struct::matrix]
			if {[dict exists $col_def -table]} {
				$datamx add rows 1
				$datamx add columns 1
				$datamx set column 0 [list [_format_table $col_def]]
			} else {
				set datastyle ""
				if {[dict exists $col_def -datastyle]} {
					set datastyle [dict get $col_def -datastyle]
					dict unset col_def -datastyle
				}
				if {[dict exists $col_def -data]} {
					set data [dict get $col_def -data]
					foreach datarow $data {
						set datacols [llength $datarow]
						set datamxcols [$datamx columns]
						if {$datacols > $datamxcols} {
							$datamx add columns [expr $datacols - $datamxcols]
						}
						$datamx add row $datarow
					}
				}
			}
			$colmx set column 0 [list [_print_matrix $datamx {*}$datastyle]]
			$datamx destroy

			lappend formattedcols [_print_matrix $colmx {*}$columnstyle]
			$colmx destroy
		}

		$rowmx set row 0 $formattedcols
		lappend formattedrows [_print_matrix $rowmx {*}$rowstyle]		
		$rowmx destroy
	}

	$tablemx set column 0 $formattedrows
	set formattedtable [_print_matrix $tablemx {*}$tablestyle]
	$tablemx destroy

	return $formattedtable
}

# ::reportx::_format_report	 --
#
#
#	Prepare final formatted report from formatted table as per the
#	directives in template
#
# Arguments:
#	template	template definition
#	formattedtable
#	            formatted table - output of _format_table
#
# Results:
#	formattedreport	Formatted report
#
proc ::reportx::_format_report {template formattedtable} {
	return $formattedtable
}

# ::reportx::_print_matrix	 --
#
#	Format the contents of a matrix using report::printmatrix and return
#	the formatted matrix
#
# Arguments:
#	mx		matrix with content to be formatted
#	style	Optional style definition
#
# Results:
#	formattedmx	Formatted matrix as a string
#

proc ::reportx::_print_matrix {mx {style {}}} {
	set options ""
	if {$style != ""} {
		lappend options style $style
	}
	
	::report::report r [$mx columns] {*}$options

	set formattedmx [string trim [r printmatrix $mx] "\r\n"]
	r destroy

	return $formattedmx
}

