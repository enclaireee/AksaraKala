#!/usr/bin/env bash
# Records one trailer shot with Godot's Movie Maker and encodes it. See video/capture/README.md.
#
#   video/capture/shoot.sh <shot_name> [--preview | --half | --native] [--keep] [--res WxH] [--out PATH]
#
#   (default)  1920x1080 render (canvas_items stretch, 4x)      -> video/out/raw/<shot>.mp4
#   --preview  480x270 render, upscaled 4x nearest to 1080p      -> video/out/raw/<shot>_preview.mp4
#   --half     960x540 render, not upscaled                       -> video/out/raw/<shot>_half.mp4
#   --native   480x270 render, upscaled 4x nearest (final look)   -> video/out/raw/<shot>.mp4
#   --keep     keep the PNG frames and WAV in video/out/tmp/<shot>_<mode>/
#   --set k=v  passes a value to the shot (read it with arg("k", default)); repeatable
#
# Exit status: 0 recorded and encoded; non-zero when the shot failed, Godot printed a SCRIPT ERROR, or the encode failed.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ="$(cd "$HERE/../.." && pwd)"
OUT="$PROJ/video/out"
GODOT="${GODOT:-/tmp/claude-0/-home-user-budayago/cc9c633a-65f6-531b-8fb7-3537ff0bd1e7/scratchpad/godot/Godot_v4.7.2-stable_linux.x86_64}"

SHOT="${1:-}"
[ -z "$SHOT" ] && { sed -n 2,13p "$0"; exit 2; }
shift
MODE=final; RES=1920x1080; SCALE=""; KEEP=0; DEST=""; ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --preview) MODE=preview; RES=480x270; SCALE=4 ;;
    --half)    MODE=half; RES=960x540; SCALE="" ;;
    --native)  MODE=native; RES=480x270; SCALE=4 ;;
    --res)     RES="$2"; MODE="r$2"; shift ;;
    --keep)    KEEP=1 ;;
    --out)     DEST="$2"; shift ;;
    --set)     ARGS+=("--$2"); shift ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
  shift
done
[ -f "$HERE/shots/$SHOT.gd" ] || { echo "no shot script $HERE/shots/$SHOT.gd" >&2; exit 2; }
command -v "$GODOT" >/dev/null || [ -x "$GODOT" ] || { echo "GODOT not found: $GODOT" >&2; exit 2; }

case "$MODE" in
  final|native) SUFFIX="" ;;
  *) SUFFIX="_$MODE" ;;
esac
[ -z "$DEST" ] && DEST="$OUT/raw/${SHOT}${SUFFIX}.mp4"
TMP="$OUT/tmp/${SHOT}_${MODE}"
LOG="${DEST%.mp4}.log"
rm -rf "$TMP"; mkdir -p "$TMP" "$OUT/raw" "$(dirname "$DEST")"

# Movie Maker sizes the movie from project.godot's window_*_override (1440x810), ignoring --resolution, and
# resamples every frame to it. The game is run from a shadow project: symlinks to every entry of the repo plus
# an override.cfg with the wanted size. Nothing in the repo changes.
SHADOW="$OUT/shadow/$RES${OVR_TAG:+_$OVR_TAG}"
mkdir -p "$SHADOW"
for f in $(ls -A "$PROJ"); do
  [ "$f" = ".git" ] && continue
  [ -e "$SHADOW/$f" ] || ln -sfn "$PROJ/$f" "$SHADOW/$f"
done
printf '[display]\nwindow/size/window_width_override=%s\nwindow/size/window_height_override=%s\n' "${RES%x*}" "${RES#*x}" > "$SHADOW/override.cfg.tmp.$$"
[ -n "${OVERRIDE_EXTRA:-}" ] && printf '%b\n' "$OVERRIDE_EXTRA" >> "$SHADOW/override.cfg.tmp.$$"
mv -f "$SHADOW/override.cfg.tmp.$$" "$SHADOW/override.cfg"

