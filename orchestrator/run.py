"""
Flutter 프로젝트 멀티에이전트 오케스트레이터
----------------------------------------------
Claude Code for VS Code 채팅창에서 호출됩니다.

사용법:
  uv run run.py                       # HANDOFF.md 자동 감지 (신규 생성 모드)
  uv run run.py --dry-run             # 과제 분류만 확인
  uv run run.py --report              # 마지막 실행 보고서 출력
  uv run run.py --patch "..."         # 수정 모드: 자유 텍스트로 기존 파일 수정
  uv run run.py --cost                # 누적 API 비용 리포트 출력
  uv run run.py --build-worker-map    # 브라운필드 프로젝트용 worker_map.json 1회성 생성
"""

import argparse
import asyncio
import json
import os
import random
import subprocess
import sys
from pathlib import Path
from datetime import datetime, timedelta

import anthropic

# ── 설정 ────────────────────────────────────────────────────────────────────

ORCHESTRATOR_MODEL = "claude-opus-4-6"
ANTHROPIC_API_KEY  = os.environ.get("ANTHROPIC_API_KEY", "")
REPORT_PATH        = Path(__file__).parent / "last_report.json"
USAGE_HISTORY_PATH = Path(__file__).parent / "usage_history.jsonl"
LOG_PATH           = Path(__file__).parent / "last_run.log"
WORKER_MAP_PATH    = Path(__file__).parent / "worker_map.json"

# ── API 토큰 사용량 / 비용 계산 ─────────────────────────────────────────────

# USD per million tokens
PRICING = {
    "claude-opus-4-6": {
        "input": 15.0,
        "output": 75.0,
        "cache_read": 15.0 * 0.1,
        "cache_creation": 15.0 * 1.25,
    },
    "claude-sonnet-4-6": {
        "input": 3.0,
        "output": 15.0,
        "cache_read": 3.0 * 0.1,
        "cache_creation": 3.0 * 1.25,
    },
    "claude-haiku-4-5-20251001": {
        "input": 0.8,
        "output": 4.0,
        "cache_read": 0.8 * 0.1,
        "cache_creation": 0.8 * 1.25,
    },
}

_usage_by_model: dict[str, dict] = {}


def compute_total_cost() -> dict:
    """_usage_by_model 과 PRICING 을 기반으로 총 토큰 / 총 비용 계산."""
    total_input = 0
    total_output = 0
    total_cache_read = 0
    total_cache_creation = 0
    total_cost = 0.0
    by_model: dict[str, dict] = {}

    for model, usage in _usage_by_model.items():
        inp = usage.get("input_tokens", 0)
        out = usage.get("output_tokens", 0)
        cr = usage.get("cache_read_input_tokens", 0)
        cc = usage.get("cache_creation_input_tokens", 0)

        total_input += inp
        total_output += out
        total_cache_read += cr
        total_cache_creation += cc

        pricing = PRICING.get(model, {})
        cost = (
            inp * pricing.get("input", 0.0) / 1_000_000
            + out * pricing.get("output", 0.0) / 1_000_000
            + cr * pricing.get("cache_read", 0.0) / 1_000_000
            + cc * pricing.get("cache_creation", 0.0) / 1_000_000
        )
        total_cost += cost

        by_model[model] = {
            "input_tokens": inp,
            "output_tokens": out,
            "cache_read_tokens": cr,
            "cache_creation_tokens": cc,
            "cost_usd": cost,
        }

    return {
        "total_input_tokens": total_input,
        "total_output_tokens": total_output,
        "total_cache_read_tokens": total_cache_read,
        "total_cache_creation_tokens": total_cache_creation,
        "total_cost_usd": total_cost,
        "by_model": by_model,
    }


# ── 누적 비용 추적 ──────────────────────────────────────────────────────────

def append_usage_history(mode: str) -> None:
    """현재 _usage_by_model 이 비어있지 않으면 usage_history.jsonl 에 한 줄 append."""
    if not _usage_by_model:
        return
    cost_data = compute_total_cost()
    entry = {
        "timestamp": datetime.now().isoformat(),
        "mode": mode,
        "cost": cost_data,
    }
    with USAGE_HISTORY_PATH.open("a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")


def load_cumulative_cost(since_days: int | None = None) -> dict:
    """USAGE_HISTORY_PATH 의 JSONL 을 읽어 비용을 누적 합산."""
    result = {
        "total_runs": 0,
        "total_cost_usd": 0.0,
        "total_input_tokens": 0,
        "total_output_tokens": 0,
        "total_cache_read_tokens": 0,
        "total_cache_creation_tokens": 0,
        "by_model": {},
        "first_run_timestamp": None,
        "last_run_timestamp": None,
    }

    if not USAGE_HISTORY_PATH.exists():
        return result

    cutoff = None
    if since_days is not None:
        cutoff = datetime.now() - timedelta(days=since_days)

    lines = USAGE_HISTORY_PATH.read_text(encoding="utf-8").strip().splitlines()
    for line in lines:
        line = line.strip()
        if not line:
            continue
        try:
            entry = json.loads(line)
        except json.JSONDecodeError:
            continue

        ts_str = entry.get("timestamp", "")
        if cutoff is not None and ts_str:
            try:
                ts = datetime.fromisoformat(ts_str)
                if ts < cutoff:
                    continue
            except (ValueError, TypeError):
                continue

        cost = entry.get("cost", {})
        result["total_runs"] += 1
        result["total_cost_usd"] += cost.get("total_cost_usd", 0.0)
        result["total_input_tokens"] += cost.get("total_input_tokens", 0)
        result["total_output_tokens"] += cost.get("total_output_tokens", 0)
        result["total_cache_read_tokens"] += cost.get("total_cache_read_tokens", 0)
        result["total_cache_creation_tokens"] += cost.get("total_cache_creation_tokens", 0)

        if result["first_run_timestamp"] is None:
            result["first_run_timestamp"] = ts_str
        result["last_run_timestamp"] = ts_str

        for model, info in cost.get("by_model", {}).items():
            if model not in result["by_model"]:
                result["by_model"][model] = {
                    "input_tokens": 0,
                    "output_tokens": 0,
                    "cache_read_tokens": 0,
                    "cache_creation_tokens": 0,
                    "cost_usd": 0.0,
                }
            bucket = result["by_model"][model]
            bucket["input_tokens"] += info.get("input_tokens", 0)
            bucket["output_tokens"] += info.get("output_tokens", 0)
            bucket["cache_read_tokens"] += info.get("cache_read_tokens", 0)
            bucket["cache_creation_tokens"] += info.get("cache_creation_tokens", 0)
            bucket["cost_usd"] += info.get("cost_usd", 0.0)

    return result


def print_cost_report() -> None:
    """누적 API 비용 리포트를 콘솔에 출력."""
    print(f"\n{'═'*55}")
    print(f"  ═══ 누적 API 비용 리포트 ═══")
    print(f"{'═'*55}")

    model_display_names = {
        "claude-opus-4-6": "Opus",
        "claude-sonnet-4-6": "Sonnet",
        "claude-haiku-4-5-20251001": "Haiku",
    }

    for label, since_days in [("전체", None), ("최근 30일", 30), ("최근 7일", 7)]:
        data = load_cumulative_cost(since_days=since_days)
        print(f"\n[ {label} ]")
        if data["total_runs"] == 0:
            print(f"  (기록 없음)")
            continue
        print(f"  실행 횟수: {data['total_runs']}회")
        if data["first_run_timestamp"]:
            print(f"  기간: {data['first_run_timestamp'][:19]} ~ {data['last_run_timestamp'][:19]}")
        print(f"  총 비용: {data['total_cost_usd']:.4f} USD")
        print(f"  총 입력: {data['total_input_tokens']:,} tokens")
        print(f"  총 출력: {data['total_output_tokens']:,} tokens")
        print(f"  캐시 읽기: {data['total_cache_read_tokens']:,} tokens")
        print(f"  캐시 생성: {data['total_cache_creation_tokens']:,} tokens")
        if data["by_model"]:
            print(f"  모델별:")
            for model, info in data["by_model"].items():
                display = model_display_names.get(model, model)
                in_k = info["input_tokens"] / 1000
                out_k = info["output_tokens"] / 1000
                cost = info["cost_usd"]
                print(f"    {display}: {in_k:.1f}K in / {out_k:.1f}K out -> {cost:.4f} USD")

    print(f"\n{'═'*55}\n")


