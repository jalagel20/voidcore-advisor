# Voidcore Advisor

> A World of Warcraft addon for the **Midnight** expansion (Patch 12.0.5+) that helps you spend your **Nebulous Voidcores** intelligently.

**Game version:** Retail WoW — Midnight Season 1 (Interface 120005)
**Status:** Active development
**Repo:** [github.com/jalagel20/voidcore-advisor](https://github.com/jalagel20/voidcore-advisor)

---

## What it does

Patch 12.0.5 introduced the **Voidforge Bonus Roll** system. After completing eligible content, you can spend Nebulous Voidcores — earned from Decimus in exchange for gold, Voidlight Marl, or Veteran Dawncrest — to roll on a bonus item from that activity's loot pool. Raid bonus rolls cost **2 cores**; Mythic+ rolls cost **1**.

This addon focuses on **raid + Mythic+** content only. Bountiful Delves and Nightmare Prey Hunts also support Voidcore rolls in-game but are intentionally out of scope here — recommendations from those pools tend to be filler relative to high-end raid/M+ pieces, and the BiS guides agree.

The catch: **Voidcores are limited.** Your weekly cap grows by two per week and the season is finite. Spending them on filler when a chase item is one boss away is a pure resource leak.

**Voidcore Advisor** answers two questions in real time:
1. **Should I spend a Voidcore here, right now?** → A clear ROLL / SKIP popup the moment a bonus roll prompt opens.
2. **Which items should I be chasing for my spec?** → A ranked, filtered, deprioritization-aware recommendation list.

---

## Features

### Live decision support
- **ROLL / SKIP popup** appears automatically when you complete eligible content (Mythic raid kills + Mythic+10 and above).
- Heroic raid recommendations are off by default — toggle with `/voidcore heroic` for trinket edge cases.
- Recommendation accounts for what you already own, so the popup never tells you to chase a piece sitting in your bank.

### Auto-detection of obtained items
- Items are marked as collected the moment they enter your bags — whether from a Voidcore roll, a natural drop, mailed loot, vendor refund, or auto-loot.
- Detection runs on four signals (`CHAT_MSG_LOOT`, `ENCOUNTER_LOOT_RECEIVED`, `BONUS_ROLL_RESULT`, `BAG_UPDATE_DELAYED`) plus a one-shot bag scan on login so existing characters don't show stale data.
- All matches go through item-ID lookup, not just name string matching, so reskinned/duplicate-named items don't false-positive.

### Spend log + deprioritization
Every Voidcore spend is recorded with full context (content type, difficulty, boss/dungeon, cost, outcome). The Advisor uses this log to deprioritize content you've already burned attempts on:

- **Attempt fatigue:** after ~4 rolls in the same content type without a tracked drop, the recommendation score adds a +1.5 penalty, nudging you toward a different content pool to spread your attempts.
- **Slot saturation:** if you already own a higher-ranked item in the same slot (e.g. you have BiS trinket #1, the addon deprioritizes BiS trinket #2 since you can't equip both).
- **Per-character data:** Voidcores are per-character, so the spend log and collected-item set are too. Account-wide settings are kept separate.

### Per-spec BiS database
Recommendations come from Wowhead's [Best Voidforge Bonus Roll Gear](https://www.wowhead.com/news/best-voidforge-bonus-roll-gear-for-all-classes-in-midnight-patch-12-0-5-381320) compiled by class guide writers. The dataset covers all 13 classes and 39 specs (including Devourer Demon Hunter, the new Midnight spec). Tied recommendations are supported (e.g. Arms Warrior's #1 is `Gaze of the Alnseer / Umbral Plume`).

---

## Installation

1. Clone or download this repository.
2. Copy the entire `VoidcoreAdvisor/` folder into your WoW `_retail_/Interface/AddOns/` directory.
3. Make sure `VoidcoreAdvisor.toc` ends up at `_retail_/Interface/AddOns/VoidcoreAdvisor/VoidcoreAdvisor.toc`.
4. Launch WoW and enable "Voidcore Advisor" in the AddOns menu on the character select screen.

For developers: a symlink is convenient.
```bash
ln -s /path/to/this/repo "/Applications/World of Warcraft/_retail_/Interface/AddOns/VoidcoreAdvisor"
```

---

## Usage

### Slash commands

| Command | Effect |
|---|---|
| `/voidcore` or `/vca` | Open the main panel (full ranked list, owned items grayed out) |
| `/voidcore heroic` | Toggle Heroic raid recommendations on/off |
| `/voidcore log` | Print your last 10 Voidcore spends with their outcomes |
| `/voidcore stats` | Show total rolls and tracked-item hits |
| `/voidcore debug` | Toggle debug logging |
| `/voidcore reset` | Clear this character's collected-items list (does not affect spend log) |

### The popup
After an eligible completion, a small overlay appears with:
- **ROLL** (green) or **SKIP** (red) verdict
- The reasoning ("rank #2, Algeth'ar Puzzle Box still available — costs 1 core")
- A history footnote if you've rolled in this exact context before ("3 prior rolls here, 1 tracked drop")

The popup auto-hides after 20 seconds. You can also open the main panel manually at any time via the minimap button or `/voidcore`.

---

## How recommendations are scored

Internally, every BiS item gets a score. **Lower is better.**

```
score = baseRank
      + min(1.5, attempts × 0.4)        -- attempt-fatigue penalty
      + (1.0 if a higher-ranked same-slot item is already owned)
```

`ShouldRoll()` picks the lowest-score item that is (a) still available in the current content's pool, (b) not already collected, and (c) eligible under your difficulty toggle. The popup verdict is based on whether any qualifying item exists.

---

## Architecture

```
VoidcoreAdvisor/
├── VoidcoreAdvisor.toc      # Addon manifest, Interface 120005
├── Core.lua                 # Event dispatcher, init, slash commands
├── Data/
│   ├── Items.lua            # itemName -> { id, slot } + reverse lookup table
│   ├── Recommendations.lua  # classID -> specID -> ranked BiS list (ties supported)
│   └── Sources.lua          # itemName -> { contentType, instanceID, bossID, difficulty[] } [WIP]
├── Modules/
│   ├── SpendLog.lua         # Currency-delta detection, spend-outcome correlation
│   ├── Tracker.lua          # Voidcore count, collected-items, loot-event subscribers
│   ├── Detector.lua         # Eligibility gate (Mythic raid / M+10+ / Heroic toggle)
│   └── Advisor.lua          # Scoring + ShouldRoll() + Recommend()
└── UI/
    ├── BonusRollPopup.lua   # ROLL/SKIP overlay
    ├── MainFrame.lua        # /voidcore full panel
    └── MinimapButton.lua    # Lightweight minimap launcher
```

**Persistence**
- `VoidcoreAdvisorDB` (account-wide): user settings — `enabled`, `showHeroicRaid`, `minMythicPlusLevel`, `showMinimapButton`, `autoDetectLoot`, `debug`.
- `VoidcoreAdvisorCharDB` (per-character): `collected[itemName][difficulty] = true`, `spendLog[]`, `attempts[fingerprint] = { rolls, hits, lastTs }`.

---

## Data sources

- **BiS rankings:** Wowhead's class guide writers, compiled in [this article](https://www.wowhead.com/news/best-voidforge-bonus-roll-gear-for-all-classes-in-midnight-patch-12-0-5-381320). When the rankings are updated by the guide team, `Data/Recommendations.lua` will be regenerated.
- **Item IDs:** scraped from the same article (50 items, all class/spec recommendations covered).
- **Boss/dungeon source mappings:** *not yet populated* — see [Roadmap](#roadmap) below.

---

## Roadmap

### Phase 1 — current (v0.1.x)
- [x] Full per-spec BiS database
- [x] ROLL/SKIP popup on bonus roll prompts
- [x] Auto-detection of collected items (bonus roll + natural drops + bag scan)
- [x] Spend log with attempt-fatigue + slot-saturation deprioritization
- [x] Slash commands and basic main panel

### Phase 2 — boss-by-boss loot probability (planned)
The headline feature. The current popup answers "should you roll" with a binary yes/no. Phase 2 will answer **"what is the probability this exact item drops if I spend a Voidcore right now?"**

The Voidcore system has a critical property:

> Once an item has been received using a Nebulous Voidcore, that item is removed from the loot pool for that player until all eligible items have been obtained on a per-difficulty basis.

This means probability is **deterministic and increasing** with each spend, not a flat random chance like classic bonus rolls. If a boss has 8 spec-eligible items on Mythic and you've already received 3 via Voidcores, your chance of any specific remaining item on the next roll is `1 / (8 - 3) = 20%`. After the next roll, it becomes `1/4 = 25%`. By your 8th roll on that boss, it's guaranteed.

What needs to be built:
1. **Full loot tables per boss/dungeon/spec/difficulty** — every item Decimus could grant from each activity, not just the BiS picks. Datamined from the journal API or scraped from Wowhead's encounter pages.
2. **Probability engine:**
   ```
   P(target item on roll k) = 1 / (poolSize - itemsObtained)
   P(target item by roll k) = 1 - ∏(i=1..k) (1 - 1/(poolSize - i + 1))
   ```
   Reaches 100% when remaining rolls ≥ remaining unique items.
3. **Display:** the popup adds a line like *"Gaze of the Alnseer: 14% this roll, 67% by your 5th roll, 100% by your 8th"*. The main panel shows a per-boss matrix of items × cumulative probability.
4. **Spend planner:** *"You have 12 Voidcores and 6 weeks left in the season. Spending all on Mythic Manaforge Omega gets you BiS in 3-4 rolls; spreading across two raids is mathematically slower."*

### Phase 3 — quality of life
- LibDBIcon integration for the minimap button (currently lightweight rolled-our-own)
- Tooltip injection on items in-game showing their BiS rank for your spec
- Currency advisor: at Decimus, recommend gold vs Voidlight Marl vs Veteran Dawncrest based on what you already have stockpiled
- Cross-character summary on the same account (e.g. for alts)
- Import/export collected-items list

---

## Unresolved issues

These are known gaps that don't block normal use but limit accuracy until resolved.

### 1. Nebulous Voidcore currency ID is a placeholder
**Where:** [`Modules/Tracker.lua:10`](Modules/Tracker.lua) — `NEBULOUS_VOIDCORE_CURRENCY_ID = 0`

**Why it matters:** The spend-detection logic watches this currency for decreases to recognize a Voidcore spend. Until it's set to the real currency ID, the SpendLog will never record spends and deprioritization won't kick in.

**Fix:** Run `/dump C_CurrencyInfo.GetCurrencyListSize()` in-game with the currency tab open, or check the WoW API datamine on Wowhead for the Patch 12.0.5 currency entry. Then update the constant.

### 2. Devourer Demon Hunter spec ID is a placeholder
**Where:** [`Data/Recommendations.lua:50`](Data/Recommendations.lua) — `[0] = { -- Devourer (FILL spec ID)`

**Why it matters:** Devourer is the new Midnight Demon Hunter spec. Until its spec ID is filled in, the addon won't surface recommendations for Devourer players (they'll see an empty panel).

**Fix:** Run `/dump GetSpecializationInfo(GetSpecialization())` while logged in on a Devourer DH and update the key.

### 3. `Data/Sources.lua` is empty
**Where:** [`Data/Sources.lua`](Data/Sources.lua)

**Why it matters:** Without source mappings, the Advisor can't filter recommendations to "items obtainable from *this specific* boss / dungeon" — it shows all spec recommendations regardless of context. The popup is still useful (ROLL/SKIP based on overall eligibility), but the recommendation isn't boss-specific.

**Also blocks:** Phase 2's probability feature, which needs full per-boss loot tables to compute pool sizes.

**Fix:** Two paths:
- **Wowhead scrape** — for each boss in the new Midnight raid + each M+ dungeon in the season, scrape the loot table. Doable but tedious.
- **In-game journal API** — `EJ_GetEncountersByRaidTier()` + `EJ_GetLootInfoByIndex()` can pull the data live from the client. Cleanest approach but requires a one-time dump script to generate the static table.

### 4. Bountiful Delve vs Nightmare Prey Hunt distinction
**Where:** [`Modules/Detector.lua:65`](Modules/Detector.lua)

**Why it matters:** Both fire `LFG_COMPLETION_REWARD`. The Detector currently labels both as `"delve"` with difficulty `"nightmare"`. This is fine for ROLL/SKIP popup logic but means the spend log and per-context attempt history conflates the two activity types.

**Fix:** Use `C_LFGList.GetActivityInfo()` or check `C_DelveInfo`/Prey Hunt API to distinguish via instance ID at the moment of completion.

### 5. WoW API event for Voidcore-specific roll results not yet wired
**Why it matters:** The legacy `BONUS_ROLL_RESULT` event is registered as a safety net, but it's unclear whether it fires for the new Voidforge Bonus Roll system. The current detection model (currency-delta + 6-second loot correlation window) will work either way, but a dedicated event would be more precise.

**Fix:** Once the Voidcore-specific event name is confirmed (Wowhead datamine or Blizzard API docs), wire it in [`Modules/Tracker.lua`](Modules/Tracker.lua) alongside the existing handlers.

---

## Contributing

Pull requests are welcome — especially for live data the maintainer can't easily verify (boss/dungeon source mappings, datamined IDs, BiS updates after balance patches).

### What we're looking for right now

- **Source mappings for `Data/Sources.lua`** — which boss in Manaforge Omega drops which item, on which difficulty, and the same for each Season 1 M+ dungeon. The cleanest path is running [`scripts/dump_sources.lua`](scripts/dump_sources.lua) in-game (just needs the instance IDs filled in first) and pasting the output.
- **Confirmed Wowhead item ID corrections** if any of the 50 in [`Data/Items.lua`](Data/Items.lua) turn out to be wrong in-game (the loot event handler will silently skip mismatched IDs, so this manifests as "I picked up the item but it didn't get marked collected").
- **BiS list updates** in [`Data/Recommendations.lua`](Data/Recommendations.lua) when class guide writers update their rankings. Cite the source.
- **The unresolved issues** listed above — fixes for any of them are high-value.

### Workflow

`main` is protected. All changes (except those by the maintainer) go through pull requests with one approving review. Linear history is required, so PR merges are squash or rebase only — no merge commits.

**If you've been added as a collaborator** (you have direct write access to the repo):

```bash
git clone https://github.com/jalagel20/voidcore-advisor.git
cd voidcore-advisor
git checkout -b your-feature-name
# ...make changes...
git commit -am "Describe what changed and why"
git push -u origin your-feature-name
gh pr create --base main --head your-feature-name --title "..." --body "..."
```

**If you're not a collaborator** (default for the public — you can read but not push to this repo): you must work from a fork.

```bash
# 1. Fork via the GitHub UI, or:
gh repo fork jalagel20/voidcore-advisor --clone
cd voidcore-advisor

# 2. Branch and commit on your fork
git checkout -b your-feature-name
# ...make changes...
git commit -am "Describe what changed and why"
git push -u origin your-feature-name

# 3. Open a PR back to the upstream repo
gh pr create --repo jalagel20/voidcore-advisor --base main \
  --head <your-username>:your-feature-name --title "..." --body "..."
```

Either way: never push directly to `main`. The remote will reject it for non-admins.

### What gets your PR merged

1. CI (none today — this is a planned addition)
2. **One approving review** from the maintainer
3. **All PR conversation threads resolved** (use the "Resolve" button on each suggestion)
4. The branch is **up to date with `main`** so the merge is linear (squash or rebase your commits if needed)

### Style notes

- Lua: 4-space indent, no semicolons, descriptive names, `local _, VA = ...` pattern at the top of every module file.
- One feature per PR. A small, focused PR is reviewed in minutes; a 12-file refactor sits.
- Commit messages should explain *why*, not just *what*. The diff already shows what.
- If you change a file under `Data/`, mention the source (Wowhead URL, in-game `/dump` output, datamine link) in the PR description.

### Reporting bugs

Open an issue with:
- Your character class + spec
- What you did (e.g. "killed Mythic Chimaerus, spent 2 Voidcores")
- What the addon said vs. what actually happened
- The output of `/voidcore log` if relevant

Screenshots of the popup or main panel are gold — they make reproducing the issue trivial.

---

## Credits

- BiS data compiled by Wowhead's class guide writers — original article [here](https://www.wowhead.com/news/best-voidforge-bonus-roll-gear-for-all-classes-in-midnight-patch-12-0-5-381320).
- Built with Claude Code.

---

## License

MIT
