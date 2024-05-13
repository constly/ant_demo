@chcp 65001 >nul

set mode=%1
if not defined mode (
	set mode=debug
)

luamake -mode %mode% 
luamake -mode release tools