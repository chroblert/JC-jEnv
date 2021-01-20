@echo off
chcp 65001
@REM AUTHOR: JC0o0l,Jerrybird
@REM description: java环境切换管理工具

if "%1" == "local" (
    echo [+] jenv local alias
    goto switch_local 
)

if "%1" == "global" (
    echo [+] jenv global alias
    goto switch_global 
)

if "%1" == "add" (
    echo [+] jenv add jdk_dir alias
    goto addjdk
)

:usage
    echo jenv [options]
    echo jenv version 显示当前所有的java版本
    echo jenv local 1.8 设置java版本，只在当前shell下起作用
    echo jenv global 1.8 设置java版本，在全局下都起作用
    echo jenv add 目录 alias 
    goto end

:aliaslist

    goto end
:switch_local
    call refreshenv
    set Java_env=%2
    @REM 多重变量嵌套
    call set TMP_JAVAHOME=%%%Java_env%%%
    set java_path=
    if NOT "%2" == "" (
        set java_path=%TMP_JAVAHOME%\bin
    ) 
    echo %java_path%
    @REM echo "%path%"|%SystemRoot%\system32\findstr "(" >nul
    @REM set notexist=%errorlevel%
    @REM echo %notexist%
    if "%java_path%" == "" (
        @REM 将(,)转义为^(,^)
        goto end
    )
    set "path=%java_path%;%path%"
    set java_path=
    set TMP_JAVAHOME=
    goto end

:switch_global
    call refreshenv
    set Java_env=%2
    @REM 多重变量嵌套
    call set TMP_JAVAHOME=%%%Java_env%%%
    set java_path=
    if "%2" == "" (
        goto end
    ) 
    set java_path=%TMP_JAVAHOME%\bin
    @REM echo "%path%"|%SystemRoot%\system32\findstr "(" >nul
    @REM set notexist=%errorlevel%
    @REM echo %notexist%
    if "%java_path%" == "" (
        goto end
    )
    REM 设置java_home环境变量
    reg delete HKCU\Environment /v JAVA_HOME /f
    reg add HKCU\Environment  /v JAVA_HOME /t REG_SZ /d %TMP_JAVAHOME%  /f
    setx JAVA_HOME %TMP_JAVAHOME%
    REM 更新本shell中path
    set "path=%java_path%;%path%"
    set "JAVA_HOME=%TMP_JAVAHOME%"
    @REM echo "%path%"
    set java_path=
    set TMP_JAVAHOME=
    goto end

:setpathusereg
    echo 使用注册表设置PATH环境变量
    echo %~1   %~2
    reg delete HKCU\Environment /v %~1 /f
    reg add HKCU\Environment  /v %~1 /t REG_SZ /d "%~2"  /f
    call refreshenv
    goto :EOF
    @REM reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v JAVA_HOME /t REG_SZ /d "%~1" /f


:addjdk
    rem echo [+] jenv add jdk_dir alias
    if "%2" == "" goto end
    if "%2" == "" goto end
    set JDK_ALIAS=%3
    set JDK_DIR=%2
    rem 添加至用户环境变量中
    %SystemRoot%\system32\setx %JDK_ALIAS% %JDK_DIR%
    rem 设置别名
    %SystemRoot%\system32\doskey %JDK_ALIAS%=%JDK_DIR%\bin\java.exe $*
    echo 已为%JDK_DIR%\bin\java.exe设置别名%JDK_ALIAS%
    rem 刷新环境变量
    call :refreshenv

:refreshenv
@echo off
::
:: RefreshEnv.cmd
::
:: Batch file to read environment variables from registry and
:: set session variables to these values.
::
:: With this batch file, there should be no need to reload command
:: environment every time you want environment changes to propagate

::echo "RefreshEnv.cmd only works from cmd.exe, please install the Chocolatey Profile to take advantage of refreshenv from PowerShell"
echo | set /p dummy="Refreshing environment variables from registry for cmd.exe. Please wait..."

goto main

:: Set one environment variable from registry key
:SetFromReg
    "%WinDir%\System32\Reg" QUERY "%~1" /v "%~2" > "%TEMP%\_envset.tmp" 2>NUL
    for /f "usebackq skip=2 tokens=2,*" %%A IN ("%TEMP%\_envset.tmp") do (
        echo/set "%~3=%%B"
    )
    goto :EOF

:: Get a list of environment variables from registry
:GetRegEnv
    "%WinDir%\System32\Reg" QUERY "%~1" > "%TEMP%\_envget.tmp"
    for /f "usebackq skip=2" %%A IN ("%TEMP%\_envget.tmp") do (
        if /I not "%%~A"=="Path" (
            call :SetFromReg "%~1" "%%~A" "%%~A"
        )
    )
    goto :EOF

:main
    echo/@echo off >"%TEMP%\_env.cmd"

    :: Slowly generating final file
    call :GetRegEnv "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" >> "%TEMP%\_env.cmd"
    call :GetRegEnv "HKCU\Environment">>"%TEMP%\_env.cmd" >> "%TEMP%\_env.cmd"

    :: Special handling for PATH - mix both User and System
    call :SetFromReg "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" Path Path_HKLM >> "%TEMP%\_env.cmd"
    call :SetFromReg "HKCU\Environment" Path Path_HKCU >> "%TEMP%\_env.cmd"

    :: Caution: do not insert space-chars before >> redirection sign
    echo/set "Path=%%Path_HKLM%%;%%Path_HKCU%%" >> "%TEMP%\_env.cmd"

    :: Cleanup
    del /f /q "%TEMP%\_envset.tmp" 2>nul
    del /f /q "%TEMP%\_envget.tmp" 2>nul

    :: capture user / architecture
    SET "OriginalUserName=%USERNAME%"
    SET "OriginalArchitecture=%PROCESSOR_ARCHITECTURE%"

    :: Set these variables
    call "%TEMP%\_env.cmd"

    :: Cleanup
    del /f /q "%TEMP%\_env.cmd" 2>nul

    :: reset user / architecture
    SET "USERNAME=%OriginalUserName%"
    SET "PROCESSOR_ARCHITECTURE=%OriginalArchitecture%"

    echo | set /p dummy="Finished."
    echo .


:end
    echo '设置完成'