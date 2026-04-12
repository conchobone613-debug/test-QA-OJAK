# Flutter 멀티에이전트 오케스트레이터 워크플로우 가이드

> 이 문서 + `flutter-agent-template` 레포만 있으면 누구나 동일한 방식으로 Flutter 프로젝트를 자동 생성할 수 있습니다.
>
> 📖 이 문서는 **현재 사용법**만 담고 있습니다. 변경 이력은 [`CHANGELOG.md`](CHANGELOG.md) 를 참조하세요.

---

## 📌 한눈에 보기

이 워크플로우는 **하나의 거대한 Flutter 프로젝트를 19개 작은 그룹으로 쪼개서, AI 서브에이전트 8개가 동시에 코드를 작성하게 만드는 시스템**입니다.

```
사용자
  ↓ "실행해줘"
Claude Code (오케스트레이터, 메인 채팅)
  ↓ HANDOFF.md 읽기
  ↓ run.py 호출
오케스트레이터 스크립트 (Python)
  ↓ ① Opus가 작업을 19개 그룹으로 분류
  ↓ ② 각 그룹마다 git worktree 생성 (격리된 작업 공간)
  ↓ ③ 8개씩 동시에 서브에이전트(Opus/Sonnet) 호출
  ↓ ④ 각 서브에이전트가 코드 작성 + 자기 worktree에 자동 commit
  ↓ ⑤ 결과 보고서 생성
사용자
  ↓ git merge auto/group_1-...
  ↓ git merge auto/group_2-...
  ...완성된 Flutter 프로젝트
```

**핵심 가치**: 19개 작업을 순차로 하면 수 시간 걸릴 일을, 병렬화 + 격리로 **수십 분에 끝낸다**.

---

## 🎯 누구를 위한 가이드인가

- Flutter 프로젝트를 처음부터 자동 생성하고 싶은 개발자
- Claude Code (CLI 또는 VS Code 확장) 사용 경험이 있음
- Anthropic API key 보유 (Tier 1 이상 권장)
- Windows / macOS / Linux 어디서든 사용 가능

---

## 📦 사전 준비

### 1. 필수 도구

| 도구 | 용도 | 설치 |
|------|------|------|
| **git** | worktree 격리 | https://git-scm.com |
| **uv** | Python 패키지 매니저 | https://docs.astral.sh/uv/ |
| **Claude Code** | AI 메인 채팅 | https://claude.com/claude-code |
| **Anthropic API Key** | Opus/Sonnet 호출 | https://console.anthropic.com |

### 2. 환경 변수

```bash
# Windows (PowerShell)
$env:ANTHROPIC_API_KEY = "sk-ant-..."

# macOS / Linux
export ANTHROPIC_API_KEY="sk-ant-..."
```

영구 설정을 원하면 OS의 환경 변수 설정 또는 `~/.bashrc` / `~/.zshrc` 에 추가하세요.

---

## 🚀 처음부터 끝까지 (Step by Step)

### Step 1. 템플릿 클론

```bash
git clone https://github.com/conchobone613-debug/flutter-agent-template.git my-flutter-app
cd my-flutter-app
```

또는 GitHub UI에서 **"Use this template"** 버튼 클릭.

### Step 2. 템플릿 구조 파악

클론하면 다음 파일/폴더가 있습니다:

```
my-flutter-app/
├── CLAUDE.md            ← Claude Code 가 읽는 프로젝트 규칙
├── HANDOFF.md           ← 작업 인계 문서 (사용자가 작성)
├── CHANGELOG.md         ← 템플릿 변경 이력
└── orchestrator/
    ├── run.py           ← 멀티에이전트 실행 스크립트
    ├── pyproject.toml   ← Python 의존성
    └── uv.lock
```

| 파일 | 역할 | 누가 수정? |
|------|------|----------|
| `CLAUDE.md` | Claude Code 의 행동 규칙 (오케스트레이터 흐름, CHANGELOG 자동화 등) | 거의 안 건드림 |
| `HANDOFF.md` | **이번에 무엇을 만들지 작성하는 곳** | **사용자가 직접 작성** |
| `orchestrator/run.py` | 분류 → worktree → 병렬 실행 → 보고 | 거의 안 건드림 |

### Step 3. HANDOFF.md 작성 — **가장 중요한 단계**

여기에 무엇을 만들지 적습니다. AI는 이 문서를 보고 작업을 그룹으로 나눕니다.

#### 형식

