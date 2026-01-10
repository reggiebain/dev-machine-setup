# HBP Catalog Review Project: Implementation Guide

## Table of Contents
1. [Refined Snowflake Prompts](#1-refined-snowflake-prompts)
2. [Copilot Studio Setup Guide](#2-copilot-studio-setup-guide)
3. [Evaluation Schema](#3-evaluation-schema)

---

## 1. Refined Snowflake Prompts

### Problems with the Current Prompts

The existing `AI_CLASSIFY` prompts have several issues:

1. **Ambiguous task framing**: The current prompts ask "is this outdated?" but the model lacks current knowledge to judge this
2. **Inverted logic**: Some prompts are confusingly worded (asking if content "accurately" refers to things)
3. **Missing temporal anchoring**: The model needs explicit reference to "today's date" and clear time thresholds
4. **No extraction step**: The model jumps straight to classification without first identifying relevant entities/claims
5. **Weak examples**: The task descriptions mention examples but don't show the model what to look for

### Refined Prompts

Below are improved prompts for each category. The key changes:
- Clearer, direct task framing
- Explicit time calculations using publication date
- Two-step reasoning (extract then classify)
- Concrete pattern matching

#### 1. PAST_EVENT (Events Referenced as Current)

```sql
AI_CLASSIFY(
    'Publication Date: ' || COALESCE(pub_date::VARCHAR, 'Unknown') || 
    E'\n\nContent:\n' || COALESCE(full_text, '') || 
    E'\n\nExecutive Summary:\n' || COALESCE(executive_summary, ''),
    [
        {'label': 'OUTDATED_PAST_EVENT', 'description': 'The content treats a past event (COVID-19 pandemic, 2008 financial crisis, specific recession, natural disaster, etc.) as ongoing or recently happening, using present-tense language like "the current crisis," "in today''s pandemic world," "as we navigate this recession," or "the ongoing lockdowns."'},
        {'label': 'CURRENT', 'description': 'The content either (a) does not mention major historical events, or (b) appropriately frames past events using past tense and historical context, such as "during the 2008 crisis," "when the pandemic hit," or "lessons learned from COVID."'},
        {'label': 'UNCLEAR', 'description': 'The content mentions a major event but the temporal framing is ambiguous and requires human review.'}
    ],
    { 
        'task_description': 'You are reviewing content for a corporate learning catalog. Your task is to identify content that treats PAST events as if they are CURRENT. 

STEP 1: Identify any mentions of major events (pandemics, financial crises, recessions, natural disasters, political events).

STEP 2: Check the language around these mentions:
- OUTDATED indicators: present tense ("is affecting," "are experiencing"), temporal markers ("today," "currently," "now," "this year"), assumption of ongoing impact without past-tense framing
- CURRENT indicators: past tense ("was," "happened," "during"), historical framing ("in 2008," "when COVID hit," "lessons from")

STEP 3: Consider the publication date. Content published DURING an event (e.g., 2020 article about COVID) that uses present tense is OUTDATED because the event has since ended.

Flag as OUTDATED_PAST_EVENT only if the content clearly treats a concluded event as ongoing.',
        'output_mode': 'single' 
    }
) as PAST_EVENT
```

#### 2. GENERATIONAL_REFERENCE

```sql
AI_CLASSIFY(
    'Publication Date: ' || COALESCE(pub_date::VARCHAR, 'Unknown') || 
    ' (This means the article is ' || COALESCE(DATEDIFF('year', pub_date, CURRENT_DATE())::VARCHAR, 'unknown') || ' years old)' ||
    E'\n\nContent:\n' || COALESCE(full_text, '') || 
    E'\n\nExecutive Summary:\n' || COALESCE(executive_summary, ''),
    [
        {'label': 'OUTDATED_GENERATION', 'description': 'The content makes claims about a generation that are now factually incorrect due to the passage of time, such as describing millennials as "entering the workforce," "in their 20s," or "recent graduates" when millennials are now in their 30s and 40s.'},
        {'label': 'CURRENT', 'description': 'The content either (a) does not make generational claims, (b) makes claims that remain accurate today, or (c) uses timeless generational descriptions that don''t depend on a specific age range.'},
        {'label': 'UNCLEAR', 'description': 'The content makes generational references but it is unclear whether they are still accurate.'}
    ],
    { 
        'task_description': 'You are reviewing content for a corporate learning catalog. Identify content with OUTDATED generational references.

REFERENCE GUIDE (as of 2025):
- Baby Boomers: Born 1946-1964, currently ages 61-79, mostly retired or retiring
- Gen X: Born 1965-1980, currently ages 45-60, mid-to-late career
- Millennials/Gen Y: Born 1981-1996, currently ages 29-44, established professionals
- Gen Z: Born 1997-2012, currently ages 13-28, entering workforce to early career

OUTDATED PATTERNS TO FLAG:
- "Millennials entering the workforce" or "millennials are job-hopping in their 20s"
- "Gen Z is not yet in the workforce" 
- "Boomers dominating leadership positions" (many have retired)
- References to "Gen Y" (outdated term)
- Any age-specific claim about a generation that conflicts with current reality

CURRENT/ACCEPTABLE PATTERNS:
- Describing generational values or communication preferences without age claims
- Historical framing: "When millennials entered the workforce in the 2010s..."
- Evergreen traits: "Millennials value work-life balance"

Use the publication date to assess: if an article is 10+ years old and makes age-specific generational claims, it is likely outdated.',
        'output_mode': 'single' 
    }
) as GENERATIONAL_REFERENCE
```

#### 3. POPULAR_PERSON

```sql
AI_CLASSIFY(
    'Publication Date: ' || COALESCE(pub_date::VARCHAR, 'Unknown') || 
    ' (This means the article is ' || COALESCE(DATEDIFF('year', pub_date, CURRENT_DATE())::VARCHAR, 'unknown') || ' years old)' ||
    E'\n\nArticle Title: ' || COALESCE(title, '') ||
    E'\n\nAuthor(s): ' || COALESCE(contributor_names, 'Unknown') ||
    E'\n\nContent:\n' || COALESCE(full_text, '') || 
    E'\n\nExecutive Summary:\n' || COALESCE(executive_summary, ''),
    [
        {'label': 'OUTDATED_POPULAR_PERSON', 'description': 'The content features a well-known person in a role or context that is no longer accurate (e.g., referring to someone as CEO who has since left, discussing an athlete''s "current" performance from 10+ years ago, or profiling a leader who has since fallen from prominence).'},
        {'label': 'CURRENT', 'description': 'The content either (a) does not center on a specific famous person, (b) uses historical framing that remains accurate, or (c) discusses the person in a way that doesn''t depend on their current role/status.'},
        {'label': 'UNCLEAR', 'description': 'The content prominently features a known person but it is unclear whether the context remains relevant. Human review recommended.'}
    ],
    { 
        'task_description': 'You are reviewing content for a corporate learning catalog. Identify content where a FAMOUS PERSON is featured in an outdated context.

STEP 1: Identify if the content prominently features a well-known business leader, celebrity, athlete, or public figure (mentioned multiple times OR is central to the article''s thesis).

STEP 2: Assess whether the content depends on that person''s ROLE or STATUS at time of writing:
- "Steve Jobs leads Apple with..." → Depends on his role (he passed away in 2011)
- "Jeff Bezos, CEO of Amazon..." → Depends on his role (he stepped down as CEO in 2021)
- "Lessons from Steve Jobs'' leadership" → Does NOT depend on current role (historical analysis)

STEP 3: Consider whether a 10+ year time gap makes the reference feel dated:
- Sports achievements from 10+ years ago presented as "recent"
- Business case studies about companies that have dramatically changed or failed
- Profiles of leaders who have since been involved in scandals or left their roles

NOTE: Not every mention of a historical figure is outdated. The question is whether the content DEPENDS on the person''s status/role being current.

When uncertain, mark UNCLEAR for human review.',
        'output_mode': 'single' 
    }
) as POPULAR_PERSON
```

#### 4. TECHNOLOGY

```sql
AI_CLASSIFY(
    'Publication Date: ' || COALESCE(pub_date::VARCHAR, 'Unknown') || 
    E'\n\nContent:\n' || COALESCE(full_text, '') || 
    E'\n\nExecutive Summary:\n' || COALESCE(executive_summary, ''),
    [
        {'label': 'OUTDATED_TECHNOLOGY', 'description': 'The content recommends, advocates for, or treats as standard practice a technology that is now obsolete, discontinued, or rarely used in modern business contexts.'},
        {'label': 'CURRENT', 'description': 'The content either (a) does not make technology recommendations, (b) discusses technology historically, or (c) references technology that remains relevant today.'},
        {'label': 'UNCLEAR', 'description': 'The content mentions technology that may or may not be outdated; requires human review.'}
    ],
    { 
        'task_description': 'You are reviewing content for a corporate learning catalog. Identify content that treats OBSOLETE TECHNOLOGY as current best practice.

CLEARLY OBSOLETE (flag as OUTDATED if recommended as current):
- Fax machines for regular business communication
- BlackBerry phones, Palm Pilots, PDAs
- Internet Explorer, Netscape Navigator
- CD-ROMs, DVDs for training/software distribution
- Lotus Notes, Microsoft Office pre-2010
- Polycom (as standalone video conferencing standard)
- On-premises servers (when discussed as the only option)
- Rolodex, paper-based contact management

CONTEXT MATTERS:
- "We used to rely on fax machines" → CURRENT (historical reference)
- "Fax your documents to..." → OUTDATED (presented as standard practice)
- "BlackBerry was once dominant" → CURRENT (historical analysis)
- "Your BlackBerry allows you to..." → OUTDATED (assumes current use)

BORDERLINE (mark UNCLEAR):
- Technologies that are declining but still used in some industries
- Software versions that may or may not still be supported
- Hardware that is old but potentially still functional

Only flag OUTDATED_TECHNOLOGY when the content clearly RECOMMENDS or ASSUMES current use of obsolete tech.',
        'output_mode': 'single' 
    }
) as TECHNOLOGY
```

#### 5. ORG_PRACTICE

```sql
AI_CLASSIFY(
    'Publication Date: ' || COALESCE(pub_date::VARCHAR, 'Unknown') || 
    E'\n\nContent:\n' || COALESCE(full_text, '') || 
    E'\n\nExecutive Summary:\n' || COALESCE(executive_summary, ''),
    [
        {'label': 'OUTDATED_ORG_PRACTICE', 'description': 'The content advocates for organizational practices that are now widely considered outdated, ineffective, or contrary to modern management thinking, without acknowledging contemporary alternatives or nuances.'},
        {'label': 'CURRENT', 'description': 'The content either (a) does not prescribe specific organizational practices, (b) discusses practices historically, (c) presents nuanced views acknowledging different approaches, or (d) advocates practices that remain accepted today.'},
        {'label': 'UNCLEAR', 'description': 'The content discusses organizational practices but it is unclear whether the recommendations are outdated.'}
    ],
    { 
        'task_description': 'You are reviewing content for a corporate learning catalog. Identify content that advocates OUTDATED ORGANIZATIONAL PRACTICES as current best practice.

OUTDATED PRACTICES (flag if presented as THE recommended approach without nuance):
- Annual performance reviews as the ONLY feedback mechanism (vs. continuous feedback)
- Strict command-and-control, top-down hierarchy as IDEAL leadership
- Open-plan offices as UNIVERSALLY productive (without acknowledging drawbacks)
- Mandatory 9-to-5 office presence as essential for productivity
- Strict dress codes as markers of professionalism (without acknowledging flexibility)
- "Face time" in office as primary measure of commitment
- Discouraging remote/hybrid work as inherently inferior

IMPORTANT NUANCES:
- Discussing these practices HISTORICALLY is fine
- Presenting them as ONE option among many is fine
- Acknowledging trade-offs and context is fine
- The issue is UNQUALIFIED advocacy as best practice

EXAMPLES:
- "The best leaders maintain strict hierarchical control" → OUTDATED
- "Hierarchical structures work well in certain contexts, such as..." → CURRENT
- "Employees must be in the office to be productive" → OUTDATED
- "In-person collaboration offers benefits for certain work types" → CURRENT

Be conservative: only flag when the advocacy is clear and unqualified.',
        'output_mode': 'single' 
    }
) as ORG_PRACTICE
```

#### 6. DISCREDITED

```sql
AI_CLASSIFY(
    'Publication Date: ' || COALESCE(pub_date::VARCHAR, 'Unknown') || 
    E'\n\nArticle Title: ' || COALESCE(title, '') ||
    E'\n\nAuthor(s): ' || COALESCE(contributor_names, 'Unknown') ||
    E'\n\nContent:\n' || COALESCE(full_text, '') || 
    E'\n\nExecutive Summary:\n' || COALESCE(executive_summary, ''),
    [
        {'label': 'POTENTIALLY_DISCREDITED', 'description': 'The content prominently features, is authored by, or relies heavily on a person or research that may have been discredited, without acknowledging any controversy. Requires web search verification.'},
        {'label': 'CURRENT', 'description': 'The content does not prominently feature any individuals or research that raise discreditation concerns, OR appropriately acknowledges known controversies.'},
        {'label': 'UNCLEAR', 'description': 'The content features individuals or research that warrant verification but there is no clear indicator of discreditation within the text.'}
    ],
    { 
        'task_description': 'You are reviewing content for a corporate learning catalog. Identify content that may feature DISCREDITED individuals or research.

IMPORTANT LIMITATION: As an AI without web access, you CANNOT definitively determine if someone has been discredited. Your role is to FLAG content that WARRANTS VERIFICATION.

FLAG FOR REVIEW (POTENTIALLY_DISCREDITED or UNCLEAR) if:
1. The article is AUTHORED BY or PROMINENTLY FEATURES a business leader, researcher, or public figure who is:
   - Central to the article''s thesis
   - Presented as an authority or role model
   - Whose reputation could materially affect the article''s credibility

2. The article relies heavily on SPECIFIC RESEARCH STUDIES that:
   - Are central to the article''s conclusions
   - Make strong or controversial claims
   - Come from a single researcher or small team

KNOWN EXAMPLES OF DISCREDITED FIGURES (non-exhaustive):
- Elizabeth Holmes (Theranos fraud)
- Adam Neumann (WeWork controversies)
- Do Kwon (Terraform Labs fraud)
- Sam Bankman-Fried (FTX fraud)
- Various researchers whose studies failed replication

DO NOT FLAG merely because someone is mentioned in passing.

When flagging, note in your reasoning WHO the concerning individual is so human reviewers can verify.',
        'output_mode': 'single' 
    }
) as DISCREDITED
```

### Complete Refined Query

Here is the full query with all refined prompts integrated:

```sql
-- [Keep all CTEs from original query unchanged through final_query]

SELECT
    core_product_id,
    title,
    contributor_names,
    content_category,
    pub_date,
    DATEDIFF('year', pub_date, CURRENT_DATE()) as years_since_publication,
    
    -- 1. PAST_EVENT
    AI_CLASSIFY(
        'Publication Date: ' || COALESCE(pub_date::VARCHAR, 'Unknown') || 
        E'\n\nContent:\n' || LEFT(COALESCE(full_text, ''), 15000) || 
        E'\n\nExecutive Summary:\n' || COALESCE(executive_summary, ''),
        [
            {'label': 'OUTDATED_PAST_EVENT', 'description': 'The content treats a past event (COVID-19 pandemic, 2008 financial crisis, specific recession, natural disaster, etc.) as ongoing or recently happening, using present-tense language like "the current crisis," "in today''s pandemic world," "as we navigate this recession," or "the ongoing lockdowns."'},
            {'label': 'CURRENT', 'description': 'The content either (a) does not mention major historical events, or (b) appropriately frames past events using past tense and historical context.'},
            {'label': 'UNCLEAR', 'description': 'The content mentions a major event but the temporal framing is ambiguous.'}
        ],
        { 
            'task_description': 'Identify content that treats PAST events as if they are CURRENT. Look for present-tense language about concluded events like COVID-19 lockdowns, the 2008 financial crisis, etc. Content published DURING an event that uses present tense is OUTDATED because the event has since ended.',
            'output_mode': 'single' 
        }
    ) as PAST_EVENT,
    
    -- 2. GENERATIONAL_REFERENCE
    AI_CLASSIFY(
        'Publication Date: ' || COALESCE(pub_date::VARCHAR, 'Unknown') || 
        ' (Article is ' || COALESCE(DATEDIFF('year', pub_date, CURRENT_DATE())::VARCHAR, 'unknown') || ' years old)' ||
        E'\n\nContent:\n' || LEFT(COALESCE(full_text, ''), 15000) || 
        E'\n\nExecutive Summary:\n' || COALESCE(executive_summary, ''),
        [
            {'label': 'OUTDATED_GENERATION', 'description': 'The content makes age-specific claims about a generation that are now incorrect (e.g., "millennials entering workforce," "Gen Z not yet working") given current year is 2025.'},
            {'label': 'CURRENT', 'description': 'The content either has no generational claims, uses historical framing, or makes claims that remain accurate.'},
            {'label': 'UNCLEAR', 'description': 'Generational references present but accuracy unclear.'}
        ],
        { 
            'task_description': 'As of 2025: Millennials are 29-44 (established professionals), Gen Z are 13-28 (entering workforce to early career). Flag content saying "millennials entering workforce" or "Gen Z not in workforce" as OUTDATED_GENERATION.',
            'output_mode': 'single' 
        }
    ) as GENERATIONAL_REFERENCE,
    
    -- 3. POPULAR_PERSON
    AI_CLASSIFY(
        'Publication Date: ' || COALESCE(pub_date::VARCHAR, 'Unknown') || 
        ' (Article is ' || COALESCE(DATEDIFF('year', pub_date, CURRENT_DATE())::VARCHAR, 'unknown') || ' years old)' ||
        E'\n\nTitle: ' || COALESCE(title, '') ||
        E'\n\nAuthor(s): ' || COALESCE(contributor_names, 'Unknown') ||
        E'\n\nContent:\n' || LEFT(COALESCE(full_text, ''), 15000) || 
        E'\n\nExecutive Summary:\n' || COALESCE(executive_summary, ''),
        [
            {'label': 'OUTDATED_POPULAR_PERSON', 'description': 'Content features a famous person in a role/context no longer accurate (e.g., someone described as current CEO who has left, or athlete''s "recent" performance from 10+ years ago).'},
            {'label': 'CURRENT', 'description': 'No prominent famous person featured, or the reference uses historical framing that remains accurate.'},
            {'label': 'UNCLEAR', 'description': 'Prominently features a known person; status/role accuracy uncertain.'}
        ],
        { 
            'task_description': 'Flag content that depends on a famous person''s CURRENT role when that role may have changed. "Steve Jobs leads Apple" is outdated (died 2011). "Lessons from Steve Jobs" is fine (historical). Consider the 10+ year threshold.',
            'output_mode': 'single' 
        }
    ) as POPULAR_PERSON,
    
    -- 4. TECHNOLOGY
    AI_CLASSIFY(
        'Publication Date: ' || COALESCE(pub_date::VARCHAR, 'Unknown') || 
        E'\n\nContent:\n' || LEFT(COALESCE(full_text, ''), 15000) || 
        E'\n\nExecutive Summary:\n' || COALESCE(executive_summary, ''),
        [
            {'label': 'OUTDATED_TECHNOLOGY', 'description': 'Content recommends or assumes current use of obsolete tech: fax machines, BlackBerry, Palm Pilots, Internet Explorer, CD-ROMs, Lotus Notes, Polycom as standard.'},
            {'label': 'CURRENT', 'description': 'No tech recommendations, historical tech discussion, or references tech still relevant today.'},
            {'label': 'UNCLEAR', 'description': 'Mentions technology that may or may not be outdated.'}
        ],
        { 
            'task_description': 'Flag content RECOMMENDING obsolete technology as current practice. "Fax your documents to..." is OUTDATED. "We used to rely on fax" is CURRENT (historical). Only flag when the content assumes current use.',
            'output_mode': 'single' 
        }
    ) as TECHNOLOGY,
    
    -- 5. ORG_PRACTICE
    AI_CLASSIFY(
        'Publication Date: ' || COALESCE(pub_date::VARCHAR, 'Unknown') || 
        E'\n\nContent:\n' || LEFT(COALESCE(full_text, ''), 15000) || 
        E'\n\nExecutive Summary:\n' || COALESCE(executive_summary, ''),
        [
            {'label': 'OUTDATED_ORG_PRACTICE', 'description': 'Content advocates outdated practices WITHOUT nuance: annual reviews as ONLY feedback, strict hierarchy as IDEAL, mandatory office presence as essential, open offices as universally good.'},
            {'label': 'CURRENT', 'description': 'No practice recommendations, discusses practices historically, presents nuanced views, or advocates still-accepted practices.'},
            {'label': 'UNCLEAR', 'description': 'Discusses organizational practices but outdatedness unclear.'}
        ],
        { 
            'task_description': 'Flag UNQUALIFIED advocacy for outdated practices. "Employees must be in office to be productive" is OUTDATED. "In-person work benefits some tasks" is CURRENT (nuanced). Only flag when advocacy is clear and absolute.',
            'output_mode': 'single' 
        }
    ) as ORG_PRACTICE,
    
    -- 6. DISCREDITED
    AI_CLASSIFY(
        'Publication Date: ' || COALESCE(pub_date::VARCHAR, 'Unknown') || 
        E'\n\nTitle: ' || COALESCE(title, '') ||
        E'\n\nAuthor(s): ' || COALESCE(contributor_names, 'Unknown') ||
        E'\n\nContent:\n' || LEFT(COALESCE(full_text, ''), 15000) || 
        E'\n\nExecutive Summary:\n' || COALESCE(executive_summary, ''),
        [
            {'label': 'POTENTIALLY_DISCREDITED', 'description': 'Content is authored by or prominently features someone who may be discredited (known examples: Elizabeth Holmes, Adam Neumann, Do Kwon, Sam Bankman-Fried). Requires web verification.'},
            {'label': 'CURRENT', 'description': 'No discreditation concerns or appropriately acknowledges controversies.'},
            {'label': 'UNCLEAR', 'description': 'Features individuals who warrant verification.'}
        ],
        { 
            'task_description': 'FLAG content that may feature discredited individuals. You cannot verify discreditation without web search, so flag anything featuring prominent business leaders, researchers, or public figures whose reputation could affect credibility. Note WHO the concerning individual is.',
            'output_mode': 'single' 
        }
    ) as DISCREDITED,
    
    cl_views_FY25_to_present,
    potential_blog_post,
    hbr_essentials
FROM
    final_query
ORDER BY
    content_category,
    core_product_id;
```

---

## 2. Copilot Studio Setup Guide

### What is Copilot Studio?

Microsoft Copilot Studio (formerly Power Virtual Agents) is a low-code platform for building AI agents. The key advantage for your project is the built-in **Bing Search** capability, which gives the agent access to current web information.

### Prerequisites

Before you start:
1. A Microsoft 365 work account (check with HBP IT if you need access)
2. Access to Copilot Studio (usually at https://copilotstudio.microsoft.com)
3. Appropriate licenses (your IT department should be able to provision this)

### Step-by-Step Setup

#### Step 1: Access Copilot Studio

1. Go to https://copilotstudio.microsoft.com
2. Sign in with your HBP Microsoft account
3. You should see the Copilot Studio home page

If you get an error, contact IT — you may need a license assigned.

#### Step 2: Create a New Copilot

1. Click **"Create"** in the left navigation
2. Select **"New copilot"**
3. Give it a name: `HBP Catalog Content Reviewer`
4. Add a description: `Reviews HBP catalog content to identify outdated articles and podcasts based on defined criteria`
5. Select your language (English)
6. Click **"Create"**

#### Step 3: Configure Knowledge Sources (Bing Search)

This is the key differentiator from Snowflake — enabling web grounding.

1. In your new copilot, go to **"Knowledge"** in the left panel
2. Click **"Add knowledge"**
3. Select **"Public websites"** (this enables Bing search)
4. Toggle ON **"Allow the copilot to search public websites"**
5. Optionally, you can add specific trusted sources:
   - Wikipedia (for verifying people/events)
   - Major news sites
   - SEC.gov (for corporate leadership verification)

#### Step 4: Create the Classification Topic

Topics are the conversational flows in Copilot Studio. You'll create one topic that handles the content review.

1. Go to **"Topics"** in the left panel
2. Click **"+ New topic"** → **"From blank"**
3. Name it: `Review Content for Outdated Criteria`
4. Add trigger phrases:
   - "Review this content"
   - "Check if this article is outdated"
   - "Analyze content for removal"

#### Step 5: Build the Topic Flow

In the topic editor, you'll build a flow that:
1. Receives content (title, text, publication date, authors)
2. Analyzes against each criterion
3. Returns structured results

**5a. Add Input Variables**

Click **"+ Add node"** → **"Ask a question"**

Create input questions for:
- `ContentTitle` (text)
- `PublicationDate` (text)
- `Authors` (text)  
- `ContentText` (text - this will be long)

**5b. Add the Analysis Node**

Click **"+ Add node"** → **"Call an action"** → **"Create a prompt"**

Create a prompt called `AnalyzeContent` with this structure:

```
You are a content reviewer for Harvard Business Publishing's corporate learning catalog. Your task is to analyze the following content and determine if it should be flagged for removal based on specific criteria.

**CONTENT TO REVIEW:**
- Title: {ContentTitle}
- Publication Date: {PublicationDate}
- Authors: {Authors}
- Full Text: {ContentText}

**TODAY'S DATE:** [Current date will be injected]

**YOUR TASK:**
Analyze this content against each of the 6 criteria below. For each criterion, respond with:
- OUTDATED: Clear evidence the content meets the removal criteria
- CURRENT: Content does not meet the removal criteria
- UNCLEAR: Cannot determine; needs human review

USE WEB SEARCH to verify current facts when needed (especially for criteria 3, 4, and 6).

---

**CRITERION 1: PAST_EVENT**
Does the content treat a past event (COVID-19, 2008 financial crisis, etc.) as if it is currently happening?
- Look for present-tense language about events that have ended
- Consider that content written DURING an event may now be outdated

[Search the web if needed to confirm whether referenced events have concluded]

Assessment: [OUTDATED/CURRENT/UNCLEAR]
Reasoning: [Brief explanation]

---

**CRITERION 2: GENERATIONAL_REFERENCE**  
Does the content make age-specific claims about generations that are no longer accurate?
- As of 2025: Millennials are 29-44, Gen Z are 13-28
- Flag claims like "millennials entering the workforce" or "Gen Z not yet working"

Assessment: [OUTDATED/CURRENT/UNCLEAR]
Reasoning: [Brief explanation]

---

**CRITERION 3: POPULAR_PERSON**
Does the content feature a famous person in a role/context that is no longer accurate?
- Examples: Describing someone as current CEO who has left, athlete's "recent" performance from 10+ years ago

[SEARCH THE WEB to verify the current status of any prominently featured individuals]

Assessment: [OUTDATED/CURRENT/UNCLEAR]
Reasoning: [Brief explanation, noting who was searched and what was found]

---

**CRITERION 4: TECHNOLOGY**
Does the content recommend or assume current use of obsolete technology?
- Clearly obsolete: fax machines (for regular use), BlackBerry, Palm Pilots, Internet Explorer, CD-ROMs, Lotus Notes
- Historical references are fine; only flag if presented as current best practice

[Search the web if uncertain whether a technology is still in use]

Assessment: [OUTDATED/CURRENT/UNCLEAR]
Reasoning: [Brief explanation]

---

**CRITERION 5: ORG_PRACTICE**
Does the content advocate outdated organizational practices without nuance?
- Examples: Annual reviews as the ONLY feedback method, mandatory office presence as essential, strict hierarchy as ideal
- Nuanced discussion or historical references are fine

Assessment: [OUTDATED/CURRENT/UNCLEAR]
Reasoning: [Brief explanation]

---

**CRITERION 6: DISCREDITED**
Is the content authored by, or does it prominently feature, anyone who has been discredited?

[SEARCH THE WEB for: "{Authors}" AND (fraud OR scandal OR convicted OR discredited)]
[Also search for any other prominently featured business leaders or researchers mentioned in the content]

Assessment: [OUTDATED/CURRENT/UNCLEAR]
Reasoning: [Brief explanation, noting who was searched and what was found]

---

**SUMMARY:**
- PAST_EVENT: [OUTDATED/CURRENT/UNCLEAR]
- GENERATIONAL_REFERENCE: [OUTDATED/CURRENT/UNCLEAR]
- POPULAR_PERSON: [OUTDATED/CURRENT/UNCLEAR]
- TECHNOLOGY: [OUTDATED/CURRENT/UNCLEAR]
- ORG_PRACTICE: [OUTDATED/CURRENT/UNCLEAR]
- DISCREDITED: [OUTDATED/CURRENT/UNCLEAR]

Overall Recommendation: [REMOVE / KEEP / HUMAN_REVIEW]
```

**5c. Enable Web Search for the Prompt**

In the prompt settings:
1. Look for **"Knowledge"** or **"Search"** settings
2. Enable **"Allow searching public websites"**
3. This allows the prompt to use Bing during execution

#### Step 6: Configure Output

Add a **"Send a message"** node that formats the output:

```
## Content Review Results

**Title:** {ContentTitle}
**Publication Date:** {PublicationDate}

### Assessment Summary
{AnalyzeContent.output}

---
Review completed. See detailed reasoning above for each criterion.
```

#### Step 7: Test Your Copilot

1. Click **"Test"** in the top right
2. Start a conversation with "Review this content"
3. Provide test content from your 50-row dataset
4. Verify:
   - Web searches are being triggered (you should see search citations)
   - All 6 criteria are being assessed
   - Output is structured and parseable

#### Step 8: Create a Batch Processing Flow (Advanced)

For running all 50 test items, you have two options:

**Option A: Manual Testing**
Run each item through the test interface, copy results to your evaluation spreadsheet.

**Option B: Power Automate Integration**
1. Publish your copilot
2. Create a Power Automate flow that:
   - Reads from an Excel file or SharePoint list with your test data
   - Calls the copilot for each row
   - Writes results back

For the initial comparison, Option A is probably sufficient. You can automate later if Copilot proves to be the better solution.

### Copilot Studio Tips

1. **Token limits**: Copilot Studio has limits on input/output length. If full article text is too long, you may need to truncate or summarize first.

2. **Web search quotas**: There may be limits on how many web searches per conversation. Test to understand the constraints.

3. **Latency**: Web-grounded responses take longer. Budget ~30-60 seconds per content item vs. near-instant for Snowflake.

4. **Cost**: Check with IT about Copilot Studio costs. There may be per-conversation charges.

5. **Versioning**: Save versions of your copilot as you iterate so you can roll back if needed.

---

## 3. Evaluation Schema

### Evaluation Goals

Your comparison needs to answer:

1. **Does web grounding (Copilot) improve detection accuracy over non-grounded (Snowflake)?**
2. **Which specific criteria benefit most from web grounding?**
3. **What are the tradeoffs (cost, speed, complexity)?**

### Metrics Framework

#### Primary Metrics (Per Category)

| Metric | Definition | Why It Matters |
|--------|------------|----------------|
| **Recall** | TP / (TP + FN) | Of the truly outdated items, how many did we catch? This is your primary metric — you want to minimize missed outdated content. |
| **Precision** | TP / (TP + FP) | Of the items we flagged, how many were truly outdated? Important for reviewer workload. |
| **F1 Score** | 2 * (P * R) / (P + R) | Balanced measure combining precision and recall. |

Where:
- TP (True Positive) = System said OUTDATED, ground truth is Y
- FP (False Positive) = System said OUTDATED, ground truth is N  
- FN (False Negative) = System said CURRENT/UNCLEAR, ground truth is Y
- TN (True Negative) = System said CURRENT, ground truth is N

#### Secondary Metrics

| Metric | Definition |
|--------|------------|
| **UNCLEAR Rate** | % of responses that are UNCLEAR (measures model confidence) |
| **Latency** | Time per item (seconds) |
| **Cost** | Estimated cost per item (if applicable) |

### Evaluation Spreadsheet Template

Create a spreadsheet with these columns:

| Column | Description |
|--------|-------------|
| core_product_id | Unique identifier |
| title | Content title |
| pub_date | Publication date |
| content_category | Article/Podcast/etc. |
| **Ground Truth Columns** | |
| GT_PAST_EVENT | Y/N from labeled dataset |
| GT_GENERATION | Y/N from labeled dataset |
| GT_POPULAR_PERSON | Y/N from labeled dataset |
| GT_TECHNOLOGY | Y/N from labeled dataset |
| GT_ORG_PRACTICE | Y/N from labeled dataset |
| GT_DISCREDITED | Y/N from labeled dataset |
| **Snowflake Results** | |
| SF_PAST_EVENT | OUTDATED/CURRENT/UNCLEAR |
| SF_GENERATION | OUTDATED/CURRENT/UNCLEAR |
| SF_POPULAR_PERSON | OUTDATED/CURRENT/UNCLEAR |
| SF_TECHNOLOGY | OUTDATED/CURRENT/UNCLEAR |
| SF_ORG_PRACTICE | OUTDATED/CURRENT/UNCLEAR |
| SF_DISCREDITED | OUTDATED/CURRENT/UNCLEAR |
| SF_latency_sec | Time to process |
| **Copilot Results** | |
| CP_PAST_EVENT | OUTDATED/CURRENT/UNCLEAR |
| CP_GENERATION | OUTDATED/CURRENT/UNCLEAR |
| CP_POPULAR_PERSON | OUTDATED/CURRENT/UNCLEAR |
| CP_TECHNOLOGY | OUTDATED/CURRENT/UNCLEAR |
| CP_ORG_PRACTICE | OUTDATED/CURRENT/UNCLEAR |
| CP_DISCREDITED | OUTDATED/CURRENT/UNCLEAR |
| CP_latency_sec | Time to process |
| CP_web_searches | Number of web searches triggered |
| **Computed Columns** | |
| SF_[criterion]_correct | 1 if SF matches GT, 0 otherwise |
| CP_[criterion]_correct | 1 if CP matches GT, 0 otherwise |

### Scoring Logic

For each criterion, map predictions to binary:
- OUTDATED → Predicted Positive (1)
- CURRENT → Predicted Negative (0)
- UNCLEAR → Treat as Negative OR exclude from calculation (document your choice)

Ground truth:
- Y → Actual Positive (1)
- N → Actual Negative (0)

### Results Summary Table

After running both systems, compute this summary:

| Criterion | Web Grounding Helps? | Snowflake Recall | Copilot Recall | Snowflake Precision | Copilot Precision |
|-----------|---------------------|------------------|----------------|---------------------|-------------------|
| PAST_EVENT | Possibly | ? | ? | ? | ? |
| GENERATION | Unlikely | ? | ? | ? | ? |
| POPULAR_PERSON | **Yes** | ? | ? | ? | ? |
| TECHNOLOGY | **Possibly** | ? | ? | ? | ? |
| ORG_PRACTICE | Unlikely | ? | ? | ? | ? |
| DISCREDITED | **Yes** | ? | ? | ? | ? |

### Hypothesis: Where Web Grounding Should Help Most

Based on the criteria definitions:

**High impact expected:**
- `POPULAR_PERSON`: Requires knowing if someone is still in a role (Bezos left Amazon CEO, etc.)
- `DISCREDITED`: Requires knowing if someone was charged/convicted/scandalized after the article was written

**Medium impact expected:**
- `TECHNOLOGY`: Some tech requires verification (is X still used?), but many obsolete items are well-known
- `PAST_EVENT`: Mostly detectable from text + pub date, but edge cases may benefit

**Low impact expected:**
- `GENERATION`: Math-based on publication date, no external knowledge needed
- `ORG_PRACTICE`: Subjective assessment of practice advocacy, web search unlikely to help

### Statistical Considerations

With only 50 items and class imbalance (mostly N), be cautious about:

1. **Small sample effects**: Differences may not be statistically significant
2. **Per-category samples**: If only 3 items are Y for DISCREDITED, you can't draw strong conclusions
3. **Confidence intervals**: Report ranges, not just point estimates

Consider using:
- McNemar's test to compare paired predictions
- Bootstrap confidence intervals for metrics
- Exact binomial CIs for small counts

### Decision Framework

After evaluation, use this framework to decide:

| Scenario | Recommendation |
|----------|---------------|
| Copilot significantly better on web-grounded criteria (3, 4, 6), similar elsewhere | Use Copilot for full pipeline OR use hybrid (Copilot for 3,4,6 only) |
| Copilot marginally better but much slower/costlier | Stick with Snowflake, accept some false negatives |
| Both perform poorly | Revisit prompts, consider fine-tuning, or accept higher human review burden |
| Snowflake sufficient across all criteria | Stick with Snowflake (simpler, integrated) |

---

## Appendix: Quick Reference

### Key Contacts (from your notes)
- Aaron Kaplan: Data asset locations and specifics
- Kathryn Leeber: BAM team coordination for removals
- Malorie Hughes: AI agent collaboration

### Timeline
- Infrastructure comparison: ~2 weeks
- Identify outdated assets: End of Q3 (end of March)

### Important Thresholds
- "Outdated" time threshold: 10+ years
- View threshold (pre-2016 content): 0-10 views in last 12 months triggers removal consideration
- Blog post auto-remove: Product type 189, published 2007-01-01 to 2014-10-31

### File Locations
- Test dataset: [Get from team]
- Snowflake data: `analytics.pim.fct_pim_data_merge`
- Article text: `analytics.article_archive.base_articles_parsed`
- Podcast transcripts: `analytics.article_archive.base_podcasts_parsed`
