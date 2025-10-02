#!/usr/bin/env bash
set -euo pipefail

# Quick builder for this Theos tweak project
# Usage examples:
#   ./build.sh                 # rootful (default)
#   ./build.sh --rootless      # rootless packaging
#   ./build.sh --clean         # clean only
#   THEOS=~/theos ./build.sh   # specify THEOS via env

# Parse options (GNU getopt may not be available everywhere; use a simple parser)
ROOTLESS=0
CLEAN_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --rootless)
      ROOTLESS=1
      shift
      ;;
    --rootful)
      ROOTLESS=0
      shift
      ;;
    --sideloaded|--trollstore)
      echo -e "\033[1m\033[31m当前项目为 Theos 越狱 Tweak，不支持 $1 打包模式（需要 App 注入与 IPA 工具链）。\033[0m" >&2
      exit 2
      ;;
    --clean)
      CLEAN_ONLY=1
      shift
      ;;
    --help|-h)
      cat <<'USAGE'
用法: build.sh [--rootless|--rootful] [--clean]
  --rootless  使用 THEOS_PACKAGE_SCHEME=rootless 进行打包
  --rootful   传统越狱（默认）
  --clean     仅清理构建产物
环境变量:
  THEOS       指定 Theos 路径，如未设置将由环境与 make 自动解析
USAGE
      exit 0
      ;;
    *)
      echo "未知参数: $1" >&2
      exit 1
      ;;
  esac
done

# Ensure THEOS env if provided is exported
if [[ -n "${THEOS:-}" ]]; then
  export THEOS
  echo "THEOS=${THEOS}"
fi

# Functions
log_ok()   { echo -e "\033[1m\033[32m$*\033[0m"; }
log_info() { echo -e "\033[1m$*\033[0m"; }
log_err()  { echo -e "\033[1m\033[31m$*\033[0m" >&2; }

log_info "开始构建 GTWeibo 项目..."

log_info "清理项目..."
make clean || true
rm -rf .theos || true

if [[ $CLEAN_ONLY -eq 1 ]]; then
  log_ok "已完成清理。"
  exit 0
fi

if [[ $ROOTLESS -eq 1 ]]; then
  log_info "使用 Rootless 打包 (THEOS_PACKAGE_SCHEME=rootless)"
  export THEOS_PACKAGE_SCHEME=rootless
else
  log_info "使用 Rootful 打包 (默认)"
  unset THEOS_PACKAGE_SCHEME || true
fi

# FINALPACKAGE=1 生成发布版，压缩符号，打 deb 包
log_info "执行 make package FINALPACKAGE=1 ..."
if make package FINALPACKAGE=1; then
  log_ok "Make 成功。"
else
  log_err "Make 失败。"
  exit 1
fi

# Collect output
mkdir -p artifacts
shopt -s nullglob
found=0
for f in packages/*.deb; do
  echo "找到包: $f"
  cp -f "$f" artifacts/
  ((found++)) || true
done

if [[ $found -eq 0 ]]; then
  log_err "未找到 .deb 包，请检查构建日志。"
  exit 1
fi

log_ok "完成。产物位于 artifacts/ 目录与 packages/ 目录。"