```markdown
# HANDOFF.md

## 작업 요약
[프로젝트 한 줄 설명]

## 현재 상태
[지금 어디까지 되어있는지]

## 남은 과제 목록

### 과제 1: [제목]
- **설명**: [무엇을 만들지 구체적으로]
- **수정 파일**: lib/path/to/file.dart, lib/another/file.dart
- **파일 겹침**: 없음
- **우선순위**: 높음 / 보통 / 낮음

### 과제 2: ...
...

## 특이사항
[제약, 외부 의존성, 주의점 등]
```

#### 작성 팁

| 항목 | 좋은 예 | 나쁜 예 |
|------|--------|--------|
| **수정 파일** | `lib/features/auth/login_screen.dart` (구체적 경로) | `로그인 화면` (모호함) |
| **파일 겹침** | "과제 5와 `app_router.dart` 겹침" | "없음" (실제로는 겹치는데) |
| **설명** | "Firebase Auth 카카오/Apple/Google 3종 로그인. 글래스모피즘 카드 안에 버튼 배치" | "로그인 만들어줘" |

⚠️ **파일 겹침을 정확히 표시해야** AI가 같은 그룹으로 묶어서 충돌을 막습니다. 표시 안 하면 두 워커가 같은 파일을 동시에 덮어쓰는 사고가 납니다.

#### 규모 권장

- **과제 수**: 8~25개 권장
- **그룹당 파일 수**: 1~10개 (10개 초과 시 응답 잘림 위험)
- **너무 작으면**: 분류/실행 오버헤드가 더 큼
- **너무 크면**: 워커 응답 토큰 한도 초과

### Step 4. 실행

Claude Code 채팅창에서:

```
HANDOFF.md 보고 실행해줘
```

Claude 가 확인 없이 바로 실행합니다:

1. `cd orchestrator && uv run run.py --auto-merge --qa` (분류 + 병렬 작업 + 자동 머지 + QA 한 번에)
2. 완료되면 채팅창에 보고서 출력

> dry-run을 먼저 보고 싶을 때: `uv run run.py --dry-run` 직접 실행

#### 실행 동안 일어나는 일 (터미널 로그)

```
[ 2/4 ] Worktree 생성 중...
         → group_1: my-flutter-app-group_1-0410-1530   [auto/group_1-0410-153022]
         → group_2: my-flutter-app-group_2-0410-1530   [auto/group_2-0410-153023]
         ... (19개)

[ 3/4 ] 서브에이전트 병렬 실행 중 (동시 8개)...

   [ 시작 ] group_1 (claude-sonnet-4-6): Flutter 프로젝트 초기화...
   [ 시작 ] group_2 (claude-opus-4-6): Firebase Functions...
   [ 시작 ] group_3 (claude-sonnet-4-6): 디자인 시스템...
   ... (8개 동시)

   [ 완료 ] group_3: 디자인 시스템 색상/타이포 정의 완료... (0:01:23)
   [ 시작 ] group_9 (claude-opus-4-6): Gemini AI 연동...
   [ 재시도 ] group_2: 529 → 2.3s 대기 (시도 1/5)
   ... (한 워커 끝나면 다음 워커 시작)

[ 4/4 ] 보고서 생성 중...
```

#### 격리 구조

각 그룹은 **부모 디렉토리에 별도 폴더**로 생성됩니다:

```
c:/dev/
├── my-flutter-app/                          ← 원본 (main 브랜치)
├── my-flutter-app-group_1-0410-1530/        ← group_1 작업 공간
├── my-flutter-app-group_2-0410-1530/        ← group_2 작업 공간
├── my-flutter-app-group_3-0410-1530/        ← group_3 작업 공간
... (19개)
```

각 워크트리에서 워커가 코드를 작성하고 자체 브랜치에 commit 합니다. 원본은 안 건드립니다.

### Step 6. 결과 보고서 확인

실행이 끝나면 자동으로 보고서가 출력됩니다:

```
═══════════════════════════════════════════════════════
  작업 완료 보고  —  2026-04-10 16:12
═══════════════════════════════════════════════════════

[ 실행 결과 ]

  ✓ group_1 (0:01:23)
    Flutter 프로젝트 초기화 및 디자인 시스템 의존성 추가 완료
    - pubspec.yaml 에 20개 의존성 추가
    - lib/main.dart 에 ProviderScope + MaterialApp 설정
    브랜치: auto/group_1-0410-153022

  ✓ group_2 (0:02:45)
    ...

[ 실패 ]

  ✗ group_11: 응답이 max_tokens에 잘림 (len=15890)

[ 자동 머지 ]
  ✓ group_1: 머지 완료
  ✓ group_2: 머지 완료
  ...

[ 다음 단계 ]
  ✅ QA 파이프라인 자동 실행 시작...
```

보고서는 `orchestrator/last_report.json` 에도 저장됩니다.

### Step 7. 결과 검토 (자동 머지 + QA)

