#!/usr/bin/env python3
import importlib.machinery
import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
loader = importlib.machinery.SourceFileLoader('pane_titles', str(ROOT / 'dotfiles/bin/.local/bin/rex-pane-titles'))
spec = importlib.util.spec_from_loader(loader.name, loader)
titles = importlib.util.module_from_spec(spec)
loader.exec_module(titles)


class PaneTitlesTest(unittest.TestCase):
    def test_installed_harness_process_shapes(self):
        for process, app in (
            ({'name': 'grok-1.0.70-macos-aarch64', 'argv0': 'grok'}, 'grok'),
            ({'name': 'node', 'argv0': '/opt/bin/cursor-agent', 'script': '/opt/cursor-agent/versions/current/index.js'}, 'cursor'),
            ({'name': '2.1.311', 'argv0': 'claude'}, 'claude'),
            ({'name': 'node', 'script': '/opt/lib/node_modules/@earendil-works/pi-coding-agent/dist/cli.js'}, 'pi'),
            ({'name': 'codex', 'argv0': 'codex'}, 'codex'),
            ({'name': 'zsh', 'argv0': '-zsh'}, 'shell'),
            ({'name': 'python3', 'script': '/work/grok-analysis.py'}, 'grok-analysis.py'),
        ):
            with self.subTest(app=app):
                self.assertEqual(titles.app_name(process), app)

    def test_agent_task_survives_tool_subprocess(self):
        agent = {'pid': 7, 'name': 'grok', 'argv0': 'grok'}
        processes = {'foreground': agent}
        label, task = titles.pane_label(processes, {'owner': {'pid': 7}, 'title': 'Fix login'}, 'api')
        self.assertEqual(label, 'api · grok · Fix login')
        child = {'foreground': {'pid': 8, 'name': 'git'}, 'ancestors': [agent]}
        self.assertEqual(titles.pane_label(child, {'owner': {'pid': 8}, 'title': 'git status'}, 'api', task)[0], label)

    def test_shell_drops_agent_task_and_private_shell_title(self):
        process = {'foreground': {'pid': 9, 'name': 'zsh', 'argv0': '-zsh'}}
        label, task = titles.pane_label(process, {'title': 'some-user@long-host:/private/path'}, 'api', (7, 'Fix login'))
        self.assertEqual(label, 'api · shell')
        self.assertIsNone(task)

    def test_task_is_not_inherited_by_another_agent(self):
        process = {'foreground': {'pid': 10, 'name': 'codex'}}
        label, _ = titles.pane_label(process, {'owner': {'pid': 9}, 'title': 'old task'}, 'api', (7, 'old task'))
        self.assertEqual(label, 'api · codex')

    def test_spinner_title_is_normalized_without_duplicate_prefix(self):
        process = {'foreground': {'pid': 7, 'name': 'claude'}}
        label, _ = titles.pane_label(process, {'owner': {'pid': 8}, 'title': '◑ Fix login'}, 'api')
        self.assertEqual(label, 'api · claude · Fix login')

    def test_grok_title_does_not_repeat_harness(self):
        process = {'foreground': {'pid': 7, 'name': 'grok'}}
        label, _ = titles.pane_label(process, {'owner': {'pid': 7}, 'title': 'Fix login - grok'}, 'api')
        self.assertEqual(label, 'api · grok · Fix login')

    def test_formatted_title_does_not_grow_on_redraw(self):
        process = {'foreground': {'pid': 7, 'name': 'claude'}}
        label, _ = titles.pane_label(process, {'owner': {'pid': 7}, 'title': '◑ api · claude · Fix login'}, 'api')
        self.assertEqual(label, 'api · claude · Fix login')
        label, _ = titles.pane_label(process, {'owner': {'pid': 99}, 'title': label}, 'api')
        self.assertEqual(label, 'api · claude · Fix login')

    def test_refresh_updates_label_without_writing_terminal_title(self):
        with tempfile.TemporaryDirectory() as temporary:
            watcher = titles.Titles('rex', Path(temporary) / 'state.json')
            def call(*args):
                if args[:2] == ('block', 'ls'):
                    return {'blocks': [{'block_id': 'b', 'creator_name': 'com.superlogical.terminal', 'label': 'shell'}]}
                return {'process': {'foreground': {'pid': 7, 'name': 'codex', 'cwd': '/work/api'}},
                        'title': {'owner': {'pid': 7}, 'title': 'Fix login'}}[args[-1]]
            watcher.call = call
            watcher.repo = lambda _: 'api'
            with patch.object(titles.subprocess, 'run') as run:
                run.return_value.returncode = 0
                watcher.refresh('s', 'b')
                run.assert_called_once_with(['rex', '--autostart=false', '--timeout=3s', 'block', 'rename',
                                             '-s', 's', 'b', 'api · codex · Fix login'], capture_output=True, timeout=5)
            self.assertEqual(watcher.owned['b'], 'api · codex · Fix login')

    def test_manual_label_is_preserved(self):
        with tempfile.TemporaryDirectory() as temporary:
            watcher = titles.Titles('rex', Path(temporary) / 'state.json')
            watcher.call = lambda *args: {'blocks': [{'block_id': 'b', 'creator_name': 'com.superlogical.terminal', 'label': 'Production logs'}]}
            with patch.object(titles.subprocess, 'run') as run:
                watcher.refresh('s', 'b')
                run.assert_not_called()

    def test_home_folder_does_not_expose_username(self):
        with tempfile.TemporaryDirectory() as temporary:
            watcher = titles.Titles('rex', Path(temporary) / 'state.json')
            self.assertEqual(watcher.repo(str(Path.home())), '~')

    def test_manual_rename_releases_automatic_label(self):
        with tempfile.TemporaryDirectory() as temporary:
            watcher = titles.Titles('rex', Path(temporary) / 'state.json')
            watcher.owned['b'] = 'api · claude · Fix login'
            watcher.call = lambda *args: {'blocks': [{'block_id': 'b', 'label': 'Review'}]}
            watcher.event({'type': 'session_event', 'payload': {'session_id': 's', 'event': {'type': 'session_view_changed'}}})
            self.assertNotIn('b', watcher.owned)

    def test_label_filters_controls_and_bounds_length(self):
        process = {'foreground': {'pid': 7, 'name': 'codex'}}
        label, _ = titles.pane_label(process, {'owner': {'pid': 7}, 'title': '\x1b]2;\n' + 'task ' * 80}, 'api')
        self.assertLessEqual(len(label), 128)
        self.assertNotIn('\x1b', label)
        self.assertNotIn('\n', label)

    def test_spinner_frames_do_not_trigger_repeated_relabel_calls(self):
        with tempfile.TemporaryDirectory() as temporary:
            watcher = titles.Titles('rex', Path(temporary) / 'state.json')
            with patch.object(watcher, 'safe_refresh') as refresh:
                for title in ('◐ Fix login', '◑ Fix login', 'Fix login'):
                    watcher.event({'type': 'session_event', 'payload': {'session_id': 's', 'event': {
                        'type': 'block_event', 'payload': {'block_id': 'b', 'name': 'title_changed', 'payload': {'title': title}}
                    }}})
                self.assertEqual(refresh.call_count, 1)

    def test_agent_title_events_do_not_write_competing_terminal_titles(self):
        with tempfile.TemporaryDirectory() as temporary:
            watcher = titles.Titles('rex', Path(temporary) / 'state.json')
            watcher.owned['b'] = 'api · codex · Fix login'
            tty = Path(temporary) / 'tty'
            watcher.ttys = {'b': tty}
            watcher.statuses = {'b': 'working'}
            with patch.object(watcher, 'safe_refresh'):
                for frame in ('⠇', '⠏', '⠋'):
                    watcher.event({'type': 'session_event', 'payload': {'session_id': 's', 'event': {
                        'type': 'block_event', 'payload': {'block_id': 'b', 'name': 'title_changed',
                        'payload': {'title': frame + ' api | GPT-6', 'owner': {'pid': 7, 'name': 'codex'}}}
                    }}})
            self.assertFalse(tty.exists(), 'the watcher must leave terminal titles to the foreground program')

    def test_braille_frames_are_not_task_names(self):
        process = {'foreground': {'pid': 7, 'name': 'codex'}}
        for frame in ('⠇', '⠏', '⠋', '⠙'):
            label, _ = titles.pane_label(process, {'owner': {'pid': 7}, 'title': frame + ' Fix login'}, 'api')
            self.assertEqual(label, 'api · codex · Fix login')

    def test_task_is_pinned_for_the_agent_session(self):
        process = {'foreground': {'pid': 7, 'name': 'codex'}}
        label, _ = titles.pane_label(process, {'owner': {'pid': 7}, 'title': 'Inspecting database'}, 'api', (7, 'Fix login'))
        self.assertEqual(label, 'api · codex · Fix login')

    def test_codex_thread_title_does_not_repeat_project(self):
        process = {'foreground': {'pid': 7, 'name': 'codex'}}
        label, _ = titles.pane_label(process, {'owner': {'pid': 7}, 'title': 'api | Fix login'}, 'api')
        self.assertEqual(label, 'api · codex · Fix login')

    def test_status_changes_do_not_trigger_title_or_label_rewrites(self):
        with tempfile.TemporaryDirectory() as temporary:
            watcher = titles.Titles('rex', Path(temporary) / 'state.json')
            watcher.owned['b'] = 'api · codex · Fix login'
            with patch.object(watcher, 'safe_refresh') as refresh, patch.object(titles.subprocess, 'run') as run:
                for state in ('working', 'blocked', 'done'):
                    watcher.event({'type': 'session_event', 'payload': {'session_id': 's', 'event': {
                        'type': 'block_event', 'payload': {'block_id': 'b', 'name': 'program_status_changed', 'payload': {'record': {'state': state}}}
                    }}})
                refresh.assert_not_called()
                run.assert_not_called()
            self.assertEqual(watcher.owned['b'], 'api · codex · Fix login')


if __name__ == '__main__':
    unittest.main()
