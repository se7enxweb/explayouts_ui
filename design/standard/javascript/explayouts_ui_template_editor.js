/* The template editor of explayouts_ui (explayouts_ui/template_editor), for every admin design. Its markup is
   parts/template_editor_body.tpl, its values the JSON data block #explayouts-ui-te-data (no inline script).

   - The list: search (name or path), design, folder and state filters; one button per template.
   - The editor: a textarea over a highlighted copy of its text (template tags, variables, operators, strings,
     comments, HTML tags), with line numbers. Tab indents; Esc then Tab leaves the text.
   - Ctrl+S / Cmd+S or "Review changes": the server's syntax check and the diff against the saved template (or the
     original), then Save in the review. A syntax error refuses the save and lists the lines; a line jumps there.
   - Revert to original (with a confirmation), and a guard against leaving or switching with unsaved changes.
   - The list is the design chain of one public siteaccess: which file each template is drawn from, which ones it
     overrides; a read-only template can be copied as an override into a design that comes before it.
   The address carries view parameters only: <base>/<path>/(siteaccess)/<name>/(design)/<base>.
   Every write is a POST with the form token; the server checks the policy again. */
function explayoutsUiTemplateEditor() {
    'use strict';

    var block = document.getElementById('explayouts-ui-te-data');
    if (!block) {
        return;
    }
    var data = {};
    try { data = JSON.parse(block.textContent); } catch (e) { data = {}; }
    var T = data.i18n || {};
    var E = data.editor || {};
    var rows = Array.isArray(E.rows) ? E.rows : [];
    var canEdit = !!E.can_edit;
    // the extension is named on a row only when the templates come from more than one
    var manyExtensions = rows.some(function (row) { return row.extension !== (rows[0] && rows[0].extension); });

    function $(id) { return document.getElementById(id); }
    function fmt(text, values) {
        return String(text || '').replace(/%[a-z]+/g, function (key) {
            return Object.prototype.hasOwnProperty.call(values, key.slice(1)) ? values[key.slice(1)] : key;
        });
    }
    function el(tag, cls, text) {
        var node = document.createElement(tag);
        if (cls) { node.className = cls; }
        if (text !== undefined && text !== null) { node.textContent = text; }
        return node;
    }
    // the view's address with its view parameters: the template's path, (siteaccess), (design)
    function viewUrl(path, design) {
        var url = E.base_url || '';
        var enc = function (p) { return p.split('/').map(encodeURIComponent).join('/'); };
        if (path) { url += '/' + enc(path); }
        if (E.siteaccess) { url += '/(siteaccess)/' + encodeURIComponent(E.siteaccess); }
        if (design) { url += '/(design)/' + enc(design); }
        return url;
    }
    function escapeHtml(s) {
        return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    /* ---- highlighting ---------------------------------------------------------------------------------------- */

    // one pass over the text: template comments, template tags, HTML comments, HTML tags
    var TOKENS = /(\{\*[\s\S]*?\*\})|(\{(?![\s}])[^{}]*\})|(<!--[\s\S]*?-->)|(<\/?[A-Za-z][^<>]*>)/g;

    function highlightTag(tag) {
        // {name ...} / {/name}: name as keyword; strings, $variables, |operators inside
        var m = /^\{(\/?)([A-Za-z][\w-]*)?/.exec(tag);
        var head = m ? m[0] : '{';
        var out = '<span class="te-b">{' + escapeHtml(m && m[1] ? m[1] : '') + '</span>';
        if (m && m[2]) { out += '<span class="te-k">' + escapeHtml(m[2]) + '</span>'; }
        var rest = tag.slice(head.length, -1);
        out += escapeHtml(rest).replace(/(&quot;|"[^"]*"|'[^']*')|(\$[\w.#-]+)|(\|[A-Za-z_][\w]*)/g, function (all, str, variable, operator) {
            if (str) { return '<span class="te-s">' + str + '</span>'; }
            if (variable) { return '<span class="te-v">' + variable + '</span>'; }
            return '<span class="te-o">' + operator + '</span>';
        });
        return out + '<span class="te-b">}</span>';
    }

    function highlightHtmlTag(tag) {
        var m = /^<(\/?)([A-Za-z][\w:-]*)/.exec(tag);
        var out = '<span class="te-t">&lt;' + escapeHtml(m[1] + m[2]) + '</span>';
        var rest = tag.slice(m[0].length);
        out += escapeHtml(rest).replace(/([\w:-]+)(=)|("[^"]*"|'[^']*')|(\{[^{}]*\})/g, function (all, name, eq, str, inner) {
            if (name) { return '<span class="te-a">' + name + '</span>' + eq; }
            if (str) { return '<span class="te-s">' + str + '</span>'; }
            return inner;
        });
        return out.replace(/&gt;$/, '<span class="te-t">&gt;</span>');
    }

    function highlight(text) {
        var out = '';
        var last = 0;
        TOKENS.lastIndex = 0;
        var m;
        while ((m = TOKENS.exec(text)) !== null) {
            out += escapeHtml(text.slice(last, m.index));
            if (m[1] || m[3]) { out += '<span class="te-c">' + escapeHtml(m[0]) + '</span>'; }
            else if (m[2]) { out += highlightTag(m[0]); }
            else { out += highlightHtmlTag(m[0]); }
            last = TOKENS.lastIndex;
        }
        out += escapeHtml(text.slice(last));
        // a last empty line still takes its height
        return out + '\n';
    }

    /* ---- state ----------------------------------------------------------------------------------------------- */

    var list = $('te-files'), search = $('te-search'), fDesign = $('te-design'), fGroup = $('te-group'), fState = $('te-state');
    var countEl = $('te-count'), titleEl = $('te-file-title'), pathEl = $('te-file-path'), facts = $('te-facts');
    var code = $('te-code'), gutter = $('te-gutter'), hl = $('te-highlight'), text = $('te-text'), empty = $('te-empty');
    var foot = $('te-foot'), statusEl = $('te-status'), problems = $('te-problems');
    var saveBtn = $('te-save'), reviewBtn = $('te-review-open'), revertBox = $('te-revert-box'), revertBtn = $('te-revert');
    var review = $('te-review'), reviewSum = $('te-review-sum'), reviewChecks = $('te-review-checks'), reviewDiff = $('te-review-diff');
    var compare = $('te-compare'), reviewSave = $('te-review-save'), reviewClose = $('te-review-close');
    var newBtn = $('te-new'), newDialog = $('te-new-dialog'), newPath = $('te-new-path');
    var readonlyBox = $('te-readonly'), overrideBox = $('te-override-box'), overrideTarget = $('te-override-target'), overrideBtn = $('te-override');

    var current = '';       // the path open in the editor
    var saved = '';         // its text as saved
    var isNew = false;      // a new template, not saved yet
    var meta = null;
    var lastKeyEscape = false;
    var busy = false;
    var gutterLines = 0;

    function dirty() { return !!current && (isNew || text.value !== saved); }

    function setStatus(message, kind) {
        statusEl.textContent = message || '';
        statusEl.className = 'a4-status explayouts-te-status' + (kind ? ' is-' + kind : '');
    }

    function updateButtons() {
        var changed = dirty();
        if (saveBtn) { saveBtn.disabled = !changed || busy || text.readOnly; }
        if (reviewBtn) { reviewBtn.disabled = !current || busy; }
        if (!busy) { setStatus(current ? (changed ? T.unsaved : T.no_changes) : '', changed ? 'warn' : ''); }
    }

    /* ---- the list -------------------------------------------------------------------------------------------- */

    function matches(row) {
        var q = (search.value || '').trim().toLowerCase();
        if (q && row.path.toLowerCase().indexOf(q) === -1) { return false; }
        if (fDesign.value && row.base !== fDesign.value) { return false; }
        if (fGroup.value && row.group !== fGroup.value) { return false; }
        // overridden: another design of the chain comes first, so this file is not the one drawn
        var overridden = row.winner === false;
        if (fState.value === 'changed' && !row.changed) { return false; }
        if (fState.value === 'overridden' && !overridden) { return false; }
        if (fState.value === 'not-overridden' && overridden) { return false; }
        return true;
    }

    function renderList() {
        list.textContent = '';
        var shown = 0;
        rows.forEach(function (row) {
            if (!matches(row)) { return; }
            shown++;
            var li = el('li');
            var btn = el('button', 'explayouts-te-file');
            btn.type = 'button';
            btn.title = row.path;
            btn.setAttribute('data-path', row.path);
            if (row.path === current) { btn.setAttribute('aria-current', 'true'); }
            btn.appendChild(el('span', 'explayouts-te-file-name', row.name));
            btn.appendChild(el('span', 'explayouts-te-file-folder', row.group || row.folder));
            var tags = el('span', 'a4-badges explayouts-te-file-tags');
            if (row.design) { tags.appendChild(el('span', 'a4-tag', row.design)); }
            if (row.extension && manyExtensions) { tags.appendChild(el('span', 'a4-tag is-mono', row.extension)); }
            if (row.changed) { tags.appendChild(el('span', 'a4-tag is-warn', T.changed)); }
            if (row.winner === true && row.overrides && row.overrides.length) {
                var won = el('span', 'a4-tag is-ok', fmt(T.winner, { siteaccess: E.siteaccess }));
                won.title = fmt(T.overrides, { paths: row.overrides.join(', ') });
                tags.appendChild(won);
            }
            if (row.overridden_by && row.overridden_by.length) {
                var lost = el('span', 'a4-tag is-info', fmt(T.overridden, { count: row.overridden_by.length }));
                lost.title = fmt(T.overridden_by, { paths: row.overridden_by.join(', ') });
                tags.appendChild(lost);
            }
            if (!row.writable) { tags.appendChild(el('span', 'a4-tag', T.read_only)); }
            btn.appendChild(tags);
            btn.addEventListener('click', function () { open(row.path); });
            li.appendChild(btn);
            list.appendChild(li);
        });
        if (!shown) {
            list.appendChild(el('li', 'a4-empty', T.no_match));
        }
        countEl.textContent = shown === rows.length ? fmt(T.count, { count: rows.length })
                                                    : fmt(T.count_of, { shown: shown, count: rows.length });
    }

    [search, fDesign, fGroup, fState].forEach(function (control) {
        control.addEventListener(control === search ? 'input' : 'change', renderList);
    });
    // the design filter is a view parameter of the address too
    fDesign.addEventListener('change', function () { setAddress(); });

    // the siteaccess chooser posts its form at once (the button stays for a page without the script)
    var saSelect = $('te-siteaccess');
    if (saSelect && saSelect.form) {
        saSelect.addEventListener('change', function () {
            if (dirty() && !window.confirm(T.discard)) { saSelect.value = E.siteaccess; return; }
            var button = saSelect.form.querySelector('[name="ChooseSiteAccessButton"]');
            if (typeof saSelect.form.requestSubmit === 'function') { saSelect.form.requestSubmit(button); } else { button.click(); }
        });
    }

    function setAddress() {
        try { window.history.replaceState(null, '', viewUrl(current, fDesign.value)); } catch (e) { /* the address stays as it is */ }
    }

    /* ---- the editor ------------------------------------------------------------------------------------------ */

    function lineCount(value) { return value.split('\n').length; }

    function paint() {
        hl.innerHTML = highlight(text.value);
        var n = lineCount(text.value);
        if (gutterLines !== n) {
            gutterLines = n;
            var lines = [];
            for (var i = 1; i <= n; i++) { lines.push(i); }
            gutter.textContent = lines.join('\n') + '\n';
        }
        syncScroll();
    }

    function syncScroll() {
        hl.scrollTop = text.scrollTop;
        hl.scrollLeft = text.scrollLeft;
        gutter.scrollTop = text.scrollTop;
    }

    function showMeta() {
        facts.textContent = '';
        if (isNew) {
            facts.appendChild(el('span', 'a4-tag is-warn', T.new_hint));
        }
        if (!meta) { return; }
        if (meta.has_original) { facts.appendChild(el('span', 'a4-tag is-warn', T.changed)); }
        if (meta.used_by) {
            var u = meta.used_by;
            var label = u.count === 0 ? T.unused
                : (u.kind === 'block' ? fmt(T.used_blocks, { count: u.count, layouts: u.layouts }) : fmt(T.used_layouts, { count: u.count }));
            facts.appendChild(el('span', 'a4-tag' + (u.count ? ' is-accent' : ''), label));
        }
        if (meta.winner === true) {
            var won = el('span', 'a4-tag is-ok', fmt(T.winner, { siteaccess: E.siteaccess }));
            if (meta.overrides && meta.overrides.length) { won.title = fmt(T.overrides, { paths: meta.overrides.join(', ') }); }
            facts.appendChild(won);
        }
        if (meta.overridden_by && meta.overridden_by.length) {
            var tag = el('span', 'a4-tag is-info', fmt(T.overridden, { count: meta.overridden_by.length }));
            tag.title = fmt(T.overridden_by, { paths: meta.overridden_by.join(', ') });
            facts.appendChild(tag);
        }
        if (!meta.writable) { facts.appendChild(el('span', 'a4-tag', T.read_only)); }
        if (revertBox) {
            revertBox.hidden = !meta.has_original || !meta.writable;
            revertBox.open = false;
        }
        // read-only: the text cannot be changed; an override can be made where the chain allows one
        text.readOnly = !canEdit || !meta.writable;
        if (readonlyBox) {
            var targets = Array.isArray(meta.override_targets) ? meta.override_targets : [];
            readonlyBox.hidden = meta.writable;
            overrideBox.hidden = targets.length === 0;
            overrideTarget.textContent = '';
            targets.forEach(function (base) {
                var option = el('option', '', base);
                option.value = base;
                overrideTarget.appendChild(option);
            });
        }
    }

    function showEditor(path) {
        current = path;
        var slash = path.lastIndexOf('/');
        titleEl.textContent = path.slice(slash + 1);
        pathEl.textContent = path;
        empty.hidden = true;
        code.hidden = false;
        foot.hidden = false;
        hideProblems();
        renderList();
        setAddress();
    }

    function open(path) {
        if (path === current) { return; }
        if (dirty() && !window.confirm(T.discard)) { return; }
        isNew = false;
        meta = E.selected_meta && path === E.selected ? E.selected_meta : null;
        if (readonlyBox) { readonlyBox.hidden = true; }
        showEditor(path);
        showMeta();
        text.value = '';
        saved = '';
        paint();
        busy = true;
        setStatus(T.loading, '');
        updateButtons();
        request('GET', path).then(function (res) {
            busy = false;
            if (!res.success) { throw new Error(res.error || ''); }
            if (path !== current) { return; }
            saved = typeof res.content === 'string' ? res.content : '';
            text.value = saved;
            meta = res.meta || null;
            showMeta();
            paint();
            text.scrollTop = 0;
            updateButtons();
        }).catch(function (err) {
            busy = false;
            updateButtons();
            setStatus(fmt(T.load_error, { message: err.message }), 'bad');
        });
    }

    text.addEventListener('input', function () { paint(); updateButtons(); });
    text.addEventListener('scroll', syncScroll);
    text.addEventListener('keydown', function (e) {
        if ((e.ctrlKey || e.metaKey) && !e.altKey && (e.key === 's' || e.key === 'S')) {
            e.preventDefault();
            if (!text.readOnly) { openReview(); }
            return;
        }
        if (e.key === 'Escape') { lastKeyEscape = true; return; }
        if (e.key === 'Tab' && !lastKeyEscape && !text.readOnly && !e.ctrlKey && !e.altKey && !e.metaKey) {
            e.preventDefault();
            indent(e.shiftKey);
        }
        lastKeyEscape = false;
    });

    // Tab: spaces up to the next tab stop; with a selection or Shift, the selected lines move in or out
    function indent(outdent) {
        var v = text.value, start = text.selectionStart, end = text.selectionEnd, size = 4;
        if (!outdent && start === end) {
            var col = start - (v.lastIndexOf('\n', start - 1) + 1);
            var spaces = new Array(size - (col % size) + 1).join(' ');
            text.setRangeText(spaces, start, end, 'end');
        } else {
            var lineStart = v.lastIndexOf('\n', start - 1) + 1;
            var block = v.slice(lineStart, end);
            var changed = block.split('\n').map(function (line) {
                if (!outdent) { return '    ' + line; }
                return line.replace(/^( {1,4}|\t)/, '');
            }).join('\n');
            text.setRangeText(changed, lineStart, end, 'select');
        }
        paint();
        updateButtons();
    }

    function jumpToLine(line) {
        var lines = text.value.split('\n');
        var pos = 0;
        for (var i = 0; i < Math.min(line - 1, lines.length); i++) { pos += lines[i].length + 1; }
        text.focus();
        text.setSelectionRange(pos, pos + (lines[line - 1] || '').length);
        var lh = parseFloat(window.getComputedStyle(text).lineHeight) || 20;
        text.scrollTop = Math.max(0, (line - 4) * lh);
        syncScroll();
    }

    /* ---- the server ------------------------------------------------------------------------------------------ */

    function request(method, params) {
        // GET: params is the template's path, sent as view parameters; POST: the form fields
        var url = method === 'GET' ? viewUrl(params) : viewUrl('');
        var init = { method: method, credentials: 'same-origin', headers: { 'X-Requested-With': 'XMLHttpRequest' } };
        if (method !== 'GET') {
            var body = new URLSearchParams(params);
            body.set('SiteAccess', E.siteaccess || '');
            body.set('ezxform_token', E.csrf_token || '');
            init.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8';
            init.body = body.toString();
        }
        return fetch(url, init).then(function (r) {
            return r.json().catch(function () { throw new Error('HTTP ' + r.status); });
        });
    }

    /* ---- problems (syntax) ----------------------------------------------------------------------------------- */

    function problemList(entries) {
        var ul = el('ul', 'explayouts-te-problem-list');
        entries.forEach(function (entry) {
            var li = el('li');
            if (entry.line) {
                var b = el('button', 'a4-link-button', fmt(T.line, { line: entry.line }));
                b.type = 'button';
                b.addEventListener('click', function () {
                    if (review && review.open) { review.close(); }
                    jumpToLine(entry.line);
                });
                li.appendChild(b);
                li.appendChild(document.createTextNode(' '));
            }
            li.appendChild(el('span', '', entry.text));
            ul.appendChild(li);
        });
        return ul;
    }

    function showProblems(validation) {
        problems.textContent = '';
        if (!validation || (!validation.errors.length && !validation.warnings.length)) {
            problems.hidden = true;
            return;
        }
        var isError = validation.errors.length > 0;
        problems.className = 'a4-notice explayouts-te-problems ' + (isError ? 'is-bad' : 'is-warn');
        problems.appendChild(el('p', 'a4-notice-title', isError ? T.syntax_errors : T.syntax_warnings));
        problems.appendChild(problemList(validation.errors.concat(validation.warnings)));
        problems.hidden = false;
    }

    function hideProblems() { problems.hidden = true; problems.textContent = ''; }

    /* ---- review and save ------------------------------------------------------------------------------------- */

    function renderDiff(diff) {
        reviewDiff.textContent = '';
        if (!diff.hunks.length) {
            reviewDiff.appendChild(el('p', 'a4-empty', T.identical));
            return;
        }
        var table = el('table', 'explayouts-te-difftable');
        var tbody = el('tbody');
        diff.hunks.forEach(function (hunk, index) {
            if (index > 0) {
                var gap = el('tr', 'is-gap');
                var td = el('td', '', '⋯');
                td.colSpan = 3;
                gap.appendChild(td);
                tbody.appendChild(gap);
            }
            hunk.lines.forEach(function (line) {
                var tr = el('tr', line.t === '+' ? 'is-add' : (line.t === '-' ? 'is-del' : ''));
                tr.appendChild(el('td', 'explayouts-te-diffno', line.o === null ? '' : String(line.o)));
                tr.appendChild(el('td', 'explayouts-te-diffno', line.n === null ? '' : String(line.n)));
                var cell = el('td', 'explayouts-te-diffline');
                cell.appendChild(el('span', 'explayouts-te-diffmark', line.t === ' ' ? ' ' : line.t));
                cell.appendChild(document.createTextNode(line.s));
                tr.appendChild(cell);
                tbody.appendChild(tr);
            });
        });
        table.appendChild(tbody);
        reviewDiff.appendChild(table);
    }

    function check() {
        reviewSum.textContent = T.checking;
        reviewChecks.textContent = '';
        reviewDiff.textContent = '';
        reviewSave.disabled = true;
        return request('POST', { Action: 'check', SelectedPath: current, TemplateContent: text.value, Compare: compare.value })
            .then(function (res) {
                if (!res.success) { throw new Error(res.error || ''); }
                var v = res.validation;
                reviewSum.textContent = fmt(T.summary, { added: res.diff.added, removed: res.diff.removed });
                var notice = el('div', 'a4-notice ' + (v.errors.length ? 'is-bad' : (v.warnings.length ? 'is-warn' : 'is-ok')));
                notice.setAttribute('role', v.errors.length ? 'alert' : 'status');
                notice.appendChild(el('p', 'a4-notice-title', v.errors.length ? T.syntax_errors : (v.warnings.length ? T.syntax_warnings : T.syntax_ok)));
                if (v.errors.length || v.warnings.length) { notice.appendChild(problemList(v.errors.concat(v.warnings))); }
                reviewChecks.appendChild(notice);
                renderDiff(res.diff);
                reviewSave.disabled = v.errors.length > 0 || !dirty();
                showProblems(v);
            })
            .catch(function (err) {
                reviewSum.textContent = '';
                var notice = el('div', 'a4-notice is-bad', fmt(T.save_error, { message: err.message }));
                notice.setAttribute('role', 'alert');
                reviewChecks.appendChild(notice);
            });
    }

    function openReview() {
        if (!current || !review) { return; }
        if (meta && meta.has_original) { compare.disabled = false; } else { compare.value = 'saved'; compare.disabled = true; }
        if (typeof review.showModal === 'function') { review.showModal(); } else { review.setAttribute('open', 'open'); }
        check().then(function () {
            if (!reviewSave.disabled) { reviewSave.focus(); }
        });
    }

    function save() {
        if (busy || !dirty()) { return; }
        busy = true;
        reviewSave.disabled = true;
        setStatus(T.checking, '');
        var sent = text.value;
        request('POST', { Action: 'save', SelectedPath: current, TemplateContent: sent }).then(function (res) {
            busy = false;
            if (!res.success) {
                if (res.validation) { showProblems(res.validation); }
                throw new Error(res.error || '');
            }
            saved = sent;
            isNew = false;
            meta = res.meta || meta;
            rows.forEach(function (row) { if (row.path === current) { row.changed = !!(meta && meta.has_original); } });
            showMeta();
            renderList();
            if (review && review.open) { review.close(); }
            if (res.validation && res.validation.warnings.length) { showProblems(res.validation); } else { hideProblems(); }
            updateButtons();
            setStatus(T.saved, 'ok');
            text.focus();
        }).catch(function (err) {
            busy = false;
            updateButtons();
            setStatus(fmt(T.save_error, { message: err.message }), 'bad');
            if (review && review.open) { reviewSave.disabled = false; }
        });
    }

    if (saveBtn) { saveBtn.addEventListener('click', openReview); }
    if (reviewBtn) { reviewBtn.addEventListener('click', openReview); }
    if (reviewSave) { reviewSave.addEventListener('click', save); }
    if (reviewClose) { reviewClose.addEventListener('click', function () { review.close(); text.focus(); }); }
    if (compare) { compare.addEventListener('change', check); }
    if (review) {
        review.addEventListener('keydown', function (e) {
            if ((e.ctrlKey || e.metaKey) && (e.key === 's' || e.key === 'S')) {
                e.preventDefault();
                if (!reviewSave.disabled) { save(); }
            }
        });
    }

    if (revertBtn) {
        revertBtn.addEventListener('click', function () {
            if (busy) { return; }
            busy = true;
            request('POST', { Action: 'revert', SelectedPath: current }).then(function (res) {
                busy = false;
                if (!res.success) { throw new Error(res.error || ''); }
                saved = typeof res.content === 'string' ? res.content : '';
                text.value = saved;
                meta = res.meta || null;
                rows.forEach(function (row) { if (row.path === current) { row.changed = false; } });
                showMeta();
                renderList();
                paint();
                hideProblems();
                updateButtons();
                setStatus(res.message || T.reverted, 'ok');
            }).catch(function (err) {
                busy = false;
                updateButtons();
                setStatus(fmt(T.save_error, { message: err.message }), 'bad');
            });
        });
    }

    /* ---- override ------------------------------------------------------------------------------------------- */

    if (overrideBtn) {
        overrideBtn.addEventListener('click', function () {
            if (busy || !current || !overrideTarget.value) { return; }
            busy = true;
            overrideBtn.disabled = true;
            request('POST', { Action: 'override', SelectedPath: current, Target: overrideTarget.value }).then(function (res) {
                if (!res.success) { throw new Error(res.error || ''); }
                window.location.assign(res.url);
            }).catch(function (err) {
                busy = false;
                overrideBtn.disabled = false;
                updateButtons();
                setStatus(fmt(T.save_error, { message: err.message }), 'bad');
            });
        });
    }

    /* ---- new template ---------------------------------------------------------------------------------------- */

    if (newBtn && newDialog) {
        newBtn.addEventListener('click', function () {
            newPath.value = current ? current.slice(0, current.lastIndexOf('/') + 1) : '';
            newPath.removeAttribute('aria-invalid');
            newDialog.showModal();
            newPath.focus();
        });
        $('te-new-cancel').addEventListener('click', function () { newDialog.close(); });
        $('te-new-create').addEventListener('click', function () {
            var p = newPath.value.trim().replace(/^\/+/, '');
            if (p.length < 5 || p.slice(-4) !== '.tpl') {
                newPath.setAttribute('aria-invalid', 'true');
                $('te-new-help').textContent = T.new_tpl;
                return;
            }
            if (dirty() && !window.confirm(T.discard)) { return; }
            newDialog.close();
            if (!rows.some(function (row) { return row.path === p; })) {
                rows.push({ path: p, name: p.slice(p.lastIndexOf('/') + 1), folder: p.slice(0, p.lastIndexOf('/')),
                            base: '', design: '', group: '', extension: '', changed: false, winner: null,
                            overridden_by: [], overrides: [], writable: true });
                rows.sort(function (a, b) { return a.path < b.path ? -1 : 1; });
            }
            isNew = true;
            meta = null;
            saved = '';
            text.readOnly = !canEdit;
            if (readonlyBox) { readonlyBox.hidden = true; }
            showEditor(p);
            text.value = '';
            showMeta();
            paint();
            updateButtons();
            text.focus();
        });
    }

    /* ---- leaving --------------------------------------------------------------------------------------------- */

    window.addEventListener('beforeunload', function (e) {
        if (dirty()) {
            e.preventDefault();
            e.returnValue = '';
        }
    });

    renderList();
    if (E.selected) {
        open(E.selected);
    }
}
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', explayoutsUiTemplateEditor);
} else {
    explayoutsUiTemplateEditor();
}