별도의 머지 명령 없이 성공한 모든 워크트리가 `main` 브랜치에 **의존성 순서대로** 자동 머지됩니다.
머지가 끝나면 곧바로 **QA 파이프라인**이 실행되어 빌드 오류나 런타임 오류를 3단계(`--qa-layers 1,2,3`)에 걸쳐 검증하고 자동 수정합니다.
완료 후 병렬 작업에 사용된 워크트리 임시 폴더들 역시 스크립트가 알아서 깔끔히 제거합니다. (수동 정리 불필요)
```

### Step 8. 실패 그룹 재실행

실패한 그룹이 있으면 (예: `group_11` 응답 잘림):

1. HANDOFF.md 를 새로 작성 — **실패한 과제만 포함**
2. 해당 과제를 더 작은 단위로 쪼개기
3. 다시 `실행해줘`

---

## 🔧 수정 모드 (`--patch`)

신규 생성이 끝난 뒤 일상적인 수정 요청도 동일한 병렬 워커 구조로 처리할 수 있습니다.
HANDOFF.md 에 새 과제를 추가하지 않고, 채팅창에 자유 텍스트 한 줄로 수정 지시를 내립니다.

### 동작 흐름

```
사용자
  ↓ uv run run.py --patch "로그인 화면에서 카카오 버튼 색상을 #FEE500으로 바꿔줘"
오케스트레이터
  ↓ ① Opus가 수정 텍스트 + worker_map.json 을 보고 영향받는 그룹을 추론
  ↓ ② 해당 그룹마다 git worktree 생성 (prefix: patch/)
  ↓ ③ 워커가 기존 파일을 worktree 에서 읽어 컨텍스트로 받음
  ↓ ④ 변경된 파일만 전체 내용으로 응답 → 적용 → 자동 commit
  ↓ ⑤ 보고서 출력 + HANDOFF.md "## 수정 이력" 자동 추가
사용자
  ↓ git merge patch/group_3-...
