# m1kapp/claude-plugins

m1kapp의 Claude Code 플러그인 마켓플레이스. `/plugin` 명령으로 한 번에 설치해서 씁니다.

```
/plugin marketplace add m1kapp/claude-plugins
/plugin install usage-report@m1kapp
```

> 설치 후 `/reload-plugins` 한 번. 그 다음 `/usage-report` 로 실행.

---

## 📦 플러그인

### `usage-report` — Claude Code 구독 가성비 보고서

Claude Code를 월 정액 구독($200 Max 20x 등)으로 쓰면서 **"실제로 API 정가로 환산하면 얼마치를 썼나 = 구독으로 얼마나 본전 뽑았나"** 가 궁금할 때. 한 줄로 원화 가성비 보고서(월별 위젯 + 일별 막대그래프 HTML)를 뽑아줍니다.

| 보는 것 | 예시 |
|---|---|
| 월별 정가 환산액 | `2026년 6월 ₩2,240만` |
| 구독 대비 본전 배율 | `75×` |
| 모델 구성 / 일별 추이 | opus-4-8 90%, 6/3 최고 ₩237만 |

동시에 클로드코드의 **트랜스크립트 자동삭제 설정(`cleanupPeriodDays`, 기본 30일)을 1년으로 보정**해서, 과거 사용기록이 30일마다 지워지는 걸 막아줍니다.

#### 사용법

```
/usage-report          # 기본 $200/월(Max 20x) 기준
/usage-report 100      # 구독료 $100로 계산
```

보고서는 `~/claude-usage-report.html`에 생성되고 브라우저로 자동으로 열립니다.

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
