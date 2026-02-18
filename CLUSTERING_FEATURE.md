# Clustering Feature for Admin Dashboard

## ✅ Feature Implemented

The admin dashboard now supports **intelligent clustering** of issues based on location and type.

## How It Works

### Clustering Logic
- **Groups issues** that are:
  - Same issue type (e.g., "Pothole", "Garbage Pile")
  - Within **100 meters** of each other (location tolerance: 0.0009 degrees)
  - Automatically calculates cluster center as average of all issue locations

### Priority Calculation
Clusters get **higher priority** based on:
1. **Number of reports**: More reports = higher priority (+10 points per additional report)
2. **Urgency level**: Critical > High > Medium > Low
3. **Age**: Older issues get priority boost
4. **Status**: "Reported" status adds priority

### Display Features

#### Cluster Card Shows:
- **Report count badge**: Number of reports in cluster
- **Issue type**: The type of issue (e.g., "Pothole")
- **Priority urgency**: Highest urgency in cluster
- **Location**: Representative address
- **Department**: Most common department
- **Priority score**: Calculated priority percentage
- **Status dropdown**: Update all issues in cluster at once

#### Expandable Details:
- Click to expand cluster card
- See representative image
- List all individual reports in cluster
- Update individual report statuses
- View all users who reported the issue

## Toggle Clustering

- **Switch in dashboard**: Toggle clustering on/off
- **When ON**: Shows clusters (grouped issues)
- **When OFF**: Shows individual issues (original view)

## Location Tolerance

- **Default**: 100 meters (0.0009 degrees)
- **Why**: People might stand slightly away when taking photos
- **Adjustable**: Can be changed in `clustering_helper.dart`

## Benefits

1. **Reduces clutter**: Multiple reports of same issue shown as one cluster
2. **Higher priority**: Clusters with more reports automatically get higher priority
3. **Better management**: Update all issues in cluster at once
4. **Visual clarity**: Clusters have higher elevation and colored borders

## Example

If 5 people report a pothole at the same location:
- **Without clustering**: 5 separate issue cards
- **With clustering**: 1 cluster card showing "5 reports"
- **Priority**: Automatically higher due to multiple reports

## Configuration

Location tolerance can be adjusted in:
```
Admin/Admin/lib/utils/clustering_helper.dart
```

Change `locationTolerance` constant (currently 0.0009 = ~100 meters)




