# export_trailhead_badge_ranking.sh

## Summary

The batch scrapes data from Trailhead profile pages and save `result.csv`.

Put a file, `trailhead.csv`, in the same directory.

`trailhead.csv` has Trailhead profile page URLs and user names.

### Example of input

File name: trailhead.csv

```csv
https://trailhead.com/me/example01, Username 01
https://trailhead.com/me/example02, Username 02
https://trailhead.com/me/example03, Username 03
```

### Example of output

File name: result.csv

```csv
01,109,72525,Ranger,Username 03,Name 03 on the Profile page
02,101,57200,Ranger,Username 01,Name 01 on the Profile page
03,100,27900,Mountaineer,Username 02,Name 02 on the Profile page
```
