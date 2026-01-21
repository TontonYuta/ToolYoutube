Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===== KIEM TRA TOOL =====
$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$yt = Join-Path $baseDir "yt-dlp.exe"

if (-not (Test-Path $yt)) {
    [System.Windows.Forms.MessageBox]::Show(
        "Khong tim thay yt-dlp.exe",
        "Loi",
        "OK",
        "Error"
    )
    exit
}

# ===== TAO FORM =====
$form = New-Object System.Windows.Forms.Form
$form.Text = "YouTube Downloader"
$form.Size = New-Object System.Drawing.Size(520, 520)
$form.StartPosition = "CenterScreen"

# ===== LABEL URL =====
$lblUrl = New-Object System.Windows.Forms.Label
$lblUrl.Text = "YouTube URL:"
$lblUrl.Location = New-Object System.Drawing.Point(10, 15)
$form.Controls.Add($lblUrl)

# ===== TEXTBOX URL =====
$txtUrl = New-Object System.Windows.Forms.TextBox
$txtUrl.Size = New-Object System.Drawing.Size(480, 25)
$txtUrl.Location = New-Object System.Drawing.Point(10, 35)
$form.Controls.Add($txtUrl)

# ===== MODE =====
$grpMode = New-Object System.Windows.Forms.GroupBox
$grpMode.Text = "Che do"
$grpMode.Size = New-Object System.Drawing.Size(230, 60)
$grpMode.Location = New-Object System.Drawing.Point(10, 70)

$rbSingle = New-Object System.Windows.Forms.RadioButton
$rbSingle.Text = "1 bai"
$rbSingle.Checked = $true
$rbSingle.Location = New-Object System.Drawing.Point(10, 25)

$rbPlaylist = New-Object System.Windows.Forms.RadioButton
$rbPlaylist.Text = "Playlist / Mix"
$rbPlaylist.Location = New-Object System.Drawing.Point(120, 25)

$grpMode.Controls.AddRange(@($rbSingle, $rbPlaylist))
$form.Controls.Add($grpMode)

# ===== FORMAT =====
$grpFormat = New-Object System.Windows.Forms.GroupBox
$grpFormat.Text = "Dinh dang"
$grpFormat.Size = New-Object System.Drawing.Size(230, 60)
$grpFormat.Location = New-Object System.Drawing.Point(260, 70)

$rbMP3 = New-Object System.Windows.Forms.RadioButton
$rbMP3.Text = "MP3"
$rbMP3.Checked = $true
$rbMP3.Location = New-Object System.Drawing.Point(10, 25)

$rbMP4 = New-Object System.Windows.Forms.RadioButton
$rbMP4.Text = "MP4"
$rbMP4.Location = New-Object System.Drawing.Point(120, 25)

$grpFormat.Controls.AddRange(@($rbMP3, $rbMP4))
$form.Controls.Add($grpFormat)

# ===== BITRATE =====
$lblBitrate = New-Object System.Windows.Forms.Label
$lblBitrate.Text = "Bitrate MP3:"
$lblBitrate.Location = New-Object System.Drawing.Point(10, 145)
$form.Controls.Add($lblBitrate)

$cmbBitrate = New-Object System.Windows.Forms.ComboBox
$cmbBitrate.Items.AddRange(@("128", "192", "320"))
$cmbBitrate.SelectedIndex = 2
$cmbBitrate.Location = New-Object System.Drawing.Point(90, 140)
$form.Controls.Add($cmbBitrate)

# ===== FOLDER =====
$btnFolder = New-Object System.Windows.Forms.Button
$btnFolder.Text = "Chon thu muc"
$btnFolder.Location = New-Object System.Drawing.Point(10, 180)

$txtFolder = New-Object System.Windows.Forms.TextBox
$txtFolder.Size = New-Object System.Drawing.Size(360, 25)
$txtFolder.Location = New-Object System.Drawing.Point(130, 180)

$btnFolder.Add_Click({
    $fd = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($fd.ShowDialog() -eq "OK") {
        $txtFolder.Text = $fd.SelectedPath
    }
})

$form.Controls.AddRange(@($btnFolder, $txtFolder))

# ===== LOG BOX =====
$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Multiline = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.Size = New-Object System.Drawing.Size(480, 180)
$txtLog.Location = New-Object System.Drawing.Point(10, 220)
$form.Controls.Add($txtLog)

# ===== DOWNLOAD BUTTON =====
$btnDownload = New-Object System.Windows.Forms.Button
$btnDownload.Text = "DOWNLOAD"
$btnDownload.Size = New-Object System.Drawing.Size(480, 40)
$btnDownload.Location = New-Object System.Drawing.Point(10, 420)

$btnDownload.Add_Click({

    if ($txtUrl.Text -eq "" -or $txtFolder.Text -eq "") {
        [System.Windows.Forms.MessageBox]::Show("Thieu thong tin!")
        return
    }

    $url = $txtUrl.Text
    if ($rbSingle.Checked) {
        $url = $url.Split("&")[0]
    }

    $args = @("--no-overwrites")

    if ($rbSingle.Checked) {
        $args += "--no-playlist"
    }

    if ($rbMP3.Checked) {
        $args += "-x"
        $args += "--audio-format"
        $args += "mp3"
        $args += "--audio-quality"
        $args += $cmbBitrate.Text
        $args += "-o"
        $args += "%(title)s.%(ext)s"
    }
    else {
        $args += "-f"
        $args += "bv*+ba/b"
        $args += "--merge-output-format"
        $args += "mp4"
        $args += "-o"
        $args += "%(title)s.%(ext)s"
    }

    # 👉 THEM URL VAO CUOI MANG
    $args += $url

    $txtLog.AppendText("Dang tai...`r`n")

    Start-Process `
        -FilePath $yt `
        -ArgumentList $args `
        -WorkingDirectory $txtFolder.Text `
        -NoNewWindow `
        -Wait

    $txtLog.AppendText("Hoan thanh!`r`n")
})


$form.Controls.Add($btnDownload)

# ===== RUN =====
$form.ShowDialog()
