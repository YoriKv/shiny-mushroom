;===============================================================================
; SA-1 Pack, as a pass of the build
;===============================================================================
; Applies SA-1 Pack over the assembled cartridge when the build sets
; !Define_SMW_SA1Pack. The `sa1` base sets that define on every pass of its
; assemble as well, so any source file that needs to know which base it is in
; can test the same name this file does.
;
; A pass of its own, and it can never fold into the main pass: the pack's
; clean-ROM guards read1() the image as it was before their own pass began,
; so inside FileType 1 they would read pass 0's empty image and every guard
; would fail open -- a partially applied pack assembles cleanly and produces
; a broken ROM. Run over the finished cartridge they read exactly what they
; read when the pack was applied post-build, which is what keeps the pinned
; hash at the same bytes.
;
; The pack's tree is deliberately not named here: `incsrc "asm/sa1.asm"`
; resolves through the include path the build passes -- the vendored tree at
; smw/vendor/sa1-pack, or wherever $SA1_PACK_PATH points -- so an upstream
; checkout under test and a staged copy both work without editing this file.

; The build's feature defines reach this pass on the same command line as the
; pack's own, and the pack's tree tests them where a feature and the pack
; claim the same bytes: the map16 remap leaves the translevel-remap hook's
; operand alone, since the hook's own lookup already reads the moved table.
; The guard is in the vendored tree, beside the patch it gates, and is inert
; on a stock build -- see smw/vendor/sa1-pack-pin.json. The overworld boost
; needs no guard: its one seam into code the relocation moves is honoured
; from the source side, an RTL pinned at $048575 in Banks/Bank04.asm.
if defined("Define_SMW_SA1Pack")
	incsrc "asm/sa1.asm"
endif
