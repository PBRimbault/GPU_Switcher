# GPU_Switcher
A simple Powershell script that enables or disables my Laptop GPU depending on whether or not AC Power is connected to a laptop in Windows 11.

# The problem

So, my Dell Precision 5470 was giving poor battery life (1 - 2 hours). After hours of investigating using [HWiNFO](https://www.hwinfo.com/), I found that it was the Nvidia A1000 Laptop GPU momentarily switching on and of for a few seconds at random. This is a known and unresolved problem discussed [here](https://www.reddit.com/r/buildapc/comments/yjif7n/gpu_spikes_briefly_to_100_when_opening_task/). It was not only the GPU that had these spikes in power consumption, but it would also 'Wake-up' my CPU cores from their C-states, consuming even more power.

I did find that if I disabled the GPU in Device Manager, that:
1. The GPU did not register in HWiNFO and more importantly,
2. The power consumption of my laptop dropped way down to ~7 Watts at idle and ~10 Watts in general browsing - very acceptable in my opinion

However, it was tendious having to constantly check that the GPU was disabled when I unplugged my laptop from AC Power and then to have to do the reverse when I plugged it back in.

# The solution

The solution was quite obviously to automate the task of enabling and disabling the GPU based on the state of AC Power.

## Part 1 - Plug or Unplug while in use

I found this [excellent article over on DEV.to](https://dev.to/muhammedziyad/automatically-disable-and-enable-your-gpu-or-any-other-device-when-your-laptop-power-state-changes-hf5) that walked you through the enable/disable on the plug in/plug out event.

However, I found that on my laptop, the Event ID would trigger both the enable and disable scripts. This meant that, depending on which script was triggered first, the GPU enable/disable would either work as expected, or fail.

I modified the script to be an 'if' statement checker that checks the battery charging status as follows:

    if ((Get-WmiObject -Class BatteryStatus -Namespace root\wmi -ComputerName "localhost").PowerOnLine -ne $true)
    {
    pnputil /disable-device "PCI\VEN_10DE&DEV_25B9&SUBSYS_0B291028&REV_A1\4&103D730F&0&0008"
    }

    if ((Get-WmiObject -Class BatteryStatus -Namespace root\wmi -ComputerName "localhost").PowerOnLine)
    {
    pnputil /enable-device "PCI\VEN_10DE&DEV_25B9&SUBSYS_0B291028&REV_A1\4&103D730F&0&0008"
    }

This 'checker' was run in Powershell when triggered by the arguments:

    -ExecutionPolicy Bypass -FILE "C:\GPU_EnableDisable\gpu_check.ps1"

The script works really well for me and is pretty much 'debugged'.

## Part 2 - Check status at logon

To further extend this little script, I wanted the charging status of my laptop to be checked every time I restart, hibernate or sleep my laptop. This is because often I will close the laptop lid (put it to hibernate or sleep) and then unplug it. This 'unplug' would not be registered by the Part 1 event tracker. When I opened up the laptop again (with the power unplugged), the GPU would be enabled - which I didn't want.

This was a fairly simple task, using similar logic to the event tracker. Following the [guide from Doctor Scripto](https://devblogs.microsoft.com/scripting/use-powershell-to-create-job-that-runs-at-startup/), I created a task in Scheduler that would run every time I logged into my laptop. This 'on logon' approach was better than 'on startup' because it would cover all use cases from startup to waking the laptop up from sleep. 

# Conclusion

Now my laptop runs efficiently on battery and goes into power mode when I'm plugged into AC Power. A further tweak to the tasks was to run them with 'SYSTEM' priveldges. This prevented the Powershell window from opening, as disucssed [here](https://stackoverflow.com/questions/6568736/how-do-i-set-a-windows-scheduled-task-to-run-in-the-background/6568823#6568823). I would suggest only changing this setting once you've tested the script and have your use cases running properly, otherwise you will not have a visual check on what happens when you plug/unplug AC Power

![image](https://github.com/user-attachments/assets/d9bf9128-5339-4c89-b1dc-1d77e64783c7)

