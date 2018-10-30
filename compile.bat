@del nesteroids.o
@del nesteroids.nes
@del nesteroids.map.txt
@del nesteroids.labels.txt
@del nesteroids.nes.ram.nl
@del nesteroids.nes.0.nl
@del nesteroids.nes.1.nl
@echo.
@echo Compiling...
cc65\bin\ca65 .\src\nesteroids.asm -g -o nesteroids.o
@IF ERRORLEVEL 1 GOTO failure
@echo.
@echo Linking...
cc65\bin\ld65 -o nesteroids.nes -C nesteroids.cfg nesteroids.o -m nesteroids.map.txt -Ln nesteroids.labels.txt --dbgfile nesteroids.nes.dbg
@IF ERRORLEVEL 1 GOTO failure
@echo.
@echo Success!
@time /t
@pause
@GOTO endbuild
:failure
@echo.
@echo Build error!
@pause
:endbuild