class _Tee:
    """stdout 출력을 화면과 로그 파일에 동시에 기록."""
    def __init__(self, log_path: Path):
        self._file = log_path.open("w", encoding="utf-8", buffering=1)
        self._stdout = sys.stdout
    def write(self, data):
        self._stdout.write(data)
        self._file.write(data)
    def flush(self):
        self._stdout.flush()
        self._file.flush()
    def close(self):
        self._file.close()

def _setup_log():
    tee = _Tee(LOG_PATH)
    sys.stdout = tee
    return tee

def strip_code_fences(text: str) -> str:
    """Claude가 ```json ... ``` 으로 감싸 응답할 경우 펜스 제거."""
    text = text.strip()
    if text.startswith("```"):
        lines = text.split("\n")
        # 첫 줄(```json 또는 ```) 제거
        lines = lines[1:]
        # 마지막 ``` 제거
        if lines and lines[-1].strip().startswith("```"):
            lines = lines[:-1]
        text = "\n".join(lines).strip()
    return text


# Delimiter 마커 — 문자열 concatenation 으로 분리해서 이 파일을 워커가 재출력할 때
# 단일 소스 라인에 완전한 마커 리터럴이 나타나지 않도록 한다 (자기참조 회피).
_M_BRA = "<<" + "<"
_M_KET = ">" + ">>"
_M_META = _M_BRA + "META" + _M_KET
_M_FILE_PFX = _M_BRA + "FILE:"
_M_END = _M_BRA + "END" + _M_KET


def parse_worker_response(raw: str) -> dict:
    """워커 응답 파서 — delimiter 포맷 + JSON 폴백.

    신 포맷은 META 블록 + 여러 FILE 블록 + END 마커로 구성된다.
    실제 마커 리터럴은 _M_META / _M_FILE_PFX / _M_END 상수 참조.
    파일 내용에 개행/따옴표/백슬래시가 자유롭게 들어갈 수 있어
    JSON 문자열 이스케이프 문제를 근본적으로 회피한다.
    """
    raw = raw.strip()

    # 신 포맷 감지
    if _M_META in raw or _M_FILE_PFX in raw:
        result: dict = {"summary": "", "changes": [], "files": {}}
        mode: str | None = None  # "meta" | "file" | None
        meta_buf: list[str] = []
        current_file: str | None = None
        file_buf: list[str] = []

        def _flush_meta():
            nonlocal meta_buf
            if meta_buf:
                try:
                    meta_json = json.loads("\n".join(meta_buf).strip())
                    result["summary"] = meta_json.get("summary", "")
                    result["changes"] = meta_json.get("changes", [])
                except json.JSONDecodeError:
                    pass
                meta_buf = []

        def _flush_file():
            nonlocal current_file, file_buf
            if current_file is not None:
                result["files"][current_file] = "\n".join(file_buf)
                current_file = None
                file_buf = []

        for line in raw.split("\n"):
            stripped = line.strip()
            if stripped == _M_META:
                _flush_file()
                mode = "meta"
                continue
            if stripped.startswith(_M_FILE_PFX) and stripped.endswith(_M_KET):
                _flush_meta()
                _flush_file()
                current_file = stripped[len(_M_FILE_PFX):-len(_M_KET)].strip()
                mode = "file"
                continue
            if stripped == _M_END:
                _flush_meta()
                _flush_file()
                mode = None
                break
            if mode == "meta":
                meta_buf.append(line)
            elif mode == "file":
                file_buf.append(line)

        # END 마커 없어도 마지막 버퍼 플러시
        _flush_meta()
        _flush_file()
        return result

    # 구 포맷 폴백 (순수 JSON) — 소형 응답에서만 안전
    return json.loads(raw)


def _worker_format_guide(modify_mode: bool = False) -> str:
    """워커 시스템 프롬프트의 포맷 가이드를 constants 로 동적 구성.

    소스에 마커 리터럴을 남기지 않아 워커가 이 파일을 재출력해도 파서가
    자기 자신을 중단시키지 않는다.
    """
    verb = "수정된" if modify_mode else ""
    only_changed = (
        "\n- 변경이 필요한 파일만 FILE 블록으로 포함 (수정 없는 파일 절대 금지)"
        if modify_mode else ""
    )
    return (
        "반드시 아래 delimiter 포맷으로만 응답하세요. 마크다운 코드펜스 금지.\n"
        "\n"
        f"{_M_META}\n"
        '{"summary": "작업 요약 (1~2문장)", "changes": ["변경사항 1", "변경사항 2"]}\n'
        f"{_M_FILE_PFX}lib/path/to/file.dart{_M_KET}\n"
        f"<{verb} 전체 파일 내용을 이스케이프 없이 그대로 작성 — 따옴표/개행/백슬래시 모두 raw>\n"
        f"{_M_FILE_PFX}lib/path/to/other.dart{_M_KET}\n"
        f"<{verb} 전체 파일 내용>\n"
        f"{_M_END}\n"
        "\n"
        "절대 규칙:\n"
        "- META 블록 안에만 JSON 사용 (summary, changes 필드만, 한 줄 권장)\n"
        "- 파일 내용은 절대 JSON 문자열로 감싸지 말 것. 원본 코드 그대로 출력.\n"
        "- 파일 구분자는 FILE:경로 형식 (경로에 따옴표 금지)\n"
        f"- 응답은 반드시 END 마커로 종료{only_changed}"
    )


MODEL_PROFILES = {
    "heavy": {
        "model": "claude-opus-4-6",
        "thinking": False,   # Tier1: output 8K/min 한도 — thinking 비활성화
        "effort": "high",
        "description": "아키텍처 설계, 보안 분석, 복잡한 리팩토링",
    },
    "standard": {
        "model": "claude-sonnet-4-6",
        "thinking": False,   # Tier1: output 8K/min 한도 — thinking 비활성화
        "effort": "medium",
        "description": "일반 기능 구현, 버그 수정, UI 작업",
    },
    "light": {
        "model": "claude-haiku-4-5-20251001",
        "thinking": False,
        "effort": None,
        "description": "변수명 변경, 단순 수정, 파일 읽기",
    },
}

# ── 과제 분류 ────────────────────────────────────────────────────────────────

async def classify_tasks(client: anthropic.AsyncAnthropic, handoff_content: str) -> list[dict]:
    print("[ 1/4 ] 과제 분류 및 모델 선택 중...")

    response = await _create_with_retry(client, dict(
        model=ORCHESTRATOR_MODEL,
        max_tokens=8000,  # Tier1 최대치. instructions 제거로 실제 4~5K 사용 예상
        system="""당신은 Flutter 프로젝트의 작업 분류 전문가입니다.
HANDOFF.md를 분석해서 과제들을 병렬 실행 가능한 그룹으로 묶고,
각 그룹에 적합한 모델 프로필을 선택하세요.

모델 프로필 기준:
- heavy (Opus): 아키텍처 설계, 보안 분석, 복잡한 리팩토링
- standard (Sonnet): 일반 기능 구현, 버그 수정, UI 작업
- light (Haiku): 변수명 변경, 단순 수정, 파일 읽기

규칙:
- 같은 파일을 건드리는 과제는 반드시 같은 그룹에 묶기
- 독립적인 과제는 별도 그룹으로 분리 (병렬 실행됨)
- reason 필드는 1문장으로 간결하게
- description 필드는 10단어 이내
- tasks 필드는 HANDOFF.md의 과제 제목(### 과제 N: ...) 그대로 기재

JSON만 출력하세요. 마크다운 펜스 금지. 형식:
{
  "groups": [
    {
      "id": "group_1",
      "description": "그룹 설명 (1줄)",
      "profile": "heavy | standard | light",
      "reason": "선택 이유 (1문장)",
      "tasks": ["과제 1: Flutter 프로젝트 초기화"],
      "files": ["lib/path/to/file.dart"]
    }
  ]
}""",
        messages=[
            {"role": "user", "content": f"다음 HANDOFF.md를 분석해주세요:\n\n{handoff_content}"}
        ],
    ), "classify_tasks")

    raw = strip_code_fences(next((b.text for b in response.content if b.type == "text"), ""))

    if not raw:
        print(f"         ⚠ 빈 응답. content blocks:")
        for b in response.content:
            print(f"           - type={b.type}")
            if hasattr(b, "text"):
                print(f"             text[:200]={b.text[:200]!r}")
        print(f"         stop_reason={response.stop_reason}")
        sys.exit(1)

    try:
        data = json.loads(raw)
        groups = data.get("groups", [])
        print(f"         → {len(groups)}개 그룹 분류 완료\n")
        for g in groups:
            profile = MODEL_PROFILES[g["profile"]]
            print(f"         • {g['id']} [{g['profile'].upper()}] {profile['model']}")
            print(f"           {g['description']}")
            print(f"           파일: {', '.join(g['files'])}")
            print(f"           이유: {g['reason']}\n")
        return groups
    except json.JSONDecodeError:
        print(f"         ⚠ JSON 파싱 실패. stop_reason={response.stop_reason}, len={len(raw)}")
        print(f"         tail: ...{raw[-300:]!r}")
        sys.exit(1)

