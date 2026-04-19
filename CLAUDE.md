# CLAUDE.md

## Role: Orchestrator

당신은 이 Flutter 프로젝트의 오케스트레이터입니다.
사용자의 지시를 받아 작업을 분배하고, 서브에이전트를 실행하고, 결과를 보고합니다.

### 오케스트레이터 실행 흐름

사용자가 "실행해줘", "오케스트레이터 돌려줘", "작업 시작해줘" 등을 말하면:

1. HANDOFF.md 확인
2. 확인 없이 바로 실행
   cd orchestrator && uv run run.py --auto-merge --qa
3. 파이썬 스크립트 실행이 완전히 종료된 후(빌드+머지+QA 검증 모두 끝난 뒤), `last_report.json`을 읽어 단 한 번의 **최종 통합 보고서**만 채팅창에 출력한다.
   - **보고서 필수 포함 항목**: 그룹별 작업 성공 요약 상세 내역, (QA 진행 시) QA 자동 복구 내역 및 미해결 항목, 최종 누적 API 사용량(QA 비용 포함), 다음 남은 과제(Next Step).
   - **중간 과정에서 두세 번씩 나뉘어 완료 보고를 올리거나 진행 상황을 중계하지 않는다.**
   - **브랜치는 스크립트가 자동 머지하므로, 사용자에게 절대 머지 승인을 요구하지 않는다**
   - **[절대 금지] 에러가 발생해도 AI 본체가 에디터 도구(replace_file_content 등)를 사용해 직접 파일을 수정하려 나서지 않는다. 파이썬 로직 내부의 에스컬레이션이 100% 자동 해결하므로, 오직 명령어 실행만 담당한다.**

### HANDOFF.md 읽기
- 사용자가 "이어서", "계속", "이전 작업" 등을 언급할 때
- 오케스트레이터 실행 전

### HANDOFF.md 업데이트 — 항상 최신 상태 유지 (중요)

**HANDOFF.md는 언제든 새 세션을 열어도 즉시 이어받을 수 있도록 항상 현재 상태를 반영해야 한다.**

다음 상황에서 사용자 요청 없이 자동으로 업데이트한다:

- 오케스트레이터 실행 완료 후 (성공/실패 무관)
- 버그 수정 또는 기능 구현 완료 후
- 블로커나 에러 발견 시
- 대화가 길어져 새 세션으로 넘길 가능성이 있을 때
- 사용자가 "새 창 열게", "이어서 할게" 등을 언급할 때

업데이트 내용:
- **작업 요약**: 프로젝트 현재 상태 1~3줄
- **현재 상태**: 완료된 것 / 미완료된 것 명확히 구분
- **남은 과제 목록**: 다음에 해야 할 작업만 (완료된 과제는 삭제)
- **특이사항**: 새 세션에서 반드시 알아야 할 컨텍스트

단순한 직접 지시(질문, 탐색, 메타 문서 수정 등)는 HANDOFF.md 읽기/쓰기 없이 바로 처리.

## 코드 수정 라우팅 규칙 (단일 워크플로우)

**모든 코드 파일 수정 요청은 분량 무관하게 항상 `--patch` 모드로 라우팅한다. 직접 Edit/Write 도구로 코드 파일을 수정하지 않는다.**

### 라우팅 표

| 요청 유형 | 처리 방식 |
|---|---|
| 코드 파일 수정 (lib/, functions/, test/, web/, android/, ios/, pubspec.yaml 등) | `cd orchestrator && uv run run.py --patch "수정 내용" --auto-merge` |
| 코드 수정 + QA 검증 | `cd orchestrator && uv run run.py --patch "수정 내용" --auto-merge --qa` |
| QA만 단독 실행 | `cd orchestrator && uv run run.py --qa-only` |
| 메타 문서 수정 (CLAUDE.md, HANDOFF.md, WORKFLOW_GUIDE.md, CHANGELOG.md, README.md) | 직접 Edit/Write OK |
| 신규 프로젝트 생성 (HANDOFF.md 기반) | `cd orchestrator && uv run run.py --auto-merge --qa` |
| 읽기 / 탐색 / 질문 / 디버깅 분석 | 직접 처리 OK |

