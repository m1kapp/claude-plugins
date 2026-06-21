---
description: Claude Code 사용량을 원화 가성비 보고서(월 탭 + 가격/질적 위젯 HTML)로 뽑고, 트랜스크립트 보존기간(cleanupPeriodDays)을 1년으로 보정한다. ccusage 기반. Usage - /usage-report [월구독USD]. 예) /usage-report (기본 $200), /usage-report 100. "사용량 보고서", "구독 가성비", "얼마나 썼나" 요청 시 사용.
disable-model-invocation: false
allowed-tools: Bash(*)
arguments:
  - plan_usd
---

## 목적

월 정액 구독($200 Max 20x 등) 대비 **실제로 API 정가로 환산하면 얼마치를 썼는지**를
월 탭 + (💰가격 / 📊질적) 위젯 HTML 보고서로 보여준다. 질적 위젯은 일별/세션/효율/시간대/커밋
필터칩으로 전환된다. 동시에 클로드코드의 트랜스크립트 자동삭제 설정
(`cleanupPeriodDays`, 미설정 시 기본 30일 → 과거 기록 소실)을 **365일(1년)로 보정**한다.

## 실행

플러그인 설치/개인 설치 양쪽 대응. 다음을 실행한다(존재하는 경로 사용):

```bash
S="${CLAUDE_PLUGIN_ROOT:+$CLAUDE_PLUGIN_ROOT/skills/usage-report/run.sh}"
[ -f "$S" ] || S="$HOME/.claude/skills/usage-report/run.sh"
bash "$S" "$0"
```

(`$0` = 월 구독 비용 USD. 비어 있으면 기본 200.)

스크립트가 하는 일:
1. `~/.claude/settings.json`의 `cleanupPeriodDays`를 365로 보정(이미 365면 건너뜀).
2. `npx ccusage --json`으로 로컬 사용량 집계.
3. `sess.py`로 트랜스크립트에서 세션·효율·시간대·커밋 통계 추출.
4. `build.py`로 **Claude 모델만** 월별 합산 → 원화(₩1,500/$) 보고서를
   `~/claude-usage-report.html`(환경변수 `USAGE_REPORT_OUT`로 변경 가능)에 생성.
5. 브라우저로 자동 오픈.

## 환경변수(선택)

- `USAGE_REPORT_KRW` (기본 1500): 원화 환산 환율(₩/$)
- `USAGE_REPORT_OUT` (기본 ~/claude-usage-report.html): 출력 경로
- `USAGE_REPORT_TZ` (기본 9): 시간대 오프셋(시간). 시간대 뷰가 이 기준으로 집계됨(KST=9)

## 결과 안내 시 유의

- 금액은 "같은 양을 API 정가로 썼다면"의 **가상 환산값**이며 실제 청구액(정액)이 아님을 명시한다.
- 보존기간 보정은 **앞으로 생기는 기록만** 보존한다(이미 삭제된 과거는 복구 불가).
- 비-Claude(codex/openclaw 등) 사용분은 구독 가성비 계산에서 제외된다.
- 커밋 수는 세션 중 친 `git commit` 횟수라 스쿼시 머지와 무관(실패 커밋 일부 포함 근사).
