@echo off
Title Easy-model2GGUF by ivo v0.2.1
:: Pixaroma Community Edition ::

:: Set colors ::
call :set_colors

:: GUI Mode Selection - Set to 1 for GUI, 0 for text mode ::
set "GUI_MODE=1"

:: Check Add-ons\Tools folder ::
set "PYTHON_PATH=..\..\python_embeded\python.exe"
if not exist %PYTHON_PATH% (
    cls
    echo %green%::::::::::::::: Run this file from the %red%'ComfyUI-Easy-Install\Add-ons\Tools'%green% folder
    echo %green%::::::::::::::: Press any key to exit...%reset%&Pause>nul
	exit
)

:: Check llama.cpp ::
if not exist llama.cpp\llama-quantize.exe (
    cls
	echo %green%::::::::::::::: %yellow%llama.cpp%green% bin pack is not in the %yellow%Add-ons\Tools\llama.cpp\%green% folder
    echo %green%::::::::::::::: Press any key to exit...%reset%&Pause>nul
	exit
)

:: Set powershell local path (temporarily) ::
if exist %windir%\System32\WindowsPowerShell\v1.0 set path=%PATH%;%windir%\System32\WindowsPowerShell\v1.0

echo.
echo %yellow%model2GGUF%green% is a tool that converts %yellow%safetensors/ckpt%green% models to %yellow%FP16/BF16 GGUF%green%
echo.
echo %green%More info: %yellow%https://github.com/city96/ComfyUI-GGUF/blob/main/tools/README.md%reset%
echo.
echo %green%Make sure you have installed the latest version of Visual C++ Redistributable:
echo %green%::::::::::::::::::: %yellow%https://aka.ms/vc14/vc_redist.x64.exe%green% ::::::::::::::::::::
echo.

:: Capture the start time ::
for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -command "Get-Date -Format yyyy-MM-dd_HH:mm:ss"') do set start=%%i

:: Installing ComfyUI-GGUF if not exist ::
if not exist ..\..\ComfyUI\custom_nodes\ComfyUI-GGUF (
	echo %green%::::::::::::::: Installing%yellow% ComfyUI-GGUF%reset%
    echo.
    git.exe clone "https://github.com/city96/ComfyUI-GGUF" ..\..\ComfyUI\custom_nodes\ComfyUI-GGUF
    ..\..\python_embeded\python.exe -m pip install -r ..\..\ComfyUI\custom_nodes\ComfyUI-GGUF\requirements.txt
)

:: Switch ComfyUI-GGUF to the auto_convert branch ::
pushd %cd%
cd ..\..\ComfyUI\custom_nodes\ComfyUI-GGUF
git.exe checkout -q auto_convert
popd

:: File select dialog ::
echo %green%::::::::::::::: Select input model file%reset%
set "input_file="
for /f "tokens=*" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -command "Add-Type -AssemblyName System.Windows.Forms; $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog; $openFileDialog.Filter = 'Model files (*.safetensors,*.pth,*.pt)|*.safetensors;*.pth;*.pt|All files (*.*)|*.*'; $openFileDialog.Title = 'Select input model file'; if($openFileDialog.ShowDialog() -eq 'OK') { Write-Output $openFileDialog.FileName }"') do set "input_file=%%i"

if "%input_file%"=="" (
    echo %red%::::::::::::::: No input file selected. Exiting.%reset%
    echo %green%::::::::::::::: Press any key to exit...%reset%&Pause>nul
    exit /b 1
)

echo.
echo %green%::::::::::::::: Selected input file: %yellow%%input_file%%reset%

:: Quantization selection based on GUI_MODE ::
if "%GUI_MODE%"=="1" (call :gui_quant_selection) else (call :text_quant_selection)

if "%quant_method%"=="" (
    echo %red%::::::::::::::: No quantization method selected. Exiting.%reset%
    echo %green%::::::::::::::: Press any key to exit...%reset%&Pause>nul
    exit /b 1
)

