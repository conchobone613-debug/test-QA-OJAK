# Changelog

이 템플릿의 변경 내역을 기록합니다. 형식은 [Keep a Changelog](https://keepachangelog.com/ko/1.1.0/) 를 따릅니다.

## [Unreleased]

### Added — WORKFLOW_GUIDE 병렬 세션 금지 경고 (2026-04-10)

`WORKFLOW_GUIDE.md` 의 수정 모드(`--patch`) 섹션에 "**동일 레포에 Claude Code 세션 2개 병렬 실행 금지**" 경고 추가. OJAK 에서 이 템플릿을 설계/구현하던 중 실제로 겪은 병렬 세션 race 케이스를 바탕으로 작성.

**왜 기록하는가**: 오케스트레이터는 단일 프로세스 기준으로 설계되었지만, Claude Code VS Code extension 은 한 프로젝트에 여러 채팅창을 띄울 수 있어 사용자가 실수로 병렬 실행할 여지가 있음. 경고가 없으면 후속 프로젝트도 같은 race 를 겪을 것이라 명시적 문서화 필요.

**경고 내용**:
- `git worktree` + `auto_merge_and_cleanup` 동시 실행 → `main` 브랜치 3-way merge race
- `HANDOFF.md "## 수정 이력"` 동시 append → 한쪽 이력 소실 가능
- `worker_map.json` 동시 쓰기 → lock-free 라 한쪽 갱신 손실
- `last_report.json`/`last_run.log` 덮어쓰기
- `run.lock` 은 보호 1차선일 뿐, 강제로 무력화 가능

**권장 운영 방식 표**:
- 한 프로젝트 여러 작업 병렬 → 세션 1개에서 여러 요청을 묶어 보내기 (분류기가 그룹 병렬 처리)
- 서로 다른 프로젝트 병렬 → OK (세션당 프로젝트 1개 원칙)
- 긴 `--patch` 중 다른 작업 → 완료까지 기다리거나 같은 세션에서 취소

**실제 사례 기록**: OJAK 에서 한 세션이 문서/기능 설계 중 다른 세션이 `orchestrator/run.py` 에 API 토큰 비용 계산을 `--patch` 로 4회 시도(revert 2회 포함). 파일 충돌은 다행히 없었지만 git log 가 뒤섞이고 working tree 에 양측 변경이 혼재, 사용자가 careful merge 해야 했음.

**기술적 race 방지**: `flock`/`msvcrt.locking` 으로 `run.lock` 을 advisory lock 으로 강화하는 옵션은 있으나 현재 미구현. "한 프로젝트 = 한 세션" 원칙이 훨씬 단순하고 안전해서 그 쪽을 공식 권장.

### Fixed — 프로젝트 고유 데이터(worker_map.json 등) 템플릿 동기화 제외 (2026-04-10)

`orchestrator/worker_map.json` 이 template 레포에 잘못 동기화되어 있는 것을 발견. 이 파일은 **각 프로젝트의 파일 경로 → 그룹/모델 매핑**이라 template 에 존재하면 clone 한 신규 프로젝트가 존재하지 않는 파일 경로의 dead entry 를 물려받게 됨.

**원인**: `~/.claude/hooks/sync_orchestrator.py` 의 `EXCLUDE` set 이 runtime 부산물(`last_report.json`, `last_run.log`, `run.lock` 등) 은 걸러내고 있었지만 `worker_map.json` 과 `usage_history.jsonl` 같은 **프로젝트 고유 데이터**는 걸러내지 않음.

**수정**:
- `~/.claude/hooks/sync_orchestrator.py` `EXCLUDE` 에 `worker_map.json`, `usage_history.jsonl` 추가
- `c:/dev/flutter-agent-template/orchestrator/worker_map.json` 삭제 + template 레포에 commit + push
- `CLAUDE.md` "템플릿 자동 동기화 규칙" 섹션에 "동기화 제외 — 프로젝트 고유 데이터" 서브섹션 추가 (worker_map.json, usage_history.jsonl, last_report.json, last_run.log, run.lock)

**왜 이게 중요한가**: 템플릿의 역할은 **모든 후속 프로젝트가 깨끗한 상태에서 시작할 수 있게 하는 것**. 프로젝트 고유 runtime/상태 데이터가 템플릿에 섞이면 새 프로젝트가 OJAK 의 파일 구조를 물려받는 꼴이 됨. 앞으로 같은 종류의 데이터(`last_*`, `*.lock`, `worker_map.*`, `usage_*`)는 기본 제외.

### Added — `--build-worker-map` 브라운필드 시드 명령 (2026-04-10)

수정 모드(`--patch`)는 `worker_map.json` 이 있어야 동작하는데, 이 파일은 신규 생성 모드(`uv run run.py`) 가 끝날 때 자동으로 만들어짐. 문제는 **이 기능이 도입되기 전에 만들어진 프로젝트**(OJAK 이 바로 이 경우) 는 worker_map 이 없어서 수정 모드를 바로 쓸 수 없다는 것. OJAK 이 겪은 한 번의 상황이지만, 후속 프로젝트가 템플릿을 늦게 채택해 동일한 상황을 겪을 수 있으므로 재사용 가능한 도구로 만듦.

**동작**:
- `uv run run.py --build-worker-map` 한 번 실행
- `git ls-files` 로 프로젝트 tracked 파일 목록 수집
- 화이트리스트(`.dart`/`.ts`/`.arb`/`.rules` + `pubspec.yaml`/`firestore.rules`/`tsconfig.json` 등 설정 파일 basename) + 블랙리스트(`orchestrator/`, `.worktrees/`, `build/`, `ios/`, `android/`, `web/`, `assets/` 등) 로 필터
- 남은 파일 목록을 Opus 분류기에 전달 → 도메인/관심사 단위 그룹 + 모델 프로필 할당
- 분류기가 파일을 누락하면 `group_fallback` (standard) 로 safety net 배정
- 결과를 `orchestrator/worker_map.json` 에 저장. **파일 수정은 전혀 하지 않음** (worktree 생성 X, 워커 실행 X)

**구현** ([orchestrator/run.py](orchestrator/run.py)):
- `WORKER_MAP_CODE_EXTS`, `WORKER_MAP_CONFIG_FILES`, `WORKER_MAP_EXCLUDE_PREFIXES` 필터 상수 추가
- `_is_worker_map_target()` 판정 헬퍼
- `BUILD_WORKER_MAP_SYSTEM` 분류 프롬프트 (heavy/standard/light 프로필 선택 기준 명시)
- `build_worker_map_main()` 메인 함수 — 스캔/분류/저장/통계 출력
- `--build-worker-map` CLI 플래그 + dispatcher 연결

**왜 이게 필요한가**: 신규 프로젝트는 `save_worker_map()` 이 `main()` 끝에서 자동으로 worker_map 을 만들어주지만, 브라운필드(이미 존재하는 프로젝트) 는 그 진입점이 없음. 기존 파일을 수동으로 worker_map 에 매핑하는 건 100+ 파일 앞에서 비현실적이라 Opus 분류기 호출 1회(~$0.5) 로 대체.

**OJAK 실측 결과**: 144개 파일 → 32개 그룹, heavy=24 / standard=82 / light=38. 궁합 엔진/사주 계산/firestore.rules → heavy, UI 화면·Repository → standard, 상수·DTO·번역 → light 로 분류됨. Opus 분류기가 경로만 보고 도메인 구조를 정확히 추론.

### Changed — CHANGELOG.md 를 sync 대상에 포함, "템플릿 도구 이력 전용" 으로 정의 (2026-04-10)

이전 규칙은 `CHANGELOG.md` 를 sync 제외였음. 이유는 "프로젝트별 이력이라 동기화하면 안 된다" 였는데, 실제로 OJAK CHANGELOG 의 모든 entry 가 템플릿 도구 변경(`run.py`, hook, CLAUDE.md, --auto-merge 등) 이고 OJAK 도메인 이력은 한 줄도 없었음. 사용자가 "템플릿 폴더 안에서도 changelog 가 남아야 한다" 고 지적하며 모순 발견.

**변경**:
- `~/.claude/hooks/sync_orchestrator.py` 의 `SYNC_ROOT_FILES` 에 `CHANGELOG.md` 추가 → 이제 OJAK CHANGELOG 변경 시 template CHANGELOG 도 자동 동기화
- `CLAUDE.md` "템플릿 자동 동기화 규칙" 섹션에서 "CHANGELOG.md 는 동기화하지 않는다" 문구 제거
- `CLAUDE.md` "CHANGELOG 자동 기록 규칙" 섹션에 정의 명확화 추가:
  - **CHANGELOG.md 는 템플릿 도구/워크플로우 변경 이력 전용**
  - 도메인 코드(`lib/`, `functions/` 등) 변경은 git log + HANDOFF.md 담당
  - 동기화 대상이므로 모든 후속 프로젝트가 동일한 도구 이력 공유
  - 기록 대상 파일 목록에 `~/.claude/hooks/`, `~/.claude/settings.json` 추가

**왜 이게 옳은가**: CHANGELOG 의 의미를 "이 프로젝트에서 일어난 모든 변경" 이 아니라 "이 프로젝트가 의존하는 도구의 변경" 으로 좁히면, 모든 후속 프로젝트가 동일한 CHANGELOG 를 공유하는 게 당연해짐. 도메인 작업 이력은 어차피 git log 가 정확하고 풍부함.

### Fixed — 템플릿 자동 동기화 hook 안정화 (2026-04-10)

`~/.claude/settings.json` 의 `PostToolUse` hook (`sync_orchestrator.py`) 이 그동안 실제로 호출되지 않고 있었음. 수동 stdin 시뮬레이션으로는 정상 동작하지만 Claude Code 가 자동 트리거할 때만 fail 하는 silent 문제. OJAK 작업 도중 발견.

**원인 (3중 복합)**:

1. **매처 형식 문제**: `"matcher": "Edit|Write"` 정규식 OR 가 매칭 안 됨 → hook entry 자체가 등록 안 됨
2. **Windows path escape 깨짐**: `"command": "python C:\\Users\\..\\hooks\\sync.py"` 가 bash/Python 으로 전달될 때 `\U`, `\k`, `\.`, `\h` 가 escape sequence 로 처리되어 path 가 망가짐 (`Userskkhho.claudehookssync.py` 같은 형태)
3. **spec 외 키**: `"async": true` 가 공식 spec 에 없는 키라서 hook entry 검증 단계에서 silent rejection 가능 (확정은 아니지만 제거)

**수정**:
- `~/.claude/settings.json` PostToolUse 매처를 `"Edit"`/`"Write"`/`"MultiEdit"` 세 entry 로 분리
- `~/.claude/hooks/sync.bat` wrapper 신규 작성 — settings.json command 는 단순히 `.bat` forward-slash 경로만 가리키고, 실제 python 호출은 `.bat` 안에서 quoted 절대경로로 격리
- `"async": true` 제거, `"timeout": 30` 추가
- `~/.claude/hooks/sync_orchestrator.py` 에 진단 로그 영구 추가 (`sync_orchestrator.log`) — 호출/실패/성공을 모두 기록해서 다음 사고 시 즉시 진단 가능

**보편 가이드 반영 (다음 프로젝트 예방)**:
- `WORKFLOW_GUIDE.md` 트러블슈팅에 "템플릿 자동 동기화가 작동 안 함" 항목 추가
  - 점검 순서, 매처 분리, spec 외 키 제거, Windows path escape, timeout 명시, 핫리로드 한계, 권장 settings 형태까지 모두 포함
- 후속 프로젝트가 hook 자동화 셋업 시 이 함정을 첫날부터 회피할 수 있도록 명시

**왜 이게 중요한가**: 단일 워크플로우(`--patch --auto-merge`)는 `run.py`/`CLAUDE.md`/`WORKFLOW_GUIDE.md` 의 자동 동기화에 의존함. 동기화가 안 되면 OJAK 에서 개선한 워크플로우가 다음 프로젝트로 전파되지 않고, 같은 문제를 매번 다시 발견·수정해야 함. 자동화의 자동화가 깨져 있던 것.

### Added — `--auto-merge` 옵션 + 단일 워크플로우 라우팅 규칙 (2026-04-10)

수정 모드(`--patch`)와 신규 생성 모드 모두에서 사용 가능한 `--auto-merge` 플래그 추가.
성공한 그룹의 브랜치를 현재 HEAD 에 자동 머지 + worktree 제거 + 머지된 브랜치 삭제까지 한 번에 처리.

**왜**: 단일 워크플로우(코드 수정은 항상 `--patch` 통과) 채택 시 매번 `git merge` 를 사용자가 수동으로 치는 마찰이 너무 큼. `flutter run` 의 `r`/`R` 핫리로드 사이클과 자연스럽게 이어지려면 머지가 자동이어야 함.

**무엇**:
- `orchestrator/run.py` 에 `auto_merge_and_cleanup()` 함수 추가
  - 성공 그룹마다 `git merge --no-edit <branch>` 실행
  - 충돌 시 `git merge --abort` + 사용자에게 수동 머지 명령 안내 출력
  - 머지 성공 후 `git worktree remove` (실패 시 `--force` 폴백)
  - `git branch -d` 로 머지된 브랜치 정리
- `--auto-merge` CLI 플래그 추가, `patch_main()` 와 `main()` 양쪽에서 사용
- `CLAUDE.md` 에 "코드 수정 라우팅 규칙 (단일 워크플로우)" 섹션 추가
  - 코드 파일 수정 = 항상 `--patch --auto-merge` 강제
  - 메타 문서/질문/탐색만 직접 처리 허용
  - 사용자가 명시적으로 "직접 수정해줘" 라고 말한 경우만 예외
- `WORKFLOW_GUIDE.md` 의 수정 모드 섹션에 `--auto-merge` 사용법과 단일 워크플로우 권장 흐름 반영

**영향**:
- 사용자 흐름: 코드 수정 요청 → 분류기/워커 자동 → 자동 머지 → 터미널에서 `r`/`R` 만 누름
- 채팅 모델(Sonnet)을 유지하면서도 보안/도메인 코드는 Opus 워커, 단순 수정은 Haiku 워커가 자동 처리됨
- 1줄 수정도 ~1분 + 토큰 비용 부과 — 트레이드오프를 받아들임

### Added — 오케스트레이터 수정 모드(--patch) 추가 (2026-04-10)

지금까지 오케스트레이터는 신규 생성 전용(HANDOFF.md → worktree 병렬 생성)이었음.
파일 수정 요청도 동일한 병렬 워커 구조로 처리하기 위해 수정 모드를 추가.

**왜**: 일상적인 수정 요청(색상 변경, 텍스트 수정 등)도 채팅창 자유 텍스트 한 줄로
worker_map.json 기반 자동 라우팅 → 영향받는 그룹만 worktree 병렬 수정 → merge 흐름을 재사용하기 위해.

**무엇**:
- `orchestrator/worker_map.json` 자동 생성: 신규 생성 모드 성공 후 `save_worker_map()` 가
  성공한 그룹의 `files_modified` 를 `{파일경로: {group_id, profile, model}}` 형태로 누적 저장.
- `--patch "수정 텍스트"` CLI 인자 추가. `patch_main()` 진입점.
- `patch_classify()`: claude-opus-4-6 으로 수정 요청 + worker_map 을 분석해
  영향받는 그룹과 그룹별 instruction 을 추출.
- `patch_worker()`: 기존 파일 내용을 worktree 에서 읽어 컨텍스트로 전달, 변경된 파일만
  전체 내용으로 응답받아 적용. 브랜치 prefix `patch/`, 커밋 메시지 `patch(group_X): ...`.
- `update_worker_map_after_patch()`: 수정 모드에서 새로 생긴 파일을 worker_map 에 추가.
- `append_patch_history()`: 성공 시 HANDOFF.md 의 `## 수정 이력` 섹션 최상단에
  요청/그룹/파일/브랜치 기록 자동 추가.
- `create_worktree()` 에 `prefix` 인자 추가 (기본 `auto`, 수정 모드는 `patch`).

### Added — 템플릿 자동 동기화 규칙 (2026-04-10)

`C:\dev\flutter-agent-template` 에 `orchestrator/run.py`, `CLAUDE.md`, `WORKFLOW_GUIDE.md` 변경 시
사용자 지시 없이 자동 동기화 + 커밋/푸시하도록 `CLAUDE.md` 에 규칙 추가.
이전 대화에서 합의했으나 문서화되지 않았던 내용을 명시적으로 기록.

### Changed — 오케스트레이터 완료 시 Windows 시스템 사운드 추가 (2026-04-10)

보고서 출력 후 `winsound.MessageBeep`으로 완료 소리 발생 (Python 내장, 별도 설치 없음).
성공 시 정보음(`MB_ICONASTERISK`), 실패 포함 시 에러음(`MB_ICONHAND`) 으로 결과 구분.
OS 트레이 balloon(이전에 추가했다가 제거)과 달리 시각적 팝업 없이 소리만 냄.

### Changed — 오케스트레이터 실행 흐름 완전 자동화: 확인 단계 제거 (2026-04-10)

"실행해줘" 이후 dry-run 확인 및 사용자 승인 단계를 완전히 제거.
`uv run run.py` 한 번으로 분류 → 실행 → 보고서 채팅 출력까지 자동 처리.
중간 알림 없이 완료 시 채팅 보고서 1회 + 완료음 1회만 발생.

- CLAUDE.md: 5단계 흐름 → 3단계로 축소 (HANDOFF 확인 → 실행 → 보고)
- WORKFLOW_GUIDE.md: Step 4(dry-run 확인) + Step 5(승인 후 실행) → Step 4(실행) 로 병합

### Changed — 오케스트레이터 완료 알림: Claude Code 팝업 → Windows OS 트레이 알림 (2026-04-10)

Claude Code 팝업 과다 문제 해결: 실행은 백그라운드 터미널에서 진행하고
완료 시 `_notify_completion()` 함수가 Windows 트레이 balloon 알림 1회만 표시.

- `run.py` `print_report()` 끝에 `_notify_completion(success, errors)` 호출 추가
- `_notify_completion()`: PowerShell `NotifyIcon` 으로 트레이 알림 표시 (8초 지속)
  - 성공만: "✓ N개 모두 성공"
  - 실패 포함: "✓ N개 성공 / ✗ N개 실패"
  - 알림 실패 시 조용히 pass (로그에는 이미 출력됨)
- CLAUDE.md 흐름: 승인 후 Claude Code 역할 즉시 종료, OS 알림 수신 후 "결과 봐줘" 요청

**효과**: 실행 중 Claude Code 팝업 0회, 완료 시 OS 알림 1회

### Added — --only-groups 필터 및 디렉토리 경로 처리 (2026-04-10)

`--only-groups group_2,group_8` 형태로 특정 그룹만 재실행할 수 있는 CLI 인자 추가.
실패한 그룹만 골라 재실행할 때 전체 재분류 + 전체 재실행 낭비를 없앰.

- `--only-groups` 인자: 쉼표 구분 group ID 목록으로 classify 결과를 필터링
- `main()` 시그니처에 `only_groups: list[str] | None` 파라미터 추가
- 워커 파일 쓰기 시 경로가 `/` 로 끝나면 디렉토리 생성 후 skip (PermissionError 방지)
- 워커 system prompt에 "디렉토리 경로는 실제 파일명을 붙여 반환" 지시 추가

**근본 원인**: HANDOFF.md에 `functions/src/seed/` 처럼 디렉토리 경로가 파일 목록에
포함되면 모델이 해당 경로를 파일로 write_text 시도 → Windows PermissionError 발생.

### Fixed — max_tokens=32000 + 스트리밍 모드로 대형 그룹 처리 (2026-04-10)

파일 5개+ 그룹이 16K 토큰을 초과해 계속 max_tokens 잘림 오류 발생하던 문제 해결.

- `max_tokens` 16000 → **32000** (50K+ 문자 응답도 완전 수신)
- `max_tokens >= 16000` 시 SDK 요구사항에 따라 자동으로 스트리밍 사용:
  `async with client.messages.stream(**params) as stream: return await stream.get_final_message()`
- `ValueError: Streaming is required for operations that may take longer than 10 minutes` 해결

**근본 원인**: Anthropic SDK가 max_tokens × rate_limit 으로 예상 소요 시간을 계산해
스트리밍 없이는 요청 자체를 차단함. 32K 토큰 요청을 Tier1 8K/min 한도로 나누면
4분 소요 → SDK가 스트리밍 강제. `client.messages.stream()` 으로 전환 후 정상 동작.

**영향**: 가장 큰 그룹들(Firebase 전체 백엔드 24파일, 온보딩 11파일)도 4분 내 완료.

### Fixed — concurrency=1 시 worker 중복 실행 및 프로세스 관리 (2026-04-10)

Windows에서 `asyncio.Semaphore(1)`이 예상대로 동작하지 않아 여러 group worker가 동시에 시작되는 문제 해결.

- `concurrency=1` 시 `asyncio.gather()` 대신 단순 `for` 순차 루프 사용 (경쟁 조건 완전 제거)
- `run.lock` 파일로 중복 실행 방지 추가 — 기존 실행 중에는 새 실행 차단
- `run.lock`을 `.gitignore`에 추가

**근본 원인**: Windows asyncio에서 Semaphore가 await 중 release되는 것으로 보이거나, 복수의 Python 프로세스가 동시에 log/worktree를 공유하면서 혼선 발생.

### Fixed — classify_tasks max_tokens 부족 및 instructions 필드 제거 (2026-04-10)

`classify_tasks` 응답이 반복적으로 `stop_reason=max_tokens` 로 잘리던 문제 해결.
- `instructions` 필드 제거: 워커가 직접 HANDOFF.md에서 태스크 섹션을 추출하므로 classify 단계에서 중복 생성할 필요 없음
- `max_tokens` 6000 → **8000** (Tier1 최대치; instructions 제거로 실제 4~5K 사용)
- `_extract_task_sections()` 추가: `group['tasks']` 이름 목록으로 HANDOFF.md의 `### 과제 N:` 섹션을 검색해 워커 지시사항으로 전달
- `run_worker(handoff_content)` 파라미터 추가, `run_with_semaphore`에서 전달

**근본 원인**: 20개 그룹 × instructions(2~3문장) = 응답 5000~6000 토큰. 기존 max_tokens(4000→6000)으로는 부족했음.

### Added — WORKFLOW_GUIDE.md + 자동 업데이트 규칙 (2026-04-10)

후속 프로젝트들이 동일한 워크플로우를 재현할 수 있도록 `WORKFLOW_GUIDE.md`
신규 추가. 사전 준비, 8단계 실행 흐름, 트러블슈팅, 동시성/비용 가이드, FAQ,
체크리스트를 포함한 자기완결적 문서.

`CLAUDE.md` 에 "WORKFLOW_GUIDE.md 수정 규칙" 섹션 추가:
- **역할 분리**: `WORKFLOW_GUIDE.md` 는 현재 사용법만 담은 깔끔한 최종본,
  `CHANGELOG.md` 가 모든 변경 이력의 단일 출처
- 가이드 본문은 그대로 덮어쓰기/교체 (strikethrough 사용 안 함)
- 모든 변경은 CHANGELOG `[Unreleased]` 에 반드시 함께 기록
- 자동 트리거: `orchestrator/run.py` 동작 변경, HANDOFF.md 형식 변경,
  새 트러블슈팅 발견, 비용/시간 실측 어긋남, 새 명령어/옵션 추가

### Added — CHANGELOG 자동 기록 규칙 (2026-04-10)

`CLAUDE.md` 에 CHANGELOG 자동 기록 규칙 섹션 추가. 앞으로 `orchestrator/`,
`CLAUDE.md`, `HANDOFF.md`, `pyproject.toml` 변경 시 사용자가 별도 요청하지
않아도 Claude 가 `[Unreleased]` 섹션에 변경 내역을 자동으로 기록한다.
릴리즈 승격(`[Unreleased]` → `[0.X.0]`) 규칙도 함께 정의.

### Changed — orchestrator/run.py 안정화 (2026-04-10)

OJAK 프로젝트에서 19개 그룹 동시 실행을 검증하면서 발견한 문제들을 모두 반영.

#### 분류 단계 (`classify_tasks`)
- `max_tokens` 4096 → **16000** (thinking 토큰 소진으로 빈 응답 반환되던 문제 해결)
- thinking 비활성화 (분류는 단순 작업, 토큰 낭비 방지)
- system 프롬프트에 출력 길이 제약 추가
  - `instructions` 필드 3~5문장 제한
  - `reason` 필드 1문장 제한
  - 응답 전체 4000토큰 이내
- 빈 응답/파싱 실패 시 `stop_reason`, content blocks, tail 출력으로 디버그 가능

#### 워커 (`run_worker`)
- `max_tokens` 8096 → **16000** (그룹당 파일 10개+ 처리 시 잘림 방지)
- 전체 본문 `try/except` 로 감싸 모든 예외를 통일된 error dict 로 변환
- 다음 케이스를 각각 명확한 에러 메시지로 분리:
  - 빈 응답 (`stop_reason` 표시)
  - `stop_reason == 'max_tokens'` 잘림 감지
  - JSON 파싱 실패 (tail 출력)
  - `result['files']` 가 비어있음
- `_detect_lang()` 헬퍼 추가 — 확장자별 코드 펜스 언어 결정
  - `.dart` → dart, `.ts` → typescript, `.json` → json, `.yaml` → yaml 등
  - TypeScript Functions 코드를 dart 펜스로 감싸 모델 혼동시키던 문제 해결
- system 프롬프트에 "Flutter/Dart 및 TypeScript 전문" + "마크다운 펜스 금지" 명시
- `git commit` 결과 검사 — `"nothing to commit"` 은 정상 통과, 그 외 실패는 에러로 변환

#### API 재시도 (신규: `_create_with_retry`)
- `anthropic.RateLimitError`, `APIStatusError` 의 `429/500/502/503/504/529` 자동 재시도
- `APIConnectionError` 도 재시도
- 백오프: `(2 ** attempt) + random.uniform(0, 1.5)` 초
- 최대 5회 재시도, 매 시도마다 진행 로그 출력
- `random` 모듈 import 추가

#### Worktree 안전성 (`create_worktree`)
- 타임스탬프에 초 추가 (`%m%d-%H%M%S`) — 동시 실행 시 경로 충돌 방지
- 기존 경로 존재 시 `git worktree remove --force` 로 자동 정리 (재실행 가능)
- `subprocess.run` 결과 명시적 검사, 실패 시 `RuntimeError` raise

#### 동시성 제어
- `--concurrency` CLI 인자 추가 (기본값 **8**, 기존 4)
- `main()` 시그니처에 `concurrency` 파라미터 전달
- `asyncio.Semaphore(concurrency)` 사용

#### `gather` 안전화
- `run_with_semaphore` 내부에 `try/except` 추가 — 워커 미처리 예외도 error dict 로 변환
- `asyncio.gather(..., return_exceptions=True)` — 워커 1개 실패가 전체 실행을 중단시키던 문제 해결
- 결과 순회 시 `BaseException` 인스턴스를 별도 error dict 로 변환

### 영향

- 동시성 8 기본값으로 19개 그룹 처리 시 실행 시간 약 50% 단축
- API rate limit 자동 처리로 수동 재실행 불필요
- 워커 1개 실패가 전체를 죽이지 않아 부분 성공 후 실패 그룹만 재실행 가능
- 디버그 정보 충실화로 실패 원인 즉시 파악 가능

### 마이그레이션

기존 사용자는 코드 변경 없이 그대로 사용 가능. 동시성 조정은 옵션:

```bash
uv run run.py --concurrency 4    # 보수적 (기존 동작)
uv run run.py                    # 기본 (8)
uv run run.py --concurrency 12   # 공격적
```

---

## [0.1.0] — 2026-04-XX

### Added
- Flutter 멀티에이전트 오케스트레이터 템플릿 초기 버전
- `orchestrator/run.py` — HANDOFF.md 분석 → 그룹 분류 → git worktree 병렬 실행
- `CLAUDE.md` — 오케스트레이터 실행 흐름 정의
- `HANDOFF.md` — 작업 인계 형식 템플릿