# ── Git Worktree ─────────────────────────────────────────────────────────────

def get_project_root() -> Path:
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        capture_output=True, text=True, encoding="utf-8"
    )
    if result.returncode != 0:
        print("⚠  git 저장소를 찾을 수 없습니다.")
        sys.exit(1)
    return Path(result.stdout.strip())

def create_worktree(project_root: Path, group_id: str, prefix: str = "auto") -> tuple[Path, str]:
    timestamp     = datetime.now().strftime('%m%d-%H%M%S')
    branch_name   = f"{prefix}/{group_id}-{timestamp}"
    # 프로젝트 내부 .worktrees/ 에 생성 (C:\dev\ 에 폴더가 흩어지지 않도록)
    worktrees_root = project_root / ".worktrees"
    worktrees_root.mkdir(exist_ok=True)
    worktree_path = worktrees_root / f"{prefix}-{group_id}-{timestamp}"

    # 이미 존재하면 (이전 실패 잔재) 정리
    if worktree_path.exists():
        subprocess.run(
            ["git", "worktree", "remove", "--force", str(worktree_path)],
            cwd=project_root, capture_output=True,
        )

    result = subprocess.run(
        ["git", "worktree", "add", "-b", branch_name, str(worktree_path)],
        cwd=project_root, capture_output=True, text=True, encoding="utf-8",
    )
    if result.returncode != 0:
        raise RuntimeError(
            f"worktree 생성 실패 ({group_id}): {result.stderr.strip()}"
        )
    return worktree_path, branch_name

# ── 서브에이전트 실행 ────────────────────────────────────────────────────────

def _detect_lang(file_rel: str) -> str:
    """파일 확장자로 코드 펜스 언어 추정."""
    ext = Path(file_rel).suffix.lower()
    return {
        ".dart": "dart", ".ts": "typescript", ".tsx": "tsx",
        ".js": "javascript", ".json": "json", ".yaml": "yaml",
        ".yml": "yaml", ".md": "markdown", ".rules": "javascript",
    }.get(ext, "")


def _accumulate_usage(model: str, usage) -> None:
    """response.usage 를 _usage_by_model 에 누적."""
    if model not in _usage_by_model:
        _usage_by_model[model] = {
            "input_tokens": 0,
            "output_tokens": 0,
            "cache_read_input_tokens": 0,
            "cache_creation_input_tokens": 0,
        }
    bucket = _usage_by_model[model]
    bucket["input_tokens"] += getattr(usage, "input_tokens", 0) or 0
    bucket["output_tokens"] += getattr(usage, "output_tokens", 0) or 0
    bucket["cache_read_input_tokens"] += getattr(usage, "cache_read_input_tokens", 0) or 0
    bucket["cache_creation_input_tokens"] += getattr(usage, "cache_creation_input_tokens", 0) or 0


async def _create_with_retry(
    client: anthropic.AsyncAnthropic,
    params: dict,
    group_id: str,
    max_retries: int = 10,
):
    """429/5xx/overloaded에 대해 지수 백오프 + 지터 재시도.
    429는 최소 60초 대기 (Anthropic API는 분 단위로 리셋되므로)."""
    for attempt in range(max_retries):
        try:
            # max_tokens >= 16000 시 SDK가 스트리밍 강제 요구 — 스트리밍으로 수집 후 반환
            if params.get("max_tokens", 0) >= 16000:
                async with client.messages.stream(**params) as stream:
                    response = await stream.get_final_message()
                if hasattr(response, "usage") and response.usage is not None:
                    _accumulate_usage(params["model"], response.usage)
                return response
            response = await client.messages.create(**params)
            if hasattr(response, "usage") and response.usage is not None:
                _accumulate_usage(params["model"], response.usage)
            return response
        except (anthropic.RateLimitError, anthropic.APIStatusError) as e:
            status = getattr(e, "status_code", None)
            # 재시도 가능한 에러만
            if status not in (429, 500, 502, 503, 504, 529):
                raise
            if attempt == max_retries - 1:
                raise
            if status == 429:
                # retry-after 헤더 우선, 없으면 최소 60초
                retry_after = None
                if hasattr(e, "response") and e.response is not None:
                    retry_after = e.response.headers.get("retry-after")
                if retry_after:
                    wait = float(retry_after) + random.uniform(0, 5)
                else:
                    wait = max(60, 2 ** attempt) + random.uniform(0, 10)
            else:
                wait = (2 ** attempt) + random.uniform(0, 1.5)
            print(f"   [ 재시도 ] {group_id}: {status} → {wait:.0f}s 대기 (시도 {attempt+1}/{max_retries})")
            await asyncio.sleep(wait)
        except anthropic.APIConnectionError as e:
            if attempt == max_retries - 1:
                raise
            wait = (2 ** attempt) + random.uniform(0, 1.5)
            print(f"   [ 재시도 ] {group_id}: 연결 오류 {e} → {wait:.1f}s 대기 (시도 {attempt+1}/{max_retries})")
            await asyncio.sleep(wait)


def _extract_task_sections(handoff_content: str, task_names: list[str]) -> str:
    """HANDOFF.md에서 tasks 목록에 해당하는 '### 과제 N:' 섹션들을 추출."""
    sections = []
    lines = handoff_content.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.startswith("### 과제 ") or line.startswith("### Task "):
            # 이 섹션이 tasks 중 하나와 매칭되는지 확인
            matched = any(
                t.strip().lower() in line.lower() or line.lower() in t.strip().lower()
                for t in task_names
            )
            if matched:
                block = [line]
                i += 1
                while i < len(lines) and not lines[i].startswith("### ") and not lines[i].startswith("---"):
                    block.append(lines[i])
                    i += 1
                sections.append("\n".join(block).strip())
                continue
        i += 1
    if sections:
        return "\n\n".join(sections)
    # 폴백: tasks 이름 목록만 반환
    return "수행할 과제:\n" + "\n".join(f"- {t}" for t in task_names)