echo %green%::::::::::::::: Selected quantization: %yellow%%quant_method%%reset%

:: Generate output file names based on input file ::
for %%I in ("%input_file%") do (
    set "input_dir=%%~dpI"
    set "input_name=%%~nI"
)

set "fp16_gguf=%input_dir%%input_name%-FP16.gguf"
set "bf16_gguf=%input_dir%%input_name%-BF16.gguf"
set "quant_gguf=%input_dir%%input_name%-%quant_method%.gguf"

echo %green%::::::::::::::: Expected GGUF files:%reset%
echo %yellow%FP16: %fp16_gguf%%reset%
echo %yellow%BF16: %bf16_gguf%%reset%

:: Converting initial model to FP16/BF16 GGUF ::
echo %green%::::::::::::::: Converting model to GGUF format%reset%
..\..\python_embeded\python.exe ..\..\ComfyUI\custom_nodes\ComfyUI-GGUF\tools\convert.py --src "%input_file%"

:: Check which GGUF file was created ::
set "intermediate_gguf="
if exist "%bf16_gguf%" (
    set "intermediate_gguf=%bf16_gguf%"
    echo %green%::::::::::::::: Found BF16 GGUF file%reset%
) else if exist "%fp16_gguf%" (
    set "intermediate_gguf=%fp16_gguf%"
    echo %green%::::::::::::::: Found FP16 GGUF file%reset%
) else (
    echo %red%::::::::::::::: GGUF conversion failed. Checking for any GGUF files in directory...%reset%
    dir "%input_dir%*.gguf" /b
    echo %green%::::::::::::::: Press any key to exit...%reset%&Pause>nul
    exit /b 1
)

:: Quantize the model ::
echo %green%::::::::::::::: Quantizing model to %quant_method%%reset%
echo %green%::::::::::::::: Input: %yellow%%intermediate_gguf%%reset%
echo %green%::::::::::::::: Output: %yellow%%quant_gguf%%reset%
.\llama.cpp\llama-quantize.exe "%intermediate_gguf%" "%quant_gguf%" %quant_method%

:: Check for fix_5d_tensors file and apply fix if found ::
set "fix_file="
for /f "delims=" %%f in ('dir "%input_dir%fix_5d_tensors_*.safetensors" /b 2^>nul') do set "fix_file=%%f"

if defined fix_file (
    echo %green%::::::::::::::: Found fix file: %yellow%%fix_file%%reset%
    echo %green%::::::::::::::: Moving fix file to script directory%reset%
    move "%input_dir%%fix_file%" ".\%fix_file%" >nul
    
    echo %green%::::::::::::::: Applying 5D tensors fix%reset%
    
    setlocal enabledelayedexpansion
    set "fixed_gguf=%input_dir%%input_name%-%quant_method%-fixed.gguf"
    
    echo %green%::::::::::::::: Source: %yellow%%quant_gguf%%reset%
    echo %green%::::::::::::::: Destination: %yellow%!fixed_gguf!%reset%
    
    ..\..\python_embeded\python.exe ..\..\ComfyUI\custom_nodes\ComfyUI-GGUF\tools\fix_5d_tensors.py --src "%quant_gguf%" --dst "!fixed_gguf!" --overwrite
    
    if exist "!fixed_gguf!" (
        echo %green%::::::::::::::: Fixed GGUF file created successfully: %yellow%!fixed_gguf!%reset%
        echo %green%::::::::::::::: Removing original quantized file: %yellow%%quant_gguf%%reset%
        del "%quant_gguf%"
        
        echo %green%::::::::::::::: Renaming fixed file to original quant name%reset%
        move "!fixed_gguf!" "%quant_gguf%" >nul
        
        echo %green%::::::::::::::: Cleaning up fix files%reset%
        del ".\%fix_file%" >nul 2>&1
        
        echo %green%::::::::::::::: Final output file: %yellow%%quant_gguf%%reset%
        endlocal
    ) else (
        echo %red%::::::::::::::: Failed to create fixed GGUF file, keeping original%reset%
        endlocal
    )
)

