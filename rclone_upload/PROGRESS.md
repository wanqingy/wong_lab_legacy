# BossDB upload progress

Source: `/mnt/e/Allen grant data/EM`
Destination: `bossdbwong:upload-bossdb-3gqks4kjnacpujok/wong_lab_retina/<dataset>/{filtered_tif,trakem}/`
Mapping: `mapping.tsv` (all) / `mapping_rest.tsv` (all except 89d). Script: `upload.sh [--dry-run] [--only SUBSTR] [mapping]`.
Last verified: 2026-10-18 (bucket object counts vs source file counts; xml sizes match source).

| Source folder | Dest dataset | tifs (bucket / source) | xml | Status |
|---|---|---|---|---|
| human-89d Fovea | human_89d_fovea | 8365 / 8365 | human-89d-fovea-tiles.xml | Done |
| 101d 17-CZ2a | human_101d_17-CZ2a | 12808 / 12808 | Human-101d-fovea-17-CZ2a 20190703.xml | Done |
| 108d fetaltest | human_108d_fetaltest | 2595 / 2596 | fetaltest-070517.xml | 1 file missing (see below) |
| 127d first round | human_127d_first_round | 12427 / 12427 | 127d-first-round -20180409.xml | Done |
| 90d 17-CZ1/Horizontal | human_90d_17-CZ1_horizontal | 2234 / 2234 | human-90d-fovea.xml | Done |
| 90d 17-CZ1/Vertical | human_90d_17-CZ1_vertical | 3996 / 3996 | human-90d-fovea-vertical.xml | Done |
| 145d round2 | (not decided) | - | - | Skipped by request; not in mapping |

## Issues
- **Unreadable source file:** `108d fetaltest/Tifs/fetal.75.6_3VBSED_stack_02_slice_0179.tif` (81 MB) gives `Input/output error` about 57 MB in when read from /mnt/e (likely bad sector). rclone fails with `RequestTimeout` on every retry. Needs a copy from another backup, `chkdsk E: /r`, or leaving it out.
- Uploading a single file with `copyto` initially failed with `s3:CreateBucket` AccessDenied (scoped user); fixed with `--s3-no-check-bucket` in `upload.sh`.

## Not uploaded (by choice)
Amira, stl/obj, dm4 raw, non-mipmap/rag, older xml versions, txt/xlsx import lists, BC/GC, test folders.

## Decisions pending
- 145d round2: which files, dest name. Its part1-5 tifs have colliding filenames, so use `filtered_tif/partN/`.

## Logs
`upload_*.log` in this folder; `run_89d.out`, `run_rest.out`.