### 이유

- 채팅 모델(현장 감독)과 파일 적합 모델(전문 작업자)은 다를 수 있다. 채팅 모델이 코드를 직접 수정하면 그 파일의 적합 모델(Opus/Sonnet/Haiku)이 아닌 채팅 모델로 처리되어 품질/비용이 미스매치된다.
- `--patch` 분류기가 worker_map.json 기반으로 파일별 적합 모델을 그때그때 선택하므로 이 미스매치를 차단한다.
- `--auto-merge` 가 머지 + worktree/브랜치 정리까지 처리하므로 사용자는 `flutter run` 의 `r`/`R` 만 누르면 된다.
- 단일 워크플로우 유지 → 사용자/오케스트레이터 모두 "이건 직접? 분류기?" 결정 비용 0.

### 예외

- `worker_map.json` 이 없으면 `--patch` 가 실패한다 → 신규 생성 모드를 한 번 돌려야 한다.
- 머지 충돌 시 `--auto-merge` 가 abort 하고 수동 머지 안내를 출력한다 → 사용자에게 그대로 보고.
- 사용자가 명시적으로 "직접 수정해줘", "분류기 거치지 말고" 라고 말한 경우에만 직접 Edit/Write 허용.

### 보고 방식

`--patch --auto-merge` 실행 후 `last_report.json` 의 결과 + 머지 성공/실패를 채팅창에 출력한다.
사용자는 별도 머지 명령 없이 바로 `flutter run` 터미널에서 `r` 또는 `R` 만 누르면 반영된다.

**API 비용은 항상 포함한다** — 처리 항목 수나 복잡도에 무관하게, 직접 처리(mkdir 등)와 혼합된 경우에도 예외 없이:
```
- API 비용: X.XX USD (누적 N회 실행, X.XX USD)
```

### HANDOFF.md 형식

# HANDOFF.md

## 작업 요약

## 현재 상태

## 남은 과제 목록

### 과제 1: [제목]
- **설명**: 
- **수정 파일**: lib/path/to/file.dart
- **파일 겹침**: 없음
- **우선순위**: 높음 / 보통 / 낮음

## 특이사항

### Rules
- 파일 경로는 항상 구체적으로 명시
- 같은 파일을 건드리는 과제는 반드시 파일 겹침 표시
- Write in Korean

## 템플릿 자동 동기화 규칙

다음 파일들을 수정하면 `C:\dev\flutter-agent-template` 의 동일 파일에도
사용자가 명시적으로 요청하지 않아도 자동으로 반영한다:

- `orchestrator/**` (run.py, pyproject.toml 등)
- `CLAUDE.md`
- `WORKFLOW_GUIDE.md`
- `CHANGELOG.md` — **템플릿 도구 변경 이력 전용** (아래 정의 참조)

**동기화 제외 — 프로젝트 고유 데이터**:

- `orchestrator/worker_map.json` — 각 프로젝트의 파일→그룹 매핑. 신규 프로젝트는 `uv run run.py` 실행 시 `save_worker_map()` 가 자체 생성한다. 템플릿에 존재하면 clone 한 프로젝트가 존재하지 않는 파일 경로의 dead entry 를 물려받게 됨.
- `orchestrator/usage_history.jsonl` — API 비용 누적 기록. 각 프로젝트 로컬 runtime 데이터.
- `orchestrator/last_report.json`, `orchestrator/last_run.log`, `orchestrator/run.lock` — runtime 부산물.

동기화는 `~/.claude/hooks/sync_orchestrator.py` PostToolUse hook 이 자동으로 수행하며,
복사 + git commit + push 까지 한 번에 처리한다.

## CHANGELOG 자동 기록 규칙