async def run_worker(
    client: anthropic.AsyncAnthropic,
    group: dict,
    worktree_path: Path,
    branch_name: str,
    handoff_content: str = "",
) -> dict:
    group_id = group["id"]
    profile  = MODEL_PROFILES[group["profile"]]
    started  = datetime.now()

    def _err(msg: str) -> dict:
        return {
            "group_id": group_id, "status": "error",
            "profile": group["profile"],
            "model": profile["model"],
            "description": group["description"],
            "message": msg,
            "branch": branch_name,
            "duration": str(datetime.now() - started),
        }

    print(f"   [ 시작 ] {group_id} ({profile['model']}): {group['description']}")

    try:
        file_contents = {}
        for file_rel in group.get("files", []):
            file_path = worktree_path / file_rel
            file_contents[file_rel] = (
                file_path.read_text(encoding="utf-8")
                if file_path.exists()
                else f"[새 파일: {file_rel}]"
            )

        files_block = "\n\n".join(
            f"### {p}\n```{_detect_lang(p)}\n{c}\n```"
            for p, c in file_contents.items()
        )

        params = dict(
            model=profile["model"],
            max_tokens=32000,  # 32K: 대형 그룹(파일 5개+)도 완전 생성. 8K/min 초과 시 _create_with_retry가 429 자동 처리
            system=(
                "당신은 Flutter/Dart 및 TypeScript 전문 개발자입니다.\n"
                "주어진 지시사항에 따라 파일을 작성하고, 전체 파일 내용을 반환하세요.\n"
                "\n"
                "중요 제약 (출력 토큰 절약):\n"
                "- 각 파일은 핵심 구조/클래스/메서드만 포함 (불필요한 주석, docstring 금지)\n"
                "- 메서드 본문은 핵심 로직만 (TODO 주석으로 세부 구현 표시 가능)\n"
                "- import 문은 실제 필요한 것만\n"
                "\n"
                "파일 경로가 슬래시(/)로 끝나는 경우(디렉토리)에는 그 안에 생성할 실제 파일명을 붙여서 응답하세요.\n"
                '예: "functions/src/seed/" → "functions/src/seed/seedData.ts", "functions/src/seed/testUsers.ts"\n'
                "\n"
                + _worker_format_guide(modify_mode=False)
            ),
            messages=[{
                "role": "user",
                "content": f"지시사항:\n{_extract_task_sections(handoff_content, group.get('tasks', []))}\n\n현재 파일:\n{files_block}"
            }],
        )

        if profile["thinking"]:
            params["thinking"] = {"type": "adaptive"}

        try:
            response = await _create_with_retry(client, params, group_id)
        except Exception as e:
            return _err(f"API 호출 실패: {type(e).__name__}: {e}")

        raw = strip_code_fences(next((b.text for b in response.content if b.type == "text"), ""))

        if not raw:
            return _err(f"빈 응답 (stop_reason={response.stop_reason})")

        if response.stop_reason == "max_tokens":
            return _err(f"응답이 max_tokens에 잘림 (len={len(raw)}). 그룹을 더 작게 분할하거나 max_tokens를 늘리세요.")

        try:
            result = parse_worker_response(raw)
        except json.JSONDecodeError as e:
            return _err(f"응답 파싱 실패 ({e}). tail: ...{raw[-200:]!r}")

        files_out = result.get("files", {})
        if not files_out:
            return _err("응답에 'files' 가 비어있음")

        for file_rel, content in files_out.items():
            # 디렉토리 경로(슬래시 종료)는 건너뜀
            if file_rel.endswith("/") or file_rel.endswith("\\"):
                (worktree_path / file_rel).mkdir(parents=True, exist_ok=True)
                continue
            file_path = worktree_path / file_rel
            file_path.parent.mkdir(parents=True, exist_ok=True)
            file_path.write_text(content, encoding="utf-8")

        subprocess.run(["git", "add", "-A"], cwd=worktree_path, capture_output=True)
        commit_result = subprocess.run(
            ["git", "commit", "-m", f"auto({group_id}): {group['description']}"],
            cwd=worktree_path, capture_output=True, text=True, encoding="utf-8",
        )
        if commit_result.returncode != 0 and "nothing to commit" not in (commit_result.stdout + commit_result.stderr):
            return _err(f"git commit 실패: {commit_result.stderr.strip()}")

        duration = str(datetime.now() - started)
        print(f"   [ 완료 ] {group_id}: {result.get('summary', '')[:80]} ({duration})")

        return {
            "group_id": group_id,
            "status": "success",
            "profile": group["profile"],
            "model": profile["model"],
            "description": group["description"],
            "summary": result.get("summary", ""),
            "changes": result.get("changes", []),
            "files_modified": list(files_out.keys()),
            "branch": branch_name,
            "duration": duration,
        }
    except Exception as e:
        return _err(f"예외 발생: {type(e).__name__}: {e}")

# ── 보고서 ───────────────────────────────────────────────────────────────────

