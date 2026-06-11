@echo off
call scripts\run_lint.bat || exit /b %errorlevel%
call scripts\run_sim.bat || exit /b %errorlevel%
