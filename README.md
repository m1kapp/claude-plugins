# m1kapp/claude-plugins

m1kapp의 Claude Code 플러그인 마켓플레이스.

## 설치

```
/plugin marketplace add m1kapp/claude-plugins
/plugin install usage-report@m1kapp
```

설치 후 `/usage-report` 로 실행.

## 플러그인

### usage-report
Claude Code 사용량([ccusage](https://github.com/ryoppippi/ccusage) 기반)을 읽어
월 정액 구독 대비 **API 정가로 환산하면 얼마치를 썼는지**를 원화 월별 위젯 HTML
보고서(월 카드 + 일별 막대그래프)로 뽑아준다. 동시에 트랜스크립트 자동삭제 설정
(`cleanupPeriodDays`)을 1년으로 보정한다.

```
/usage-report          # 기본 $200/월(Max 20x) 기준
/usage-report 100      # 구독료 $100로 계산
```

> 금액은 "같은 양을 API 정가로 썼다면"의 가상 환산값이며, 구독 실제 청구는 정액이다.

## 라이선스

MIT
