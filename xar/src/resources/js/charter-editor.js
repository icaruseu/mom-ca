/**
 * MOM-CA Charter Editor
 * Dual-mode editor: Visual (contenteditable) + XML (CodeMirror)
 */

(function() {
'use strict';

// ─── CEI Schema: allowed inline elements per context ───────────────────

const CEI_NS = 'http://www.monasterium.net/NS/cei';

const INLINE_ELEMENTS = {
  common: ['persName','placeName','orgName','geogName','foreign','date','dateRange','num','measure','hi','sup','lb','index'],
  abstract: ['persName','placeName','orgName','geogName','foreign','date','dateRange','num','measure','hi','sup','lb','issuer','recipient','index'],
  tenor: ['persName','placeName','orgName','geogName','foreign','date','dateRange','num','measure','hi','sup','lb','index',
           'invocatio','intitulatio','inscriptio','arenga','publicatio','narratio','rogatio','intercessio',
           'dispositio','sanctio','corroboratio','datatio','subscriptio','notariusSub','setPhrase',
           'expan','sic','corr','del','add','supplied','unclear','app','pTenor'],
  nota: ['persName','placeName','orgName','foreign','hi','sup','lb','note','bibl'],
  sealDesc: ['seal','legend','sigillant','hi','sup']
};

const TOOLBAR_GROUPS = {
  abstract: [
    { label: 'Indexing', items: ['persName','placeName','orgName','geogName','foreign','index','date','dateRange','num'] },
    { label: 'Layout', items: ['hi','sup','lb'] },
    { label: 'Roles', items: ['issuer','recipient'] }
  ],
  tenor: [
    { label: 'Indexing', items: ['persName','placeName','orgName','geogName','foreign','index','date','dateRange','num'] },
    { label: 'Layout', items: ['hi','sup','lb'] },
    { label: 'Diplomatics', items: ['invocatio','intitulatio','inscriptio','arenga','publicatio','narratio',
                                     'dispositio','sanctio','corroboratio','datatio','subscriptio'] },
    { label: 'Transcription', items: ['expan','sic','corr','del','add','supplied','unclear'] }
  ],
  nota: [
    { label: 'Indexing', items: ['persName','placeName','orgName','foreign'] },
    { label: 'Layout', items: ['hi','sup','lb'] }
  ]
};

// ─── CEI Schema data (loaded from server) ──────────────────────────────

var CEI_ATTRIBUTES = {};  // populated by loadSchema()

// Empty (self-closing) elements
const EMPTY_ELEMENTS = ['lb'];

var ALLOWED_CHILDREN = {};  // populated by loadSchema()

// ─── HTML ↔ CEI-XML Conversion ─────────────────────────────────────────

function escapeXml(s) {
  return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

/** Serialize a contenteditable div's DOM to CEI XML string */
function serializeToCEI(node) {
  var xml = '';
  for (var i = 0; i < node.childNodes.length; i++) {
    var child = node.childNodes[i];
    if (child.nodeType === Node.TEXT_NODE) {
      xml += escapeXml(child.textContent);
    } else if (child.nodeType === Node.ELEMENT_NODE) {
      if (child.classList && child.classList.contains('cei-anno')) {
        var elem = child.dataset.cei;
        var attrs = '';
        var keys = Object.keys(child.dataset);
        for (var j = 0; j < keys.length; j++) {
          if (keys[j] !== 'cei' && child.dataset[keys[j]] !== '') {
            attrs += ' ' + keys[j] + '="' + escapeXml(child.dataset[keys[j]]) + '"';
          }
        }
        if (EMPTY_ELEMENTS.indexOf(elem) !== -1) {
          xml += '<cei:' + elem + attrs + '/>';
        } else {
          xml += '<cei:' + elem + attrs + '>' + serializeToCEI(child) + '</cei:' + elem + '>';
        }
      } else if (child.tagName === 'BR') {
        // Skip browser-inserted BRs
      } else if (child.tagName === 'DIV' || child.tagName === 'P') {
        // Browser may wrap lines in divs/p — flatten
        xml += serializeToCEI(child);
      }
    }
  }
  return xml;
}

/** Parse a CEI XML string into HTML for contenteditable */
function ceiToHtml(xmlStr) {
  // Wrap in root with namespace for parsing
  var wrapped = '<root xmlns:cei="' + CEI_NS + '">' + xmlStr + '</root>';
  try {
    var parser = new DOMParser();
    var doc = parser.parseFromString(wrapped, 'text/xml');
    if (doc.querySelector('parsererror')) {
      return escapeForHtml(xmlStr); // Fallback: show as text
    }
    return convertNodeToHtml(doc.documentElement);
  } catch(e) {
    return escapeForHtml(xmlStr);
  }
}

function escapeForHtml(s) {
  var div = document.createElement('div');
  div.textContent = s;
  return div.innerHTML;
}

function convertNodeToHtml(node) {
  var html = '';
  for (var i = 0; i < node.childNodes.length; i++) {
    var child = node.childNodes[i];
    if (child.nodeType === Node.TEXT_NODE) {
      html += escapeForHtml(child.textContent);
    } else if (child.nodeType === Node.ELEMENT_NODE) {
      var localName = child.localName;
      // Build data attributes from XML attributes
      var dataAttrs = ' data-cei="' + localName + '"';
      for (var a = 0; a < child.attributes.length; a++) {
        var attr = child.attributes[a];
        if (attr.name !== 'xmlns' && !attr.name.startsWith('xmlns:')) {
          dataAttrs += ' data-' + attr.localName + '="' + escapeForHtml(attr.value) + '"';
        }
      }
      if (EMPTY_ELEMENTS.indexOf(localName) !== -1) {
        html += '<span class="cei-anno cei-empty"' + dataAttrs + '>&#x23CE;</span>';
      } else {
        html += '<span class="cei-anno"' + dataAttrs + '>' + convertNodeToHtml(child) + '</span>';
      }
    }
  }
  return html;
}

// ─── Toolbar (mode toggle only) + Context Menu ─────────────────────────

function buildToolbar(container, context) {
  // Mode toggle only in toolbar
  var modeDiv = document.createElement('div');
  modeDiv.className = 'mode-toggle';
  var btnVisual = document.createElement('button');
  btnVisual.type = 'button';
  btnVisual.textContent = 'Standard';
  btnVisual.className = 'active';
  btnVisual.dataset.mode = 'visual';
  var btnXml = document.createElement('button');
  btnXml.type = 'button';
  btnXml.textContent = 'XML';
  btnXml.dataset.mode = 'xml';
  modeDiv.appendChild(btnVisual);
  modeDiv.appendChild(btnXml);
  container.appendChild(modeDiv);

  var hint = document.createElement('span');
  hint.className = 'text-small text-muted';
  hint.style.marginLeft = '12px';
  hint.textContent = 'Select text \u2192 right-click to annotate';
  container.appendChild(hint);

  return { btnVisual: btnVisual, btnXml: btnXml };
}

// ─── Context Menu ───────────────────────────────────────────────────────

var activeContextMenu = null;

function hideContextMenu() {
  if (activeContextMenu) {
    activeContextMenu.remove();
    activeContextMenu = null;
  }
}

function showContextMenu(x, y, groups, editorDiv) {
  hideContextMenu();

  var menu = document.createElement('div');
  menu.className = 'cei-context-menu';
  menu.style.left = x + 'px';
  menu.style.top = y + 'px';

  groups.forEach(function(group, gi) {
    if (gi > 0) {
      var sep = document.createElement('div');
      sep.className = 'cei-ctx-sep';
      menu.appendChild(sep);
    }
    var header = document.createElement('div');
    header.className = 'cei-ctx-header';
    header.textContent = group.label;
    menu.appendChild(header);

    group.items.forEach(function(elem) {
      var item = document.createElement('button');
      item.className = 'cei-ctx-item';
      item.textContent = elem;
      item.type = 'button';
      item.addEventListener('click', function(e) {
        e.preventDefault();
        insertAnnotation(elem, editorDiv);
        hideContextMenu();
      });
      menu.appendChild(item);
    });
  });

  document.body.appendChild(menu);
  activeContextMenu = menu;

  // Adjust position if off-screen
  var rect = menu.getBoundingClientRect();
  if (rect.right > window.innerWidth) menu.style.left = (x - rect.width) + 'px';
  if (rect.bottom > window.innerHeight) menu.style.top = (y - rect.height) + 'px';

  // Close on outside click
  setTimeout(function() {
    document.addEventListener('click', hideContextMenu, { once: true });
  }, 10);
}

function insertAnnotation(elemName, editorDiv) {
  var sel = window.getSelection();
  if (!sel.rangeCount) return;
  var range = sel.getRangeAt(0);
  if (!editorDiv.contains(range.commonAncestorContainer)) return;

  if (EMPTY_ELEMENTS.indexOf(elemName) !== -1) {
    var emptySpan = document.createElement('span');
    emptySpan.className = 'cei-anno cei-empty';
    emptySpan.dataset.cei = elemName;
    emptySpan.innerHTML = '\u23CE';
    range.insertNode(emptySpan);
    return;
  }

  var selectedText = range.toString();
  if (!selectedText) selectedText = elemName;

  // Use surroundContents if selection is within a single node (supports nesting)
  // Falls back to extract+insert for cross-node selections
  var span = document.createElement('span');
  span.className = 'cei-anno';
  span.dataset.cei = elemName;

  try {
    // surroundContents works perfectly for nesting within a parent element
    range.surroundContents(span);
  } catch(e) {
    // Cross-element selection: extract, wrap, insert
    var fragment = range.extractContents();
    span.appendChild(fragment);
    range.insertNode(span);
  }

  // Collapse selection after the new element
  sel.removeAllRanges();
  var newRange = document.createRange();
  newRange.setStartAfter(span);
  newRange.collapse(true);
  sel.addRange(newRange);

  // Auto-open attr dialog if element has attributes
  if (CEI_ATTRIBUTES[elemName] && CEI_ATTRIBUTES[elemName].length > 0) {
    setTimeout(function() { showAttrDialog(span); }, 50);
  }
}

// ─── Attribute Dialog ───────────────────────────────────────────────────

function showAttrDialog(annoSpan) {
  var elem = annoSpan.dataset.cei;
  var attrs = CEI_ATTRIBUTES[elem] || [];
  if (attrs.length === 0 && !confirm('Remove <cei:' + elem + '> element?\n(This element has no editable attributes)')) {
    return;
  }
  if (attrs.length === 0) {
    unwrapAnnotation(annoSpan);
    return;
  }

  var overlay = document.createElement('div');
  overlay.className = 'attr-dialog-overlay';

  var dialog = document.createElement('div');
  dialog.className = 'attr-dialog';

  // Header
  var header = document.createElement('div');
  header.className = 'attr-dialog-header';
  header.innerHTML = '<span>cei:' + elem + '</span><button class="close-btn" type="button">&times;</button>';
  dialog.appendChild(header);

  // Body
  var body = document.createElement('div');
  body.className = 'attr-dialog-body';
  var inputs = {};
  attrs.forEach(function(a) {
    var field = document.createElement('div');
    field.className = 'editor-field';
    var label = document.createElement('label');
    label.textContent = a.label;
    field.appendChild(label);
    var input = document.createElement('input');
    input.type = 'text';
    if (a.pattern) input.pattern = a.pattern;
    input.value = annoSpan.dataset[a.name] || '';
    input.placeholder = a.name;
    field.appendChild(input);
    body.appendChild(field);
    inputs[a.name] = input;
  });
  dialog.appendChild(body);

  // Footer
  var footer = document.createElement('div');
  footer.className = 'attr-dialog-footer';
  var removeBtn = document.createElement('button');
  removeBtn.className = 'btn';
  removeBtn.textContent = 'Remove Element';
  removeBtn.type = 'button';
  removeBtn.style.color = 'var(--color-accent)';
  var okBtn = document.createElement('button');
  okBtn.className = 'btn btn--primary';
  okBtn.textContent = 'OK';
  okBtn.type = 'button';
  footer.appendChild(removeBtn);
  footer.appendChild(okBtn);
  dialog.appendChild(footer);

  overlay.appendChild(dialog);
  document.body.appendChild(overlay);

  // Focus first input
  var firstInput = body.querySelector('input');
  if (firstInput) firstInput.focus();

  function close() { document.body.removeChild(overlay); }

  header.querySelector('.close-btn').onclick = close;
  overlay.onclick = function(e) { if (e.target === overlay) close(); };

  okBtn.onclick = function() {
    Object.keys(inputs).forEach(function(name) {
      var val = inputs[name].value.trim();
      if (val) {
        annoSpan.dataset[name] = val;
      } else {
        delete annoSpan.dataset[name];
      }
    });
    close();
  };

  removeBtn.onclick = function() {
    unwrapAnnotation(annoSpan);
    close();
  };

  // Enter to confirm
  dialog.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') { okBtn.click(); e.preventDefault(); }
    if (e.key === 'Escape') { close(); }
  });
}

function unwrapAnnotation(span) {
  var parent = span.parentNode;
  while (span.firstChild) {
    parent.insertBefore(span.firstChild, span);
  }
  parent.removeChild(span);
}

// ─── Mixed Editor Initialization ────────────────────────────────────────

var cmInstances = {};

function initMixedEditor(wrapper) {
  var context = wrapper.dataset.context || 'abstract';
  var fieldName = wrapper.dataset.field;
  var toolbar = wrapper.querySelector('.mixed-editor-toolbar');
  var editorDiv = wrapper.querySelector('.cei-editor');
  var cmWrapper = wrapper.querySelector('.cm-wrapper');
  var hiddenInput = wrapper.querySelector('input[type="hidden"]');

  // Find mode toggle buttons (already in HTML)
  var btnVisual = toolbar.querySelector('[data-mode="visual"]');
  var btnXml = toolbar.querySelector('[data-mode="xml"]');
  var tb = { btnVisual: btnVisual, btnXml: btnXml };

  // XML textarea for pro mode
  var xmlTextarea = null;

  // Mode switching
  tb.btnVisual.onclick = function() {
    if (xmlTextarea) {
      editorDiv.innerHTML = ceiToHtml(xmlTextarea.value);
    }
    editorDiv.style.display = '';
    cmWrapper.style.display = 'none';
    tb.btnVisual.classList.add('active');
    tb.btnXml.classList.remove('active');
  };

  tb.btnXml.onclick = function() {
    var xml = serializeToCEI(editorDiv);
    editorDiv.style.display = 'none';
    cmWrapper.style.display = 'block';
    tb.btnXml.classList.add('active');
    tb.btnVisual.classList.remove('active');

    if (!xmlTextarea) {
      xmlTextarea = document.createElement('textarea');
      xmlTextarea.className = 'xml-textarea';
      xmlTextarea.spellcheck = false;
      cmWrapper.appendChild(xmlTextarea);
    }
    xmlTextarea.value = xml;
  };

  // Right-click context menu for inserting CEI elements
  var fieldGroups = TOOLBAR_GROUPS[context] || TOOLBAR_GROUPS.abstract;
  // Track selection state before contextmenu fires (browser may collapse it)
  var savedSelection = '';
  editorDiv.addEventListener('mouseup', function() {
    var sel = window.getSelection();
    savedSelection = sel ? sel.toString().trim() : '';
  });
  editorDiv.addEventListener('keyup', function() {
    var sel = window.getSelection();
    savedSelection = sel ? sel.toString().trim() : '';
  });

  editorDiv.addEventListener('contextmenu', function(e) {
    // Only in visual mode
    if (editorDiv.style.display === 'none') return;
    e.preventDefault();

    var hasSelection = savedSelection.length > 0;

    // Determine context: are we inside an annotation?
    var parentAnno = e.target.closest('.cei-anno');
    var parentElem = parentAnno ? parentAnno.dataset.cei : null;

    // DECISION: selection → always show insert menu, no selection → attr dialog
    if (!hasSelection && parentAnno && parentAnno !== editorDiv) {
      showAttrDialog(parentAnno);
      return;
    }

    // Get allowed children for this context
    var allowedItems = null;
    if (parentElem && ALLOWED_CHILDREN[parentElem] !== undefined) {
      allowedItems = ALLOWED_CHILDREN[parentElem];
      if (allowedItems.length === 0) {
        if (!hasSelection) showAttrDialog(parentAnno);
        return;
      }
    }

    // Build context-sensitive menu groups
    var menuGroups;
    if (allowedItems) {
      // Filter field groups to only allowed items
      menuGroups = [];
      fieldGroups.forEach(function(group) {
        var filtered = group.items.filter(function(item) {
          return allowedItems.indexOf(item) !== -1;
        });
        if (filtered.length > 0) {
          menuGroups.push({ label: group.label + ' (in ' + parentElem + ')', items: filtered });
        }
      });
      if (menuGroups.length === 0) {
        // Fallback: flat list of allowed items
        menuGroups = [{ label: 'Allowed in ' + parentElem, items: allowedItems }];
      }
    } else {
      // Top-level: use full field groups
      menuGroups = fieldGroups;
    }

    showContextMenu(e.pageX, e.pageY, menuGroups, editorDiv);
  });

  // Click on annotation → show attr dialog
  editorDiv.addEventListener('click', function(e) {
    var anno = e.target.closest('.cei-anno');
    if (anno && anno !== editorDiv) {
      e.preventDefault();
      showAttrDialog(anno);
    }
  });

  // Before form submit: serialize content to hidden input
  var form = wrapper.closest('form');
  if (form) {
    form.addEventListener('submit', function() {
      if (xmlTextarea && cmWrapper.style.display !== 'none') {
        hiddenInput.value = xmlTextarea.value;
      } else {
        hiddenInput.value = serializeToCEI(editorDiv);
      }
    });
  }
}

// ─── Tab Switching ──────────────────────────────────────────────────────

function initTabs() {
  var buttons = document.querySelectorAll('.editor-tabs button');
  var tabs = document.querySelectorAll('.editor-tab');

  buttons.forEach(function(btn) {
    btn.addEventListener('click', function() {
      var target = btn.dataset.tab;
      tabs.forEach(function(t) {
        t.classList.toggle('active', t.dataset.tab === target);
      });
      buttons.forEach(function(b) {
        b.classList.toggle('active', b.dataset.tab === target);
      });
    });
  });

  // Activate first tab
  if (buttons.length > 0) buttons[0].click();
}

// ─── Repeatable Fields ──────────────────────────────────────────────────

function initRepeatables() {
  document.querySelectorAll('.btn-add-entry').forEach(function(btn) {
    btn.addEventListener('click', function() {
      var group = btn.closest('.repeatable-group');
      var template = group.querySelector('.repeatable-template');
      if (!template) return;
      var clone = template.cloneNode(true);
      clone.classList.remove('repeatable-template');
      clone.style.display = '';
      clone.querySelectorAll('input').forEach(function(inp) { inp.value = ''; });
      group.insertBefore(clone, btn);
    });
  });

  document.addEventListener('click', function(e) {
    if (e.target.classList.contains('btn-remove')) {
      var entry = e.target.closest('.repeatable-entry');
      if (entry) entry.remove();
    }
  });
}

// ─── Schema Loading ─────────────────────────────────────────────────────

function loadSchema(callback) {
  fetch('/mom/api/editor/schema', { credentials: 'same-origin' })
    .then(function(r) { return r.json(); })
    .then(function(data) {
      if (data.children) ALLOWED_CHILDREN = data.children;
      if (data.attributes) CEI_ATTRIBUTES = data.attributes;
      // Also rebuild TOOLBAR_GROUPS from schema children for top-level contexts
      if (data.children.abstract) {
        TOOLBAR_GROUPS.abstract = buildGroupsFromChildren(data.children.abstract, 'abstract');
      }
      if (data.children.tenor) {
        TOOLBAR_GROUPS.tenor = buildGroupsFromChildren(data.children.tenor, 'tenor');
      }
      callback();
    })
    .catch(function(err) {
      console.warn('Could not load CEI schema, using defaults:', err);
      callback();
    });
}

function buildGroupsFromChildren(children, context) {
  var indexing = [], layout = [], roles = [], diplomatics = [], transcription = [];
  var indexItems = ['persName','placeName','orgName','geogName','foreign','index','date','dateRange','num','measure','testis','rolename'];
  var layoutItems = ['hi','sup','lb','pb'];
  var roleItems = ['issuer','recipient'];
  var diplItems = ['invocatio','intitulatio','inscriptio','arenga','publicatio','narratio','rogatio','intercessio','dispositio','sanctio','corroboratio','datatio','subscriptio','notariusSub','setPhrase'];
  var transItems = ['expan','sic','corr','del','add','supplied','unclear','app'];

  children.forEach(function(c) {
    if (indexItems.indexOf(c) !== -1) indexing.push(c);
    else if (layoutItems.indexOf(c) !== -1) layout.push(c);
    else if (roleItems.indexOf(c) !== -1) roles.push(c);
    else if (diplItems.indexOf(c) !== -1) diplomatics.push(c);
    else if (transItems.indexOf(c) !== -1) transcription.push(c);
  });

  var groups = [];
  if (indexing.length) groups.push({ label: 'Indexing', items: indexing });
  if (layout.length) groups.push({ label: 'Layout', items: layout });
  if (roles.length) groups.push({ label: 'Roles', items: roles });
  if (diplomatics.length) groups.push({ label: 'Diplomatics', items: diplomatics });
  if (transcription.length) groups.push({ label: 'Transcription', items: transcription });
  return groups;
}

// ─── Init ───────────────────────────────────────────────────────────────

function init() {
  initTabs();
  initRepeatables();

  // Load schema from server, then init mixed editors
  loadSchema(function() {
    document.querySelectorAll('.mixed-editor-wrapper').forEach(function(w) {
      initMixedEditor(w);
    });
  });
}

// Run when DOM ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}

})();
