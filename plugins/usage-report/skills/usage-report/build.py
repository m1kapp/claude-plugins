#!/usr/bin/env python3
"""ccusage --json -> 간단 원화 월별 가성비 보고서(HTML).
사용: python build.py <ccusage.json> <out.html> [plan_usd] [krw_rate]
Claude 모델만 집계(구독 가성비 기준). 비-Claude(codex 등)는 제외."""
import json, sys
from collections import defaultdict

src   = sys.argv[1]
out   = sys.argv[2]
PLAN  = float(sys.argv[3]) if len(sys.argv) > 3 else 200.0   # $/월 (Max 20x)
KRW   = float(sys.argv[4]) if len(sys.argv) > 4 else 1500.0

d = json.load(open(src))
colors = {"opus-4-8":"#d97757","opus-4-6":"#c15f3c","sonnet-4-6":"#6a9bcc",
          "fable-5":"#8b6db5","haiku-4-5":"#5fa563","opus-4-8-fast":"#b08050",
          "opus-4-6-fast":"#e0a060"}
def color(m): return colors.get(m, "#999")
def short(m): return m.replace("claude-","").replace("-20251001","")
def won(usd):
    man = usd*KRW/1_0000
    return f"{man/10000:.2f}억" if man >= 10000 else f"{man:,.0f}만"

# 월 -> 모델 -> cost, 그리고 월 -> 일 -> {total, models} (claude 모델만)
mm = defaultdict(lambda: defaultdict(float))
dd = defaultdict(lambda: defaultdict(lambda: {"total":0.0, "models":defaultdict(float)}))
for day in d.get("daily", []):
    date  = day["period"]; month = date[:7]
    for b in day.get("modelBreakdowns", []):
        name = b["modelName"]
        if not name.startswith("claude"): continue
        c = b.get("cost", 0); sm = short(name)
        mm[month][sm] += c
        dd[month][date]["total"] += c
        dd[month][date]["models"][sm] += c

months = sorted(m for m in mm if sum(mm[m].values()) >= 0.01)
grand  = sum(sum(mm[m].values()) for m in months)
# 모든 월 공유 세로축 스케일 (최고 사용일 기준)
DMAX = max((x["total"] for m in months for x in dd[m].values()), default=1) or 1

def widget(mo):
    models = mm[mo]; tot = sum(models.values())
    ratio  = tot/PLAN
    stack=""; legend=""
    for m,c in sorted(models.items(), key=lambda x:-x[1]):
        pct = c/tot*100
        if pct < 0.3: continue
        stack  += f'<span style="width:{pct}%;background:{color(m)}"></span>'
        legend += (f'<div class="lr"><span class="dot" style="background:{color(m)}">'
                   f'</span><b>{m}</b><span class="lp">₩{won(c)} · {pct:.0f}%</span></div>')
    # 일별 세로 막대 그래프 (월 전체 일자, 공유 스케일)
    days = sorted(dd[mo])
    bars=""
    for date in days:
        x = dd[mo][date]; h = x["total"]/DMAX*100
        seg=""
        for m,c in sorted(x["models"].items(), key=lambda y:y[1]):  # 작은게 위로
            seg = f'<span style="height:{c/x["total"]*100}%;background:{color(m)}"></span>' + seg
        bars += (f'<div class="col" title="{date} · ₩{won(x["total"])}">'
                 f'<div class="cb" style="height:{h:.1f}%">{seg}</div>'
                 f'<div class="cx">{int(date[8:])}</div></div>')
    peak = max(days, key=lambda dt: dd[mo][dt]["total"])
    chart = (f'<div class="chart">{bars}</div>'
             f'<div class="ccap">일별 정가 환산 · 최고일 {peak[5:]} ₩{won(dd[mo][peak]["total"])}</div>')
    y,mo2 = mo.split("-")
    return f'''<div class="w">
      <div class="wt"><div><div class="wl">{y}년 {int(mo2)}월</div>
        <div class="wb">₩{won(tot)}</div><div class="ws">정가 환산 · {len(days)}일</div></div>
        <div class="wr"><div class="rx">{ratio:.0f}×</div><div class="rl">₩{won(PLAN)} 구독 대비</div></div></div>
      {chart}
      <div class="stk">{stack}</div><div class="lg">{legend}</div>
      <div class="cmp"><div class="c"><span class="ck">실제 지불</span><span class="cv">₩{won(PLAN)}</span></div>
        <span class="ar">→</span><div class="c"><span class="ck">API 정가</span><span class="cv hot">₩{won(tot)}</span></div>
        <span class="ar">=</span><div class="c"><span class="ck">순이득</span><span class="cv good">₩{won(tot-PLAN)}</span></div></div>
    </div>'''

