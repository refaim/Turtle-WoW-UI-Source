@echo off
del /s /q *.blp *.ogg *.pub *.sig *.ttf *.png *.m2
for /r %%F in (*) do if %%~zF==0 del "%%F"