```

### 사용법

```bash
cd orchestrator
uv run run.py --patch "로그인 화면에서 카카오 버튼 색상을 #FEE500으로 바꾸고, 버튼 텍스트도 '카카오로 시작하기'로 변경" --auto-merge
```

여러 파일/그룹에 걸친 수정도 한 번에 가능합니다. 분류기가 알아서 영향받는 그룹만 묶어서 병렬 실행합니다.

**`--auto-merge` 권장**: 성공한 그룹을 현재 HEAD(보통 main) 에 자동 머지하고 worktree/브랜치까지 정리합니다. `flutter run -d chrome` 으로 띄워둔 상태라면 자동 머지 직후 터미널에서 `r` 또는 `R` 만 누르면 즉시 반영됩니다.

```bash
# 권장 흐름 (단일 워크플로우)
uv run run.py --patch "수정 내용" --auto-merge
# → flutter run 터미널로 가서 r 또는 R
```

머지 충돌이 발생하면 자동 머지가 abort 되고 수동 머지 명령이 안내됩니다.

### worker_map.json (자동 생성)

신규 생성 모드(`uv run run.py`) 가 성공적으로 완료되면 `orchestrator/worker_map.json` 이
자동으로 갱신됩니다. 형식:

```json
{
  "lib/core/theme/app_colors.dart": {
    "group_id": "group_3",
    "profile": "standard"
  },
  "functions/src/saju/calculateSaju.ts": {
    "group_id": "group_2",
    "profile": "heavy"
  }
}
```

이 매핑을 보고 분류기가 "어떤 파일이 어떤 그룹/모델에 속해 있는지" 를 알게 됩니다.
`--patch` 모드가 실행되어 새 파일이 생기면 `update_worker_map_after_patch()` 가 자동으로 누적합니다.

### 브라운필드 프로젝트 셋업 (`--build-worker-map`)

**이미 만들어진 프로젝트**(신규 생성 모드를 거치지 않았거나, 이 템플릿 도입 전에 만든 프로젝트) 는 `worker_map.json` 이 없어서 `--patch` 모드를 바로 쓸 수 없습니다. 이 경우 딱 한 번 다음 명령을 실행합니다:

```bash
cd orchestrator
uv run run.py --build-worker-map
```

#### 동작

1. `git ls-files` 로 tracked 파일 목록 수집
2. 화이트리스트(`.dart`, `.ts`, `.arb`, `.rules` + `pubspec.yaml`/`firestore.rules`/`tsconfig.json` 등 설정 basename) + 블랙리스트(`orchestrator/`, `.worktrees/`, `build/`, `ios/`, `android/`, `web/`, `assets/` 등) 로 필터
3. Opus 분류기가 파일 경로를 보고 도메인/관심사 그룹으로 묶어 `heavy`/`standard`/`light` 프로필 할당
4. `orchestrator/worker_map.json` 저장
5. **파일 수정 전혀 안 함** — worktree 생성 X, 워커 실행 X, 기존 코드 안전

#### 비용/시간 (실측)

| 프로젝트 규모 | 분류 대상 | 분류기 호출 | 소요 시간 | 비용 |
|---|---|---|---|---|
| 중형 (OJAK 기준: lib 109 + functions 28 + config 7) | ~144개 | Opus 1회 | ~60초 | ~$0.5 |

#### 결과 검토 + 수동 조정

분류는 100% 정확하지 않을 수 있습니다. 명령 실행 후 `orchestrator/worker_map.json` 을 직접 열어서 오분류된 파일이 있으면 해당 entry 를 수동으로 수정하세요 (메타 파일이라 직접 Edit 허용).

예를 들어 분류기가 `lib/core/utils/validators.dart` 를 light 로 넣었는데 실제로는 복잡한 검증 로직이면:

```json
"lib/core/utils/validators.dart": {
  "group_id": "group_15",
  "profile": "standard"
}
```

로 수정하면 됩니다. 다음 `--patch` 실행 시 적용됨.

#### 언제 쓰나

- **초기 셋업 시 한 번만** 돌리면 됨. 두 번 돌릴 이유 없음.
- `worker_map.json` 을 완전히 날려먹었거나, 프로젝트 구조가 근본적으로 바뀐 후 재빌드하고 싶을 때는 다시 돌려도 OK (기존 파일을 덮어씀).
- 신규 프로젝트는 이 명령 필요 없음 — `uv run run.py` 가 알아서 만듦.

### 워커 동작 차이 (신규 생성 vs 수정)

| 항목 | 신규 생성 모드 | 수정 모드(`--patch`) |
|------|---------------|---------------------|
| 입력 소스 | HANDOFF.md 의 과제 목록 | 채팅창 자유 텍스트 |
| 분류기 컨텍스트 | HANDOFF.md 본문 | 수정 텍스트 + worker_map.json |
| 워커 컨텍스트 | 빈 파일(또는 기존 파일) | 항상 기존 파일 내용 |
| 응답 범위 | 그룹 내 모든 파일 | **변경된 파일만** |
| 브랜치 prefix | `auto/` | `patch/` |
| 커밋 메시지 | `auto(group_X): ...` | `patch(group_X): ...` |
| 완료 후 | `last_report.json` 만 갱신 | `HANDOFF.md "## 수정 이력"` 자동 append |

### 결과 보고서

신규 생성 모드와 동일한 형식으로 출력됩니다. 다음 단계로 안내되는 명령은 `git merge patch/...` 입니다.

### 머지

`--auto-merge` 를 사용하면 자동입니다 (권장).

수동으로 검토하고 싶을 때만 `--auto-merge` 없이 실행:

```bash
cd ../my-flutter-app
git merge patch/group_3-0410-153022
```

### 단일 워크플로우 권장

코드 파일 수정은 **분량 무관 항상 `--patch --auto-merge`** 를 권장합니다.
"이건 작아서 직접 수정 / 이건 커서 분류기" 식의 분기는 인지 부하만 늘리고 모델 적합성도 일관성을 잃습니다.

- 채팅 모델(Sonnet)이 직접 수정하면 그 파일의 적합 모델(Opus/Sonnet/Haiku)이 아닌 채팅 모델로 처리됨
- `--patch` 는 worker_map 기반으로 파일별 적합 모델을 그때그때 자동 선택
- 1줄 수정이라도 동일하게 적용 → 1분 + 토큰 비용 트레이드오프를 받아들이는 게 장기적으로 유리

이 규칙은 `CLAUDE.md` 의 "코드 수정 라우팅 규칙" 섹션에 명시되어 있어 Claude Code 가 자동으로 따릅니다.

### 주의사항

- `worker_map.json` 이 없으면 수정 모드는 실행되지 않습니다. 먼저 신규 생성 모드를 한 번이라도 돌려야 합니다. 이미 존재하는 프로젝트(브라운필드) 는 `--build-worker-map` 으로 1회성 시드 생성 가능.
- 분류기가 수정과 무관한 그룹을 잘못 포함시키면 수정 텍스트를 더 구체적으로 (어떤 화면, 어떤 파일) 적어 주세요.
- 변경되지 않은 파일은 워커가 응답에 포함하지 않으므로 안전합니다 — 같은 그룹의 다른 파일이 의도치 않게 덮어써지지 않습니다.

### ⚠️ 동일 레포에 Claude Code 세션 2개 병렬 실행 금지

**같은 프로젝트 디렉토리에 Claude Code 채팅창을 2개 이상 띄워서 동시에 `--patch` 를 돌리면 안 됩니다.**

**왜 위험한가**:

- 두 세션이 동시에 `git worktree` 를 만들고 `auto_merge_and_cleanup` 이 동시에 머지를 시도하면 **`main` 브랜치 race condition** 발생. 한쪽의 commit 이 아직 머지되지 않은 상태에서 다른 쪽이 같은 `main` 에 3-way merge 를 시도 → 충돌/abort.
- `HANDOFF.md` 의 "## 수정 이력" 섹션이 동시에 append 되면서 **HANDOFF.md race** 발생. 한쪽의 이력이 덮어써질 수 있음.
- `worker_map.json` 을 두 세션이 동시에 `update_worker_map_after_patch()` 로 쓰면 **단일 파일 lock-free 쓰기** 라 한쪽의 갱신이 손실될 수 있음.
- `last_report.json`, `last_run.log` 도 단일 파일이라 한쪽이 다른 쪽 결과를 덮어씀. 실행 로그 소실.
- `run.lock` 파일이 있긴 하지만 "이미 실행 중" 메시지만 띄우고 사용자가 실수로 지우면 보호 무력화.

**OJAK 에서 실제 발생했던 케이스** (2026-04-10):
- 이 템플릿의 `--patch` 기능 자체를 설계/구현하던 중, 한 세션이 문서/기능을 수정하는 동안 다른 세션이 `orchestrator/run.py` 에 API 토큰 비용 계산 기능을 `--patch` 로 여러 번 시도(revert 2회 포함 총 4회).
- 결과: git log 에 커밋이 뒤섞이고, `HANDOFF.md` "## 수정 이력" 에 4개 entry 가 append 되었으며, working tree 에 두 세션의 uncommitted 변경이 혼재.
- 다행히 파일 충돌은 없었지만(건드리는 영역이 달랐음), `orchestrator/run.py` 한 파일에 양쪽 변경이 layered 되어 통합 시점에 careful merge 가 필요했음.

**권장 운영 방식**:

| 상황 | 권장 |
|---|---|
| 한 프로젝트에서 여러 작업을 병렬로 하고 싶음 | **세션 1개만**. 요청을 묶어서 한 번의 `--patch` 로 보내면 분류기가 알아서 그룹별 병렬 실행 |
| 서로 다른 프로젝트를 병렬로 작업 | OK. 세션당 프로젝트 1개 원칙 지키면 안전 |
| 긴 `--patch` 실행 중인데 다른 작업을 하고 싶음 | 완료까지 기다리거나, 같은 세션에서 취소 후 새 요청. 새 세션 열지 말 것 |
| 정말 병렬이 필요하다 | 한 세션은 `--patch --auto-merge` 를 끝낸 후(`main` 브랜치가 깨끗해진 후) 다른 세션을 시작. 사실상 직렬화 |

**기술적으로 race condition 을 막는 방법은?**

이론적으로 `run.lock` 을 강화해서 `advisory lock` 을 걸거나 `flock`/`msvcrt.locking` 을 쓸 수 있지만, 현재 구현에는 없습니다. 현실적으로 **"한 프로젝트 = 한 세션" 원칙을 지키는 쪽이 훨씬 단순**하고, 그게 오케스트레이터의 설계 전제입니다 (단일 프로세스 기준).

---

## 🔍 QA 파이프라인 (`--qa`, `--qa-only`)

빌드 또는 수정 후 자동으로 3층 QA 검증을 실행하고, 에러를 감지하면 자동 에스컬레이션으로 수정을 시도합니다.

### 사용법

```bash
# 신규 생성 후 QA 자동 실행
uv run run.py --auto-merge --qa

