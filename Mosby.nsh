# This script detects and runs Mosby for the relevant architecture
@echo -off

# Make sure that the drive where this script resides is writeable
echo test > %0_write_test
if not exist %0_write_test then
  echo ERROR: The directory where Mosby resides needs to be writeable
  exit /b 8
endif
del %0_write_test > NUL

# Check each architecture for an executable we can run
for %a in _x64 _ia32 _aa64 _arm _riscv64 _loongarch64
  # We have to run a subscript for this (hence why we look for a
  # writeable device) because if you run a .efi for the wrong
  # arch in a script, that script gets forcefully terminated!
  echo "Mosby%a.efi -v" > %0_test_arch.nsh
  %0_test_arch.nsh > NUL
  # Someone might try to run in a Secure Boot enabled environment
  # and then run into signature validation errors (ACCESS_DENIED)
  if %lasterror% == 15 then
    echo ERROR: Application is not (properly) signed for Secure Boot
    del %0_test_arch.nsh > NUL
    exit /b 26
  endif
  if %lasterror% == 0 then
    set -v ARCH %a
  endif
  del %0_test_arch.nsh > NUL
endfor

# If %ARCH% could not be detected, we still try to run 'Mosby.efi'
Mosby%ARCH%.efi %1 %2 %3 %4 %5 %6 %7 %8 %9
