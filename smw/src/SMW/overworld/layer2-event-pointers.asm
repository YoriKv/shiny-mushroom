; The Layer 2 event divider table: one 16-bit entry index per event, slicing
; SMW_Layer2EventData_TileEntries. Event n covers entries [Ptrs[n], Ptrs[n+1]),
; so an event's start is the previous event's end and equal neighbours are an
; event with no Layer 2 work at all.
;
; Every row is derived from the entry table's own sublabels, so this file
; carries no data of its own and never needs editing: growing an event's rows
; moves the labels and the dividers follow. It sits beside the entry fragment
; rather than inside it so that the two can be placed apart -- what gives the
; entries room to grow past the 371 rows the shipped cartridge has space for.
;
; LM: This table may be moved to freespace if Lunar Magic's overworld event
; expansion hijack is applied, in which case a 24-bit pointer to the data
; can be found at $04E471.
Ptrs:			; Crash: Event 78 will use a garbage value for the final tile index.
	dw TileEntries_Event00/$04,TileEntries_Event01/$04,TileEntries_Event02/$04,TileEntries_Event03/$04
	dw TileEntries_Event04/$04,TileEntries_Event05/$04,TileEntries_Event06/$04,TileEntries_Event07/$04
	dw TileEntries_Event08/$04,TileEntries_Event09/$04,TileEntries_Event0A/$04,TileEntries_Event0B/$04
	dw TileEntries_Event0C/$04,TileEntries_Event0D/$04,TileEntries_Event0E/$04,TileEntries_Event0F/$04
	dw TileEntries_Event10/$04,TileEntries_Event11/$04,TileEntries_Event12/$04,TileEntries_Event13/$04
	dw TileEntries_Event14/$04,TileEntries_Event15/$04,TileEntries_Event16/$04,TileEntries_Event17/$04
	dw TileEntries_Event18/$04,TileEntries_Event19/$04,TileEntries_Event1A/$04,TileEntries_Event1B/$04
	dw TileEntries_Event1C/$04,TileEntries_Event1D/$04,TileEntries_Event1E/$04,TileEntries_Event1F/$04
	dw TileEntries_Event20/$04,TileEntries_Event21/$04,TileEntries_Event22/$04,TileEntries_Event23/$04
	dw TileEntries_Event24/$04,TileEntries_Event25/$04,TileEntries_Event26/$04,TileEntries_Event27/$04
	dw TileEntries_Event28/$04,TileEntries_Event29/$04,TileEntries_Event2A/$04,TileEntries_Event2B/$04
	dw TileEntries_Event2C/$04,TileEntries_Event2D/$04,TileEntries_Event2E/$04,TileEntries_Event2F/$04
	dw TileEntries_Event30/$04,TileEntries_Event31/$04,TileEntries_Event32/$04,TileEntries_Event33/$04
	dw TileEntries_Event34/$04,TileEntries_Event35/$04,TileEntries_Event36/$04,TileEntries_Event37/$04
	dw TileEntries_Event38/$04,TileEntries_Event39/$04,TileEntries_Event3A/$04,TileEntries_Event3B/$04
	dw TileEntries_Event3C/$04,TileEntries_Event3D/$04,TileEntries_Event3E/$04,TileEntries_Event3F/$04
	dw TileEntries_Event40/$04,TileEntries_Event41/$04,TileEntries_Event42/$04,TileEntries_Event43/$04
	dw TileEntries_Event44/$04,TileEntries_Event45/$04,TileEntries_Event46/$04,TileEntries_Event47/$04
	dw TileEntries_Event48/$04,TileEntries_Event49/$04,TileEntries_Event4A/$04,TileEntries_Event4B/$04
	dw TileEntries_Event4C/$04,TileEntries_Event4D/$04,TileEntries_Event4E/$04,TileEntries_Event4F/$04
	dw TileEntries_Event50/$04,TileEntries_Event51/$04,TileEntries_Event52/$04,TileEntries_Event53/$04
	dw TileEntries_Event54/$04,TileEntries_Event55/$04,TileEntries_Event56/$04,TileEntries_Event57/$04
	dw TileEntries_Event58/$04,TileEntries_Event59/$04,TileEntries_Event5A/$04,TileEntries_Event5B/$04
	dw TileEntries_Event5C/$04,TileEntries_Event5D/$04,TileEntries_Event5E/$04,TileEntries_Event5F/$04
	dw TileEntries_Event60/$04,TileEntries_Event61/$04,TileEntries_Event62/$04,TileEntries_Event63/$04
	dw TileEntries_Event64/$04,TileEntries_Event65/$04,TileEntries_Event66/$04,TileEntries_Event67/$04
	dw TileEntries_Event68/$04,TileEntries_Event69/$04,TileEntries_Event6A/$04,TileEntries_Event6B/$04
	dw TileEntries_Event6C/$04,TileEntries_Event6D/$04,TileEntries_Event6E/$04,TileEntries_Event6F/$04
	dw TileEntries_Event70/$04,TileEntries_Event71/$04,TileEntries_Event72/$04,TileEntries_Event73/$04
	dw TileEntries_Event74/$04,TileEntries_Event75/$04,TileEntries_Event76/$04,TileEntries_Event77/$04
	dw TileEntries_Event78/$04
