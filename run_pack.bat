:: Windows平台 打包
chcp 65001

set current_dir=%~dp0

set mode=%1
if not defined mode (
	set mode=release
)

luamake -mode %mode%
luamake -mode release tools
"./bin/msvc/%mode%/ant_demo.exe" -p

set src_dir=%current_dir%bin\msvc\%mode%\
set dest_dir=%current_dir%publish\

copy %src_dir%ant_demo.exe %dest_dir%
copy %src_dir%fmod.dll %dest_dir%
copy %src_dir%fmodstudio.dll %dest_dir%

rd /s /q %dest_dir%internal
xcopy %src_dir%internal %dest_dir%internal\ /E /Y