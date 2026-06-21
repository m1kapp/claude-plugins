#!/bin/bash
# 랭킹 제출. 사용: bash submit.sh [닉네임] [endpoint]
# 닉네임을 명시하면 ~/.usage-report-nick에 저장하고, 다음부턴 생략해도 같은 이름으로 올라감.
# (계정/기기 고정 — 리포트의 익명 ID로 중복 갱신)
set -e
NICK_FILE="$HOME/.usage-report-nick"
NICK="$1"
ENDPOINT="${2:-${USAGE_REPORT_ENDPOINT:-https://clauderank.m1k.app}}"
JSON_OUT="${USAGE_REPORT_OUT:-$HOME/claude-usage-report.html}"; JSON_OUT="${JSON_OUT%.html}.json"

# 닉네임 결정: 인자 → 저장된 닉 → git 이름 → whoami
if [ -n "$NICK" ]; then
  printf '%s' "$NICK" > "$NICK_FILE"
else
  NICK="$(cat "$NICK_FILE" 2>/dev/null)"
  [ -z "$NICK" ] && NICK="$(git config user.name 2>/dev/null || whoami)"
fi
if [ -z "$NICK" ]; then echo "닉네임을 주세요: bash submit.sh <닉네임>"; exit 1; fi
if [ ! -f "$JSON_OUT" ]; then echo "리포트 JSON이 없습니다($JSON_OUT). 먼저 /usage-report 실행."; exit 1; fi

echo "제출: $NICK → $ENDPOINT  (리포트: $JSON_OUT)"
RESP=$(NICK="$NICK" JSON_OUT="$JSON_OUT" python3 -c 'import json,os;print(json.dumps({"nick":os.environ["NICK"],"report":json.load(open(os.environ["JSON_OUT"]))}))' \
  | curl -s -X POST "$ENDPOINT/api/submit" -H "Content-Type: application/json" -d @-)
printf '%s' "$RESP" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    if d.get('ok'):
        e = d['entry']
        print(f\"✅ 등록 완료! 본전배율 {e['ratio']}× · 채팅 {e['chats']:,} · {'$ENDPOINT'}\")
    else:
        print('⚠️ ' + str(d.get('error', '제출 실패')))
except Exception:
    print('⚠️ 응답 파싱 실패 — 엔드포인트 확인: $ENDPOINT')
"