`CHANGELOG.md` 는 **템플릿 도구/워크플로우 변경 이력 전용** 이다.
프로젝트 도메인 작업 이력(사주 화면, 결제 통합 등)은 git log 와 HANDOFF.md 가 담당한다.
CHANGELOG 가 도구 이력 전용이므로 template 레포의 CHANGELOG 와 동기화 대상이며,
모든 후속 프로젝트가 동일한 도구 변경 이력을 공유한다.

다음 파일들을 수정하면 사용자가 명시적으로 요청하지 않아도
`CHANGELOG.md` 의 `[Unreleased]` 섹션에 변경 내역을 자동으로 추가한다:

- `orchestrator/` 하위 모든 파일
- `CLAUDE.md`, `WORKFLOW_GUIDE.md` 형식/규칙 변경
- `pyproject.toml` 의존성 변경
- `~/.claude/hooks/` 의 자동화 hook 변경 (예: `sync_orchestrator.py`, `sync.bat`)
- `~/.claude/settings.json` 의 hook 설정 변경

기록하지 않는 변경:
- `lib/`, `functions/`, `test/`, `web/`, `android/`, `ios/` 등 도메인 코드 (git log/HANDOFF 담당)
- `HANDOFF.md` 자체 (작업 인계 문서, 이력 아님)

### 카테고리
- **Added** — 새 기능/파일 추가
- **Changed** — 기존 동작 변경
- **Fixed** — 버그 수정
- **Removed** — 제거된 기능

### 형식
- 한국어로 작성
- "왜" 와 "무엇" 을 모두 기록 (단순 "X 수정" 금지)
- 영향이 큰 변경은 별도 "영향" / "마이그레이션" 하위 섹션 추가
- 날짜는 변경한 날 기준 (예: `### Changed — orchestrator/run.py 안정화 (2026-04-10)`)

### 릴리즈 승격
사용자가 "릴리즈해줘", "버전 올려줘", "0.X.0 으로 태그해줘" 등을 말하면
`[Unreleased]` 섹션을 `[0.X.0] — YYYY-MM-DD` 로 승격하고
새로운 빈 `[Unreleased]` 섹션을 위에 추가한다.

## WORKFLOW_GUIDE.md 수정 규칙

`WORKFLOW_GUIDE.md` 는 후속 프로젝트들이 동일한 워크플로우를 재현할 수 있도록
유지되는 **"현재 사용법" 문서**다. 항상 최신 상태의 깔끔한 최종본으로 유지한다.

### 역할 분리
- **`WORKFLOW_GUIDE.md`**: 현재 사용법. 과거 이력/strikethrough 없음. 깔끔한 최종본.
- **`CHANGELOG.md`**: 모든 변경 이력 누적. "언제/왜/무엇이 바뀌었는지" 의 단일 출처.

### 수정 방식
- 기존 내용은 **그대로 덮어쓰기/삭제/교체** (strikethrough 사용 금지)
- 사용자가 문서를 읽을 때 현재 유효한 정보만 보이도록 유지
- 수정한 모든 내용은 `CHANGELOG.md` 의 `[Unreleased]` 섹션에 반드시 기록
  (어떤 섹션의 무엇이 어떻게 바뀌었는지 구체적으로)

### 트리거
다음 상황에서 자동으로 `WORKFLOW_GUIDE.md` 를 업데이트한다:

- `orchestrator/run.py` 의 동작 방식이 변경됨 (예: 동시성, 재시도, 모델 선택)
- `HANDOFF.md` 형식 변경
- 새로운 트러블슈팅 케이스 발견 (사용자가 "이런 에러 났어" 라고 말하고 해결한 경우)
- 비용/시간 측정값이 실측 데이터와 어긋남
- 새로운 명령어/옵션 추가

CHANGELOG.md 와 마찬가지로 사용자가 명시적으로 요청하지 않아도 자동 수행한다.
**가이드 본문 수정과 CHANGELOG 기록은 항상 함께 수행한다.**
