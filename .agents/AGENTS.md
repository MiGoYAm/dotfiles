Always use Context7 when I need library/API documentation, code generation, setup or configuration steps without me having to explicitly ask.

Be brief.
<!-- 
# Subagent model routing

- Delegate only for useful parallelism, fresh context, specialist judgment or
  tool isolation. Do a direct read or command yourself when delegation would
  cost more coordination than it saves. The tiers below are a menu, not a
  required sequence: choose the lowest tier that fits

  | Model | Effort | Recommended work |
  | --- | --- | --- |
  | `gpt-6-luna` | low | Cheap, bounded verification; focused exploration, extraction, classification and log triage. Not final judgment about correctness, security or design. |
  | `gpt-6.2-sol` | medium; high for review | Default for substantial implementation and technical investigation. |

- Escalate one tier only for a concrete failure or unresolved risk. Preserve the
  original brief, evidence and prior findings instead of repeating an unchanged
  prompt.

- Prefer fewer, well-scoped agents over long agent chains; a cheap model whose
  result needs substantial rework is not cheaper. -->

<!-- https://github.com/cursor/plugins/blob/main/pstack/skills/technical-writing/SKILL.md -->
<!-- # Writing, prose, replies, PR descriptions

Write so a tired engineer understands on the first read.

- Cut every word that does no work.
- Use the short, everyday word: "use", not "utilize".
- When a rule makes a sentence worse, fix the sentence another way or leave it alone.
- Write the real symbol, file, flag, or command name, not a synonym or a description of it.
- Don't invent jargon. Use the words a developer would say out loud. Say what a named pattern means the first time.

## Vary the rhythm

- Mix sentence lengths. Split the sentence that carries two thoughts. Keep the long sentence that carries one.
- Have a view in explanation. Keep reference dry.
- Be specific. Not "schema changes can cause issues" but "a column rename fails the build".

## Pick the mode first (Diátaxis)

One document, one mode. Don't mix modes. Split and link instead.

- **Tutorial: learning by doing.** Say what the learner will build. Every step produces a visible result, and you say what they should see. Explanation gets one clause and a link.
- **How-to: steps to a goal.** Solve the reader's problem. Assume competence. Action only. Allow forks. Name the guide by the task.
- **Reference: facts for lookup.** Only describe. Be dry, complete, and sure. Mirror the structure of the thing described.
- **Explanation: understanding and why.** One bounded topic. Give context: design decisions, history, constraints, alternatives. Opinion is allowed here and nowhere else.

## Write sentences to the reader (Google developer style)

- Talk to the reader as "you", in the present tense.
- Say who does what. Passive is fine only when the actor is unknown or beside the point.
- Write instructions as commands. Put the condition before the instruction and the common case first.
- No buzzwords, no figurative language, no "please", and never "simply", "easy", or "quickly" in a procedure.
- Don't pre-announce, and don't start consecutive sentences with the same phrase.
- Link with words that say where the link goes.
- Headings carry the point, in sentence case. One h1 per page, no skipped levels.
- Numbered lists for sequences, bullets for everything else. Introduce a list with a complete sentence. Keep items parallel.
- Code goes in code font. UI elements go in bold. Use serial commas. Drop "etc.".

## Make statements load one at a time (STE rules)

- One instruction per sentence. One thought per sentence everywhere else.
- Split instructions longer than about 20 words and other sentences longer than about 25.
- Put the warning or condition before the step it guards.
- Keep "the" and "a".
- Give each word one meaning, and pick one word per action.
- Write procedures as direct commands, never as narration and never in the passive.
- Avoid "-ing" words where you can.

## Leave no sentence open to two readings (Global English)

- Keep words like "only" and "not" next to the word they change.
- Break up long noun strings.
- Make every "it", "they", and "this" point at one obvious thing. Never use "this" or "which" to point at a whole clause.
- Don't drop verbs, or the small words that show structure, such as "that".
- Repeat the article in a series when it prevents a misread. Say which parts "and" or "or" joins.
- Use periods, not semicolons or em dashes. No slashes, and no "(s)". Make text in parentheses a full grammatical unit.
- Call each thing by one name, everywhere.
- Skip idioms, colloquialisms, Latin abbreviations, and metaphors. -->

## Polish

- Do not translate words taken from configuration, code, docs. 

  For example: "Znalazłem gotowe reguły poza Oxlint dla wymiarów obrazów, poziomów nagłówków, zoomu i ograniczania ruchu w CSS."
  *ograniczania ruchu w CSS* -> "`prefers-reduced-motion` w CSS"

  Direct text is always better than proxy wording.
- Polonize words so the text reads more smoothly. *Label* -> "Labelki", "Labele"
