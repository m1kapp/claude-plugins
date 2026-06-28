#!/bin/bash
# usage-report: cleanupPeriodDays 보정 + ccusage 집계 + 원화 가성비 보고서 생성/오픈
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
SETTINGS="$HOME/.claude/settings.json"
OUT="${USAGE_REPORT_OUT:-$HOME/claude-usage-report.html}"  # 환경변수로 변경 가능
PLAN="${1:-$(cat "$HOME/.usage-report-plan" 2>/dev/null || echo 200)}"   # 종목($/월): 인자 > 저장된 종목 > 200
DAYS="${2:-365}"   # cleanupPeriodDays 목표값 (기본 1년)
KRWRATE="${USAGE_REPORT_KRW:-1500}"  # 환율(₩/$) 환경변수로 변경 가능

# 신원 = Claude 계정 UUID(~/.claude.json) 의 sha256 해시. (원문 비노출, 깃헙/기기 바꿔도 동일)
# 허수 방지: 오직 자신의 Claude 연결 세션으로만 제출 가능 — 폴백(이메일/기기 UUID) 없음.
# Claude 로그인이 없으면 빈 id → 리더보드 제출은 불가(로컬 리포트는 그대로 생성됨).
export USAGE_REPORT_ID="$(python3 - <<'PY'
import json, hashlib, os
home = os.path.expanduser("~")
try:
    d = json.load(open(os.path.join(home, ".claude.json")))
    acc = (d.get("oauthAccount") or {}).get("accountUuid")
    if acc:
        print("claude_" + hashlib.sha256(acc.encode()).hexdigest()[:32])
except Exception:
    pass
PY
)"

# OS별 열기 명령
opener() {
  if   command -v open     >/dev/null 2>&1; then open "$1"
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$1"
  elif command -v start    >/dev/null 2>&1; then start "$1"
  else echo "  (브라우저로 직접 여세요: $1)"; fi
}

# 1) 트랜스크립트 보존 기간을 1년으로 보정(idempotent)
if [ -f "$SETTINGS" ]; then
  python3 - "$SETTINGS" "$DAYS" <<'PY'
import json,sys
p,days=sys.argv[1],int(sys.argv[2])
s=open(p).read()
try: cur=json.loads(s).get("cleanupPeriodDays")
except Exception: cur="(파싱불가)"
if cur==days:
    print(f"보존기간 이미 {days}일")
else:
    import json as j; d=j.loads(s); d["cleanupPeriodDays"]=days
    open(p,"w").write(j.dumps(d,ensure_ascii=False,indent=2))
    print(f"보존기간 {cur} -> {days}일 적용")
PY
fi

# 2) ccusage 집계
echo "ccusage 집계 중..."
npx ccusage@latest --json > /tmp/ccusage.json 2>/dev/null

# 2.5) RTK 토큰 절감(설치돼 있으면) 역추적 집계
RTK_JSON=""
if command -v rtk >/dev/null 2>&1; then
  if rtk gain -f json -m > /tmp/rtk_gain.json 2>/dev/null && [ -s /tmp/rtk_gain.json ]; then
    RTK_JSON=/tmp/rtk_gain.json
    echo "RTK 절감 데이터 감지 → 보고서에 반영"
  fi
fi

# 2.7) 월별 세션 활동 통계
echo "세션 활동 분석 중..."
python3 "$DIR/sess.py" > /tmp/sessions.json 2>/dev/null || echo '{}' > /tmp/sessions.json

# 3) 보고서 생성
python3 "$DIR/build.py" /tmp/ccusage.json "$OUT" "$PLAN" "$KRWRATE" "$RTK_JSON" /tmp/sessions.json

# 4) JSON/HTML 생성 완료 (로컬 HTML은 자동으로 열지 않음 — 제출 후 웹 리포트 /u/<id> 가 열림)
echo "리포트 데이터 생성 완료: $OUT"
