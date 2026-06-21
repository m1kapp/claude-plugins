---
description: Claude Code 사용량을 원화 가성비 보고서(월 탭 + 가격/질적 5필터 HTML)로 뽑고, 트랜스크립트 보존기간(cleanupPeriodDays)을 1년으로 보정한다. 선택적으로 랭킹 등록. ccusage 기반. Usage - /usage-report [월구독USD]. "사용량 보고서", "구독 가성비", "얼마나 썼나" 요청 시 사용.
disable-model-invocation: false
allowed-tools: Bash(*)
arguments:
  - plan_usd
---

## 목적

월 정액 구독($200 Max 20x 등) 대비 **API 정가로 환산하면 얼마치를 썼는지**를 월 탭 +
(💰가격 / 📊질적 5필터) HTML 보고서로 보여준다. 동시에 트랜스크립트 자동삭제 설정
(`cleanupPeriodDays`, 기본 30일 → 과거 기록 소실)을 **365일로 보정**한다.

## 실행

플러그인/개인 설치 양쪽 대응. 스킬 디렉터리를 잡아 run.sh를 실행한다:

```bash
RP="${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/usage-report}"
[ -d "$RP" ] || RP="$HOME/.claude/skills/usage-report"
bash "$RP/run.sh" "$0"     # $0 = 월 구독 USD(기본 200)
```

1. `~/.claude/settings.json`의 `cleanupPeriodDays`를 365로 보정(이미 365면 스킵).
2. `npx ccusage --json` 집계 → `sess.py`로 세션·효율·시간대·커밋 추출.
3. `build.py`로 **Claude 모델만** 월별 합산 → `~/claude-usage-report.html` + `.json` 생성, 브라우저 오픈.

## 랭킹 제출 (한 번 물어보고)

리포트를 보여준 뒤 **"랭킹(clauderank.m1k.app)에도 올릴까요?" 한 번 물어본다.** 원하면:

```bash
bash "$RP/submit.sh" <닉네임>
```

- 닉네임은 한 번 주면 `~/.usage-report-nick`에 저장돼 다음부턴 생략 가능. 같은 기기는 익명 ID로 갱신.
- **매번 묻지 않고 바로 올리려면 `/usage-rank`** (등록 전용 명령)를 쓰라고 안내한다.

## 결과 안내 시 유의

- 금액은 "같은 양을 API 정가로 썼다면"의 **가상 환산값**이며 실제 청구액(정액)이 아님을 명시한다.
- 보존기간 보정은 **앞으로 생기는 기록만** 보존(이미 삭제된 과거는 복구 불가).
- 비-Claude(codex 등) 사용분은 제외. 커밋 수는 `git commit` 호출 횟수라 스쿼시 머지와 무관(근사).
- 시간대는 KST 기준(환경변수 `USAGE_REPORT_TZ`로 변경). 월별 플랜은 `USAGE_REPORT_PLANS="2026-05=100,2026-06=200"`.
