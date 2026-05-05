# Responsive Header Testing Guide

## Fixed Files
1. `lib/widgets/layout/frame.dart` - Made Frame responsive with dynamic height and padding
2. `lib/screens/game.dart` - Added responsive header for local game mode
3. `lib/screens/game_machine.dart` - Added responsive header for AI game mode  
4. `lib/screens/game_online.dart` - Added responsive header for online game mode
5. `lib/screens/play_with_friend.dart` - Added responsive header for friend game mode

## Responsive Features Implemented

### Frame Widget
- Dynamic height: 8% of screen height (clamped between 50-90px)
- Dynamic padding: 3% of screen width (clamped between 12-30px)

### Header Breakpoints
- **Small screens (< 600px)**: Compact layout
  - Icons: 20px (down from 25px)
  - Avatars: 30px (down from 40px)
  - Name font: 12px (down from 16px)
  - Status font: 10px (down from 12px)
  - Score font: 24px (down from 32px)
  - Spacing: 6px (down from 10px)
  - Hide player names and status text to save space

- **Medium/Large screens (≥ 600px)**: Full layout
  - All original sizes preserved
  - Complete information displayed

## Testing Instructions
1. Run the app on different screen sizes:
   - Mobile portrait (< 600px width)
   - Mobile landscape (> 600px width)  
   - Tablet (> 900px width)

2. Verify responsive behavior:
   - On small screens: Names and status should be hidden, elements should be smaller
   - On larger screens: All elements should be visible at normal sizes
   - Frame height should adjust proportionally
   - No overflow or layout issues

## Expected Results
- Headers adapt smoothly to different screen sizes
- No content overflow on small screens
- Maintains good visual hierarchy
- Preserves all functionality across breakpoints
