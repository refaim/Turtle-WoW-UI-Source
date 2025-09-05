@echo off
del /s /q *.blp *.ogg *.pub *.sig *.ttf *.png *.m2 *.zmp *.wav
for /r %%F in (*) do if %%~zF==0 del "%%F"