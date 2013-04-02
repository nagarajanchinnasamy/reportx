# nested.tcl --
#
#	Nested tables demo of reportx package
#
# Copyright (c) 2013 by Nagarajan Chinnasamy <nagarajanchinnasamy@gmail.com>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#

package require reportx 0.2.1

set template {
	-report {
		-rows { -style row
			1 {
				-columns {
					1 {
						-data {
							{ "1st Row 1st Column. The column to the right has the second table in it." }
						}
					}
					2 {
						-report {
							-rows { -style row
								1 {
									-columns {
										1 {
											-data {
												{ "Nested Table. 1st Row 1st Column" }
											}
										}
									}
								}
								2 {
									-columns {
										1 {
											-data {
												{ "Nested Table. 2nd Row 1st Column" }
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

set styles_def {
	row {} {
		# Top and bottom lines
		top       set "[string repeat "+ = " [columns]]+"
		bottom    set [top get]
		
		# Data lines
		data      set "[string repeat "| "   [columns]]|"
		datasep   set "[string repeat "+ = " [columns]]+"
		
		top       enable
		bottom    enable
		datasep   enable
	}
}

puts [::reportx::format $template {} $styles_def]
