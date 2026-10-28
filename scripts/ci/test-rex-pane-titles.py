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

    def test_visible_title_is_emitted_and_spinner_preserved(self):
        with tempfile.TemporaryDirectory() as temporary:
            watcher = titles.Titles('rex', Path(temporary) / 'state.json')
            tty = Path(temporary) / 'tty'
            watcher.ttys['b'] = tty
            watcher.owned['b'] = 'api · cursor · Fix login'
            watcher.draw('b', '◑ Fix login')
            self.assertEqual(tty.read_text(), '\x1b]2;◑ api · cursor · Fix login\x07')

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

    def test_manual_rename_stops_visible_title_rewrites(self):
        with tempfile.TemporaryDirectory() as temporary:
            watcher = titles.Titles('rex', Path(temporary) / 'state.json')
            watcher.owned['b'] = 'api · claude · Fix login'
            tty = Path(temporary) / 'tty'
            watcher.ttys['b'] = tty
            watcher.call = lambda *args: {'blocks': [{'block_id': 'b', 'label': 'Review'}]}
            watcher.event({'type': 'session_event', 'payload': {'session_id': 's', 'event': {'type': 'session_view_changed'}}})
            watcher.draw('b', '◑ Fix login')
            self.assertFalse(tty.exists())

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


if __name__ == '__main__':
    unittest.main()
