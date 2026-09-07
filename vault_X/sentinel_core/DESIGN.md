---
name: Sentinel Core
colors:
  surface: '#101415'
  surface-dim: '#101415'
  surface-bright: '#363a3b'
  surface-container-lowest: '#0b0f10'
  surface-container-low: '#191c1e'
  surface-container: '#1d2022'
  surface-container-high: '#272a2c'
  surface-container-highest: '#323537'
  on-surface: '#e0e3e5'
  on-surface-variant: '#c6c6cd'
  inverse-surface: '#e0e3e5'
  inverse-on-surface: '#2d3133'
  outline: '#909097'
  outline-variant: '#45464d'
  surface-tint: '#bec6e0'
  primary: '#bec6e0'
  on-primary: '#283044'
  primary-container: '#0f172a'
  on-primary-container: '#798098'
  inverse-primary: '#565e74'
  secondary: '#a9c7ff'
  on-secondary: '#003063'
  secondary-container: '#3c90ff'
  on-secondary-container: '#002957'
  tertiary: '#b7c8e1'
  on-tertiary: '#213145'
  tertiary-container: '#06182b'
  on-tertiary-container: '#728299'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#dae2fd'
  primary-fixed-dim: '#bec6e0'
  on-primary-fixed: '#131b2e'
  on-primary-fixed-variant: '#3f465c'
  secondary-fixed: '#d6e3ff'
  secondary-fixed-dim: '#a9c7ff'
  on-secondary-fixed: '#001b3d'
  on-secondary-fixed-variant: '#00468c'
  tertiary-fixed: '#d3e4fe'
  tertiary-fixed-dim: '#b7c8e1'
  on-tertiary-fixed: '#0b1c30'
  on-tertiary-fixed-variant: '#38485d'
  background: '#101415'
  on-background: '#e0e3e5'
  surface-variant: '#323537'
typography:
  headline-xl:
    fontFamily: Hanken Grotesk
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-mono:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  button:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  container-max: 1200px
  gutter: 20px
---

## Brand & Style

The design system is engineered for a secure, professional, and trustworthy offline password manager. The brand personality is rooted in **Modern Corporate** aesthetics with a lean toward **Minimalism**, emphasizing stability, privacy, and precision. 

The UI must evoke an immediate sense of "digital vault" robustness without feeling dated or overly complex. We achieve this through:
- **Clean Interfaces:** High whitespace to reduce cognitive load during sensitive tasks.
- **High-Fidelity Finishes:** Subtle gradients and micro-interactions that suggest a premium, well-maintained codebase.
- **Professionalism:** A serious, utilitarian approach where every pixel serves a functional purpose, eschewing decorative fluff for structural clarity.

## Colors

The palette utilizes a "Deep Tech" foundation to reinforce security and eye comfort for long-term use.

- **Primary (Deep Navy):** `#0F172A` - Used for the main backgrounds and primary structural elements to provide a grounded, high-contrast environment.
- **Secondary (Vibrant Blue):** `#0084ff` - Used exclusively for primary action buttons, links, and active indicators. It symbolizes clear communication and trusted digital interactions.
- **Tertiary (Slate Gray):** `#64748B` - Used for secondary text, borders, and inactive states. It provides a sophisticated bridge between the dark background and light content.
- **Functional Accents:**
    - **Warning/Danger:** `#EF4444` (Rose Red) for master password deletion or compromised password alerts.
    - **Surface Levels:** `#1E293B` for cards and modals to create depth against the primary navy.

## Typography

The typography strategy balances modern professionalism with technical precision. 

- **Hanken Grotesk** is used for headlines to provide a sharp, contemporary feel that distinguishes the app from standard system utilities.
- **Inter** is the workhorse for all body copy and UI controls, chosen for its exceptional legibility and neutral, trustworthy tone.
- **JetBrains Mono** is utilized for passwords, recovery keys, and masked data strings. Its monospaced nature ensures that characters like '1', 'l', and 'I' are easily distinguishable, which is critical for security.

For mobile layouts, use `headline-lg-mobile` to prevent text wrapping issues on smaller screens. Maintain high contrast (White on Navy) for all primary reading paths.

## Layout & Spacing

This design system uses a **Fixed Grid** model for desktop to maintain a compact, "dashboard" feel, and a **Fluid Grid** for mobile to maximize reachability.

- **Grid:** A 12-column grid on desktop with a 1200px max-width container. 
- **Rhythm:** A 4px baseline grid governs all vertical spacing. Elements should almost always use `md` (16px) or `lg` (24px) padding to maintain an airy, professional feel.
- **Mobile:** Transition to a 4-column grid with 16px margins.
- **Information Density:** For password lists, use "Comfortable" vertical padding (16px) by default, with a "Compact" toggle (8px) for power users managing hundreds of entries.

## Elevation & Depth

The design system utilizes **Tonal Layers** combined with **Low-contrast outlines** to define hierarchy, avoiding heavy shadows which can feel cluttered.

1.  **Level 0 (Base):** Primary Navy (`#0F172A`).
2.  **Level 1 (Surface):** Slate Surface (`#1E293B`). Used for list items and cards.
3.  **Level 2 (Elevated):** Lighter Slate (`#334155`). Used for hover states and active inputs.
4.  **Overlays:** Modals use a backdrop blur (12px) to focus the user on the security task at hand, with a subtle 1px border (`#475569`) to define the container edge. 

Shadows, if used, should be extremely subtle: `0 4px 6px -1px rgba(0, 0, 0, 0.3)`.

## Shapes

The shape language is **Rounded (0.5rem base)**, reflecting an updated, approachable balance that softens the strict security boundaries without sacrificing modern precision.

- **Standard Elements:** Buttons, Input fields, and Checkboxes use `rounded` (8px).
- **Containers:** Cards and Modals use `rounded-lg` (16px).
- **Indicators:** Small status dots or security strength meters use `rounded-full` to stand out as organic elements within a structured grid.

## Components

- **Buttons:** Primary buttons use the Vibrant Blue background with White text. Secondary buttons use a Slate outline. Ensure a minimum touch target of 44px.
- **Input Fields:** Fields use a dark background (`#020617`) with a 1px Slate border. On focus, the border transitions to Vibrant Blue with a subtle outer glow.
- **Security Strength Meter:** A multi-segmented bar (4 segments) that transitions from Red to Vibrant Blue as password complexity increases.
- **Cards:** Used for individual password entries. Include a sharp, consistent icon on the left (e.g., brand logos or generic category icons) and "Copy" actions on the right that appear on hover/tap.
- **Chips:** Used for tagging entries (e.g., "Work", "Personal"). These should be low-contrast (Slate background) to avoid competing with primary action buttons.
- **Lists:** Password lists should be clean with subtle dividers (`#1E293B`). Use `label-mono` for the "Username" preview to distinguish it from the Site Name.
- **Icons:** Use 24px line icons with a 2px stroke weight. Icons must be sharp, monochrome (Slate-300), and only turn Vibrant Blue when active or successful.