cards = "".join(widget(m) for m in months)
nmon  = len(months)
ratio = grand/(PLAN*nmon) if nmon else 0
html = f'''<!DOCTYPE html><html lang="ko"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>Claude 구독 가성비</title>
<style>
*{{box-sizing:border-box;margin:0;padding:0}}
body{{font-family:-apple-system,'Segoe UI','Apple SD Gothic Neo',sans-serif;background:#f4f1ea;color:#2a2622;padding:30px 16px;line-height:1.5}}
.wrap{{max-width:900px;margin:0 auto}}
h1{{font-family:Georgia,serif;font-size:26px;letter-spacing:-.5px}}
.sub{{color:#7a7268;font-size:13px;margin:6px 0 22px}}
.tot{{background:#2a2622;color:#f4f1ea;border-radius:14px;padding:20px 24px;margin-bottom:22px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:12px}}
.tk{{font-size:12px;color:#9a9389;text-transform:uppercase;letter-spacing:.5px}}
.tv{{font-size:32px;font-weight:800;font-family:Georgia,serif;color:#d97757}}
.tr{{text-align:right}} .tr b{{font-size:22px;color:#5fa563}}
.grid{{display:grid;grid-template-columns:1fr 1fr;gap:16px}}
@media(max-width:680px){{.grid{{grid-template-columns:1fr}}}}
.w{{background:#fff;border:1px solid #e6e0d6;border-radius:16px;padding:20px}}
.wt{{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:13px}}
.wl{{font-size:13px;color:#7a7268;font-family:Georgia,serif}}
.wb{{font-size:30px;font-weight:800;font-family:Georgia,serif;margin:2px 0;letter-spacing:-1px}}
.ws{{font-size:12px;color:#9a9389}} .wr{{text-align:right;flex:none}}
.rx{{font-size:28px;font-weight:800;color:#5fa563;font-family:Georgia,serif;line-height:1}}
.rl{{font-size:11px;color:#9a9389;margin-top:2px}}
.chart{{display:flex;align-items:flex-end;gap:2px;height:120px;padding-top:6px;border-bottom:2px solid #e6e0d6;margin-bottom:6px}}
.col{{flex:1;display:flex;flex-direction:column;justify-content:flex-end;align-items:center;height:100%}}
.cb{{width:76%;display:flex;flex-direction:column;border-radius:3px 3px 0 0;overflow:hidden;min-height:1px}} .cb span{{width:100%}}
.col:hover .cb{{outline:2px solid #2a2622;outline-offset:1px}}
.cx{{font-size:8px;color:#b3aa9c;margin-top:2px;font-variant-numeric:tabular-nums}}
.ccap{{font-size:11px;color:#9a9389;margin-bottom:13px}}
.stk{{display:flex;height:15px;border-radius:8px;overflow:hidden;background:#eee;margin-bottom:13px}} .stk span{{height:100%}}
.lg{{border-top:1px solid #f0ebe2;padding-top:11px;margin-bottom:13px}}
.lr{{display:flex;align-items:center;gap:8px;font-size:13px;margin:5px 0}}
.lr b{{font-weight:600;min-width:108px}} .lp{{color:#9a9389;font-size:12px}}
.dot{{width:10px;height:10px;border-radius:3px;flex:none}}
.cmp{{display:flex;align-items:stretch;gap:8px;flex-wrap:wrap;background:#fbf4ee;border-radius:10px;padding:13px 14px}}
.c{{display:flex;flex-direction:column;justify-content:space-between;min-height:44px}}
.ck{{font-size:11px;color:#9a9389}} .cv{{font-size:15px;font-weight:700;margin-top:auto}}
.cv.hot{{color:#d97757}} .cv.good{{color:#5fa563}} .ar{{color:#c9c0b3;font-weight:700;display:flex;align-items:center}}
.note{{background:#fff;border:1px solid #e6e0d6;border-left:4px solid #d97757;border-radius:10px;padding:14px 18px;font-size:13px;color:#5a534a;margin-top:20px}}
.foot{{text-align:center;color:#9a9389;font-size:11.5px;margin-top:22px}}
</style></head><body><div class="wrap">
<h1>Claude 구독 가성비 보고서</h1>
<p class="sub">ccusage 로컬 데이터 · ₩{KRW:,.0f}/$ 환산 · Max 20x ₩{won(PLAN)}/월 · Claude 모델만 집계</p>
<div class="tot"><div><div class="tk">{nmon}개월 합산 정가 환산</div><div class="tv">₩{won(grand)}</div></div>
  <div class="tr"><div class="tk">구독료 대비 순이득</div><b>₩{won(grand-PLAN*nmon)} · {ratio:.0f}배</b></div></div>
<div class="grid">{cards}</div>
<div class="note">⚠️ 금액은 "같은 양을 API 정가로 썼다면"의 <b>가상 환산값</b>이며 실제 청구는 정액입니다.
로컬 트랜스크립트 보존 기간(<code>cleanupPeriodDays</code>) 내 데이터만 집계됩니다. 비-Claude(codex 등) 사용분 제외.</div>
<div class="foot">막대 색 = 모델 구성 · usage-report 스킬 생성</div>
</div></body></html>'''
open(out, "w").write(html)
print(f"OK  {nmon}개월  정가 ₩{won(grand)}  순이득 ₩{won(grand-PLAN*nmon)}  ({ratio:.0f}배)")
