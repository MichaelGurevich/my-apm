---
name: to-idea
description: "Turn the current ideation conversation into an idea brief saved as a Markdown file: no interview, just synthesis of what you've already discussed."
disable-model-invocation: true
---

Take the current conversation and write it up as an idea brief. Do NOT interview me; just synthesize what we've discussed, in my words where you can. Leave out technical detail except under "Parked for grill-me".

Save it to `.scratch/<idea-slug>/idea.md`, then suggest `/grill-me` as the next step.

<idea-template>

# <Idea name>

## Idea

One or two sentences anyone could repeat.

## Goal

What the idea is for, and what success looks like.

## How it works

The idea described from the outside, as someone would experience it.

## Scope

- **In the first version:** ...
- **Left out:** ...

## Constraints

## Open questions

## Parked for grill-me

Technical points raised during ideation, one line each.

</idea-template>
