---
description: Claude 사용량 리포트를 만들고 곧바로 가성비 랭킹(clauderank.m1k.app)에 등록한다. 닉네임은 한 번 정하면 계정에 고정 저장돼 매번 같은 이름으로 올라간다. Usage - /usage-rank [닉네임]. "랭킹 등록", "랭크 올려", "내 기록 올려" 요청 시 사용.
disable-model-invocation: false
allowed-tools: Bash(*)
arguments:
  - nickname
---

## 목적

`/usage-report`(리포트 생성)와 달리, **리포트 생성 + 랭킹 등록까지 한 번에** 한다.
랭킹 등록이 이 명령의 목적이므로 **추가 확인 없이 바로 올린다**(사용자가 이 명령을 부른 것 자체가 동의).

## 실행

usage-report 스킬의 스크립트를 재사용한다. 다음을 실행한다:

```bash
RP="${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/usage-report}"
[ -d "$RP" ] || RP="$HOME/.claude/skills/usage-report"
bash "$RP/run.sh"            # 리포트(HTML+JSON) 생성 + 보존기간 보정
bash "$RP/submit.sh" "$0"    # 랭킹 등록 ($0=닉네임, 생략 시 저장된 닉/ git 이름 사용)
```

- `$0`(닉네임)을 주면 `~/.usage-report-nick`에 저장되어 **다음부턴 생략해도 같은 이름**으로 올라간다.
- 같은 기기는 리포트의 익명 ID로 **중복 갱신**(새 줄 안 쌓임).

## 안내

- 출력의 "✅ 등록 완료! 본전배율 N×"와 랭킹 주소(clauderank.m1k.app)를 사용자에게 전달한다.
- 닉네임이 처음이라 비어 있으면 git 사용자명/whoami로 자동 등록되니, 원하는 이름이 있으면 `/usage-rank <닉네임>`으로 한 번 지정하라고 안내한다.
