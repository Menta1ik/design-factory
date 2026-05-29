# Windows PowerShell wrapper for Design Factory CLI
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
node "$ScriptPath\df" $args
