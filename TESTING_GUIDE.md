# iSee App - Testing Guide

**Version:** Beta V1.0.0  
**Last Updated:** October 25, 2025

## Testing Overview
This guide provides comprehensive testing procedures for all features of the iSee shoulder surfer detection app.

---

## Test Checklist

### 1. Visual Verification - Camera Island

**Steps:**
1. Look for the **iSee icon** in your menu bar (top-right of screen)
2. Click the menu bar icon
3. Select **"Toggle Camera Feed"**
4. Observe the camera island expanding from the notch

**What to verify:**
- [ ] Island appears from notch with smooth animation
- [ ] Camera feed shows at **433×260** dimensions
- [ ] Width is **443px** (should look narrower than before)
- [ ] Height is **280px** (10px padding + 260px camera + 10px padding)
- [ ] Aspect ratio looks correct (5:3 - slightly wider than 16:9)
- [ ] Face detection boxes appear correctly over your face
- [ ] Boxes stay within camera bounds (no overflow)

**Header Icons (left to right):**
- [ ] **X button** on far left (closes overlay)
- [ ] **Gear icon** on far right (opens settings)
- [ ] **Bell icon** next to gear (visual indicator)

---

### 2. Face Detection Overlay

**Steps:**
1. With camera feed open, position your face in view
2. Observe the green bounding box around your face
3. Have someone else (or use your phone) appear in frame

**What to verify:**
- [ ] **1 face**: Green box labeled "You"
- [ ] **2+ faces**: First box green ("You"), others red ("Other")
- [ ] Boxes are perfectly aligned with faces
- [ ] Boxes stay within **433×260** camera area
- [ ] No boxes extending beyond camera borders
- [ ] Box coordinates scale correctly with new dimensions

---

### 3. Notification Popups

**Steps:**
1. Click menu bar → **"Start Monitoring"** (if not already on)
2. Cover your face with your phone to trigger 2 faces
3. Wait ~2 seconds for alert to trigger
4. Observe notification popup in notch

**What to verify:**
- [ ] Notification appears in notch with animation
- [ ] Width is **443px** (matches camera island)
- [ ] Title: "Shoulder Surfer Detected!" or "Multiple People Detected"
- [ ] Dropdown menu (⋯) icon visible on right
- [ ] Click ⋯ → See "👁️ Preview" and "✓ Acknowledge" options
- [ ] Click "Preview" → Camera overlay opens
- [ ] Click "Acknowledge" → Notification dismisses

---

### 4. Width Consistency

**Steps:**
1. Open camera island ("Toggle Camera Feed")
2. Note the width
3. Trigger an alert notification
4. Compare notification width to camera island width

**What to verify:**
- [ ] Both have **exactly same width** (443px)
- [ ] No overflow or inconsistent sizing
- [ ] Both sit centered in the notch area
- [ ] Smooth animations for both

---

### 5. Stop Monitoring Test

**Steps:**
1. Ensure monitoring is ON
2. Open camera feed if needed
3. Click menu bar → **"Stop Monitoring"**

**What to verify:**
- [ ] Camera overlay closes immediately
- [ ] Face detection stops
- [ ] Button changes to "Start Monitoring"
- [ ] No crash or errors

---

### 6. Settings Integration

**Steps:**
1. Click **gear icon** in camera overlay header
   OR click menu bar → "Settings..."
2. Observe Settings window

**What to verify:**
- [ ] Settings window opens
- [ ] "Notifications" section visible
- [ ] "Auto-hide Delay" slider present (5-30 seconds)
- [ ] "Monitoring" section visible
- [ ] "Detection" section visible
- [ ] NO "Overlay Appearance" section (removed)

---

### 7. Auto-Dismiss Timer

**Steps:**
1. Open Settings → Set "Auto-hide Delay" to **5 seconds**
2. Close Settings
3. Open camera feed ("Toggle Camera Feed")
4. Start timer and wait

**What to verify:**
- [ ] Camera overlay auto-closes after **5 seconds**
- [ ] Smooth fade-out animation
- [ ] No errors

**Repeat with:**
- [ ] 10 seconds
- [ ] 30 seconds

---

### 8. Dimension Verification (Visual)

**Use these reference points:**

**Camera Feed:**
```
Width:  ━━━━━━━━━━━━━━━━━━━━━━━━ 433px
Height: │
        │
        │  260px
        │
        │
        ━
```

