@echo off
setlocal ENABLEDELAYEDEXPANSION

set TYPE=%1
echo === Wwise_Unpacker v1.3 ===
echo.
echo == Unpacking to '%TYPE%'
echo.

goto:start

rem ================= Methods
:UNPACK_WAV
  rd /s /q dest_raw
  rd /s /q dest_wav
  mkdir dest_raw > nul 2>&1
  mkdir dest_wav > nul 2>&1
  
  echo ---- Running 'quickbms': Extract raw files
  for %%a in ("Game_Files\*.pck") do (
    mkdir dest_raw\%%~na > nul 2>&1
    Tools\quickbms.exe -q -k Tools\wwise_pck_extractor.bms "%%a" "dest_raw\%%~na"
    set/a fileNum = 0
    for %%d in ("dest_raw\%%~na\*.wem") do (
      ren "%%d" "%%~na_!fileNum!.wem"
      set/a fileNum += 1
    )
  )
  echo.
  
  echo ---- Running 'bnkextr'
  for %%b in ("Game_Files\*.bnk") do (
    Tools\bnkextr.exe "%%b" > nul
    ren *.wav *.wem
    move *.wem "dest_raw"
  )
  echo.
  
  echo ---- Running 'vgmstream-cli': Convert to wav
  for /r "dest_raw" %%c in ("*.wem") do (Tools\vgmstream-cli.exe -o "dest_wav\%%~nc.wav" "%%c" > nul)
  echo.
goto:eof


:UNPACK_MP3
  if not exist dest_wav (
    call :UNPACK_WAV
  )
  
  rd /s /q dest_mp3
  mkdir dest_mp3 > nul 2>&1
  
  echo ---- Running 'ffmpeg': Convert to mp3
  for /r "dest_wav" %%a in ("*.wav") do (
    echo Converting %%~nxa
    Tools\ffmpeg.exe -loglevel error -y -i "%%a" -acodec libmp3lame -q:a 0 -y "dest_mp3\%%~na.mp3"
  )
  echo.
goto:eof


rem ================= Main
:start
if "%TYPE%"=="wav" (
  call :UNPACK_WAV
)
if "%TYPE%"=="mp3" (
  call :UNPACK_MP3
)


rem ================= Footer
echo -------------------------------------------------------------
echo == Unpack finished! Files should be in the 'dest_%TYPE%' folder
echo -------------------------------------------------------------

pause
