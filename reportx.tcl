package require struct::matrix
package require report

namespace eval ::reportx {
	namespace export format

	proc format {template {subst_data ""} {styles_def ""}} {}

	proc _print_matrix {mx {stylename {}} args} {}
	proc _format_report {report_def} {}
}

proc ::reportx::_print_matrix {mx {stylename {}} args} {
	set options ""
	if {$stylename != ""} {
		lappend options style $stylename
	}
	
	::report::report r [$mx columns] {*}$options
	foreach {colno colsize colalign} $args {
		r size $colno $colsize
		r justify $colno $colalign
	}

	set result [r printmatrix $mx]
	r destroy
	return $result
}

proc ::reportx::_format_report {report_def} {

	set reportmx [struct::matrix]
	set rownums [lsort -integer [dict keys [dict get $report_def -report -rows]]]

	$reportmx add rows [llength $rownums]
	$reportmx add columns 1

	set formattedrows ""
	foreach rownum $rownums {
		set row_def [dict create {*}[dict get $report_def -report -rows $rownum]]
		set rowmx [struct::matrix]
		
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
				lappend formattedcols [_print_matrix $colmx]
			}
		}

		$rowmx set row 0 $formattedcols
		if {[dict exists $row_def -style]} {
			lappend formattedrows [_print_matrix $rowmx [dict get $row_def -style]]
		} else {
			lappend formattedrows [_print_matrix $rowmx]
		}
		
		$rowmx destroy
	}

	$reportmx set column 0 $formattedrows

	if {[dict exists $report_def -report -style]} {
		set formattedreport [_print_matrix $reportmx [dict get $report_def -report -style]]
	} else {
		set formattedreport [_print_matrix $reportmx]
	}

	$reportmx destroy

	return $formattedreport
}

proc ::reportx::format {template {subst_data ""} {styles_def ""}} {
	dict with subst_data {}
	set report_def [subst -nobackslashes -nocommands $template]

	foreach {stylename styleargs stylescript} $styles_def {
		::report::defstyle $stylename $styleargs $stylescript
	}
	
	return [_format_report $report_def]
}
