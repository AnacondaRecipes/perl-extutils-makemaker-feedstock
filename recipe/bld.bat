:: If it has Build.PL use that, otherwise use Makefile.PL
IF exist Build.PL (
    perl Build.PL
    IF ERRORLEVEL 1 exit /b 1

    Build
    IF ERRORLEVEL 1 exit /b 1

    Build test
    IF ERRORLEVEL 1 exit /b 1

    :: Make sure this goes in site
    Build install --installdirs site
    IF ERRORLEVEL 1 exit /b 1
) ELSE (
    IF exist Makefile.PL (
        :: Make sure this goes in site
        perl Makefile.PL INSTALLDIRS=site
        IF ERRORLEVEL 1 exit /b 1

        :: Perl on Windows with MSVC emits an nmake-style Makefile; do not use GNU make
        :: (msys2-make) or you get "multiple target patterns" and other parse errors.
        for /f "usebackq delims=" %%M in (`perl -MConfig -e "print $Config{make}"`) do set "MAKE_PROG=%%M"

        "%MAKE_PROG%"
        IF ERRORLEVEL 1 exit /b 1

        "%MAKE_PROG%" test
        IF ERRORLEVEL 1 exit /b 1

        "%MAKE_PROG%" install
        IF ERRORLEVEL 1 exit /b 1
    ) ELSE (
        ECHO Unable to find Build.PL or Makefile.PL. You need to modify bld.bat.
        exit /b 1
    )
)