:: Switch to ComfyUI-GGUF main branch ::
echo %green%::::::::::::::: Switch ComfyUI-GGUF to the %yellow%main branch%reset%
pushd %cd%
cd ..\..\ComfyUI\custom_nodes\ComfyUI-GGUF
git.exe checkout -q main
popd

:: Capture the end time ::
for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -command "Get-Date -Format yyyy-MM-dd_HH:mm:ss"') do set end=%%i

for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -command "$s=[datetime]::ParseExact('%start%','yyyy-MM-dd_HH:mm:ss',$null); $e=[datetime]::ParseExact('%end%','yyyy-MM-dd_HH:mm:ss',$null); if($e -lt $s){$e=$e.AddDays(1)}; ($e-$s).TotalSeconds"') do set diff=%%i

:: Final Messages ::
echo.
echo %green%::::::::::::::: Conversion Complete%reset%
echo %green%::::::::::::::: Input: %yellow%%input_file%%reset%
echo %green%::::::::::::::: Intermediate: %yellow%%intermediate_gguf%%reset%
echo %green%::::::::::::::: Output: %yellow%%quant_gguf%%reset%
echo %green%::::::::::::::: Quantization: %yellow%%quant_method%%reset%
echo.
echo %green%::::::::::::::: Total Running Time:%red% %diff% %green%seconds%reset%
echo %green%::::::::::::::: Press any key to exit%reset%&Pause>nul
exit

