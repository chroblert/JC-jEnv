@echo off
chcp 65001
@REM AUTHOR: JC0o0l,Jerrybird
@REM description: java环境切换管理工具
@REM Repo: https://github.com/Chroblert/JC-jEnv.git

@REM set JC_jEnv=JC_jEnv

if "%1" == "local" (
    echo |set /p JCOut=" [+] jenv local alias"
    echo.
    goto switch_local 
)

if "%1" == "global" (
    echo | set /p JCOut=" [+] jenv global alias"
    echo.
    goto switch_global 
)

if "%1" == "add" (
    echo | set /p JCOut=" [+] jenv add jdk_dir alias"
    echo.
    goto addjdk
)
if "%1" == "del" (
    echo | set /p JCOut=" [+] jenv del alias"
    echo.
    goto deljdk
)

if "%1" == "version" (
    goto version
)

:usage
    @REM echo | set /p JCOut=" ================================================"
    echo ================================================
    @REM echo.
    echo | set /p JCOut=" | JC-jEnv"
    echo.
    echo | set /p JCOut=" | Despt:  windows Java环境管理工具"
    echo.
    echo | set /p JCOut=" | Author: JC0o0l,Jerrybird"
    echo.
    echo | set /p JCOut=" | Repo:   https://github.com/chroblert/JC-jEnv.git"
    echo.
    @REM echo | set /p JCOut=" ================================================"
    echo ================================================
    echo.
    echo | set /p JCOut=" 使用说明"
    echo.
    echo | set /p JCOut="  jenv [options]"
    echo.
    echo | set /p JCOut="       version "
    echo.
    echo | set /p JCOut="         - 显示当前所有的java版本"
    echo.
    echo | set /p JCOut="       local alias "
    echo.
    echo | set /p JCOut="         - 设置java版本，只在当前shell下起作用"
    echo.
    echo | set /p JCOut="       global alias "
    echo.
    echo | set /p JCOut="         - 设置java版本，在全局下都起作用"
    echo.
    echo | set /p JCOut="       add 目录 alias"
    echo.
    echo | set /p JCOut="         - add a version "
    echo.
    echo | set /p JCOut="       del alias     "
    echo.
    echo | set /p JCOut="         - delete a version"
    echo.
    goto end

:version
    if "%JC_jEnv%" == "" (
        echo | set /p JCOut=" 当前没有设置任何版本"
        echo.
        goto usage
    )
    @REM 枚举JC_jEnv环境变量中的值
    echo.
    echo | set /p JCOut=" all version:"
    echo.
    set remain=%JC_jEnv%
    setlocal enabledelayedexpansion
:loop
    for /f "delims=;, tokens=1*" %%i in ("%remain%") do (
        @REM echo | set /p JCOut=" %%i"
        @REM echo.
        set jenv_name=%%i
        set value=!%%i!
        if /i "!value!" equ "%JAVA_HOME%" (
            echo | set /p JCOut=" * !jenv_name! !value!"
            echo.
        ) else (
            echo | set /p JCOut="   !jenv_name! !value!"
            echo.
        )
        set remain=%%j
    )
    if defined remain goto :loop
    setlocal disabledelayedexpansion
    goto end
@REM 导出配置到文件
:export
    goto end

@REM 导入配置文件
:import
    goto end
:switch_local
    @REM call refreshenv
    set Java_env=%2
    @REM 多重变量嵌套
    call set TMP_JAVAHOME=%%%Java_env%%%
    set java_path=
    if NOT "%2" == "" (
        set java_path=%TMP_JAVAHOME%\bin
    ) 
    if "%java_path%" == "" (
        @REM 将(,)转义为^(,^)
        goto end
    )
    set "path=%java_path%;%path%"
    set "JAVA_HOME=%TMP_JAVAHOME%"
    echo | set /p JCOut="  已切换到%2 %java_path%"
    echo.
    @REM rem 设置别名
    %SystemRoot%\system32\doskey %2=%JAVA_HOME%\bin\java.exe $*   >null
    set java_path=
    set TMP_JAVAHOME=
    goto end

:switch_global
    @REM call refreshenv
    set Java_env=%2
    @REM 多重变量嵌套
    call set TMP_JAVAHOME=%%%Java_env%%%
    set java_path=
    if "%2" == "" (
        goto end
    ) 
    set java_path=%TMP_JAVAHOME%\bin
    if "%java_path%" == "" (
        goto end
    )
    REM 设置java_home环境变量
    reg delete HKCU\Environment /v JAVA_HOME /f >null
    echo | set /p JCOut="  .使用reg删除以前的JAVA_HOME %JAVA_HOME%"
    echo.
    reg add HKCU\Environment  /v JAVA_HOME /t REG_SZ /d %TMP_JAVAHOME%  /f >null
    echo | set /p JCOut="  .使用reg创建新的JAVA_HOME %TMP_JAVAHOME%"
    echo.
    setx JAVA_HOME %TMP_JAVAHOME% >null
    echo | set /p JCOut="  .使用setx更新JAVA_HOME"
    echo.
    @REM 更新本shell中path
    set "path=%java_path%;%path%"
    set "JAVA_HOME=%TMP_JAVAHOME%"
    @REM rem 设置别名
    %SystemRoot%\system32\doskey %2=%JAVA_HOME%\bin\java.exe $*   >null
    @REM echo | set /p JCOut=" "%path%""
    @REM echo.
    set java_path=
    set TMP_JAVAHOME=
    goto end

