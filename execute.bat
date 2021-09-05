@echo off
cd %~dp0

setlocal ENABLEDELAYEDEXPANSION

set BEFORE_STRING=.png
set ORIGINAL_STRING=_o.png
set MASK_STRING=_mask.png

set currentDir=%~dp0
set srcDir=src\

set XAPI_KEY=

@REM 画像のリサイズとマスク処理
for %%f in (./src/*.png) do (
  set filepath=%currentDir%%srcDir%%%f
  echo !filepath!
  set original=!filepath:%BEFORE_STRING%=%ORIGINAL_STRING%!
  echo !original!
  set maskPath=!filepath:%BEFORE_STRING%=%MASK_STRING%!
  echo !maskPath!

  copy !filepath! !original!
  curl -H "X-API-Key: !XAPI_KEY!" -F "image_file=@!filepath!" -f https://api.remove.bg/v1.0/removebg -o !filepath!
  magick !filepath! -gravity center -background none -extent 820x820 !filepath!
  magick !filepath! -channel RGBA -separate +channel %\% -evaluate-sequence add -threshold 0 !maskPath!
)

endlocal

@REM obj作成
python ./apps/eval.py --name pifu_demo --batch_size 1 --mlp_dim 257 1024 512 256 128 1 --mlp_dim_color 513 1024 512 256 128 3 --num_stack 4 --num_hourglass 2 --resolution 256 --hg_down ave_pool --norm group --norm_color group --test_folder_path ./src --load_netG_checkpoint_path ./checkpoints/net_G --load_netC_checkpoint_path ./checkpoints/net_C --gpu_id 0

@REM ファイルの移動
If not Exist .\src\tmp mkdir .\src\tmp
for %%f in (./src/*.png) do (
  echo %%f
  move .\src\%%f .\src\tmp\%%f
)

@REM obj -> plyへの変換
python scripts/Convert/MeshConvert.py

pause
exit 0
