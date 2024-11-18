if ((Get-WmiObject -Class BatteryStatus -Namespace root\wmi -ComputerName "localhost").PowerOnLine -ne $true)
{
pnputil /disable-device "PCI\VEN_10DE&DEV_25B9&SUBSYS_0B291028&REV_A1\4&103D730F&0&0008"
}

if ((Get-WmiObject -Class BatteryStatus -Namespace root\wmi -ComputerName "localhost").PowerOnLine)
{
pnputil /enable-device "PCI\VEN_10DE&DEV_25B9&SUBSYS_0B291028&REV_A1\4&103D730F&0&0008"
}