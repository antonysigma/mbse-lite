# MBSE-lite architecture decisions

> [!NOTE]
> This document records the design philosophy behind MBSE-lite so future sessions do not need to recover it from prior interactive transcripts of large language models (LLMs), such as Cursor CLI or Codex CLI.

## What MBSE-lite optimizes for

MBSE-lite is intentionally not a full SysML or Arcadia workbench.

It optimizes for:

- text-editable design inputs
- explicit requirement traceability
- simple schemas that validate quickly
- architecture and behavior described in terms that engineers can revise in ordinary editors
- documents that are easy to regenerate for review meetings

The project deliberately favors clarity over exhaustive modeling power.

## First-class concepts

The first-class concepts in MBSE-lite are:

- stakeholder needs
- use cases
- system requirements
- functions and behaviors
- verification plans
- interfaces

Notably, MBSE-lite does **not** make component instances first-class XML objects. Components may appear in diagrams, but the schema fundamentally tracks interfaces and functions more than object identity.

## Interface/function-first modeling

The modeling style is intentionally interface-oriented and function-oriented.

That means:

- describe what a function does and what signals it consumes or produces
- describe what an interface carries between parts of the system
- prefer explicit input/output/control/resource declarations
- avoid over-modeling internal instance hierarchies when they do not improve engineering decisions

This is closer in spirit to:

- functional decomposition
- task-graph thinking
- strongly typed data flow
- array-oriented and transform-oriented software design

than to:

- Java-style object hierarchies
- heavy instance modeling
- method-centric decomposition around mutable objects

An engineer familiar with lambda-based task graphs, captured data flow, or array-oriented programming should see the intended analogy: the important thing is the transformation and the interface contract, not the persistence of a deep object graph.

## Why simplify richer MBSE tools

Tools such as Arcadia/Capella and SysML often introduce:

- specialized components for interface mediation
- explicit ports and delegations
- instance-heavy decomposition
- multiple abstraction layers for similar signals

MBSE-lite treats much of that as unnecessary overhead for medium-scale projects.

When importing from those tools:

- preserve the engineering intent
- keep the traceability
- simplify the representation

For example, if a richer model represents:

- a human-machine interaction component
- a machine-machine interaction component
- several port-to-port exchanges

MBSE-lite may collapse that into:

- a `User controls` interface
- a `Radio channel input`
- an `Audio signal`

if those simpler interfaces communicate the same design intent more clearly.

## Functional behavior and custom IDEF0

MBSE-lite supports a custom text syntax for IDEF0-like functional diagrams.

The point is not to preserve standard IDEF0 tooling purity. The point is to make function flow editable in plain XML with explicit signals:

- `in`: signal input
- `out`: signal output
- `ctrl`: control mechanisms, e.g. algorithms
- `res`: resources, e.g. software configurations, algorithm parameters, constants

This reinforces the project’s bias toward explicit data and control flow over object-centered modeling.

## Relationship to Kass 2016 and related MBSE simplification work

The schema and workflow are inspired by the MBSE product-development framing described by Nichole Kass and related simplification efforts around functional analysis and model instances.

The important philosophical inheritance is:

- stakeholder needs
- system problems
- solution structure
- traceability among them

MBSE-lite keeps that backbone while intentionally dropping many heavier tool concepts that are not essential for the target scale of work.

## Practical reading rule

When deciding between preserving a source model literally and simplifying it for MBSE-lite, prefer:

1. requirement traceability
2. explicit functional signals
3. interface clarity
4. straightforward wording

over fidelity to instance-heavy modeling conventions from the source tool.