def print_report(results: list[dict], groups: list[dict], mode: str = "create"):
    print(f"\n{'═'*55}")
    print(f"  작업 완료 보고  —  {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    print(f"{'═'*55}")

    print(f"\n[ 작업 분배 ]\n")
    for g in groups:
        profile = MODEL_PROFILES[g["profile"]]
        thinking_str = f"thinking {'ON' if profile['thinking'] else 'OFF'}"
        effort_str   = f"effort {profile['effort']}" if profile['effort'] else ""
        tag = f"{profile['model']} / {thinking_str}" + (f" / {effort_str}" if effort_str else "")
        print(f"  {g['id']}: {g['description']}")
        print(f"    모델: {tag}")
        print(f"    파일: {', '.join(g['files'])}\n")

    success = [r for r in results if r["status"] == "success"]
    errors  = [r for r in results if r["status"] == "error"]

    print(f"[ 실행 결과 ]\n")
    for r in success:
        print(f"  ✓ {r['group_id']} ({r['duration']})")
        print(f"    {r['summary']}")
        for c in r.get("changes", []):
            print(f"    - {c}")
        print(f"    브랜치: {r['branch']}\n")

    if errors:
        print(f"[ 실패 ]\n")
        for r in errors:
            print(f"  ✗ {r['group_id']}: {r['message']}\n")

    # API 사용량 섹션
    cost_data = compute_total_cost()
    print(f"[ API 사용량 ]\n")
    model_display_names = {
        "claude-opus-4-6": "Opus",
        "claude-sonnet-4-6": "Sonnet",
        "claude-haiku-4-5-20251001": "Haiku",
    }
    for model, info in cost_data["by_model"].items():
        display = model_display_names.get(model, model)
        in_k = info["input_tokens"] / 1000
        out_k = info["output_tokens"] / 1000
        cost = info["cost_usd"]
        print(f"  {display}: {in_k:.1f}K in / {out_k:.1f}K out -> {cost:.4f} USD")
    print(f"  합계: {cost_data['total_cost_usd']:.4f} USD\n")

    # 누적 비용 기록 및 출력
    append_usage_history(mode=mode)
    cumulative = load_cumulative_cost()
    if cumulative["total_runs"] > 0:
        print(f"[ 누적 비용 ] 총 {cumulative['total_runs']}회 실행, 누적 {cumulative['total_cost_usd']:.4f} USD\n")

    print(f"[ 다음 단계 ]\n")
    if success:
        for r in success:
            print(f"  git merge {r['branch']}")
        print(f"\n  확인 후 merge 해주세요.")
    print(f"{'═'*55}\n")

    REPORT_PATH.write_text(json.dumps({
        "timestamp": datetime.now().isoformat(),
        "groups": groups,
        "results": results,
        "cost": cost_data,
    }, ensure_ascii=False, indent=2), encoding="utf-8")

    try:
        import winsound
        if errors:
            winsound.MessageBeep(winsound.MB_ICONHAND)   # 실패 포함: 에러음
        else:
            winsound.MessageBeep(winsound.MB_ICONASTERISK)  # 전체 성공: 정보음
    except Exception:
        pass


# ── 자동 머지 + worktree 정리 ────────────────────────────────────────────────

def auto_merge_and_cleanup(
    results: list[dict],
    worktrees: dict[str, tuple[Path, str]],
    project_root: Path,
) -> None:
    """성공한 그룹의 브랜치를 현재 HEAD 에 자동 머지하고 worktree 정리."""
    success = [r for r in results if r.get("status") == "success"]
    if not success:
        print(f"\n[ 자동 머지 ] 성공한 그룹 없음 — 스킵\n")
        return

    print(f"\n[ 자동 머지 ] {len(success)}개 그룹 머지 + worktree 정리 중...\n")

    merged_count = 0
    failed_merges: list[tuple[str, str, str]] = []  # (group_id, branch, error)

    for r in success:
        group_id = r["group_id"]
        branch = r["branch"]
        wt_path, _ = worktrees[group_id]

        merge_result = subprocess.run(
            ["git", "merge", "--no-edit", branch],
            cwd=project_root, capture_output=True, text=True, encoding="utf-8",
        )

        if merge_result.returncode != 0:
            subprocess.run(
                ["git", "merge", "--abort"],
                cwd=project_root, capture_output=True,
            )
            err = (merge_result.stderr or merge_result.stdout).strip()[:300]
            r["merged"] = False
            r["merge_error"] = err
            failed_merges.append((group_id, branch, err))
            print(f"   ✗ {group_id}: 머지 실패")
            print(f"     {err[:200]}")
            continue

        r["merged"] = True
        merged_count += 1
        print(f"   ✓ {group_id}: 머지 완료 ({branch})")

        # worktree 정리
        rm_result = subprocess.run(
            ["git", "worktree", "remove", str(wt_path)],
            cwd=project_root, capture_output=True, text=True, encoding="utf-8",
        )
        if rm_result.returncode != 0:
            subprocess.run(
                ["git", "worktree", "remove", "--force", str(wt_path)],
                cwd=project_root, capture_output=True,
            )

        # 머지된 브랜치 삭제 (실패해도 무시 — 이미 main 에 반영됨)
        subprocess.run(
            ["git", "branch", "-d", branch],
            cwd=project_root, capture_output=True,
        )

    print(f"\n   → {merged_count}/{len(success)}개 머지 성공")

    if failed_merges:
        print(f"\n   ⚠ 머지 실패 그룹 — 수동 처리 필요:")
        for group_id, branch, _ in failed_merges:
            print(f"     cd {project_root} && git merge {branch}")
        print()

# ── worker_map (수정 모드용 파일→그룹 매핑) ─────────────────────────────────

def save_worker_map(groups: list[dict], results: list[dict]):
    """성공한 그룹의 파일 매핑을 worker_map.json 에 누적 저장."""
    successful_ids = {r["group_id"] for r in results if r.get("status") == "success"}
    existing: dict = {}
    if WORKER_MAP_PATH.exists():
        try:
            existing = json.loads(WORKER_MAP_PATH.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            existing = {}

    # 신규 생성 모드는 group['files'] 가 의도이므로 그것 기준으로 저장.
    # 단, run_worker 가 실제로 만든 파일(files_modified)이 있으면 그 쪽이 더 정확.
    result_by_id = {r["group_id"]: r for r in results if r.get("status") == "success"}
    for g in groups:
        if g["id"] not in successful_ids:
            continue
        profile_key = g["profile"]
        profile = MODEL_PROFILES[profile_key]
        files = result_by_id[g["id"]].get("files_modified") or g.get("files", [])
        for file_rel in files:
            if not file_rel or file_rel.endswith("/") or file_rel.endswith("\\"):
                continue
            existing[file_rel] = {
                "group_id": g["id"],
                "profile": profile_key,
                "model": profile["model"],
            }

    WORKER_MAP_PATH.write_text(
        json.dumps(existing, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(f"         → worker_map.json 업데이트 ({len(existing)}개 파일)")


def update_worker_map_after_patch(groups: list[dict], results: list[dict]):
    """수정 모드에서 새로 생긴 파일을 worker_map 에 추가."""
    if not WORKER_MAP_PATH.exists():
        return
    try:
        worker_map = json.loads(WORKER_MAP_PATH.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return

    successful_ids = {r["group_id"] for r in results if r.get("status") == "success"}
    result_by_id = {r["group_id"]: r for r in results if r.get("status") == "success"}
    changed = False
    for g in groups:
        if g["id"] not in successful_ids:
            continue
        profile_key = g["profile"]
        profile = MODEL_PROFILES[profile_key]
        files = result_by_id[g["id"]].get("files_modified") or g.get("files", [])
        for file_rel in files:
            if not file_rel or file_rel.endswith("/") or file_rel.endswith("\\"):
                continue
            if file_rel not in worker_map:
                worker_map[file_rel] = {
                    "group_id": g["id"],
                    "profile": profile_key,
                    "model": profile["model"],
                }
                changed = True
    if changed:
        WORKER_MAP_PATH.write_text(
            json.dumps(worker_map, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

# ── 수정 모드: 분류기 ────────────────────────────────────────────────────────

PATCH_CLASSIFIER_SYSTEM = """당신은 Flutter 프로젝트의 수정 요청 분석 전문가입니다.
사용자의 자유 텍스트 수정 요청과 worker_map.json 을 보고
어떤 파일들을 어떤 그룹 단위로 수정해야 하는지 결정하세요.

worker_map.json 형식: {파일경로: {group_id, profile, model}}

규칙:
- 같은 group_id 에 속한 파일들은 하나의 그룹 entry 로 묶기
- 수정 요청과 무관한 그룹은 절대 포함하지 말 것
- 새 파일이 필요하면 가장 관련성 높은 기존 group_id 에 추가
- profile 은 worker_map 의 해당 파일 profile 을 그대로 사용
- instruction 은 그 그룹에서 수행할 구체적인 작업만 (사용자 요청 중 해당 부분만 발췌)
- description 은 10단어 이내

JSON만 출력. 마크다운 펜스 금지. 형식:
{
  "groups": [
    {
      "id": "group_3",
      "profile": "standard",
      "description": "수정 내용 요약",
      "files": ["lib/path/to/file.dart"],
      "instruction": "구체적인 수정 지시 (이 그룹 한정)"
    }
  ]
}"""


async def patch_classify(
    client: anthropic.AsyncAnthropic,
    patch_text: str,
    worker_map: dict,
) -> list[dict]:
    print("[ 1/4 ] 수정 요청 분석 중...")

    response = await _create_with_retry(client, dict(
        model=ORCHESTRATOR_MODEL,
        max_tokens=8000,
        system=PATCH_CLASSIFIER_SYSTEM,
        messages=[{
            "role": "user",
            "content": (
                f"수정 요청:\n{patch_text}\n\n"
                f"worker_map.json:\n{json.dumps(worker_map, ensure_ascii=False, indent=2)}"
            ),
        }],
    ), "patch_classify")

    raw = strip_code_fences(next((b.text for b in response.content if b.type == "text"), ""))

    if not raw:
        print(f"         ⚠ 빈 응답. stop_reason={response.stop_reason}")
        sys.exit(1)

    try:
        data = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"         ⚠ JSON 파싱 실패: {e}")
        print(f"         tail: ...{raw[-300:]!r}")
        sys.exit(1)

    groups = data.get("groups", [])
    print(f"         → {len(groups)}개 그룹이 영향받음\n")
    for g in groups:
        if g["profile"] not in MODEL_PROFILES:
            print(f"         ⚠ 알 수 없는 profile: {g['profile']} → standard 로 대체")
            g["profile"] = "standard"
        profile = MODEL_PROFILES[g["profile"]]
        print(f"         • {g['id']} [{g['profile'].upper()}] {profile['model']}")
        print(f"           {g.get('description', '')}")
        print(f"           파일: {', '.join(g.get('files', []))}")
        print(f"           지시: {g.get('instruction', '')[:120]}\n")
    return groups

# ── 수정 모드: 워커 ──────────────────────────────────────────────────────────

PATCH_WORKER_SYSTEM = (
    "당신은 Flutter/Dart 및 TypeScript 전문 개발자입니다.\n"
    "주어진 기존 파일 내용을 읽고, 수정 지시사항에 따라 파일을 수정하세요.\n"
    "\n"
    "중요 제약:\n"
    "- **변경이 필요한 파일만** 응답에 포함 (수정하지 않는 파일은 절대 넣지 마세요)\n"
    "- 응답하는 파일은 항상 **수정된 전체 파일 내용** (diff 아님)\n"
    "- 기존 코드 구조와 스타일을 유지\n"
    "- 요청에 없는 리팩토링/주석 추가 금지\n"
    "- import 문은 실제 필요한 것만 변경\n"
    "\n"
    + _worker_format_guide(modify_mode=True)
)


async def patch_worker(
    client: anthropic.AsyncAnthropic,
    group: dict,
    worktree_path: Path,
    branch_name: str,
) -> dict:
    group_id = group["id"]
    profile  = MODEL_PROFILES[group["profile"]]
    started  = datetime.now()

    def _err(msg: str) -> dict:
        return {
            "group_id": group_id, "status": "error",
            "profile": group["profile"],
            "model": profile["model"],
            "description": group.get("description", ""),
            "message": msg,
            "branch": branch_name,
            "duration": str(datetime.now() - started),
            "instruction": group.get("instruction", ""),
        }

    print(f"   [ 시작 ] {group_id} ({profile['model']}): {group.get('description', '')}")

    try:
        file_contents = {}
        for file_rel in group.get("files", []):
            file_path = worktree_path / file_rel
            file_contents[file_rel] = (
                file_path.read_text(encoding="utf-8")
                if file_path.exists()
                else f"[새 파일 — 신규 생성: {file_rel}]"
            )

        files_block = "\n\n".join(
            f"### {p}\n```{_detect_lang(p)}\n{c}\n```"
            for p, c in file_contents.items()
        )

        params = dict(
            model=profile["model"],
            max_tokens=32000,
            system=PATCH_WORKER_SYSTEM,
            messages=[{
                "role": "user",
                "content": (
                    f"수정 지시:\n{group.get('instruction', '')}\n\n"
                    f"현재 파일 내용:\n{files_block}"
                ),
            }],
        )

        if profile["thinking"]:
            params["thinking"] = {"type": "adaptive"}

        try:
            response = await _create_with_retry(client, params, group_id)
        except Exception as e:
            return _err(f"API 호출 실패: {type(e).__name__}: {e}")

        raw = strip_code_fences(next((b.text for b in response.content if b.type == "text"), ""))

        if not raw:
            return _err(f"빈 응답 (stop_reason={response.stop_reason})")

        if response.stop_reason == "max_tokens":
            return _err(f"응답이 max_tokens 에 잘림 (len={len(raw)}). 그룹을 더 작게 분할하세요.")

        try:
            result = parse_worker_response(raw)
        except json.JSONDecodeError as e:
            return _err(f"응답 파싱 실패 ({e}). tail: ...{raw[-200:]!r}")

        files_out = result.get("files", {})
        if not files_out:
            return _err("응답의 files 가 비어있음 (수정사항 없음)")

        for file_rel, content in files_out.items():
            if file_rel.endswith("/") or file_rel.endswith("\\"):
                (worktree_path / file_rel).mkdir(parents=True, exist_ok=True)
                continue
            file_path = worktree_path / file_rel
            file_path.parent.mkdir(parents=True, exist_ok=True)
            file_path.write_text(content, encoding="utf-8")

        subprocess.run(["git", "add", "-A"], cwd=worktree_path, capture_output=True)
        commit_msg = f"patch({group_id}): {result.get('summary', group.get('description', ''))[:80]}"
        commit_result = subprocess.run(
            ["git", "commit", "-m", commit_msg],
            cwd=worktree_path, capture_output=True, text=True, encoding="utf-8",
        )
        if commit_result.returncode != 0 and "nothing to commit" not in (commit_result.stdout + commit_result.stderr):
            return _err(f"git commit 실패: {commit_result.stderr.strip()}")

        duration = str(datetime.now() - started)
        print(f"   [ 완료 ] {group_id}: {result.get('summary', '')[:80]} ({duration})")

        return {
            "group_id": group_id,
            "status": "success",
            "profile": group["profile"],
            "model": profile["model"],
            "description": group.get("description", ""),
            "summary": result.get("summary", ""),
            "changes": result.get("changes", []),
            "files_modified": list(files_out.keys()),
            "branch": branch_name,
            "duration": duration,
            "instruction": group.get("instruction", ""),
        }
    except Exception as e:
        return _err(f"예외 발생: {type(e).__name__}: {e}")

# ── 수정 모드: HANDOFF.md 이력 추가 ──────────────────────────────────────────

def append_patch_history(patch_text: str, results: list[dict], project_root: Path):
    """수정 모드 결과를 HANDOFF.md 의 '## 수정 이력' 섹션에 추가."""
    handoff_path = project_root / "HANDOFF.md"
    if not handoff_path.exists():
        return

    success = [r for r in results if r["status"] == "success"]
    if not success:
        return

    content = handoff_path.read_text(encoding="utf-8")
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M')

    lines = [f"### {timestamp} — 수정 요청"]
    lines.append(f"- **요청**: {patch_text.strip()[:300]}")
    for r in success:
        lines.append(f"- **{r['group_id']}** ({r['model']}): {r.get('summary', '')}")
        files_modified = r.get('files_modified', [])
        if files_modified:
            lines.append(f"  - 파일: {', '.join(files_modified)}")
        lines.append(f"  - 브랜치: `{r['branch']}`")
    entry = "\n".join(lines) + "\n"

    if "## 수정 이력" in content:
        # '## 수정 이력' 헤더 바로 다음 줄에 새 entry 삽입 (최신이 위)
        out_lines = []
        inserted = False
        for line in content.splitlines(keepends=True):
            out_lines.append(line)
            if not inserted and line.strip() == "## 수정 이력":
                out_lines.append("\n" + entry)
                inserted = True
        new_content = "".join(out_lines)
    else:
        new_content = content.rstrip() + "\n\n## 수정 이력\n\n" + entry

    handoff_path.write_text(new_content, encoding="utf-8")
    print(f"   → HANDOFF.md 수정 이력 추가됨")

# ── worker_map 빌드 모드 (브라운필드 프로젝트용) ────────────────────────────

# 분류 대상 확장자 (코드 파일)
WORKER_MAP_CODE_EXTS = {".dart", ".ts", ".tsx", ".js", ".jsx", ".arb", ".rules"}

# 분류 대상 설정/의존성 파일 (basename 기준)
WORKER_MAP_CONFIG_FILES = {
    "pubspec.yaml", "analysis_options.yaml",
    "firestore.rules", "storage.rules", "firestore.indexes.json", "firebase.json",
    "package.json", "tsconfig.json",
}

# 분류 제외 경로 prefix
WORKER_MAP_EXCLUDE_PREFIXES = (
    "orchestrator/", ".worktrees/", "build/", ".dart_tool/",
    "node_modules/", ".git/", "ios/", "android/", "macos/",
    "windows/", "linux/", "web/", "assets/",
)


def _is_worker_map_target(rel_path: str) -> bool:
    """분류 대상인지 판정."""
    if not rel_path:
        return False
    normalized = rel_path.replace("\\", "/")
    if normalized.endswith(".gitkeep"):
        return False
    if any(normalized.startswith(p) for p in WORKER_MAP_EXCLUDE_PREFIXES):
        return False
    basename = Path(normalized).name
    if basename in WORKER_MAP_CONFIG_FILES:
        return True
    if normalized.endswith(".md"):
        return False
    ext = Path(normalized).suffix.lower()
    return ext in WORKER_MAP_CODE_EXTS


BUILD_WORKER_MAP_SYSTEM = """당신은 Flutter 프로젝트의 파일 분류 전문가입니다.
주어진 파일 경로 목록을 보고 도메인/관심사에 따라 그룹으로 묶고,
각 그룹에 적합한 모델 프로필을 선택하세요.

모델 프로필 기준:
- heavy (Opus): 도메인 로직/알고리즘(사주 계산, 궁합 매칭, 보안 규칙, 결제 검증), 아키텍처 설계
- standard (Sonnet): 일반 UI/화면/위젯, Provider/상태관리, Firebase Functions 일반 CRUD/호출, Repository
- light (Haiku): 디자인 토큰, 상수, 라우트 정의, 간단한 설정 파일, DTO 모델 클래스, 번역 파일(arb)

규칙:
- 같은 디렉토리/기능 범위 파일은 같은 그룹으로 묶기
- 파일명/경로로 용도를 추정해 적합한 profile 선택
- **모든 입력 파일이 정확히 하나의 그룹에 속해야 함** (누락/중복 금지)
- 입력에 없는 파일은 절대 추가하지 말 것
- description 은 10단어 이내
- reason 은 1문장

JSON만 출력. 마크다운 펜스 금지. 형식:
{
  "groups": [
    {
      "id": "group_1",
      "description": "그룹 설명",
      "profile": "heavy | standard | light",
      "reason": "선택 이유 1문장",
      "files": ["lib/path/to/file.dart"]
    }
  ]
}"""


async def build_worker_map_main():
    """기존 프로젝트를 스캔해서 worker_map.json 을 1회성 생성.

    신규 생성 모드를 거치지 않고 만들어진 브라운필드 프로젝트에서
    --patch 모드를 쓰기 위한 시드 생성 명령. 파일은 건드리지 않음.
    """
    if not ANTHROPIC_API_KEY:
        print("⚠  ANTHROPIC_API_KEY 가 설정되지 않았습니다.")
        sys.exit(1)

    project_root = get_project_root()

    print(f"\n워커맵 빌드 시작  —  {datetime.now().strftime('%H:%M:%S')}\n")

    result = subprocess.run(
        ["git", "ls-files"],
        cwd=project_root, capture_output=True, text=True, encoding="utf-8",
    )
    if result.returncode != 0:
        print(f"⚠  git ls-files 실패: {result.stderr.strip()}")
        sys.exit(1)

    all_files = [f.strip().replace("\\", "/") for f in result.stdout.splitlines() if f.strip()]
    target_files = sorted(set(f for f in all_files if _is_worker_map_target(f)))

    print(f"[ 1/3 ] 파일 스캔")
    print(f"         전체 tracked : {len(all_files)}개")
    print(f"         분류 대상    : {len(target_files)}개")

    if not target_files:
        print("⚠  분류 대상 파일이 없습니다.")
        sys.exit(1)

    client = anthropic.AsyncAnthropic(api_key=ANTHROPIC_API_KEY)

    print(f"\n[ 2/3 ] Opus 분류기로 그룹화 중...")

    response = await _create_with_retry(client, dict(
        model=ORCHESTRATOR_MODEL,
        max_tokens=16000,
        system=BUILD_WORKER_MAP_SYSTEM,
        messages=[{
            "role": "user",
            "content": (
                f"프로젝트 파일 목록 ({len(target_files)}개):\n\n"
                + "\n".join(target_files)
            ),
        }],
    ), "build_worker_map")

    raw = strip_code_fences(next((b.text for b in response.content if b.type == "text"), ""))
    if not raw:
        print(f"         ⚠ 빈 응답 (stop_reason={response.stop_reason})")
        sys.exit(1)
    if response.stop_reason == "max_tokens":
        print(f"         ⚠ 응답이 max_tokens 에 잘림 (len={len(raw)}).")
        sys.exit(1)

    try:
        data = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"         ⚠ JSON 파싱 실패: {e}")
        print(f"         tail: ...{raw[-300:]!r}")
        sys.exit(1)

    groups = data.get("groups", [])
    if not groups:
        print("         ⚠ 그룹이 비어있음")
        sys.exit(1)

    worker_map: dict = {}
    classified_files: set = set()

    print(f"         → {len(groups)}개 그룹으로 분류\n")

    for g in groups:
        profile_key = g.get("profile", "standard")
        if profile_key not in MODEL_PROFILES:
            print(f"         ⚠ 알 수 없는 profile={profile_key!r} → standard 로 대체")
            profile_key = "standard"
        profile = MODEL_PROFILES[profile_key]
        group_id = g.get("id", f"group_{len(worker_map)}")
        files = g.get("files", [])

        print(f"         • {group_id} [{profile_key.upper()}] {profile['model']}")
        print(f"           {g.get('description', '')}")
        print(f"           파일: {len(files)}개")
        print(f"           이유: {g.get('reason', '')}\n")

        for file_rel in files:
            file_rel = file_rel.replace("\\", "/").strip()
            if not file_rel or file_rel.endswith("/"):
                continue
            worker_map[file_rel] = {
                "group_id": group_id,
                "profile": profile_key,
                "model": profile["model"],
            }
            classified_files.add(file_rel)

    # 누락/추가 파일 검증
    target_set = set(target_files)
    missing = sorted(target_set - classified_files)
    extra = sorted(classified_files - target_set)

    if extra:
        print(f"         ⚠ 분류기가 입력에 없던 {len(extra)}개 파일을 추가함 → 제거")
        for f in extra[:20]:
            print(f"           - {f}")
        for f in extra:
            worker_map.pop(f, None)

    if missing:
        print(f"         ⚠ 분류기가 {len(missing)}개 파일을 누락 → group_fallback (standard) 로 할당")
        fallback_profile = MODEL_PROFILES["standard"]
        for f in missing[:20]:
            print(f"           + {f}")
        if len(missing) > 20:
            print(f"           ... 외 {len(missing) - 20}개")
        for f in missing:
            worker_map[f] = {
                "group_id": "group_fallback",
                "profile": "standard",
                "model": fallback_profile["model"],
            }

    print(f"\n[ 3/3 ] worker_map.json 저장")
    WORKER_MAP_PATH.write_text(
        json.dumps(worker_map, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    # 프로필별 통계
    by_profile: dict = {}
    for meta in worker_map.values():
        by_profile[meta["profile"]] = by_profile.get(meta["profile"], 0) + 1

    print(f"         → {len(worker_map)}개 파일 매핑 저장")
    print(f"         → {WORKER_MAP_PATH}")
    print(f"         → 프로필별: {', '.join(f'{k}={v}' for k, v in sorted(by_profile.items()))}")
    print(f"\n완료. 이제 --patch --auto-merge 모드를 사용할 수 있습니다.\n")

# ── 수정 모드: 메인 ──────────────────────────────────────────────────────────

async def patch_main(patch_text: str, concurrency: int, auto_merge: bool = False):
    if not ANTHROPIC_API_KEY:
        print("⚠  ANTHROPIC_API_KEY 가 설정되지 않았습니다.")
        sys.exit(1)

    if not WORKER_MAP_PATH.exists():
        print(f"⚠  worker_map.json 이 없습니다: {WORKER_MAP_PATH}")
        print("   먼저 신규 생성 모드(uv run run.py)를 한 번 실행해 주세요.")
        sys.exit(1)

    try:
        worker_map = json.loads(WORKER_MAP_PATH.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"⚠  worker_map.json 파싱 실패: {e}")
        sys.exit(1)

    if not worker_map:
        print("⚠  worker_map.json 이 비어있습니다.")
        sys.exit(1)

    print(f"\n오케스트레이터(수정 모드) 시작 — {datetime.now().strftime('%H:%M:%S')}\n")
    print(f"수정 요청: {patch_text}\n")

    project_root = get_project_root()
    client = anthropic.AsyncAnthropic(api_key=ANTHROPIC_API_KEY)

    groups = await patch_classify(client, patch_text, worker_map)
    if not groups:
        print("수정할 그룹이 없습니다.")
        return

    print(f"[ 2/4 ] Worktree 생성 중...")
    worktrees: dict[str, tuple[Path, str]] = {}
    for group in groups:
        wt_path, branch = create_worktree(project_root, group["id"], prefix="patch")
        worktrees[group["id"]] = (wt_path, branch)
        print(f"         → {group['id']}: {wt_path.name}  [{branch}]")

    print(f"\n[ 3/4 ] 수정 워커 병렬 실행 중 (동시 {concurrency}개)...\n")
    semaphore = asyncio.Semaphore(concurrency)

    async def run_with_semaphore(group):
        async with semaphore:
            wt_path, branch = worktrees[group["id"]]
            try:
                return await patch_worker(client, group, wt_path, branch)
            except Exception as e:
                return {
                    "group_id": group["id"], "status": "error",
                    "profile": group["profile"], "description": group.get("description", ""),
                    "message": f"워커 미처리 예외: {type(e).__name__}: {e}",
                    "branch": branch, "duration": "n/a",
                }

    results: list[dict] = []
    if concurrency == 1:
        for g in groups:
            try:
                r = await patch_worker(client, g, *worktrees[g["id"]])
                results.append(r)
                if r.get("status") == "error":
                    print(f"   [ 실패 ] {g['id']}: {r.get('message', '')[:120]}")
            except Exception as e:
                err = {
                    "group_id": g["id"], "status": "error",
                    "profile": g["profile"], "description": g.get("description", ""),
                    "message": f"워커 예외: {type(e).__name__}: {e}",
                    "branch": worktrees[g["id"]][1], "duration": "n/a",
                }
                print(f"   [ 예외 ] {g['id']}: {type(e).__name__}: {e}")
                results.append(err)
    else:
        raw_results = await asyncio.gather(
            *[run_with_semaphore(g) for g in groups],
            return_exceptions=True,
        )
        for g, r in zip(groups, raw_results):
            if isinstance(r, BaseException):
                results.append({
                    "group_id": g["id"], "status": "error",
                    "profile": g["profile"], "description": g.get("description", ""),
                    "message": f"세마포어 래퍼 예외: {type(r).__name__}: {r}",
                    "branch": worktrees[g["id"]][1], "duration": "n/a",
                })
            else:
                results.append(r)

    print(f"\n[ 4/4 ] 보고서 생성 중...")
    print_report(list(results), groups, mode="patch")
    update_worker_map_after_patch(groups, results)
    append_patch_history(patch_text, results, project_root)

    if auto_merge:
        auto_merge_and_cleanup(results, worktrees, project_root)

# ── 메인 ─────────────────────────────────────────────────────────────────────

async def main(handoff_path: Path, dry_run: bool, concurrency: int = 8, only_groups: list[str] | None = None, auto_merge: bool = False):
    if not ANTHROPIC_API_KEY:
        print("⚠  ANTHROPIC_API_KEY 가 설정되지 않았습니다.")
        print("   Windows: $env:ANTHROPIC_API_KEY='sk-ant-...'")
        sys.exit(1)

    if not handoff_path.exists():
        print(f"⚠  HANDOFF.md 를 찾을 수 없습니다: {handoff_path}")
        sys.exit(1)

    print(f"\n오케스트레이터 시작  —  {datetime.now().strftime('%H:%M:%S')}\n")

    handoff_content = handoff_path.read_text(encoding="utf-8")
    project_root    = get_project_root()
    client          = anthropic.AsyncAnthropic(api_key=ANTHROPIC_API_KEY)

    groups = await classify_tasks(client, handoff_content)

    if not groups:
        print("과제가 없습니다. HANDOFF.md 를 확인해주세요.")
        return

    if only_groups:
        groups = [g for g in groups if g["id"] in only_groups]
        if not groups:
            print(f"⚠  --only-groups 에 해당하는 그룹이 없습니다: {only_groups}")
            return
        print(f"   → {len(groups)}개 그룹만 실행: {[g['id'] for g in groups]}")

    if dry_run:
        print("[ dry-run ] 실제 실행을 건너뜁니다.")
        return

    print(f"[ 2/4 ] Worktree 생성 중...")
    worktrees: dict[str, tuple[Path, str]] = {}
    for group in groups:
        wt_path, branch = create_worktree(project_root, group["id"])
        worktrees[group["id"]] = (wt_path, branch)
        print(f"         → {group['id']}: {wt_path.name}  [{branch}]")

    print(f"\n[ 3/4 ] 서브에이전트 병렬 실행 중 (동시 {concurrency}개)...\n")
    semaphore = asyncio.Semaphore(concurrency)

    async def run_with_semaphore(group):
        async with semaphore:
            wt_path, branch = worktrees[group["id"]]
            try:
                return await run_worker(client, group, wt_path, branch, handoff_content)
            except Exception as e:
                return {
                    "group_id": group["id"],
                    "status": "error",
                    "profile": group["profile"],
                    "description": group.get("description", ""),
                    "message": f"워커 미처리 예외: {type(e).__name__}: {e}",
                    "branch": branch,
                    "duration": "n/a",
                }

    # concurrency=1 시 asyncio.gather 세마포어 경쟁 조건 회피 — 단순 순차 루프 사용
    results = []
    if concurrency == 1:
        for g in groups:
            try:
                r = await run_worker(client, g, *worktrees[g["id"]], handoff_content)
                results.append(r)
                if r.get("status") == "error":
                    print(f"   [ 실패 ] {g['id']}: {r.get('message', '')[:120]}")
            except Exception as e:
                err = {
                    "group_id": g["id"], "status": "error",
                    "profile": g["profile"], "description": g.get("description", ""),
                    "message": f"워커 예외: {type(e).__name__}: {e}",
                    "branch": worktrees[g["id"]][1], "duration": "n/a",
                }
                print(f"   [ 예외 ] {g['id']}: {type(e).__name__}: {e}")
                results.append(err)
    else:
        raw_results = await asyncio.gather(
            *[run_with_semaphore(g) for g in groups],
            return_exceptions=True,
        )
        for g, r in zip(groups, raw_results):
            if isinstance(r, BaseException):
                results.append({
                    "group_id": g["id"], "status": "error",
                    "profile": g["profile"], "description": g.get("description", ""),
                    "message": f"세마포어 래퍼 예외: {type(r).__name__}: {r}",
                    "branch": worktrees[g["id"]][1], "duration": "n/a",
                })
            else:
                results.append(r)

    print(f"\n[ 4/4 ] 보고서 생성 중...")
    print_report(list(results), groups, mode="create")
    save_worker_map(groups, results)

    if auto_merge:
        auto_merge_and_cleanup(results, worktrees, project_root)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--handoff",     type=Path, default=Path("HANDOFF.md"))
    parser.add_argument("--dry-run",     action="store_true")
    parser.add_argument("--report",      action="store_true")
    parser.add_argument("--cost",        action="store_true",
                        help="누적 API 비용 리포트 출력")
    parser.add_argument("--concurrency", type=int, default=1,
                        help="동시 실행 워커 수 (Tier1=1, Tier2=4, Tier3=8)")
    parser.add_argument("--only-groups", type=str, default=None,
                        help="실행할 그룹 ID를 쉼표로 구분 (예: group_2,group_8)")
    parser.add_argument("--patch", type=str, default=None,
                        help="수정 모드: 자유 텍스트 수정 요청 (worker_map.json 기반)")
    parser.add_argument("--auto-merge", action="store_true",
                        help="성공한 그룹을 현재 HEAD 에 자동 머지하고 worktree/브랜치 정리")
    parser.add_argument("--build-worker-map", action="store_true",
                        help="브라운필드 프로젝트용: 기존 파일을 스캔해서 worker_map.json 을 1회성 생성 (파일 수정 안 함)")
    args = parser.parse_args()

    if args.report:
        if REPORT_PATH.exists():
            data = json.loads(REPORT_PATH.read_text(encoding="utf-8"))
            print_report(data["results"], data["groups"])
        else:
            print("보고서가 없습니다. 먼저 run.py 를 실행해주세요.")
        sys.exit(0)

    if args.cost:
        print_cost_report()
        sys.exit(0)

    # 중복 실행 방지 lock 파일
    lock_path = Path(__file__).parent / "run.lock"
    if lock_path.exists():
        existing_pid = lock_path.read_text().strip()
        print(f"⚠  이미 실행 중일 수 있습니다 (PID {existing_pid}).")
        print(f"   정말 실행하려면 {lock_path} 를 삭제하세요.")
        sys.exit(1)
    lock_path.write_text(str(os.getpid()))

    tee = _setup_log()
    try:
        if args.build_worker_map:
            asyncio.run(build_worker_map_main())
        elif args.patch:
            asyncio.run(patch_main(args.patch, args.concurrency, args.auto_merge))
        else:
            only_groups = [g.strip() for g in args.only_groups.split(",")] if args.only_groups else None
            asyncio.run(main(args.handoff, args.dry_run, args.concurrency, only_groups, args.auto_merge))
    finally:
        sys.stdout = tee._stdout
        tee.close()
        lock_path.unlink(missing_ok=True)