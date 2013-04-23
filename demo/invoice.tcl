# invoice.tcl --
#
#	Invoice printing demo of reportx package
#
# Copyright (c) 2013 by Nagarajan Chinnasamy <nagarajanchinnasamy@gmail.com>
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 


package require reportx 0.2.3

set template {
	-table { -style invoice
		-rows {
			1 {
				-columns {
					1 { -datastyle invoiceHeader
						-data {
							{ "${-company_name}" }
							{ "${-company_street1}, ${-company_street2}, ${-company_city}-${-company_pin}" }
							{ "TIN: ${-company_tin}, Phone: ${-company_phone1} EMail: ${-company_email1}" }
						}
					}
				}
			}
			2 { -style addressInvoiceInfo
				-columns {
					1 { -datastyle partyAddress
						-data {
							{ "B I L L E D    T O:" }
							{ "${-buyer_title}. ${-buyer_name}" }
							{ "${-buyer_street1}, ${-buyer_street2}, ${-buyer_city}-${-buyer_pin}" }
							{ "${-buyer_state}" }
							{ "Ph: ${-buyer_phone1}" }
							{ "" }
							{ "TIN: ${-buyer_tin}" }
						}
					}
					2 { -datastyle invoiceInfo
						-data {
							{ "I N V O I C E" ""}
							{ "Invoice No." "${-invoice_no}" }
							{ "Invoice Date" "${-invoice_date}" }
						}
					}
				}
			}
			3 {
				-columns {
					1 { -datastyle transportInfo
						-data {
							{ From ${-transport_fromcity} To ${-transport_tocity} "Bale No." "${-transport_baleno}" }
							{ Transport "${-transport_service}, ${-transport_lrno}" "LR Date" "${-transport_lrdate}" Weight "${-transport_weight}" }
						}
					}
				}
			}
			4 {
				-columns {
					1 { -datastyle particularsTable
						-data {
							{ "S.No." "Particulars" "Qty/Mts" "Price" "Amount" }
							${-delivery_items}
							{ "" "E. & O.E.                                   TOTAL" "" "" "${-delivery_totalamt}" }
						}
					}
				}
			}
			5 {
				-columns {
					1 { -datastyle rupeesInWords
						-data {
							{ "RUPEES ${-delivery_rupeesinwords} Only" }
						}
					}
				}
			}
			6 { -style notesAndFor
				-columns {
					1 { -datastyle notesAndConditions
						-data {
							{ "N O T E S:" }
							{ "    * Interest 24% will be charged from the date of issue" }
							{ "    * Payment should be made by Draft only" }
							{ "    * We are not responsible for any loss or damage in transit" }
							{ "    * All disputes are Subject to MyCity Jurisdiction only" }
						}
					}
					2 {
						-datastyle forSignature
						-data {
							{ "For ${-company_name}" }
							{ "" }
							{ "" }
							{ "" }
							{ "Authorised Signatory" }
						}
					}
				}
			}
		}
	}
}

