# DATA contract

`DATA` is the object at the top of `template.html`; everything below it is the renderer. Strings marked *html* may carry inline HTML (`<code>`, `<b>`). Every other string is escaped. The demo dataset shipped in the template exercises every field below.

```js
const DATA = {
  title: 'Sign in with a magic link',            // h1 and <title>
  question: 'Which systems does one sign-in…',    // the one question the page answers; the lede
  client: { label: 'Browser', sub: 'web app' },   // the box wires start from
  headersNote: 'Every request carries…',          // html, optional; shown in every drawer unless call.headers overrides
  modes: [ { id, label } ],                       // 1–3; the first is the baseline (black), the others green
  lanes: [ { id, label, sub? } ],                 // ≤ 5 systems, top to bottom; colour comes from position
  calls: { [callId]: Call },                      // each call once; steps reference it by id
  flows: [ Flow ],                                // ≤ 6; one tab each, keys 1–9
  sections: [ { title, html } ]                   // optional; rendered under the player, in order
}
```

## Call

```js
{
  lane: 'auth',                 // lanes[].id that does the work
  from: 'bff',                  // optional lanes[].id; omit when the client calls. Draws a lane→lane wire.
  method: 'GET',                // any verb: GET, POST, EMIT, CONSUME, CRON…
  path: '/sessions',            // printed after the lane label; keep the query out, list it in params
  why: '…',                     // html. Required. The drawer prints “missing” without it.
  kind: 'read' | 'write' | 'warn',
                                // default read. write = dashed pill, counted in the tally
                                // (POST/PUT/PATCH/DELETE count as write on their own).
                                // warn = red dashed pill and red wire: the thing you want eyes on.
  params: [ { name, required: true | false, from: 'host prop' | 'constant 2000' | 'search box, debounced' } ],
  body: '{ "name": "…" }',      // printed as <pre>
  headers: '…',                 // html, optional; replaces headersNote for this call
  response: [ { group?: 'Always' | 'Only with reelUuid', key: 'inReel', type?: 'boolean', why: '…', present?: false } ],
                                // one heading per distinct group, first-seen order
                                // present:false → dimmed: in the contract, absent from this request
                                // [] → “nothing read from it”
  note: '…',                    // html, optional red callout in the drawer
  src: 'path/file.ts:41'        // where you read it
}
```

## Flow

```js
{
  id, entry: 'Videos page', label: 'Create a reel', sub: 'one line under the title',
  host: Host,                   // optional: the page behind the modal, shared by every step
  steps: { [modeId]: Step[] }   // a mode left out shows “no steps in <mode>” and n/a on the tab
}
```

## Step

```js
{
  title: 'Reel picker',
  where: 'modal · ReelModal.tsx',     // optional grey hint beside the title
  screen: Screen | 'plain text',      // omit for a page step that shows the host
  calls: [ 'callId', … ],             // [] is a real step with no call
  note: '…',                          // html, optional red callout above the screen (“Product decision: …”)
  fork: { label: 'Which reel?', options: [ { id: 'existing', label: 'Existing reel' }, { id: 'new', label: '+ New reel' } ] },
                                      // one fork per flow; it shows on every step of that flow
  by: { [optionId]: { title?, calls?, screen?, note? } }   // overrides applied while that option is picked
}
```

## Screen

```js
{ kind: 'page' }                                // the host, lit
{ kind: 'modal', title, lines, cta?, host? }    // host dimmed, modal on top
{ kind: 'card',  title, lines }                 // no host; pipelines, jobs, backend-only steps
{ kind: 'toast', title }                        // “✓ Saved”
{ html: '<div>…</div>' }                        // escape hatch, raw
```

## Host

```js
{ title: 'Highlight reels', crumb: 'Results › Sessions', lines: [ … ] }
```

## Lines: the wireframe markers

One string per row. The first token decides the look:

| Prefix | Renders as |
|---|---|
| `[x] ` / `[ ] ` | checked / unchecked row |
| `(*) ` / `( ) ` / `(~) ` | selected / plain / disabled pick-list item |
| `> ` | primary button, pulsing: the thing the user clicks next |
| `\| ` | input field holding that value |
| `# ` | small section label |
| `~ ` | muted secondary text |
| `! ` | red inline warning |
| `---` | divider |
| anything else | plain row |

## URL state

`#f=<flow, 1-based>&s=<step>&m=<modeId>&b=<optionId>&d=<call index on that step>`. `d` opens the drawer. The page rewrites the hash as you click, so any state is a deep link.
