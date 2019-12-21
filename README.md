# whitelamp-backup

Personal rsync-based back-up with a simple config for multiple sources and destinations

Originally intended for backing up personal USB "master" drives to any devices that are configured to back it up.

Destination files are never deleted; instead, a trash file is updated indicating which destination files no longer exist in the source directory.

Copy backup.cfg.EXAMPLE to backup.cfg (ignored by Git) and edit.


