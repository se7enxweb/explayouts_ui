<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>7x Template Editor</title>
    <style>
        :root {
            --bg: #0f172a;
            --panel: #1e293b;
            --panel-2: #334155;
            --fg: #e2e8f0;
            --muted: #94a3b8;
            --accent: #38bdf8;
            --accent-2: #818cf8;
            --ok: #4ade80;
            --warn: #fbbf24;
            --danger: #f87171;
            --font: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace;
        }
        * { box-sizing: border-box; }
        html, body { height: 100%; margin: 0; background: var(--bg); color: var(--fg); font-family: var(--font); font-size: 14px; }
        .app { display: flex; height: 100vh; overflow: hidden; }
        .sidebar { width: 420px; min-width: 260px; max-width: 80vw; background: var(--panel); border-right: 1px solid var(--panel-2); display: flex; flex-direction: column; position: relative; }
        .resizer { width: 6px; cursor: col-resize; background: var(--panel-2); position: absolute; right: 0; top: 0; bottom: 0; z-index: 10; }
        .sidebar-header { padding: 1rem; border-bottom: 1px solid var(--panel-2); }
        .sidebar-header h1 { margin: 0 0 .5rem; font-size: 1.1rem; color: var(--accent); }
        .sidebar-header h1 small { color: var(--muted); font-weight: 400; }
        .sidebar input[type="text"] { width: 100%; padding: .5rem; background: var(--bg); color: var(--fg); border: 1px solid var(--panel-2); border-radius: .25rem; }
        .flat-list { flex: 1; overflow: auto; padding: .5rem; }
        .flat-list .empty { color: var(--muted); padding: 1rem .5rem; text-align: center; }
        .flat-list button { display: block; width: 100%; text-align: left; background: transparent; color: var(--fg); border: none; border-radius: .25rem; padding: .3rem .5rem; cursor: pointer; font-family: inherit; font-size: 13px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .flat-list button:hover { background: var(--panel-2); }
        .flat-list button.active { background: var(--accent-2); color: #fff; }
        .main { flex: 1; display: flex; flex-direction: column; min-width: 0; }
        .toolbar { display: flex; align-items: center; gap: .5rem; padding: .75rem 1rem; background: var(--panel); border-bottom: 1px solid var(--panel-2); }
        .exit-btn { margin-left: auto; }
        .toolbar .path { flex: 1; color: var(--muted); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .toolbar .status { padding: .25rem .75rem; border-radius: .25rem; font-size: .85rem; opacity: 0; transition: opacity .2s; }
        .toolbar .status.show { opacity: 1; }
        .toolbar .status.ok { background: rgba(74,222,128,.2); color: var(--ok); }
        .toolbar .status.err { background: rgba(248,113,113,.2); color: var(--danger); }
        .btn { padding: .45rem .9rem; border: none; border-radius: .25rem; background: var(--accent); color: #0f172a; cursor: pointer; font-weight: 600; font-family: inherit; }
        .btn:hover { filter: brightness(1.1); }
        .btn.secondary { background: var(--panel-2); color: var(--fg); }
        .editor-wrap { flex: 1; display: flex; overflow: hidden; position: relative; }
        .line-numbers { width: 3.5rem; padding: 1rem .5rem; background: var(--panel); color: var(--muted); text-align: right; overflow: hidden; white-space: pre; line-height: 1.5; }
        textarea#tpl-editor { flex: 1; padding: 1rem; background: var(--bg); color: var(--fg); border: none; outline: none; resize: none; line-height: 1.5; font-family: var(--font); font-size: 14px; tab-size: 2; white-space: pre; overflow: auto; }
        .empty { flex: 1; display: flex; align-items: center; justify-content: center; color: var(--muted); font-size: 1.2rem; }
        .error-box { flex: 1; display: flex; align-items: center; justify-content: center; color: var(--danger); padding: 1rem; text-align: center; }
    </style>
</head>
<body>
<div class="app">
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <h1>7x Template Editor <small id="tpl-count"></small></h1>
            <input type="text" id="filter" placeholder="Filter templates..." autocomplete="off">
        </div>
        <nav class="flat-list" id="tree"></nav>
        <div class="resizer" id="resizer"></div>
    </aside>
    <main class="main">
        <div class="toolbar">
            <button class="btn secondary" id="new-file">New</button>
            <button class="btn" id="save-file">Save</button>
            <button class="btn secondary exit-btn" id="exit-editor" title="Return to admin">×</button>
            <span class="path" id="path">No file selected</span>
            <span class="status" id="status"></span>
        </div>
        <div class="editor-wrap" id="editor-wrap">
            <div class="empty">Select a template from the list to start editing.</div>
        </div>
    </main>
</div>

<script>
window.TPL_FILES = {$files_json};
window.BASE_URL = {$base_url};
window.SELECTED = {$selected_json};
window.INITIAL = {$initial_content_json};
window.CSRF_TOKEN = {$csrf_token};

document.addEventListener('DOMContentLoaded', function() {
    if (!Array.isArray(window.TPL_FILES)) {
        window.TPL_FILES = [];
    }

    var tree = document.getElementById('tree');
    var filter = document.getElementById('filter');
    var saveBtn = document.getElementById('save-file');
    var newBtn = document.getElementById('new-file');
    var exitBtn = document.getElementById('exit-editor');
    var pathEl = document.getElementById('path');
    var statusEl = document.getElementById('status');
    var editorWrap = document.getElementById('editor-wrap');
    var countEl = document.getElementById('tpl-count');
    var sidebar = document.getElementById('sidebar');
    var resizer = document.getElementById('resizer');

    var currentPath = '';
    var editor = null;
    var lineNumbers = null;
    var startX = 0;
    var startWidth = 0;

    function doDrag(e) {
        var newWidth = startWidth + e.clientX - startX;
        if ( newWidth < 260 ) newWidth = 260;
        if ( newWidth > window.innerWidth * 0.8 ) newWidth = window.innerWidth * 0.8;
        sidebar.style.width = newWidth + 'px';
    }

    function stopDrag() {
        document.documentElement.removeEventListener('mousemove', doDrag, false);
        document.documentElement.removeEventListener('mouseup', stopDrag, false);
    }

    resizer.addEventListener('mousedown', function(e) {
        startX = e.clientX;
        startWidth = parseInt( document.defaultView.getComputedStyle( sidebar ).width, 10 );
        document.documentElement.addEventListener('mousemove', doDrag, false);
        document.documentElement.addEventListener('mouseup', stopDrag, false);
        e.preventDefault();
    });

    function showError(where, msg) {
        where.innerHTML = '<div class="error-box">' + msg + '</div>';
        console.error(msg);
    }

    function renderFlat(term) {
        try {
            tree.innerHTML = '';
            if (!Array.isArray(window.TPL_FILES)) {
                showError(tree, 'TPL_FILES is not an array. Check the server response.');
                return;
            }
            var lower = (term || '').toLowerCase();
            var files = lower
                ? window.TPL_FILES.filter(function(p) { return p.toLowerCase().indexOf(lower) !== -1; })
                : window.TPL_FILES;
            if (!files.length) {
                tree.innerHTML = '<p class="empty">No templates match.</p>';
                return;
            }
            files.forEach(function(file) {
                var btn = document.createElement('button');
                btn.textContent = file;
                btn.title = file;
                btn.className = 'flat-item';
                if (file === currentPath) btn.classList.add('active');
                btn.addEventListener('click', function() { loadFile(file); });
                tree.appendChild(btn);
            });
        } catch (e) {
            showError(tree, 'Render error: ' + e.message);
        }
    }

    function createEditor() {
        editorWrap.innerHTML = '';
        lineNumbers = document.createElement('div');
        lineNumbers.className = 'line-numbers';
        editor = document.createElement('textarea');
        editor.id = 'tpl-editor';
        editor.spellcheck = false;
        editorWrap.appendChild(lineNumbers);
        editorWrap.appendChild(editor);

        editor.addEventListener('input', updateLineNumbers);
        editor.addEventListener('scroll', function() { lineNumbers.scrollTop = editor.scrollTop; });
        editor.addEventListener('keydown', function(e) {
            if (e.key === 'Tab') {
                e.preventDefault();
                var start = editor.selectionStart;
                var end = editor.selectionEnd;
                editor.value = editor.value.substring(0, start) + '  ' + editor.value.substring(end);
                editor.selectionStart = editor.selectionEnd = start + 2;
                updateLineNumbers();
            }
            if ((e.ctrlKey || e.metaKey) && e.key === 's') {
                e.preventDefault();
                saveFile();
            }
        });
    }

    function updateLineNumbers() {
        var lines = editor.value.split('\n').length;
        var lineTexts = [];
        for (var i = 1; i <= lines; i++) {
            lineTexts.push(i);
        }
        lineNumbers.textContent = lineTexts.join('\n');
    }

    function showStatus(msg, ok) {
        statusEl.textContent = msg;
        statusEl.className = 'status show ' + (ok ? 'ok' : 'err');
        setTimeout(function() { statusEl.classList.remove('show'); }, 2500);
    }

    function loadFile(path) {
        try {
            currentPath = path;
            createEditor();
            pathEl.textContent = path;
            renderFlat(filter.value);
            fetch(BASE_URL + '?file=' + encodeURIComponent(path), {
                headers: { 'X-Requested-With': 'XMLHttpRequest' }
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.error) throw new Error(data.error);
                editor.value = data.content || '';
                updateLineNumbers();
                editor.focus();
            })
            .catch(function(err) { showStatus(err.message, false); });
        } catch (e) {
            showStatus('Load error: ' + e.message, false);
        }
    }

    function saveFile() {
        try {
            if (!currentPath) { showStatus('No file selected', false); return; }
            var body = 'SaveTemplate=1&ezxform_token=' + encodeURIComponent(CSRF_TOKEN)
                       + '&SelectedPath=' + encodeURIComponent(currentPath)
                       + '&TemplateContent=' + encodeURIComponent(editor.value);
            fetch(BASE_URL, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: body
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                showStatus(data.message || 'Saved', data.success);
            })
            .catch(function(err) { showStatus('Save failed: ' + err.message, false); });
        } catch (e) {
            showStatus('Save error: ' + e.message, false);
        }
    }

    saveBtn.addEventListener('click', saveFile);

    exitBtn.addEventListener('click', function() {
        try {
            window.location.href = document.referrer && document.referrer.indexOf(window.location.hostname) !== -1
                ? document.referrer
                : '/';
        } catch (e) {
            window.location.href = '/';
        }
    });

    newBtn.addEventListener('click', function() {
        try {
            var p = prompt('New template path (relative to design/ or extension/, must end in .tpl):');
            if (!p) return;
            var endsWithTpl = p.length >= 4 && p.lastIndexOf('.tpl') === p.length - 4;
            if (!endsWithTpl) { showStatus('Path must end in .tpl', false); return; }
            currentPath = p;
            createEditor();
            pathEl.textContent = p;
            editor.value = '';
            updateLineNumbers();
            if (!Array.isArray(window.TPL_FILES)) window.TPL_FILES = [];
            window.TPL_FILES.push(p);
            window.TPL_FILES.sort();
            countEl.textContent = '(' + window.TPL_FILES.length + ' templates)';
            renderFlat(filter.value);
        } catch (e) {
            showStatus('New file error: ' + e.message, false);
        }
    });

    filter.addEventListener('input', function() { renderFlat(filter.value); });

    if (SELECTED) {
        currentPath = SELECTED;
        pathEl.textContent = SELECTED;
    }

    if (window.TPL_FILES && window.TPL_FILES.length) {
        countEl.textContent = '(' + window.TPL_FILES.length + ' templates)';
    } else {
        countEl.textContent = '(0 templates)';
    }

    renderFlat('');

    if (SELECTED) {
        createEditor();
        editor.value = INITIAL;
        updateLineNumbers();
    }
});
</script>
</body>
</html>