:gui_quant_selection
echo %green%::::::::::::::: Select quantization method%reset%
for /f "tokens=*" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -command "Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $form = New-Object System.Windows.Forms.Form; $form.Text = 'Select Quantization Method'; $form.Size = New-Object System.Drawing.Size(375,480); $form.StartPosition = 'CenterScreen'; $form.MaximizeBox = $false; $form.FormBorderStyle = 'FixedDialog'; $monospaceFont = New-Object System.Drawing.Font('Consolas', 9); $defaultFont = $form.Font; $label = New-Object System.Windows.Forms.Label; $label.Location = New-Object System.Drawing.Point(10,10); $label.Size = New-Object System.Drawing.Size(400,20); $label.Text = 'Select quantization method (ordered by quality):'; $groupBox = New-Object System.Windows.Forms.GroupBox; $groupBox.Location = New-Object System.Drawing.Point(10,35); $groupBox.Size = New-Object System.Drawing.Size(340,350); $groupBox.Text = 'Quantization Methods'; $yPos = 20; $radio1 = New-Object System.Windows.Forms.RadioButton; $radio1.Location = New-Object System.Drawing.Point(10,$yPos); $radio1.Size = New-Object System.Drawing.Size(320,20); $radio1.Text = '1 - Q8_0    (highest quality, largest size)'; $radio1.Tag = 'Q8_0'; $radio1.Font = $monospaceFont; $yPos += 25; $radio2 = New-Object System.Windows.Forms.RadioButton; $radio2.Location = New-Object System.Drawing.Point(10,$yPos); $radio2.Size = New-Object System.Drawing.Size(320,20); $radio2.Text = '2 - Q6_K    (very high quality)'; $radio2.Tag = 'Q6_K'; $radio2.Font = $monospaceFont; $yPos += 25; $radio3 = New-Object System.Windows.Forms.RadioButton; $radio3.Location = New-Object System.Drawing.Point(10,$yPos); $radio3.Size = New-Object System.Drawing.Size(320,20); $radio3.Text = '3 - Q5_K_M  (high quality)'; $radio3.Tag = 'Q5_K_M'; $radio3.Font = $monospaceFont; $yPos += 25; $radio4 = New-Object System.Windows.Forms.RadioButton; $radio4.Location = New-Object System.Drawing.Point(10,$yPos); $radio4.Size = New-Object System.Drawing.Size(320,20); $radio4.Text = '4 - Q5_K_S  (high quality)'; $radio4.Tag = 'Q5_K_S'; $radio4.Font = $monospaceFont; $yPos += 25; $radio5 = New-Object System.Windows.Forms.RadioButton; $radio5.Location = New-Object System.Drawing.Point(10,$yPos); $radio5.Size = New-Object System.Drawing.Size(320,20); $radio5.Text = '5 - Q5_1    (high quality)'; $radio5.Tag = 'Q5_1'; $radio5.Font = $monospaceFont; $yPos += 25; $radio6 = New-Object System.Windows.Forms.RadioButton; $radio6.Location = New-Object System.Drawing.Point(10,$yPos); $radio6.Size = New-Object System.Drawing.Size(320,20); $radio6.Text = '6 - Q5_0    (high quality)'; $radio6.Tag = 'Q5_0'; $radio6.Font = $monospaceFont; $yPos += 25; $radio7 = New-Object System.Windows.Forms.RadioButton; $radio7.Location = New-Object System.Drawing.Point(10,$yPos); $radio7.Size = New-Object System.Drawing.Size(320,20); $radio7.Text = '7 - Q4_K_M  (medium-high quality)'; $radio7.Tag = 'Q4_K_M'; $radio7.Font = $monospaceFont; $yPos += 25; $radio8 = New-Object System.Windows.Forms.RadioButton; $radio8.Location = New-Object System.Drawing.Point(10,$yPos); $radio8.Size = New-Object System.Drawing.Size(320,20); $radio8.Text = '8 - Q4_K_S  (medium-high quality)'; $radio8.Tag = 'Q4_K_S'; $radio8.Font = $monospaceFont; $yPos += 25; $radio9 = New-Object System.Windows.Forms.RadioButton; $radio9.Location = New-Object System.Drawing.Point(10,$yPos); $radio9.Size = New-Object System.Drawing.Size(320,20); $radio9.Text = '9 - Q4_1    (medium quality)'; $radio9.Tag = 'Q4_1'; $radio9.Font = $monospaceFont; $yPos += 25; $radio10 = New-Object System.Windows.Forms.RadioButton; $radio10.Location = New-Object System.Drawing.Point(10,$yPos); $radio10.Size = New-Object System.Drawing.Size(320,20); $radio10.Text = 'A - Q4_0    (medium quality)'; $radio10.Tag = 'Q4_0'; $radio10.Font = $monospaceFont; $yPos += 25; $radio11 = New-Object System.Windows.Forms.RadioButton; $radio11.Location = New-Object System.Drawing.Point(10,$yPos); $radio11.Size = New-Object System.Drawing.Size(320,20); $radio11.Text = 'B - Q3_K_M  (low-medium quality)'; $radio11.Tag = 'Q3_K_M'; $radio11.Font = $monospaceFont; $yPos += 25; $radio12 = New-Object System.Windows.Forms.RadioButton; $radio12.Location = New-Object System.Drawing.Point(10,$yPos); $radio12.Size = New-Object System.Drawing.Size(320,20); $radio12.Text = 'C - Q3_K_S  (low quality)'; $radio12.Tag = 'Q3_K_S'; $radio12.Font = $monospaceFont; $yPos += 25; $radio13 = New-Object System.Windows.Forms.RadioButton; $radio13.Location = New-Object System.Drawing.Point(10,$yPos); $radio13.Size = New-Object System.Drawing.Size(320,20); $radio13.Text = 'D - Q2_K    (lowest quality, smallest size)'; $radio13.Tag = 'Q2_K'; $radio13.Font = $monospaceFont; $radio7.Checked = $true; $OKButton = New-Object System.Windows.Forms.Button; $OKButton.Location = New-Object System.Drawing.Point(100,400); $OKButton.Size = New-Object System.Drawing.Size(75,30); $OKButton.Text = 'OK'; $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK; $CancelButton = New-Object System.Windows.Forms.Button; $CancelButton.Location = New-Object System.Drawing.Point(190,400); $CancelButton.Size = New-Object System.Drawing.Size(75,30); $CancelButton.Text = 'Cancel'; $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel; $form.AcceptButton = $OKButton; $form.CancelButton = $CancelButton; $form.Controls.Add($OKButton); $form.Controls.Add($CancelButton); $form.Controls.Add($label); $groupBox.Controls.Add($radio1); $groupBox.Controls.Add($radio2); $groupBox.Controls.Add($radio3); $groupBox.Controls.Add($radio4); $groupBox.Controls.Add($radio5); $groupBox.Controls.Add($radio6); $groupBox.Controls.Add($radio7); $groupBox.Controls.Add($radio8); $groupBox.Controls.Add($radio9); $groupBox.Controls.Add($radio10); $groupBox.Controls.Add($radio11); $groupBox.Controls.Add($radio12); $groupBox.Controls.Add($radio13); $form.Controls.Add($groupBox); $result = $form.ShowDialog(); if ($result -eq [System.Windows.Forms.DialogResult]::OK) { if($radio1.Checked) { Write-Output $radio1.Tag } elseif($radio2.Checked) { Write-Output $radio2.Tag } elseif($radio3.Checked) { Write-Output $radio3.Tag } elseif($radio4.Checked) { Write-Output $radio4.Tag } elseif($radio5.Checked) { Write-Output $radio5.Tag } elseif($radio6.Checked) { Write-Output $radio6.Tag } elseif($radio7.Checked) { Write-Output $radio7.Tag } elseif($radio8.Checked) { Write-Output $radio8.Tag } elseif($radio9.Checked) { Write-Output $radio9.Tag } elseif($radio10.Checked) { Write-Output $radio10.Tag } elseif($radio11.Checked) { Write-Output $radio11.Tag } elseif($radio12.Checked) { Write-Output $radio12.Tag } else { Write-Output $radio13.Tag } }"') do set "quant_method=%%i"
goto :eof

