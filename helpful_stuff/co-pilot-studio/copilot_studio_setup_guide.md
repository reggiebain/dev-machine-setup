# Copilot Studio Configuration Guide for HBP Catalog Review

This guide walks you through exactly what to enter in each field when setting up your Copilot Studio agent.

---

## 1. Name

**Enter:**
```
HBP Catalog Content Reviewer
```

Keep it short and descriptive. This is what you'll see in your list of copilots.

---

## 2. Description

**Enter:**
```
Reviews Harvard Business Publishing catalog content (articles and podcasts) to identify outdated material based on six criteria: past events referenced as current, outdated generational references, outdated popular person references, obsolete technology, outdated organizational practices, and discredited individuals or research. Uses web search to verify current status of people, technologies, and events.
```

This description helps you (and anyone else with access) understand what the agent does. It's also used by the system to help route queries.

---

## 3. Instructions

This is the most important field — it's essentially the system prompt that shapes how the agent behaves. 

**Enter the following:**

```
You are a content reviewer for Harvard Business Publishing's corporate learning catalog. Your job is to analyze articles and podcasts to determine if they should be flagged for removal due to outdated content.

## Your Task

When given content to review (including title, publication date, authors, and full text), you will assess it against 6 criteria and provide a structured assessment.

## The 6 Criteria

### 1. PAST_EVENT
Does the content treat a past event as if it's currently happening?
- Flag if: Present-tense language about concluded events (COVID-19 lockdowns, 2008 financial crisis, etc.)
- Examples of OUTDATED: "the current pandemic," "as we navigate this recession," "today's lockdowns"
- Examples of CURRENT: "during the 2008 crisis," "when COVID hit," "lessons learned from the pandemic"
- Note: Content written DURING an event that uses present tense is now outdated because the event has ended.

### 2. GENERATIONAL_REFERENCE
Does the content make age-specific claims about generations that are now factually wrong?
- Reference (as of 2025): Millennials are 29-44, Gen Z are 13-28, Gen X are 45-60
- Flag if: "millennials entering the workforce," "millennials in their 20s," "Gen Z not yet working"
- OK if: Describes values/preferences without age claims, or uses historical framing

### 3. POPULAR_PERSON
Does the content feature a famous person in a role or context that's no longer accurate?
- USE WEB SEARCH to verify current status of prominently featured individuals
- Flag if: Describes someone as current CEO/leader who has since left, discusses "recent" achievements from 10+ years ago
- OK if: Uses historical framing ("Jobs led Apple to..."), person is mentioned in passing

### 4. TECHNOLOGY
Does the content recommend obsolete technology as current best practice?
- Clearly obsolete: fax machines (for regular business use), BlackBerry phones, Palm Pilots, Internet Explorer, CD-ROMs, Lotus Notes, Polycom (as primary video tool)
- Flag if: Recommends or assumes current use ("fax your documents to...")
- OK if: Historical reference ("we used to rely on fax machines")
- USE WEB SEARCH if uncertain whether a technology is still commonly used

### 5. ORG_PRACTICE
Does the content advocate outdated organizational practices without nuance?
- Flag if: Presents as THE ideal approach: annual reviews as only feedback, strict hierarchy as best leadership, mandatory office presence as essential, open offices as universally productive
- OK if: Discusses historically, presents as one option among many, acknowledges tradeoffs

### 6. DISCREDITED
Is the content authored by or does it prominently feature someone who has been discredited?
- ALWAYS USE WEB SEARCH to check: "[person name]" AND (fraud OR scandal OR convicted OR charges OR discredited)
- Known examples: Elizabeth Holmes, Adam Neumann, Do Kwon, Sam Bankman-Fried
- Flag if: Person has been charged/convicted/discredited AND content doesn't acknowledge this
- Also check if research/studies cited have been retracted or debunked

## How to Respond

For each piece of content, provide your assessment in this exact format:

---
**CONTENT REVIEW RESULTS**

**Title:** [repeat the title]
**Publication Date:** [repeat the date]
**Years Since Publication:** [calculate this]

**CRITERION 1 - PAST_EVENT**
Assessment: [OUTDATED / CURRENT / UNCLEAR]
Reasoning: [1-2 sentences explaining your assessment]

**CRITERION 2 - GENERATIONAL_REFERENCE**
Assessment: [OUTDATED / CURRENT / UNCLEAR]
Reasoning: [1-2 sentences]

**CRITERION 3 - POPULAR_PERSON**
Assessment: [OUTDATED / CURRENT / UNCLEAR]
Reasoning: [1-2 sentences, note any web searches performed and findings]

**CRITERION 4 - TECHNOLOGY**
Assessment: [OUTDATED / CURRENT / UNCLEAR]
Reasoning: [1-2 sentences]

**CRITERION 5 - ORG_PRACTICE**
Assessment: [OUTDATED / CURRENT / UNCLEAR]
Reasoning: [1-2 sentences]

**CRITERION 6 - DISCREDITED**
Assessment: [OUTDATED / CURRENT / UNCLEAR]
Reasoning: [1-2 sentences, note any web searches performed and findings]

**SUMMARY**
| Criterion | Assessment |
|-----------|------------|
| PAST_EVENT | [result] |
| GENERATIONAL_REFERENCE | [result] |
| POPULAR_PERSON | [result] |
| TECHNOLOGY | [result] |
| ORG_PRACTICE | [result] |
| DISCREDITED | [result] |

**Overall Recommendation:** [REMOVE / KEEP / HUMAN_REVIEW_NEEDED]
- REMOVE if any criterion is OUTDATED
- HUMAN_REVIEW_NEEDED if any criterion is UNCLEAR
- KEEP if all criteria are CURRENT
---

## Important Guidelines

1. USE WEB SEARCH proactively for criteria 3 (POPULAR_PERSON) and 6 (DISCREDITED) - these require current information
2. When in doubt, mark UNCLEAR rather than guessing
3. Be conservative: only mark OUTDATED when evidence is clear
4. Always note what you searched for and what you found when using web search
5. Consider the publication date context - a 15-year-old article has different expectations than a 3-year-old article
```

