# Product Overview

## Project Purpose
Crossword Master is a Flutter-based crossword puzzle game supporting both solo (vs AI) and local-network multiplayer modes. Players place letters from a hand of tiles onto a crossword grid to complete words and score points.

## Key Features
- **Solo mode**: Play against an AI opponent with configurable think time
- **Local Wi-Fi multiplayer**: Host or join rooms over the same network using WebSocket (host:port share code)
- **Turn-based gameplay**: Players alternate placing letters; passing and swapping letters are also valid moves
- **Scoring**: Points per letter placed + word-length bonus when a word is completed
- **Google Sign-In**: Optional authentication for profile/leaderboard features
- **Animated UI**: Slide transitions between screens, tap-bounce and animated card widgets
- **Cross-platform**: Targets iOS, Android, Web, macOS, Linux, and Windows

## Target Users
Casual word-game players who want a crossword experience with a friend on the same Wi-Fi network, or solo practice against an AI.

## Core Use Cases
1. Launch app → tap Solo Play → fill crossword grid against AI
2. Launch app → tap Multiplayer → host a room, share code with friend on same Wi-Fi → play turn-based
3. Sign in with Google → view profile and leaderboard scores