# Game user data (settings, saves) in a throwaway folder: the player's real save is never touched.
export XDG_DATA_HOME="$TMP/userdata"
mkdir -p "$XDG_DATA_HOME"

echo "[shoot] $SHOT  mode=$MODE  render=$RES  -> $DEST"
T0=$(date +%s)
set +e
xvfb-run -a -s "-screen 0 1920x1080x24" \
  "$GODOT" --path "$SHADOW" --rendering-driver "${RDRIVER:-opengl3}" --audio-driver Dummy \
  --resolution "$RES" --fixed-fps 60 --write-movie "$TMP/f.png" \
  -s res://video/capture/runner.gd -- --shot="$SHOT" ${ARGS[@]+"${ARGS[@]}"} >"$LOG" 2>&1
CODE=$?
set -e
T1=$(date +%s)

grep -q "recording movie in ${RES%x*}.*${RES#*x} @" "$LOG" || { echo "[shoot] Movie Maker did not record at $RES:" >&2; grep "recording movie" "$LOG" >&2; exit 1; }
# Loud failure: exit code, shot failure, any script error.
BAD=0
grep -n "@@SHOT FAIL" "$LOG" && BAD=1
grep -n -A3 "SCRIPT ERROR\|Parse Error\|Failed to load script" "$LOG" && BAD=1
grep -q "@@SHOT done" "$LOG" || BAD=1
if [ $CODE -ne 0 ] || [ $BAD -ne 0 ]; then
  echo "[shoot] FAILED (godot exit $CODE). Log: $LOG" >&2
  grep -v "^ALSA\|^$" "$LOG" | tail -25 >&2
  [ $KEEP -eq 1 ] || rm -rf "$TMP"
  exit 1
fi

NFR=$(ls "$TMP" | grep -c '^f[0-9]*\.png$' || true)
START=$(grep -o '@@SHOT rec_start [0-9]*' "$LOG" | tail -1 | awk '{print $3}')
STOP=$(grep -o '@@SHOT rec_stop [0-9]*' "$LOG" | tail -1 | awk '{print $3}')
START=${START:-0}
STOP=${STOP:-$NFR}
[ "$STOP" -gt "$NFR" ] && STOP=$NFR
N=$((STOP - START))
[ $N -le 0 ] && { echo "[shoot] nothing recorded (start $START stop $STOP of $NFR frames)" >&2; exit 1; }
SECS=$(awk "BEGIN{print $N/60}")
echo "[shoot] rendered $NFR frames in $((T1 - T0)) s ($(awk "BEGIN{printf \"%.1f\", $NFR/60/($T1-$T0+0.001)*100}")% of real time); keeping frames $START..$((STOP - 1)) ($SECS s)"

VF="format=yuv420p"
[ -n "$SCALE" ] && VF="scale=iw*$SCALE:ih*$SCALE:flags=neighbor,$VF"
AST=$(awk "BEGIN{printf \"%.6f\", $START/60}")
ADUR=$(awk "BEGIN{printf \"%.6f\", $N/60}")
ffmpeg -hide_banner -loglevel error -y \
  -framerate 60 -start_number "$START" -i "$TMP/f%08d.png" \
  -i "$TMP/f.wav" \
  -frames:v "$N" -vf "$VF" -c:v libx264 -preset slow -crf 10 -tune animation -r 60 \
  -af "atrim=start=$AST:duration=$ADUR,asetpts=PTS-STARTPTS" -c:a aac -b:a 320k -ar 48000 \
  -movflags +faststart "$DEST"
echo "[shoot] wrote $DEST ($(du -h "$DEST" | cut -f1)); encode $(( $(date +%s) - T1 )) s"
# Marks for the edit, relative to the first kept frame.
grep -o '@@SHOT mark .*' "$LOG" | sed 's/@@SHOT mark /[mark] frame /' || true
if [ $KEEP -eq 0 ]; then rm -rf "$TMP"; else echo "[shoot] frames kept in $TMP"; fi
