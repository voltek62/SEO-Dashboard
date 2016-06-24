@echo off
rem ---------- tools
SET CURL=tools\curl\bin\curl.exe
SET NSIS=tools\nsis\makensis.exe
SET NSSM=tools\nssm\win64\nssm.exe
SET ZIP=tools\7zip\7za.exe

rem ---------- components versions
SET KIBANA_VERSION=4.5.1
SET FILEBEAT_VERSION=1.2.3

rem ---------- installer version
SET INSTALLER_VERSION=1.0.0
IF DEFINED APPVEYOR_BUILD_VERSION SET INSTALLER_VERSION=%APPVEYOR_BUILD_VERSION%
echo "Building installer v%INSTALLER_VERSION%"

rem ---------- Download packages ----------
if not exist "downloads" mkdir downloads

if not exist "downloads\kibana-%KIBANA_VERSION%.zip" %CURL% "https://download.elastic.co/kibana/kibana/kibana-%KIBANA_VERSION%-windows.zip" -o downloads\kibana-%KIBANA_VERSION%.zip
if not exist "downloads\filebeat-%KIBANA_VERSION%.zip" %CURL% "https://download.elastic.co/beats/filebeat/filebeat-%FILEBEAT_VERSION%-windows.zip" -o downloads\filebeat-%FILEBEAT_VERSION%.zip

rem --------------------------------------

rem ---------- Unzip packages ----------
rmdir /Q /S temp
rmdir /Q /S dist
mkdir temp
mkdir dist

%ZIP% x -otemp downloads\kibana-%KIBANA_VERSION%.zip
%ZIP% x -otemp downloads\filebeat-%FILEBEAT_VERSION%.zip

move temp\kibana-%KIBANA_VERSION%-windows dist\kibana
move temp\filebeat-%FILEBEAT_VERSION%-windows dist\filebeat

copy /Y tools\kibana-example.yml dist\kibana\config\kibana.yml
copy /Y tools\filebeat-example.yml dist\filebeat\filebeat.yml

rem ------------------------------------

rem ---------- Run makensis ----------
rem if not exist "nsis" mkdir nsis
rem %NSIS% /Dversion="%INSTALLER_VERSION%" elk.nsi
