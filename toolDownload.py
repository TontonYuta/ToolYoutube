import customtkinter as ctk
import yt_dlp
import threading
import os
import sys
from tkinter import messagebox, filedialog

# === CẤU HÌNH GIAO DIỆN ===
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("dark-blue")

def get_base_path():
    """Lấy đường dẫn chuẩn dù chạy file .py hay .exe"""
    if getattr(sys, 'frozen', False):
        return os.path.dirname(sys.executable)
    return os.path.dirname(os.path.abspath(__file__))

class YouTubeDownloaderFinal(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("YouTube Downloader V6.4 - Anti-Freeze")
        self.geometry("650x500")
        self.resizable(False, False)
        
        self.base_path = get_base_path()
        self.ffmpeg_exe = os.path.join(self.base_path, 'ffmpeg.exe')
        
        # Mặc định lưu vào thư mục Downloads cạnh tool
        self.save_path = os.path.join(self.base_path, "Downloads")
        if not os.path.exists(self.save_path): os.makedirs(self.save_path)

        # 1. HEADER
        ctk.CTkLabel(self, text="YOUTUBE DOWNLOADER PRO", font=("Arial", 24, "bold")).pack(pady=(20, 5))

        # 2. CHECK FFMPEG STATUS (Quan trọng)
        self.lbl_ffmpeg = ctk.CTkLabel(self, text="Đang kiểm tra FFmpeg...", font=("Arial", 12, "bold"))
        self.lbl_ffmpeg.pack(pady=(0, 15))
        self.check_ffmpeg_startup()

        # 3. INPUT
        frame_input = ctk.CTkFrame(self, fg_color="transparent")
        frame_input.pack(pady=5, padx=20, fill="x")
        
        self.entry_url = ctk.CTkEntry(frame_input, height=45, font=("Arial", 14), placeholder_text="Dán link YouTube vào đây...")
        self.entry_url.pack(side="left", fill="x", expand=True, padx=(0, 10))
        ctk.CTkButton(frame_input, text="DÁN LINK", width=100, height=45, fg_color="#333", hover_color="#555", command=self.paste_link).pack(side="right")

        # 4. TABS
        self.tab_view = ctk.CTkTabview(self, width=600, height=130)
        self.tab_view.pack(pady=10)
        
        self.tab_video = self.tab_view.add("   🎬 VIDEO   ")
        self.tab_audio = self.tab_view.add("   🎵 MP3/AUDIO   ")

        # --- Video Tab ---
        ctk.CTkLabel(self.tab_video, text="Chất lượng:").grid(row=0, column=0, padx=15, pady=20)
        self.opt_video_qual = ctk.CTkOptionMenu(self.tab_video, values=["1080p (Full HD)", "Max Quality (4K)", "720p (Nhẹ)"])
        self.opt_video_qual.grid(row=0, column=1, padx=15, pady=20)
        self.chk_playlist_v = ctk.CTkCheckBox(self.tab_video, text="Tải cả Playlist")
        self.chk_playlist_v.grid(row=0, column=2, padx=15, pady=20)

        # --- Audio Tab ---
        ctk.CTkLabel(self.tab_audio, text="Định dạng:").grid(row=0, column=0, padx=15, pady=20)
        self.opt_audio_mode = ctk.CTkOptionMenu(self.tab_audio, values=["M4A (Siêu Nhanh)", "MP3 (320kbps)"])
        self.opt_audio_mode.grid(row=0, column=1, padx=15, pady=20)
        self.chk_playlist_a = ctk.CTkCheckBox(self.tab_audio, text="Tải cả Playlist")
        self.chk_playlist_a.grid(row=0, column=2, padx=15, pady=20)

        # 5. BUTTON
        self.btn_download = ctk.CTkButton(self, text="TẢI XUỐNG NGAY", width=300, height=50, font=("Arial", 16, "bold"), fg_color="white", text_color="black", hover_color="#ddd", command=self.start_download)
        self.btn_download.pack(pady=10)

        # 6. STATUS
        self.lbl_status = ctk.CTkLabel(self, text="Sẵn sàng...", font=("Arial", 12))
        self.lbl_status.pack(pady=(0, 5))
        
        self.progress_bar = ctk.CTkProgressBar(self, width=550, progress_color="white")
        self.progress_bar.set(0)
        self.progress_bar.pack(pady=(0, 10))

        # 7. FOOTER
        frame_footer = ctk.CTkFrame(self, fg_color="transparent")
        frame_footer.pack(side="bottom", fill="x", padx=20, pady=10)
        ctk.CTkButton(frame_footer, text="📂 Folder", width=80, fg_color="#333", command=self.browse_folder).pack(side="left")
        self.lbl_path = ctk.CTkLabel(frame_footer, text=f" {self.save_path}", text_color="gray")
        self.lbl_path.pack(side="left", padx=10)

    # === LOGIC ===
    def check_ffmpeg_startup(self):
        if os.path.exists(self.ffmpeg_exe):
            self.lbl_ffmpeg.configure(text="✅ Đã tìm thấy FFmpeg (Sẵn sàng ghép file)", text_color="#00ff00")
            return True
        else:
            self.lbl_ffmpeg.configure(text=f"❌ Thiếu file ffmpeg.exe tại: {self.base_path}", text_color="#ff4444")
            return False

    def paste_link(self):
        try:
            self.entry_url.delete(0, 'end')
            self.entry_url.insert(0, self.clipboard_get())
        except: pass

    def browse_folder(self):
        p = filedialog.askdirectory()
        if p: self.save_path = p; self.lbl_path.configure(text=f" {p}")

    def start_download(self):
        url = self.entry_url.get()
        if not url: return messagebox.showerror("Lỗi", "Chưa nhập Link!")

        # Kiểm tra lại lần nữa trước khi bấm nút
        if not self.check_ffmpeg_startup():
            messagebox.showerror("Lỗi Thiếu File", f"Tool không tìm thấy file ffmpeg.exe!\n\nHãy copy file ffmpeg.exe để vào cạnh file tool này.")
            return

        self.btn_download.configure(state="disabled", text="⏳ ĐANG XỬ LÝ...")
        self.progress_bar.set(0)
        
        is_audio = "AUDIO" in self.tab_view.get()
        # Chạy luồng riêng để không đơ giao diện
        threading.Thread(target=self.run_process, args=(url, is_audio)).start()

    def run_process(self, url, is_audio):
        # Cấu hình yt-dlp
        ydl_opts = {
            'outtmpl': f'{self.save_path}/%(title)s.%(ext)s',
            'progress_hooks': [self.progress_hook],
            'quiet': True, 
            'no_warnings': True, 
            'addmetadata': True,
            'ffmpeg_location': self.base_path, # Trỏ thẳng vào thư mục chứa ffmpeg
            'writesubtitles': False, # Tắt sub để tránh lỗi vtt
        }

        if is_audio:
            mode = self.opt_audio_mode.get()
            if "M4A" in mode:
                ydl_opts.update({'format': 'bestaudio[ext=m4a]'})
            else:
                ydl_opts.update({
                    'format': 'bestaudio/best',
                    'postprocessors': [{'key': 'FFmpegExtractAudio','preferredcodec': 'mp3','preferredquality': '320'}],
                })
            ydl_opts['noplaylist'] = not self.chk_playlist_a.get()
        else:
            qual = self.opt_video_qual.get()
            ydl_opts.update({'merge_output_format': 'mp4'})
            
            if "720p" in qual: ydl_opts.update({'format': 'bv*[height<=720]+ba/b[height<=720]/b'})
            elif "1080p" in qual: ydl_opts.update({'format': 'bv*[height<=1080]+ba/b[height<=1080]/b'})
            else: ydl_opts.update({'format': 'bv+ba/b'})
            
            ydl_opts['noplaylist'] = not self.chk_playlist_v.get()

        try:
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                ydl.download([url])
            
            self.lbl_status.configure(text="✅ HOÀN TẤT!", text_color="#00ff00")
            messagebox.showinfo("Thành công", "Đã tải xong! Mở thư mục Downloads để xem.")
            
        except Exception as e:
            # Bắt mọi lỗi để không bị treo
            self.lbl_status.configure(text="❌ Lỗi xảy ra!", text_color="red")
            err_msg = str(e)
            if "ffmpeg" in err_msg.lower():
                messagebox.showerror("Lỗi FFmpeg", "Không tìm thấy hoặc không chạy được FFmpeg.\nHãy kiểm tra lại file ffmpeg.exe.")
            else:
                messagebox.showerror("Lỗi Tải", f"Chi tiết lỗi:\n{err_msg}")
                
        finally:
            # Luôn mở lại nút dù thành công hay thất bại
            self.btn_download.configure(state="normal", text="TẢI XUỐNG NGAY")

    def progress_hook(self, d):
        if d['status'] == 'downloading':
            try:
                p = d.get('_percent_str', '0%').replace('%','')
                self.progress_bar.set(float(p)/100)
                fname = os.path.basename(d.get('filename', ''))[:30]
                self.lbl_status.configure(text=f"Đang tải: {d.get('_percent_str')} | {fname}...", text_color="white")
            except: pass
        elif d['status'] == 'finished':
            self.lbl_status.configure(text="♻️ Đang ghép Audio & Video (Đừng tắt)...", text_color="yellow")
            self.progress_bar.set(1)

if __name__ == "__main__":
    app = YouTubeDownloaderFinal()
    app.mainloop()
