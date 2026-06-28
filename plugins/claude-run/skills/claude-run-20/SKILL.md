---
description: $20 종목(20m · Pro)으로 가성비 랭킹에 출전·갱신한다. 20m 달리기 🏃. 플랜을 $20로 지정·저장하고 최신 데이터로 올린다. 닉네임은 처음 한 번만. Usage - /claude-run-20 [닉네임]. "20달러로 등록", "20m로 달려" 요청 시 사용.
disable-model-invocation: false
allowed-tools: Bash(*)
arguments:
  - nickname
---

## 목적

**$20 종목(20m 달리기)**으로 출전 — 구독 플랜을 $20/월로 **지정·저장**하고 최신 사용량으로 랭킹을 갱신한다.
한 번 출전하면 이후엔 그냥 **`/claude-run`** 만 쳐도 저장된 종목($20)으로 갱신된다.

## 실행

```bash
RP="${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/usage-report}"
[ -d "$RP" ] || RP="$HOME/.claude/skills/usage-report"
echo 20 > "$HOME/.usage-report-plan"   # 종목($20) 저장
bash "$RP/run.sh" 20                   # $20 기준 최신 데이터 생성
bash "$RP/submit.sh" "$0"             # 갱신 + 내 웹 리포트 자동 열림 ($0=닉네임)
```

## 안내

- 출력의 "✅ 합류 완료! 본전배율 N×", "🔗 내 리포트", "🏃 같이 달리기"를 전달한다.
- 다음부턴 **`/claude-run`** 한 줄이면 $20 종목으로 자동 갱신.
- 랭킹에서 빠지려면 **`/claude-run-out`**.