# 수정 후 QA 자동 실행
uv run run.py --patch "수정 내용" --auto-merge --qa

# QA만 단독 실행 (빌드/수정 없이)
uv run run.py --qa-only

# 특정 레이어만 실행 (예: 정적 분석 + 런타임만)
uv run run.py --qa-only --qa-layers 1,2

# 에러 수집만 하고 자동 수정 안 함
uv run run.py --qa-only --no-escalation
```

### 3층 QA 레이어

| 레이어 | 검증 내용 | 도구 | 자동 수정 |
|---|---|---|---|
| **L1: 정적 분석** | `flutter analyze` 에러 + `flutter build web` 컴파일 | Flutter CLI | ✓ 에스컬레이션 |
| **L2: 런타임 검증** | 콘솔 에러, 빈 화면, Flutter 엔진 미로딩 | Playwright | ✓ 에스컬레이션 |
| **L3: 시각 QA** | UI 붕괴, 빨간 에러 배너, 렌더링 실패 | Playwright + Claude Vision | ✗ 보고만 |

### 에스컬레이션 로직

QA에서 에러가 감지되면 Opus가 에러 난이도를 분석하고 적절한 레벨부터 수정을 시작합니다:

```
에러 감지 → Opus가 난이도 판단 → 시작 레벨 결정
                                    ↓
    Lv1: Haiku → 수정 → 재검증 → 해결? → 완료
                                    ↓ 실패
    Lv2: Sonnet → 수정 → 재검증 → 해결? → 완료
                                    ↓ 실패
    Lv3: Opus → 수정 → 재검증 → 해결? → 완료
                                    ↓ 실패
    Lv4: Opus+Thinking → 수정 → 재검증 → 해결? → 완료
                                    ↓ 실패
    사용자에게 미해결 에러 상세 보고
