---
name: Efficient Support System
colors:
  surface: '#fbf9f9'
  surface-dim: '#dbdad9'
  surface-bright: '#fbf9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f3'
  surface-container: '#efeded'
  surface-container-high: '#e9e8e7'
  surface-container-highest: '#e3e2e2'
  on-surface: '#1b1c1c'
  on-surface-variant: '#404752'
  inverse-surface: '#303031'
  inverse-on-surface: '#f2f0f0'
  outline: '#707883'
  outline-variant: '#bfc7d4'
  surface-tint: '#0061a4'
  primary: '#0061a4'
  on-primary: '#ffffff'
  primary-container: '#2196f3'
  on-primary-container: '#002c4f'
  inverse-primary: '#9ecaff'
  secondary: '#785900'
  on-secondary: '#ffffff'
  secondary-container: '#fdc003'
  on-secondary-container: '#6c5000'
  tertiary: '#006e1c'
  on-tertiary: '#ffffff'
  tertiary-container: '#42a547'
  on-tertiary-container: '#003308'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d1e4ff'
  primary-fixed-dim: '#9ecaff'
  on-primary-fixed: '#001d36'
  on-primary-fixed-variant: '#00497d'
  secondary-fixed: '#ffdf9e'
  secondary-fixed-dim: '#fabd00'
  on-secondary-fixed: '#261a00'
  on-secondary-fixed-variant: '#5b4300'
  tertiary-fixed: '#94f990'
  tertiary-fixed-dim: '#78dc77'
  on-tertiary-fixed: '#002204'
  on-tertiary-fixed-variant: '#005313'
  background: '#fbf9f9'
  on-background: '#1b1c1c'
  surface-variant: '#e3e2e2'
typography:
  display-lg:
    fontFamily: Roboto
    fontSize: 57px
    fontWeight: '400'
    lineHeight: 64px
    letterSpacing: -0.25px
  headline-lg:
    fontFamily: Roboto
    fontSize: 32px
    fontWeight: '400'
    lineHeight: 40px
  headline-md:
    fontFamily: Roboto
    fontSize: 28px
    fontWeight: '400'
    lineHeight: 36px
  headline-sm:
    fontFamily: Roboto
    fontSize: 24px
    fontWeight: '400'
    lineHeight: 32px
  title-lg:
    fontFamily: Roboto
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  title-md:
    fontFamily: Roboto
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
    letterSpacing: 0.15px
  body-lg:
    fontFamily: Roboto
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.5px
  body-md:
    fontFamily: Roboto
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.25px
  label-lg:
    fontFamily: Roboto
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-md:
    fontFamily: Roboto
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  margin-mobile: 16px
  gutter-mobile: 16px
---

## Brand & Style
This design system is built for a professional IT helpdesk environment where efficiency, clarity, and reliability are paramount. The aesthetic follows the **Corporate / Modern** movement, specifically leveraging the **Material Design 3 (M3)** framework to provide a familiar, systematic, and highly functional user interface.

The brand personality is authoritative yet approachable, aiming to reduce the cognitive load of support agents and end-users alike. The UI emphasizes a "clean desk" philosophy—removing unnecessary clutter to highlight actionable data and ticket statuses. The emotional response should be one of calm productivity and trust in the system's speed and accuracy.

## Colors
The palette is rooted in a professional blue primary, signifying stability and support. The secondary Amber is utilized sparingly for high-visibility accents, such as "Pending" statuses or urgent call-to-actions.

- **Primary (#2196F3):** Used for key action buttons, active states, and brand headers.
- **Secondary (#FFC107):** Reserved for highlighting priorities and warning-level notifications.
- **Semantic Colors:** Success (Green), Warning (Orange), and Error (Red) follow industry standards to ensure instant recognition of ticket health.
- **Neutrals:** The background and surface colors utilize a high-white contrast to ensure text readability and a "breathable" interface.

## Typography
The system uses **Roboto** as the sole typeface to maintain consistency with the Material 3 specification and ensure maximum legibility across different mobile screen densities.

- **Headlines:** Used for page titles and major section headers.
- **Titles:** Reserved for ticket subjects and card headers.
- **Body:** Standardized for ticket descriptions and comments.
- **Labels:** Applied to buttons, status tags (chips), and input field captions.
- **Scale:** On mobile, avoid `display` sizes unless used for empty-state illustrations. Use `title-lg` for top app bars.

## Layout & Spacing
This design system employs an **8px linear grid system**. All dimensions, padding, and margins must be multiples of 8 (or 4 for extremely tight alignments).

- **Mobile Layout:** Use a fluid grid with a standard 16px side margin.
- **Vertical Rhythm:** Use 16px spacing between cards in a list and 8px spacing between elements within a card.
- **Touch Targets:** Ensure all interactive elements have a minimum touch target of 48x48px, even if the visual representation is smaller.

## Elevation & Depth
Elevation is used functionally to indicate hierarchy and interactivity, adhering to the **Tonal Layers** approach of Material 3.

- **Level 0 (Flat):** Used for the main background.
- **Level 1 (Subtle):** Default state for cards and search bars. Use a very soft shadow (blur: 4px, opacity: 0.08) or a slight tonal tint.
- **Level 2:** Hover or pressed states for interactive cards.
- **Level 3:** Floating Action Buttons (FAB) and Dialogs to ensure they sit clearly above the primary content.
- **Style:** Avoid heavy, dark shadows. Use ambient, diffused shadows that feel integrated into the surface.

## Shapes
The shape language balances professionalism with modern softness.

- **Cards:** Use a `12px` to `16px` radius (Large) to containerize ticket information.
- **Buttons:** Use an `8px` radius (Medium) to maintain a more structured, "work-ready" appearance compared to the default M3 pill shape.
- **Inputs:** Use an `8px` radius for text fields to match the button style.
- **Chips/Tags:** Use a fully rounded (Pill) shape for status indicators (e.g., "Open", "Resolved").

## Components
- **Buttons:** Primary buttons use a solid #2196F3 fill with White `label-lg` text. Outlined buttons are used for secondary actions like "Cancel" or "Save Draft."
- **Chips:** Used for ticket categories and priorities. High-priority tickets use a light red background with dark red text; low-priority uses light grey.
- **Lists:** Ticket lists should use a "Clean Card" style with 16px internal padding and a 1px soft border or Level 1 elevation.
- **Input Fields:** Outlined text fields with an 8px corner radius. Focus states must use the Primary Blue with a 2px stroke.
- **Icons:** Use **Material Icons Rounded** exclusively to match the softened corners of the UI components.
- **FAB:** A primary blue Floating Action Button in the bottom-right corner is the dedicated trigger for "Create New Ticket."
- **Progress Indicators:** Use linear progress bars for ticket completion/SLA tracking, utilizing the Success green for on-track items and Warning orange for nearing deadlines.