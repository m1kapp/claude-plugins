---
description: 내 Claude 사용량을 가성비 랭킹(clauderank.m1k.app)에 갱신한다. 최신 데이터로 매번 그냥 덮어쓰는 단일 명령 — 별도 리포트 생성 단계 없음. 닉네임은 한 번 정하면 계정에 고정. Usage - /claude-run [닉네임]. "랭킹 등록", "랭크 올려", "내 기록 갱신", "얼마나 썼나" 요청 시 사용.
disable-model-invocation: false
allowed-tools: Bash(*)
arguments:
  - nickname
---

## 목적

내 사용량을 **최신으로 생성 + 랭킹에 갱신**까지 한 번에. (별도 리포트 단계 없이 항상 이 한 명령.)
**추가 확인 없이 바로 갱신한다**(이 명령을 부른 것 자체가 동의 · 무조건 올리는 방향).

## 실행

```bash
RP="${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/usage-report}"
[ -d "$RP" ] || RP="$HOME/.claude/skills/usage-report"
bash "$RP/run.sh"            # 최신 사용량 데이터 생성(JSON) + 보존기간 보정 (로컬 HTML 자동열기 없음)
bash "$RP/submit.sh" "$0"    # 랭킹 갱신 + 내 웹 리포트 자동 열림 ($0=닉네임, 생략 시 저장된 닉)
```

- `$0`(닉네임)을 주면 `~/.usage-report-nick`에 저장되어 **다음부턴 생략해도 같은 이름**으로 올라간다.
- 신원은 **내 Claude 계정**(`~/.claude.json` 계정 UUID 해시) 기준 — 깃헙/기기 바꿔도 **한 줄로 갱신**(중복·허수 방지). Claude 로그인이 없으면 제출이 거부된다.

## 안내

- 출력의 "✅ 합류 완료! 본전배율 N×", "🔗 내 리포트", "🏃 같이 달리기" 링크를 사용자에게 전달한다(제출 성공 시 내 리포트가 브라우저로 자동 열림).
- 닉네임이 처음이라 비어 있으면 git 사용자명/whoami로 자동 등록되니, 원하는 이름이 있으면 `/claude-run <닉네임>`으로 한 번 지정하라고 안내한다.
- 랭킹에서 빠지려면 **`/claude-run-out`** 로 본인 기록을 삭제할 수 있다고 안내한다.
