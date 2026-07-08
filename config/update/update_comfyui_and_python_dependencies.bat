@echo off
set "PIPargs=--no-cache-dir --no-warn-script-location --timeout=1000 --retries 10"
call update_comfyui.bat nopause
echo -
echo This will try to update pytorch and all python dependencies.
echo -
echo If you just want to update normally, close this and run update_comfyui.bat instead.
echo -
pause
for /f "tokens=1,2 delims=|" %%a in ('..\python_embeded\python.exe -c "import torch; v=torch.__version__.split(chr(43))[0].rsplit(chr(46),1)[0]; c=torch.version.cuda or chr(78); print(v,c,sep=chr(124))" 2^>nul') do (
    set "TORCH_VERSION=%%a"
    set "CUDA_VERSION=%%b"
)

if "%TORCH_VERSION%"=="2.7" if "%CUDA_VERSION%"=="12.8" (
    ..\python_embeded\python.exe -s -m pip install --upgrade torch==2.7.1 torchvision==0.22.1 torchaudio==2.7.1 --index-url https://download.pytorch.org/whl/cu128 -r ../ComfyUI/requirements.txt pygit2 %PIPargs%
    goto :DONE
)
if "%TORCH_VERSION%"=="2.8" if "%CUDA_VERSION%"=="12.8" (
    ..\python_embeded\python.exe -s -m pip install --upgrade torch==2.8.0 torchvision==0.23.0 torchaudio==2.8.0 --index-url https://download.pytorch.org/whl/cu128 -r ../ComfyUI/requirements.txt pygit2 %PIPargs%
    goto :DONE
)
if "%TORCH_VERSION%"=="2.9" if "%CUDA_VERSION%"=="13.0" (
    ..\python_embeded\python.exe -s -m pip install --upgrade torch==2.9.1 torchvision==0.24.1 torchaudio==2.9.1 --index-url https://download.pytorch.org/whl/cu130 -r ../ComfyUI/requirements.txt pygit2 %PIPargs%
    goto :DONE
)
if "%TORCH_VERSION%"=="2.10" if "%CUDA_VERSION%"=="13.0" (
    ..\python_embeded\python.exe -s -m pip install --upgrade torch==2.10.0 torchvision==0.25.0 torchaudio==2.10.0 --index-url https://download.pytorch.org/whl/cu130 -r ../ComfyUI/requirements.txt pygit2 %PIPargs%
    goto :DONE
)

echo Could not detect a supported Torch/CUDA pair. Updating ComfyUI python dependencies only.
..\python_embeded\python.exe -s -m pip install --upgrade -r ../ComfyUI/requirements.txt pygit2 %PIPargs%

:DONE
pause