**Total Island:**
```
Width:  ━━━━━━━━━━━━━━━━━━━━━━━━━━ 443px
        (5px + 433px + 5px)

Height: 32px  (header)
        10px  (top padding)
        260px (camera)
        10px  (bottom padding)
        ────
        312px total
```

**Visual Comparison:**
- Island should be **~12% narrower** than before (500→443)
- Island should be **~10% shorter** than before (346→312)
- Should feel more compact and less intrusive

---

## Quick Visual Tests

### Test 1: Notch Integration
✅ **PASS** if:
- Island expands smoothly from notch
- Appears to grow out of notch seamlessly
- Header icons visible and clickable

❌ **FAIL** if:
- Island appears below notch
- Notch and island are visually separated
- Animation is jerky

### Test 2: Face Detection
✅ **PASS** if:
- Green box appears over your face
- Red boxes appear over other faces
- Boxes track face movement
- Boxes never exceed 433×260 camera area

❌ **FAIL** if:
- Boxes misaligned with faces
- Boxes extend beyond camera borders
- Detection doesn't work

### Test 3: Width Consistency
✅ **PASS** if:
- Camera island = 443px wide
- Notification popup = 443px wide
- Both look identical in width

❌ **FAIL** if:
- Different widths visible
- One appears wider than the other

---

## Performance Tests

### CPU Usage
1. Open Activity Monitor
2. Find "isee" process
3. Monitor CPU % while:
   - Camera feed open
   - Face detection active
   - Moving around

**Expected**: <20% CPU on M-series Macs

### Memory Usage
**Expected**: <150 MB RAM

### Battery Impact
With monitoring ON for 1 hour:
**Expected**: <5% battery drain

---

## Common Issues & Solutions

### Issue: App not in menu bar
**Solution**: Look for small icon in top-right, may be hidden in menu bar overflow

### Issue: Camera not showing
**Solution**: 
1. Check System Settings → Privacy & Security → Camera
2. Ensure "isee" is allowed
3. Restart app if needed

### Issue: Notifications not appearing
**Solution**:
1. Check System Settings → Notifications → isee
2. Ensure notifications are allowed
3. Click menu → Settings → Request Permissions

### Issue: Face detection not working
**Solution**:
1. Ensure good lighting
2. Face directly toward camera
3. Remove glasses/mask if needed
4. Check camera feed is working first

---

## Test Results Template

Copy and fill this out:

```
## Test Results - [Date]

### Visual Tests
- [ ] Camera island width: 443px ✓/✗
- [ ] Camera feed: 433×260 ✓/✗
- [ ] Face detection overlay matches: ✓/✗
- [ ] Notification width: 443px ✓/✗
- [ ] Width consistency: ✓/✗

### Functional Tests
- [ ] Toggle camera feed: ✓/✗
- [ ] Face detection works: ✓/✗
- [ ] Notifications trigger: ✓/✗
- [ ] Dropdown menu works: ✓/✗
- [ ] Preview button opens camera: ✓/✗
- [ ] Acknowledge button dismisses: ✓/✗
- [ ] Stop monitoring closes camera: ✓/✗
- [ ] Auto-dismiss timer works: ✓/✗

### Performance
- CPU usage: ___%
- Memory usage: ___MB
- Battery impact: Acceptable/High

### Issues Found
1. 
2. 
3. 

### Overall Rating
Pass/Fail/Needs Improvement
```

---

## Screenshot Checklist

Take screenshots of:
1. [ ] Camera island open (showing dimensions)
2. [ ] Face detection with 1 face (green box)
3. [ ] Face detection with 2 faces (green + red boxes)
4. [ ] Notification popup with dropdown menu open
5. [ ] Settings window
6. [ ] Menu bar dropdown

---

## Next Steps After Testing

If all tests **PASS**:
✅ Camera resize implementation successful!
✅ Ready for production use

If tests **FAIL**:
1. Document specific issues
2. Note which dimensions are incorrect
3. Check console logs for errors
4. Report back for fixes

---

## Need Help?

The app is currently running at PID 9580. You can:
- Test all features interactively
- Check the menu bar for the iSee icon
- Use "Toggle Camera Feed" to see the new dimensions
- Trigger alerts by covering your face with your phone

Let me know what you observe! 🚀


