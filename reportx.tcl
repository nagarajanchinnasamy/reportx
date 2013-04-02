# reportx.tcl --
#
#	Implementation of matrix report formatting wrapper around report package.
#
# Copyright (c) 2013 by Nagarajan Chinnasamy <nagarajanchinnasamy@gmail.com>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 

package require Tcl 8.2
package require struct::matrix 2.0.1
package require report 0.3.1

package provide reportx 0.2.1

namespace eval ::reportx {
	namespace export format

	proc format {template {subst_data ""} {styles_def ""}} {}

	proc _print_matrix {mx {stylename {}} args} {}
	proc _format_report {report_def} {}
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
#	formattedreport	Formatted report as a string
#

proc ::reportx::format {template {subst_data ""} {styles_def ""}} {
	dict with subst_data {}
	set report_def [subst -nobackslashes -nocommands $template]

	foreach {stylename styleargs stylescript} $styles_def {
		::report::defstyle $stylename $styleargs $stylescript
	}
	
	return [_format_report $report_def]
}

# ::reportx::_format_report	 --
#
#
#	Prepare formatted report according to the structure defined by
#	report_def. Calls itself recursively if a cell contains nested
#	-report definition.
#
# Arguments:
#	report_def	a variable substituted template definition
#
# Results:
#	formattedreport	Formatted report of a -report definition
#

proc ::reportx::_format_report {report_def} {

	set reportmx [struct::matrix]
	set reportstyle ""
	if {[dict exists $report_def -report -style]} {
		set reportstyle [dict get $report_def -report -style]
		dict unset report_def -report -style
	}

	set rowsstyle ""
	if {[dict exists $report_def -report -rows -style]} {
		set rowsstyle [dict get $report_def -report -rows -style]
		dict unset report_def -report -rows -style
	}
	
	set rownums [lsort -integer [dict keys [dict get $report_def -report -rows]]]

	$reportmx add rows [llength $rownums]
	$reportmx add columns 1

	set formattedrows ""
	foreach rownum $rownums {
		set row_def [dict create {*}[dict get $report_def -report -rows $rownum]]
		set rowmx [struct::matrix]

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
			set col_def [dict create {*}[dict get $row_def -columns $colnum]]
			set colmx [struct::matrix]

			if {[dict exists $col_def -report]} {
				$colmx add rows 1
				$colmx add columns 1
				$colmx set column 0 [list [_format_report $col_def]]
			} elseif {[dict exists $col_def -data]} {
				set data [dict get $col_def -data]
				
				foreach datarow $data {
					set datacols [llength $datarow]
					set colmxcols [$colmx columns]
					if {$datacols > $colmxcols} {
						$colmx add columns [expr $datacols - $colmxcols]
					}
					$colmx add row $datarow
				}
			}
			if {[dict exists $col_def -style]} {
				lappend formattedcols [_print_matrix $colmx [dict get $col_def -style]]
			} else {
				lappend formattedcols [_print_matrix $colmx {*}$columnsstyle]
			}
puts stderr "row: $rownum  col: $colnum"
puts stderr "formattedcols: $formattedcols"
			$colmx destroy
		}

		$rowmx set row 0 $formattedcols
		if {[dict exists $row_def -style]} {
			lappend formattedrows [_print_matrix $rowmx [dict get $row_def -style]]
		} else {
			lappend formattedrows [_print_matrix $rowmx {*}$rowsstyle]
		}

puts stderr "row: $rownum"
puts stderr "formattedrows: $formattedrows"
		
		$rowmx destroy
	}

	$reportmx set column 0 $formattedrows

	set formattedreport [_print_matrix $reportmx {*}$reportstyle]
	$reportmx destroy

	return $formattedreport
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