```

- **단순 에러** (오타, import 누락): Lv1 Haiku에서 바로 해결
- **보통 에러** (상태 관리, null 안전성): Lv2 Sonnet부터 시작
- **복잡 에러** (Provider 순환, 아키텍처): Lv3 Opus부터 시작
- **근본 결함**: Lv4 Opus+Thinking부터 시작

### Playwright 사전 준비

L2/L3 레이어를 사용하려면 Playwright가 필요합니다:

```bash
cd orchestrator
uv add playwright
playwright install chromium
```

Playwright가 미설치면 L2/L3은 자동으로 건너뛰고 L1만 실행됩니다.

### Flutter Semantics 자동 삽입

Playwright가 Flutter 웹 앱의 UI 요소에 접근하려면 Semantics 트리가 활성화되어야 합니다.
코드 생성 시 워커가 `Semantics` 위젯으로 버튼/텍스트를 감싸도록 프롬프트에 명시되어 있습니다.

### QA 결과 보고서

```
───────────────────────────────────────────────────────
  QA 결과 보고
───────────────────────────────────────────────────────

  라운드: 2회
  통과 레이어: L1, L2

  [ 자동 수정 ]
    ✓ L1-analyze — Haiku로 해결
      import 누락 3건 자동 추가

  [ 미해결 — 사용자 확인 필요 ]
    ✗ [visual] /home: 하단 네비게이션 아이콘 잘림

  ✅ QA 전체 통과 — 1차 데모 준비 완료   (에러 없는 경우)
