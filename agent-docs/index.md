# Commonware Documentation Index

Welcome to the Commonware documentation. This index serves as a retrieval map for the project primitives, architecture, and workflows.

## Project Overview
- [Project Overview](overview/project-overview.md): High-level introduction to Commonware's goals and philosophy.
- [Coding Conventions](reference/coding-conventions.md): Standards for Rust code, naming, and error handling.
- [Git Conventions](reference/git-conventions.md): Guidelines for commits, branching, and pull requests.

## Core Primitives
- [Common Invariants](architecture/invariants.md): System-wide guarantees and safety properties.
- [Specifications](reference/specs.md): Collection of technical specifications for primitives.

## Runtime and Testing
- [Runtime Architecture](architecture/runtime.md): Abstract runtime design and isolation from platform-specific I/O.
- [Simulation Framework](architecture/simulation.md): Deterministic testing and network simulation.
- [Testing Guide](guides/testing.md): Best practices for writing unit, integration, and deterministic tests.

## P2P and Networking
- [P2P Overview](architecture/p2p-overview.md): Authenticated, encrypted peer-to-peer communication.
- [P2P Protocols](guides/p2p-protocols.md): Guide to implementing and using P2P communication channels.
- [Handshake Design](architecture/handshake.md): Secure identity verification and connection establishment.
- [Handshake Workflow](guides/handshake-workflow.md): Step-by-step connection process.

## Consensus
- [Simplex Safety](architecture/simplex-safety.md): Formal safety properties of the Simplex consensus mechanism.
- [Quorum Certificates](architecture/simplex-qc.md): Design and verification of consensus proofs.
- [State Transitions](architecture/simplex-transitions.md): How the consensus state machine evolves.

## Storage
- [Storage Overview](architecture/storage-overview.md): Abstract storage traits and persistence strategies.
- [Storage Traits](reference/storage-traits.md): Reference for implementing custom storage backends.
- [Journal Usage](guides/journal-usage.md): Append-only logging and recovery for consensus state.
- [QMDB Design](architecture/qmdb-design.md): Design of the Quorum-based Merkle Database.
- [QMDB Usage](guides/qmdb-usage.md): Storing and verifying authenticated data.

## Cryptography
- [Cryptography Architecture](architecture/cryptography.md): Key generation, signing, and deterministic verification.
- [Secure Connections](guides/secure-connections.md): Using cryptographic primitives for transport security.

## Codec
- [Codec and Formats](architecture/codec-and-formats.md): Design of serialization and structured data handling.
- [Implementing Codecs](guides/implementing-codecs.md): Practical guide for adding Encode and Decode to types.
- [Wire Formats](reference/wire-formats.md): Specifications for on-wire data representations.

## Stream
- [Stream Layer](architecture/stream-layer.md): Message-oriented transport over arbitrary streams.
- [Stream Composition](architecture/stream-composition.md): Layering security and reliability on raw transports.
- [Stream Specification](reference/stream-spec.md): Technical details of the stream protocol.

## Conformance
- [Conformance Overview](overview/conformance.md): System for asserting stability of encoding and mechanisms.
- [Conformance System](architecture/conformance-system.md): Internal design of the conformance testing suite.
- [Conformance Workflow](guides/conformance-workflow.md): How to add and run conformance tests.
- [Conformance Specification](reference/conformance-spec.md): Rules for fixture generation and hashing.

## Fuzzing
- [Fuzzing Architecture](architecture/fuzzing.md): Integration with cargo-fuzz for adversarial input testing.
- [Fuzzing Workflow](guides/fuzzing_workflow.md): Running and triaging fuzz tests.
- [Fuzzing Commands](reference/fuzzing_commands.md): Quick reference for common fuzzing operations.

## Docs and MCP
- [Docs Mirror](architecture/docs-mirror.md): Strategy for synchronizing code and documentation.
- [Docs Workflow](guides/docs-workflow.md): Maintaining the agent-docs system.
- [Docs Specification](reference/docs-spec.md): Standards for documentation structure and metadata.
- [MCP Server](architecture/mcp-server.md): Model Context Protocol server for LLM integration.
- [MCP Workflow](guides/mcp-workflow.md): Using MCP to interact with Commonware primitives.
- [MCP API](reference/mcp-api.md): Reference for available MCP tools and resources.

## Deployer
- [Deployer Overview](overview/deployer.md): Automated infrastructure deployment for distributed systems.
- [Deployer Internals](architecture/deployer-internals.md): Design of the cloud provider abstraction layer.
- [Deployment Workflow](guides/deployment-workflow.md): Deploying clusters to AWS with the deployer CLI.
- [Deployer Configuration](reference/deployer-config.md): Schema for deployment manifests.
