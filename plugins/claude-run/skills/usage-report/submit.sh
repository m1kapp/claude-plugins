#!/bin/bash
# 랭킹 제출. 사용: bash submit.sh [닉네임] [endpoint]
# 닉네임을 명시하면 ~/.usage-report-nick에 저장하고, 다음부턴 생략해도 같은 이름으로 올라감.
# (계정/기기 고정 — 리포트의 익명 ID로 중복 갱신)
set -e
NICK_FILE="$HOME/.usage-report-nick"
NICK="$1"
ENDPOINT="${2:-${USAGE_REPORT_ENDPOINT:-https://clauderank.m1k.app}}"
JSON_OUT="${USAGE_REPORT_OUT:-$HOME/claude-usage-report.html}"; JSON_OUT="${JSON_OUT%.html}.json"

# 닉네임 결정: 인자(수동 변경) → 저장된 닉 → 이메일 앞부분(자동) → git 이름 → whoami
# 대부분은 자동(이메일 @앞). 바꾸고 싶은 사람만 인자로 주면 저장돼서 고정됨.
if [ -n "$NICK" ]; then
  printf '%s' "$NICK" > "$NICK_FILE"
else
  NICK="$(cat "$NICK_FILE" 2>/dev/null)"
  if [ -z "$NICK" ]; then
    NICK="$(python3 - <<'PY'
import json, os
try:
    oa = (json.load(open(os.path.expanduser("~/.claude.json"))).get("oauthAccount") or {})
    e = oa.get("emailAddress") or ""
    print(e.split("@")[0] if "@" in e else "")
except Exception:
    print("")
PY
)"
  fi
  [ -z "$NICK" ] && NICK="$(git config user.name 2>/dev/null || whoami)"
fi
if [ -z "$NICK" ]; then echo "닉네임을 주세요: bash submit.sh <닉네임>"; exit 1; fi
if [ ! -f "$JSON_OUT" ]; then echo "리포트 JSON이 없습니다($JSON_OUT). 먼저 /claude-run 실행."; exit 1; fi

# 허수 방지: 오직 자신의 Claude 연결 세션(claude_ id)으로만 제출 가능
RID="$(python3 -c "import json,sys;print(json.load(open('$JSON_OUT')).get('id',''))" 2>/dev/null)"
case "$RID" in
  claude_*) : ;;
  *) echo "⚠️ Claude 계정 세션이 필요해요. Claude Code에 로그인된 상태에서 /claude-run 으로 다시 실행하세요."; exit 1 ;;
esac

echo "제출: $NICK → $ENDPOINT  (리포트: $JSON_OUT)"
RESP=$(NICK="$NICK" JSON_OUT="$JSON_OUT" python3 -c 'import json,os;print(json.dumps({"nick":os.environ["NICK"],"report":json.load(open(os.environ["JSON_OUT"]))}))' \
  | curl -s -X POST "$ENDPOINT/api/submit" -H "Content-Type: application/json" -d @-)
printf '%s' "$RESP" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    if d.get('ok'):
        e = d['entry']
        print(f\"✅ 합류 완료! 본전배율 {e['ratio']}× · 채팅 {e['chats']:,}\")
    else:
        print('⚠️ ' + str(d.get('error', '제출 실패')))
except Exception:
    print('⚠️ 응답 파싱 실패 — 엔드포인트 확인: $ENDPOINT')
"

# 개인 리포트 URL — 출력 + 브라우저로 열기 (내 리포트 보러가기)
EID=$(printf '%s' "$RESP" | python3 -c "import json,sys
try: print(json.load(sys.stdin).get('entry',{}).get('id',''))
except Exception: print('')" 2>/dev/null)
if [ -n "$EID" ]; then
  MYURL="$ENDPOINT/u/$EID"
  echo "🔗 내 리포트: $MYURL"
  echo "🏃 같이 달리기: $ENDPOINT"
  if   command -v open     >/dev/null 2>&1; then open "$MYURL"     >/dev/null 2>&1 || true
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$MYURL" >/dev/null 2>&1 || true
  elif command -v start    >/dev/null 2>&1; then start "$MYURL"    >/dev/null 2>&1 || true
  fi
fi