───────────────────────────────────────────────────────
```

### CLI 인자 요약

| 인자 | 설명 |
|---|---|
| `--qa` | 빌드/수정 후 QA 파이프라인 자동 실행 |
| `--qa-only` | QA만 단독 실행 (빌드/수정 없이) |
| `--qa-layers 1,2,3` | 실행할 QA 레이어 선택 (기본: 1,2,3) |
| `--no-escalation` | 에러 수집만 하고 자동 수정 안 함 |

### 주의사항

- L1 정적 분석이 실패하면 L2/L3은 실행되지 않습니다 (빌드 자체가 안 되므로)
- L3 시각 QA는 자동 수정하지 않고 보고만 합니다 (UI 변경의 위험도가 높으므로)
- 에스컬레이션 수정은 `qa-fix(haiku):`, `qa-fix(sonnet):` 등의 커밋 메시지로 git에 기록됩니다
- 최대 3라운드까지 시도합니다 (라운드마다 L1→L2→L3 순차)

---

## 🛠 트러블슈팅

### "ANTHROPIC_API_KEY 가 설정되지 않았습니다"
→ 환경 변수 다시 설정하고 터미널 재시작.

### "JSON 파싱 실패. stop_reason=max_tokens"
→ 분류 모델이 너무 길게 응답함. HANDOFF.md 를 짧게 줄이거나, `run.py` 의 분류 단계 `max_tokens` 를 더 늘리세요.

### "응답이 max_tokens에 잘림" (워커)
→ 그룹의 파일 수가 너무 많거나 파일이 큼. HANDOFF.md 에서 해당 과제를 2~3개로 분할하세요.

### "529 / 429 에러"
→ Anthropic API rate limit. **자동 재시도가 5회까지 됩니다** (지수 백오프). 그래도 실패하면:
- `--concurrency 4` 로 동시성 낮추기
- API tier 업그레이드
- 잠시 후 재시도

### "git worktree 생성 실패"
→ 같은 이름의 worktree 가 이미 있음. `git worktree list` 로 확인 후 `git worktree remove --force ../path` 로 정리.

### "워커 1개가 실패하면 전체가 멈추나?"
→ **아니요.** `gather(return_exceptions=True)` 로 격리되어 있습니다. 실패한 그룹만 보고서에 표시되고 나머지는 정상 진행.

### Windows 에서 한글 깨짐
→ `PYTHONIOENCODING=utf-8 PYTHONUTF8=1` 환경 변수 설정 후 실행.

### 템플릿 자동 동기화가 작동 안 함
→ 이 워크플로우는 `~/.claude/settings.json` 의 `PostToolUse` hook 으로 `run.py`/`CLAUDE.md`/`WORKFLOW_GUIDE.md` 변경을 템플릿 레포에 자동 반영합니다. 작동 안 할 때 점검 순서:

1. **로그 확인**: `~/.claude/hooks/sync_orchestrator.log` 에 호출 흔적이 있는지. 비어있으면 hook 자체가 트리거 안 됨 (아래 2~5번 확인).
2. **매처 분리**: `"Edit|Write"` 같은 OR 정규식 매처는 매칭 실패 가능. `"Edit"`/`"Write"`/`"MultiEdit"` 를 별도 entry 로 분리.
3. **spec 외 키 제거**: `"async": true` 같은 비공식 키는 제거 (silent rejection 가능). 공식 키는 `matcher`, `hooks`, `type`, `command`, `timeout`.
4. **Windows path escape**: hook command 의 path 는 **반드시 forward slash** 또는 **`.bat` wrapper** 사용. backslash 는 bash/Python 에서 `\U`, `\k`, `\.`, `\h` 등이 escape sequence 로 처리되어 path 가 망가짐.
   - ❌ `"command": "python C:\\Users\\me\\.claude\\hooks\\sync.py"` → bash 에서 `Usersmeclaudehookssync.py` 로 깨짐
   - ✅ `"command": "C:/Users/me/.claude/hooks/sync.bat"` 또는 `"command": "python C:/Users/me/.claude/hooks/sync.py"`
5. **timeout 명시**: `"timeout": 30` 추가 (git push 까지 여유).
6. **settings.json 핫리로드 한계**: settings.json 변경은 새 Claude Code 세션부터 적용됨. 변경 후에도 안 되면 한 번 재시작.

권장 형태:
```json
"PostToolUse": [
  {
    "matcher": "Edit",
    "hooks": [{"type": "command", "command": "C:/Users/me/.claude/hooks/sync.bat", "timeout": 30}]
  },
  {
    "matcher": "Write",
    "hooks": [{"type": "command", "command": "C:/Users/me/.claude/hooks/sync.bat", "timeout": 30}]
  },
  {
    "matcher": "MultiEdit",
    "hooks": [{"type": "command", "command": "C:/Users/me/.claude/hooks/sync.bat", "timeout": 30}]
  }
]
```

`.bat` wrapper 안에서 `python "절대경로"` 로 호출하면 어떤 escape 문제도 격리됩니다.

---

## ⚙️ 동시성 조정

기본값은 **8** 입니다. 상황에 따라 조정:

```bash
uv run run.py --concurrency 4    # 보수적 (Tier 1 / 안정성 우선)
uv run run.py                    # 기본 (Tier 2+)
uv run run.py --concurrency 12   # 공격적 (Tier 4+, 빠른 처리)
```

| 동시성 | 19개 그룹 처리 시간 (대략) | 권장 Tier |
|---|---|---|
| 1 | 10~20분 | 모든 Tier |
| 4 | 3~5분 | Tier 1 |
| **8 (기본)** | **2~3분** | **Tier 2+** |
| 12 | 1.5~2분 | Tier 3+ |
| 19 | 1~1.5분 (rate limit 위험) | Tier 4 |

비용은 동시성과 무관합니다. 시간만 줄어듭니다.

---

## 💰 비용 가이드

### 시나리오 비교 (19개 그룹 기준)

| 방식 | 비용 (USD) | 시간 |
|------|---|---|
| 단일 채팅 + Opus 순차 | ~$13~29 | 수 시간 |
| 단일 채팅 + Sonnet 순차 | ~$3 | 수 시간 |
| **오케스트레이터 (Opus 7 + Sonnet 12)** | **~$5** | **3~5분** |

오케스트레이터는 **시간 + 비용 모두 절감**합니다. 격리된 컨텍스트라 토큰 누적이 없기 때문.

### 단일 그룹 평균 비용

| 모델 | input ~3k + output ~6k | 비용 |
|---|---|---|
| Opus | $0.045 + $0.45 | ~$0.50 |
| Sonnet | $0.009 + $0.09 | ~$0.10 |
| Haiku | $0.003 + $0.03 | ~$0.03 |

---

## 🎓 모델 선택 자동화 원리

`run.py` 는 분류 단계에서 **Opus 가 직접 각 그룹의 모델을 결정**합니다:

```
heavy   (Opus)    → 아키텍처 설계, 보안 분석, 복잡한 도메인 로직
standard (Sonnet) → 일반 기능 구현, 버그 수정, UI 작업
light   (Haiku)   → 변수명 변경, 단순 수정, import 정리
```

- **신규 프로젝트** (0 → 1): standard / heavy 위주
- **유지보수** (포맷, 리네임, deprecated 치환): light 위주
- **도메인 로직** (사주, 결제, 매칭 알고리즘): heavy

수동으로 강제하고 싶으면 HANDOFF.md 의 "특이사항" 에 명시하면 됩니다.

---

## 📝 CHANGELOG 자동 기록

템플릿의 핵심 파일을 수정하면 Claude 가 자동으로 `CHANGELOG.md` 에 변경 내역을 기록합니다 (사용자가 요청 안 해도).

대상 파일:
- `orchestrator/` 하위 모든 파일
- `CLAUDE.md`, `HANDOFF.md` 형식/규칙
- `pyproject.toml` 의존성

이 규칙은 `CLAUDE.md` 의 "CHANGELOG 자동 기록 규칙" 섹션에 정의되어 있습니다.

릴리즈 시:
```
릴리즈해줘 0.2.0 으로
```
→ `[Unreleased]` 가 `[0.2.0] — YYYY-MM-DD` 로 자동 승격됩니다.

---

## 🔑 핵심 설계 원칙

이 워크플로우가 동작하는 이유:

1. **격리**: 각 워커는 독립된 git worktree 에서 작업 → 충돌 없음
2. **병렬**: 동시 8개 → 순차 대비 8배 빠름
3. **자동 재시도**: rate limit / 일시 오류는 자동 복구 (5회 백오프)
4. **에러 격리**: 워커 1개 실패가 전체를 죽이지 않음
5. **모델 mix**: 작업 난이도에 맞는 모델 자동 선택 → 비용 최적
6. **명시적 계약**: HANDOFF.md 가 사람-AI 간 계약서 역할

---

## 📚 추가 자료

- **템플릿 레포**: https://github.com/conchobone613-debug/flutter-agent-template
- **Claude Code 문서**: https://docs.claude.com/claude-code
- **Anthropic API 문서**: https://docs.anthropic.com
- **uv 문서**: https://docs.astral.sh/uv

---

## 🙋 자주 묻는 질문

**Q. Flutter 가 아닌 다른 프레임워크 (React, Django) 에도 쓸 수 있나?**
A. 가능합니다. `run.py` 의 워커 system prompt 와 `_detect_lang()` 의 확장자 매핑만 수정하면 됩니다.

**Q. 19개 그룹을 19개 동시 실행할 수 있나?**
A. 기술적으로 가능하지만 권장 안 합니다. Anthropic API rate limit (특히 Tier 1 의 ITPM) 에 걸려 재시도가 폭주합니다. 8~12 가 안정적.

**Q. 머지 순서를 자동으로 정할 수 있나?**
A. 현재 버전은 수동입니다. 향후 의존성 그래프 자동 생성 기능을 추가할 수 있습니다 (CHANGELOG 에 TODO).

**Q. 워커가 만든 코드가 잘못됐으면?**
A. 해당 worktree 에서 직접 수정하거나, `--patch` 모드로 자유 텍스트 수정 요청 → 자동 병렬 수정. 머지 안 한 브랜치는 언제든 버려도 됩니다.

**Q. 동시 실행 중에 한 워커가 다른 워커의 결과물을 참조할 수 있나?**
A. 불가능합니다. 격리가 핵심 원리라 워커끼리 통신 안 합니다. 의존성 있는 작업은 1차 실행 → 머지 → 2차 실행 으로 분리하세요.

---

## 📋 체크리스트 (실전 사용 시)

```
[ ] git, uv, Claude Code 설치
[ ] ANTHROPIC_API_KEY 환경 변수 설정
[ ] flutter-agent-template 클론
[ ] HANDOFF.md 작성 (과제 8~25개, 파일 겹침 정확히 표시)
[ ] Claude Code 채팅: "HANDOFF.md 보고 실행해줘"
[ ] dry-run 결과 검토 (그룹 수, 모델 선택, 파일 겹침)
[ ] 승인: "실행해줘"
[ ] 실행 완료 대기 (3~5분)
[ ] 보고서 확인 (성공/실패 그룹)
[ ] 실패 그룹은 따로 재실행
[ ] 의존성 순서대로 git merge
[ ] worktree 정리 (git worktree remove)
[ ] 완성된 프로젝트로 다음 작업 진행
```

---

*이 가이드는 OJAK 프로젝트(사주팔자 데이팅앱)의 19개 그룹 멀티에이전트 실행을 검증하면서 작성되었습니다. 동일한 워크플로우로 다양한 Flutter 프로젝트에 적용 가능합니다.*