:setpathusereg
    echo | set /p JCOut=" 使用注册表设置PATH环境变量"
    echo.
    echo | set /p JCOut=" %~1   %~2"
    echo.
    reg delete HKCU\Environment /v %~1 /f
    reg add HKCU\Environment  /v %~1 /t REG_SZ /d "%~2"  /f
    call refreshenv
    goto :EOF
    @REM reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v JAVA_HOME /t REG_SZ /d "%~1" /f

:deljdk
    if NOT "%~2" == "" (
        @REM 删除某个版本的jdk
        reg delete HKCU\Environment /v %~2 /f >null
    )
    call set t_JC_jEnv=%%JC_jEnv:;%~2=%%
    call setx JC_jEnv %%t_JC_jEnv:%~2;=%%
    call set JC_jEnv=%%t_JC_jEnv:%~2;=%%
    set %~2=
    goto refreshenv
:addjdk
    rem echo | set /p JCOut=" [+] jenv add jdk_dir alias"
    rem echo.
    if [%2] == [] (
        echo | set /p JCOut=" 请设置JDK路径"
        echo.
        goto end
    )
    if [%3] == [] (
        echo | set /p JCOut=" 请设置JDK别名"
        echo.
        goto end
    )
    if %2 == "" (
        echo | set /p JCOut=" 请设置JDK路径"
        echo.
        goto end
    )
    if %3 == "" (
        echo | set /p JCOut=" 请设置JDK别名"
        echo.
        goto end
    )
    set JDK_ALIAS=%3
    set JDK_DIR=%2
    @REM 判断是否存在JDK_ALIAS别名
    call set t_temp=%%%JDK_ALIAS%%%
    if NOT "%t_temp%" == "" (
        echo | set /p JCOut=" %JDK_ALIAS%已经存在"
        echo.
        goto end
    )
    rem 添加至用户环境变量中
    %SystemRoot%\system32\setx %JDK_ALIAS% %JDK_DIR% >null
    @REM echo | set /p JCOut="/%SystemRoot%\system32\setx %JDK_ALIAS% %JDK_DIR% >>f:/JC_jEnv.cmd"
    @REM echo.
    echo | set /p JCOut="%JC_jEnv%"|%SystemRoot%\system32\findstr "%JDK_ALIAS%" >nul
    echo.
    set notexist=%errorlevel%
    @REM 环境变量JC_jEnv中已存在当前要添加JAVA_ALIAS
    if %notexist% == 0 (
        echo | set /p JCOut=" 已设置过该版本的java"
        echo.
        goto end
    )
    @REM 保存添加的环境变量到JC_jEnv中
    if "%JC_jEnv%" == "" (
        echo | set /p JCOut=" 用户环境变量中没有JC_jEnv"
        echo.
        %SystemRoot%\system32\setx JC_jEnv "%JDK_ALIAS%" >null
        @REM echo | set /p JCOut="/%SystemRoot%\system32\setx JC_jEnv "%JDK_ALIAS%" >>f:/JC_jEnv.cmd"
        @REM echo.
    ) else (
        %SystemRoot%\system32\setx JC_jEnv "%JDK_ALIAS%;%JC_jEnv%" >null
        @REM echo | set /p JCOut="/%SystemRoot%\system32\setx JC_jEnv "%JDK_ALIAS%;%JC_jEnv%" >>f:/JC_jEnv.cmd"
        @REM echo.
    )
    @REM rem 设置别名
    %SystemRoot%\system32\doskey %JDK_ALIAS%=%JDK_DIR%\bin\java.exe $*   >null
    @REM echo | set /p JCOut="/%SystemRoot%\system32\doskey %JDK_ALIAS%=%JDK_DIR%\bin\java.exe $* >>f:/JC_jEnv.cmd"
    @REM echo.

    echo | set /p JCOut=" 已为%JDK_DIR%\bin\java.exe设置别名%JDK_ALIAS%"
    echo.
    @REM 清空定义的变量
    @REM set JDK_ALIAS=
    set JDK_DIR=
    @REM 刷新环境变量
    goto refreshenv

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
    goto :EOF


:end
    echo.
    echo Done
