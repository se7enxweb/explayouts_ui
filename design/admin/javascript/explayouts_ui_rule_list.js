/* The mappings page (explayouts_ui/rule_list) and its rule panels (rule_detail.tpl): one file for every admin design,
   printed by parts/rule_list_script.tpl, where the inline script stood until 1.3.19. Its settings and texts are the
   JSON data block #explayouts-ui-rule-list-data of that template; they are kept as the globals the inline script set
   (nglTargetTypes, nglConditionTypes, nglContentClasses, nglSiteAccessList, nglContentBrowserUrl, nglCmsViewBase,
   nglAutoOpenNewRule, nglAutoOpenRuleId, nglI18n). Markup it writes carries no inline style, and it is built with DOM
   methods (textContent, setAttribute), never from strings. */
(function () {
    var data = {};
    var block = document.getElementById('explayouts-ui-rule-list-data');
    try { data = block ? JSON.parse(block.textContent) : {}; } catch (e) { data = {}; }
    window.nglTargetTypes = data.target_types || [];
    window.nglConditionTypes = data.condition_types || [];
    window.nglContentClasses = data.content_classes || {};
    window.nglSiteAccessList = data.siteaccess_list || [];
    window.nglContentBrowserUrl = data.content_browser_url || '/explayouts_content_browser_ui/browser/';
    window.nglCmsViewBase = data.cms_view_base || '/content/view/full/';
    window.nglAutoOpenNewRule = !!data.auto_open_new_rule;
    window.nglAutoOpenRuleId = data.auto_open_rule_id ? String(data.auto_open_rule_id) : '';
    window.nglI18n = data.i18n || {};
})();
if (!window.explayoutsUiRuleListReady) {
window.explayoutsUiRuleListReady = true;
document.addEventListener('DOMContentLoaded', function() {
    // el('input', { type: 'hidden', name: 'x' }, [ 'text', node ]): attributes through setAttribute, text as text nodes
    function el(tag, attrs, children) {
        var node = document.createElement(tag);
        for (var key in (attrs || {})) {
            if (!attrs.hasOwnProperty(key) || attrs[key] === null || attrs[key] === undefined || attrs[key] === false) continue;
            node.setAttribute(key, attrs[key] === true ? '' : String(attrs[key]));
        }
        (children || []).forEach(function(child) {
            if (child === null || child === undefined) return;
            node.appendChild(typeof child === 'string' ? document.createTextNode(child) : child);
        });
        return node;
    }

    function removeButton() {
        return el('button', { type: 'button', 'class': 'remove-setting js-remove-row a4-btn a4-btn-small a4-btn-outline-danger' }, [nglI18n.remove]);
    }

    function toggleRule(id) {
        var rule = document.getElementById('rule-' + id);
        if (!rule) return;
        rule.classList.toggle('show-body');
        if (rule.classList.contains('show-body')) {
            var body = rule.querySelector('.nl-rule-body');
            if (body) body.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
    }

    document.querySelectorAll('.js-toggle-body, .js-link-layout').forEach(function(el) {
        el.addEventListener('click', function(e) {
            e.preventDefault();
            var rule = this.closest('.nl-rule');
            if (rule) toggleRule(rule.getAttribute('data-rule-id'));
        });
    });

    document.querySelectorAll('.js-add-rule').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            // close any open rule detail first
            document.querySelectorAll('.nl-rule.show-body').forEach(function(rule) {
                rule.classList.remove('show-body');
            });
            toggleRule('new');
        });
    });

    document.querySelectorAll('.nl-rule-body-overlay').forEach(function(overlay) {
        overlay.addEventListener('click', function(e) {
            if (e.target === this) {
                var rule = this.closest('.nl-rule');
                if (rule) rule.classList.remove('show-body');
            }
        });
    });

    document.querySelectorAll('.nl-dropdown-toggle').forEach(function(toggle) {
        toggle.addEventListener('click', function(e) {
            e.stopPropagation();
            var dropdown = this.closest('.nl-dropdown');
            if (!dropdown) return;
            var wasActive = dropdown.classList.contains('nl-dropdown-active');
            document.querySelectorAll('.nl-dropdown.nl-dropdown-active').forEach(function(d) { d.classList.remove('nl-dropdown-active'); });
            if (!wasActive) dropdown.classList.add('nl-dropdown-active');
        });
    });

    document.addEventListener('click', function() {
        document.querySelectorAll('.nl-dropdown.nl-dropdown-active').forEach(function(d) { d.classList.remove('nl-dropdown-active'); });
    });

    var targetTypeLabels = {
        'node': nglI18n.location,
        'subtree': nglI18n.subtree,
        'path': nglI18n.path,
        'path_prefix': nglI18n.path_prefix,
        'path_regex': nglI18n.path_regex,
        'route': nglI18n.route
    };
    var conditionTypeLabels = {
        'class': nglI18n.klass,
        'content_type': nglI18n.klass,
        'siteaccess': nglI18n.siteaccess,
        'query_parameter': nglI18n.query_parameter,
        'route_parameter': nglI18n.route_parameter,
        'time': nglI18n.time
    };

    function isTargetLocation(type) {
        return ['node', 'subtree'].indexOf(type) !== -1;
    }

    /** The value field of a target: a location (hidden, chosen in the content browser) or a text field */
    function buildTargetValueControl(type, value, display) {
        if (isTargetLocation(type)) {
            return [
                el('input', { type: 'hidden', name: 'TargetValue[]', value: value || '' }),
                el('span', { 'class': 'target-value-display' }, [display || nglI18n.content_browser])
            ];
        }
        return [el('input', { type: 'text', name: 'TargetValue[]', value: value || '', size: 40, 'class': 'a4-input',
                              'aria-label': targetTypeLabels[type] || type })];
    }

    function getTargetViewLink(nodeId) {
        var base = window.nglCmsViewBase || '/content/view/full';
        return base + '/' + (nodeId || '');
    }

    function updateTargetValueControl(li, type, value, display) {
        var holder = li.querySelector('.target-value-holder');
        if (!holder) {
            holder = document.createElement('span');
            holder.className = 'target-value-holder settings-value editable-value js-setting-edit';
            holder.setAttribute('data-setting-type', 'target');
            var typeControl = li.querySelector('input[name="TargetType[]"], select[name="TargetType[]"]');
            if (typeControl && typeControl.nextSibling) li.insertBefore(holder, typeControl.nextSibling);
            else li.appendChild(holder);
        }
        holder.replaceChildren.apply(holder, buildTargetValueControl(type, value, display));

        var viewLink = li.querySelector('.js-view-target');
        if (!viewLink) {
            viewLink = document.createElement('a');
            viewLink.href = '#';
            viewLink.target = '_blank';
            viewLink.className = 'nl-btn js-view-target';
            viewLink.textContent = nglI18n.view_in_cms;
            viewLink.hidden = true;
            li.insertBefore(viewLink, holder.nextSibling);
        }

        if (isTargetLocation(type) && value && !isNaN(parseInt(value, 10))) {
            viewLink.href = getTargetViewLink(value);
            viewLink.hidden = false;
        } else {
            viewLink.href = '#';
            viewLink.hidden = true;
        }
    }

    /** The value field of a condition: a list (classes, siteaccesses, edited as a multiple select) or a text field */
    function buildConditionValueControl(type, value) {
        var isClass = (type === 'class' || type === 'content_type');
        var isSiteaccess = (type === 'siteaccess');
        if (isClass || isSiteaccess) {
            var items = [];
            try {
                var parsed = JSON.parse(value || '');
                if (Array.isArray(parsed)) items = parsed;
            } catch (err) {}
            return [
                el('input', { type: 'hidden', name: 'ConditionValue[]', value: value || '' }),
                el('ul', { 'class': 'condition-items' }, items.map(function(it) { return el('li', {}, [String(it)]); }))
            ];
        }
        return [el('input', { type: 'text', name: 'ConditionValue[]', value: value || '', size: 50, 'class': 'a4-input',
                              'aria-label': buildConditionLabel(type) })];
    }

    /** A type select of a new row: the known types, the given one selected */
    function buildTypeSelect(name, className, types, labels, selectedType, ariaLabel) {
        return el('select', { name: name, 'class': 'nl-select a4-input is-auto ' + className, 'aria-label': ariaLabel },
                  types.map(function(t) {
                      return el('option', { value: t, selected: t === selectedType }, [labels[t] || t]);
                  }));
    }

    function buildConditionLabel(type) {
        return conditionTypeLabels[type] || type;
    }

    document.querySelectorAll('.js-add-target').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            var id = this.getAttribute('data-rule-id');
            var list = document.getElementById('targets-table-' + id);
            var select = document.getElementById('target-type-' + id);
            var fixedType = this.getAttribute('data-target-type');
            var type = fixedType || (select ? select.value : '');
            if (!list || !type) return;
            var typeControl;
            if (fixedType) {
                typeControl = [
                    el('input', { type: 'hidden', name: 'TargetType[]', value: fixedType }),
                    el('span', { 'class': 'target-type-label' }, [el('strong', {}, [(targetTypeLabels[fixedType] || fixedType) + ':'])])
                ];
            } else {
                typeControl = [buildTypeSelect('TargetType[]', 'js-target-type-select', window.nglTargetTypes || [], targetTypeLabels, type, nglI18n.target_type)];
            }
            var li = el('li', { 'class': 'nl-rule-setting-item' }, typeControl.concat([
                ' ',
                el('span', { 'class': 'target-value-holder settings-value editable-value js-setting-edit', 'data-setting-type': 'target' },
                   buildTargetValueControl(type, '', '')),
                ' ',
                el('a', { href: '#', target: '_blank', 'class': 'nl-btn js-view-target', hidden: true }, [nglI18n.view_in_cms]),
                ' ',
                removeButton()
            ]));
            list.appendChild(li);

            if (!fixedType) {
                var typeSelect = li.querySelector('.js-target-type-select');
                if (typeSelect) {
                    typeSelect.addEventListener('change', function() {
                        updateTargetValueControl(li, this.value, '', '');
                    });
                }
            }
        });
    });

    /** A new class or siteaccess condition has no value yet, so its value is an empty list with nothing to click on:
        its multiple select is opened right away (the same as clicking the value of an existing condition). */
    function openConditionList(li) {
        var span = li.querySelector('.js-setting-edit');
        if (span && !li.classList.contains('editing')) span.click();
    }

    document.querySelectorAll('.js-add-condition').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            var id = this.getAttribute('data-rule-id');
            var list = document.getElementById('conditions-table-' + id);
            var select = document.getElementById('condition-type-' + id);
            var type = select ? select.value : '';
            if (!list || !type) return;
            var isMulti = (type === 'class' || type === 'content_type' || type === 'siteaccess');
            var li = el('li', { 'class': 'nl-rule-setting-item' }, [
                buildTypeSelect('ConditionType[]', 'js-condition-type-select', window.nglConditionTypes || [], conditionTypeLabels, type, nglI18n.condition_type),
                ' ',
                el('span', { 'class': 'settings-value editable-value js-setting-edit', 'data-setting-type': 'condition', 'data-setting-id': '' },
                   [el('strong', {}, [buildConditionLabel(type) + ':'])].concat(buildConditionValueControl(type, isMulti ? '[]' : ''))),
                ' ',
                removeButton()
            ]);
            list.appendChild(li);
            if (isMulti) openConditionList(li);

            var typeSelect = li.querySelector('.js-condition-type-select');
            if (typeSelect) {
                typeSelect.addEventListener('change', function() {
                    var valueSpan = li.querySelector('.settings-value');
                    if (valueSpan) {
                        var multi = (this.value === 'class' || this.value === 'content_type' || this.value === 'siteaccess');
                        valueSpan.replaceChildren.apply(valueSpan, [el('strong', {}, [buildConditionLabel(this.value) + ':'])].concat(buildConditionValueControl(this.value, multi ? '[]' : '')));
                        li.classList.remove('editing');
                        if (multi) openConditionList(li);
                    }
                });
            }
        });
    });

    document.addEventListener('click', function(e) {
        var remove = e.target && e.target.closest ? e.target.closest('.js-remove-row') : null;
        if (remove) {
            e.preventDefault();
            var item = remove.closest('li');
            if (item && item.parentNode) item.parentNode.removeChild(item);
        }
    });

    document.querySelectorAll('.js-rule-edit[data-action="discard"]').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            var rule = this.closest('.nl-rule');
            if (rule) rule.classList.remove('show-body');
        });
    });

    window.addEventListener('keyup', function(e) {
        if (e.key === 'Escape') {
            document.querySelectorAll('.nl-rule.show-body').forEach(function(rule) {
                rule.classList.remove('show-body');
            });
        }
    });

    document.querySelectorAll('.nl-toggle-input').forEach(function(input) {
        var label = input.parentNode ? input.parentNode.querySelector('.nl-toggle-label') : null;
        if (label) {
            input.addEventListener('change', function() {
                label.textContent = input.checked ? label.getAttribute('data-on') : label.getAttribute('data-off');
                var ruleId = input.getAttribute('data-rule-id');
                if (ruleId) {
                    var rule = document.getElementById('rule-' + ruleId);
                    if (rule) {
                        var content = rule.querySelector('.nl-rule-content');
                        if (content) {
                            if (input.checked) content.classList.remove('disabled');
                            else content.classList.add('disabled');
                            content.setAttribute('data-enabled', input.checked ? '1' : '0');
                        }
                    }
                }
            });
        }
    });

    // The content browser opens in a dialog on the page, not in a popup window: a popup is easily blocked or
    // opens behind the browser window, and then choosing a location looks like nothing happened.
    function contentBrowserDialog() {
        var dialog = document.getElementById('ngl-content-browser-dialog');
        if (dialog) return dialog;
        dialog = document.createElement('dialog');
        dialog.id = 'ngl-content-browser-dialog';
        dialog.className = 'ngl-content-browser-dialog';
        dialog.setAttribute('aria-label', nglI18n.content_browser || 'Content browser');
        var close = document.createElement('button');
        close.type = 'button';
        close.className = 'ngl-content-browser-dialog-close';
        close.setAttribute('aria-label', nglI18n.close || 'Close');
        close.textContent = '\u00d7';
        close.addEventListener('click', function() { dialog.close(); });
        var frame = document.createElement('iframe');
        frame.className = 'ngl-content-browser-dialog-frame';
        frame.title = nglI18n.content_browser || 'Content browser';
        dialog.appendChild(close);
        dialog.appendChild(frame);
        dialog.addEventListener('close', function() { frame.src = 'about:blank'; });
        document.body.appendChild(dialog);
        return dialog;
    }

    function openContentBrowser(url) {
        var dialog = contentBrowserDialog();
        dialog.querySelector('iframe').src = url;
        if (typeof dialog.showModal === 'function') dialog.showModal();
        else window.open(url, 'contentbrowser', 'width=900,height=700,scrollbars=yes,resizable=yes');
    }

    window.setRuleTargetValue = function(nodeId, name, pathWithNames, field) {
        var openDialog = document.getElementById('ngl-content-browser-dialog');
        if (openDialog && openDialog.open) openDialog.close();
        var input = window.nglActiveTargetInput;
        if (!input) return;
        input.value = nodeId;
        var item = input.closest ? input.closest('li') : null;
        if (item) {
            var viewLink = item.querySelector('.js-view-target');
            if (viewLink) {
                viewLink.href = (window.nglCmsViewBase || '/content/view/full') + '/' + nodeId;
                viewLink.hidden = false;
            }
            var display = item.querySelector('.target-value-display');
            if (display) display.textContent = pathWithNames || name || nodeId;
        }
        window.nglActiveTargetInput = null;
    };

    window.nglActiveTargetInput = null;

    function getConditionValueArray(raw) {
        try {
            var parsed = JSON.parse(raw);
            return Array.isArray(parsed) ? parsed : [parsed];
        } catch (err) {
            return raw ? [raw] : [];
        }
    }

    function buildMultiSelect(name, options, selected, placeholder) {
        var opts = [];
        for (var key in options) {
            if (!options.hasOwnProperty(key)) continue;
            opts.push(el('option', { value: key, selected: selected.indexOf(key) !== -1 }, [String(options[key])]));
        }
        return el('select', { multiple: true, 'class': 'nl-select condition-edit-select', 'data-hidden-name': name,
                              title: placeholder || null, 'aria-label': placeholder || null }, opts);
    }

    function updateConditionHiddenFromSelect(select) {
        var selected = [];
        for (var i = 0; i < select.options.length; i++) {
            if (select.options[i].selected) selected.push(select.options[i].value);
        }
        var hiddenName = select.getAttribute('data-hidden-name');
        var li = select.closest ? select.closest('li') : null;
        var hidden = li ? li.querySelector('input[type="hidden"][name="' + hiddenName + '"], input[type="hidden"][name="' + (hiddenName || 'ConditionValue[]') + '"]') : null;
        if (!hidden) hidden = select.parentNode.querySelector('input[type="hidden"]');
        if (hidden) hidden.value = JSON.stringify(selected);
    }

    document.addEventListener('click', function(e) {
        var edit = e.target && (e.target.classList.contains('js-setting-edit') || e.target.closest('.js-setting-edit'));
        if (!edit) return;
        var span = e.target.classList.contains('js-setting-edit') ? e.target : e.target.closest('.js-setting-edit');
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'SELECT' || e.target.tagName === 'TEXTAREA') return;
        var li = span.closest('li');
        if (!li) return;
        var isTarget = span.getAttribute('data-setting-type') === 'target';

        if (isTarget) {
            var targetTypeInput = li.querySelector('input[name="TargetType[]"]') || li.querySelector('select[name="TargetType[]"]');
            var targetType = targetTypeInput ? targetTypeInput.value : '';
            var targetValueInput = li.querySelector('input[name="TargetValue[]"]');
            if (!targetValueInput) return;
            var locationTypes = ['node', 'subtree'];
            if (locationTypes.indexOf(targetType) !== -1) {
                window.nglActiveTargetInput = targetValueInput;
                var url = (window.nglContentBrowserUrl || '/explayouts_content_browser_ui/browser/') + '?return_uri=js&field=active';
                openContentBrowser(url);
            } else if (targetValueInput.type !== 'hidden') {
                targetValueInput.focus();
                targetValueInput.select();
            }
            return;
        }

        // condition edit
        var conditionTypeInput = li.querySelector('input[name="ConditionType[]"]') || li.querySelector('select[name="ConditionType[]"]');
        var conditionType = conditionTypeInput ? conditionTypeInput.value : '';
        var hidden = li.querySelector('input[type="hidden"][name="ConditionValue[]"]');
        var raw = hidden ? hidden.value : '';
        var current = getConditionValueArray(raw);

        var classConditionTypes = ['class', 'content_type'];
        var siteaccessConditionTypes = ['siteaccess'];
        var isClass = classConditionTypes.indexOf(conditionType) !== -1;
        var isSiteaccess = siteaccessConditionTypes.indexOf(conditionType) !== -1;

        if (!isClass && !isSiteaccess) {
            var textInput = li.querySelector('input[type="text"][name="ConditionValue[]"]');
            if (textInput) { textInput.focus(); textInput.select(); }
            return;
        }

        // For class/siteaccess, toggle a multi-select
        var wasEditing = li.classList.contains('editing');
        li.classList.toggle('editing');

        function renderConditionChips(items) {
            var list = li.querySelector('.condition-items');
            if (!list) return;
            list.replaceChildren();
            for (var i = 0; i < items.length; i++) {
                var name = items[i];
                if (isClass && window.nglContentClasses && window.nglContentClasses[items[i]]) {
                    name = window.nglContentClasses[items[i]];
                }
                var chip = document.createElement('li');
                chip.textContent = name;
                list.appendChild(chip);
            }
        }

        if (wasEditing) {
            var hidden2 = li.querySelector('input[type="hidden"][name="ConditionValue[]"]');
            if (hidden2) renderConditionChips(getConditionValueArray(hidden2.value));
            return;
        }

        var editSelect = li.querySelector('.condition-edit-select');
        if (!editSelect) {
            var wrapper = document.createElement('span');
            wrapper.className = 'condition-edit-controls';
            if (isClass) {
                wrapper.appendChild(buildMultiSelect('ConditionValue[]', window.nglContentClasses || {}, current, nglI18n.select_classes));
            } else if (isSiteaccess) {
                var options = {};
                var saList = window.nglSiteAccessList || [];
                for (var k = 0; k < saList.length; k++) options[saList[k]] = saList[k];
                wrapper.appendChild(buildMultiSelect('ConditionValue[]', options, current, nglI18n.select_siteaccesses));
            }
            if (hidden) hidden.parentNode.insertBefore(wrapper, hidden.nextSibling);
            else span.appendChild(wrapper);
            editSelect = wrapper.querySelector('.condition-edit-select');
            editSelect.addEventListener('change', function() {
                updateConditionHiddenFromSelect(this);
            });
        }
    });

    document.addEventListener('input', function(e) {
        if (e.target && e.target.name === 'TargetValue[]') {
            var item = e.target.closest ? e.target.closest('li') : null;
            var viewLink = item ? item.querySelector('.js-view-target') : null;
            if (viewLink) {
                if (/^\d+$/.test(e.target.value)) {
                    viewLink.href = (window.nglCmsViewBase || '/content/view/full') + '/' + e.target.value;
                    viewLink.hidden = false;
                } else {
                    viewLink.hidden = true;
                }
            }
        }
    });

    if ( window.nglAutoOpenNewRule )
        toggleRule('new');
    else if ( window.nglAutoOpenRuleId )
        toggleRule(window.nglAutoOpenRuleId);
});
}
