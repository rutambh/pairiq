---
name: Pair IQ v2.0
colors:
  surface: '#16213E'
  surface-dim: '#11131e'
  surface-bright: '#373845'
  surface-container-lowest: '#0c0d19'
  surface-container-low: '#191b27'
  surface-container: '#1d1f2b'
  surface-container-high: '#282936'
  surface-container-highest: '#333441'
  on-surface: '#e2e1f2'
  on-surface-variant: '#e2bebf'
  inverse-surface: '#e2e1f2'
  inverse-on-surface: '#2e303c'
  outline: '#a9898a'
  outline-variant: '#5a4042'
  surface-tint: '#ffb2b7'
  primary: '#ffb2b7'
  on-primary: '#67001c'
  primary-container: '#fc536d'
  on-primary-container: '#5b0017'
  inverse-primary: '#b71d3f'
  secondary: '#ffb2b9'
  on-secondary: '#67001e'
  secondary-container: '#8f1533'
  on-secondary-container: '#ff9da7'
  tertiary: '#e9c400'
  on-tertiary: '#3a3000'
  tertiary-container: '#c9a900'
  on-tertiary-container: '#4c3f00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdadb'
  primary-fixed-dim: '#ffb2b7'
  on-primary-fixed: '#40000e'
  on-primary-fixed-variant: '#91002b'
  secondary-fixed: '#ffdadc'
  secondary-fixed-dim: '#ffb2b9'
  on-secondary-fixed: '#400010'
  on-secondary-fixed-variant: '#8c1231'
  tertiary-fixed: '#ffe16d'
  tertiary-fixed-dim: '#e9c400'
  on-tertiary-fixed: '#221b00'
  on-tertiary-fixed-variant: '#544600'
  background: '#1A1A2E'
  on-background: '#e2e1f2'
  surface-variant: '#333441'
  surface-elevated: '#1E2A4A'
  card-back: '#0F3460'
  success: '#4CAF50'
  text-primary: '#FFFFFF'
typography:
  display-hero:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: 1px
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '400'
    lineHeight: 30px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.5px
  stats-value:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 40px
  button-height: 60px
  card-gap: 12px
---

## Brand & Style
The brand personality is **Playful yet Accessible**, striking a careful balance between the high-energy excitement of a game and the clarity required for multi-generational use. It aims to evoke a sense of "Friendly Achievement"—rewarding for children and comfortable for senior citizens.

The design style is **Corporate / Modern with Tactile influences**. It utilizes the deep, immersive qualities of a dark interface but softens the "gamer" edge through generous rounding, high-contrast legibility, and clear functional signaling. The aesthetic moves away from aggressive neon glows toward soft, purposeful light and distinct physical metaphors (large, pressable surfaces).

- **High Accessibility**: Prioritizes motor-control-friendly targets and AAA contrast ratios.
- **Visual Hierarchy**: Uses scale and containment to guide the eye toward primary actions without cognitive overload.
- **Emotional Response**: Calming yet encouraging; the dark palette reduces eye strain, while the gold and crimson accents provide celebratory feedback.

## Colors
The palette is rooted in a **Dark Navy (#1A1A2E)** environment to provide a stable, low-strain backdrop. 

- **Primary & Secondary**: The Crimson Red and Soft Red are used sparingly for active states and critical UI elements to maintain their impact without overwhelming the user.
- **Success & Reward**: **Success Green (#4CAF50)** and **Gold (#FFD700)** are reserved strictly for positive reinforcement and achievement, creating a clear "color-language" for progress.
- **Contrast & Legibility**: All interactive elements must maintain a contrast ratio of at least 4.5:1 (WCAG AA) or 7:1 (WCAG AAA) against the background. 
- **Distinct Surfaces**: The `card-back` (#0F3460) is specifically chosen to be lighter and more saturated than the `background` to ensure cards are immediately identifiable as interactive objects.

## Typography
**Plus Jakarta Sans** is selected for its friendly, rounded terminals and exceptional legibility at large scales.

- **Legibility First**: Minimum body text is set to 18px to accommodate senior users. Label text for buttons and interactive elements is bolded and set to 20px.
- **Weight Usage**: Use `800` (ExtraBold) for celebratory headers and `400` (Regular) for descriptions. Avoid weights below 400 to maintain stroke thickness for visual clarity.
- **Line Height**: Generous line heights (1.5x for body) are used to prevent "text crowding," making the interface feel breathable and less intimidating.

## Layout & Spacing
The system follows a **Fluid Grid** model with high-margin "Safe Areas."

- **Layout Philosophy**: Content is centered to reduce eye travel. For card grids, a maximum width of 600px is recommended on tablets/desktop to keep the game within the central field of vision.
- **Rhythm**: An 8px base unit governs all dimensions. 
- **Ergonomics**: Interactive elements are spaced at least 16px apart to prevent accidental taps (fat-finger errors).
- **Mobile Reflow**: On mobile, the grid shifts to a maximum of 4 columns to ensure each card remains a large, accessible target.

## Elevation & Depth
Visual hierarchy is established through **Tonal Layers** and **Ambient Glows**:

- **Surface Tiering**: The `background` is the lowest layer. `surface` containers (16213E) represent the primary content area. `surface-elevated` (1E2A4A) is used for active modals or temporary overlays.
- **Shadows**: Use soft, diffused shadows with a slight `primary_color` tint for interactive elements. This creates a "lift" effect that signals clickability. 
- **Card States**: Use a subtle inner-glow when a card is selected to reinforce the 3D flip concept without relying solely on movement.

## Shapes
A **Rounded (0.5rem base)** shape language is used to maximize the "Playful" and "Safe" brand feel. 

- **Primary Buttons**: Use `rounded-xl` (1.5rem / 24px) to create a friendly, pill-like appearance that invites interaction.
- **Game Cards**: Use `rounded-lg` (1rem / 16px). This distinguishes cards from the more circular buttons while remaining softer than standard industrial UI.
- **Inputs & Containers**: Follow the `rounded-lg` standard for consistency.

## Components
- **Buttons**: Minimum height is 60px. Labels should be accompanied by a leading icon (Material Symbols Rounded) sized at 24px. Primary buttons use the Crimson Red fill with White text; secondary buttons use a Deep Blue surface with a 2px Crimson border.
- **Memory Cards**: Cards must have a distinct 3D depth. The "back" face should feature a simple, bold geometric pattern or logo. The "front" face uses a high-contrast icon (Success Green or Gold) against a clean White or light grey surface.
- **Chips/Badges**: Used for "New High Score" or "Stage Level." These should have a Gold background with Dark Navy text for maximum "reward" visibility.
- **Input Fields**: Large touch targets (min 56px height) with high-contrast borders (15% white overlay on surface color).
- **Progress Bars**: 12px height with rounded ends. Use the Secondary/Accent Light color for the track and Primary for the fill to show active progress.
- **Cards (Container)**: Used for stats and settings. Feature a 1px border using `neutral_color` at 20% opacity to define boundaries on the dark background.