/*
 * WhatsApp Web - bulk contact deletion helper
 *
 * MODIFIED VERSION
 *
 * Changes:
 * 1. Clicks the actual contact row rather than its inner span.
 * 2. Header verification timeout increased to 10 seconds.
 * 3. Additional diagnostic logging when header verification fails.
 *
 * IMPORTANT:
 * Test using Probe before attempting deletion.
 * WhatsApp Web's DOM may change, so this remains untested
 * against your live WhatsApp Web interface.
 */

(() => {
  if (window.__waBulk) window.__waBulk.destroy();

  // ---- Settings ------------------------------------------------------------

  const CFG = {
    editIcon: /edit|pencil|\bpen\b/i,
    deleteIcon: /delete|trash|\bbin\b|remove/i,

    iconNever: /chat|message|media|group|exit|block|report|clear|label|list|starred|archive/i,

    confirmBtn: /^(yes,? )?(delete|remove)( contact)?$/i,

    blockIfDialogMentions: /address book|phone contacts|google|synced from/i,

    ignoreRows: /^(new group|new contact|new community|new chat)$/i,

    delayMs: [2500, 4500],

    timeout: 8000,
  };

  // ---- Helpers -------------------------------------------------------------

  const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

  const rand = ([a, b]) => a + Math.random() * (b - a);

  const visible = (e) => e && e.offsetParent !== null;

  async function waitFor(fn, t = CFG.timeout) {
    const s = Date.now();

    while (Date.now() - s < t) {
      const v = fn();

      if (v) return v;

      await sleep(150);
    }

    return null;
  }

  function click(el) {
    for (const t of ['mousedown', 'mouseup', 'click']) {
      el.dispatchEvent(
        new MouseEvent(t, {
          bubbles: true,
          cancelable: true,
          view: window
        })
      );
    }
  }

  function esc() {
    document.dispatchEvent(
      new KeyboardEvent('keydown', {
        key: 'Escape',
        keyCode: 27,
        bubbles: true
      })
    );
  }

  const skipErr = (m) =>
    Object.assign(new Error(m), { skip: true });

  // ---- UI shell ------------------------------------------------------------

  const ui = document.createElement('div');

  ui.id = 'wa-bulk-ui';

  ui.style.cssText =
    'position:fixed;top:10px;right:10px;width:340px;max-height:90vh;display:flex;flex-direction:column;' +
    'background:#fff;color:#111;border:1px solid #888;border-radius:8px;z-index:99999;font:13px sans-serif;box-shadow:0 4px 20px #0006';

  ui.innerHTML = `
    <div style="padding:8px;border-bottom:1px solid #ddd;display:flex;gap:6px;align-items:center">
      <b style="flex:1">WhatsApp bulk contact delete</b>
      <button id="wb-x">x</button>
    </div>

    <div style="padding:8px;display:flex;gap:6px;flex-wrap:wrap">
      <button id="wb-scan">1. Scan contacts</button>
      <button id="wb-probe">2. Probe (no delete)</button>
      <button id="wb-del">3. Delete selected</button>
      <button id="wb-stop">Stop</button>
    </div>

    <div style="padding:0 8px 6px">
      <input id="wb-q" placeholder="Search..." style="width:100%;box-sizing:border-box">
      <label>
        <input type="checkbox" id="wb-all"> Select all shown
      </label>
      <span id="wb-n"></span>
    </div>

    <div id="wb-list" style="overflow:auto;flex:1;min-height:120px;padding:0 8px;border-top:1px solid #eee"></div>

    <div id="wb-log" style="font:11px monospace;max-height:110px;overflow:auto;padding:6px 8px;border-top:1px solid #ddd;background:#f6f6f6"></div>
  `;

  document.body.appendChild(ui);

  const $ = (id) => ui.querySelector('#' + id);

  const log = (m) => {
    const d = document.createElement('div');

    d.textContent = m;

    $('wb-log').appendChild(d);

    $('wb-log').scrollTop = 1e9;

    console.log('[wa-bulk]', m);
  };

  // ---- State ---------------------------------------------------------------

  let contacts = [];

  const selected = new Set();

  let stop = false;
  let busy = false;

  function shown() {
    const q = $('wb-q').value.trim().toLowerCase();

    return contacts.filter((n) =>
      n.toLowerCase().includes(q)
    );
  }

  function render() {
    const list = $('wb-list');

    list.innerHTML = '';

    for (const n of shown()) {
      const l = document.createElement('label');

      l.style.cssText = 'display:block;padding:2px 0';

      const c = document.createElement('input');

      c.type = 'checkbox';
      c.checked = selected.has(n);

      c.onchange = () => {
        c.checked ? selected.add(n) : selected.delete(n);

        count();
      };

      l.append(c, ' ' + n);

      list.appendChild(l);
    }

    count();
  }

  function count() {
    $('wb-n').textContent =
      `${selected.size} selected / ${contacts.length} total`;
  }

  // ---- New chat panel ------------------------------------------------------

  function newChatOpen() {
    return [...document.querySelectorAll('h1,h2,span,div')].some(
      (e) =>
        !ui.contains(e) &&
        e.children.length === 0 &&
        e.textContent.trim() === 'New chat' &&
        visible(e)
    );
  }

  async function openNewChat() {
    if (newChatOpen()) return;

    const b = document.querySelector(
      '[aria-label="New chat"],[data-icon="new-chat-outline"]'
    );

    if (!b) {
      throw new Error('Could not find the New chat button');
    }

    click(b.closest('button,[role=button]') || b);

    if (!(await waitFor(newChatOpen))) {
      throw new Error('New chat panel did not open');
    }
  }

  function getScroller() {
    let best = null;
    let bc = 0;

    document.querySelectorAll('div').forEach((d) => {
      if (ui.contains(d)) return;

      if (
        !/(auto|scroll)/.test(getComputedStyle(d).overflowY) ||
        d.scrollHeight <= d.clientHeight + 5
      ) return;

      if (d.getBoundingClientRect().left > innerWidth * 0.45) return;

      const n = d.querySelectorAll(
        '[role=listitem],[role=button],[role=row]'
      ).length;

      if (n > bc) {
        bc = n;
        best = d;
      }
    });

    return best;
  }

  function rowNames(sc) {
    const out = [];

    sc.querySelectorAll(
      '[role=gridcell],[role=listitem],[role=button],[role=row]'
    ).forEach((r) => {
      const s = r.querySelector('span[title]');

      const n = s && s.getAttribute('title').trim();

      if (n && !CFG.ignoreRows.test(n)) {
        out.push(n);
      }
    });

    return out;
  }

  async function scan() {
    await openNewChat();

    const sc = await waitFor(getScroller);

    if (!sc) {
      throw new Error('Could not find the contact list');
    }

    const found = new Set();

    sc.scrollTop = 0;

    await sleep(500);

    let last = -1;
    let stable = 0;

    while (stable < 3 && !stop) {
      rowNames(sc).forEach((n) => found.add(n));

      sc.scrollTop += sc.clientHeight * 0.8;

      await sleep(400);

      if (sc.scrollTop === last) {
        stable++;
      } else {
        stable = 0;
        last = sc.scrollTop;
      }
    }

    contacts = [...found].sort((a, b) =>
      a.localeCompare(b)
    );

    for (const n of [...selected]) {
      if (!found.has(n)) selected.delete(n);
    }

    render();

    log(
      `Scanned ${contacts.length} entries. NOTE: this list includes phone-synced contacts too - only tick ones you know are WhatsApp-only.`
    );

    esc();
  }

  // ---- Contact deletion helpers -------------------------------------------

  const labelOf = (e) =>
    (e.innerText || e.getAttribute('aria-label') || '').trim();

  function findByText(re, root = document) {
    return [...root.querySelectorAll(
      'button,[role=button],[role=menuitem],li,[role=listitem]'
    )]
      .filter(
        (e) =>
          visible(e) &&
          !ui.contains(e) &&
          labelOf(e).length < 60
      )
      .find((e) =>
        labelOf(e).split('\n').some((l) => re.test(l.trim()))
      );
  }

  function dump(where) {
    const items = [...document.querySelectorAll(
      'button,[role=button],[role=menuitem]'
    )]
      .filter((e) => visible(e) && !ui.contains(e))
      .map((e) => labelOf(e).split('\n')[0])
      .filter(Boolean);

    log(
      `[probe] clickable items ${where}: ${[...new Set(items)].slice(0, 25).join(' | ')}`
    );
  }

  function describe(e) {
    const q = (sel, attr) => {
      const x = e.querySelector(sel);

      return x && x.getAttribute(attr);
    };

    return [
      e.getAttribute('aria-label'),
      e.getAttribute('title'),
      e.getAttribute('data-icon'),
      e.getAttribute('data-testid'),
      q('[data-icon]', 'data-icon'),
      q('[aria-label]', 'aria-label'),
      q('[title]', 'title'),
      (e.innerText || '').split('\n')[0]
    ]
      .filter(Boolean)
      .join(' | ')
      .trim();
  }

  function candidates() {
    const dlg = [...document.querySelectorAll('[role=dialog]')]
      .find(visible);

    const sel = 'button,[role=button],[role=menuitem]';

    const all = [...(dlg || document).querySelectorAll(sel)]
      .filter((e) => visible(e) && !ui.contains(e));

    return dlg
      ? all
      : all.filter(
          (e) => e.getBoundingClientRect().left > innerWidth * 0.5
        );
  }

  function findAction(re) {
    return candidates().find((e) => {
      const d = describe(e);

      return (
        d.length < 120 &&
        re.test(d) &&
        !CFG.iconNever.test(d)
      );
    });
  }

  function dumpIcons(where) {
    const list = [...new Set(
      candidates().map(describe).filter(Boolean)
    )].slice(0, 30);

    log(
      `[probe] ${where}: ${list.join(' // ') || '(no clickable items found in info pane)'}`
    );
  }

  function findSearch() {
    return [...document.querySelectorAll(
      '[contenteditable="true"],input[type=text],input:not([type])'
    )].find(
      (e) =>
        !ui.contains(e) &&
        !e.closest('#main') &&
        !e.closest('footer') &&
        visible(e) &&
        e.getBoundingClientRect().left < innerWidth * 0.45
    );
  }

  function setText(el, t) {
    el.focus();

    document.execCommand('selectAll', false);

    document.execCommand('delete', false);

    document.execCommand('insertText', false, t);
  }

  // ---- Delete one contact --------------------------------------------------

  async function deleteOne(name, mode) {
    esc();

    await sleep(600);

    await openNewChat();

    const box = await waitFor(findSearch);

    if (!box) {
      throw new Error('Search box not found');
    }

    setText(box, name);

    await sleep(1000);

    const norm = (s) =>
      s.normalize('NFC').replace(/\s+/g, ' ').trim();

    const leftTitles = () =>
      [...document.querySelectorAll('span[title]')].filter(
        (s) =>
          !ui.contains(s) &&
          !s.closest('#main') &&
          visible(s) &&
          s.getBoundingClientRect().left < innerWidth * 0.45
      );

    // MODIFIED: Return the actual contact row, not the inner span.

    const matches = () => {
      const rows = new Map();

      leftTitles()
        .filter(
          (s) =>
            norm(s.getAttribute('title')) === norm(name)
        )
        .forEach((s) => {
          const row = s.closest(
            '[role=gridcell],[role=listitem],[role=button],[role=row]'
          );

          if (row) {
            rows.set(row, row);
          }
        });

      return rows.size ? [...rows.values()] : null;
    };

    const hits = (await waitFor(matches, 4000)) || [];

    if (hits.length !== 1) {
      log(
        `Titles visible after search: ${leftTitles()
          .map((s) => JSON.stringify(s.getAttribute('title')))
          .slice(0, 8)
          .join(', ') || '(none)'}`
      );

      throw skipErr(
        `${hits.length} exact matches for "${name}" - skipped`
      );
    }

    click(hits[0]);

    // ---- Header verification -----------------------------------------------

    const headerFor = () => {
      const h = document.querySelector('#main header');

      if (!h) return null;

      // Remove emoji characters for comparison only.
      // The original contact name remains unchanged.
      const stripEmoji = (s) =>
        s.replace(/\p{Extended_Pictographic}/gu, '')
         .replace(/[\uFE0E\uFE0F\u200D]/g, '')
         .trim();

      const comparable = (s) => norm(stripEmoji(s));

      const titled = [...h.querySelectorAll('span[title]')]
        .some(
          (s) =>
            comparable(s.getAttribute('title')) ===
            comparable(name)
        );

      const headerLines = (h.innerText || '')
        .split('\n')
        .map(line => comparable(line))
        .filter(Boolean);
    
      const nameFound =
        headerLines.includes(comparable(name));

      return titled || nameFound ? h : null;
    };

    // MODIFIED: Increased timeout to 10 seconds.

    const header = await waitFor(headerFor, 10000);

    if (!header) {
      const h = document.querySelector('#main header');

      log(`[diagnostic] Expected contact: ${name}`);

      log(
        `[diagnostic] Header text: ${
          h ? JSON.stringify(h.innerText) : '(no header found)'
        }`
      );

      log(
        `[diagnostic] Header titles: ${
          h
            ? [...h.querySelectorAll('[title]')]
                .map((e) => e.getAttribute('title'))
                .join(' | ')
            : '(none)'
        }`
      );

      log(
        `[diagnostic] Current URL: ${location.href}`
      );

      throw new Error(
        `Chat header verification failed for "${name}". Stopped safely.`
      );
    }

    await sleep(800);

    const targets = [
      (header.querySelector('span[title]') || {}).closest &&
        header.querySelector('span[title]').closest('[role=button]'),

      header.querySelector('[role=button]'),

      header
    ].filter(Boolean);

    let edit = null;

    for (const t of targets) {
      click(t);

      edit = await waitFor(
        () => findAction(CFG.editIcon),
        3000
      );

      if (edit) break;
    }

    if (mode === 'probe') {
      dumpIcons('after opening contact info');
    }

    if (!edit) {
      dumpIcons('pen icon NOT found');

      esc();

      throw new Error(
        `Pen/edit icon not found for "${name}"`
      );
    }

    click(edit);

    await sleep(1200);

    if (mode === 'probe') {
      dumpIcons('after clicking pen');
    }

    const del = await waitFor(
      () => findAction(CFG.deleteIcon),
      4000
    );

    if (!del) {
      dumpIcons('trash icon NOT found');

      esc();
      esc();

      throw new Error(
        `Trash icon not found for "${name}" (maybe not a WhatsApp-only contact)`
      );
    }

    if (mode === 'probe') {
      log(
        `[probe] OK: pen and trash found for "${name}" (trash = ${describe(del)}). Nothing was deleted.`
      );

      esc();
      esc();

      return;
    }

    // ---- Confirmation ------------------------------------------------------

    click(del);

    const dlg = await waitFor(
      () =>
        [...document.querySelectorAll('[role=dialog]')]
          .find(visible)
    );

    if (!dlg) {
      throw new Error('Confirmation dialog did not appear');
    }

    if (CFG.blockIfDialogMentions.test(dlg.innerText)) {
      const cancel = findByText(/^cancel$/i, dlg);

      cancel ? click(cancel) : esc();

      throw skipErr(
        `Dialog for "${name}" mentions phone/address book - skipped: ${dlg.innerText.replace(/\n/g, ' ').slice(0, 120)}`
      );
    }

    const ok = findByText(CFG.confirmBtn, dlg);

    if (!ok) {
      dump('in confirmation dialog');

      throw new Error('Confirm button not found');
    }

    click(ok);

    await waitFor(
      () =>
        ![...document.querySelectorAll('[role=dialog]')]
          .some(visible),
      6000
    );
  }

  // ---- Buttons -------------------------------------------------------------

  const guard = (fn) => async () => {
    if (busy) {
      return log('Busy - press Stop first.');
    }

    busy = true;
    stop = false;

    try {
      await fn();
    } catch (e) {
      log('ERROR: ' + e.message);
    } finally {
      busy = false;
    }
  };

  $('wb-x').onclick = () => api.destroy();

  $('wb-q').oninput = render;

  $('wb-all').onchange = (e) => {
    shown().forEach((n) =>
      e.target.checked
        ? selected.add(n)
        : selected.delete(n)
    );

    render();
  };

  $('wb-stop').onclick = () => {
    stop = true;

    log('Stopping after current contact...');
  };

  $('wb-scan').onclick = guard(scan);

  $('wb-probe').onclick = guard(async () => {
    const first = [...selected][0];

    if (!first) {
      return log('Tick one contact first.');
    }

    await deleteOne(first, 'probe');
  });

  $('wb-del').onclick = guard(async () => {
    const names = [...selected];

    if (!names.length) {
      return log('Nothing selected.');
    }

    const typed = prompt(
      `You are about to delete ${names.length} contact(s):\n\n` +
      `${names.slice(0, 15).join('\n')}` +
      `${names.length > 15 ? '\n...and ' + (names.length - 15) + ' more' : ''}\n\n` +
      'Chats and messages are NOT deleted by this tool. Only delete contacts you know are WhatsApp-only.\nType DELETE to confirm:'
    );

    if (typed !== 'DELETE') {
      return log('Cancelled - nothing deleted.');
    }

    let done = 0;

    for (const n of names) {
      if (stop) {
        log('Stopped.');
        break;
      }

      try {
        await deleteOne(n, 'delete');

        selected.delete(n);

        contacts = contacts.filter((c) => c !== n);

        done++;

        render();

        log(`Deleted: ${n}`);

        if (
          done === 1 &&
          names.length > 1 &&
          !confirm(
            'First contact deleted. Check that it behaved as expected (chat still there, phone contacts untouched).\nContinue with the rest?'
          )
        ) {
          log('Paused by you.');

          break;
        }

      } catch (e) {
        log(`${e.skip ? 'Skipped' : 'FAILED'}: ${e.message}`);

        if (!e.skip) {
          log('Stopping because of an unexpected UI state.');

          break;
        }
      }

      await sleep(rand(CFG.delayMs));
    }

    log(`Finished: ${done} deleted. Refreshing list...`);

    await scan();
  });

  // ---- API -----------------------------------------------------------------

  const api = {
    destroy() {
      stop = true;

      ui.remove();

      delete window.__waBulk;
    }
  };

  window.__waBulk = api;

  log('Ready. Click "1. Scan contacts".');

})();