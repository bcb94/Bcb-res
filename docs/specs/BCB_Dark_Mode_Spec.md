# Add Global Light / Dark Mode to BCB Command Center

> Source: Google Doc "ADD GLOBAL LIGHT / DARK MODE TO BCB COMMAND CENTER"
> (`14uSUaCzdscXLBIXL9VUmy9oeOv3-ASyOuG0ztbhsPzw`).
> Transcribed into the repository so coding sessions can read it as a file.

Add a subtle global theme toggle that allows users to switch between:

- **Light Mode** — the current BCB design
- **Dark Mode** — a professionally designed dark version of the same BCB design system

Do not redesign or change the current Light Mode. The current state should remain the default Light Mode.

## Toggle Placement

Add a small, subtle Light/Dark Mode toggle in an appropriate location within the main navigation/sidebar. Use a simple sun/moon icon or compact toggle control.

The toggle should:

- Be easy to find without becoming a prominent navigation feature.
- Match the existing BCB global design system.
- Transition smoothly between themes.
- Work consistently on desktop, tablet, and mobile.
- Remember each logged-in user's theme preference.

## Dark Mode Design

Do **NOT** simply invert the colors of the existing interface.

Create a proper BCB Dark Mode using the same design hierarchy as Light Mode. Use:

- Deep charcoal/navy as the primary application background.
- Slightly lighter navy/charcoal surfaces for cards.
- Subtle lighter surfaces for nested elements.
- Soft borders to separate cards and sections.
- Off-white/light gray primary text rather than harsh pure white everywhere.
- Muted gray-blue secondary text.
- Existing BCB blue as the primary accent color.
- Slightly brighter BCB blue where necessary to maintain accessibility and contrast.

The dark theme should retain the BCB blue/navy identity rather than looking like a generic black theme.

## Sidebar + Accordion Cards

Make sure the newly updated accordion navigation works properly in both themes.

In Dark Mode:

- Sidebar should use a deep navy/charcoal surface.
- Accordion cards should use a slightly lighter navy surface.
- Hover states should subtly brighten.
- Expanded cards should have a stronger navy/blue treatment.
- Active modules should use the BCB blue accent.
- Nested sub-features should remain visually distinguishable.
- Frequently Used should have its own subtle dark surface.
- Blue should remain slightly more visually prominent than the other navigation modules.

## Global Component Support

Dark Mode must apply to the ENTIRE BCB Command Center, not only the sidebar.

Update the global design system/theme variables so all existing components automatically support both Light and Dark Mode, including:

Page backgrounds; Navigation; Accordion cards; Dashboard cards; Tables; Forms; Inputs; Search bars; Dropdowns; Modals; Drawers; Tabs; Buttons; Filters; Status badges; Tooltips; Alerts; Charts; Calendars; Documents; Loading/skeleton states; Empty states; Borders; Shadows; Typography; Icons.

Do not manually style Dark Mode separately on every page if this can be handled through global theme variables/design tokens.

## Transitions

Switching between Light and Dark Mode should have a subtle, smooth transition.

Avoid: flashing; abrupt white-to-black changes; slow animations; excessive fading; reloading the page.

The transition should feel immediate and polished.

## User Preference

Save the user's selected theme preference so it persists between sessions and devices when possible.

Do not make the user select Dark Mode every time they log in.

Light Mode should remain the default for users who have never selected a theme.

## Important

Do not change: existing functionality; navigation structure; feature groupings; routes; permissions; data; existing BCB branding.

This is an extension of the GLOBAL BCB DESIGN SYSTEM.

The application should now have two professionally designed themes:

- **BCB LIGHT** — the current clean light design.
- **BCB DARK** — deep navy/charcoal, premium, high contrast, and construction-professional.

Both modes should feel like the exact same BCB Command Center rather than two separately designed applications.
