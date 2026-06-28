# m1kapp/claude-plugins

m1kapp의 Claude Code 플러그인 마켓플레이스. `/plugin` 명령으로 한 번에 설치해서 씁니다.

```
/plugin marketplace add m1kapp/claude-plugins
/plugin install claude-run@m1kapp
```

> 설치 후 `/reload-plugins` 한 번. 그 다음 `/claude-run` 으로 랭킹에 합류.

---

## 📦 플러그인

### `claude-run` — 같이 달리는 구독 가성비 랭킹

Claude Code 구독을 **"API 정가로 환산하면 몇 배 뽑았나(본전배율)"** 로 환산해, 모두의 기록을 모아보는 랭킹([clauderun.m1k.app](https://clauderun.m1k.app))에 한 줄로 합류합니다.

| 보는 것 | 예시 |
|---|---|
| 월별 정가 환산액 | `2026년 6월 ₩3,000만` |
| 구독 대비 본전 배율 | `100×` |
| 개발자 프로필(누적) | 🦉 심야형 스프린터 · 캐시 장인 98% |

신원은 **내 Claude 계정 기준**(계정 UUID 해시)이라, 깃헙·기기를 바꿔도 한 줄로 갱신되고 **중복·허수가 안 들어갑니다**. 동시에 트랜스크립트 자동삭제 설정(`cleanupPeriodDays`, 기본 30일)을 **1년으로 보정**해 과거 기록을 보존합니다.

#### 사용법

```
/claude-run            # 최신 사용량으로 랭킹 갱신 (닉네임은 처음 한 번만)
/claude-run 닉네임      # 닉네임 지정/변경
/claude-run-out        # 랭킹에서 내 기록만 삭제
```

제출하면 **내 리포트(`clauderun.m1k.app/u/<id>`)가 브라우저로 자동으로 열립니다.**

#### 환경변수 (선택)

| 변수 | 기본 | 설명 |
|---|---|---|
| `USAGE_REPORT_KRW` | `1500` | 원화 환산 환율(₩/$) |
| `USAGE_REPORT_OUT` | `~/claude-usage-report.html` | 출력 경로 |

---

## ✅ 필요 조건

- **Claude Code** (플러그인 지원 버전)
- **python3** — 보고서 생성
- **node / npx** — [ccusage](https://github.com/ryoppippi/ccusage)가 자동 설치되어 로컬 사용량을 읽음

별도 API 키·계정 연동 불필요. ccusage가 각자의 `~/.claude` 로컬 기록만 읽으므로, **설치한 사람마다 자기 사용량 보고서**가 나옵니다.

---

## ❓ 자주 묻는 질문

**Q. 금액이 실제 청구액인가요?**
아니요. "같은 양을 **API 정가로 썼다면**"의 가상 환산값입니다. 구독제 실제 청구는 월 정액 그대로이고, 이 수치는 "구독이 얼마나 이득이었나"를 보여주는 용도입니다.

**Q. 클로드코드 Stats 화면의 토큰 수랑 다른데요?**
Stats는 cache read를 축약/제외한 집계라 작게 보입니다. 실제 API에 흐른 토큰은 cache read가 대부분(98%)이라, ccusage 기준이 훨씬 큽니다.

**Q. 몇 달 전 기록이 안 보여요.**
`cleanupPeriodDays`(기본 30일)로 이미 삭제된 과거는 복구 불가입니다. 이 플러그인이 설정을 1년으로 바꿔주므로 **지금부터 생기는 기록**은 보존됩니다.

**Q. codex 등 다른 도구 사용량도 잡히나요?**
ccusage는 잡지만, 이 보고서는 **Claude 모델만** 집계합니다(구독 가성비가 목적이므로).

---

## 🔧 마켓플레이스 관리 (기여자용)

새 플러그인 추가:
1. `plugins/<이름>/.claude-plugin/plugin.json` + 컴포넌트(`skills/`, `commands/` 등) 추가
2. `.claude-plugin/marketplace.json`의 `plugins` 배열에 항목 추가
3. `git push`

기존 사용자는 `/plugin marketplace update m1kapp` 로 갱신받습니다.
플러그인 수정 배포 시 `plugin.json`의 `version`을 올려야 사용자에게 업데이트가 노출됩니다.

---

## 라이선스

MIT © m1kapp