set styles_def {
	invoice {} {
		# Top and bottom lines
		top       set "[string repeat "+ = " [columns]]+"
		bottom    set [top get]
		
		# Data lines
		data      set "[string repeat "| "   [columns]]|"
		datasep   set "[string repeat "+ = " [columns]]+"
		
		top       enable
		bottom    enable
		datasep   enable

		size 0 112
		justify 0 right
	}

	invoiceHeader {} {
		# Data lines
		data      set "[string repeat "\" \" "   [columns]]\" \""
		
		size 0 110
		justify 0 center
	}

	partyAddress {} {	
		# Data lines
		data      set "[string repeat "\" \" "   [columns]]\" \""

		# Top caption
		topdata   set "[string repeat "\" \" " [columns]]\" \""
		topcapsep set "[string repeat "- - " [columns]]-"
		tcaption  1

		topcapsep enable

		size 0 65
		justify 0 left
	}

	invoiceInfo {} {	
		# Data lines
		data      set "\" \" [string repeat ": "   [expr [columns] - 1]]\" \""

		# Top caption
		topdata   set "[string repeat "\" \" " [columns]]\" \""
		topcapsep set "[string repeat "- - " [columns]]-"
		tcaption  1

		topcapsep enable

		foreach {colno colsize colalign} {0 20 left 1 15 left} {
			size $colno $colsize
			justify $colno $colalign
		}
	}

	addressInvoiceInfo {} {
		
		# Data lines
		data      set "\" \" [string repeat "| "   [expr [columns] - 1]]\" \""

		foreach {colno colsize colalign} {0 69 left 1 40 left} {
			size $colno $colsize
			justify $colno $colalign
		}
	}

	transportInfo {} {
		data      set "\" \" [string repeat ": \" \" " [expr [columns]/2]]"
		datasep   set "[string repeat "\" \" \" \" " [columns]] \"\n\""
		datasep   enable

		foreach {colno colsize colalign} {0 10 left 1 40 left 2 10 left 3 25 left 4 10 left 5 10 left} {
			size $colno $colsize
			justify $colno $colalign
		}
	}

	particularsTable {} {
		
		# Data lines
		data      set "\" \" [string repeat "| "   [expr [columns] - 1]]\" \""
		datasep   set "- - [string repeat "+ - " [expr [columns]-1]]-"

		# Top caption
		topdata      set "\" \" [string repeat "| "   [expr [columns] - 1]]\" \""
		topcapsep   set "- - [string repeat "+ - " [expr [columns]-1]]-"
		tcaption  1

		datasep   enable
		topcapsep enable
		
		foreach {colno colsize colalign} {0 5 right 1 56 left 2 10 right 3 15 right 4 20 right} {
			size $colno $colsize
			justify $colno $colalign
		}
	}

	rupeesInWords {} {
		
		# Data lines
		data      set "\" \" [string repeat "| "   [expr [columns] - 1]]\" \""
		
		size 0 110
		justify 0 left
	}

	notesAndConditions {} {
		
		# Data lines
		data      set "[string repeat "\" \" "   [columns]]\" \""

		# Top caption
		topdata   set "[string repeat "\" \" " [columns]]\" \""
		topcapsep set "[string repeat "- - " [columns]]-"
		tcaption  1

		topcapsep enable

		size 0 65
		justify 0 left
	}

	forSignature {} {
		# Data lines
		data      set "[string repeat "\" \" "   [columns]]\" \""

		# Top caption
		topdata   set "[string repeat "\" \" " [columns]]\" \""
		topcapsep set "[string repeat "- - " [columns]]-"
		tcaption  1

		topcapsep enable

		size 0 40
		justify 0 center
	}

	notesAndFor {} {
		# Data lines
		data      set "\" \" [string repeat "| "   [expr [columns] - 1]]\" \""

		foreach {colno colsize colalign} {0 69 left 1 40 left} {
			size $colno $colsize
			justify $colno $colalign
		}
	}
}

puts [::reportx::format $template -subst {
		-company_name "Name Of My Company"
		-company_street1 "Address Line 1"
		-company_street2 "Address Line 2"
		-company_city "City"
		-company_pin "Pin/Zip"
		-company_tin "Taxation Identification"
		-company_phone1 "+999-9999999999"
		-company_email1 "youremail@domain.com"
		-buyer_title "M/S"
		-buyer_name "Name of Buyer's Company"
		-buyer_street1 "Address Line 1"
		-buyer_street2 "Address Line 2"
		-buyer_city "City"
		-buyer_pin "Pin/Zip"
		-buyer_state "State"
		-buyer_phone1 "+999-9999999999"
		-buyer_tin "Taxation Identification"
		-invoice_no "99999"
		-invoice_date "2013-03-15"
		-transport_fromcity "FromCity"
		-transport_tocity "ToCity"
		-transport_baleno "99/99"
		-transport_service "Name of Transport Service"
		-transport_lrno "Ref. No."
		-transport_lrdate "Ref. Dt."
		-transport_weight "99.00 Kg"
		-delivery_items {
			{1 "Product Name 1" 25.00 47.00 1175.00}
			{2 "Product Name 2" 25.00 47.00 1175.00}
			{3 "Product Name 3" 25.00 47.00 1175.00}
			{4 "Product Name 4" 25.00 47.00 1175.00}
		}
		-delivery_totalamt 4700.00
		-delivery_rupeesinwords "Four Thousand Seven Hundred Only"
	} -styles $styles_def]