:text_quant_selection
echo.
echo %green%::::::::::::::: Select quantization method (ordered by quality)%reset%
echo 1 - Q8_0    (highest quality, largest size)
echo 2 - Q6_K    (very high quality)
echo 3 - Q5_K_M  (high quality)
echo 4 - Q5_K_S  (high quality)
echo 5 - Q5_1    (high quality)
echo 6 - Q5_0    (high quality)
echo 7 - Q4_K_M  (medium-high quality)
echo 8 - Q4_K_S  (medium-high quality)
echo 9 - Q4_1    (medium quality)
echo A - Q4_0    (medium quality)
echo B - Q3_K_M  (low-medium quality)
echo C - Q3_K_S  (low quality)
echo D - Q2_K    (lowest quality, smallest size)
echo.

choice /C 123456789ABCD /N /M "Enter your choice (1-9, A-D): "

if %ERRORLEVEL% equ 1 set "quant_method=Q8_0"
if %ERRORLEVEL% equ 2 set "quant_method=Q6_K"
if %ERRORLEVEL% equ 3 set "quant_method=Q5_K_M"
if %ERRORLEVEL% equ 4 set "quant_method=Q5_K_S"
if %ERRORLEVEL% equ 5 set "quant_method=Q5_1"
if %ERRORLEVEL% equ 6 set "quant_method=Q5_0"
if %ERRORLEVEL% equ 7 set "quant_method=Q4_K_M"
if %ERRORLEVEL% equ 8 set "quant_method=Q4_K_S"
if %ERRORLEVEL% equ 9 set "quant_method=Q4_1"
if %ERRORLEVEL% equ 10 set "quant_method=Q4_0"
if %ERRORLEVEL% equ 11 set "quant_method=Q3_K_M"
if %ERRORLEVEL% equ 12 set "quant_method=Q3_K_S"
if %ERRORLEVEL% equ 13 set "quant_method=Q2_K"
goto :eof

:set_colors
set warning=[33m
set     red=[91m
set   green=[92m
set  yellow=[93m
set    bold=[1m
set   reset=[0m
goto :eof