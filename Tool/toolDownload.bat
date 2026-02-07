@echo off
cd /d "%~dp0"
chcp 65001 >nul
title YouTube Downloader Pro V3 - by Gemini
color 0F

:: ====== CẤU HÌNH CHUNG ======
:: Nơi lưu file (để trống là lưu tại thư mục hiện tại)
set "SAVE_PATH=%~dp0Downloads"
if not exist "%SAVE_PATH%" mkdir "%SAVE_PATH%"

:: Các tham số chung (Metadata, Ảnh bìa, Tắt check ngày tháng)
set "COMMON_ARGS=--no-mtime --embed-thumbnail --add-metadata --progress"

:: ====== KIỂM TRA TOOL ======
where yt-dlp >nul 2>nul
if errorlevel 1 goto ERR_TOOL
where ffmpeg >nul 2>nul
if errorlevel 1 goto ERR_TOOL

:MAIN_MENU
cls
echo ========================================================
echo               YOUTUBE DOWNLOADER PRO V3
echo ========================================================
echo  Nơi lưu: %SAVE_PATH%
echo ========================================================
echo.
echo  [ ÂM THANH / AUDIO ]
echo    1. MP3 - Chất lượng cao nhất (320kbps)
echo    2. M4A - Nhẹ, chuẩn cho iPhone/Apple
echo.
echo  [ VIDEO / HÌNH ẢNH ]
echo    3. MP4 - Full HD (1080p) - Khuyên dùng
echo    4. MP4 - Max Quality (2K, 4K, 8K)
echo    5. MP4 - Tương thích cao (H.264 cho TV/Xe hơi cũ)
echo.
echo  [ TIỆN ÍCH ]
echo    6. Cập nhật yt-dlp lên bản mới nhất
echo    0. Thoát
echo.
echo ========================================================
set /p choice=👉 Lựa chọn của bạn (0-6): 

if "%choice%"=="1" set "FMT=mp3" & goto PROCESS_AUDIO
if "%choice%"=="2" set "FMT=m4a" & goto PROCESS_AUDIO
if "%choice%"=="3" goto VIDEO_1080
if "%choice%"=="4" goto VIDEO_MAX
if "%choice%"=="5" goto VIDEO_LEGACY
if "%choice%"=="6" goto UPDATE
if "%choice%"=="0" exit
goto MAIN_MENU

:: ========================================================
:: XỬ LÝ AUDIO (MP3/M4A)
:: ========================================================
:PROCESS_AUDIO
cls
echo [ ĐANG CHẾ ĐỘ TẢI AUDIO - %FMT% ]
echo.
set /p url=👉 Dán Link YouTube vào đây: 

:: Hỏi về Playlist
set "PL_ARGS=--no-playlist"
echo.
set /p is_pl=❓ Link này là Playlist? Tải toàn bộ không? (y/n): 
if /i "%is_pl%"=="y" set "PL_ARGS=--yes-playlist"

echo.
echo 🔽 Đang tải Audio...
yt-dlp %COMMON_ARGS% %PL_ARGS% -x --audio-format %FMT% --audio-quality 0 -o "%SAVE_PATH%\%%(title)s.%%(ext)s" "%url%"
goto FINISH

:: ========================================================
:: XỬ LÝ VIDEO: 1080P
:: ========================================================
:VIDEO_1080
cls
echo [ ĐANG CHẾ ĐỘ TẢI VIDEO - FULL HD 1080P ]
echo.
set /p url=👉 Dán Link YouTube vào đây: 

set "PL_ARGS=--no-playlist"
echo.
set /p is_pl=❓ Link này là Playlist? Tải toàn bộ không? (y/n): 
if /i "%is_pl%"=="y" set "PL_ARGS=--yes-playlist"

echo.
echo 🔽 Đang tải Video 1080p + Subtitles...
:: Logic: Lấy video tốt nhất nhưng chiều cao <= 1080, cộng audio tốt nhất
yt-dlp %COMMON_ARGS% %PL_ARGS% -f "bv*[height<=1080]+ba/b[height<=1080]/b" --merge-output-format mp4 --embed-subs --sub-langs all,-live_chat -o "%SAVE_PATH%\%%(title)s.%%(ext)s" "%url%"
goto FINISH

:: ========================================================
:: XỬ LÝ VIDEO: MAX QUALITY
:: ========================================================
:VIDEO_MAX
cls
echo [ ĐANG CHẾ ĐỘ TẢI VIDEO - MAX QUALITY (4K/8K) ]
echo ⚠️ Lưu ý: Video 4K thường dùng codec VP9/AV1, một số máy cũ có thể bị giật.
echo.
set /p url=👉 Dán Link YouTube vào đây: 

set "PL_ARGS=--no-playlist"
echo.
set /p is_pl=❓ Link này là Playlist? Tải toàn bộ không? (y/n): 
if /i "%is_pl%"=="y" set "PL_ARGS=--yes-playlist"

echo.
echo 🔽 Đang tải Video chất lượng gốc...
yt-dlp %COMMON_ARGS% %PL_ARGS% -f "bv+ba/b" --merge-output-format mp4 --embed-subs --sub-langs all,-live_chat -o "%SAVE_PATH%\%%(title)s.%%(ext)s" "%url%"
goto FINISH

:: ========================================================
:: XỬ LÝ VIDEO: LEGACY (WMP / OTO / TV CŨ)
:: ========================================================
:VIDEO_LEGACY
cls
echo [ ĐANG CHẾ ĐỘ TẢI VIDEO - TƯƠNG THÍCH CAO (H.264) ]
echo.
set /p url=👉 Dán Link YouTube vào đây: 

set "PL_ARGS=--no-playlist"
echo.
set /p is_pl=❓ Link này là Playlist? Tải toàn bộ không? (y/n): 
if /i "%is_pl%"=="y" set "PL_ARGS=--yes-playlist"

echo.
echo 🔽 Đang tải Video H.264...
yt-dlp %COMMON_ARGS% %PL_ARGS% -f "bv*[vcodec^=avc]+ba[acodec^=mp4a]/b[ext=mp4]/b" --merge-output-format mp4 -o "%SAVE_PATH%\%%(title)s.%%(ext)s" "%url%"
goto FINISH

:: ========================================================
:: CÁC HÀM HỖ TRỢ
:: ========================================================
:UPDATE
cls
echo 🔄 Đang kiểm tra và cập nhật yt-dlp...
yt-dlp -U
echo.
echo ✅ Đã cập nhật xong (hoặc đã là bản mới nhất).
pause
goto MAIN_MENU

:FINISH
echo.
echo ========================================================
echo ✅ HOÀN TẤT QUÁ TRÌNH TẢI XUỐNG!
echo 📂 File đã lưu tại: %SAVE_PATH%
echo ========================================================
echo 1. Quay lại Menu chính
echo 2. Thoát
set /p end_choice=Chọn: 
if "%end_choice%"=="1" goto MAIN_MENU
exit

:ERR_TOOL
cls
echo ❌ LỖI: THIẾU CÔNG CỤ
echo ----------------------
echo Script này cần 2 file sau nằm cùng thư mục (hoặc trong PATH):
echo 1. yt-dlp.exe
echo 2. ffmpeg.exe
echo.
pause
exit