# Agent Instructions

- Be concise.
- Do only what is asked.
- Use safe, non-destructive actions.
- Ask before making risky changes.

## Using `talk/`

- Start with `talk/template.md` to capture talk goals, core message, and spoken plan.
- Use `talk/steps.md` as the build workflow from whiteboard to rehearsal.
- Use `talk/checklist.md` as the base readiness checklist; mark items only when true.
- Apply topic checklists as needed:
- `talk/being-clear.md` for story structure and clarity.
- `talk/being-awesome.md` for memorable delivery elements tied to technical points.
- `talk/avoiding-common-mistakes.md` for slide quality, pacing, and accessibility checks.
- Keep talk title/date metadata consistent across files where those fields exist.

## Output dir

- Save generated materials here, organized by title and date.
- Output dir should be at the root level of the project. If use this repo (markdown-slides) as submodule, dir should be `{root_repo}/output/`
- If the root repo overwrites the output dir, use the new path for dir
- Talk dir structure: `{output_dir}/talk/{date}_{talk_title}/`
