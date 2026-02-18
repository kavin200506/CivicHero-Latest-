# Priority Algorithms for Admin Dashboard

## ✅ Feature Implemented

The admin dashboard now includes **4 different priority algorithms** to sort issues/clusters based on different criteria.

## Available Algorithms

### 1. **Smart Priority** (Default)
- **How it works**: Uses the comprehensive priority calculation algorithm
- **Factors considered**:
  - Urgency level (Critical > High > Medium > Low)
  - Number of reports (more reports = higher priority)
  - Age of issue (older issues get priority boost)
  - Status (reported issues get extra priority)
- **Best for**: Overall priority management

### 2. **Recently Reported**
- **How it works**: Sorts by most recently reported first
- **Factors considered**:
  - Latest report date in cluster (for clusters)
  - Individual report date (for single issues)
- **Best for**: Seeing newest issues first

### 3. **Report Count**
- **How it works**: Sorts by number of people who reported the issue
- **Factors considered**:
  - Cluster size (more reports = higher priority)
  - For individual issues, falls back to smart priority
- **Best for**: Identifying issues that affect many people

### 4. **Risk Level**
- **How it works**: Sorts by urgency/severity level
- **Factors considered**:
  - Urgency: Critical > High > Medium > Low
  - Highest urgency in cluster (for clusters)
- **Best for**: Addressing most critical issues first

## Location

The priority algorithm selector is located:
- **In the sidebar** (left panel)
- **Below the "Hide Heatmap" button**
- **Easy to access** and change

## How It Works

1. **Select Algorithm**: Choose from dropdown
2. **Automatic Sorting**: Issues/clusters are immediately re-sorted
3. **Works with Clustering**: Applies to both clustered and individual views
4. **Works with Status Tabs**: Sorting applies within each status filter

## Algorithm Details

### Smart Priority Calculation

**For Individual Issues:**
```
Base Score = Urgency (Low: 10, Medium: 15, High: 25, Critical: 40)
+ Age Factor = (days old / 7) * 2.5 (max 30)
+ Status Bonus = +10 if still "Reported"
= Final Priority Score (0-100)
```

**For Clusters:**
```
Base Score = Highest Urgency in Cluster
+ Report Count Bonus = (count - 1) * 10 points per additional report
+ Age Factor = (days old / 7) * 2.5 (max 30)
+ Status Bonus = +10 if still "Reported"
= Final Priority Score (0-100)
```

### Example

**Cluster with 5 reports of a Critical pothole:**
- Smart Priority: 40 (Critical) + 40 (4 extra reports) + age + status = **High priority**
- Report Count: 5 reports = **Highest priority**
- Risk Level: Critical = **Highest priority**
- Recently Reported: Depends on when last reported

## Use Cases

- **Smart Priority**: Default view, balanced approach
- **Recently Reported**: Track new issues as they come in
- **Report Count**: Focus on issues affecting many people
- **Risk Level**: Address critical safety issues first

## Integration

- ✅ Works with **Status Tabs** (All, Reported, Assigned, etc.)
- ✅ Works with **Clustering** (enabled/disabled)
- ✅ Works with **Filters** (type, department, etc.)
- ✅ Updates **immediately** when changed