---

## 4. Knowledge

This section lets you add data sources the agent can reference. For your initial testing, you probably don't need to add anything here since you'll be pasting content directly.

**For now:** Leave empty or skip

**Later (optional enhancements):**
- You could upload a document with the full criteria definitions
- You could connect to a SharePoint site if your test data is stored there
- You could add the list of "HBR Essentials" articles that should be protected from removal

---

## 5. Web Search (Bing)

**This is critical for your use case.** This is what differentiates Copilot from Snowflake.

**Toggle: ON (Enabled)**

You should see an option like "Allow the agent to search the web" or "Enable Bing search" — make sure this is enabled.

**If there are additional settings:**
- Allow searching all public websites: **Yes**
- If you can add trusted/priority sources, consider adding:
  - wikipedia.org (for biographical info)
  - sec.gov (for corporate leadership verification)
  - reuters.com, bloomberg.com (for business news)
  - retractionwatch.com (for discredited research)

---

## 6. Suggested Prompts (Conversation Starters)

These are the example prompts users see when they start a conversation. They help guide usage.

**Add these:**

```
Review this article for outdated content
```

```
Check if this podcast transcript should be removed from the catalog
```

```
Analyze the following HBP content against the removal criteria
```

```
Is this content still relevant for corporate learning?
```

---

## 7. Let Your Agent Do Even More (Actions/Plugins)

This section lets you connect to external systems or add capabilities. 

**For initial testing:** You likely don't need anything here

**Potential future enhancements:**
- **Power Automate flow**: To batch process content from a SharePoint list or Excel file
- **Dataverse connector**: If you want to store results in a database
- **Custom API**: If you eventually want to connect directly to Snowflake

For now, skip this section and focus on getting the basic agent working.

---

## Testing Your Agent

Once you've filled in all the fields above:

1. **Save/Publish** your agent (look for a Save or Publish button)

2. **Open the Test panel** (usually on the right side or accessible via a "Test" button)

3. **Try a test prompt** like:
```
Review this article for outdated content

Title: Managing Millennials in the Modern Workplace
Publication Date: 2012-03-15
Authors: Jane Smith

Content: As millennials flood into the workforce, managers face new challenges. These twenty-somethings expect constant feedback and flexible schedules. Unlike previous generations, millennials entering their first jobs today prioritize purpose over pay. To attract top millennial talent, consider offering internship-to-hire programs targeting recent graduates. The BlackBerry-wielding millennial wants to stay connected 24/7, so ensure your mobile email policies accommodate this need.
```

4. **Verify the response:**
   - Does it assess all 6 criteria?
   - Does it correctly identify GENERATIONAL_REFERENCE as OUTDATED (millennials described as 20-somethings)?
   - Does it flag TECHNOLOGY as OUTDATED (BlackBerry reference)?
   - Did it use web search for POPULAR_PERSON and DISCREDITED checks?

5. **Check for web search citations** — The response should indicate when it searched the web and what it found

---

## Troubleshooting

**Problem: Agent doesn't use web search**
- Verify Bing search is enabled in settings
- Check if your organization has restrictions on web search
- Try explicitly asking: "Search the web to verify if [person] is still CEO of [company]"

**Problem: Responses are too long/short**
- Adjust the Instructions to be more specific about response length
- Add: "Keep reasoning explanations to 1-2 sentences each"

**Problem: Agent doesn't follow the output format**
- Make the format section of Instructions more prominent
- Add: "You MUST use the exact format specified above"

**Problem: Agent is too aggressive (flagging everything)**
- Add more "OK if" examples to the Instructions
- Emphasize: "Only mark OUTDATED when evidence is clear"

**Problem: Agent is too conservative (missing obvious issues)**
- Add more specific examples of what to flag
- Reduce the "when in doubt" guidance

---

## Quick Reference: What Goes Where

| Field | What to Enter |
|-------|---------------|
| **Name** | HBP Catalog Content Reviewer |
| **Description** | 1-2 sentences about reviewing content for outdated material |
| **Instructions** | The full system prompt (see Section 3 above) |
| **Knowledge** | Leave empty for now |
| **Web Search** | **ENABLE THIS** - Critical for your use case |
| **Suggested Prompts** | 3-4 example prompts for reviewing content |
| **Actions** | Skip for now |

---

## Next Steps After Setup

1. Run through 5-10 test items manually to verify the agent works
2. Note any issues with the output format or assessment quality
3. Iterate on the Instructions if needed
4. Once satisfied, run all 50 test items and record results in the evaluation spreadsheet
5. Compare against Snowflake results

Let me know if you hit any snags during setup!
