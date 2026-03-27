xquery version "3.1";

(:~
 : Import mom-data from mounted eXist-db backup.
 :
 : Prerequisites:
 : 1. docker-compose.yml mounts the backup at /exist/import-data
 : 2. Restart container: docker compose down && docker compose up -d
 : 3. Run this script in eXide: http://localhost:8080/exist/apps/eXide/
 :
 : The backup directory structure should be:
 :   /exist/import-data/db/__contents__.xml
 :   /exist/import-data/db/mom-data/__contents__.xml
 :   /exist/import-data/db/mom-data/metadata.archive.public/...
 :   etc.
 :
 : WARNING: This restores ~860k XML files. It will take a while.
 : Monitor progress in the eXist-db logs.
 :)

let $backup-dir := "/exist/import-data"
let $admin-pass := ""

return
<result>
    <info>Starting restore from {$backup-dir}</info>
    <restore>{ system:restore($backup-dir, $admin-pass, true()) }</restore>
    <info>Restore completed.</info>
</result>
