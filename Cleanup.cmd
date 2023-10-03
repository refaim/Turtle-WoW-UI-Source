@echo off
del /s /q *.blp *.ogg *.pub *.sig *.ttf
for /r %%F in (*) do if %%~zF==0 del "%%F"